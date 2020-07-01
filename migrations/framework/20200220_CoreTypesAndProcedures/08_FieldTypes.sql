--liquibase formatted sql

--changeset vrafael:framework_20200220_FieldTypes logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--добавление базовых типов полей
DECLARE
    @TypeID_FieldType bigint = dbo.TypeIDByTag(N'FieldType')
   ,@TypeID_Field bigint = dbo.TypeIDByTag(N'Field')
   ,@TypeID_FieldIdentifier bigint = dbo.TypeIDByTag(N'FieldIdentifier')
   ,@TypeID_FieldLink bigint = dbo.TypeIDByTag(N'FieldLink')
   ,@TypeID_FieldLinkToType bigint = dbo.TypeIDByTag(N'FieldLinkToType')
   ,@TypeID_FieldString bigint = dbo.TypeIDByTag(N'FieldString')
   ,@TypeID_FieldColor bigint = dbo.TypeIDByTag(N'FieldColor')
   ,@TypeID_FieldInt bigint = dbo.TypeIDByTag(N'FieldInt')
   ,@TypeID_FieldBigint bigint = dbo.TypeIDByTag(N'FieldBigint')
   ,@TypeID_FieldDatetime bigint = dbo.TypeIDByTag(N'FieldDatetime')
   ,@TypeID_FieldText bigint = dbo.TypeIDByTag(N'FieldText')
   ,@TypeID_FieldBool bigint = dbo.TypeIDByTag(N'FieldBool')
   ,@TypeID_FieldVarbinary bigint = dbo.TypeIDByTag(N'FieldVarbinary')
   ,@TypeID_FieldFloat bigint = dbo.TypeIDByTag(N'FieldFloat')
   ,@TypeID_FieldMoney bigint = dbo.TypeIDByTag(N'FieldMoney')
   
--FieldIdentifier
IF @TypeID_FieldIdentifier IS NULL
BEGIN
    EXEC dbo.FieldTypeSet
        @ID = @TypeID_FieldIdentifier OUTPUT
       ,@TypeID = @TypeID_FieldType
       ,@Name = N'Поле идентификатор'
       ,@Tag = N'FieldIdentifier'
       ,@OwnerID = @TypeID_Field
       ,@Description = N'Уникальный идентификатор записи. Может быть только на типе верхнего уровня'
       ,@Abstract = 0
       ,@Icon = N'las la-italic'
       ,@StateMachineID = NULL
       ,@DataType = N'dbo.identifier'
END

--FieldLink
IF @TypeID_FieldLink IS NULL
BEGIN
    EXEC dbo.FieldTypeSet
        @ID = @TypeID_FieldLink OUTPUT
       ,@TypeID = @TypeID_FieldType
       ,@Name = N'Поле ссылка'
       ,@Tag = N'FieldLink'
       ,@OwnerID = @TypeID_Field
       ,@Description = N'Ссылка на объект'
       ,@Abstract = 0
       ,@Icon = N'la la-link'
       ,@StateMachineID = NULL
       ,@DataType = N'dbo.link'
END

--FieldLinkToType
IF @TypeID_FieldLinkToType IS NULL
BEGIN
    EXEC dbo.FieldTypeSet
        @ID = @TypeID_FieldLinkToType OUTPUT
       ,@TypeID = @TypeID_FieldType
       ,@Name = N'Поле ссылка на тип'
       ,@Tag = N'FieldLinkToType'
       ,@OwnerID = @TypeID_FieldLink
       ,@Description = N'Ссылка на тип объекта'
       ,@Abstract = 0
       ,@Icon = N'las la-link'
       ,@StateMachineID = NULL
       ,@DataType = N'dbo.link'
END

--FieldString
IF @TypeID_FieldString IS NULL
BEGIN
    EXEC dbo.FieldTypeSet
        @ID = @TypeID_FieldString OUTPUT
       ,@TypeID = @TypeID_FieldType
       ,@Name = N'Поле строка'
       ,@Tag = N'FieldString'
       ,@OwnerID = @TypeID_Field
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-font'
       ,@StateMachineID = NULL
       ,@DataType = N'dbo.string'
END

--FieldColor
IF @TypeID_FieldColor IS NULL
BEGIN
    EXEC dbo.FieldTypeSet
        @ID = @TypeID_FieldColor OUTPUT
       ,@TypeID = @TypeID_FieldType
       ,@Name = N'Поле цвет'
       ,@Tag = N'FieldColor'
       ,@OwnerID = @TypeID_Field
       ,@Description = N'Цвет в формате HEX RGBA'
       ,@Abstract = 0
       ,@Icon = N'las la-palette'
       ,@StateMachineID = NULL
       ,@DataType = N'dbo.color'
END

--FieldInt
IF @TypeID_FieldInt IS NULL
BEGIN
    EXEC dbo.FieldTypeSet
        @ID = @TypeID_FieldInt OUTPUT
       ,@TypeID = @TypeID_FieldType
       ,@Name = N'Поле целое число'
       ,@Tag = N'FieldInt'
       ,@OwnerID = @TypeID_Field
       ,@Description = N'Целое число от -2147483648 до 2147483647 (32бит)'
       ,@Abstract = 0
       ,@Icon = N'las la-quote-left'
       ,@StateMachineID = NULL
       ,@DataType = N'int'
END

--FieldBigint
IF @TypeID_FieldBigint IS NULL
BEGIN
    EXEC dbo.FieldTypeSet
        @ID = @TypeID_FieldBigint OUTPUT
       ,@TypeID = @TypeID_FieldType
       ,@Name = N'Поле большое целое число'
       ,@Tag = N'FieldBigint'
       ,@OwnerID = @TypeID_Field
       ,@Description = N'Целое число с расширенным диапазоном (64бит)'
       ,@Abstract = 0
       ,@Icon = N'las la-quote-right'
       ,@StateMachineID = NULL
       ,@DataType = N'bigint'
END

--FieldText
IF @TypeID_FieldText IS NULL
BEGIN
    EXEC dbo.FieldTypeSet
        @ID = @TypeID_FieldText OUTPUT
       ,@TypeID = @TypeID_FieldType
       ,@Name = N'Поле текст'
       ,@Tag = N'FieldText'
       ,@OwnerID = @TypeID_Field
       ,@Description = N'Текстовые данные до 2Гб юникод'
       ,@Abstract = 0
       ,@Icon = N'las la-text-height'
       ,@StateMachineID = NULL
       ,@DataType = N'nvarchar(max)'
END

--FieldBool
IF @TypeID_FieldBool IS NULL
BEGIN
    EXEC dbo.FieldTypeSet
        @ID = @TypeID_FieldBool OUTPUT
       ,@TypeID = @TypeID_FieldType
       ,@Name = N'Поле логическое'
       ,@Tag = N'FieldBool'
       ,@OwnerID = @TypeID_Field
       ,@Description = N'Логические булевый тип принимающий значения 1(TRUE), 0(FALSE)'
       ,@Abstract = 0
       ,@Icon = N'las la-check-square'
       ,@StateMachineID = NULL
       ,@DataType = N'bit'
END

--FieldDatetime
IF @TypeID_FieldDatetime IS NULL
BEGIN
    EXEC dbo.FieldTypeSet
        @ID = @TypeID_FieldDatetime OUTPUT
       ,@TypeID = @TypeID_FieldType
       ,@Name = N'Поле дата и время'
       ,@Tag = N'FieldDatetime'
       ,@OwnerID = @TypeID_Field
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-clock'
       ,@StateMachineID = NULL
       ,@DataType = N'datetime2'
END

--FieldVarbinary
IF @TypeID_FieldVarbinary IS NULL
BEGIN
    EXEC dbo.FieldTypeSet
        @ID = @TypeID_FieldVarbinary OUTPUT
       ,@TypeID = @TypeID_FieldType
       ,@Name = N'Поле двоичные данные'
       ,@Tag = N'FieldVarbinary'
       ,@OwnerID = @TypeID_Field
       ,@Description = N'Данные в двоичном формате'
       ,@Abstract = 0
       ,@Icon = N'las la-file-import'
       ,@StateMachineID = NULL
       ,@DataType = N'varbinary(max)'
END

--FieldFloat
IF @TypeID_FieldFloat IS NULL
BEGIN
    EXEC dbo.FieldTypeSet
        @ID = @TypeID_FieldFloat OUTPUT
       ,@TypeID = @TypeID_FieldType
       ,@Name = N'Поле дробное число'
       ,@Tag = N'FieldFloat'
       ,@OwnerID = @TypeID_Field
       ,@Description = N'Число с плавающей запятой'
       ,@Abstract = 0
       ,@Icon = N'las la-calculator'
       ,@StateMachineID = NULL
       ,@DataType = N'float'
END

--FieldMoney
IF @TypeID_FieldMoney IS NULL
BEGIN
    EXEC dbo.FieldTypeSet
        @ID = @TypeID_FieldMoney OUTPUT
       ,@TypeID = @TypeID_FieldType
       ,@Name = N'Поле деньги'
       ,@Tag = N'FieldMoney'
       ,@OwnerID = @TypeID_Field
       ,@Description = N'Поле содержащее денежные (валютные) значения'
       ,@Abstract = 0
       ,@Icon = N'las la-money-bill'
       ,@StateMachineID = NULL
       ,@DataType = N'money'
END