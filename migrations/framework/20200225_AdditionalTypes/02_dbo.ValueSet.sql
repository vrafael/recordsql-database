--liquibase formatted sql

--changeset vrafael:framework_20200225_03_dboValueSet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[ValueSet]
    @ValueID dbo.[identifier] = NULL OUTPUT
   ,@TypeID dbo.[link] = NULL
   ,@TypeTag dbo.[string] = NULL
   ,@OwnerID dbo.[link] = NULL
   ,@CaseID dbo.link = NULL
   ,@Order int = NULL
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @Inserted dbo.list;

    SELECT
        @ValueID = IIF(@ValueID > 0, @ValueID, NULL)
       ,@TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), dbo.TypeIDByTag(N'Value'));

    BEGIN TRAN;

    ---------Value---------
    WITH CTE as
    (
        SELECT
            @ValueID as [ValueID]
           ,@TypeID as [TypeID]
           ,@OwnerID as [OwnerID]
           ,@CaseID as [CaseID]
           ,@Order as [Order]
    )
    MERGE [dbo].[TValue] [target]
    USING CTE [source] ON [target].[ValueID] = [source].[ValueID]
    WHEN MATCHED THEN
        UPDATE
        SET
            [TypeID] = [source].[TypeID]
           ,[OwnerID] = [source].[OwnerID]
           ,[CaseID] = [source].[CaseID]
           ,[Order] = [source].[Order]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [TypeID]
           ,[OwnerID]
           ,[CaseID]
           ,[Order]
        )
        VALUES
        (
            [source].[TypeID]
           ,[source].[OwnerID]
           ,[source].[CaseID]
           ,[source].[Order]
        )
        OUTPUT inserted.[ValueID] INTO @Inserted;

    SELECT TOP (1) @ValueID = I.[ID]
    FROM @Inserted I;

    COMMIT TRAN;
END
GO