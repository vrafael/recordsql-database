--liquibase formatted sql

--changeset vrafael:framework_20200225_06_BasicStateMachine logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--базовая схема состояний
DECLARE
    @StateMachineID_Basic bigint = dbo.DirectoryIDByTag(N'StateMachine', N'Basic')
   ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
   ,@TransitionID_Basic_Form bigint = dbo.DirectoryIDByOwner(N'Transition', N'Basic', N'Form')
   ,@TransitionID_Basic_Unform bigint = dbo.DirectoryIDByOwner(N'Transition', N'Basic', N'Unform')
   ,@StoredProcedureID_dbo_BasicTransition bigint = dbo.DirectoryIDByOwner(N'StoredProcedure', N'dbo', N'BasicTransition')
   ,@CaseTransitionID_Before bigint = dbo.DirectoryIDByTag(N'CaseTransition', N'Before')
   ,@CaseTransitionID_After bigint = dbo.DirectoryIDByTag(N'CaseTransition', N'After')

IF @StateMachineID_Basic IS NULL
BEGIN
    EXEC dbo.DirectorySet
        @ID = @StateMachineID_Basic OUTPUT
       ,@TypeTag = N'StateMachine'
       ,@StateID = NULL
       ,@OwnerID = NULL
       ,@Name = N'Базовый'
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
       ,@Name = N'Сформирован'
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
       ,@Name = N'Сформировать'
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
       ,@Name = N'Расформировать'
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
    FROM dbo.TValue v
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.OwnerID = @TransitionID_Basic_Form
        AND v.CaseID = @CaseTransitionID_Before
        AND l.LinkedID = @StoredProcedureID_dbo_BasicTransition
)
BEGIN
    EXEC dbo.LinkSet
        @ValueID = NULL
       ,@TypeTag = N'LinkToStoredProcedureOnTransition'
       ,@OwnerID = @TransitionID_Basic_Form
       ,@CaseID = @CaseTransitionID_Before
       ,@Order = 1
       ,@LinkedID = @StoredProcedureID_dbo_BasicTransition
END

--добавляем ссылку на переход Unform
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.OwnerID = @TransitionID_Basic_Unform
        AND v.CaseID = @CaseTransitionID_Before
        AND l.LinkedID = @StoredProcedureID_dbo_BasicTransition
)
BEGIN
    EXEC dbo.LinkSet
        @ValueID = NULL
       ,@TypeTag = N'LinkToStoredProcedureOnTransition'
       ,@OwnerID = @TransitionID_Basic_Unform
       ,@CaseID = @CaseTransitionID_Before
       ,@Order = 1
       ,@LinkedID = @StoredProcedureID_dbo_BasicTransition
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