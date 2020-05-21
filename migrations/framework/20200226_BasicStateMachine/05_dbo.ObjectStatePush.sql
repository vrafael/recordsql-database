--liquibase formatted sql

--changeset vrafael:framework_20200226_05_dboObjectStatePush logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[ObjectStatePush]
    @ID dbo.link
   ,@StateID dbo.link = NULL
   ,@StateTag dbo.string = NULL
   ,@Strict bit = 0
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

    DECLARE
        @TypeID bigint
       ,@TransitionID bigint
       ,@CurrentStateID bigint
       ,@StateMachineID bigint
       ,@SourceStateID bigint
       ,@TargetStateID bigint
       ,@StoredProcedure dbo.string
       ,@TypeID_LinkToStoredProcedureOnTransition bigint = dbo.TypeIDByTag(N'LinkToStoredProcedureOnTransition')
       ,@TypeID_LinkToStoredProcedureOnState bigint = dbo.TypeIDByTag(N'LinkToStoredProcedureOnState')
       ,@LinkCaseTransitionID_Before bigint = dbo.DirectoryIDByTag(N'LinkCaseTransition', N'Before')
       ,@LinkCaseTransitionID_After bigint = dbo.DirectoryIDByTag(N'LinkCaseTransition', N'After')

    --список процедур на выполнение при изменении состояни
    DECLARE @TransitionStoredProcedures TABLE
    (
        StoredProcedure dbo.string NOT NULL
       ,[After] bit NOT NULL --до или после изменения статуса
       ,[Order] int IDENTITY(1, 1) NOT NULL
    )

    SET @StateTag = NULLIF(LTRIM(RTRIM(@StateTag)), N'')

    IF @StateID IS NULL
    BEGIN
        SELECT TOP (1)
            @TypeID = o.TypeID
           ,@CurrentStateID = o.StateID
           ,@StateMachineID = ot.StateMachineID
           ,@StateID = st.StateID
           ,@TransitionID = tr.TransitionID
           ,@SourceStateID = tr.SourceStateID
           ,@TargetStateID = tr.TargetStateID
        FROM dbo.TObject o WITH(ROWLOCK, UPDLOCK) --блокируем строку объекта до завершения транзакции
            JOIN dbo.TObjectType ot ON ot.ID = o.TypeID
            OUTER APPLY --State
            (
                SELECT TOP (1)
                    s.ID as StateID
                FROM dbo.TDirectory sd
                    JOIN dbo.TObject so
                        JOIN dbo.TDirectory ssd ON ssd.ID = so.StateID
                            AND ssd.[Tag] = N'Formed' 
                    ON so.ID = sd.ID
                    JOIN dbo.TState s ON s.ID = sd.ID
                WHERE sd.OwnerID = ot.StateMachineID
                    AND sd.[Tag] = @StateTag
            ) st
            OUTER APPLY --Transition
            (
                SELECT TOP(1)
                    trd.ID as TransitionID
                   ,tr.SourceStateID
                   ,tr.TargetStateID
                FROM dbo.TDirectory trd
                    JOIN dbo.TObject tro ON tro.ID = trd.ID
                    JOIN dbo.TDirectory tsd ON tsd.ID = tro.StateID
                        AND tsd.[Tag] = N'Formed' --переход сформирован
                    JOIN dbo.TTransition tr ON tr.ID = trd.ID
                        AND (tr.SourceStateID = o.StateID --текущее состояние объекта равно исходному состоянию перехода
                            OR (tr.SourceStateID IS NULL AND o.StateID IS NULL))
                        AND (tr.TargetStateID = st.StateID --конечное состояние объекта равно найденному по коду состоянию
                            OR (tr.TargetStateID IS NULL AND st.StateID IS NULL))
                WHERE trd.OwnerID = ot.StateMachineID
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
            CROSS APPLY --State
            (
                SELECT TOP (1)
                    s.ID as StateID
                FROM dbo.TObject so
                    JOIN dbo.TDirectory ssd ON ssd.ID = so.StateID
                        AND ssd.[Tag] = N'Formed'
                    JOIN dbo.TDirectory sd ON sd.ID = so.ID
                        AND sd.OwnerID = ot.StateMachineID
                    JOIN dbo.TState s ON s.ID = sd.ID
                WHERE so.ID = @StateID
            ) st
            CROSS APPLY --Transition
            (
                SELECT TOP(1)
                    trd.ID as TransitionID
                   ,tr.SourceStateID
                   ,tr.TargetStateID
                FROM dbo.TDirectory trd
                    JOIN dbo.TObject tro ON tro.ID = trd.ID
                    JOIN dbo.TDirectory sd ON sd.ID = tro.StateID
                        AND sd.[Tag] = N'Formed' --переход сформирован
                    JOIN dbo.TTransition tr ON tr.ID = trd.ID
                        AND (tr.SourceStateID = o.StateID --текущее состояние объекта равно исхдному состоянию перехода
                            OR (o.StateID IS NULL AND tr.SourceStateID IS NULL))
                        AND tr.TargetStateID = st.StateID
                WHERE trd.OwnerID = ot.StateMachineID
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

    IF @StateTag IS NOT NULL
        AND @StateID IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Для конечного автомата ID=%s объекта ID=%s не найдено состояние по коду "%s"'
           ,@p0 = @StateMachineID
           ,@p1 = @ID
           ,@p2 = @StateTag
    END

    IF @TransitionID IS NULL
    BEGIN
        --если жесткое условие наличия перехода не задано и текущее состояние равно конечному состоянию
        IF @Strict = 0 
            AND ISNULL(@CurrentStateID, 0) = ISNULL(@StateID, 0)
        BEGIN
            --то выполнение перехода можно не производить
            RETURN 0
        END
            
        EXEC dbo.Error
            @Message = N'В конечном автомате ID=%s объекта ID=%s типа ID=%s не найден активный переход состояний в состояние ID=%s'
           ,@p0 = @StateMachineID
           ,@p1 = @ID
           ,@p2 = @TypeID
           ,@p3 = @StateID 
    END;
           
    WITH Owners AS
    (
        SELECT
            @SourceStateID as OwnerID
           ,@TypeID_LinkToStoredProcedureOnState as LinkTypeID
           ,@LinkCaseTransitionID_After as CaseID
           ,0 as [After]
           ,0 as [Order]
        UNION ALL
        SELECT
            @TransitionID as OwnerID
           ,@TypeID_LinkToStoredProcedureOnTransition as LinkTypeID
           ,@LinkCaseTransitionID_Before as CaseID
           ,0 as [After]
           ,1 as [Order]
        UNION ALL
        SELECT
            @TransitionID as OwnerID
           ,@TypeID_LinkToStoredProcedureOnTransition as LinkTypeID
           ,@LinkCaseTransitionID_After as CaseID
           ,1 as [After]
           ,0 as [Order]
        UNION ALL
        SELECT
            @SourceStateID as OwnerID
           ,@TypeID_LinkToStoredProcedureOnState as LinkTypeID
           ,@LinkCaseTransitionID_Before as CaseID
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
        JOIN dbo.TValue v 
            JOIN dbo.TLink l ON l.ValueID = v.ValueID
        ON v.TypeID = ow.LinkTypeID
            AND v.OwnerID = ow.OwnerID
            AND v.CaseID = ow.CaseID
        JOIN dbo.TDirectory spd ON spd.ID = l.LinkedID
        JOIN dbo.TDirectory ssd ON ssd.ID = spd.OwnerID
    --ToDo ??? Stored Procedure StateID or OBJECT_ID(CONCAT(so.[Name], N'.', pd.[Name]), 'P') IS NOT NULL
    ORDER BY
        ow.[After]
       ,ow.[Order]
       ,v.[Order];

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