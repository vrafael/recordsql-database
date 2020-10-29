--liquibase formatted sql

--changeset vrafael:framework_20200312_Relationships_01_dboRelationshipSetBefore logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[RelationshipSetBefore]
    @LinkID bigint OUTPUT
   ,@TypeID bigint
   ,@OwnerID bigint
   ,@CaseID bigint
   ,@TargetID bigint OUTPUT
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @TypeID_FieldLink bigint = dbo.TypeIDByTag(N'FieldLink')
       ,@ExistLinkID bigint
       ,@ExistTargetID bigint
       ,@ProcedureName dbo.string

    DECLARE
        @Links TABLE --список существующих разрешенных типов значений поля ссылки
        (
            LinkID bigint NOT NULL
           ,TypeID bigint NOT NULL
           ,TargetID bigint NOT NULL
           ,Lvl int NOT NULL
        )

    IF @CaseID IS NOT NULL
        AND NOT EXISTS --один из родительких типов условия является владельцем поля ссылки
        (
            SELECT 1
            FROM dbo.DirectoryOwnersInline(@CaseID, N'Type', 1) ot
                JOIN dbo.TObject fo ON fo.OwnerID = ot.ID
                    AND fo.TypeID = @TypeID_FieldLink
                --JOIN dbo.TField f ON f.ID = fd.ID
        )
    BEGIN
        EXEC dbo.Error
            @Message = N'Поле ID=%s не является полем типа ID=%s'
           ,@p0 = @OwnerID
           ,@p1 = @CaseID
    END;

    --ищем наивысший уровень допустимого типа ссылки
    WITH LinkedTypes AS
    (
        SELECT
            ot.ID
           ,ot.Lvl
        FROM dbo.DirectoryOwnersInline(@TargetID, N'Type', 0) ot
        UNION ALL
        SELECT
            ot.ID
           ,-ot.Lvl
        FROM dbo.DirectoryChildrenInline(@TargetID, N'Type', 0) ot
    )
    INSERT INTO @Links 
    (
        LinkID
       ,TypeID
       ,TargetID
       ,Lvl
    ) 
    SELECT
        l.LinkID
       ,l.TypeID
       ,l.TargetID
       ,lt.Lvl
    FROM dbo.TLink l WITH(UPDLOCK, ROWLOCK)
        JOIN LinkedTypes lt ON lt.ID = l.TargetID
    WHERE ((@CaseID IS NULL AND l.CaseID IS NULL)
            OR l.CaseID = @CaseID)
        AND l.TypeID = @TypeID
        AND l.OwnerID = @OwnerID
        AND l.LinkID <> @LinkID --кроме текущего разрешения

    IF @@ROWCOUNT > 0
    BEGIN
        SELECT TOP (1) 
            @ExistLinkID = l.LinkID
           ,@ExistTargetID = l.Lvl
        FROM @Links l
        WHERE l.Lvl > 0 
        ORDER BY
            l.Lvl DESC

        IF @ExistLinkID <> @LinkID
        BEGIN
            SELECT
                @LinkID = @ExistLinkID
               ,@TargetID = @ExistTargetID
        END

        --удаляем лишние разрешения
        DECLARE cur_links_delete CURSOR LOCAL STATIC FORWARD_ONLY FOR
            SELECT
                l.LinkID
               ,dp.ProcedureName
            FROM @Links l
                CROSS APPLY dbo.TypeProcedureInline(l.TypeID, N'Del') dp
            WHERE l.LinkID <> @LinkID
        
        OPEN cur_links_delete
        FETCH NEXT FROM cur_links_delete INTO
            @ExistLinkID
           ,@ProcedureName
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC @ProcedureName
                @LinkID = @ExistLinkID
            
            FETCH NEXT FROM cur_links_delete INTO 
                @ExistLinkID
               ,@ProcedureName
        END
        
        CLOSE cur_links_delete
        DEALLOCATE cur_links_delete
    END
END
GO