--liquibase formatted sql

--changeset vrafael:framework_20200603_Test_02_Test logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true context:dev,test
--тестовый тип
DECLARE
    @TypeID_ObjectType bigint = dbo.TypeIDByTag(N'ObjectType')
   ,@TypeID_Object bigint = dbo.TypeIDByTag(N'Object')
   ,@TypeID_Test bigint = dbo.TypeIDByTag(N'Test')
   ,@FieldID_Test_Link bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'Link')
   ,@FieldID_Test_Color bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'Color')
   ,@FieldID_Test_Integer bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'Integer')
   ,@FieldID_Test_Bigint bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'Bigint')
   ,@FieldID_Test_Text bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'Text')
   ,@FieldID_Test_Boolean bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'Boolean')
   ,@FieldID_Test_Datetime bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'Datetime')
   ,@FieldID_Test_Varbinary bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'Varbinary')
   ,@FieldID_Test_Float bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'Float')
   ,@FieldID_Test_Money bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'Money')
   ,@FieldID_Test_Date bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'Date')
   ,@FieldID_Test_Time bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'Time')
   ,@StateMachineID_Basic bigint = dbo.DirectoryIDByTag(N'StateMachine', N'Basic')

BEGIN TRAN

--Test
IF @TypeID_Test IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_Test OUTPUT
       ,@TypeID = @TypeID_ObjectType
       ,@OwnerID = @TypeID_Object
       ,@Name = N'Test type'
       ,@Tag = N'Test'
       ,@Description = N'Test type for checking the display fields'
       ,@Abstract = 0
       ,@Icon = N'las la-cat'
       ,@StateMachineID = @StateMachineID_Basic
END

IF @FieldID_Test_Color IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_Color OUTPUT
       ,@TypeTag = N'FieldColor'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Test
       ,@Name = N'Color'
       ,@Tag = N'Color'
       ,@Description = NULL
       ,@Order = 5
END

IF @FieldID_Test_Integer IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_Integer OUTPUT
       ,@TypeTag = N'FieldInt'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Test
       ,@Name = N'Integer'
       ,@Tag = N'Integer'
       ,@Description =NULL
       ,@Order = 6
END

IF @FieldID_Test_Bigint IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_Bigint OUTPUT
       ,@TypeTag = N'FieldBigint'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Test
       ,@Name = N'Bigint'
       ,@Tag = N'Bigint'
       ,@Description = NULL
       ,@Order = 7
END

IF @FieldID_Test_Text IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_Text OUTPUT
       ,@TypeTag = N'FieldText'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Test
       ,@Name = N'Text'
       ,@Tag = N'Text'
       ,@Description = NULL
       ,@Order = 8
END

IF @FieldID_Test_Boolean IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_Boolean OUTPUT
       ,@TypeTag = N'FieldBool'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Test
       ,@Name = N'Boolean'
       ,@Tag = N'Boolean'
       ,@Description = NULL
       ,@Order = 9
END

IF @FieldID_Test_Datetime IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_Datetime OUTPUT
       ,@TypeTag = N'FieldDatetime'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Test
       ,@Name = N'Datetime'
       ,@Tag = N'Datetime'
       ,@Description = NULL
       ,@Order = 10
END

IF @FieldID_Test_Varbinary IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_Varbinary OUTPUT
       ,@TypeTag = N'FieldVarbinary'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Test
       ,@Name = N'Varbinary'
       ,@Tag = N'Varbinary'
       ,@Description = NULL
       ,@Order = 11
END

IF @FieldID_Test_Float IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_Float OUTPUT
       ,@TypeTag = N'FieldFloat'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Test
       ,@Name = N'Float'
       ,@Tag = N'Float'
       ,@Description = NULL
       ,@Order = 12
END

IF @FieldID_Test_Money IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_Money OUTPUT
       ,@TypeTag = N'FieldMoney'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Test
       ,@Name = N'Money'
       ,@Tag = N'Money'
       ,@Description = NULL
       ,@Order = 13
END

IF @FieldID_Test_Date IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_Date OUTPUT
       ,@TypeTag = N'FieldDate'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Test
       ,@Name = N'Date'
       ,@Tag = N'Date'
       ,@Description = NULL
       ,@Order = 14
END

IF @FieldID_Test_Time IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_Time OUTPUT
       ,@TypeTag = N'FieldTime'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Test
       ,@Name = N'Time'
       ,@Tag = N'Time'
       ,@Description = NULL
       ,@Order = 15
END

--формируем поля
EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_Color
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_Integer
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_Bigint
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_Text
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_Boolean
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_Datetime
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_Varbinary
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_Float
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_Money
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_Date
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_Time
   ,@StateTag = N'Formed'

--формируем тип
EXEC dbo.ObjectStatePush
    @ID = @TypeID_Test
   ,@StateTag = N'Formed'

COMMIT
