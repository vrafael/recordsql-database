--liquibase formatted sql

--changeset vrafael:framework_20200319_BeforeAfter_02_dboEventDelBefore logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[EventDelBefore]
    @EventID bigint
   ,@ObjectID bigint
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    IF EXISTS
    (
        SELECT 1
        FROM dbo.TObject o
        WHERE o.ID = @ObjectID
    )
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Запрещено удалять событие EventID=%s объекта ID=%s'
           ,@p0 = @EventID
           ,@p1 = @ObjectID
    END
END
GO