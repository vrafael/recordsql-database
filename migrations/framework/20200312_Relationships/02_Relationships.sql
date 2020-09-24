--liquibase formatted sql

--changeset vrafael:framework_20200312_Relationships_02_Relationships logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--задаются все разрешенные типы для полей FieldLink
DECLARE 
    @TypeID_Relationship bigint = dbo.TypeIDByTag(N'Relationship')
   ,@TypeID_Object bigint = dbo.TypeIDByTag(N'Object')
   ,@TypeID_Type bigint = dbo.TypeIDByTag(N'Type')
   ,@TypeID_State bigint = dbo.TypeIDByTag(N'State')
   ,@TypeID_ObjectType bigint = dbo.TypeIDByTag(N'ObjectType')
   ,@TypeID_StateMachine bigint = dbo.TypeIDByTag(N'StateMachine')
   ,@TypeID_Error bigint = dbo.TypeIDByTag(N'Error')
   ,@TypeID_StoredProcedure bigint = dbo.TypeIDByTag(N'StoredProcedure')
   ,@TypeID_Transition bigint = dbo.TypeIDByTag(N'Transition')
   ,@TypeID_Field bigint = dbo.TypeIDByTag(N'Field')
   ,@TypeID_FieldLink bigint = dbo.TypeIDByTag(N'FieldLink')
   ,@TypeID_LinkToStoredProcedure bigint = dbo.TypeIDByTag(N'LinkToStoredProcedure')
   ,@TypeID_LinkToStoredProcedureOnTransition bigint = dbo.TypeIDByTag(N'LinkToStoredProcedureOnTransition')
   ,@TypeID_LinkToStoredProcedureOnState bigint = dbo.TypeIDByTag(N'LinkToStoredProcedureOnState')
   ,@TypeID_LinkType bigint = dbo.TypeIDByTag(N'LinkType')
   ,@TypeID_Schema bigint = dbo.TypeIDByTag(N'Schema')
   ,@TypeID_DatabaseObject bigint = dbo.TypeIDByTag(N'DatabaseObject')
   ,@TypeID_Event bigint = dbo.TypeIDByTag(N'Event')
   ,@FieldID_Object_Type bigint = dbo.DirectoryIDByOwner(N'Field', N'Object', N'Type')
   ,@FieldID_Object_State bigint = dbo.DirectoryIDByOwner(N'Field', N'Object', N'State')
   ,@FieldID_Object_Owner bigint = dbo.DirectoryIDByOwner(N'Field', N'Object', N'Owner')
   ,@FieldID_ObjectType_StateMachine bigint = dbo.DirectoryIDByOwner(N'Field', N'ObjectType', N'StateMachine')
   ,@FieldID_Error_Type bigint = dbo.DirectoryIDByOwner(N'Field', N'Error', N'Type')
   ,@FieldID_Error_Procedure bigint = dbo.DirectoryIDByOwner(N'Field', N'Error', N'Procedure')
   --,@FieldID_Error_Login bigint = dbo.DirectoryIDByOwner(N'Field', N'Error', N'Login') --ToDo
   ,@FieldID_Transition_SourceState bigint = dbo.DirectoryIDByOwner(N'Field', N'Transition', N'SourceState')
   ,@FieldID_Transition_TargetState bigint = dbo.DirectoryIDByOwner(N'Field', N'Transition', N'TargetState')
   ,@FieldID_Link_Type bigint = dbo.DirectoryIDByOwner(N'Field', N'Link', N'Type')
   ,@FieldID_Link_Owner bigint = dbo.DirectoryIDByOwner(N'Field', N'Link', N'Owner')
   ,@FieldID_Link_Case bigint = dbo.DirectoryIDByOwner(N'Field', N'Link', N'Case')
   ,@FieldID_Link_Target bigint = dbo.DirectoryIDByOwner(N'Field', N'Link', N'Target')
   ,@FieldID_Event_Type bigint = dbo.DirectoryIDByOwner(N'Field', N'Event', N'Type')
   ,@FieldID_Event_Object bigint = dbo.DirectoryIDByOwner(N'Field', N'Event', N'Object')
   --,@FieldID_Event_Login bigint = dbo.DirectoryIDByOwner(N'Field', N'Event', N'Login')
   ,@FieldID_EventTransition_Transition bigint = dbo.DirectoryIDByOwner(N'Field', N'EventTransition', N'Transition')

--Object.Type=>ALL=>Type
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Object_Type
        AND l.CaseID IS NULL
        AND l.TargetID = @TypeID_ObjectType
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Object_Type
       ,@CaseID = NULL
       ,@TargetID = @TypeID_ObjectType
END

--Object.State=>ALL=>State
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Object_State
        AND l.CaseID IS NULL
        AND l.TargetID = @TypeID_State
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Object_State
       ,@CaseID = NULL
       ,@TargetID = @TypeID_State
END

--Type.Owner=>ALL=>Type
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Object_Owner
        AND l.CaseID = @TypeID_Type
        AND l.TargetID = @TypeID_Type
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Object_Owner
       ,@CaseID = @TypeID_Type
       ,@TargetID = @TypeID_Type
END

--ObjectType.StateMachine=>ALL=>StateMachine
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_ObjectType_StateMachine
        AND l.CaseID IS NULL
        AND l.TargetID = @TypeID_StateMachine
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_ObjectType_StateMachine
       ,@CaseID = NULL
       ,@TargetID = @TypeID_StateMachine
END

--Error.Type=>ALL=>Type
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Error_Type
        AND l.CaseID IS NULL
        AND l.TargetID = @TypeID_Type
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Error_Type
       ,@CaseID = NULL
       ,@TargetID = @TypeID_Type
END

--Error.Procedure=>ALL=>StoredProcedure
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Error_Procedure
        AND l.CaseID IS NULL
        AND l.TargetID = @TypeID_StoredProcedure
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Error_Procedure
       ,@CaseID = NULL
       ,@TargetID = @TypeID_StoredProcedure
END

--Transition.SourceState=>ALL=>State
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Transition_SourceState
        AND l.CaseID IS NULL
        AND l.TargetID = @TypeID_State
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Transition_SourceState
       ,@CaseID = NULL
       ,@TargetID = @TypeID_State
END

--Transition.TargetState=>ALL=>State
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Transition_TargetState
        AND l.CaseID IS NULL
        AND l.TargetID = @TypeID_State
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Transition_TargetState
       ,@CaseID = NULL
       ,@TargetID = @TypeID_State
END

--Value.Type=>ALL=>Type
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Link_Type
        AND l.CaseID IS NULL
        AND l.TargetID = @TypeID_LinkType
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Link_Type
       ,@CaseID = NULL
       ,@TargetID = @TypeID_LinkType
END

-------Relationship
--Value.Owner=>Relationship=>FieldLink
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Link_Owner
        AND l.CaseID = @TypeID_Relationship
        AND l.TargetID = @TypeID_FieldLink
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Link_Owner
       ,@CaseID = @TypeID_Relationship
       ,@TargetID = @TypeID_FieldLink
END

--Value.Case=>Relationship=>Type
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Link_Case
        AND l.CaseID = @TypeID_Relationship
        AND l.TargetID = @TypeID_Type
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Link_Case
       ,@CaseID = @TypeID_Relationship
       ,@TargetID = @TypeID_Type
END

--Link.Linked=>Relationship=>ObjectType
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Link_Target
        AND l.CaseID = @TypeID_Relationship
        AND l.TargetID = @TypeID_ObjectType
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Link_Target
       ,@CaseID = @TypeID_Relationship
       ,@TargetID = @TypeID_ObjectType
END

--LinkToStoredProcedure
--Link.Linked=>LinkToStoredProcedure=>StoredProcedure
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Link_Target
        AND l.CaseID = @TypeID_LinkToStoredProcedure
        AND l.TargetID = @TypeID_StoredProcedure
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Link_Target
       ,@CaseID = @TypeID_LinkToStoredProcedure
       ,@TargetID = @TypeID_StoredProcedure
END

--LinkToStoredProcedureOnTransition
--Link.Owner=>LinkToStoredProcedureOnTransition=>Transition
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Link_Owner
        AND l.CaseID = @TypeID_LinkToStoredProcedureOnTransition
        AND l.TargetID = @TypeID_Transition
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Link_Owner
       ,@CaseID = @TypeID_LinkToStoredProcedureOnTransition
       ,@TargetID = @TypeID_Transition
END

--LinkToStoredProcedureOnState
--Link.Owner=>LinkToStoredProcedureOnState=>State
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Link_Owner
        AND l.CaseID = @TypeID_LinkToStoredProcedureOnState
        AND l.TargetID = @TypeID_State
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Link_Owner
       ,@CaseID = @TypeID_LinkToStoredProcedureOnState
       ,@TargetID = @TypeID_State
END

--DatabaseObject
--Directory.Owner=>DatabaseObject=>Schema
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Object_Owner
        AND l.CaseID = @TypeID_DatabaseObject
        AND l.TargetID = @TypeID_Schema
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Object_Owner
       ,@CaseID = @TypeID_DatabaseObject
       ,@TargetID = @TypeID_Schema
END

--Field
--Directory.Owner=>Field=>Type
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Object_Owner
        AND l.CaseID = @TypeID_Field
        AND l.TargetID = @TypeID_Type
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Object_Owner
       ,@CaseID = @TypeID_Field
       ,@TargetID = @TypeID_Type
END

--State
--Directory.Owner=>State=>StateMachine
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Object_Owner
        AND l.CaseID = @TypeID_State
        AND l.TargetID = @TypeID_StateMachine
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Object_Owner
       ,@CaseID = @TypeID_State
       ,@TargetID = @TypeID_StateMachine
END

--Transition
--Directory.Owner=>Transition=>StateMachine
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Object_Owner
        AND l.CaseID = @TypeID_Transition
        AND l.TargetID = @TypeID_StateMachine
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Object_Owner
       ,@CaseID = @TypeID_Transition
       ,@TargetID = @TypeID_StateMachine
END

--Event
--Event.Type=>ALL=>Type
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Event_Type
        AND l.CaseID = NULL
        AND l.TargetID = @TypeID_Type
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Event_Type
       ,@CaseID = NULL
       ,@TargetID = @TypeID_Type
END

--Event.Object=>ALL=>Object
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Event_Object
        AND l.CaseID = NULL
        AND l.TargetID = @TypeID_Object
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Event_Object
       ,@CaseID = NULL
       ,@TargetID = @TypeID_Object
END


--Eventtransition.Transition=>ALL=>Transition
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_EventTransition_Transition
        AND l.CaseID = NULL
        AND l.TargetID = @TypeID_Transition
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_EventTransition_Transition
       ,@CaseID = NULL
       ,@TargetID = @TypeID_Transition
END