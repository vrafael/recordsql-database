--liquibase formatted sql

--changeset vrafael:framework_20200225_AdditionalTypes_02_FieldLinksValueTypes logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--задаются все разрешенные типы для полей FieldLink
DECLARE 
    @TypeID_LinkValueType bigint = dbo.TypeIDByTag(N'LinkValueType')
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
   ,@TypeID_ValueType bigint = dbo.TypeIDByTag(N'ValueType')
   ,@TypeID_Schema bigint = dbo.TypeIDByTag(N'Schema')
   ,@TypeID_DatabaseObject bigint = dbo.TypeIDByTag(N'DatabaseObject')
   ,@TypeID_Event bigint = dbo.TypeIDByTag(N'Event')
   ,@FieldID_Object_Type bigint = dbo.DirectoryIDByOwner(N'Field', N'Object', N'Type')
   ,@FieldID_Object_State bigint = dbo.DirectoryIDByOwner(N'Field', N'Object', N'State')
   ,@FieldID_Directory_Owner bigint = dbo.DirectoryIDByOwner(N'Field', N'Directory', N'Owner')
   ,@FieldID_ObjectType_StateMachine bigint = dbo.DirectoryIDByOwner(N'Field', N'ObjectType', N'StateMachine')
   ,@FieldID_Error_Type bigint = dbo.DirectoryIDByOwner(N'Field', N'Error', N'Type')
   ,@FieldID_Error_Procedure bigint = dbo.DirectoryIDByOwner(N'Field', N'Error', N'Procedure')
   --,@FieldID_Error_Login bigint = dbo.DirectoryIDByOwner(N'Field', N'Error', N'Login') --ToDo
   ,@FieldID_Transition_SourceState bigint = dbo.DirectoryIDByOwner(N'Field', N'Transition', N'SourceState')
   ,@FieldID_Transition_TargetState bigint = dbo.DirectoryIDByOwner(N'Field', N'Transition', N'TargetState')
   ,@FieldID_Value_Type bigint = dbo.DirectoryIDByOwner(N'Field', N'Value', N'Type')
   ,@FieldID_Value_Owner bigint = dbo.DirectoryIDByOwner(N'Field', N'Value', N'Owner')
   ,@FieldID_Value_Case bigint = dbo.DirectoryIDByOwner(N'Field', N'Value', N'Case')
   ,@FieldID_Link_Linked bigint = dbo.DirectoryIDByOwner(N'Field', N'Link', N'Linked')
   ,@FieldID_Event_Type bigint = dbo.DirectoryIDByOwner(N'Field', N'Event', N'Type')
   ,@FieldID_Event_Object bigint = dbo.DirectoryIDByOwner(N'Field', N'Event', N'Object')
   --,@FieldID_Event_Login bigint = dbo.DirectoryIDByOwner(N'Field', N'Event', N'Login')
   ,@FieldID_EventTransition_Transition bigint = dbo.DirectoryIDByOwner(N'Field', N'EventTransition', N'Transition')

--Object.Type=>ALL=>Type
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Object_Type
        AND v.CaseID IS NULL
        AND l.LinkedID = @TypeID_ObjectType
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Object_Type
       ,@CaseID = NULL
       ,@LinkedID = @TypeID_ObjectType
END

--Object.State=>ALL=>State
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Object_State
        AND v.CaseID IS NULL
        AND l.LinkedID = @TypeID_State
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Object_State
       ,@CaseID = NULL
       ,@LinkedID = @TypeID_State
END

--Type.Owner=>ALL=>Type
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Directory_Owner
        AND v.CaseID = @TypeID_Type
        AND l.LinkedID = @TypeID_Type
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Directory_Owner
       ,@CaseID = @TypeID_Type
       ,@LinkedID = @TypeID_Type
END

--ObjectType.StateMachine=>ALL=>StateMachine
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_ObjectType_StateMachine
        AND v.CaseID IS NULL
        AND l.LinkedID = @TypeID_StateMachine
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_ObjectType_StateMachine
       ,@CaseID = NULL
       ,@LinkedID = @TypeID_StateMachine
END

--Error.Type=>ALL=>Type
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Error_Type
        AND v.CaseID IS NULL
        AND l.LinkedID = @TypeID_Type
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Error_Type
       ,@CaseID = NULL
       ,@LinkedID = @TypeID_Type
END

--Error.Procedure=>ALL=>StoredProcedure
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Error_Procedure
        AND v.CaseID IS NULL
        AND l.LinkedID = @TypeID_StoredProcedure
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Error_Procedure
       ,@CaseID = NULL
       ,@LinkedID = @TypeID_StoredProcedure
END

--Transition.SourceState=>ALL=>State
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Transition_SourceState
        AND v.CaseID IS NULL
        AND l.LinkedID = @TypeID_State
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Transition_SourceState
       ,@CaseID = NULL
       ,@LinkedID = @TypeID_State
END

--Transition.TargetState=>ALL=>State
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Transition_TargetState
        AND v.CaseID IS NULL
        AND l.LinkedID = @TypeID_State
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Transition_TargetState
       ,@CaseID = NULL
       ,@LinkedID = @TypeID_State
END

--Value.Type=>ALL=>Type
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Value_Type
        AND v.CaseID IS NULL
        AND l.LinkedID = @TypeID_ValueType
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Value_Type
       ,@CaseID = NULL
       ,@LinkedID = @TypeID_ValueType
END

-------LinkValueType
--Value.Owner=>LinkValueType=>FieldLink
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Value_Owner
        AND v.CaseID = @TypeID_LinkValueType
        AND l.LinkedID = @TypeID_FieldLink
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Value_Owner
       ,@CaseID = @TypeID_LinkValueType
       ,@LinkedID = @TypeID_FieldLink
END

--Value.Case=>LinkValueType=>Type
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Value_Case
        AND v.CaseID = @TypeID_LinkValueType
        AND l.LinkedID = @TypeID_Type
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Value_Case
       ,@CaseID = @TypeID_LinkValueType
       ,@LinkedID = @TypeID_Type
END

--Link.Linked=>LinkValueType=>ObjectType
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Link_Linked
        AND v.CaseID = @TypeID_LinkValueType
        AND l.LinkedID = @TypeID_ObjectType
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Link_Linked
       ,@CaseID = @TypeID_LinkValueType
       ,@LinkedID = @TypeID_ObjectType
END

--LinkToStoredProcedure
--Link.Linked=>LinkToStoredProcedure=>StoredProcedure
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Link_Linked
        AND v.CaseID = @TypeID_LinkToStoredProcedure
        AND l.LinkedID = @TypeID_StoredProcedure
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Link_Linked
       ,@CaseID = @TypeID_LinkToStoredProcedure
       ,@LinkedID = @TypeID_StoredProcedure
END

--LinkToStoredProcedureOnTransition
--Link.Owner=>LinkToStoredProcedureOnTransition=>Transition
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Value_Owner
        AND v.CaseID = @TypeID_LinkToStoredProcedureOnTransition
        AND l.LinkedID = @TypeID_Transition
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Value_Owner
       ,@CaseID = @TypeID_LinkToStoredProcedureOnTransition
       ,@LinkedID = @TypeID_Transition
END

--LinkToStoredProcedureOnState
--Link.Owner=>LinkToStoredProcedureOnState=>State
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Value_Owner
        AND v.CaseID = @TypeID_LinkToStoredProcedureOnState
        AND l.LinkedID = @TypeID_State
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Value_Owner
       ,@CaseID = @TypeID_LinkToStoredProcedureOnState
       ,@LinkedID = @TypeID_State
END

--DatabaseObject
--Directory.Owner=>DatabaseObject=>Schema
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Directory_Owner
        AND v.CaseID = @TypeID_DatabaseObject
        AND l.LinkedID = @TypeID_Schema
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Directory_Owner
       ,@CaseID = @TypeID_DatabaseObject
       ,@LinkedID = @TypeID_Schema
END

--Field
--Directory.Owner=>Field=>Type
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Directory_Owner
        AND v.CaseID = @TypeID_Field
        AND l.LinkedID = @TypeID_Type
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Directory_Owner
       ,@CaseID = @TypeID_Field
       ,@LinkedID = @TypeID_Type
END

--State
--Directory.Owner=>State=>StateMachine
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Directory_Owner
        AND v.CaseID = @TypeID_State
        AND l.LinkedID = @TypeID_StateMachine
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Directory_Owner
       ,@CaseID = @TypeID_State
       ,@LinkedID = @TypeID_StateMachine
END

--Transition
--Directory.Owner=>Transition=>StateMachine
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Directory_Owner
        AND v.CaseID = @TypeID_Transition
        AND l.LinkedID = @TypeID_StateMachine
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Directory_Owner
       ,@CaseID = @TypeID_Transition
       ,@LinkedID = @TypeID_StateMachine
END

--Event
--Event.Type=>ALL=>Type
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Event_Type
        AND v.CaseID = NULL
        AND l.LinkedID = @TypeID_Type
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Event_Type
       ,@CaseID = NULL
       ,@LinkedID = @TypeID_Type
END

--Event.Object=>ALL=>Object
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_Event_Object
        AND v.CaseID = NULL
        AND l.LinkedID = @TypeID_Object
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_Event_Object
       ,@CaseID = NULL
       ,@LinkedID = @TypeID_Object
END


--Eventtransition.Transition=>ALL=>Transition
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v 
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.TypeID = @TypeID_LinkValueType
        AND v.OwnerID = @FieldID_EventTransition_Transition
        AND v.CaseID = NULL
        AND l.LinkedID = @TypeID_Transition
)
BEGIN
    EXEC dbo.LinkValueTypeSet
        @TypeID = @TypeID_LinkValueType
       ,@OwnerID = @FieldID_EventTransition_Transition
       ,@CaseID = NULL
       ,@LinkedID = @TypeID_Transition
END