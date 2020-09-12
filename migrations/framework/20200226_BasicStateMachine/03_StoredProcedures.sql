--liquibase formatted sql

--changeset vrafael:framework_20200226_01_StoredProcedures logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
DECLARE
    @SchemaID_dbo bigint = dbo.DirectoryIDByTag(N'Schema', N'dbo')
   ,@StoredProcedureID_dbo_BasicTransition bigint = dbo.DirectoryIDByOwner(N'StoredProcedure', N'dbo', N'BasicTransition')

IF @SchemaID_dbo IS NULL
BEGIN
    EXEC dbo.DirectorySet
        @ID = @SchemaID_dbo OUTPUT
       ,@TypeTag = N'Schema'
       ,@OwnerID = NULL
       ,@Name = N'dbo'
       ,@Tag = N'dbo'
       ,@Description = NULL
END

IF @StoredProcedureID_dbo_BasicTransition IS NULL
BEGIN
    EXEC dbo.DatabaseObjectSet
        @ID = @StoredProcedureID_dbo_BasicTransition OUTPUT
       ,@TypeTag = N'StoredProcedure'
       ,@OwnerID = @SchemaID_dbo
       ,@Name = N'dbo.BasicTransition'
       ,@Tag = N'BasicTransition'
       ,@Description = N'Процедура вызывает привязанные к этому переходу через Ссылки на процедуру на переходе Процедуры в зависимости от типа обрабатываемого объекта в поле Условие ссылки'
       ,@object_id = NULL
       ,@Script = NULL
END
