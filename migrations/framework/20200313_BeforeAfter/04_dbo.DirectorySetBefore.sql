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

    SET @Name = NULLIF(LTRIM(RTRIM(@Name)), N'')

    IF (@Name IS NULL)
        AND(NULLIF(LTRIM(RTRIM(@Tag)), N'') IS NULL)
    BEGIN
        EXEC dbo.Error
            @Message = N'Нельзя добавлять объекты типа ID=%s в справочник без указания наименования или кода'
           ,@p0 = @TypeID
    END;

    --ToDo проверка на уникальность объекта по коду аналогично v1
END
GO