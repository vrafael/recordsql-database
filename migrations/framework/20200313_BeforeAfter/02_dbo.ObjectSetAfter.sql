--liquibase formatted sql

--changeset vrafael:framework_20200313_BeforeAfter_02_dboObjectSetAfter logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[ObjectSetAfter]
    @ID bigint
   ,@EventTypeID bigint --переменная для проброса из SetBefore процедуры типа события
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    EXEC dbo.EventSet
        @TypeID = @EventTypeID
       ,@ObjectID = @ID
END
GO