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
       ,@Name = N'Объект'
       ,@Tag = N'Object'
       ,@OwnerID = NULL
       ,@Description = N'Базовый тип'
       ,@Abstract = 1
       ,@Icon = NULL
       ,@StateMachineID = NULL
END

--Directory
IF @TypeID_Directory IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_Directory OUTPUT
       ,@TypeID = -1 --@TypeID_DirectoryType
       ,@Name = N'Справочник'
       ,@Tag = N'Directory'
       ,@OwnerID = @TypeID_Object
       ,@Description = N'Позиция справочника'
       ,@Abstract = 1
       ,@Icon = NULL
       ,@StateMachineID = NULL
END

--Type
IF @TypeID_Type IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_Type OUTPUT
       ,@TypeID = -1 --@TypeID_DirectoryType
       ,@Name = N'Тип'
       ,@Tag = N'Type'
       ,@OwnerID = @TypeID_Directory
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = NULL
       ,@StateMachineID = NULL
END

--ObjectType
IF @TypeID_ObjectType IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_ObjectType OUTPUT
       ,@TypeID = -1 --@TypeID_DirectoryType
       ,@Name = N'Тип объекта'
       ,@Tag = N'ObjectType'
       ,@OwnerID = @TypeID_Type
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = NULL
       ,@StateMachineID = NULL
END

--DirectoryType
IF @TypeID_DirectoryType IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_DirectoryType OUTPUT
       ,@TypeID = -1 --@TypeID_DirectoryType
       ,@Name = N'Тип справочника'
       ,@Tag = N'DirectoryType'
       ,@OwnerID = @TypeID_ObjectType
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = NULL
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
       ,@Name = N'Тип поля'
       ,@Tag = N'FieldType'
       ,@OwnerID = @TypeID_DirectoryType
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = NULL
       ,@StateMachineID = NULL
END

--Field
IF @TypeID_Field IS NULL
BEGIN
    EXEC dbo.FieldTypeSet
        @ID = @TypeID_Field OUTPUT
       ,@TypeID = @TypeID_FieldType
       ,@Name = N'Поле'
       ,@Tag = N'Field'
       ,@OwnerID = @TypeID_Directory
       ,@Description = N'Поле типа'
       ,@Abstract = 1
       ,@Icon = NULL
       ,@StateMachineID = NULL
       ,@DataType = N'sql_variant'
END

--Error
IF @TypeID_Error IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_Error OUTPUT
       ,@TypeID = @TypeID_Type
       ,@Name = N'Ошибка'
       ,@Tag = N'Error'
       ,@OwnerID = NULL
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = NULL
END

--SystemError
IF @TypeID_SystemError IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_SystemError OUTPUT
       ,@TypeID = @TypeID_Type
       ,@Name = N'Системная ошибка'
       ,@Tag = N'SystemError'
       ,@OwnerID = @TypeID_Error
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = NULL
END

--SecurityError
IF @TypeID_SecurityError IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_SecurityError OUTPUT
       ,@TypeID = @TypeID_Type
       ,@Name = N'Ошибка безопасности'
       ,@Tag = N'SecurityError'
       ,@OwnerID = @TypeID_Error
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = NULL
END