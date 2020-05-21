--liquibase formatted sql

--changeset vrafael:framework_20200220_05_dboObjectTypeSet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[ObjectTypeSet]
    @ID dbo.[identifier] = NULL OUTPUT
   ,@TypeID dbo.[link] = NULL
   ,@TypeTag dbo.[string] = NULL
   ,@StateID dbo.[link] = NULL
   ,@Name dbo.[string] = NULL
   ,@Tag dbo.[string] = NULL
   ,@OwnerID dbo.[link] = NULL
   ,@Description nvarchar(max) = NULL
   ,@Abstract [bit] = NULL
   ,@Icon dbo.[string] = NULL
   ,@StateMachineID dbo.[link] = NULL
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @Inserted dbo.list

    SELECT
        @ID = IIF(@ID > 0, @ID, NULL)
       ,@TypeID = COALESCE(@TypeID, dbo.TypeIDByTag(@TypeTag), dbo.TypeIDByTag(N'ObjectType'));

    BEGIN TRAN;
            
    EXEC dbo.TypeSet
        @ID = @ID OUTPUT
       ,@TypeID = @TypeID
       ,@StateID = @StateID
       ,@Name = @Name
       ,@Tag = @Tag
       ,@OwnerID = @OwnerID
       ,@Description = @Description
       ,@Abstract = @Abstract
       ,@Icon = @Icon;

    ---------ObjectType---------
    WITH CTE as 
    (
        SELECT
            @ID as [ID]
           ,@StateMachineID as [StateMachineID]
    )
    MERGE [dbo].[TObjectType] [target]
    USING CTE [source] ON [target].[ID] = [source].[ID]
    WHEN MATCHED THEN
        UPDATE
        SET
            [StateMachineID] = [source].[StateMachineID]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [ID]
           ,[StateMachineID]
        )
        VALUES
        (
            [source].[ID]
           ,[source].[StateMachineID]
        );

    COMMIT TRAN;
END
GO