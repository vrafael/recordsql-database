--liquibase formatted sql

--changeset vrafael:framework_20200218_01_dboObjectNameByID logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER FUNCTION [dbo].[ObjectNameByID]
(
    @ID bigint
)
RETURNS dbo.string
AS
BEGIN
    RETURN
    (
        SELECT TOP (1)
            o.Name
        FROM dbo.TObject o
        WHERE o.ID = @ID
    )
END