--liquibase formatted sql

--changeset vrafael:framework_20200321_BeforeAfter_09_dboDatabaseObjectDelBefore logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[DatabaseObjectDelBefore]
    @ID bigint
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @LinkOwnerID bigint
       ,@LinkTypeID bigint
    
    SELECT TOP (1)
        @LinkTypeID = v.TypeID
       ,@LinkOwnerID = v.OwnerID
    FROM dbo.TValue v
        JOIN dbo.TLink l ON l.LinkedID = v.ValueID
    WHERE l.LinkedID = @ID
    
    IF @LinkOwnerID IS NOT NULL
    BEGIN
        EXEC dbo.Error
            @Message = N'На объект базы данных ID=%s cуществуют ссылка с объекта ID=%s типа ID=%s'
           ,@p0 = @ID
           ,@p1 = @LinkOwnerID
           ,@p2 = @LinkTypeID
    END
END
GO