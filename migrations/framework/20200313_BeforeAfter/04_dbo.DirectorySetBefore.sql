--liquibase formatted sql

--changeset vrafael:framework_20200313_BeforeAfter_04_dboDirectorySetBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[DirectorySetBefore]
    @ID bigint
   ,@TypeID bigint
   ,@Name dbo.string OUTPUT
   ,@Tag dbo.string
   ,@OwnerID bigint
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @OwnerID_Temp bigint

    SET @Name = NULLIF(LTRIM(RTRIM(@Name)), N'')

    IF (@Name IS NULL)
        AND(NULLIF(LTRIM(RTRIM(@Tag)), N'') IS NULL)
    BEGIN
        EXEC dbo.Error
            @Message = N'Нельзя добавлять объекты типа ID=%s в справочник без указания наименования или кода'
           ,@p0 = @TypeID
    END;

    --ToDo проверка на уникальность объекта по коду аналогично v1

    --защита от зацикливния по OwnerID
    IF @OwnerID IS NOT NULL
    BEGIN
        SET @OwnerID_Temp = @OwnerID

        WHILE @OwnerID_Temp IS NOT NULL
        BEGIN
            SELECT @OwnerID_Temp = d.OwnerID
            FROM dbo.TDirectory d
            WHERE d.ID = @OwnerID_Temp

            IF @@ROWCOUNT = 0
            BEGIN
                BREAK
            END

            IF @OwnerID_Temp = @OwnerID
            BEGIN
                EXEC dbo.Error
                    @Message = N'Обнаружено зацикливание в цепочке владельцев объекта ID=%s'
                   ,@p0 = @ID
            END
        END
    END
END
GO