--liquibase formatted sql

--changeset vrafael:framework_20200321_BeforeAfter_StateMachine_01_dboStateMachineDelBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[StateMachineDelBefore]
    @ID bigint
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @CurProcedureName dbo.string
       ,@CurID bigint

    DECLARE cur_del CURSOR LOCAL STATIC FORWARD_ONLY FOR
        --удаляем дочерние переходы и состояния
        SELECT
            dp.ProcedureName
           ,o.ID
        FROM 
            (
                SELECT
                    dbo.TypeIDByTag(N'Transition') as TypeID
                ,0 as [Order]
                UNION ALL
                SELECT
                    dbo.TypeIDByTag(N'State') as TypeID
                ,1 as [Order]
            ) ct 
            CROSS APPLY dbo.TypeProcedureInline(ct.TypeID, N'Del') dp
            JOIN dbo.TObject o ON o.TypeID = ct.TypeID
                AND o.OwnerID = @ID
        ORDER BY ct.[Order]

    OPEN cur_del
    FETCH NEXT FROM cur_del INTO 
        @CurProcedureName
       ,@CurID
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC @CurProcedureName
            @ID = @CurID
    	
    	FETCH NEXT FROM cur_del INTO 
            @CurProcedureName
           ,@CurID
    END
    
    CLOSE cur_del
    DEALLOCATE cur_del    
END
GO