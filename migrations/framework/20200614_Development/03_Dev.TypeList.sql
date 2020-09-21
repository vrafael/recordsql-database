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
        @StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
       ,@TypeID_LinkValueType bigint = dbo.TypeIDByTag(N'LinkValueType');

    WITH Tree AS
    (
        SELECT
            o.ID
           ,o.OwnerID
           ,o.Name
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
           ,o.Name
           ,t.Icon
           ,t.Abstract
           ,c.Lvl + 1 as Lvl
        FROM [Tree] c
            JOIN dbo.TObject o ON o.OwnerID = c.ID
            JOIN dbo.TDirectory d ON d.ID = o.ID
            JOIN dbo.TType t ON t.ID = d.ID
    )
    SELECT 
        [type_object].[ID] as [_object.ID]
       ,[type_object].[TypeID] as [_object.TypeID]
       ,[type_object].[TypeName] as [_object.TypeName]
       ,[type_object].[TypeTag] as [_object.TypeTag]
       ,[type_object].[TypeIcon] as [_object.TypeIcon]
       ,[type_object].[StateName] as [_object.StateName]
       ,[type_object].[StateColor] as [_object.StateColor]
       ,[type_object].[Name] as [_object.Name]
       ,tr.ID
       ,tr.OwnerID
       ,tr.Name
       ,tr.Icon
       ,tr.Abstract
       ,d.[Tag]
       ,d.[Description]
       ,(
            SELECT 
                [field_object].[ID] as [_object.ID]
               ,[field_object].[TypeID] as [_object.TypeID]
               ,[field_object].[TypeName] as [_object.TypeName]
               ,[field_object].[TypeTag] as [_object.TypeTag]
               ,[field_object].[TypeIcon] as [_object.TypeIcon]
               ,[field_object].[StateName] as [_object.StateName]
               ,[field_object].[StateColor] as [_object.StateColor]
               ,[field_object].[Name] as [_object.Name]
               ,fo.[ID]
               ,fd.[Tag]
               ,CASE ftd.Tag
                    WHEN N'FieldLink' THEN CONCAT(fd.Tag, N'ID')
                    WHEN N'FieldLinkToType' THEN CONCAT(fd.Tag, N'ID')
                    ELSE fd.Tag
                END as [Column]
               ,ROW_NUMBER() OVER(ORDER BY ff.[Order]) as [Order]
               ,fd.[Description]
            FROM dbo.TObject fo
                JOIN dbo.TDirectory fd ON fd.ID = fo.ID
                JOIN dbo.TField ff ON ff.ID = fd.ID
                JOIN dbo.TDirectory ftd ON ftd.ID = fo.TypeID
                CROSS APPLY dbo.ObjectInline(fo.ID) [field_object]
            WHERE fo.OwnerID = tr.ID
                AND fo.StateID = @StateID_Basic_Formed --показываем поля только сформированных типов
            ORDER BY
                ff.[Order]
            FOR JSON PATH
        ) as Fields
    FROM Tree tr
        JOIN dbo.TDirectory d ON d.ID = tr.ID
        CROSS APPLY dbo.ObjectInline(tr.ID) [type_object]
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