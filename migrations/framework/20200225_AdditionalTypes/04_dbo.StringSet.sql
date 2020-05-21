--liquibase formatted sql

--changeset vrafael:framework_20200225_04_dboStringSet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[StringSet]
    @ValueID dbo.[identifier] = NULL OUTPUT
   ,@TypeID dbo.[link] = NULL
   ,@TypeTag dbo.[string] = NULL
   ,@OwnerID dbo.[link] = NULL
   ,@CaseID dbo.link = NULL
   ,@Order int = NULL
   ,@String dbo.string = NULL
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
       ,@TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), dbo.TypeIDByTag(N'String'));

    BEGIN TRAN;

    EXEC dbo.ValueSet
        @ValueID = @ValueID OUTPUT
       ,@TypeID = @TypeID
       ,@TypeTag = @TypeTag
       ,@OwnerID = @OwnerID
       ,@CaseID = @CaseID
       ,@Order = @Order;

    ---------String---------
    WITH CTE as
    (
        SELECT
            @ValueID as [ValueID]
           ,@String as [String]
    )
    MERGE [dbo].[TString] [target]
    USING CTE [source] ON [target].[ValueID] = [source].[ValueID]
    WHEN MATCHED THEN
        UPDATE
        SET
            [String] = [source].[String]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [ValueID]
           ,[String]
        )
        VALUES
        (
            [source].[ValueID]
           ,[source].[String]
        );

    COMMIT TRAN;
END
GO