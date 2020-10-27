--liquibase formatted sql

--changeset vrafael:framework_20200313_BeforeAfter_07_dboObjectTypeDelBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[ObjectTypeDelBefore]
    @ID bigint
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    --проверяем наличие записей этого типа
    IF EXISTS
    (
        SELECT 1
        FROM dbo.TObject o
        WHERE o.TypeID = @ID
    )
    BEGIN
        EXEC dbo.Error
            @Message = N'Нельзя удалить тип ID=%s, т.к. существуют объекты этого типа'
           ,@p0 = @ID
    END
END
GO