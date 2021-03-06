--liquibase formatted sql

--changeset vrafael:framework_20200222_03_StateMachineTypes logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--добавление типов автомата состояний
DECLARE
    @TypeID_Directory bigint = dbo.TypeIDByTag(N'Directory')
   ,@TypeID_DirectoryType bigint = dbo.TypeIDByTag(N'DirectoryType')
   ,@TypeID_StateMachine bigint = dbo.TypeIDByTag(N'StateMachine')
   ,@TypeID_State bigint = dbo.TypeIDByTag(N'State')
   ,@TypeID_Transition bigint = dbo.TypeIDByTag(N'Transition')
   ,@TypeID_DatabaseObject bigint = dbo.TypeIDByTag(N'DatabaseObject')
   ,@TypeID_StoredProcedure bigint = dbo.TypeIDByTag(N'StoredProcedure')
   ,@TypeID_Scheme bigint = dbo.TypeIDByTag(N'Schema')

--StateMachne
IF @TypeID_StateMachine IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_StateMachine OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@OwnerID = @TypeID_Directory
       ,@Name = N'State machine'
       ,@Tag = N'StateMachine'
       ,@Description = N'Finite state machine'
       ,@Abstract = 0
       ,@Icon = N'las la-project-diagram'
       ,@StateMachineID = NULL
END

--State
IF @TypeID_State IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_State OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@OwnerID = @TypeID_Directory
       ,@Name = N'State'
       ,@Tag = N'State'
       ,@Description = N'State of finite state machine'
       ,@Abstract = 0
       ,@Icon = N'las la-bookmark'
       ,@StateMachineID = NULL
END

--Transition
IF @TypeID_Transition IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_Transition OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@OwnerID = @TypeID_Directory
       ,@Name = N'Transition'
       ,@Tag = N'Transition'
       ,@Description = N'Transit between states of finite state machine'
       ,@Abstract = 0
       ,@Icon = N'las la-arrow-right'
       ,@StateMachineID = NULL
END
