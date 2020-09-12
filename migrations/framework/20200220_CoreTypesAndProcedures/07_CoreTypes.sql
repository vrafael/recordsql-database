--liquibase formatted sql

--changeset vrafael:framework_20200220_CoreTypes logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--добавление базовых типов
DECLARE
    @TypeID_Object bigint = dbo.TypeIDByTag(N'Object')
   ,@TypeID_Directory bigint = dbo.TypeIDByTag(N'Directory')
   ,@TypeID_Type bigint = dbo.TypeIDByTag(N'Type')
   ,@TypeID_ObjectType bigint = dbo.TypeIDByTag(N'ObjectType')
   ,@TypeID_DirectoryType bigint = dbo.TypeIDByTag(N'DirectoryType')
   ,@TypeID_FieldType bigint = dbo.TypeIDByTag(N'FieldType')
   ,@TypeID_Field bigint = dbo.TypeIDByTag(N'Field')
   ,@TypeID_Error bigint = dbo.TypeIDByTag(N'Error')
   ,@TypeID_SystemError bigint = dbo.TypeIDByTag(N'SystemError')
   ,@TypeID_SecurityError bigint = dbo.TypeIDByTag(N'SecurityError')

--Object
IF @TypeID_Object IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_Object OUTPUT
       ,@TypeID = -1 --@TypeID_ObjectType
       ,@OwnerID = NULL
       ,@Name = N'Объект'
       ,@Tag = N'Object'
       ,@Description = N'Базовый тип'
       ,@Abstract = 1
       ,@Icon = N'las la-atom'
       ,@StateMachineID = NULL
END

--Directory
IF @TypeID_Directory IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_Directory OUTPUT
       ,@TypeID = -1 --@TypeID_DirectoryType
       ,@OwnerID = @TypeID_Object
       ,@Name = N'Справочник'
       ,@Tag = N'Directory'
       ,@Description = N'Позиция справочника'
       ,@Abstract = 1
       ,@Icon = N'las la-book'
       ,@StateMachineID = NULL
END

--Type
IF @TypeID_Type IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_Type OUTPUT
       ,@TypeID = -1 --@TypeID_DirectoryType
       ,@OwnerID = @TypeID_Directory
       ,@Name = N'Тип'
       ,@Tag = N'Type'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-th-list'
       ,@StateMachineID = NULL
END

--ObjectType
IF @TypeID_ObjectType IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_ObjectType OUTPUT
       ,@TypeID = -1 --@TypeID_DirectoryType
       ,@OwnerID = @TypeID_Type
       ,@Name = N'Тип объекта'
       ,@Tag = N'ObjectType'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-th-list'
       ,@StateMachineID = NULL
END

--DirectoryType
IF @TypeID_DirectoryType IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_DirectoryType OUTPUT
       ,@TypeID = -1 --@TypeID_DirectoryType
       ,@OwnerID = @TypeID_ObjectType
       ,@Name = N'Тип справочника'
       ,@Tag = N'DirectoryType'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-th-large'
       ,@StateMachineID = NULL
END;

--при первичном добавлении объектов их типов еще не существует, поэтому заполнем их вручную
UPDATE o
SET TypeID = IIF(d.Tag = N'Object', @TypeID_ObjectType, @TypeID_DirectoryType)
FROM dbo.TObject o
    JOIN dbo.TDirectory d ON d.ID = o.ID 
    JOIN dbo.TType t ON t.ID = d.ID
    JOIN dbo.TObjectType ot ON ot.ID = t.ID
WHERE d.Tag IN (N'Object', N'Directory', N'Type', N'ObjectType', N'DirectoryType')
    AND o.TypeID = -1 --тип не указан

--FieldType
IF @TypeID_FieldType IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_FieldType OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@OwnerID = @TypeID_DirectoryType
       ,@Name = N'Тип поля'
       ,@Tag = N'FieldType'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-columns'
       ,@StateMachineID = NULL
END

--Field
IF @TypeID_Field IS NULL
BEGIN
    EXEC dbo.FieldTypeSet
        @ID = @TypeID_Field OUTPUT
       ,@TypeID = @TypeID_FieldType
       ,@OwnerID = @TypeID_Directory
       ,@Name = N'Поле'
       ,@Tag = N'Field'
       ,@Description = N'Поле типа'
       ,@Abstract = 1
       ,@Icon = N'las la-tag'
       ,@StateMachineID = NULL
       ,@DataType = N'sql_variant'
END

--Error
IF @TypeID_Error IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_Error OUTPUT
       ,@TypeID = @TypeID_Type
       ,@OwnerID = NULL
       ,@Name = N'Ошибка'
       ,@Tag = N'Error'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-exclamation-circle'
END

--SystemError
IF @TypeID_SystemError IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_SystemError OUTPUT
       ,@TypeID = @TypeID_Type
       ,@OwnerID = @TypeID_Error
       ,@Name = N'Системная ошибка'
       ,@Tag = N'SystemError'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-bug'
END

--SecurityError
IF @TypeID_SecurityError IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_SecurityError OUTPUT
       ,@TypeID = @TypeID_Type
       ,@OwnerID = @TypeID_Error
       ,@Name = N'Ошибка безопасности'
       ,@Tag = N'SecurityError'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-exclamation-triangle'
END