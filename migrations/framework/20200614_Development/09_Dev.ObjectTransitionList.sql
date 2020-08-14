--liquibase formatted sql

--changeset vrafael:framework_20200614_Development_09_DevTransitions logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [Dev].[ObjectTransitionList]
    @ID bigint
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE 
        @StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')

    SELECT
        tr.ID as TransitionID
       ,tro.Name as TransitionName
       ,trd.Description
       ,tst.Color
    FROM dbo.TObject o
        JOIN dbo.TObjectType ot ON ot.ID = o.TypeID
        JOIN dbo.TDirectory trd ON trd.OwnerID = ot.StateMachineID
        JOIN dbo.TObject tro ON tro.ID = trd.ID
            AND tro.StateID = @StateID_Basic_Formed
        JOIN dbo.TTransition tr ON tr.ID = trd.ID
            AND (tr.SourceStateID = o.StateID OR (o.StateID IS NULL AND tr.SourceStateID IS NULL))
        LEFT JOIN dbo.TState tst ON tst.ID = tr.TargetStateID
    WHERE o.ID = @ID
    ORDER BY tr.Priority
    FOR JSON PATH
END
--EXEC [Dev].[ObjectTransitionList] @ID = 215
GO