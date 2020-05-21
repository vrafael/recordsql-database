--liquibase formatted sql

--changeset vrafael:framework_20200225_06_dboEventTransitionSet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[EventTransitionSet]
    @EventID dbo.[identifier] = NULL OUTPUT
   ,@TypeID dbo.[link] = NULL
   ,@TypeTag dbo.[string] = NULL
   ,@ObjectID dbo.[link] = NULL
   ,@LoginID dbo.link = NULL
   ,@Moment datetime2 = NULL
   ,@TransitionID dbo.[link] = NULL
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
       ,@TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), dbo.TypeIDByTag(N'EventTransition'));

    BEGIN TRAN;

    EXEC dbo.EventSet
        @EventID = @EventID OUTPUT
       ,@TypeID = @TypeID
       ,@TypeTag = @TypeTag
       ,@ObjectID = @ObjectID
       ,@LoginID = @LoginID
       ,@Moment = @Moment;

    ---------EventTransition---------
    WITH CTE as
    (
        SELECT
            @EventID as [EventID]
           ,@TransitionID as [TransitionID]
    )
    MERGE [dbo].[TEventTransition] [target]
    USING CTE [source] ON [target].[EventID] = [source].[EventID]
    WHEN MATCHED THEN
        UPDATE
        SET
            [TransitionID] = [source].[TransitionID]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [EventID]
           ,[TransitionID]
        )
        VALUES
        (
            [source].[EventID]
           ,[source].[TransitionID]
        );

    COMMIT TRAN;
END
GO