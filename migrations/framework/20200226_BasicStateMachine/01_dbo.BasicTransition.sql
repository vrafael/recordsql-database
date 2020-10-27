--liquibase formatted sql

--changeset vrafael:framework_20200226_01_dboBasicTransition logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
--Процедура на базовой схеме состояний, которая вызывает процедуры привязанные к типам объектов ссылками с условием указывающим на тип объекта
CREATE OR ALTER PROCEDURE [dbo].[BasicTransition]
    @ID bigint = NULL
   ,@TransitionID bigint = NULL
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @ProcedureName dbo.string
       ,@TypeID_LinkToStoredProcedureOnTransition bigint = dbo.TypeIDByTag(N'LinkToStoredProcedureOnTransition')
       ,@Message nvarchar(4000)
    
    DECLARE cur CURSOR LOCAL STATIC FORWARD_ONLY FOR
        SELECT 
            CONCAT(QUOTENAME(ds.[Tag]), N'.', QUOTENAME(dp.[Tag])) as ProcedureName
        FROM dbo.TObject o
            CROSS APPLY dbo.DirectoryOwnersInline(o.TypeID, N'Type', 1) t
            JOIN dbo.TLink l ON l.TypeID = @TypeID_LinkToStoredProcedureOnTransition
                AND l.OwnerID = @TransitionID
                AND l.CaseID = t.ID
            JOIN dbo.TDirectory dp
                JOIN dbo.TObject op ON op.ID = dp.ID
                JOIN dbo.TDirectory ds ON ds.ID = op.OwnerID
            ON dp.ID = l.TargetID
        WHERE o.ID = @ID
        --ToDo добавить проверку что процедура сформирована!?
        ORDER BY 
            t.Lvl DESC
           ,l.[Order]
    
    OPEN cur
    FETCH NEXT FROM CUR INTO @ProcedureName
        
    BEGIN TRAN

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC @ProcedureName
            @ID = @ID
           ,@TransitionID = @TransitionID

        IF @@ERROR <> 0
        BEGIN
            SET @Message = ERROR_MESSAGE()
            
            EXEC dbo.Error
                @Message = N'Сбой при формировании объекта ID=%s при вызове процедуры "%s". Сообщение об ошибке: "%s"'
               ,@p1 = @ID
               ,@p2 = @ProcedureName
               ,@p3 = @Message
        END

        FETCH NEXT FROM CUR INTO @ProcedureName
    END

    COMMIT
    
    CLOSE cur
    DEALLOCATE cur
END