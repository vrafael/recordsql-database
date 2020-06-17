--liquibase formatted sql

--changeset vrafael:framework_20200614_Development_04_DevRecordGet logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [Dev].[RecordGet]
    @ID bigint
   ,@TypeID bigint = NULL
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @ProcedureName dbo.string

    SET @TypeID = ISNULL(@TypeID, (SELECT TOP (1) o.TypeID FROM dbo.TObject o WHERE o.ID = @ID))

    IF @TypeID IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не удалось определить тип объекта ID=%s'
           ,@p0 = @ID
    END

    SELECT
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
--EXEC Dev.RecordGet @ID = 173, @TypeID = 71
GO