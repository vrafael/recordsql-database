--liquibase formatted sql

--changeset vrafael:framework_20200321_BeforeAfter_StateMachine_07_dboSchemaSetBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[SchemaSetBefore]
    @ID bigint
   ,@Name dbo.string OUTPUT
   ,@Tag dbo.string
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    IF SCHEMA_ID(@Tag) IS NULL
    BEGIN
        EXEC dbo.Error
            @Message = N'Не найдена схема "%s"'
           ,@p0 = @Tag
    END

    SET @Name = @Tag
END
GO