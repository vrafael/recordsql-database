--liquibase formatted sql

--changeset vrafael:framework_20200310_Metadata_02_dboTypeTree logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[TypeTree]
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
           ,t.Icon
           ,t.Abstract
           ,0 as Lvl
        FROM dbo.TDirectory d
            JOIN dbo.TType t ON t.ID = d.ID
        WHERE (d.OwnerID IS NULL)
        UNION ALL
        SELECT
            d.ID
           ,d.OwnerID
           ,t.Icon
           ,t.Abstract
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
       ,tr.OwnerID
       ,tr.Icon
       ,tr.Abstract
       ,(
            SELECT
                fo.ID
               ,fo.TypeID
               ,fo.TypeName
               ,fo.TypeIcon
               ,fo.StateName
               ,fo.StateColor
               ,fo.[Name]
            FROM dbo.TDirectory fd
                JOIN dbo.TField f ON f.ID = fd.ID
                CROSS APPLY dbo.ObjectInline(f.ID) fo
            WHERE fd.OwnerID = tr.ID
            ORDER BY f.[Order]
            FOR JSON PATH
        ) as Fields
    FROM Tree tr
        JOIN dbo.TObject o ON o.ID = tr.ID
        CROSS APPLY dbo.ObjectInline(o.ID) ot
    ORDER BY
        tr.Lvl
       ,tr.ID
    FOR JSON PATH
END
--EXEC dbo.TypeTree