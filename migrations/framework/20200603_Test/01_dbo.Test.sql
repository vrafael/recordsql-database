--liquibase formatted sql

--changeset vrafael:framework_20200603_Test_01_dboTest logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true context:dev,test
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[Test]
    @Step int = 100
   ,@Count int = 10
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    SELECT TOP (@Count)
        ROW_NUMBER() OVER(ORDER BY so.object_id) * @Step as [Number]
    FROM sys.objects so
    FOR JSON PATH
END
--EXEC dbo.Test @Step = 1, @Count = 5