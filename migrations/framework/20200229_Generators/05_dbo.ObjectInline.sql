--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_05_dboObjectInline logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER FUNCTION [dbo].[ObjectInline]
(
    @ID bigint
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (1)
        o.ID as ID
       ,o.TypeID as TypeID
       ,ot.Name as TypeName
       ,t.Icon as TypeIcon
       ,os.Name  as StateName
       ,s.Color as StateColor
       ,ISNULL(o.Name, CAST(o.ID as nvarchar(512))) as [Name]
    FROM dbo.TObject o
        JOIN dbo.TType t ON t.ID = o.TypeID
        JOIN dbo.TObject ot ON ot.ID = t.ID
        LEFT JOIN dbo.TObject os 
            JOIN dbo.TState s ON s.ID = os.ID
        ON os.ID = o.StateID
    WHERE o.ID = @ID
)
