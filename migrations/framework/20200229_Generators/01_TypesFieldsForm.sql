--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_01_TypesFieldsForm logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--применение всем типам и полям базового типа состояний
DECLARE 
    @StateMachineID_Basic bigint = dbo.DirectoryIDByTag(N'StateMachine', N'Basic')
   ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')

--переводим все типы на базовый конечный автомат
UPDATE ot
SET StateMachineID = @StateMachineID_Basic
FROM dbo.DirectoryChildrenInline(dbo.TypeIDByTag(N'Type'), N'Type', 1) t
    JOIN dbo.TObjectType ot ON ot.ID = t.ID
WHERE ot.StateMachineID IS NULL


--переводим все поля на базовый конечный автомат
UPDATE ot
SET StateMachineID = @StateMachineID_Basic
FROM dbo.TObjectType ot 
    JOIN dbo.TFieldType ft ON ft.ID = ot.ID
WHERE ot.StateMachineID IS NULL

--переводим все объекты БД на базовый конечный автомат
UPDATE ot
SET StateMachineID = @StateMachineID_Basic
FROM dbo.DirectoryChildrenInline(dbo.TypeIDByTag(N'DatabaseObject'), N'Type', 1) t
    JOIN dbo.TObjectType ot ON ot.ID = t.ID
WHERE ot.StateMachineID IS NULL

--отмечаем все объекты типов с базовым конечным автоматом сформированными --ToDo DANGER!!! отрефакторить скрипт
UPDATE o
SET StateID = @StateID_Basic_Formed
FROM dbo.TObjectType ot
    JOIN dbo.TObject o ON o.TypeID = ot.ID
WHERE ot.StateMachineID = @StateMachineID_Basic
    AND o.StateID IS NULL