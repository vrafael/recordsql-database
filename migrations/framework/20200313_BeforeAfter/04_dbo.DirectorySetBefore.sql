--liquibase formatted sql

--changeset vrafael:framework_20200313_BeforeAfter_04_dboDirectorySetBefore logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[DirectorySetBefore]
    @ID bigint
   ,@TypeID bigint
   ,@Name dbo.string OUTPUT
   ,@Tag dbo.string
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE @pi int = 0

    SET @Name = NULLIF(LTRIM(RTRIM(@Name)), N'')

    IF (@Name IS NULL)
        AND(NULLIF(LTRIM(RTRIM(@Tag)), N'') IS NULL)
    BEGIN
        EXEC dbo.Error
            @Message = N'Нельзя добавлять объекты типа ID=%s в справочник без указания наименования или кода'
           ,@p0 = @TypeID
    END;

    --заполняем название из поля тег
    IF @Name IS NULL
    BEGIN
        SELECT
            @Name = @Tag
           ,@pi = PATINDEX('%[^a-zA-Z0-9 ]%', @Tag)

        WHILE (@pi > 0)
        BEGIN
            SELECT
                @Name = REPLACE(@Name, SUBSTRING(@Name, @pi, 1), N'')
               ,@pi = PATINDEX('%[^a-zA-Z0-9 ]%', @Name)
        END
    END

    --ToDo проверка на уникальность объекта по коду аналогично v1
END
GO