--liquibase formatted sql

--changeset vrafael:framework_20200225_06_AdditionalFields logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--добавление полей типов автомата состояний
DECLARE
    @TypeID_DatabaseObject bigint = dbo.TypeIDByTag(N'DatabaseObject')
   ,@FieldID_DatabaseObject_object_id bigint = dbo.DirectoryIDByOwner(N'Field', N'DatabaseObject', N'object_id')
   ,@FieldID_DatabaseObject_Script bigint = dbo.DirectoryIDByOwner(N'Field', N'DatabaseObject', N'Script')
   ,@TypeID_State bigint = dbo.TypeIDByTag(N'State')
   ,@FieldID_State_Color bigint = dbo.DirectoryIDByOwner(N'Field', N'State', N'Color')
   ,@TypeID_Link bigint = dbo.TypeIDByTag(N'Link')
   ,@FieldID_Link_LinkID bigint = dbo.DirectoryIDByOwner(N'Field', N'Link', N'LinkID')
   ,@FieldID_Link_Type bigint = dbo.DirectoryIDByOwner(N'Field', N'Link', N'Type')
   ,@FieldID_Link_Owner bigint = dbo.DirectoryIDByOwner(N'Field', N'Link', N'Owner')
   ,@FieldID_Link_Target bigint = dbo.DirectoryIDByOwner(N'Field', N'Link', N'Target')
   ,@FieldID_Link_Case bigint = dbo.DirectoryIDByOwner(N'Field', N'Link', N'Case')
   ,@FieldID_Link_Order bigint = dbo.DirectoryIDByOwner(N'Field', N'Link', N'Order')
   ,@TypeID_Event bigint = dbo.TypeIDByTag(N'Event')
   ,@FieldID_Event_EventID bigint = dbo.DirectoryIDByOwner(N'Field', N'Event', N'EventID')
   ,@FieldID_Event_Type bigint = dbo.DirectoryIDByOwner(N'Field', N'Event', N'Type')
   ,@FieldID_Event_Object bigint = dbo.DirectoryIDByOwner(N'Field', N'Event', N'Object')
   ,@FieldID_Event_Login bigint = dbo.DirectoryIDByOwner(N'Field', N'Event', N'Login')
   ,@FieldID_Event_Moment bigint = dbo.DirectoryIDByOwner(N'Field', N'Event', N'Moment')
   ,@TypeID_EventTransition bigint = dbo.TypeIDByTag(N'EventTransition')
   ,@FieldID_EventTransition_Transition bigint = dbo.DirectoryIDByOwner(N'Field', N'EventTransition', N'Transition')

--------------DatabaseObject
--dbo.TDatabaseObject	object_id	int
IF @FieldID_DatabaseObject_object_id IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_DatabaseObject_object_id OUTPUT
       ,@TypeTag = N'FieldInt'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_DatabaseObject
       ,@Name = N'object_id'
       ,@Tag = N'object_id'
       ,@Description = N'Database object identifier'
       ,@Order = 1
END

--dbo.TDatabaseObject	Script	nvarchar
IF @FieldID_DatabaseObject_Script IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_DatabaseObject_Script OUTPUT
       ,@TypeTag = N'FieldText'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_DatabaseObject
       ,@Name = N'Script'
       ,@Tag = N'Script'
       ,@Description = N'Script of object'
       ,@Order = 2
END

--------------Link
--dbo.TLink	LinkID	identifier
IF @FieldID_Link_LinkID IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Link_LinkID OUTPUT
       ,@TypeTag = N'FieldIdentifier'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Link
       ,@Name = N'LinkID'
       ,@Tag = N'LinkID'
       ,@Description = N'Link identifier'
       ,@Order = 1
END

--dbo.TLink	Type	link
IF @FieldID_Link_Type IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Link_Type OUTPUT
       ,@TypeTag = N'FieldLinkToType'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Link
       ,@Name = N'Type'
       ,@Tag = N'Type'
       ,@Description = N'Link type'
       ,@Order = 2
END

--dbo.TLink	Owner	link
IF @FieldID_Link_Owner IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Link_Owner OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Link
       ,@Name = N'Owner'
       ,@Tag = N'Owner'
       ,@Description = N'Link owner'
       ,@Order = 3
END

IF @FieldID_Link_Target IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Link_Target OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Link
       ,@Name = N'Target'
       ,@Tag = N'Target'
       ,@Description = N'Target object of link'
       ,@Order = 4
END

--dbo.TLink	Case	link
IF @FieldID_Link_Case IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Link_Case OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Link
       ,@Name = N'Case'
       ,@Tag = N'Case'
       ,@Description = N'Additional case for linking'
       ,@Order = 5
END

--dbo.TLink	Order	int
IF @FieldID_Link_Order IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Link_Order OUTPUT
       ,@TypeTag = N'FieldInt'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Link
       ,@Name = N'Order'
       ,@Tag = N'Order'
       ,@Description = NULL
       ,@Order = 6
END

--------------Event
--dbo.TEvent	EventID	identifier
IF @FieldID_Event_EventID IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Event_EventID OUTPUT
       ,@TypeTag = N'FieldIdentifier'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Event
       ,@Name = N'EventID'
       ,@Tag = N'EventID'
       ,@Description = N'Event identifier'
       ,@Order = 1
END

--dbo.TEvent	Type	link
IF @FieldID_Event_Type IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Event_Type OUTPUT
       ,@TypeTag = N'FieldLinkToType'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Event
       ,@Name = N'Type'
       ,@Tag = N'Type'
       ,@Description = NULL
       ,@Order = 2
END

--dbo.TEvent	 Object	link
IF @FieldID_Event_Object IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Event_Object OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Event
       ,@Name = N'Object'
       ,@Tag = N'Object'
       ,@Description = N'Event object'
       ,@Order = 3
END

--dbo.TEvent	Login	link
IF @FieldID_Event_Login IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Event_Login OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Event
       ,@Name = N'Login'
       ,@Tag = N'Login'
       ,@Description = NULL
       ,@Order = 4
END

--dbo.TEvent    Moment	int
IF @FieldID_Event_Moment IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Event_Moment OUTPUT
       ,@TypeTag = N'FieldDatetime'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Event
       ,@Name = N'Moment'
       ,@Tag = N'Moment'
       ,@Description = NULL
       ,@Order = 5
END

--------------EventTransition
--dbo.TEventTransition	Transition	link
IF @FieldID_EventTransition_Transition IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_EventTransition_Transition OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_EventTransition
       ,@Name = N'Transiton'
       ,@Tag = N'Transition'
       ,@Description = N'State transition of object'
       ,@Order = 1
END
