--liquibase formatted sql

--changeset vrafael:framework_20200225_07_AdditionalTypes logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
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
   ,@TypeID_ValueType bigint = dbo.TypeIDByTag(N'ValueType')
   ,@TypeID_Value bigint = dbo.TypeIDByTag(N'Value')
   ,@TypeID_Link bigint = dbo.TypeIDByTag(N'Link')
   ,@TypeID_LinkValueType bigint = dbo.TypeIDByTag(N'LinkValueType')
   ,@TypeID_LinkToStoredProcedure bigint = dbo.TypeIDByTag(N'LinkToStoredProcedure')
   ,@TypeID_LinkToStoredProcedureOnTransition bigint = dbo.TypeIDByTag(N'LinkToStoredProcedureOnTransition')
   ,@TypeID_LinkToStoredProcedureOnState bigint = dbo.TypeIDByTag(N'LinkToStoredProcedureOnState')
   ,@TypeID_String bigint = dbo.TypeIDByTag(N'String')
   ,@TypeID_Event bigint = dbo.TypeIDByTag(N'Event')
   ,@TypeID_EventCreate bigint = dbo.TypeIDByTag(N'EventCreate')
   ,@TypeID_EventUpdate bigint = dbo.TypeIDByTag(N'EventUpdate')
   ,@TypeID_EventDelete bigint = dbo.TypeIDByTag(N'EventDelete')
   ,@TypeID_EventTransition bigint = dbo.TypeIDByTag(N'EventTransition')

--DatabaseObject
IF @TypeID_DatabaseObject IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_DatabaseObject OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@Name = N'Объект БД'
       ,@Tag = N'DatabaseObject'
       ,@OwnerID = @TypeID_Directory
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
       ,@Name = N'Схема'
       ,@Tag = N'Schema'
       ,@OwnerID = @TypeID_Directory
       ,@Description = N'Схема базы данных'
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
       ,@Name = N'Хранимая процедура'
       ,@Tag = N'StoredProcedure'
       ,@OwnerID = @TypeID_DatabaseObject
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
       ,@Name = N'Функция'
       ,@Tag = N'Function'
       ,@OwnerID = @TypeID_DatabaseObject
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
       ,@Name = N'Скалярная функция'
       ,@Tag = N'ScalarFunction'
       ,@OwnerID = @TypeID_Function
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
       ,@Name = N'Табличная функция'
       ,@Tag = N'TableFunction'
       ,@OwnerID = @TypeID_Function
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
       ,@Name = N'Инлайн функция'
       ,@Tag = N'InlineFunction'
       ,@OwnerID = @TypeID_Function
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
       ,@Name = N'Таблица'
       ,@Tag = N'Table'
       ,@OwnerID = @TypeID_DatabaseObject
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
       ,@Name = N'Представление'
       ,@Tag = N'View'
       ,@OwnerID = @TypeID_DatabaseObject
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-border-none'
       ,@StateMachineID = NULL
END

--ValueType
IF @TypeID_ValueType IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_ValueType OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@Name = N'Тип значения'
       ,@Tag = N'ValueType'
       ,@OwnerID = @TypeID_Type
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-table'
END

--Value
IF @TypeID_Value IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_Value OUTPUT
       ,@TypeID = @TypeID_ValueType
       ,@Name = N'Значение'
       ,@Tag = N'Value'
       ,@OwnerID = NULL
       ,@Description = N'Внешнее значение объекта'
       ,@Abstract = 1
       ,@Icon = N'las la-paperclip'
END

--Link
IF @TypeID_Link IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_Link OUTPUT
       ,@TypeID = @TypeID_ValueType
       ,@Name = N'Ссылка'
       ,@Tag = N'Link'
       ,@OwnerID = @TypeID_Value
       ,@Description = N'Ссылка на другой объект'
       ,@Abstract = 1
       ,@Icon = N'las la-external-link-alt'
END

--LinkValueType
IF @TypeID_LinkValueType IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_LinkValueType OUTPUT
       ,@TypeID = @TypeID_ValueType
       ,@Name = N'Разрешенный тип значения ссылки'
       ,@Tag = N'LinkValueType'
       ,@OwnerID = @TypeID_Link
       ,@Description = N'Проверка ссылки на соответствие разрешенному типу'
       ,@Abstract = 0
       ,@Icon = N'las la-anchor'
END

--LinkToStoredProcedure
IF @TypeID_LinkToStoredProcedure IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_LinkToStoredProcedure OUTPUT
       ,@TypeID = @TypeID_ValueType
       ,@Name = N'Ссылка на процедуру'
       ,@Tag = N'LinkToStoredProcedure'
       ,@OwnerID = @TypeID_Link
       ,@Description = NULL
       ,@Abstract = 1
       ,@Icon = N'las la-external-link-alt'
END

--LinkToStoredProcedureOnTransition
IF @TypeID_LinkToStoredProcedureOnTransition IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_LinkToStoredProcedureOnTransition OUTPUT
       ,@TypeID = @TypeID_ValueType
       ,@Name = N'Процедура на переходе'
       ,@Tag = N'LinkToStoredProcedureOnTransition'
       ,@OwnerID = @TypeID_LinkToStoredProcedure
       ,@Description = N'Ссылка на процедуру, вызываемую автоматически на переходе состояний'
       ,@Abstract = 0
       ,@Icon = N'las la-external-link-alt'
END

--LinkToStoredProcedureOnState
IF @TypeID_LinkToStoredProcedureOnState IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_LinkToStoredProcedureOnState OUTPUT
       ,@TypeID = @TypeID_ValueType
       ,@Name = N'Процедура на состоянии'
       ,@Tag = N'LinkToStoredProcedureOnState'
       ,@OwnerID = @TypeID_LinkToStoredProcedure
       ,@Description = N'Ссылка на процедуру, вызываемую автоматически на входе в состояние/выходе из состояния'
       ,@Abstract = 0
       ,@Icon = N'las la-external-link-alt'
END

--String
IF @TypeID_String IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_String OUTPUT
       ,@TypeID = @TypeID_ValueType
       ,@Name = N'Строка'
       ,@Tag = N'String'
       ,@OwnerID = @TypeID_Value
       ,@Description = N'Внешнаяя строка объекта'
       ,@Abstract = 1
       ,@Icon = N'las la-paragraph'
END

--Event
IF @TypeID_Event IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_Event OUTPUT
       ,@TypeID = @TypeID_Type
       ,@Name = N'Событие'
       ,@Tag = N'Event'
       ,@OwnerID = NULL
       ,@Description = N'Событие объекта'
       ,@Abstract = 1
       ,@Icon = N'las la-calendar-times'
END

--EventCreate
IF @TypeID_EventCreate IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_EventCreate OUTPUT
       ,@TypeID = @TypeID_Type
       ,@Name = N'Создание объекта'
       ,@Tag = N'EventCreate'
       ,@OwnerID = @TypeID_Event
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
       ,@Name = N'Изменение объекта'
       ,@Tag = N'EventUpdate'
       ,@OwnerID = @TypeID_Event
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
       ,@Name = N'Удаление объекта'
       ,@Tag = N'EventDelete'
       ,@OwnerID = @TypeID_Event
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
       ,@Name = N'Переход объекта'
       ,@Tag = N'EventTransition'
       ,@OwnerID = @TypeID_Event
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-calendar-check'
END