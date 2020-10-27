--liquibase formatted sql

--changeset vrafael:framework_20200321_BeforeAfter_StateMachine_02_dboStateDelBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[StateDelBefore]
    @ID bigint
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @TransitionID bigint
       ,@CurID bigint
       ,@CurProcecureName dbo.string

    SELECT TOP (1)
        @TransitionID = t.ID
    FROM dbo.TTransition t
    WHERE t.SourceStateID = @ID
        OR t.TargetStateID = @ID

    IF @TransitionID IS NOT NULL
    BEGIN
        EXEC dbo.Error
            @Message = N'Состояние ID=%s нельзя удалить т.к. оно используется на переходе ID=%s'
           ,@p0 = @ID
           ,@p1 = @TransitionID
    END
END
GO