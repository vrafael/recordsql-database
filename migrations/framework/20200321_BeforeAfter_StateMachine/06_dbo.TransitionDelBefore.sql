--liquibase formatted sql

--changeset vrafael:framework_20200321_BeforeAfter_StateMachine_06_dboTransitionDelBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[TransitionDelBefore]
    @ID bigint
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    --запрет на уделение перехода при наличии событий
    IF EXISTS
    (
        SELECT 1
        FROM dbo.VEventTransition et
        WHERE et.TransitionID = @ID
    )
    BEGIN
        EXEC dbo.Error
            @Message = N'Запрещено удалять переход ID=%s т.к. зарегистрированы события этого перехода'
           ,@p0 = @ID
    END
END
GO