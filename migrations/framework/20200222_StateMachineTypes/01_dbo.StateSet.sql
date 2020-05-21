--liquibase formatted sql

--changeset vrafael:framework_20200222_01_dboStateSet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[StateSet]
    @ID dbo.[identifier] = NULL OUTPUT
   ,@TypeID dbo.[link] = NULL
   ,@TypeTag dbo.[string] = NULL
   ,@StateID dbo.[link] = NULL
   ,@Name dbo.[string] = NULL
   ,@OwnerID dbo.[link] = NULL
   ,@Tag dbo.[string] = NULL
   ,@Description nvarchar(max) = NULL
   ,@Color dbo.color = NULL
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT
        @ID = IIF(@ID > 0, @ID, NULL)
       ,@TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), dbo.TypeIDByTag(N'State'));

    BEGIN TRAN;

    EXEC dbo.DirectorySet
        @ID = @ID OUTPUT
       ,@TypeID = @TypeID
       ,@StateID = @StateID
       ,@Name = @Name
       ,@OwnerID = @OwnerID
       ,@Tag = @Tag
       ,@Description = @Description;

    ---------State---------
    WITH CTE as
    (
        SELECT
            @ID as [ID]
           ,@Color as [Color]
    )
    MERGE [dbo].[TState] [target]
    USING CTE [source] ON [target].[ID] = [source].[ID]
    WHEN MATCHED THEN
        UPDATE
        SET
            [Color] = [source].[Color]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [ID]
           ,[Color]
        )
        VALUES
        (
            [source].[ID]
           ,[source].[Color]
        );

    COMMIT TRAN;
END
GO