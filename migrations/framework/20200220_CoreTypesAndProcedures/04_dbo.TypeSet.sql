--liquibase formatted sql

--changeset vrafael:framework_20200220_04_dboTypeSet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[TypeSet]
    @ID dbo.[identifier] = NULL OUTPUT
   ,@TypeID dbo.[link] = NULL
   ,@TypeTag dbo.[string] = NULL
   ,@StateID dbo.[link] = NULL
   ,@OwnerID dbo.[link] = NULL
   ,@Name dbo.[string] = NULL
   ,@Tag dbo.[string] = NULL
   ,@Description nvarchar(max) = NULL
   ,@Abstract [bit] = NULL
   ,@Icon dbo.[string] = NULL
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT
        @ID = IIF(@ID > 0, @ID, NULL)
       ,@TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), dbo.TypeIDByTag(N'Type'));

    BEGIN TRAN;
            
    EXEC dbo.DirectorySet
        @ID = @ID OUTPUT
       ,@TypeID = @TypeID
       ,@StateID = @StateID
       ,@OwnerID = @OwnerID
       ,@Name = @Name
       ,@Tag = @Tag
       ,@Description = @Description;

    ---------Type---------
    WITH CTE as 
    (
        SELECT
            @ID as [ID]
           ,@Abstract as [Abstract]
           ,@Icon as [Icon]
    )
    MERGE [dbo].[TType] [target]
    USING CTE [source] ON [target].[ID] = [source].[ID]
    WHEN MATCHED THEN
        UPDATE
        SET
            [Abstract] = [source].[Abstract]
           ,[Icon] = [source].[Icon]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [ID]
           ,[Abstract]
           ,[Icon]
        )
        VALUES
        (
            [source].[ID]
           ,[source].[Abstract]
           ,[source].[Icon]
        );

    COMMIT TRAN;
END
GO