--liquibase formatted sql

--changeset vrafael:framework_20200313_BeforeAfter_01_dboObjectSetBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[ObjectSetBefore]
    @ID bigint OUTPUT
   ,@TypeID bigint
   ,@StateID bigint OUTPUT
   ,@OwnerID bigint
   ,@Name dbo.string OUTPUT
   ,@EventTypeID bigint = NULL OUTPUT --переменная для проброса в SetAfter процедуру типа события
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON
    
    DECLARE 
        @TypeID_Previous bigint
       ,@TypeStateID bigint
       ,@Abstract bit
       ,@OwnerID_Temp bigint

    --с клиента при создании новой записи может прийти отрицательное значение идентификатора
    SET @ID = IIF(@ID > 0, @ID, NULL)
    
    IF @TypeID IS NULL --ToDo изменить на проверку условия что поле Type является обязательным 
    BEGIN
        EXEC dbo.Error
            @Message = N'Не указан тип объекта'
    END

    SELECT
        @TypeStateID = o.StateID
       ,@Abstract = t.[Abstract]
    FROM dbo.TObject o
        JOIN dbo.TType t ON t.ID = o.ID
    WHERE o.ID = @TypeID;

    IF @@ROWCOUNT <> 1
    BEGIN
        EXEC dbo.Error
            @Message = N'Не найден тип ID=%s'
           ,@p0 = @TypeID;
    END;

    IF (@Abstract = 1)
    BEGIN
        EXEC dbo.Error
            @Message = N'Нельзя создавать объекты абстрактного типа ID=%s'
           ,@p0 = @TypeID;
    END;

    IF @TypeStateID IS NULL
    BEGIN
        EXEC dbo.Error
            @Message = N'Нельзя создавать объекты несформированного типа ID=%s'
           ,@p0 = @TypeID;
    END

    SELECT 
        @Name = NULLIF(RTRIM(LTRIM(@Name)), N'')
       ,@EventTypeID = IIF(@ID IS NULL, dbo.TypeIDByTag(N'EventInsert'), dbo.TypeIDByTag(N'EventUpdate'))

    IF @ID IS NULL
    BEGIN
        SET @StateID = NULL
    END
    ELSE
    BEGIN
        SELECT
            @TypeID_Previous = o.TypeID
           ,@StateID = o.StateID --состояние не изменяется в Set-процедурах, только в
        FROM dbo.TObject (NOLOCK) o
        WHERE o.ID = @ID

        IF @@ROWCOUNT = 0
        BEGIN
            EXEC dbo.Error
                @Message = 'Не найден объект с идентификатором ID=%s'
               ,@p1 = @ID
        END

        --изменение типа объекта
        IF @TypeID <> @TypeID_Previous
        BEGIN
            --ToDo рассмотреть возможность смены типа объекта в рамках супертипа аналогично v1 
            EXEC dbo.Error
                @TypeTag = N'SystemError'
               ,@Message = N'Запрещено изменять тип ID=%s на тип ID=%s объекта ID=%s'
               ,@p0 = @TypeID_Previous
               ,@p1 = @TypeID
               ,@p2 = @ID
        END
    END

    --защита от зацикливания по OwnerID
    IF @OwnerID IS NOT NULL
    BEGIN
        SET @OwnerID_Temp = @OwnerID

        WHILE @OwnerID_Temp IS NOT NULL
        BEGIN
            SELECT @OwnerID_Temp = o.OwnerID
            FROM dbo.TObject o
            WHERE o.ID = @OwnerID_Temp

            IF @@ROWCOUNT = 0
            BEGIN
                BREAK
            END

            IF @OwnerID_Temp = @OwnerID
            BEGIN
                EXEC dbo.Error
                    @Message = N'Обнаружено зацикливание в цепочке владельцев ID=%s объекта ID=%s'
                   ,@p0 = @OwnerID
                   ,@p1 = @ID
            END
        END
    END
END
GO