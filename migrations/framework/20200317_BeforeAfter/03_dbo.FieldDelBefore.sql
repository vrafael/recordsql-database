--liquibase formatted sql

--changeset vrafael:framework_20200317_BeforeAfter_03_dboFieldDelBefore logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[FieldDelBefore]
    @ID bigint
   ,@OwnerID bigint
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')

    IF EXISTS
    (
        SELECT 1
        FROM dbo.TObject oo 
        WHERE oo.ID = @OwnerID
            AND oo.StateID = @StateID_Basic_Formed
    )
    BEGIN
        EXEC dbo.Error
            @Message = N'При удалении поля ID=%s его владелец ID=%s должен быть расформирован'
           ,@p0 = @ID
           ,@p1 = @OwnerID
    END
END
GO