--liquibase formatted sql

--changeset vrafael:framework_20200220_06_dboFieldTypeSet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[FieldTypeSet]
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
   ,@StateMachineID dbo.[link] = NULL
   ,@DataType dbo.[string] = NULL
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT
        @ID = IIF(@ID > 0, @ID, NULL)
       ,@TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), dbo.TypeIDByTag(N'FieldType'));

    BEGIN TRAN;

    EXEC dbo.ObjectTypeSet
        @ID = @ID OUTPUT
       ,@TypeID = @TypeID
       ,@StateID = @StateID
       ,@OwnerID = @OwnerID
       ,@Name = @Name
       ,@Tag = @Tag
       ,@Description = @Description
       ,@Abstract = @Abstract
       ,@Icon = @Icon
       ,@StateMachineID = @StateMachineID;

    ---------FieldType---------
    WITH CTE as 
    (
        SELECT
            @ID as [ID]
           ,@DataType as [DataType]
    )
    MERGE [dbo].[TFieldType] [target]
    USING CTE [source] ON [target].[ID] = [source].[ID]
    WHEN MATCHED THEN
        UPDATE
        SET
            [DataType] = [source].[DataType]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [ID]
           ,[DataType]
        )
        VALUES
        (
            [source].[ID]
           ,[source].[DataType]
        );

    COMMIT TRAN;
END;