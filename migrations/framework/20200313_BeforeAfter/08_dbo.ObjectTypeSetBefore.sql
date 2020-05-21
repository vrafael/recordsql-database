--liquibase formatted sql

--changeset vrafael:framework_20200313_BeforeAfter_08_dboObjectTypeSetBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[ObjectTypeSetBefore]
    @ID bigint
   ,@Abstract bit
   ,@StateMachineID bigint OUTPUT
   ,@OwnerID bigint
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
       ,@Count int
       ,@TypeID_Object bigint = dbo.TypeIDByTag(N'Object')

    IF ISNULL(@Abstract, 0) = 1
        AND EXISTS
        (
            SELECT 1
            FROM dbo.TObject o
            WHERE o.TypeID = @ID
        )
    BEGIN
        EXEC dbo.Error
            @Message = N'Запрещено делать абстрактным тип ID=%s, т.к. существуют объекты этого типа'
           ,@p0 = @ID
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.DirectoryOwnersInline(@OwnerID, N'Type', 1) ot
        WHERE ot.ID = @TypeID_Object
    )
    BEGIN
        EXEC dbo.Error
            @Message = N'Тип объекта должен быть наследником типа ID=%s'
           ,@p0 = @TypeID_Object
    END

    --запрет на изменение схемы состояний активного типа
    IF EXISTS
    (
        SELECT 1
        FROM dbo.TObject o
            JOIN dbo.TObjectType ot ON ot.ID = o.ID
        WHERE o.ID = @ID
            AND ISNULL(ot.StateMachineID, 0) <> ISNULL(@StateMachineID, 0)
    )
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM dbo.TObject o
            WHERE o.ID = @ID
                AND o.StateID = @StateID_Basic_Formed
        )
        BEGIN
            EXEC dbo.Error
                @Message = N'Схему состояний типа объекта ID=%s разрешено изменять только в неактивном состоянии'
               ,@p0 = @ID
        END

        --ToDo рассмотреть возможно изменения схемы состояний на объектах
        SELECT
            @Count = COUNT(1)
        FROM dbo.TObject o
        WHERE o.TypeID = @ID
            AND o.StateID IS NOT NULL

        IF @Count > 0
        BEGIN
            EXEC dbo.Error
                @Message = N'Не удалось изменить схему состояний типа объектов ID=%s на ID=%s поскольку обнаружено %s объектов с непустым состоянием'
               ,@p0 = @ID
               ,@p1 = @StateMachineID
               ,@p2 = @Count
        END
    END

    --наследуем схему состояний и тип заголовка, если не указаны
    IF @StateMachineID IS NULL
    BEGIN
        SELECT
            @StateMachineID = ot.StateMachineID
        FROM dbo.TObjectType ot
        WHERE ot.ID = @OwnerID
    END
END
GO