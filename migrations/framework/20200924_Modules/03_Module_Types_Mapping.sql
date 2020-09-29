--liquibase formatted sql

--changeset vrafael:framework_20200924_Modules_03_Module_Types_Mapping logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
DECLARE
    @TypeID_Module bigint = dbo.TypeIDByTag(N'Module');

WITH ModuleTypeMapping AS
(
    SELECT
        t.ID as TypeID
       ,d.ID as ModuleID
    FROM 
        (
            VALUES
                (N'Type', N'Typization')
               ,(N'ObjectType', N'Typization')
               ,(N'DirectoryType', N'Typization')
               ,(N'FieldType', N'Typization')
               ,(N'Error', N'ErrorHandling')
               ,(N'SystemError', N'ErrorHandling')
               ,(N'SecurityError', N'ErrorHandling')
               ,(N'Field', N'Typization')
               ,(N'FieldIdentifier', N'Typization')
               ,(N'FieldLink', N'Typization')
               ,(N'FieldLinkToType', N'Typization')
               ,(N'FieldString', N'Typization')
               ,(N'FieldColor', N'Typization')
               ,(N'FieldInt', N'Typization')
               ,(N'FieldBigint', N'Typization')
               ,(N'FieldText', N'Typization')
               ,(N'FieldBool', N'Typization')
               ,(N'FieldDatetime', N'Typization')
               ,(N'FieldDate', N'Typization')
               ,(N'FieldTime', N'Typization')
               ,(N'FieldVarbinary', N'Typization')
               ,(N'FieldFloat', N'Typization')
               ,(N'FieldMoney', N'Typization')
               ,(N'StateMachine', N'StateMachine')
               ,(N'State', N'StateMachine')
               ,(N'Transition', N'StateMachine')
               ,(N'Schema', N'DataBase')
               ,(N'StoredProcedure', N'DataBase')
               ,(N'Function', N'DataBase')
               ,(N'ScalarFunction', N'DataBase')
               ,(N'TableFunction', N'DataBase')
               ,(N'InlineFunction', N'DataBase')
               ,(N'Table', N'DataBase')
               ,(N'View', N'DataBase')
               ,(N'LinkType', N'Typization')
               ,(N'Relationship', N'Typization')
               ,(N'LinkToStoredProcedureOnTransition', N'StateMachine')
               ,(N'LinkToStoredProcedureOnState', N'StateMachine')
               ,(N'Event', N'History')
               ,(N'EventInsert', N'History')
               ,(N'EventUpdate', N'History')
               ,(N'EventDelete', N'History')
               ,(N'EventTransition', N'History')
               ,(N'CaseTransitionOrder', N'StateMachine')
               ,(N'Module', N'Typization')
        ) mtm (TypeTag, ModuleTag)
        JOIN dbo.VType t ON t.Tag = mtm.TypeTag
        JOIN dbo.VDirectory d ON d.Tag = mtm.ModuleTag
            AND d.TypeID = @TypeID_Module
)
UPDATE t
SET t.ModuleID = (SELECT TOP (1) mtm.ModuleID FROM ModuleTypeMapping mtm WHERE mtm.TypeID = t.ID)
FROM dbo.TType t
WHERE EXISTS(SELECT 1 FROM ModuleTypeMapping mtm WHERE mtm.TypeID = t.ID AND (t.ModuleID IS NULL OR mtm.ModuleID <> t.ModuleID))