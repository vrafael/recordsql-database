--liquibase formatted sql

--changeset vrafael:framework_20200723_ContextProcedure_02_dboContextProcedureInline logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
-- Функция просмотра стека
CREATE OR ALTER FUNCTION [dbo].[ContextProcedureInline]
(
    @Context varbinary(max)
   ,@Nestlevel int
)
RETURNS TABLE
AS
RETURN
(
    WITH [Range] ([Number]) AS
    (
        SELECT CAST(1 as int) as [Number]
        UNION ALL
        SELECT r.Number + 1 as [Number]
        FROM [Range] r
        WHERE r.Number < 28
    )
    SELECT
        c.ProcID
       ,do.ID as ProcedureID
       ,OBJECT_SCHEMA_NAME(c.ProcID) as ProcedureSchema --ISNULL(ds.Tag, OBJECT_SCHEMA_NAME(c.ProcID)) as ProcedureSchema
       ,OBJECT_NAME(c.ProcID) as ProcedureName --ISNULL(d.Tag, OBJECT_NAME(c.ProcID)) as ProcedureName
       ,c.[ProcedureLevel]
    FROM
        (
            SELECT
                r.Number AS [ProcedureLevel]
               ,CONVERT(int, SUBSTRING(@Context, r.Number * 4 + 1 + 8 * 2, 4)) AS ProcID
            FROM [Range] r
            WHERE r.Number <= @Nestlevel
        ) c
        LEFT JOIN dbo.TDatabaseObject do
            ON do.[object_id] = c.ProcID
)