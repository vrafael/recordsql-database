--liquibase formatted sql

--changeset vrafael:framework_20200220_03_dboFieldSet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[FieldSet]
    @ID dbo.[identifier] = NULL OUTPUT
   ,@TypeID dbo.[link] = NULL
   ,@TypeTag dbo.[string] = NULL
   ,@StateID dbo.[link] = NULL
   ,@OwnerID dbo.[link] = NULL
   ,@Name dbo.[string] = NULL
   ,@Tag dbo.[string] = NULL
   ,@Description nvarchar(max) = NULL
   ,@Order [int] = NULL
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT
        @ID = IIF(@ID > 0, @ID, NULL)
       ,@TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), dbo.TypeIDByTag(N'Field'));

    BEGIN TRAN;

    EXEC dbo.DirectorySet
        @ID = @ID OUTPUT
       ,@TypeID = @TypeID
       ,@StateID = @StateID
       ,@OwnerID = @OwnerID
       ,@Name = @Name
       ,@Tag = @Tag
       ,@Description = @Description;

    ---------Field---------
    WITH CTE as 
    (
        SELECT
            @ID as [ID]
           ,@Order as [Order]
    )
    MERGE [dbo].[TField] [target]
    USING CTE [source] ON [target].[ID] = [source].[ID]
    WHEN MATCHED THEN
        UPDATE
        SET
            [Order] = [source].[Order]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [ID]
           ,[Order]
        )
        VALUES
        (
            [source].[ID]
           ,[source].[Order]
        );

    COMMIT TRAN;
END
GO