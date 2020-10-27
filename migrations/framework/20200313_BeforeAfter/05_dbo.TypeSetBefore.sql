--liquibase formatted sql

--changeset vrafael:framework_20200313_BeforeAfter_05_dboTypeSetBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[TypeSetBefore]
    @ID bigint
   ,@TypeID bigint
   ,@OwnerID bigint
   ,@Name dbo.string OUTPUT
   ,@Tag dbo.string OUTPUT
   ,@Icon dbo.string OUTPUT
   ,@Abstract bit
   ,@ModuleID bigint OUTPUT
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE 
        @OwnerTypeID bigint = (SELECT TOP (1) o.TypeID FROM dbo.TObject o WHERE o.ID = @OwnerID)
       ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')

    SELECT
        @Abstract = ISNULL(@Abstract, 0)
       ,@Name = ISNULL(@Name, @Tag) 
       ,@Tag = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(@Tag, CHAR(10), N'_'), CHAR(13), N'_'), CHAR(9), N'_'), N' ', N'')))

    --проверка что тип объекта "Тип" является наследником типа его владельца (супертипа)
    IF (@OwnerID IS NOT NULL)
    BEGIN
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.DirectoryOwnersInline(@TypeID, N'Type', 1) pt
            WHERE pt.ID = @OwnerTypeID
        )
        BEGIN
            EXEC dbo.Error
                @Message = N'Тип ID=%s не является наследником типа ID=%s'
               ,@p0 = @TypeID
               ,@p1 = @OwnerTypeID;
        END
                
        --наследуем иконку, если не указана явно
        SELECT TOP (1)
            @Icon = ISNULL(@Icon, t.Icon)
           ,@ModuleID = ISNULL(@ModuleID, t.ModuleID)
        FROM dbo.TType t
        WHERE t.ID = @OwnerID
    END

    IF @ID IS NOT NULL
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM dbo.TObject o
                JOIN dbo.TDirectory d ON d.ID = o.ID
                JOIN dbo.TType t ON t.ID = o.ID
            WHERE o.ID = @ID
                AND o.StateID = @StateID_Basic_Formed
                AND
                (
                    ISNULL(o.TypeID, 0) <> ISNULL(@TypeID, 0)
                    OR ISNULL(o.OwnerID, 0) <> ISNULL(@OwnerID, 0)
                    OR ISNULL(d.[Tag], N'') <> ISNULL(@Tag, N'')
                )
        )
        BEGIN
            EXEC dbo.Error
                @Message = 'Тип ID=%s в состоянии ID=%s. ключевые поля (тип, владелец, код) разрешено изменять только в неактивном состоянии'
               ,@p0 = @ID
               ,@p1 = @StateID_Basic_Formed
        END
    END
END
GO