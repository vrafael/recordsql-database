--liquibase formatted sql

--changeset vrafael:framework_20200317_BeforeAfter_01_dboFieldSetBefore logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[FieldSetBefore]
    @ID bigint OUTPUT
   ,@TypeID bigint
   ,@OwnerID bigint
   ,@Name dbo.string OUTPUT
   ,@Tag dbo.string
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE 
        @ExistFieldID bigint
       ,@ExistsFieldOwnerID bigint
       ,@StateID bigint
       ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')

    SELECT
        @ID = IIF(@ID > 0, @ID, NULL) 
       ,@Name = ISNULL(@Name, @Tag)

    IF @OwnerID IS NULL
    BEGIN
        EXEC dbo.Error
            @Message = N'Нельзя создавать поле типа ID=%s без указания владельца'
           ,@p0 = @TypeID
    END

    IF NULLIF(LTRIM(RTRIM(@Tag)), N'') IS NULL
    BEGIN
        EXEC dbo.Error
            @Message = N'Нельзя создавать поле типа ID=%s без указания кода справочника'
           ,@p0 = @TypeID
    END

    IF EXISTS
    (
        SELECT 1
        FROM dbo.TObject o
        WHERE (o.ID = @ID)
            AND (o.OwnerID <> @OwnerID)
    )
    BEGIN
        EXEC dbo.Error
            @Message = N'Нельзя изменять владельца поля ID=%s на ID=%s'
           ,@p0 = @ID
           ,@p1 = @OwnerID
    END

    --проверка уникальности кода атрибута в рамках владельцев и наследников
    SELECT TOP (1)
        @ExistFieldID = f.ID
       ,@ExistsFieldOwnerID = o.OwnerID
    FROM 
        (
            SELECT --родители текущего типа
                ot.ID
               ,- ot.Lvl - 1 as Lvl
            FROM dbo.DirectoryOwnersInline(@ID, N'Type', 1) ot 
            UNION ALL
            SELECT --наследнки текущего типа
                ct.ID
               ,ct.Lvl as Lvl
            FROM dbo.DirectoryChildrenInline(@ID, N'Type', 0) ct 
        ) oi
        JOIN dbo.TObject o ON o.OwnerID = oi.ID
        JOIN dbo.TDirectory d ON d.ID = o.ID
        JOIN dbo.TField f ON f.ID = d.ID
    WHERE (@ID IS NULL OR d.ID = @ID)
        AND(d.[Tag] = @Tag)
    ORDER BY oi.Lvl

    IF @ExistFieldID IS NOT NULL
    BEGIN
        EXEC dbo.Error
            @Message = N'В цепочке наследования уже существует поле ID=%s владельца ID=%s с именем "%s"'
           ,@p0 = @ExistFieldID
           ,@p1 = @ExistsFieldOwnerID
           ,@p2 = @Tag
    END

    --запрет на изменение ключевых параметров сформированного атрибута
    IF EXISTS (SELECT 1 FROM dbo.TObject o WHERE o.ID = @ID AND o.StateID = @StateID_Basic_Formed)
        AND EXISTS
        (
            SELECT 1
            FROM dbo.TObject o
                JOIN dbo.TDirectory d ON d.ID = o.ID
                JOIN dbo.TField f ON f.ID = d.ID
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
            @Message = N'Нельзя изменять параметры (тип, владелец, имя) сформированного поля ID=%s владельца ID=%s'
           ,@p0 = @ID
           ,@p1 = @OwnerID
    END
END
GO