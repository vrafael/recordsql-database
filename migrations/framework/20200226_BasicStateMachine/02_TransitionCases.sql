--liquibase formatted sql

--changeset vrafael:framework_20200226_02_TransitionCases logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--добавление условий для вызова процедур на переходах состояний
DECLARE
    @TypeID_Directory bigint = dbo.TypeIDByTag(N'Directory')
   ,@TypeID_Case bigint = dbo.TypeIDByTag(N'Case')
   ,@TypeID_CaseTransitionOrder bigint = dbo.TypeIDByTag(N'CaseTransitionOrder')
   ,@CaseTransitionOrderID_Before bigint = dbo.DirectoryIDByTag(N'CaseTransitionOrder', N'Before')
   ,@CaseTransitionOrderID_After bigint = dbo.DirectoryIDByTag(N'CaseTransitionOrder', N'After')

--Case
IF @TypeID_Case IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_Case OUTPUT
       ,@TypeTag = N'DirectoryType'
       ,@StateID = NULL
       ,@Name = N'Case'
       ,@OwnerID = @TypeID_Directory
       ,@Tag = N'Case'
       ,@Description = N'Values for FieldLink Case, whose to get choise of using link '
       ,@Abstract = 1
       ,@Icon = N'las la-hand-pointer'
       ,@StateMachineID = NULL
END

--CaseTransitionOrder
IF @TypeID_CaseTransitionOrder IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_CaseTransitionOrder OUTPUT
       ,@TypeTag = N'DirectoryType'
       ,@StateID = NULL
       ,@Name = N'Order of transition'
       ,@OwnerID = @TypeID_Case
       ,@Tag = N'CaseTransitionOrder'
       ,@Description = N'Procedure execution order during the transition between states'
       ,@Abstract = 0
       ,@Icon = N'las la-hand-spock'
       ,@StateMachineID = NULL
END

--CaseTransitionOrder Before
IF @CaseTransitionOrderID_Before IS NULL 
BEGIN 
    EXEC dbo.DirectorySet
        @ID = @CaseTransitionOrderID_Before OUTPUT
       ,@TypeTag = N'CaseTransitionOrder'
       ,@OwnerID = NULL
       ,@Name = N'Перед переходом'
       ,@Tag = N'Before'
       ,@Description = N'Procedures and actions that are performed before the state transition' 
END

--CaseTransitionOrder After
IF @CaseTransitionOrderID_After IS NULL 
BEGIN 
    EXEC dbo.DirectorySet
        @ID = @CaseTransitionOrderID_After OUTPUT
       ,@TypeTag = N'CaseTransitionOrder'
       ,@OwnerID = NULL
       ,@Name = N'После перехода'
       ,@Tag = N'After'
       ,@Description = N'Procedures and actions that are performed after the state transition' 
END