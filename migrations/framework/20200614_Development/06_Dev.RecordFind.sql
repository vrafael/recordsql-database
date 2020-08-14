--liquibase formatted sql

--changeset vrafael:framework_20200614_Development_06_DevRecordFind logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [Dev].[RecordFind]
    @TypeTag dbo.string --=NULL
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
       ,@TypeID bigint = dbo.TypeIDByTag(@TypeTag)

    IF @TypeID IS NULL
    BEGIN
        IF @TypeTag IS NOT NULL
        BEGIN
            EXEC dbo.Error
                @TypeTag = N'SystemError'
               ,@Message = N'Не удалось определить тип по тегу "%s"'
               ,@p0 = @TypeTag
        END
        ELSE
        BEGIN
            EXEC dbo.Error
                @TypeTag = N'SystemError'
               ,@Message = N'Не указан тип записи'
        END
    END

    SELECT TOP (1)
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
      ,@TypeID = @TypeID
      ,@Find = @Find
END
--EXEC Dev.RecordFind @TypeTag = N'Error', @Find = '{"ErrorID" :{"ValueFrom": 500}}'
--EXEC Dev.RecordFind @TypeTag = N'Type', @Find = '{"Type" :{"Value": [3]}}'
GO
EXEC dbo.DatabaseObjectDescription
    @ObjectName = N'Dev.RecordFind'
   ,@Description = N'Поиск записей по типу с фильтрацией и пейджингом'