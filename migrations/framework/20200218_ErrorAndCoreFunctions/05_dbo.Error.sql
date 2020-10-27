--liquibase formatted sql

--changeset vrafael:framework_20200218_05_dboError logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
-- прерывание транзакции и возврат ошибки
CREATE OR ALTER PROCEDURE [dbo].[Error]
    @TypeTag dbo.string = N'Error'
   ,@Message nvarchar(max)
   ,@p0 dbo.string = NULL
   ,@p1 dbo.string = NULL
   ,@p2 dbo.string = NULL
   ,@p3 dbo.string = NULL
   ,@p4 dbo.string = NULL
   ,@p5 dbo.string = NULL
   ,@p6 dbo.string = NULL
   ,@p7 dbo.string = NULL
   ,@p8 dbo.string = NULL
   ,@p9 dbo.string = NULL
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @ProcedureID bigint
       ,@TypeID bigint = dbo.TypeIDByTag(@TypeTag)
       ,@pos int = 0
       ,@i int = 1
       ,@paramID bigint = null
       ,@param dbo.string = null
       ,@str dbo.string = null
       ,@Context varbinary(max) = CONTEXT_INFO()
       ,@Nestlevel int = @@NESTLEVEL
       ,@CallStack nvarchar(max)

    IF @TypeID IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не определен тип ошибки по имени "%s"'
           ,@p0 = @TypeTag;
    END

    -- предпоследняя процедура в стеке - в которой произошла ошибка
    SELECT TOP (1)
        @ProcedureID = cpl.ProcedureID
       --,@ProcedureName = CONCAT(QUOTENAME(cpl.ProcedureSchema), N'.', QUOTENAME(cpl.ProcedureName))
    FROM dbo.ContextProcedureInline(@Context, @Nestlevel) cpl
    WHERE cpl.ProcedureLevel = @Nestlevel - 1

	--заполняем стек вызова процедур
	SET @CallStack =
	(
        SELECT
            REPLICATE(N' ', cpl.ProcedureLevel - 1)
			+ CASE 
				WHEN cpl.ProcedureName IS NULL THEN N'script'
				WHEN cpl.ProcedureID IS NULL THEN CONCAT(cpl.ProcedureSchema, N'.', cpl.ProcedureName)
				ELSE CONCAT(N'[', cpl.ProcedureSchema, N'.', cpl.ProcedureName, N'|ID=', CAST(cpl.ProcedureID as nvarchar(32)), N']')
			  END
			+ CHAR(10) as 'data()'
        FROM dbo.ContextProcedureInline(@Context, @Nestlevel) cpl
        WHERE cpl.ProcedureLevel < @Nestlevel
        ORDER BY cpl.ProcedureLevel
        FOR XML PATH(N'')
    )

    SET @Message = NULLIF(LTRIM(RTRIM(@Message)), N'')

    ----------------------------
    SET @pos = CHARINDEX(N'%s', @Message, @pos)

    WHILE @pos > 0
    BEGIN
        IF @pos > 3
            AND @pos < LEN(@Message)
            AND (SUBSTRING(@Message, @pos - 3, 3) = N'ID=')
        BEGIN
            SET @param =
                CASE @i
                    WHEN 1 THEN @p0
                    WHEN 2 THEN @p1
                    WHEN 3 THEN @p2
                    WHEN 4 THEN @p3
                    WHEN 5 THEN @p4
                    WHEN 6 THEN @p5
                    WHEN 7 THEN @p6
                    WHEN 8 THEN @p7
                    WHEN 9 THEN @p8
                    WHEN 10 THEN @p9
                END

            SET @paramID = TRY_CAST(@param as bigint)

            IF @paramID IS NOT NULL
            BEGIN
                SET @str = CONCAT(N'[', ISNULL(dbo.ObjectNameByID(@paramID), CAST(@paramID as nvarchar(20))), N'|ID=%s]')
                SET @Message= STUFF(@Message, @pos - 3, 5, @str)
                SET @pos += LEN(@str)
            END
        END

        SELECT
            @pos = CHARINDEX(N'%s', @Message, @pos + 1)
           ,@i += 1
    END
    ----------------------------

    IF (@Message IS NOT NULL)
    BEGIN
        SET @Message =
            REPLACE
            (
                FORMATMESSAGE
                (
                    @Message
                   ,@p0
                   ,@p1
                   ,@p2
                   ,@p3
                   ,@p4
                   ,@p5
                   ,@p6
                   ,@p7
                   ,@p8
                   ,@p9
                )
               ,N'%'
               ,N'%%'
            )
    END;

    -- сохраняем ошибку
    EXEC dbo.ErrorSet
        @TypeID = @TypeID
       ,@ProcedureID = @ProcedureID
       ,@Message = @Message
       ,@Nestlevel = @Nestlevel
	   ,@CallStack = @CallStack
END