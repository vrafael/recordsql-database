--liquibase formatted sql

--changeset vrafael:framework_20200225_AdditionalTypes_09_dboDatabaseObjectDescription logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[DatabaseObjectDescription]
    @ObjectName dbo.string
   ,@Description nvarchar(max)
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @object_id int = OBJECT_ID(@ObjectName)
       ,@DatabaseObjectID bigint

    IF @object_id IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не найден объект в базе данных "%s"'
           ,@p0 = @ObjectName
    END

    SELECT TOP (1) 
        @DatabaseObjectID = do.ID
    FROM dbo.VDatabaseObject do 
    WHERE do.object_id = @object_id

    IF @DatabaseObjectID IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'В системе не зарегистрирован объект "%s"'
           ,@p0 = @ObjectName
    END

    UPDATE TOP (1) d
    SET d.[Description] = @Description
    FROM dbo.TDirectory d 
    WHERE d.ID = @DatabaseObjectID
END
--EXEC dbo.DatabaseObjectDescription N'Dev.Swagger', N'Список всех методов API с описанием и списком параметров'
GO