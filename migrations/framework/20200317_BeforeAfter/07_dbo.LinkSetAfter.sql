--liquibase formatted sql

--changeset vrafael:framework_20200317_BeforeAfter_07_dboValueSetAfter logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
--сортировка ссылок объекта в рамках типа и условия 
CREATE OR ALTER PROCEDURE [dbo].[LinkSetAfter]
    @TypeID bigint
   ,@OwnerID bigint
   ,@CaseID bigint
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;

    --устанавливаем порядок внешних ссылок в рамках объекта
    UPDATE l
    SET l.[Order] = lo.[Order]
    FROM 
        (
            SELECT
                lo.LinkID
               ,(ROW_NUMBER() OVER(ORDER BY ISNULL(NULLIF(lo.[Order], 0), 2147483646))) * 10 as [Order]
            FROM dbo.TLink lo
            WHERE lo.TypeID = @TypeID
                AND lo.OwnerID = @OwnerID
                AND (lo.CaseID = @CaseID
                    OR (@CaseID IS NULL AND lo.CaseID IS NULL))
        ) lo
        JOIN dbo.TLink l ON l.LinkID = lo.LinkID
END