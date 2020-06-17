--liquibase formatted sql

--changeset vrafael:framework_20200614_Development_06_DevRecordFind logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [Dev].[RecordFind]
    @TypeID bigint
   ,@Find nvarchar(max) = NULL
   ,@PageSize int = NULL
   ,@PageNumber int = NULL
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @ProcedureName dbo.string

    IF @TypeID IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не удалось определить тип объекта'
    END

    SELECT
        @ProcedureName = tpi.ProcedureName
    FROM dbo.TypeProcedureInline(@TypeID, N'Find') tpi

    IF @ProcedureName IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не удалось определить процедуру Find типа ID=%s'
           ,@p0 = @TypeID
    END

    EXEC @ProcedureName
       @PageSize = @PageSize
      ,@PageNumber = @PageNumber
      ,@Find = @Find
END
--EXEC Dev.RecordFind @TypeID = 8
GO
EXEC dbo.DatabaseObjectDescription
    @ObjectName = N'Dev.RecordFind'
   ,@Description = N'Поиск записей по типу с фильтрацией и пейджингом'