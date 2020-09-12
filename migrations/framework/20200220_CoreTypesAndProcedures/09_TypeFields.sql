--liquibase formatted sql

--changeset vrafael:framework_20200220_TypeFields logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--добавление полей базовых типов
DECLARE 
    @TypeID_Object bigint = dbo.TypeIDByTag(N'Object')
   ,@FieldID_Object_ID bigint = dbo.DirectoryIDByOwner(N'Field', N'Object', N'ID')
   ,@FieldID_Object_Type bigint = dbo.DirectoryIDByOwner(N'Field', N'Object', N'Type')
   ,@FieldID_Object_State bigint = dbo.DirectoryIDByOwner(N'Field', N'Object', N'State')
   ,@FieldID_Object_Name bigint = dbo.DirectoryIDByOwner(N'Field', N'Object', N'Name')
   ,@FieldID_Object_Owner bigint = dbo.DirectoryIDByOwner(N'Field', N'Object', N'Owner')
   ,@TypeID_Directory bigint = dbo.TypeIDByTag(N'Directory')
   ,@FieldID_Directory_Tag bigint = dbo.DirectoryIDByOwner(N'Field', N'Directory', N'Tag')
   ,@FieldID_Directory_Description bigint = dbo.DirectoryIDByOwner(N'Field', N'Directory', N'Description')
   ,@TypeID_Type bigint = dbo.TypeIDByTag(N'Type')
   ,@FieldID_Type_Abstract bigint = dbo.DirectoryIDByOwner(N'Field', N'Type', N'Abstract')
   ,@FieldID_Type_Icon bigint = dbo.DirectoryIDByOwner(N'Field', N'Type', N'Icon')
   ,@TypeID_ObjectType bigint = dbo.TypeIDByTag(N'ObjectType')
   ,@FieldID_ObjectType_StateMachine bigint = dbo.DirectoryIDByOwner(N'Field', N'ObjectType', N'StateMachine')
   ,@TypeID_FieldType bigint = dbo.TypeIDByTag(N'FieldType')
   ,@FieldID_FieldType_DataType bigint = dbo.DirectoryIDByOwner(N'Field', N'FieldType', N'DataType')
   ,@TypeID_Field bigint = dbo.TypeIDByTag(N'Field')
   ,@FieldID_Field_Order bigint = dbo.DirectoryIDByOwner(N'Field', N'Field', N'Order')
   ,@TypeID_Error bigint = dbo.TypeIDByTag(N'Error')
   ,@FieldID_Error_ErrorID bigint = dbo.DirectoryIDByOwner(N'Field', N'Error', N'ErrorID')
   ,@FieldID_Error_Type bigint = dbo.DirectoryIDByOwner(N'Field', N'Error', N'Type')
   ,@FieldID_Error_Procedure bigint = dbo.DirectoryIDByOwner(N'Field', N'Error', N'Procedure')
   ,@FieldID_Error_Login bigint = dbo.DirectoryIDByOwner(N'Field', N'Error', N'Login')
   ,@FieldID_Error_Message bigint = dbo.DirectoryIDByOwner(N'Field', N'Error', N'Message')
   ,@FieldID_Error_Moment bigint = dbo.DirectoryIDByOwner(N'Field', N'Error', N'Moment')
   ,@FieldID_Error_Context bigint = dbo.DirectoryIDByOwner(N'Field', N'Error', N'Context')
   ,@FieldID_Error_Nestlevel bigint = dbo.DirectoryIDByOwner(N'Field', N'Error', N'Nestlevel')
   ,@FieldID_Error_Callstack bigint = dbo.DirectoryIDByOwner(N'Field', N'Error', N'Callstack')

--------------Object
--dbo.TObject	ID	identifier
IF @FieldID_Object_ID IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Object_ID OUTPUT
       ,@TypeTag = N'FieldIdentifier'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Object
       ,@Name = N'ID'
       ,@Tag = N'ID'
       ,@Description = NULL
       ,@Order = 1
END

--dbo.TObject	Type	link
IF @FieldID_Object_Type IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Object_Type OUTPUT
       ,@TypeTag = N'FieldLinkToType'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Object
       ,@Name = N'Тип'
       ,@Tag = N'Type'
       ,@Description = NULL
       ,@Order = 2
END

--dbo.TObject	State	link
IF @FieldID_Object_State IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Object_State OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Object
       ,@Name = N'Состояние'
       ,@Tag = N'State'
       ,@Description = NULL
       ,@Order = 3
END

--dbo.TObject	Owner	link
IF @FieldID_Object_Owner IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Object_Owner OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Object
       ,@Name = N'Владелец'
       ,@Tag = N'Owner'
       ,@Description = N'Поддержка иерархических структур'
       ,@Order = 4
END

--dbo.TObject	Name	string
IF @FieldID_Object_Name IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Object_Name OUTPUT
       ,@TypeTag = N'FieldString'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Object
       ,@Name = N'Наименование'
       ,@Tag = N'Name'
       ,@Description = NULL
       ,@Order = 5
END

--------------Directory
--dbo.TDirectory	Tag	string
IF @FieldID_Directory_Tag IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Directory_Tag OUTPUT
       ,@TypeTag = N'FieldString'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Directory
       ,@Name = N'Тег'
       ,@Tag = N'Tag'
       ,@Description = N'Уникальный код справочника'
       ,@Order = 2
END

--dbo.TDirectory	Description	nvarchar
IF @FieldID_Directory_Description IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Directory_Description OUTPUT
       ,@TypeTag = N'FieldText'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Directory
       ,@Name = N'Описание'
       ,@Tag = N'Description'
       ,@Description = NULL
       ,@Order = 3
END

--------------Type
--dbo.TType	Abstract	bool
IF @FieldID_Type_Abstract IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Type_Abstract OUTPUT
       ,@TypeTag = N'FieldBool'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Type
       ,@Name = N'Абстрактный'
       ,@Tag = N'Abstract'
       ,@Description = N'Супертип, нельзя создавать объекты абстрактного типа, только у его наследников'
       ,@Order = 1
END

--dbo.TType	Icon	string
IF @FieldID_Type_Icon IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Type_Icon OUTPUT
       ,@TypeTag = N'FieldString'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Type
       ,@Name = N'Иконка'
       ,@Tag = N'Icon'
       ,@Description = N'Название иконки из коллекции Font Awesome'
       ,@Order = 2
END

--------------ObjectType
--dbo.TObjectType	StateMachine	link
IF @FieldID_ObjectType_StateMachine IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_ObjectType_StateMachine OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_ObjectType
       ,@Name = N'Автомат состояний'
       ,@Tag = N'StateMachine'
       ,@Description = NULL
       ,@Order = 1
END

--------------FieldType
--dbo.TFieldType	DataType	string
IF @FieldID_FieldType_DataType IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_FieldType_DataType OUTPUT
       ,@TypeTag = N'FieldString'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_FieldType
       ,@Name = N'Тип данных'
       ,@Tag = N'DataType'
       ,@Description = N'Название типа поля в базе данных'
       ,@Order = 1
END

--------------Field
--dbo.TField	Order	int
IF @FieldID_Field_Order IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Field_Order OUTPUT
       ,@TypeTag = N'FieldInt'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Field
       ,@Name = N'Порядок'
       ,@Tag = N'Order'
       ,@Description = NULL
       ,@Order = 1
END

--------------Error
--dbo.TError	ErrorID	identifier
IF @FieldID_Error_ErrorID IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Error_ErrorID OUTPUT
       ,@TypeTag = N'FieldIdentifier'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Error
       ,@Name = N'ErrorID'
       ,@Tag = N'ErrorID'
       ,@Description = NULL
       ,@Order = 1
END

--dbo.TError	Type	link
IF @FieldID_Error_Type IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Error_Type OUTPUT
       ,@TypeTag = N'FieldLinkToType'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Error
       ,@Name = N'Тип'
       ,@Tag = N'Type'
       ,@Description = NULL
       ,@Order = 2
END

--dbo.TError	Procedure	link
IF @FieldID_Error_Procedure IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Error_Procedure OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Error
       ,@Name = N'Процедура'
       ,@Tag = N'Procedure'
       ,@Description = NULL
       ,@Order = 3
END

--dbo.TError	Login	link
IF @FieldID_Error_Login IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Error_Login OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Error
       ,@Name = N'Логин'
       ,@Tag = N'Login'
       ,@Description = NULL
       ,@Order = 4
END

--dbo.TError	Message	nvarchar
IF @FieldID_Error_Message IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Error_Message OUTPUT
       ,@TypeTag = N'FieldText'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Error
       ,@Name = N'Сообщение'
       ,@Tag = N'Message'
       ,@Description = NULL
       ,@Order = 5
END

--dbo.TError	Moment	datetime2
IF @FieldID_Error_Moment IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Error_Moment OUTPUT
       ,@TypeTag = N'FieldDatetime'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Error
       ,@Name = N'Момент'
       ,@Tag = N'Moment'
       ,@Description = NULL
       ,@Order = 6
END

--dbo.TError	Context	varbinary
IF @FieldID_Error_Context IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Error_Context OUTPUT
       ,@TypeTag = N'FieldVarbinary'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Error
       ,@Name = N'Контекст'
       ,@Tag = N'Context'
       ,@Description = N'Содержимое контекста в момент возникновения ошибки'
       ,@Order = 7
END

--dbo.TError	Nestlevel	int
IF @FieldID_Error_Nestlevel IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Error_Nestlevel OUTPUT
       ,@TypeTag = N'FieldInt'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Error
       ,@Name = N'Вложенность'
       ,@Tag = N'Nestlevel'
       ,@Description = N'Уровень вложенности'
       ,@Order = 8
END

--dbo.TError	Callstack	nvarchar
IF @FieldID_Error_Callstack IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Error_Callstack OUTPUT
       ,@TypeTag = N'FieldText'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Error
       ,@Name = N'Стек вызова'
       ,@Tag = N'Callstack'
       ,@Description = N'Иерархия вызовов процедур в момент возникновения ошибки в текстовом формате'
       ,@Order = 9
END
