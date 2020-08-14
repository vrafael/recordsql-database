--liquibase formatted sql

--changeset vrafael:framework_20200614_Development_05_DevRecordSet logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [Dev].[RecordSet]
    @TypeTag dbo.string = NULL
   ,@Set nvarchar(max)
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @ProcedureNameSet dbo.string
       ,@ProcedureNameGet dbo.string
       ,@TypeID bigint = JSON_VALUE(@Set,'$.Type.ID')
       ,@Identifier bigint --= JSON_VALUE(@Set,'$.ID')

    SET @TypeID = ISNULL(@TypeID, dbo.TypeIDByTag(@TypeTag)) --, (SELECT TOP (1) o.TypeID FROM dbo.TObject o WHERE o.ID = @Identifier))

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

    IF @ProcedureNameGet IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не удалось определить процедуру Get типа ID=%s'
           ,@p0 = @TypeID
    END

    EXEC @ProcedureNameSet
        @Identifier OUTPUT
       ,@TypeTag = @TypeTag
       ,@Set = @Set

    EXEC @ProcedureNameGet
        @Identifier
END
GO
EXEC dbo.DatabaseObjectDescription
    @ObjectName = N'Dev.RecordSet'
   ,@Description = N'Добавление/изменение записи'