--liquibase formatted sql

--changeset vrafael:framework_20200319_BeforeAfter_03_dboLinkValueTypeSetBefore logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[LinkValueTypeSetBefore]
    @ValueID bigint
   ,@TypeID bigint
   ,@OwnerID bigint
   ,@CaseID bigint
   ,@LinkedID bigint
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @TypeID_FieldLink bigint = dbo.TypeIDByTag(N'FieldLink')
       ,@ExistValueID bigint
       ,@ExistLinkedID bigint
       ,@ProcedureName dbo.string

    DECLARE
        @Links TABLE --список существующих рарешенных типов значений поля ссылки
        (
            ValueID bigint NOT NULL
           ,TypeID bigint NOT NULL
           ,LinkedID bigint NOT NULL
           ,Lvl int NOT NULL
        )

    IF @CaseID IS NOT NULL
        AND NOT EXISTS --один из родительких типов условия является владельцем поля ссылки
        (
            SELECT 1
            FROM dbo.DirectoryOwnersInline(@CaseID, N'Type', 1) ot
                JOIN dbo.TDirectory fd ON fd.OwnerID = ot.ID
                --JOIN dbo.TField f ON f.ID = fd.ID
                JOIN dbo.TObject fo ON fo.ID = fd.ID
                    AND fo.TypeID = @TypeID_FieldLink 
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
        FROM dbo.DirectoryOwnersInline(@LinkedID, N'Type', 0) ot
        UNION ALL
        SELECT
            ot.ID
           ,-ot.Lvl
        FROM dbo.DirectoryChildrenInline(@LinkedID, N'Type', 0) ot
    )
    INSERT INTO @Links 
    (
        ValueID
       ,TypeID
       ,LinkedID
       ,Lvl
    ) 
    SELECT
        v.ValueID
       ,v.TypeID
       ,l.LinkedID
       ,lt.Lvl
    FROM dbo.TValue v 
        JOIN dbo.TLink l WITH(UPDLOCK, ROWLOCK) ON l.LinkedID = v.ValueID
        JOIN LinkedTypes lt ON lt.ID = l.LinkedID
    WHERE ((@CaseID IS NULL AND v.CaseID IS NULL)
            OR v.CaseID = @CaseID)
        AND v.TypeID = @TypeID
        AND v.OwnerID = @OwnerID
        AND v.ValueID <> @ValueID --кроме текущего разрешения

    IF @@ROWCOUNT > 0
    BEGIN
        SELECT TOP (1) 
            @ExistValueID = l.ValueID
           ,@ExistLinkedID = l.Lvl
        FROM @Links l
        WHERE l.Lvl > 0 
        ORDER BY
            l.Lvl DESC

        IF @ExistValueID <> @ValueID
        BEGIN
            SELECT
                @ValueID = @ExistValueID
               ,@LinkedID = @ExistLinkedID
        END

        --удаляем лишние разрешения
        DECLARE cur_links_delete CURSOR LOCAL STATIC FORWARD_ONLY FOR
            SELECT
                l.ValueID
               ,dp.ProcedureName
            FROM @Links l
                CROSS APPLY dbo.TypeProcedureInline(l.TypeID, N'Del') dp
            WHERE l.ValueID <> @ValueID
        
        OPEN cur_links_delete
        FETCH NEXT FROM cur_links_delete INTO
            @ExistValueID
           ,@ProcedureName
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC @ProcedureName
                @ValueID = @ExistValueID
            
            FETCH NEXT FROM cur_links_delete INTO 
                @ExistValueID
               ,@ProcedureName
        END
        
        CLOSE cur_links_delete
        DEALLOCATE cur_links_delete
    END
END
GO