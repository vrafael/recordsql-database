--liquibase formatted sql

--changeset vrafael:framework_20200614_Development_05_DevRecordSet logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [Dev].[RecordSet]
    @Set nvarchar(max)
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @ProcedureNameSet dbo.string
       ,@ProcedureNameGet dbo.string
       ,@TypeID bigint = JSON_VALUE(@Set,'$.Type.ID')
       ,@TypeTag dbo.string = JSON_VALUE(@Set,'$.Type.Tag')
       ,@ID bigint = JSON_VALUE(@Set,'$.ID')

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
        @ProcedureNameSet = tpis.ProcedureName
       ,@ProcedureNameGet = tpig.ProcedureName
    FROM dbo.TypeProcedureInline(@TypeID, N'Set') tpis
        OUTER APPLY dbo.TypeProcedureInline(@TypeID, N'Get') tpig

    IF @ProcedureNameSet IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не удалось определить процедуру Set типа ID=%s'
           ,@p0 = @TypeID
    END

    EXEC @ProcedureNameSet
        @ID OUTPUT
       ,@Set = @Set

    EXEC @ProcedureNameGet
        @ID   
END
GO
EXEC dbo.DatabaseObjectDescription
    @ObjectName = N'Dev.RecordSet'
   ,@Description = N'Добавление/изменение записи'