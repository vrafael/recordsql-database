--liquibase formatted sql

--changeset vrafael:framework_20200321_BeforeAfter_05_dboTransitionSetAfter logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[TransitionSetAfter]
    @OwnerID bigint
   ,@SourceStateID bigint
   ,@TargetStateID bigint
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    --устанавливаем порядок переходов 
    UPDATE t
    SET t.Priority = ot.Priority
    FROM 
        (
            SELECT
                t.ID
               ,(ROW_NUMBER() OVER(ORDER BY ISNULL(NULLIF(t.[Priority], 0), 2147483646))) * 10 as [Priority]
            FROM dbo.TTransition t
                JOIN dbo.TDirectory d ON d.ID = t.ID
                    AND d.OwnerID = @OwnerID
            WHERE (t.SourceStateID = @SourceStateID
                    OR (@SourceStateID IS NULL AND t.SourceStateID IS NULL))
                AND (t.TargetStateID = @TargetStateID
                    OR (@TargetStateID IS NULL AND t.TargetStateID IS NULL))
        ) ot
        JOIN dbo.TTransition t ON t.ID = ot.ID
END
GO