--liquibase formatted sql

--changeset vrafael:framework_20200313_BeforeAfter_03_dboObjectDelBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
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
        @LinkTypeID bigint
       ,@LinkOwnerID bigint
       ,@LinkCount int
       ,@LinkID bigint
       ,@ProcedureName dbo.string
   
    SELECT TOP (1)
        @LinkTypeID = l.TypeID
       ,@LinkOwnerID = l.OwnerID
    FROM dbo.TLink l
    WHERE l.TargetID = @ID

    IF @LinkOwnerID IS NOT NULL
    BEGIN
        SELECT @LinkCount = COUNT(l.TargetID)
        FROM dbo.TLink l
        WHERE l.TargetID = @ID

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
           ,l.ValueID
        FROM dbo.TLink l
            CROSS APPLY dbo.TypeProcedureInline(l.TypeID, N'Del') sp
        WHERE l.OwnerID = @ID
    
    OPEN cur_values
    FETCH NEXT FROM cur_values INTO 
        @ProcedureName
       ,@LinkID

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC @ProcedureName
            @LinkID = @LinkID
        
        FETCH NEXT FROM cur_values INTO 
            @ProcedureName
           ,@LinkID
    END
    
    CLOSE cur_values
    DEALLOCATE cur_values

    EXEC dbo.EventSet
        @TypeTag = N'EventDelete'
       ,@ObjectID = @ID
END
GO