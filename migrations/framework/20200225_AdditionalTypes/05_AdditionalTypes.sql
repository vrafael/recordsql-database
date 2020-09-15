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
       ,@OwnerID = @TypeID_Directory
       ,@Name = N'Объект БД'
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
       ,@Name = N'Схема'
       ,@Tag = N'Schema'
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
       ,@OwnerID = @TypeID_DatabaseObject
       ,@Name = N'Хранимая процедура'
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
       ,@Name = N'Функция'
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
       ,@Name = N'Скалярная функция'
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
       ,@Name = N'Табличная функция'
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
       ,@Name = N'Инлайн функция'
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
       ,@Name = N'Таблица'
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
       ,@Name = N'Представление'
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
       ,@Name = N'Тип значения'
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
       ,@Name = N'Ссылка'
       ,@Tag = N'Link'
       ,@Description = N'Ссылка на другой объект'
       ,@Abstract = 1
       ,@Icon = N'las la-external-link-alt'
END

--LinkValueType
IF @TypeID_LinkValueType IS NULL
BEGIN
    EXEC dbo.TypeSet
        @ID = @TypeID_LinkValueType OUTPUT
       ,@TypeID = @TypeID_LinkType
       ,@OwnerID = @TypeID_Link
       ,@Name = N'Разрешение ссылки'
       ,@Tag = N'LinkValueType'
       ,@Description = N'Проверка ссылки на соответствие разрешенному типу'
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
       ,@Name = N'Ссылка на процедуру'
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
       ,@Name = N'Процедура на переходе'
       ,@Tag = N'LinkToStoredProcedureOnTransition'
       ,@Description = N'Ссылка на процедуру, вызываемую автоматически на переходе состояний'
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
       ,@Name = N'Процедура на состоянии'
       ,@Tag = N'LinkToStoredProcedureOnState'
       ,@Description = N'Ссылка на процедуру, вызываемую автоматически на входе в состояние/выходе из состояния'
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
       ,@Name = N'Событие'
       ,@Tag = N'Event'
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
       ,@OwnerID = @TypeID_Event
       ,@Name = N'Создание объекта'
       ,@Tag = N'EventCreate'
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
       ,@Name = N'Изменение объекта'
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
       ,@Name = N'Удаление объекта'
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
       ,@Name = N'Переход объекта'
       ,@Tag = N'EventTransition'
       ,@Description = NULL
       ,@Abstract = 0
       ,@Icon = N'las la-calendar-check'
END