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
        @ProcedureName dbo.string
       ,@TypeID bigint = JSON_VALUE(@Set,'$.Type.ID')

    IF @TypeID IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не удалось определить тип объекта'
    END

    SELECT
        @ProcedureName = tpi.ProcedureName
    FROM dbo.TypeProcedureInline(@TypeID, N'Set') tpi

    IF @ProcedureName IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не удалось определить процедуру Set типа ID=%s'
           ,@p0 = @TypeID
    END

    EXEC @ProcedureName
       @Set = @Set
END
GO