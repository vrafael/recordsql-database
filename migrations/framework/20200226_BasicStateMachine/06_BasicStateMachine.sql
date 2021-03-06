--liquibase formatted sql

--changeset vrafael:framework_20200225_06_BasicStateMachine logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--базовая схема состояний
DECLARE
    @StateMachineID_Basic bigint = dbo.DirectoryIDByTag(N'StateMachine', N'Basic')
   ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
   ,@TransitionID_Basic_Form bigint = dbo.DirectoryIDByOwner(N'Transition', N'Basic', N'Form')
   ,@TransitionID_Basic_Unform bigint = dbo.DirectoryIDByOwner(N'Transition', N'Basic', N'Unform')
   ,@StoredProcedureID_dbo_BasicTransition bigint = dbo.DirectoryIDByOwner(N'StoredProcedure', N'dbo', N'BasicTransition')
   ,@CaseTransitionOrderID_Before bigint = dbo.DirectoryIDByTag(N'CaseTransitionOrder', N'Before')
   ,@CaseTransitionOrderID_After bigint = dbo.DirectoryIDByTag(N'CaseTransitionOrder', N'After')

IF @StateMachineID_Basic IS NULL
BEGIN
    EXEC dbo.DirectorySet
        @ID = @StateMachineID_Basic OUTPUT
       ,@TypeTag = N'StateMachine'
       ,@StateID = NULL
       ,@OwnerID = NULL
       ,@Name = N'Basic state machine'
       ,@Tag = N'Basic'
       ,@Description = N'Базовый конечный автомат состояний'
END

IF @StateID_Basic_Formed IS NULL
BEGIN
    EXEC dbo.StateSet
        @ID = @StateID_Basic_Formed OUTPUT
       ,@TypeTag = N'State' 
       ,@StateID = NULL
       ,@OwnerID = @StateMachineID_Basic
       ,@Name = N'Formed'
       ,@Tag = N'Formed'
       ,@Description = NULL
       ,@Color = N'00FF00'
END

IF @TransitionID_Basic_Form IS NULL
BEGIN
    EXEC dbo.TransitionSet
        @ID = @TransitionID_Basic_Form OUTPUT
       ,@TypeTag = N'Transition'
       ,@StateID = NULL
       ,@OwnerID = @StateMachineID_Basic
       ,@Name = N'Form'
       ,@Tag = N'Form'
       ,@Description = N'Формирование объекта'
       ,@SourceStateID = NULL
       ,@TargetStateID = @StateID_Basic_Formed
       ,@Priority = 1
END

IF @TransitionID_Basic_Unform IS NULL
BEGIN
    EXEC dbo.TransitionSet
        @ID = @TransitionID_Basic_Unform OUTPUT
       ,@TypeTag = N'Transition'
       ,@StateID = NULL
       ,@OwnerID = @StateMachineID_Basic
       ,@Name = N'Unform'
       ,@Tag = N'Unform'
       ,@Description = N'Расформирование объекта'
       ,@SourceStateID = @StateID_Basic_Formed
       ,@TargetStateID = NULL
       ,@Priority = 1
END

--добавляем ссылку на переход Form 
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.OwnerID = @TransitionID_Basic_Form
        AND l.CaseID = @CaseTransitionOrderID_After --для встраивания полей в типы необходимо вызывать процы после перехода
        AND l.TargetID = @StoredProcedureID_dbo_BasicTransition
)
BEGIN
    EXEC dbo.LinkSet
        @LinkID = NULL
       ,@TypeTag = N'LinkToStoredProcedureOnTransition'
       ,@OwnerID = @TransitionID_Basic_Form
       ,@TargetID = @StoredProcedureID_dbo_BasicTransition
       ,@CaseID = @CaseTransitionOrderID_After
       ,@Order = 1
END

--добавляем ссылку на переход Unform
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.OwnerID = @TransitionID_Basic_Unform
        AND l.CaseID = @CaseTransitionOrderID_After --для встраивания полей в типы необходимо вызывать процы после перехода
        AND l.TargetID = @StoredProcedureID_dbo_BasicTransition
)
BEGIN
    EXEC dbo.LinkSet
        @LinkID = NULL
       ,@TypeTag = N'LinkToStoredProcedureOnTransition'
       ,@OwnerID = @TransitionID_Basic_Unform
       ,@TargetID = @StoredProcedureID_dbo_BasicTransition
       ,@CaseID = @CaseTransitionOrderID_After --для встраивания полей в типы необходимо вызывать процы после перехода
       ,@Order = 1
END

--переводим  тип Состояние и Переход на базовый конечный автомат
UPDATE ot
SET StateMachineID = @StateMachineID_Basic
FROM dbo.TObject o 
    JOIN dbo.TDirectory d ON d.ID = o.ID
    JOIN dbo.TObjectType ot ON ot.ID = d.ID
WHERE ot.StateMachineID IS NULL
    AND d.[Tag] IN (N'State', N'Transition')

--вручную формируем состояния и переходы базового конечного автомата
UPDATE dbo.TObject
SET StateID = @StateID_Basic_Formed
WHERE ID IN (@StateID_Basic_Formed, @TransitionID_Basic_Form, @TransitionID_Basic_Unform, @StoredProcedureID_dbo_BasicTransition)
    AND StateID IS NULL