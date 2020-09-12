--liquibase formatted sql

--changeset vrafael:framework_20200220_01_dboObjectSet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[ObjectSet]
    @ID dbo.[identifier] = NULL OUTPUT
   ,@TypeID dbo.[link] = NULL
   ,@TypeTag dbo.[string] = NULL
   ,@StateID dbo.[link] = NULL
   ,@OwnerID dbo.[link] = NULL
   ,@Name dbo.[string] = NULL
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @Inserted dbo.list

    SELECT
        @ID = IIF(@ID > 0, @ID, NULL)
       ,@TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), dbo.TypeIDByTag(N'Object'));

    BEGIN TRAN;

    ---------Object---------
    WITH CTE as 
    (
        SELECT
            @ID as [ID]
           ,@TypeID as [TypeID]
           ,@StateID as [StateID]
           ,@OwnerID as [OwnerID]
           ,@Name as [Name]
    )
    MERGE [dbo].[TObject] [target]
    USING CTE [source] ON [target].[ID] = [source].[ID]
    WHEN MATCHED THEN
        UPDATE
        SET
            [TypeID] = [source].[TypeID]
           ,[StateID] = [source].[StateID]
           ,[OwnerID] = [source].[OwnerID]
           ,[Name] = [source].[Name]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [TypeID]
           ,[StateID]
           ,[OwnerID]
           ,[Name]
        )
        VALUES
        (
            [source].[TypeID]
           ,[source].[StateID]
           ,[source].[OwnerID]
           ,[source].[Name]
        )
        OUTPUT inserted.[ID] INTO @Inserted;

    SELECT TOP (1) @ID = I.[ID]
    FROM @Inserted I;

    COMMIT TRAN;
END
GO