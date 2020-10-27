--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_04_dboFieldsByOwnerInline logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
--список полей по владельцу
CREATE OR ALTER FUNCTION [dbo].[FieldsByOwnerInline]
(
    @OwnerID bigint
   ,@Owners bit = 0 --включая владельцев
)
RETURNS TABLE
AS
RETURN
(
    WITH Owners AS
    (
        SELECT 
            @OwnerID as ID
           ,0 as Lvl 
        UNION ALL 
        SELECT 
            o.OwnerID as ID
           ,ow.Lvl + 1 as Lvl
        FROM Owners ow 
            JOIN dbo.TObject o ON o.ID = ow.ID
        WHERE @Owners = 1
            AND o.OwnerID IS NOT NULL
    )
    SELECT
        o.ID as [ID]
       ,o.TypeID as [TypeID]
       ,ot.Name as [TypeName]
       ,td.Tag as [TypeTag]
       ,t.Icon as [TypeIcon]
       ,o.StateID as [StateID]
       --,so.Name as [StateName]
       ,o.Name as [Name]
       ,d.[Tag] as [Tag]
       ,o.OwnerID
       ,od.[Tag] as OwnerTag
       ,CASE td.Tag
            WHEN N'FieldLink' THEN CONCAT(d.Tag, N'ID')
            WHEN N'FieldLinkToType' THEN CONCAT(d.Tag, N'ID')
            ELSE d.Tag
        END as [Column]
       ,ft.DataType as [DataType]
       ,ow.Lvl
       ,f.[Order] as [Order]
    FROM Owners ow
        JOIN dbo.TObject o ON o.OwnerID = ow.ID
        JOIN dbo.TDirectory d ON d.ID = o.ID
        JOIN dbo.TField f ON f.ID = d.ID
        --Type
        JOIN dbo.TObject ot ON ot.ID = o.TypeID
        JOIN dbo.TDirectory td ON td.ID = ot.ID
        JOIN dbo.TType t ON t.ID = td.ID 
        JOIN dbo.TFieldType ft ON ft.ID = td.ID
        --State
        LEFT JOIN dbo.TObject so ON so.ID = o.StateID
        --Owner 
        JOIN dbo.TDirectory od ON od.ID = ow.ID
)
--SELECT * FROM dbo.FieldsByOwnerInline(1, 1)