--liquibase formatted sql

--changeset vrafael:framework_20200321_BeforeAfter_StateMachine_02_dboStateSetBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[StateSetBefore]
    @ID bigint
   ,@Name dbo.string
   ,@OwnerID bigint
   ,@Tag dbo.string
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @ExistStateID bigint
       ,@TypeID_State bigint = dbo.TypeIDByTag(N'State')

    IF @OwnerID IS NULL
    BEGIN
        EXEC dbo.Error
            @Message = N'Нельзя создать состояние "%s" без автомата состояния'
           ,@p0 = @Name
    END

    SELECT TOP (1)
        @ExistStateID = o.ID
    FROM dbo.DirectoryChildrenInline(@TypeID_State, N'Type', 1) ct
        JOIN dbo.TObject o ON o.TypeID = ct.ID
        JOIN dbo.TDirectory d ON d.ID = o.ID
    WHERE (o.OwnerID = @OwnerID)
        AND (d.[Tag] = @Tag)
        AND (@ID IS NULL OR o.ID <> @ID)

    IF @ExistStateID IS NOT NULL
    BEGIN
        EXEC dbo.Error
            @Message = N'На автомате состояний ID=%s уже существует состояние ID=%s с кодом "%s"'
           ,@p0 = @OwnerID
           ,@p1 = @ExistStateID
           ,@p2 = @Tag
    END
END
GO