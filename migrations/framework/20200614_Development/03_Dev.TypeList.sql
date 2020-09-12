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
            o.ID
           ,o.OwnerID
           ,t.Icon
           ,t.Abstract
           ,0 as Lvl
        FROM dbo.TObject o
            JOIN dbo.TDirectory d ON d.ID = o.ID
            JOIN dbo.TType t ON t.ID = d.ID
        WHERE (o.OwnerID IS NULL)
        UNION ALL
        SELECT
            o.ID
           ,o.OwnerID
           ,t.Icon
           ,t.Abstract
           ,c.Lvl + 1 as Lvl
        FROM [Tree] c
            JOIN dbo.TObject o ON o.OwnerID = c.ID
            JOIN dbo.TDirectory d ON d.ID = o.ID
            JOIN dbo.TType t ON t.ID = d.ID
    )
    SELECT 
        ot.ID
       ,ot.TypeID
       ,ot.TypeName
       ,ot.TypeIcon
       ,ot.StateName
       ,ot.StateColor
       ,tr.OwnerID
       ,ot.[Name]
       ,d.[Tag]
       ,tr.Icon
       ,tr.Abstract
       ,d.[Description]
    FROM Tree tr
        JOIN dbo.TDirectory d ON d.ID = tr.ID 
        CROSS APPLY dbo.ObjectInline(tr.ID) ot
    ORDER BY
        tr.Lvl
       ,tr.ID
    FOR JSON PATH, INCLUDE_NULL_VALUES
END
--EXEC Dev.TypeList
GO
EXEC dbo.DatabaseObjectDescription
    @ObjectName = N'Dev.TypeList'
   ,@Description = N'Список всех доступных типов в системе. Поле OwnerID указывает на родительский тип, от которого дочерний тип наследует все поля и обработчики CRUD'