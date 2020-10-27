--liquibase formatted sql

--changeset vrafael:framework_20200310_Development_03_DevTypeTree logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [Dev].[TypeTree]
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE 
        @StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
       ,@TypeID_Relationship bigint = dbo.TypeIDByTag(N'Relationship')
       ,@TypeID_Module bigint = dbo.TypeIDByTag(N'Module');

    SELECT
        (
            SELECT
                o.ID
               ,o.OwnerID
               ,o.Name
               ,d.Tag
               ,d.[Description]
            FROM dbo.TObject o
                JOIN dbo.TDirectory d ON d.ID = o.ID
            WHERE o.TypeID = @TypeID_Module
            FOR JSON PATH, INCLUDE_NULL_VALUES
        ) as Modules
       ,(
            SELECT
                [type_object].[ID] as [_object.ID]
               ,[type_object].[TypeID] as [_object.TypeID]
               ,[type_object].[TypeName] as [_object.TypeName]
               ,[type_object].[TypeTag] as [_object.TypeTag]
               ,[type_object].[TypeIcon] as [_object.TypeIcon]
               ,[type_object].[StateName] as [_object.StateName]
               ,[type_object].[StateColor] as [_object.StateColor]
               ,[type_object].[Name] as [_object.Name]
               ,o.ID
               ,o.OwnerID
               ,o.Name
               ,d.[Tag]
               ,d.[Description]
               ,t.Icon
               ,t.Abstract
               ,t.ModuleID
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
                    WHERE fo.OwnerID = o.ID
                        AND fo.StateID = @StateID_Basic_Formed --показываем только сформированные поля
                    ORDER BY
                        ff.[Order]
                    FOR JSON PATH
                ) as Fields
            FROM dbo.TObject o
                JOIN dbo.TDirectory d ON d.ID = o.ID
                JOIN dbo.TType t ON t.ID = d.ID
                CROSS APPLY dbo.ObjectInline(o.ID) [type_object]
            --ORDER BY o.ID
            FOR JSON PATH, INCLUDE_NULL_VALUES
        ) as Types
    FOR JSON PATH
END
--EXEC Dev.TypeTree
GO
EXEC dbo.DatabaseObjectDescription
    @ObjectName = N'Dev.TypeTree'
   ,@Description = N'Список доступных типов и модулей в системе. Поле OwnerID указывает на родительский объект, от которого дочерний тип наследует все поля и обработчики CRUD'