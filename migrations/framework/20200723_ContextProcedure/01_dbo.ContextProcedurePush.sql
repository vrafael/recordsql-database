--liquibase formatted sql

--changeset vrafael:framework_20200723_ContextProcedure_01_dboContextProcedurePush logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
-- Процедура, изменяющая контекст исполняемых процедур
CREATE OR ALTER PROCEDURE [dbo].[ContextProcedurePush]
    @ProcID int
AS
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON
    SET FMTONLY OFF

    DECLARE
        @position int = (@@NESTLEVEL - 1) * 4 + (8 * 2) -- позиция с учетом идентификатора пользователя в начале контекста (bigint)
       ,@Context varbinary(128) = ISNULL(CONTEXT_INFO(), CONVERT(varbinary(128), REPLICATE(CONVERT(binary(1), 0x00), 128))) -- читаем текущий контекст

    IF (@ProcID IS NULL)
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не задан @@PROCID исполняемой процедуры для записи в контекст'
    END

    IF @position + 4 <= 128 -- пишем процу если в контексте достаточно места
    BEGIN
        SET @Context = SUBSTRING(@Context, 1, @position) + CONVERT(binary(4), @ProcID) + SUBSTRING(@Context, @position + 5, 128) -- заменяем содержимое контекста текущей позиции
        SET CONTEXT_INFO @Context
    END
END