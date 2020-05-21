--liquibase formatted sql

--changeset vrafael:framework_20200317_BeforeAfter_07_dboValueSetAfter logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
--сортировка ссылок объекта в рамках типа и условия 
CREATE OR ALTER PROCEDURE [dbo].[ValueSetAfter]
    @TypeID bigint
   ,@OwnerID bigint
   ,@CaseID bigint
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;

    --устанавливаем порядок внешних ссылок в рамках объекта
    UPDATE v
    SET v.[Order] = vo.[Order]
    FROM 
        (
            SELECT
                vo.ValueID
               ,(ROW_NUMBER() OVER(ORDER BY ISNULL(NULLIF(vo.[Order], 0), 2147483646))) * 10 as [Order]
            FROM dbo.TValue vo
            WHERE vo.TypeID = @TypeID
                AND vo.OwnerID = @OwnerID
                AND (vo.CaseID = @CaseID
                    OR (@CaseID IS NULL AND vo.CaseID IS NULL))
        ) vo
        JOIN dbo.TValue v ON v.ValueID = vo.ValueID
END