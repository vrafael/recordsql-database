--liquibase formatted sql

--changeset vrafael:framework_20200225_01_dboDatabaseObjectSet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[DatabaseObjectSet]
    @ID dbo.[identifier] = NULL OUTPUT
   ,@TypeID dbo.[link] = NULL
   ,@TypeTag dbo.[string] = NULL
   ,@StateID dbo.[link] = NULL
   ,@OwnerID dbo.[link] = NULL
   ,@Name dbo.[string] = NULL
   ,@Tag dbo.[string] = NULL
   ,@Description nvarchar(max) = NULL
   ,@object_id int = NULL
   ,@Script nvarchar(max) = NULL
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT
        @ID = IIF(@ID > 0, @ID, NULL)
       ,@TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), dbo.TypeIDByTag(N'DatabaseObject'));

    BEGIN TRAN;

    EXEC dbo.DirectorySet
        @ID = @ID OUTPUT
       ,@TypeID = @TypeID
       ,@StateID = @StateID
       ,@OwnerID = @OwnerID
       ,@Name = @Name
       ,@Tag = @Tag
       ,@Description = @Description;

    ---------DatabaseObject---------
    WITH CTE as
    (
        SELECT
            @ID as [ID]
           ,@object_id as [object_id]
           ,@Script as [Script]
    )
    MERGE [dbo].[TDatabaseObject] [target]
    USING CTE [source] ON [target].[ID] = [source].[ID]
    WHEN MATCHED THEN
        UPDATE
        SET
            [object_id] = [source].[object_id]
           ,[Script] = [source].[Script]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [ID]
           ,[object_id]
           ,[Script]
        )
        VALUES
        (
            [source].[ID]
           ,[source].[object_id]
           ,[source].[Script]
        );

    COMMIT TRAN;
END
GO