--liquibase formatted sql

--changeset vrafael:framework_20200218_09_dboDirectoryIDByTag logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER FUNCTION [dbo].[DirectoryIDByTag]
(
    @TypeTag dbo.string
   ,@Tag dbo.string
)
RETURNS bigint
AS
BEGIN
    RETURN
    (
        SELECT TOP (1)
            o.ID
        FROM dbo.DirectoryChildrenInline((SELECT 1 FROM dbo.TType t JOIN dbo.TDirectory td ON td.ID = t.ID WHERE td.Tag = @TypeTag), N'Type', 1) t
            JOIN dbo.TObject o ON o.TypeID = t.ID
            JOIN dbo.TDirectory d ON d.ID = o.ID
        WHERE (d.Tag = @Tag)
        ORDER BY t.Lvl
    )
END