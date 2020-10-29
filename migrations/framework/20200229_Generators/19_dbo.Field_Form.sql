--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_19_dboFieldForm logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[FieldForm]
    @ID bigint
   ,@TransitionID bigint = NULL
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE 
        @FieldOwnerID bigint
       ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
       ,@TypeID bigint

    SELECT
        @FieldOwnerID = o.OwnerID
    FROM dbo.TObject o 
    WHERE o.ID = @ID

    --переформировываем владельца поля и его дочерние типы
    IF (dbo.ObjectStateTag(@FieldOwnerID) = N'Formed')
    BEGIN
        DECLARE cur CURSOR LOCAL STATIC FORWARD_ONLY FOR
            SELECT ct.ID
            FROM dbo.DirectoryChildrenInline(@FieldOwnerID, N'Type', 1) ct
                JOIN dbo.TObject ot ON ot.ID = ct.ID
            WHERE ot.StateID = @StateID_Basic_Formed
            ORDER BY ct.Lvl

        OPEN cur

        --расформировывается владелец и его дочерние типы
        EXEC dbo.ObjectStatePush
            @ID = @FieldOwnerID

        --формируем типы начиная с верхнего уровня
        FETCH NEXT FROM cur INTO @TypeID
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.ObjectStatePush
                @ID = @TypeID
               ,@StateID = @StateID_Basic_Formed

            FETCH NEXT FROM cur INTO @TypeID
        END
        
        CLOSE cur
        DEALLOCATE cur
    END
END
--EXEC dbo.FieldForm