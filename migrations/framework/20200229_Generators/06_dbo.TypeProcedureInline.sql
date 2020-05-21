--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_06_dboTypeProcedureInline logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
--получение исполняемой процедуры по типу
CREATE OR ALTER FUNCTION [dbo].[TypeProcedureInline]
(
    @TypeID bigint
   ,@Operation dbo.string --Set/Get/Find/Del
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (1)
        NULL as ProcedureID --ToDo идентификатор процедуры
       ,CONCAT(N'[', ss.[name], N'].[', sp.[name], N']') as ProcedureName
       ,t.ID as OwnerTypeID
    FROM dbo.DirectoryOwnersInline(@TypeID, N'Type', 1) t
        JOIN dbo.TDirectory dt ON dt.ID = t.ID
        JOIN sys.procedures sp ON sp.name = CONCAT(dt.Tag, @Operation) --ToDo переделать на внешние ссылки с CASE = Operation
        JOIN sys.schemas ss ON ss.schema_id = sp.schema_id
            AND ss.name = N'dbo'
    ORDER BY t.Lvl
)
--SELECT * FROM dbo.TypeProcedureInline(3, N'Set')