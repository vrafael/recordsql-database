--liquibase formatted sql

--changeset vrafael:framework_20200222_04_StateMachineFields logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--добавление полей типов автомата состояний
DECLARE
    @TypeID_State bigint = dbo.TypeIDByTag(N'State')
   ,@FieldID_State_Color bigint = dbo.DirectoryIDByOwner(N'Field', N'State', N'Color')
   ,@TypeID_Transition bigint = dbo.TypeIDByTag(N'Transition')
   ,@FieldID_Transition_SourceState bigint = dbo.DirectoryIDByOwner(N'Field', N'Transition', N'SourceState')
   ,@FieldID_Transition_TargetState bigint = dbo.DirectoryIDByOwner(N'Field', N'Transition', N'TargetState')
   ,@FieldID_Transition_Priority bigint = dbo.DirectoryIDByOwner(N'Field', N'Transition', N'Priority')

--------------State
--dbo.TState	Color	color
IF @FieldID_State_Color IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_State_Color OUTPUT
       ,@TypeTag = N'FieldColor'
       ,@StateID = NULL
       ,@Name = N'Цвет'
       ,@OwnerID = @TypeID_State
       ,@Tag = N'Color'
       ,@Description = N'Цветовой идентификатор состояния'
       ,@Order = 1
END

--------------Transition
--dbo.TTransition	SourceState	link
IF @FieldID_Transition_SourceState IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Transition_SourceState OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@Name = N'Исходное состояния'
       ,@OwnerID = @TypeID_Transition
       ,@Tag = N'SourceState'
       ,@Description = NULL
       ,@Order = 1
END

--dbo.TTransition	TargetState	link
IF @FieldID_Transition_TargetState IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Transition_TargetState OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@Name = N'Конечное состояния'
       ,@OwnerID = @TypeID_Transition
       ,@Tag = N'TargetState'
       ,@Description = NULL
       ,@Order = 2
END

--dbo.TTransition	Priority	bit
IF @FieldID_Transition_Priority IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Transition_Priority OUTPUT
       ,@TypeTag = N'FieldBit'
       ,@StateID = NULL
       ,@Name = N'Приоритет'
       ,@OwnerID = @TypeID_Transition
       ,@Tag = N'Priority'
       ,@Description = NULL
       ,@Order = 3
END
