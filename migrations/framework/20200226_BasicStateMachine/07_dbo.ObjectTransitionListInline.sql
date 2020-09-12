--liquibase formatted sql

--changeset vrafael:framework_20200226_BasicStateMachine_07_dboObjectTransitionListInline logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
--список возможных переходов состояний для объекта
CREATE OR ALTER FUNCTION [dbo].[ObjectTransitionListInline]
(
    @ID bigint
) 
RETURNS TABLE
AS
RETURN
(
    SELECT
        tr.ID as TransitionID
       ,tro.Name as TransitionName
       ,trd.Description
       ,tst.Color
    FROM dbo.TObject o
        JOIN dbo.TObjectType ot ON ot.ID = o.TypeID
        JOIN dbo.TObject tro
            JOIN dbo.TDirectory trd ON trd.ID = tro.ID
            JOIN dbo.TDirectory sd ON sd.ID = tro.StateID
                AND sd.Tag = N'Formed'
        ON tro.OwnerID = ot.StateMachineID
        JOIN dbo.TTransition tr ON tr.ID = trd.ID
            AND (tr.SourceStateID = o.StateID OR (o.StateID IS NULL AND tr.SourceStateID IS NULL))
        LEFT JOIN dbo.TState tst ON tst.ID = tr.TargetStateID
    WHERE o.ID = @ID
    --ORDER BY tr.Priority
)
--SELECT * FROM dbo.ObjectTransitionListInline(1)
GO