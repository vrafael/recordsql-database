--liquibase formatted sql

--changeset vrafael:framework_20200222_02_dboTransitionSet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[TransitionSet]
    @ID dbo.[identifier] = NULL OUTPUT
   ,@TypeID dbo.[link] = NULL
   ,@TypeTag dbo.[string] = NULL
   ,@StateID dbo.[link] = NULL
   ,@OwnerID dbo.[link] = NULL
   ,@Name dbo.[string] = NULL
   ,@Tag dbo.[string] = NULL
   ,@Description nvarchar(max) = NULL
   ,@SourceStateID dbo.[link] = NULL
   ,@TargetStateID dbo.[link] = NULL
   ,@Priority int = NULL
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT
        @ID = IIF(@ID > 0, @ID, NULL)
       ,@TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), dbo.TypeIDByTag(N'Transition'));

    BEGIN TRAN;

    EXEC dbo.DirectorySet
        @ID = @ID OUTPUT
       ,@TypeID = @TypeID
       ,@StateID = @StateID
       ,@OwnerID = @OwnerID
       ,@Name = @Name
       ,@Tag = @Tag
       ,@Description = @Description;

    ---------Transition---------
    WITH CTE as
    (
        SELECT
            @ID as [ID]
           ,@SourceStateID as SourceStateID
           ,@TargetStateID as TargetStateID
           ,@Priority as [Priority]
    )
    MERGE [dbo].[TTransition] [target]
    USING CTE [source] ON [target].[ID] = [source].[ID]
    WHEN MATCHED THEN
        UPDATE
        SET
            SourceStateID = [source].[SourceStateID]
           ,TargetStateID = [source].[TargetStateID]
           ,[Priority] = [source].[Priority]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [ID]
           ,[SourceStateID]
           ,[TargetStateID]
           ,[Priority]
        )
        VALUES
        (
            [source].[ID]
           ,[source].[SourceStateID]
           ,[source].[TargetStateID]
           ,[source].[Priority]
        );

    COMMIT TRAN;
END
GO