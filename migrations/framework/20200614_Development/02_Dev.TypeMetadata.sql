--liquibase formatted sql

--changeset vrafael:framework_20200310_Development_02_DevTypeMetadata logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [Dev].[TypeMetadata]
    @TypeTag dbo.string
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
       ,@TypeID_Relationship bigint = dbo.TypeIDByTag(N'Relationship')
       ,@TypeID_Object bigint = dbo.TypeIDByTag(N'Object')
       ,@TypeID bigint

    IF @TypeTag IS NOT NULL
    BEGIN
        SET @TypeID = dbo.TypeIDByTag(@TypeTag)

        IF @TypeID IS NULL
        BEGIN
            EXEC dbo.Error
                @TypeTag = N'SystemError'
                ,@Message = N'Не удалось определить тип по тегу "%s"'
                ,@p0 = @TypeTag
        END
    END
    ELSE
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
            ,@Message = N'Не указан тип записи'
    END

    SELECT TOP (1)
        o.ID
       ,o.Name
       ,d.Tag
       ,t.Icon
       ,sd.Tag as [State]
       ,ISNULL(t.Abstract, 0) as [Abstract]
       ,(
            SELECT
                cto.ID as TypeID
               ,cto.[Name] as TypeName
               ,ctd.[Tag] as TypeTag
               ,cto.[OwnerID]
               ,ctt.[Icon] as TypeIcon
               ,ctt.Abstract
            FROM dbo.DirectoryChildrenInline(o.ID, N'Type', 1) ct
                JOIN dbo.TObject cto ON cto.ID = ct.ID
                JOIN dbo.TDirectory ctd ON ctd.ID = cto.ID
                JOIN dbo.TType ctt ON ctt.ID = ctd.ID
            FOR JSON PATH
        ) as ChildrenTypes
       ,CAST(IIF(
            EXISTS(
                SELECT 1
                FROM dbo.DirectoryOwnersInline(@TypeID, N'Type', 1) ot
                WHERE ot.ID = @TypeID_Object
            ), 1, 0)
         as bit) as [Object]
       ,(
            SELECT 
                fs.[ID]
               ,fs.[TypeID] as [Type.ID]
               ,fs.[TypeName] as [Type.Name]
               ,fs.[TypeTag] as [Type.Tag]
               ,fs.[TypeIcon] as [Type.Icon]
               ,fs.[Name]
               ,fs.[Tag]
               ,fs.[Column]
               ,(   --ToDo кешировать
                    SELECT
                        cto.ID as TypeID
                       ,cto.[Name] as TypeName
                       ,ctd.[Tag] as TypeTag
                       ,cto.[OwnerID]
                       ,ctt.[Icon] as TypeIcon
                    FROM
                        (
                            SELECT
                                ct.ID
                               ,MAX(ct.Lvl) as Lvl
                            FROM dbo.DirectoryOwnersInline(o.ID, N'Type', 1) ot
                                JOIN dbo.TLink l ON l.OwnerID = fs.ID
                                    AND (l.CaseID = ot.ID OR l.CaseID IS NULL)
                                    AND l.TypeID = @TypeID_Relationship
                                CROSS APPLY dbo.DirectoryChildrenInline(l.TargetID, N'Type', 1) ct
                            GROUP BY ct.ID
                        ) ct
                        JOIN dbo.TObject cto ON cto.ID = ct.ID
                        JOIN dbo.TDirectory ctd ON ctd.ID = cto.ID
                        JOIN dbo.TType ctt ON ctt.ID = ctd.ID
                    WHERE fs.TypeTag in (N'FieldLink', 'FieldLinkToType')
                    ORDER BY
                        ct.Lvl
                    FOR JSON PATH
                ) as [Check.LinkRelationships]
               ,ROW_NUMBER() OVER(ORDER BY fs.Lvl DESC) as [Order]
               --,fs.[DataType]
            FROM dbo.FieldsByOwnerInline(o.ID, 1) fs
                JOIN dbo.TObject oo ON oo.ID = fs.OwnerID
                    AND oo.StateID = @StateID_Basic_Formed --показываем поля только сформированных типов 
            WHERE fs.StateID = @StateID_Basic_Formed
            ORDER BY
                fs.Lvl DESC
            FOR JSON PATH
        ) as Fields
       ,(
            SELECT
                l.LinkID as RelationID
               ,CONCAT(ISNULL(co.Name, oo.Name), N'.', fo.Name) as RelationName
               ,ISNULL(ct.Icon, ot.Icon) as TypeIcon
               ,ISNULL(cd.Tag, od.Tag) as TypeTag
               ,fd.Tag as FieldLinkTag
            FROM dbo.DirectoryOwnersInline(o.ID, N'Type', 1) oot 
                JOIN dbo.TLink l ON l.TargetID = oot.ID
                JOIN dbo.TDirectory fd 
                    JOIN dbo.TObject fo ON fo.ID = fd.ID
                        AND fo.StateID = @StateID_Basic_Formed
                ON fd.ID = l.OwnerID
                JOIN dbo.TDirectory od
                    JOIN dbo.TObject oo ON oo.ID = od.ID
                        AND oo.StateID = @StateID_Basic_Formed
                    JOIN dbo.TType ot ON ot.ID = od.ID
                ON od.ID = fo.OwnerID
                LEFT JOIN dbo.TDirectory cd
                    JOIN dbo.TObject co ON co.ID = cd.ID
                    JOIN dbo.TType ct ON ct.ID = cd.ID
                ON cd.ID = l.CaseID
            FOR JSON PATH
       ) as Relations
    FROM dbo.TObject o
        JOIN dbo.TDirectory d ON d.ID = o.ID
        JOIN dbo.TType t ON t.ID = d.ID
        LEFT JOIN dbo.TDirectory sd ON sd.ID = o.StateID
    WHERE o.ID = @TypeID
    FOR JSON PATH
END
--EXEC Dev.TypeMetadata @TypeTag = N'state'
GO
EXEC dbo.DatabaseObjectDescription
    @ObjectName = N'Dev.TypeMetadata'
   ,@Description = N'Метаданные типа по Идентификатору объекта или Типа'