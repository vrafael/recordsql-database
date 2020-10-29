--liquibase formatted sql

--changeset vrafael:framework_20200218_10_dboDirectoryIDByOwner logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
--объект справочника по владельцу
CREATE OR ALTER FUNCTION [dbo].[DirectoryIDByOwner]
(
    @TypeTag dbo.string
   ,@OwnerTag dbo.string
   ,@Tag dbo.string
)
RETURNS bigint
AS
BEGIN
    RETURN
    (
        SELECT TOP (1)
            o.ID
        FROM dbo.DirectoryChildrenInline((SELECT TOP (1) t.ID FROM dbo.TDirectory d JOIN dbo.TType t ON t.ID = d.ID WHERE d.[Tag] = @TypeTag), N'Type', 1) t --дочерние типы
            JOIN dbo.TObject o ON o.TypeID = t.ID
            JOIN dbo.TDirectory d ON d.ID = o.ID
            JOIN dbo.TObject oo ON oo.ID = o.OwnerID
            JOIN dbo.TDirectory do ON do.ID = oo.ID
        WHERE (d.[Tag] = @Tag)
            AND (do.[Tag] = @OwnerTag)
    )
END