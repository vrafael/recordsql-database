--liquibase formatted sql

--changeset vrafael:framework_20200225_03_dboLinkSet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[LinkSet]
    @ValueID dbo.[identifier] = NULL OUTPUT
   ,@TypeID dbo.[link] = NULL
   ,@TypeTag dbo.[string] = NULL
   ,@OwnerID dbo.[link] = NULL
   ,@CaseID dbo.link = NULL
   ,@Order int = NULL
   ,@LinkedID dbo.link = NULL
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
       ,@TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), dbo.TypeIDByTag(N'Link'));

    BEGIN TRAN;

    EXEC dbo.ValueSet
        @ValueID = @ValueID OUTPUT
       ,@TypeID = @TypeID
       ,@TypeTag = @TypeTag
       ,@OwnerID = @OwnerID
       ,@CaseID = @CaseID
       ,@Order = @Order;

    ---------Link---------
    WITH CTE as
    (
        SELECT
            @ValueID as [ValueID]
           ,@LinkedID as [LinkedID]
    )
    MERGE [dbo].[TLink] [target]
    USING CTE [source] ON [target].[ValueID] = [source].[ValueID]
    WHEN MATCHED THEN
        UPDATE
        SET
            [LinkedID] = [source].[LinkedID]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [ValueID]
           ,[LinkedID]
        )
        VALUES
        (
            [source].[ValueID]
           ,[source].[LinkedID]
        );

    COMMIT TRAN;
END
GO