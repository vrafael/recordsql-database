--liquibase formatted sql

--changeset vrafael:framework_20200226_BasicStateMachine_08_dboObjectStateTag logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER FUNCTION [dbo].[ObjectStateTag]
(
    @ID bigint
)
RETURNS nvarchar(512)
AS
BEGIN
    RETURN
    (
        SELECT TOP (1) sd.Tag
        FROM dbo.TObject o
            LEFT JOIN dbo.TDirectory sd ON sd.ID = o.StateID
        WHERE o.[ID] = @ID
    )
END
--SELECT dbo.ObjectStateTag(@ID)