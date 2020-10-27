--liquibase formatted sql

--changeset vrafael:framework_20200225_02_dboLinkSet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[LinkSet]
    @LinkID dbo.[identifier] = NULL OUTPUT
   ,@TypeID dbo.[link] = NULL
   ,@TypeTag dbo.[string] = NULL
   ,@OwnerID dbo.[link] = NULL
   ,@TargetID dbo.link = NULL
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
        @LinkID = IIF(@LinkID > 0, @LinkID, NULL)
       ,@TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), dbo.TypeIDByTag(N'Value'));

    BEGIN TRAN;

    ---------Value---------
    WITH CTE as
    (
        SELECT
            @LinkID as [LinkID]
           ,@TypeID as [TypeID]
           ,@OwnerID as [OwnerID]
           ,@TargetID as [TargetID]
           ,@CaseID as [CaseID]
           ,@Order as [Order]
    )
    MERGE [dbo].[TLink] [target]
    USING CTE [source] ON [target].[LinkID] = [source].[LinkID]
    WHEN MATCHED THEN
        UPDATE
        SET
            [TypeID] = [source].[TypeID]
           ,[OwnerID] = [source].[OwnerID]
           ,[TargetID] = [source].[TargetID]
           ,[CaseID] = [source].[CaseID]
           ,[Order] = [source].[Order]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [TypeID]
           ,[OwnerID]
           ,[TargetID]
           ,[CaseID]
           ,[Order]
        )
        VALUES
        (
            [source].[TypeID]
           ,[source].[OwnerID]
           ,[source].[TargetID]
           ,[source].[CaseID]
           ,[source].[Order]
        )
        OUTPUT inserted.[LinkID] INTO @Inserted;

    SELECT TOP (1) @LinkID = I.[ID]
    FROM @Inserted I;

    COMMIT TRAN;
END
GO