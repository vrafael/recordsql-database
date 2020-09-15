--liquibase formatted sql

--changeset vrafael:framework_20200225_03_dboEventSet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[EventSet]
    @EventID dbo.[identifier] = NULL OUTPUT
   ,@TypeID dbo.[link] = NULL
   ,@TypeTag dbo.[string] = NULL
   ,@ObjectID dbo.[link] = NULL
   ,@LoginID dbo.link = NULL
   ,@Moment datetime2 = NULL
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @Inserted dbo.list;

    SELECT
        @EventID = IIF(@EventID > 0, @EventID, NULL)
       ,@TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), dbo.TypeIDByTag(N'Event'));

    BEGIN TRAN;

    ---------Event---------
    WITH CTE as
    (
        SELECT
            @EventID as [EventID]
           ,@TypeID as [TypeID]
           ,@ObjectID as [ObjectID]
           ,@LoginID as [LoginID]
           ,@Moment as [Moment]
    )
    MERGE [dbo].[TEvent] [target]
    USING CTE [source] ON [target].[EventID] = [source].[EventID]
    WHEN MATCHED THEN
        UPDATE
        SET
            [TypeID] = [source].[TypeID]
           ,[ObjectID] = [source].[ObjectID]
           ,[LoginID] = [source].[LoginID]
           ,[Moment] = [source].[Moment]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [TypeID]
           ,[ObjectID]
           ,[LoginID]
           ,[Moment]
        )
        VALUES
        (
            [source].[TypeID]
           ,[source].[ObjectID]
           ,[source].[LoginID]
           ,[source].[Moment]
        )
        OUTPUT inserted.[EventID] INTO @Inserted;

    SELECT TOP (1) @EventID = I.[ID]
    FROM @Inserted I;

    COMMIT TRAN;
END
GO