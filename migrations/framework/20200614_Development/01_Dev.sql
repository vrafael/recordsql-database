--liquibase formatted sql

--changeset vrafael:framework_20200310_Development_01_Dev logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
IF SCHEMA_ID(N'Dev') IS NULL
BEGIN
    EXECUTE (N'CREATE SCHEMA Dev AUTHORIZATION dbo')
END