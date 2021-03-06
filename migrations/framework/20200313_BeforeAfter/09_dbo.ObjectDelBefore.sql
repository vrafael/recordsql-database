--liquibase formatted sql

--changeset vrafael:framework_20200313_BeforeAfter_09_dboObjectDelBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[ObjectDelBefore]
    @ID bigint
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @ChildrenCount int

    SELECT
        @ChildrenCount = COUNT(1)
    FROM dbo.TObject o
    WHERE o.OwnerID = @ID

    IF @ChildrenCount > 0
    BEGIN
        EXEC dbo.Error 
            @Message = N'Нельзя удалить ID=%s т.к. у него есть %s дочерних объектов'
           ,@p0 = @ID
           ,@p1 = @ChildrenCount
    END
END
GO