--liquibase formatted sql

--changeset vrafael:framework_20200614_Development_04_DevRecordGet logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [Dev].[RecordGet]
    @ID bigint
   ,@TypeID bigint = NULL
   ,@TypeTag dbo.string = NULL
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @ProcedureName dbo.string

    SET @TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), (SELECT TOP (1) o.TypeID FROM dbo.TObject o WHERE o.ID = @ID))

    IF @TypeID IS NULL
    BEGIN
        IF @TypeTag IS NOT NULL
        BEGIN
            EXEC dbo.Error
                @TypeTag = N'SystemError'
               ,@Message = N'Не удалось определить тип по тегу "%s"'
               ,@p0 = @TypeTag
        END
        ELSE IF @ID IS NOT NULL
        BEGIN
            EXEC dbo.Error
                @TypeTag = N'SystemError'
               ,@Message = N'Не удалось определить тип объекта с идентификатором %s'
               ,@p0 = @ID
        END
        ELSE
        BEGIN
            EXEC dbo.Error
                @TypeTag = N'SystemError'
               ,@Message = N'Не указан идентификатор объекта или тип записи'
        END
    END

    SELECT TOP (1)
        @ProcedureName = tpi.ProcedureName
    FROM dbo.TypeProcedureInline(@TypeID, N'Get') tpi

    IF @ProcedureName IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не удалось определить процедуру Get типа ID=%s'
           ,@p0 = @TypeID
    END

    EXEC @ProcedureName
        @ID
END
--EXEC Dev.RecordGet @ID = 173, @TypeTag = 'event'
GO
EXEC dbo.DatabaseObjectDescription
    @ObjectName = N'Dev.RecordGet'
   ,@Description = N'Получение записи по Идентификатору объекта или по связке Идентификатор/Тип записи'