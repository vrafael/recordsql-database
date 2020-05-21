--liquibase formatted sql

--changeset vrafael:framework_20200313_BeforeAfter_06_dboTypeDelBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
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
            FROM dbo.TDirectory d
                JOIN dbo.TType t ON t.ID = d.ID
            WHERE d.OwnerID = @ID
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
           ,v.ValueID
        FROM dbo.TValue v
            JOIN dbo.TLink l ON l.ValueID = v.ValueID
            CROSS APPLY dbo.TypeProcedureInline(v.TypeID, N'Del') dp
        WHERE v.CaseID = @ID
            OR l.LinkedID = @ID
        UNION ALL
        --и поля типа
        SELECT
            dp.ProcedureName
           ,d.ID
        FROM dbo.TObject o
            JOIN dbo.TDirectory d ON d.ID = o.ID   
            JOIN dbo.TField f ON f.ID = d.ID
            CROSS APPLY dbo.TypeProcedureInline(o.TypeID, N'Del') dp
        WHERE d.OwnerID = @ID;

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