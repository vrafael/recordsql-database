--liquibase formatted sql

--changeset vrafael:framework_20200226_04_dboObjectTransitionPush logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[ObjectTransitionPush]
    @ID dbo.link
   ,@TransitionID dbo.link = NULL
   ,@TransitionTag dbo.string = NULL
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

    DECLARE
        @TypeID bigint
       ,@CurrentStateID bigint
       ,@StateMachineID bigint
       ,@SourceStateID bigint
       ,@TargetStateID bigint
       ,@StoredProcedure dbo.string
       ,@TypeID_LinkToStoredProcedureOnTransition bigint = dbo.TypeIDByTag(N'LinkToStoredProcedureOnTransition')
       ,@TypeID_LinkToStoredProcedureOnState bigint = dbo.TypeIDByTag(N'LinkToStoredProcedureOnState')
       ,@CaseTransitionOrderID_Before bigint = dbo.DirectoryIDByTag(N'CaseTransitionOrder', N'Before')
       ,@CaseTransitionOrderID_After bigint = dbo.DirectoryIDByTag(N'CaseTransitionOrder', N'After')

    --список процедур на выполнение при изменении состояни
    DECLARE @TransitionStoredProcedures TABLE
    (
        StoredProcedure dbo.string NOT NULL
       ,[After] bit NOT NULL --до или после изменения статуса
       ,[Order] int IDENTITY(1, 1) NOT NULL
    )

    IF @TransitionID IS NULL
    BEGIN
        SELECT TOP (1)
            @TypeID = o.TypeID
           ,@CurrentStateID = o.StateID
           ,@StateMachineID = ot.StateMachineID
           ,@TransitionID = tr.TransitionID
           ,@SourceStateID = tr.SourceStateID
           ,@TargetStateID = tr.TargetStateID 
        FROM dbo.TObject o WITH(ROWLOCK, UPDLOCK) --блокируем строку объекта до завершения транзакции
            JOIN dbo.TObjectType ot ON ot.ID = o.TypeID
            OUTER APPLY
            (
                SELECT TOP(1)
                    tro.ID as TransitionID
                   ,tr.SourceStateID
                   ,tr.TargetStateID
                FROM dbo.TObject tro
                    JOIN dbo.TDirectory trd ON trd.ID = tro.ID
                    JOIN dbo.TDirectory sd ON sd.ID = tro.StateID
                        AND sd.[Tag] = N'Formed' --переход сформирован
                    JOIN dbo.TTransition tr ON tr.ID = tro.ID
                        AND (tr.SourceStateID = o.StateID --текущее состояние объекта равно исхдному состоянию перехода
                            OR (o.StateID IS NULL AND tr.SourceStateID IS NULL))
                WHERE tro.OwnerID = ot.StateMachineID
                    AND trd.[Tag] = @TransitionTag
                ORDER BY
                    tr.Priority
            ) tr
        WHERE o.ID = @ID
    END
    ELSE 
    BEGIN
        SELECT TOP (1)
            @TypeID = o.TypeID
           ,@CurrentStateID = o.StateID
           ,@StateMachineID = ot.StateMachineID
           ,@TransitionID = tr.TransitionID
           ,@SourceStateID = tr.SourceStateID
           ,@TargetStateID = tr.TargetStateID 
        FROM dbo.TObject o WITH(ROWLOCK, UPDLOCK) --блокируем строку объекта до завершения транзакции
            JOIN dbo.TObjectType ot ON ot.ID = o.TypeID
            OUTER APPLY
            (
                SELECT TOP(1)
                    tro.ID as TransitionID
                   ,tr.SourceStateID
                   ,tr.TargetStateID
                FROM dbo.TObject tro
                    JOIN dbo.TDirectory sd ON sd.ID = tro.StateID
                        AND sd.[Tag] = N'Formed' --переход сформирован
                    JOIN dbo.TTransition tr ON tr.ID = tro.ID
                        AND (tr.SourceStateID = o.StateID --текущее состояние объекта равно исхдному состоянию перехода
                            OR (o.StateID IS NULL AND tr.SourceStateID IS NULL))
                WHERE tro.OwnerID = ot.StateMachineID
                    AND tro.ID = @TransitionID
                ORDER BY 
                    tr.Priority
            ) tr
        WHERE o.ID = @ID
    END;

    IF @StateMachineID IS NULL
    BEGIN
        EXEC dbo.Error
            @Message = N'К типу ID=%s объекта ID=%s не привязан конечный автомат'
           ,@p0 = @TypeID
           ,@p1 = @ID
    END;

    IF @TransitionID IS NULL
    BEGIN
        EXEC dbo.Error
            @Message = N'В конечном автомате ID=%s объекта ID=%s типа ID=%s не найден активный переход состояний с кодом "%s"'
           ,@p0 = @StateMachineID
           ,@p1 = @ID
           ,@p2 = @TypeID
           ,@p3 = @TransitionTag
    END;

    WITH Owners AS
    (
        SELECT
            @SourceStateID as OwnerID
           ,@TypeID_LinkToStoredProcedureOnState as LinkTypeID
           ,@CaseTransitionOrderID_After as CaseID
           ,0 as [After]
           ,0 as [Order]
        UNION ALL
        SELECT
            @TransitionID as OwnerID
           ,@TypeID_LinkToStoredProcedureOnTransition as LinkTypeID
           ,@CaseTransitionOrderID_Before as CaseID
           ,0 as [After]
           ,1 as [Order]
        UNION ALL
        SELECT
            @TransitionID as OwnerID
           ,@TypeID_LinkToStoredProcedureOnTransition as LinkTypeID
           ,@CaseTransitionOrderID_After as CaseID
           ,1 as [After]
           ,0 as [Order]
        UNION ALL
        SELECT
            @SourceStateID as OwnerID
           ,@TypeID_LinkToStoredProcedureOnState as LinkTypeID
           ,@CaseTransitionOrderID_Before as CaseID
           ,1 as [After]
           ,1 as [Order]
    )
    INSERT INTO @TransitionStoredProcedures
    (
        StoredProcedure
       ,[After]
    )
    SELECT
        CONCAT(QUOTENAME(ssd.[Tag]), N'.', QUOTENAME(spd.[Tag])) as StoredProcedure
       ,ow.[After]
    FROM Owners ow
        JOIN dbo.TLink l ON l.TypeID = ow.LinkTypeID
            AND l.OwnerID = ow.OwnerID
            AND l.CaseID = ow.CaseID
        JOIN dbo.TDirectory spd 
            JOIN dbo.TObject spo ON spo.ID = spd.ID
        ON spd.ID = l.TargetID
        JOIN dbo.TDirectory ssd ON ssd.ID = spo.OwnerID
    --ToDo ??? Stored Procedure StateID or OBJECT_ID(CONCAT(so.[Name], N'.', pd.[Name]), 'P') IS NOT NULL
    ORDER BY
        ow.[After]
       ,ow.[Order]
       ,l.[Order];

    DECLARE cur_before CURSOR LOCAL STATIC FORWARD_ONLY FOR
        SELECT tsp.StoredProcedure
        FROM @TransitionStoredProcedures tsp
        WHERE tsp.[After] = 0
        ORDER BY tsp.[Order]

    DECLARE cur_after CURSOR LOCAL STATIC FORWARD_ONLY FOR
        SELECT tsp.StoredProcedure
        FROM @TransitionStoredProcedures tsp
        WHERE tsp.[After] = 1
        ORDER BY tsp.[Order]

    OPEN cur_before
    OPEN cur_after
    
    BEGIN TRAN

    FETCH NEXT FROM cur_before INTO @StoredProcedure
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC @StoredProcedure
            @ID = @ID
           ,@TransitionID = @TransitionID
        
        FETCH NEXT FROM cur_before INTO @StoredProcedure
    END

    UPDATE dbo.TObject
    SET [StateID] = @TargetStateID
    WHERE ID = @ID

    FETCH NEXT FROM cur_after INTO @StoredProcedure
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC @StoredProcedure
            @ID = @ID
           ,@TransitionID = @TransitionID

        FETCH NEXT FROM cur_after INTO @StoredProcedure
    END

    EXEC dbo.EventTransitionSet
        @TypeTag = N'EventTransition'
       ,@ObjectID = @ID
       ,@TransitionID = @TransitionID

    COMMIT
    
    CLOSE cur_before
    CLOSE cur_after
    DEALLOCATE cur_before
    DEALLOCATE cur_after
END
GO