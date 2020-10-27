--liquibase formatted sql

--changeset vrafael:framework_20200313_BeforeAfter_06_dboTypeDelBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[TypeDelBefore]
    @ID bigint
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @StateID bigint
       ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
       ,@ChildTypeID bigint
       --cursor
       ,@CurProcedureName dbo.string
       ,@CurID bigint

    SELECT TOP (1)
        @StateID = o.StateID
       ,@ChildTypeID = ct.ID
    FROM dbo.TObject o
        OUTER APPLY
        (
            SELECT TOP (1)
                t.ID
            FROM dbo.TObject o
                JOIN dbo.TType t ON t.ID = o.ID
            WHERE o.OwnerID = @ID
        ) ct
    WHERE o.ID = @ID

    --сформированный тип нельзя удалить    
    IF @StateID = @StateID_Basic_Formed
    BEGIN
        EXEC dbo.Error
            @Message = N'Для удаления тип ID=%s должен быть расформирован'
           ,@p0 = @ID
    END

    --проверяем наличие дочерних типов
    IF @ChildTypeID IS NOT NULL
    BEGIN
        EXEC dbo.Error
            @Message = N'Нельзя удалить тип ID=%s, т.к. от него наследуется другой тип ID=%s'
           ,@p0 = @ID
           ,@p1 = @ChildTypeID
    END

    DECLARE cur_del CURSOR LOCAL STATIC FORWARD_ONLY FOR
        --удаляем связи с другими типами 
        SELECT
            dp.ProcedureName
           ,l.LinkID
        FROM dbo.TLink l
            CROSS APPLY dbo.TypeProcedureInline(l.TypeID, N'Del') dp
        WHERE l.CaseID = @ID
            OR l.TargetID = @ID
        UNION ALL
        --и поля типа
        SELECT
            dp.ProcedureName
           ,o.ID
        FROM dbo.TObject o   
            JOIN dbo.TField f ON f.ID = o.ID
            CROSS APPLY dbo.TypeProcedureInline(o.TypeID, N'Del') dp
        WHERE o.OwnerID = @ID;

    OPEN cur_del
    FETCH NEXT FROM cur_del INTO 
        @CurProcedureName
       ,@CurID
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC @CurProcedureName
            @CurID --первый параметр процедуры удаления всегда является идентификатором записи
    	
    	FETCH NEXT FROM cur_del INTO 
            @CurProcedureName
           ,@CurID
    END
    
    CLOSE cur_del
    DEALLOCATE cur_del    
END
GO