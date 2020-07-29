--liquibase formatted sql

--changeset vrafael:framework_20200321_BeforeAfter_StateMachine_04_dboTransitionSetBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[TransitionSetBefore]
    @ID bigint
   ,@Name dbo.string
   ,@OwnerID bigint
   ,@SourceStateID bigint
   ,@TargetStateID bigint
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @SourceStateOwnerID bigint
       ,@TargetStateOwnerID bigint
       --,@ExistTransitionID bigint
       ,@CurrentSourceStateID bigint
       ,@CurrentTargetStateID bigint

    IF @SourceStateID IS NOT NULL
    BEGIN
        SELECT TOP (1)
            @SourceStateOwnerID = ssd.OwnerID
        FROM dbo.TDirectory ssd
        WHERE ssd.ID = @SourceStateID
    END

    IF @TargetStateID IS NOT NULL
    BEGIN
        SELECT TOP (1)
            @TargetStateOwnerID = tsd.OwnerID
        FROM dbo.TDirectory tsd
        WHERE tsd.ID = @TargetStateID
    END

    SET @OwnerID = COALESCE(@OwnerID, @SourceStateOwnerID, @TargetStateOwnerID)

    IF @OwnerID IS NULL
    BEGIN
        EXEC dbo.Error
            @Message = N'Нельзя создать переход "%s" (%s -> %s) без указания конечного автомата'
           ,@p0 = @Name 
           ,@p1 = @SourceStateID
           ,@p2 = @TargetStateID
    END
    ELSE IF @SourceStateID IS NOT NULL
        AND @OwnerID <> @SourceStateOwnerID
    BEGIN
        EXEC dbo.Error
            @Message = N'Владелец перехода "%s" (%s -> %s) и начального состояния ID=%s должен совпадать'
           ,@p0 = @Name
           ,@p1 = @SourceStateID
           ,@p2 = @TargetStateID
           ,@p3 = @SourceStateOwnerID
    END
    ELSE IF @TargetStateID IS NOT NULL
        AND @OwnerID <> @TargetStateOwnerID
    BEGIN
        EXEC dbo.Error
            @Message = N'Владелец перехода "%s" (%s -> %s) и конечного состояния ID=%s должен совпадать'
           ,@p0 = @Name
           ,@p1 = @SourceStateID
           ,@p2 = @TargetStateID
           ,@p3 = @TargetStateOwnerID
    END

    /*--закомментировано для возможности создавать переходы с одинаковыми именами
    SELECT TOP (1)
        @ExistTransitionID = o.ID
    FROM dbo.DirectoryChildrenInline(dbo.TypeIDByName('Transition'), N'Type', 1) ct
        JOIN dbo.TObject o ON o.TypeID = ct.ID
        JOIN dbo.TDirectory d ON d.ID = o.ID
    WHERE (d.OwnerID = @OwnerID)
        AND (d.[Tag] = @Tag)
        AND (@ID IS NULL OR o.ID <> @ID)

    IF @ExistTransitionID IS NOT NULL
    BEGIN
        EXEC dbo.Error
            @Message = N'На конечном автомате ID=%s уже существует переход ID=%s с именем "%s"'
           ,@p0 = @OwnerID
           ,@p1 = @ExistTransitionID 
           ,@p2 = @Name
    END*/

    --запрет на изменение перехода -- для этого запрета надо разрешить дублирование имен переходов на схеме состояний
    IF @ID IS NOT NULL
    BEGIN
        SELECT
            @CurrentSourceStateID = t.SourceStateID
           ,@CurrentTargetStateID = t.TargetStateID
        FROM dbo.TTransition t
        WHERE t.ID = @ID

        IF ISNULL(@SourceStateID, 0) <> ISNULL(@CurrentSourceStateID, 0)
            OR ISNULL(@TargetStateID, 0) <> ISNULL(@CurrentTargetStateID, 0)
        BEGIN
            EXEC dbo.Error
                @Message = N'Запрещено изменение начального и конечного состояния перехода ID=%s. Создайте новый переход'
               ,@p1 = @ID
        END
    END
    
END
GO