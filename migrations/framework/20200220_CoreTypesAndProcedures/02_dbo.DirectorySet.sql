--liquibase formatted sql

--changeset vrafael:framework_20200220_02_dboDirectorySet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[DirectorySet]
    @ID dbo.[identifier] = NULL OUTPUT
   ,@TypeID dbo.[link] = NULL
   ,@TypeTag dbo.[string] = NULL
   ,@StateID dbo.[link] = NULL
   ,@OwnerID dbo.[link] = NULL
   ,@Name dbo.[string] = NULL
   ,@Tag dbo.[string] = NULL
   ,@Description nvarchar(max) = NULL
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT
        @ID = IIF(@ID > 0, @ID, NULL)
       ,@TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), dbo.TypeIDByTag(N'Directory'));

    BEGIN TRAN;

    ---------Object---------
    EXEC dbo.ObjectSet
        @ID = @ID OUTPUT
       ,@TypeID = @TypeID
       ,@StateID = @StateID
       ,@OwnerID = @OwnerID
       ,@Name = @Name;

    ---------Directory---------
    WITH CTE as
    (
        SELECT
            @ID as [ID]
           ,@Tag as [Tag]
           ,@Description as [Description]
    )
    MERGE [dbo].[TDirectory] [target]
    USING CTE [source] ON [target].[ID] = [source].[ID]
    WHEN MATCHED THEN
        UPDATE
        SET
            [Tag] = [source].[Tag]
           ,[Description] = [source].[Description]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [ID]
           ,[Tag]
           ,[Description]
        )
        VALUES
        (
            [source].[ID]
           ,[source].[Tag]
           ,[source].[Description]
        );

    COMMIT TRAN;
END
GO