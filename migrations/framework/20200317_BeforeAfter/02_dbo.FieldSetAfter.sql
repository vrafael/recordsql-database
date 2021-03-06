--liquibase formatted sql

--changeset vrafael:framework_20200317_BeforeAfter_02_dboFieldSetAfter logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[FieldSetAfter]
    @OwnerID bigint
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    --обновляем порядок полей в рамках родителя
    UPDATE f
    SET f.[Order] = fs.[Order]
    FROM 
        (
            SELECT
                o.ID
               ,(ROW_NUMBER() OVER(ORDER BY ISNULL(NULLIF(f.[Order], 0), 2147483646), d.[Tag])) * 10 as [Order]
            FROM dbo.TObject o 
                JOIN dbo.TDirectory d ON d.ID = o.ID
                JOIN dbo.TField f ON f.ID = d.ID
            WHERE o.OwnerID = @OwnerID
        ) fs
        JOIN dbo.TField f ON f.ID = fs.ID
END
GO