--liquibase formatted sql

--changeset vrafael:framework_20200321_BeforeAfter_08_dboDatabaseObjectSetBefore logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[DatabaseObjectSetBefore]
    @ID bigint
   ,@TypeID bigint OUTPUT
   ,@Name dbo.string OUTPUT
   ,@OwnerID bigint
   ,@Tag dbo.string OUTPUT
   ,@object_id int OUTPUT
   ,@Script nvarchar(max)
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @ActualTypeID bigint

    SELECT 
        @Name = @Tag
       ,@Tag = NULLIF(LTRIM(RTRIM(@Tag)), N'')
    
    IF @Tag IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Запрещено создавать объект базы данных типа ID=%s без указания кода'
           ,@p0 = @TypeID
    END

    IF @OwnerID IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Запрещено создавать объект базы данных типа ID=%s с кодом "%s" без указания владельца'
           ,@p0 = @TypeID
           ,@p1 = @Tag
    END

    --запрет на изменение кода
    IF EXISTS
    (
        SELECT 1
        FROM dbo.TDirectory o
        WHERE o.ID = @ID
            AND o.[Tag] <> @Tag
    )
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Запрещено изменять код объекта базы данных ID=%s на %s'
           ,@p0 = @ID
           ,@p1 = @Tag
    END

    --получаем код владельца
    SELECT 
        @Name = CONCAT(do.[Tag], N'.', @Tag)
       ,@object_id = OBJECT_ID(CONCAT(QUOTENAME(do.[Tag]), N'.', QUOTENAME(@Tag)))
    FROM dbo.TDirectory do
    WHERE do.ID = @OwnerID

    IF (@object_id IS NULL)
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не найден объект базы данных "%s" типа ID=%s'
           ,@p0 = @Name
           ,@p1 = @TypeID
    END

    SELECT
        @ActualTypeID = 
            CASE so.[type]
                WHEN N'P' THEN dbo.TypeIDByTag(N'StoredProcedure')
                WHEN N'FN' THEN dbo.TypeIDByTag(N'ScalarFunction')
                WHEN N'TF' THEN dbo.TypeIDByTag(N'TableFunction')
                WHEN N'IF' THEN dbo.TypeIDByTag(N'InlineFunction')
                WHEN N'V' THEN dbo.TypeIDByTag(N'View')
                WHEN N'U' THEN dbo.TypeIDByTag(N'Table')
                ELSE NULL
            END
       ,@Script = sm.[definition]
    FROM sys.objects so
        JOIN sys.schemas ss ON so.schema_id = ss.schema_id
        LEFT JOIN sys.sql_modules sm ON sm.object_id = so.object_id
    WHERE so.object_id = @object_id
        AND so.is_ms_shipped = 0

    IF @ActualTypeID IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не удалось определить тип объекта "%s" по OBJECT_ID=%s'
           ,@p0 = @Name
           ,@p1 = @object_id;
    END

    SET @TypeID = ISNULL(@TypeID, @ActualTypeID)

    IF @TypeID <> @ActualTypeID
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Тип системного объекта "%s" указан неверно (указан тип ID=%s, актуальный тип ID=%s)'
           ,@p0 = @Name
           ,@p1 = @TypeID
           ,@p2 = @ActualTypeID;
    END;
END
GO