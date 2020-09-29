--liquibase formatted sql

--changeset vrafael:framework_20200225_05_AdditionalTypes logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--добавление типов автомата состояний
DECLARE
    @TypeID_Directory bigint = dbo.TypeIDByTag(N'Directory')
   ,@TypeID_DirectoryType bigint = dbo.TypeIDByTag(N'DirectoryType')
   ,@TypeID_DatabaseObject bigint = dbo.TypeIDByTag(N'DatabaseObject')
   ,@TypeID_Schema bigint = dbo.TypeIDByTag(N'Schema')
   ,@TypeID_StoredProcedure bigint = dbo.TypeIDByTag(N'StoredProcedure')
   ,@TypeID_Function bigint = dbo.TypeIDByTag(N'Function')
   ,@TypeID_InlineFunction bigint = dbo.TypeIDByTag(N'InlineFunction')
   ,@TypeID_ScalarFunction bigint = dbo.TypeIDByTag(N'ScalarFunction')
   ,@TypeID_TableFunction bigint = dbo.TypeIDByTag(N'TableFunction')
   ,@TypeID_Table bigint = dbo.TypeIDByTag(N'Table')
   ,@TypeID_View bigint = dbo.TypeIDByTag(N'View')
   ,@TypeID_Object bigint = dbo.TypeIDByTag(N'Object')
   ,@TypeID_Type bigint = dbo.TypeIDByTag(N'Type')
   ,@TypeID_LinkType bigint = dbo.TypeIDByTag(N'LinkType')
   ,@TypeID_Link bigint = dbo.TypeIDByTag(N'Link')
   ,@TypeID_Relationship bigint = dbo.TypeIDByTag(N'Relationship')
   ,@TypeID_LinkToStoredProcedure bigint = dbo.TypeIDByTag(N'LinkToStoredProcedure')
   ,@TypeID_LinkToStoredProcedureOnTransition bigint = dbo.TypeIDByTag(N'LinkToStoredProcedureOnTransition')
   ,@TypeID_LinkToStoredProcedureOnState bigint = dbo.TypeIDByTag(N'LinkToStoredProcedureOnState')
   ,@TypeID_String bigint = dbo.TypeIDByTag(N'String')
   ,@TypeID_Event bigint = dbo.TypeIDByTag(N'Event')
   ,@TypeID_EventInsert bigint = dbo.TypeIDByTag(N'EventInsert')
   ,@TypeID_EventUpdate bigint = dbo.TypeIDByTag(N'EventUpdate')
   ,@TypeID_EventDelete bigint = dbo.TypeIDByTag(N'EventDelete')
   ,@TypeID_EventTransition bigint = dbo.TypeIDByTag(N'EventTransition')

--DatabaseObject
IF @TypeID_DatabaseObject IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_DatabaseObject OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@OwnerID = @TypeID_Directory
       ,@Name = N'Database object'
       ,@Tag = N'DatabaseObject'
       ,@Description = NULL
       ,@Abstract = 1
       ,@Icon = N'las la-database'
       ,@StateMachineID = NULL
END

--Scheme
IF @TypeID_Schema IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_Schema OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@OwnerID = @TypeID_Directory
       ,@Name = N'Scheme'
       ,@Tag = N'Schema'
       ,@Description = N'Database schema'
       ,@Abstract = 0
       ,@Icon = N'las la-folder'
       ,@StateMachineID = NULL
END

--StoredProcedure
IF @TypeID_StoredProcedure IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_StoredProcedure OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@OwnerID = @TypeID_DatabaseObject
       ,@Name = N'Stored procedure'
       ,@Tag = N'StoredProcedure'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-code'
       ,@StateMachineID = NULL
END

--Function
IF @TypeID_Function IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_Function OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@OwnerID = @TypeID_DatabaseObject
       ,@Name = N'Function'
       ,@Tag = N'Function'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-code'
       ,@StateMachineID = NULL
END

--ScalarFunction
IF @TypeID_ScalarFunction IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_ScalarFunction OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@OwnerID = @TypeID_Function
       ,@Name = N'Scalar function'
       ,@Tag = N'ScalarFunction'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-code'
       ,@StateMachineID = NULL
END

--TableFunction
IF @TypeID_TableFunction IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_TableFunction OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@OwnerID = @TypeID_Function
       ,@Name = N'Table function'
       ,@Tag = N'TableFunction'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-code'
       ,@StateMachineID = NULL
END

--InlineFunction
IF @TypeID_InlineFunction IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_InlineFunction OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@OwnerID = @TypeID_Function
       ,@Name = N'Inline function'
       ,@Tag = N'InlineFunction'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-code'
       ,@StateMachineID = NULL
END

--Table
IF @TypeID_Table IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_Table OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@OwnerID = @TypeID_DatabaseObject
       ,@Name = N'Table'
       ,@Tag = N'Table'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-table'
       ,@StateMachineID = NULL
END

--Veiw
IF @TypeID_View IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_View OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@OwnerID = @TypeID_DatabaseObject
       ,@Name = N'View'
       ,@Tag = N'View'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-border-none'
       ,@StateMachineID = NULL
END

--LinkType
IF @TypeID_LinkType IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_LinkType OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@OwnerID = @TypeID_Type
       ,@Name = N'Link type'
       ,@Tag = N'LinkType'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-table'
END

--Link
IF @TypeID_Link IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_Link OUTPUT
       ,@TypeID = @TypeID_LinkType
       ,@OwnerID = NULL
       ,@Name = N'Link'
       ,@Tag = N'Link'
       ,@Description = N'Materialized typed link from object to object'
       ,@Abstract = 1
       ,@Icon = N'las la-external-link-alt'
END

--Relationship
IF @TypeID_Relationship IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_Relationship OUTPUT
       ,@TypeID = @TypeID_LinkType
       ,@OwnerID = @TypeID_Link
       ,@Name = N'Relationship'
       ,@Tag = N'Relationship'
       ,@Description = N'Link to allowed type of FieldLink value'
       ,@Abstract = 0
       ,@Icon = N'las la-anchor'
END

--LinkToStoredProcedure
IF @TypeID_LinkToStoredProcedure IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_LinkToStoredProcedure OUTPUT
       ,@TypeID = @TypeID_LinkType
       ,@OwnerID = @TypeID_Link
       ,@Name = N'Link to procedure'
       ,@Tag = N'LinkToStoredProcedure'
       ,@Description = NULL
       ,@Abstract = 1
       ,@Icon = N'las la-external-link-alt'
END

--LinkToStoredProcedureOnTransition
IF @TypeID_LinkToStoredProcedureOnTransition IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_LinkToStoredProcedureOnTransition OUTPUT
       ,@TypeID = @TypeID_LinkType
       ,@OwnerID = @TypeID_LinkToStoredProcedure
       ,@Name = N'Procedure on transition'
       ,@Tag = N'LinkToStoredProcedureOnTransition'
       ,@Description = N'Link to procedure which execute on before/after transition'
       ,@Abstract = 0
       ,@Icon = N'las la-external-link-alt'
END

--LinkToStoredProcedureOnState
IF @TypeID_LinkToStoredProcedureOnState IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_LinkToStoredProcedureOnState OUTPUT
       ,@TypeID = @TypeID_LinkType
       ,@OwnerID = @TypeID_LinkToStoredProcedure
       ,@Name = N'Procedure on state'
       ,@Tag = N'LinkToStoredProcedureOnState'
       ,@Description = N'Link to procedure which execute on state enter/exit'
       ,@Abstract = 0
       ,@Icon = N'las la-external-link-alt'
END

--Event
IF @TypeID_Event IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_Event OUTPUT
       ,@TypeID = @TypeID_Type
       ,@OwnerID = NULL
       ,@Name = N'Event'
       ,@Tag = N'Event'
       ,@Description = N'Event of object'
       ,@Abstract = 1
       ,@Icon = N'las la-calendar-times'
END

--EventInsert
IF @TypeID_EventInsert IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_EventInsert OUTPUT
       ,@TypeID = @TypeID_Type
       ,@OwnerID = @TypeID_Event
       ,@Name = N'Event of insert'
       ,@Tag = N'EventInsert'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-calendar-plus'
END

--EventUpdate
IF @TypeID_EventUpdate IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_EventUpdate OUTPUT
       ,@TypeID = @TypeID_Type
       ,@OwnerID = @TypeID_Event
       ,@Name = N'Event of update'
       ,@Tag = N'EventUpdate'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-calendar-check'
END

--EventDelete
IF @TypeID_EventDelete IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_EventDelete OUTPUT
       ,@TypeID = @TypeID_Type
       ,@OwnerID = @TypeID_Event
       ,@Name = N'Event of delete'
       ,@Tag = N'EventDelete'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-calendar-times'
END

--EventTransition
IF @TypeID_EventTransition IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_EventTransition OUTPUT
       ,@TypeID = @TypeID_Type
       ,@OwnerID = @TypeID_Event
       ,@Name = N'Event of transition'
       ,@Tag = N'EventTransition'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-calendar-check'
END