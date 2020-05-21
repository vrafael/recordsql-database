--liquibase formatted sql

--changeset vrafael:framework_20200225_08_AdditionalFields logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--добавление полей типов автомата состояний
DECLARE
    @TypeID_DatabaseObject bigint = dbo.TypeIDByTag(N'DatabaseObject')
   ,@FieldID_DatabaseObject_object_id bigint = dbo.DirectoryIDByOwner(N'Field', N'DatabaseObject', N'object_id')
   ,@FieldID_DatabaseObject_Script bigint = dbo.DirectoryIDByOwner(N'Field', N'DatabaseObject', N'Script')
   ,@TypeID_State bigint = dbo.TypeIDByTag(N'State')
   ,@FieldID_State_Color bigint = dbo.DirectoryIDByOwner(N'Field', N'State', N'Color')
   ,@TypeID_Value bigint = dbo.TypeIDByTag(N'Value')
   ,@FieldID_Value_ValueID bigint = dbo.DirectoryIDByOwner(N'Field', N'Value', N'ValueID')
   ,@FieldID_Value_Type bigint = dbo.DirectoryIDByOwner(N'Field', N'Value', N'Type')
   ,@FieldID_Value_Owner bigint = dbo.DirectoryIDByOwner(N'Field', N'Value', N'Owner')
   ,@FieldID_Value_Case bigint = dbo.DirectoryIDByOwner(N'Field', N'Value', N'Case')
   ,@FieldID_Value_Order bigint = dbo.DirectoryIDByOwner(N'Field', N'Value', N'Order')
   ,@TypeID_Link bigint = dbo.TypeIDByTag(N'Link')
   ,@FieldID_Link_Linked bigint = dbo.DirectoryIDByOwner(N'Field', N'Link', N'Linked')
   ,@TypeID_String bigint = dbo.TypeIDByTag(N'String')
   ,@FieldID_String_Value bigint = dbo.DirectoryIDByOwner(N'Field', N'String', N'Value')
   ,@TypeID_Event bigint = dbo.TypeIDByTag(N'Event')
   ,@FieldID_Event_EventID bigint = dbo.DirectoryIDByOwner(N'Field', N'Value', N'ValueID')
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
       ,@Name = N'object_id'
       ,@OwnerID = @TypeID_DatabaseObject
       ,@Tag = N'object_id'
       ,@Description = N'Идентификатор объекта в базе данных'
       ,@Order = 1
END

--dbo.TDatabaseObject	Script	nvarchar
IF @FieldID_DatabaseObject_Script IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_DatabaseObject_Script OUTPUT
       ,@TypeTag = N'FieldText'
       ,@StateID = NULL
       ,@Name = N'Скрипт'
       ,@OwnerID = @TypeID_DatabaseObject
       ,@Tag = N'Script'
       ,@Description = N'Скрипт объекта базе данных'
       ,@Order = 2
END

--------------Value
--dbo.TValue	ValueID	identifier
IF @FieldID_Value_ValueID IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Value_ValueID OUTPUT
       ,@TypeTag = N'FieldIdentifier'
       ,@StateID = NULL
       ,@Name = N'ValueID'
       ,@OwnerID = @TypeID_Value
       ,@Tag = N'ValueID'
       ,@Description = N'Идентификатор значения'
       ,@Order = 1
END

--dbo.TValue	Type	link
IF @FieldID_Value_Type IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Value_Type OUTPUT
       ,@TypeTag = N'FieldLinkToType'
       ,@StateID = NULL
       ,@Name = N'Тип'
       ,@OwnerID = @TypeID_Value
       ,@Tag = N'Type'
       ,@Description = N'Тип значения'
       ,@Order = 2
END

--dbo.TValue	Owner	link
IF @FieldID_Value_Owner IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Value_Owner OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@Name = N'Владелец'
       ,@OwnerID = @TypeID_Value
       ,@Tag = N'Owner'
       ,@Description = N'Владелец значения'
       ,@Order = 3
END

--dbo.TValue	Case	link
IF @FieldID_Value_Case IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Value_Case OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@Name = N'Условие'
       ,@OwnerID = @TypeID_Value
       ,@Tag = N'Case'
       ,@Description = N'Необязательное условие'
       ,@Order = 4
END

--dbo.TValue	Order	int
IF @FieldID_Value_Order IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Value_Order OUTPUT
       ,@TypeTag = N'FieldInt'
       ,@StateID = NULL
       ,@Name = N'Порядок'
       ,@OwnerID = @TypeID_Value
       ,@Tag = N'Order'
       ,@Description = NULL
       ,@Order = 5
END

--------------Link
--dbo.TLink	Linked	link
IF @FieldID_Link_Linked IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Link_Linked OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@Name = N'Связанный'
       ,@OwnerID = @TypeID_Link
       ,@Tag = N'Linked'
       ,@Description = N'Объект на который указывает ссылка'
       ,@Order = 1
END

--------------String
--dbo.TString	Value	FieldString
IF @FieldID_String_Value IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_String_Value OUTPUT
       ,@TypeTag = N'FieldString'
       ,@StateID = NULL
       ,@Name = N'Значение'
       ,@OwnerID = @TypeID_String
       ,@Tag = N'Value'
       ,@Description = N'Значение строки'
       ,@Order = 1
END

--------------Event
--dbo.TEvent	EventID	identifier
IF @FieldID_Event_EventID IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Event_EventID OUTPUT
       ,@TypeTag = N'FieldIdentifier'
       ,@StateID = NULL
       ,@Name = N'EventID'
       ,@OwnerID = @TypeID_Event
       ,@Tag = N'EventID'
       ,@Description = N'Идентификатор события'
       ,@Order = 1
END

--dbo.TEvent	Type	link
IF @FieldID_Event_Type IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Event_Type OUTPUT
       ,@TypeTag = N'FieldLinkToType'
       ,@StateID = NULL
       ,@Name = N'Тип'
       ,@OwnerID = @TypeID_Event
       ,@Tag = N'Type'
       ,@Description = N'Тип события'
       ,@Order = 2
END

--dbo.TEvent	 Object	link
IF @FieldID_Event_Object IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Event_Object OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@Name = N'Объект'
       ,@OwnerID = @TypeID_Event
       ,@Tag = N'Object'
       ,@Description = N'Объект события'
       ,@Order = 3
END

--dbo.TEvent	Login	link
IF @FieldID_Event_Login IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Event_Login OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@Name = N'Логин'
       ,@OwnerID = @TypeID_Event
       ,@Tag = N'Login'
       ,@Description = N'Логин события'
       ,@Order = 4
END

--dbo.TEvent    Moment	int
IF @FieldID_Event_Moment IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Event_Moment OUTPUT
       ,@TypeTag = N'FieldDatetime'
       ,@StateID = NULL
       ,@Name = N'Момент'
       ,@OwnerID = @TypeID_Event
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
       ,@Name = N'Переход'
       ,@OwnerID = @TypeID_EventTransition
       ,@Tag = N'Transition'
       ,@Description = N'Переход объекта'
       ,@Order = 1
END