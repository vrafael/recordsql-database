--liquibase formatted sql

--changeset vrafael:framework_20200603_Test_02_Test logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true context:dev,test
--тестовый тип
DECLARE
    @TypeID_ObjectType bigint = dbo.TypeIDByTag(N'ObjectType')
   ,@TypeID_Object bigint = dbo.TypeIDByTag(N'Object')
   ,@TypeID_Test bigint = dbo.TypeIDByTag(N'Test')
   ,@FieldID_Test_FieldColor bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'FieldColor')
   ,@FieldID_Test_FieldInt bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'FieldInt')
   ,@FieldID_Test_FieldBigint bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'FieldBigint')
   ,@FieldID_Test_FieldText bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'FieldText')
   ,@FieldID_Test_FieldBool bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'FieldBool')
   ,@FieldID_Test_FieldDatetime bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'FieldDatetime')
   ,@FieldID_Test_FieldVarbinary bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'FieldVarbinary')
   ,@FieldID_Test_FieldFloat bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'FieldFloat')
   ,@FieldID_Test_FieldMoney bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'FieldMoney')
   ,@FieldID_Test_FieldDate bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'FieldDate')
   ,@FieldID_Test_FieldTime bigint = dbo.DirectoryIDByOwner(N'Field', N'Test', N'FieldTime')
   ,@StateMachineID_Basic bigint = dbo.DirectoryIDByTag(N'StateMachine', N'Basic')

BEGIN TRAN

--Test
IF @TypeID_Test IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_Test OUTPUT
       ,@TypeID = @TypeID_ObjectType
       ,@Name = N'Тестовый тип'
       ,@Tag = N'Test'
       ,@OwnerID = @TypeID_Object
       ,@Description = N'Тип для проверки отображения полей'
       ,@Abstract = 0
       ,@Icon = N'las la-cat'
       ,@StateMachineID = @StateMachineID_Basic
END

IF @FieldID_Test_FieldColor IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_FieldColor OUTPUT
       ,@TypeTag = N'FieldColor'
       ,@StateID = NULL
       ,@Name = N'Поле FieldColor'
       ,@OwnerID = @TypeID_Test
       ,@Tag = N'FieldColor'
       ,@Description = NULL
       ,@Order = 5
END

IF @FieldID_Test_FieldInt IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_FieldInt OUTPUT
       ,@TypeTag = N'FieldInt'
       ,@StateID = NULL
       ,@Name = N'Поле FieldInt'
       ,@OwnerID = @TypeID_Test
       ,@Tag = N'FieldInt'
       ,@Description =NULL
       ,@Order = 6
END

IF @FieldID_Test_FieldBigint IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_FieldBigint OUTPUT
       ,@TypeTag = N'FieldBigint'
       ,@StateID = NULL
       ,@Name = N'Поле FieldBigint'
       ,@OwnerID = @TypeID_Test
       ,@Tag = N'FieldBigint'
       ,@Description = NULL
       ,@Order = 7
END

IF @FieldID_Test_FieldText IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_FieldText OUTPUT
       ,@TypeTag = N'FieldText'
       ,@StateID = NULL
       ,@Name = N'Поле FieldText'
       ,@OwnerID = @TypeID_Test
       ,@Tag = N'FieldText'
       ,@Description = NULL
       ,@Order = 8
END

IF @FieldID_Test_FieldBool IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_FieldBool OUTPUT
       ,@TypeTag = N'FieldBool'
       ,@StateID = NULL
       ,@Name = N'Поле FieldBool'
       ,@OwnerID = @TypeID_Test
       ,@Tag = N'FieldBool'
       ,@Description = NULL
       ,@Order = 9
END

IF @FieldID_Test_FieldDatetime IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_FieldDatetime OUTPUT
       ,@TypeTag = N'FieldDatetime'
       ,@StateID = NULL
       ,@Name = N'Поле FieldDatetime'
       ,@OwnerID = @TypeID_Test
       ,@Tag = N'FieldDatetime'
       ,@Description = NULL
       ,@Order = 10
END

IF @FieldID_Test_FieldVarbinary IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_FieldVarbinary OUTPUT
       ,@TypeTag = N'FieldVarbinary'
       ,@StateID = NULL
       ,@Name = N'Поле FieldVarbinary'
       ,@OwnerID = @TypeID_Test
       ,@Tag = N'FieldVarbinary'
       ,@Description = NULL
       ,@Order = 11
END

IF @FieldID_Test_FieldFloat IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_FieldFloat OUTPUT
       ,@TypeTag = N'FieldFloat'
       ,@StateID = NULL
       ,@Name = N'Поле FieldFloat'
       ,@OwnerID = @TypeID_Test
       ,@Tag = N'FieldFloat'
       ,@Description = NULL
       ,@Order = 12
END

IF @FieldID_Test_FieldMoney IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_FieldMoney OUTPUT
       ,@TypeTag = N'FieldMoney'
       ,@StateID = NULL
       ,@Name = N'Поле FieldMoney'
       ,@OwnerID = @TypeID_Test
       ,@Tag = N'FieldMoney'
       ,@Description = NULL
       ,@Order = 13
END

IF @FieldID_Test_FieldDate IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_FieldDate OUTPUT
       ,@TypeTag = N'FieldDate'
       ,@StateID = NULL
       ,@Name = N'Поле FieldDate'
       ,@OwnerID = @TypeID_Test
       ,@Tag = N'FieldDate'
       ,@Description = NULL
       ,@Order = 14
END

IF @FieldID_Test_FieldTime IS NULL
BEGIN
    EXEC dbo.FieldSet
        @ID = @FieldID_Test_FieldTime OUTPUT
       ,@TypeTag = N'FieldTime'
       ,@StateID = NULL
       ,@Name = N'Поле FieldTime'
       ,@OwnerID = @TypeID_Test
       ,@Tag = N'FieldTime'
       ,@Description = NULL
       ,@Order = 15
END

--формируем поля
EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_FieldColor
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_FieldInt
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_FieldBigint
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_FieldText
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_FieldBool
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_FieldDatetime
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_FieldVarbinary
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_FieldFloat
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_FieldMoney
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_FieldDate
   ,@StateTag = N'Formed'

EXEC dbo.ObjectStatePush
    @ID = @FieldID_Test_FieldTime
   ,@StateTag = N'Formed'

--формируем тип
EXEC dbo.ObjectStatePush
    @ID = @TypeID_Test
   ,@StateTag = N'Formed'

COMMIT
