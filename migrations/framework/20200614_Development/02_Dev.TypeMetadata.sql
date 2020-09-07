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
       ,@TypeID_LinkValueType bigint = dbo.TypeIDByTag(N'LinkValueType')
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
       ,ISNULL(t.Abstract, 0) as [Abstract]
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
                       ,ctd.[OwnerID] as TypeOwnerID
                       ,ctt.[Icon] as TypeIcon
                    FROM
                        (
                            SELECT
                                ct.ID
                                ,MAX(ct.Lvl) as Lvl
                            FROM dbo.DirectoryOwnersInline(o.ID, N'Type', 1) ot
                                JOIN dbo.TValue v ON v.OwnerID = fs.ID
                                    AND (v.CaseID = ot.ID OR v.CaseID IS NULL)
                                    AND v.TypeID = @TypeID_LinkValueType
                                JOIN dbo.TLink l ON l.ValueID = v.ValueID
                                CROSS APPLY dbo.DirectoryChildrenInline(l.LinkedID, N'Type', 1) ct
                            GROUP BY ct.ID
                        ) ct
                        JOIN dbo.TObject cto ON cto.ID = ct.ID
                        JOIN dbo.TDirectory ctd ON ctd.ID = cto.ID
                        JOIN dbo.TType ctt ON ctt.ID = ctd.ID
                    WHERE fs.TypeTag in (N'FieldLink', 'FieldLinkToType')
                    ORDER BY
                        ct.Lvl
                    FOR JSON PATH
                ) as [Check.FieldLinkValueType]
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
                CONCAT(ISNULL(co.Name, oo.Name), N'.', fo.Name) as RelationName
               ,ISNULL(cd.Tag, od.Tag) as TypeTag
               ,fd.Tag as FieldLinkTag
            FROM dbo.DirectoryOwnersInline(o.ID, N'Type', 1) ot 
                JOIN dbo.TLink l ON l.LinkedID = ot.ID
                JOIN dbo.TValue v ON v.ValueID = l.ValueID
                JOIN dbo.TDirectory fd 
                    JOIN dbo.TObject fo ON fo.ID = fd.ID
                        AND fo.StateID = @StateID_Basic_Formed
                ON fd.ID = v.OwnerID
                JOIN dbo.TDirectory od
                    JOIN dbo.TObject oo ON oo.ID = od.ID
                        AND oo.StateID = @StateID_Basic_Formed
                ON od.ID = fd.OwnerID
                LEFT JOIN dbo.TDirectory cd 
                    JOIN dbo.TObject co ON co.ID = cd.ID
                ON cd.ID = v.CaseID
            FOR JSON PATH
       ) as Relations
    FROM dbo.TObject o
        JOIN dbo.TDirectory d ON d.ID = o.ID
        JOIN dbo.TType t ON t.ID = d.ID
    WHERE o.ID = @TypeID
    FOR JSON PATH
END
--EXEC Dev.TypeMetadata @TypeTag = N'state'
GO
EXEC dbo.DatabaseObjectDescription
    @ObjectName = N'Dev.TypeMetadata'
   ,@Description = N'Метаданные типа по Идентификатору объекта или Типа'