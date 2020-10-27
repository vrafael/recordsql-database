--liquibase formatted sql

--changeset vrafael:framework_20200218_02_dboTypeIDByTag logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER FUNCTION [dbo].[TypeIDByTag]
(
    @TypeTag dbo.string
)
RETURNS bigint
AS
BEGIN
    RETURN
    (
        SELECT TOP (1) t.ID
        FROM dbo.TType t
            JOIN dbo.TDirectory d ON d.ID = t.ID
        WHERE d.[Tag] = @TypeTag
    )
END
--SELECT dbo.TypeIDByTag(N'Object')
