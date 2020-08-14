--liquibase formatted sql

--changeset vrafael:framework_20200614_Development_07_DevRecordDel logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [Dev].[RecordDel]
    @TypeTag dbo.string --=NULL
   ,@Identifier bigint
   --,@TypeID bigint = NULL
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @ProcedureName dbo.string
       ,@TypeID bigint = dbo.TypeIDByTag(@TypeTag)

    --SET @TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), (SELECT TOP (1) o.TypeID FROM dbo.TObject o WHERE o.ID = @Identifier))

    IF @TypeID IS NULL
    BEGIN
        IF @TypeTag IS NOT NULL
        BEGIN
            EXEC dbo.Error
                @TypeTag = N'SystemError'
               ,@Message = N'Не удалось определить тип по тегу "%s"'
               ,@p0 = @TypeTag
        END
        /*ELSE IF @Identifier IS NOT NULL
        BEGIN
            EXEC dbo.Error
                @TypeTag = N'SystemError'
               ,@Message = N'Не удалось определить тип объекта с идентификатором %s'
               ,@p0 = @Identifier
        END*/
        ELSE
        BEGIN
            EXEC dbo.Error
                @TypeTag = N'SystemError'
               ,@Message = N'Не указан тип записи'
               --,@Message = N'Не указан идентификатор объекта или тип записи'
        END
    END

    SELECT TOP (1)
        @ProcedureName = tpi.ProcedureName
    FROM dbo.TypeProcedureInline(@TypeID, N'Del') tpi

    IF @ProcedureName IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не удалось определить процедуру Del типа ID=%s'
           ,@p0 = @TypeID
    END

    EXEC @ProcedureName
        @Identifier
END
--EXEC Dev.RecordDel
GO
EXEC dbo.DatabaseObjectDescription
    @ObjectName = N'Dev.RecordDel'
   ,@Description = N'Удаление записи по Идентификатору объекта или по связке Идентификатор/Тип записи'