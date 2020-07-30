--liquibase formatted sql

--changeset vrafael:framework_20200310_Development_02_DevTypeMetadata logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [Dev].[TypeMetadata]
    @ID bigint = NULL
   --,@TypeID dbo.link = NULL
   ,@TypeTag dbo.string --= NULL
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
       ,@TypeID_LinkValueType bigint = dbo.TypeIDByTag(N'LinkValueType')
       ,@TypeID bigint

    --IF @TypeID IS NULL
    --BEGIN
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
        ELSE IF @ID IS NOT NULL
        BEGIN
            SELECT TOP (1) 
                @TypeID = o.TypeID
            FROM dbo.TObject o
            WHERE o.ID = @ID

            IF @TypeID IS NULL
            BEGIN
                EXEC dbo.Error
                    @TypeTag = N'SystemError'
                   ,@Message = N'Не удалось определить тип объекта с идентификатором %s'
                   ,@p0 = @ID
            END
        END
        ELSE 
        BEGIN
            EXEC dbo.Error
                @TypeTag = N'SystemError'
               ,@Message = N'Не указан идентификатор объекта или тип записи'
        END
    /*END 
    ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.TType t 
            WHERE t.ID = @TypeID
        )
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не найден тип с идентификатором %s'
           ,@p0 = @TypeID
    END*/

    SELECT TOP (1)
        o.ID
       ,o.Name
       ,d.Tag
       ,t.Icon
       ,ISNULL(t.Abstract, 0) as [Abstract]
       ,(
            SELECT 
                fs.[ID]
               --,fs.[OwnerID] as [OwnerType.ID]
               --,oo.[Name] as [OwnerType.Name]
               --,fs.[OwnerTag] as [OwnerType.Tag]
               ,fs.[TypeID] as [Type.ID]
               ,fs.[TypeName] as [Type.Name]
               ,fs.[TypeTag] as [Type.Tag]
               ,fs.[TypeIcon] as [Type.Icon]
               ,fs.[Name]
               ,fs.[Tag]
               ,fs.[Column]
               ,(   --ToDo кешировать
                    SELECT
                        cto.ID --as ID
                        ,cto.[Name] --as TypeName
                        ,ctd.[Tag] --as TypeTag
                        ,ctd.[OwnerID] --as TypeOwnerID
                        ,ctt.[Icon] --as TypeIcon
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
       --,IIF(o.StateID = @StateID_Basic_Formed, ps.[ProcedureName], NULL) as [Procedures.Set]
       --,IIF(o.StateID = @StateID_Basic_Formed, pg.[ProcedureName], NULL) as [Procedures.Get]
       --,IIF(o.StateID = @StateID_Basic_Formed, pf.[ProcedureName], NULL) as [Procedures.Find]
       --,IIF(o.StateID = @StateID_Basic_Formed, pd.[ProcedureName], NULL) as [Procedures.Del]
    FROM dbo.TObject o
        JOIN dbo.TDirectory d ON d.ID = o.ID
        JOIN dbo.TType t ON t.ID = d.ID
        --OUTER APPLY dbo.TypeProcedureInline(t.ID, N'Set') ps
        --OUTER APPLY dbo.TypeProcedureInline(t.ID, N'Get') pg
        --OUTER APPLY dbo.TypeProcedureInline(t.ID, N'Find') pf
        --OUTER APPLY dbo.TypeProcedureInline(t.ID, N'Del') pd
    WHERE o.ID = @TypeID
    FOR JSON PATH
END
--EXEC Dev.TypeMetadata @TypeTag = 'state'
GO
EXEC dbo.DatabaseObjectDescription
    @ObjectName = N'Dev.TypeMetadata'
   ,@Description = N'Метаданные типа по Идентификатору объекта или Типа'