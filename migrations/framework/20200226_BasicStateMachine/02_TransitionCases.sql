--liquibase formatted sql

--changeset vrafael:framework_20200226_02_TransitionCases logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--добавление условий для выхова процедур на переходах состояний
DECLARE
    @TypeID_Directory bigint = dbo.TypeIDByTag(N'Directory')
   ,@TypeID_Case bigint = dbo.TypeIDByTag(N'Case')
   ,@TypeID_CaseTransition bigint = dbo.TypeIDByTag(N'CaseTransition')
   ,@CaseTransitionID_Before bigint = dbo.DirectoryIDByTag(N'CaseTransition', N'Before')
   ,@CaseTransitionID_After bigint = dbo.DirectoryIDByTag(N'CaseTransition', N'After')

--Case
IF @TypeID_Case IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_Case OUTPUT
       ,@TypeTag = N'DirectoryType'
       ,@StateID = NULL
       ,@Name = N'Условие'
       ,@Tag = N'Case'
       ,@OwnerID = @TypeID_Directory
       ,@Description = N'Справочник условий'
       ,@Abstract = 1
       ,@Icon = NULL
       ,@StateMachineID = NULL
END

--CaseTransition
IF @TypeID_CaseTransition IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_CaseTransition OUTPUT
       ,@TypeTag = N'DirectoryType'
       ,@StateID = NULL
       ,@Name = N'Порядок выполнения процедуры на переходе'
       ,@Tag = N'CaseTransition'
       ,@OwnerID = @TypeID_Case
       ,@Description = N'Справочник условий для ссылок на переходе'
       ,@Abstract = 0
       ,@Icon = NULL
       ,@StateMachineID = NULL
END

--CaseTransition Before
IF @CaseTransitionID_Before IS NULL 
BEGIN 
    EXEC dbo.DirectorySet
        @ID = @CaseTransitionID_Before OUTPUT
       ,@TypeTag = N'CaseTransition'
       ,@Name = N'Перед переходом'
       ,@OwnerID = NULL
       ,@Tag = N'Before'
       ,@Description = N'Процедуры и действия выполняющиеся до перехода состояний' 
END

--CaseTransition After
IF @CaseTransitionID_After IS NULL 
BEGIN 
    EXEC dbo.DirectorySet
        @ID = @CaseTransitionID_After OUTPUT
       ,@TypeTag = N'CaseTransition'
       ,@Name = N'После перехода'
       ,@OwnerID = NULL
       ,@Tag = N'After'
       ,@Description = N'Процедуры и действия выполняющиеся после перехода состояний' 
END