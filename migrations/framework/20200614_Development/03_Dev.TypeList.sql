--liquibase formatted sql

--changeset vrafael:framework_20200310_Development_03_DevTypeList logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [Dev].[TypeList]
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE 
        @StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed');

    WITH Tree AS
    (
        SELECT
            d.ID
           ,d.OwnerID
           ,d.[Tag]
           ,t.Icon
           ,t.Abstract
           ,d.[Description]
           ,0 as Lvl
        FROM dbo.TDirectory d
            JOIN dbo.TType t ON t.ID = d.ID
        WHERE (d.OwnerID IS NULL)
        UNION ALL
        SELECT
            d.ID
           ,d.OwnerID
           ,d.[Tag]
           ,t.Icon
           ,t.Abstract
           ,d.[Description]
           ,c.Lvl + 1 as Lvl
        FROM [Tree] c
            JOIN dbo.TDirectory d ON d.OwnerID = c.ID
            JOIN dbo.TType t ON t.ID = d.ID
    )
    SELECT 
        ot.ID
       ,ot.TypeID
       ,ot.TypeName
       ,ot.TypeIcon
       ,ot.StateName
       ,ot.StateColor
       ,ot.[Name]
       ,tr.[Tag]
       ,tr.OwnerID
       ,tr.Icon
       ,tr.Abstract
       ,tr.[Description]
       /*,(
            SELECT
                fo.ID
               ,fo.TypeID
               ,fo.TypeName
               ,fo.TypeIcon
               ,fo.StateName
               ,fo.StateColor
               ,fo.[Name]
               ,fd.[Tag]
               ,fd.[Description]
            FROM dbo.TDirectory fd
                JOIN dbo.TField f ON f.ID = fd.ID
                CROSS APPLY dbo.ObjectInline(f.ID) fo
            WHERE fd.OwnerID = tr.ID
            ORDER BY f.[Order]
            FOR JSON PATH
        ) as Fields*/
    FROM Tree tr
        CROSS APPLY dbo.ObjectInline(tr.ID) ot
    ORDER BY
        tr.Lvl
       ,tr.ID
    FOR JSON PATH
END
--EXEC Dev.TypeList