--liquibase formatted sql

--changeset vrafael:framework_20200313_BeforeAfter_03_dboObjectDelBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[ObjectDelBefore]
    @ID bigint
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @LinkTypeID bigint
       ,@LinkOwnerID bigint
       ,@LinkCount int
       ,@ValueID bigint
       ,@ProcedureName dbo.string
   
    SELECT TOP (1)
        @LinkTypeID = v.TypeID
       ,@LinkOwnerID = v.OwnerID
    FROM dbo.TLink l
        JOIN dbo.TValue v ON v.ValueID = l.ValueID
    WHERE l.LinkedID = @ID

    IF @LinkOwnerID IS NOT NULL
    BEGIN
        SELECT @LinkCount = COUNT(l.LinkedID)
        FROM dbo.TLink l
        WHERE l.LinkedID = @ID

        EXEC dbo.Error
            @Message = N'Нельзя удалить объект ID=%s, т.к. на него есть ссылка типа ID=%s объекта ID=%s. Общее количество ссылок на объект: %s'
           ,@p0 = @ID
           ,@p1 = @LinkTypeID
           ,@p2 = @LinkOwnerID
           ,@p3 = @LinkCount
    END

    DECLARE cur_values CURSOR LOCAL STATIC FORWARD_ONLY FOR
        SELECT
            sp.ProcedureName
           ,v.ValueID
        FROM dbo.TValue v
            CROSS APPLY dbo.TypeProcedureInline(v.TypeID, N'Del') sp
        WHERE v.OwnerID = @ID
    
    OPEN cur_values
    FETCH NEXT FROM cur_values INTO 
        @ProcedureName
       ,@ValueID

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC @ProcedureName
            @ValueID = @ValueID
        
        FETCH NEXT FROM cur_values INTO 
            @ProcedureName
           ,@ValueID
    END
    
    CLOSE cur_values
    DEALLOCATE cur_values

    EXEC dbo.EventSet
        @TypeTag = N'EventDelete'
       ,@ObjectID = @ID
END
GO