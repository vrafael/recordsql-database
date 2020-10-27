--liquibase formatted sql

--changeset vrafael:framework_20201026_ScriptGenerator_01_dboObjectScript logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
--генератор скрипта объекта
CREATE OR ALTER PROCEDURE [dbo].[ObjectScript]
    @ID bigint
   ,@Script nvarchar(max) = N'' OUTPUT
   ,@FieldIdentifier dbo.string = NULL
   ,@Print bit = 0
   ,@TabStart tinyint = 0
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
       ,@ProcedureSet dbo.string
       ,@Tab tinyint = 4
       ,@TypeID bigint
       ,@TypeTag dbo.string
       ,@Tag dbo.string
       ,@ProcedureParams nvarchar(max)
       ,@DeclareParams nvarchar(max)
       ,@SQL nvarchar(max) = N'DROP TABLE IF EXISTS #objectvalues
'

    DECLARE
        @Fields TABLE --поля
        (
            [ID] bigint NOT NULL
           ,[OwnerID] bigint NOT NULL
           ,[OwnerTag] dbo.string NOT NULL
           ,[TypeID] bigint NOT NULL
           ,[TypeTag] dbo.string NOT NULL
           ,[Tag] dbo.string NOT NULL
           ,[Column] dbo.string NOT NULL
           ,[DataType] dbo.string NOT NULL
           ,[Order] bigint NOT NULL IDENTITY(1, 1)
        )

    SELECT
        @TypeID = o.TypeID
       ,@TypeTag = td.Tag
       ,@ProcedureSet = tpi.ProcedureName
       ,@Script = ISNULL(@Script, N'')
    FROM dbo.TObject o
        JOIN dbo.TDirectory td ON td.ID = o.TypeID
        CROSS APPLY dbo.TypeProcedureInline(o.TypeID, N'Set') tpi
    WHERE o.ID = @ID

    --заполняем таблицу с полями
    INSERT INTO @Fields
    (
        [ID]
       ,[OwnerID]
       ,[OwnerTag]
       ,[TypeID]
       ,[TypeTag]
       ,[Tag]
       ,[Column]
       ,[DataType]
    )
    SELECT 
        fs.[ID]
       ,fs.[OwnerID]
       ,fs.[OwnerTag]
       ,fs.[TypeID]
       ,fs.[TypeTag]
       ,fs.[Tag]
       ,fs.[Column]
       ,fs.[DataType]
    FROM dbo.FieldsByOwnerInline(@TypeID, 1) fs
    WHERE fs.StateID = @StateID_Basic_Formed
    ORDER BY
        fs.Lvl DESC
       ,fs.[Order]

    SELECT TOP (1)
        @SQL += CONCAT(N'SELECT v.* INTO #objectvalues FROM dbo.[V', fs.OwnerTag, N'] as v WHERE v.ID = ', @ID)
    FROM @Fields fs
    ORDER BY fs.[Order] DESC

    SELECT
        @SQL += N'
SELECT @DeclareParams = '

    SELECT
        @SQL +=
            (
                SELECT
                    CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab - 1)
                    + CASE ROW_NUMBER() OVER(ORDER BY fs.[Order]) WHEN 1 THEN N' ' ELSE N' + CHAR(13) + CHAR(10) + ' END --для первого параметра убираем запятую
                    + CONCAT(N'REPLICATE(N'' '', (', @TabStart, N' + 1) * ', @Tab, N' - 1) + ')
                    + CONCAT(
                        N'CONCAT(N'''
                       ,CASE ROW_NUMBER() OVER(ORDER BY fs.[Order]) WHEN 1 THEN N' ' ELSE N',' END
                       ,N'@', fs.[Column], N'_', @ID, N' bigint = '', '
                            ,CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2), N'IIF([', LOWER(fs.[Column]), N'_o].ID IS NULL, N''NULL'','
                                ,CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 3), N'IIF([', LOWER(fs.[Column]), N'_od].ID IS NULL, '
                                ,CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 4), N'CONCAT(N''dbo.DirectoryIDByTag(N'''''', [', LOWER(fs.[Column]), N'_td].[Tag], '''''', N'''''', [', LOWER(fs.[Column]), N'_d].[Tag], '''''')''),'
                                ,CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 4), N'CONCAT(N''dbo.DirectoryIDByOwner(N'''''', [', LOWER(fs.[Column]), N'_td].[Tag], '''''', N'''''', [', LOWER(fs.[Column]), N'_od].[Tag], '''''', N'''''', [', LOWER(fs.[Column]), N'_d].[Tag], '''''')''))))'
                    ) 
                FROM @Fields fs
                WHERE fs.TypeTag = N'FieldLink'
                ORDER BY fs.[Order]
                FOR XML PATH(N'')
            ) + N'
FROM #objectvalues as v'

    SELECT
        @SQL +=
            (
                SELECT
                    CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab - 1) + CONCAT(N'LEFT JOIN dbo.TObject [', LOWER(fs.[Column]), N'_o]')
                    + CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2 - 1) + CONCAT(N'JOIN dbo.TDirectory [', LOWER(fs.[Column]), N'_d] ON [', LOWER(fs.[Column]), N'_d].ID = [', LOWER(fs.[Column]), N'_o].ID')
                    + CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2 - 1) + CONCAT(N'LEFT JOIN dbo.TDirectory [', LOWER(fs.[Column]), N'_od] ON [', LOWER(fs.[Column]), N'_od].ID = [', LOWER(fs.[Column]), N'_o].OwnerID')
                    + CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2 - 1) + CONCAT(N'JOIN dbo.TDirectory [', LOWER(fs.[Column]), N'_td] ON [', LOWER(fs.[Column]), N'_td].ID = [', LOWER(fs.[Column]), N'_o].TypeID')
                    + CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab - 1) + CONCAT('ON [', LOWER(fs.[Column]), N'_o].ID = v.[', fs.[Column], ']')
                FROM @Fields fs
                WHERE fs.TypeTag = N'FieldLink'
                ORDER BY fs.[Order]
                FOR XML PATH(N'')
            )

    SELECT
        @SQL += N'
SELECT @ProcedureParams = '

    SELECT
        @SQL +=
            (
                SELECT
                    CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab - 1)
                    + CASE ROW_NUMBER() OVER(ORDER BY fs.[Order]) WHEN 1 THEN N' ' ELSE N' + CHAR(13) + CHAR(10) + ' END --для первого параметра убираем запятую
                    + CONCAT(N'REPLICATE(N'' '', (', @TabStart, N' + 1) * ', @Tab, N' - 1) + ')
                    + CONCAT(
                        N'CONCAT(N'''
                       ,IIF(ROW_NUMBER() OVER(ORDER BY fs.[Order]) = 1, N' ', N',')
                       ,IIF(fs.TypeTag = N'FieldLinkToType', '@TypeTag', CONCAT(N'@', fs.[Column]))
                       ,N' = '', IIF(', N'v.[', fs.[Column], N'] IS NULL' ,N', N''NULL'', '
                            ,CASE
                                WHEN fs.TypeTag = N'FieldIdentifier' AND @FieldIdentifier IS NOT NULL THEN N'@FieldIdentifier'
                                WHEN fs.TypeTag = N'FieldLinkToType' THEN CONCAT(N'N''N''''', @TypeTag, N'''''''')
                                WHEN fs.TypeTag = N'FieldLink' THEN CONCAT(N'N''@', fs.[Column], N'_', @ID, N'''')
                                WHEN fs.TypeTag IN (N'FieldString', N'FieldText', N'FieldColor') THEN CONCAT(N'CONCAT(''N'''''', REPLACE(v.[', fs.[Column], N'], N'''''''', N''''''''''''), N'''''''')')                 --CONCAT('N''', REPLACE(v.[Name], N'''', N''''''), N'''') => @Tag = N'SessionDel'
                                WHEN fs.TypeTag IN (N'FieldDate', N'FieldTime', N'FieldDatetime') THEN CONCAT(N'CONCAT(''N'''''', CAST(v.[', fs.[Column], N'] as nvarchar(max)), N'''''''')')
                                ELSE CONCAT(N'CAST(v.[', fs.[Column], N'] as nvarchar(max))')
                            END
                       ,N'))'
                    ) 
                FROM @Fields fs
                ORDER BY fs.[Order]
                FOR XML PATH(N'')
            ) + N'
FROM #objectvalues as v'

    SELECT
        @SQL = REPLACE(REPLACE(REPLACE(@SQL, N'&#x0D;', CHAR(13)), N'&lt;', N'<'), N'&gt;', N'>')

    EXEC sp_executesql 
        @SQL
       ,N'@ProcedureParams nvarchar(max) OUTPUT, @DeclareParams nvarchar(max) OUTPUT, @FieldIdentifier dbo.string'
       ,@ProcedureParams = @ProcedureParams OUTPUT
       ,@DeclareParams = @DeclareParams OUTPUT
       ,@FieldIdentifier = @FieldIdentifier

    SELECT
        @SQL = CONCAT(REPLICATE(N' ', @TabStart * @Tab), N'DECLARE', CHAR(13), CHAR(10), @DeclareParams, CHAR(13), CHAR(10), CHAR(13), CHAR(10))
        + CONCAT(REPLICATE(N' ', @TabStart * @Tab), N'EXEC ', @ProcedureSet, CHAR(13), CHAR(10), @ProcedureParams)

    SELECT 
        @Script += @SQL

    IF @Print = 1
    BEGIN 
        WHILE LEN(@SQL) > 0
        BEGIN
            PRINT IIF(CHARINDEX(NCHAR(13), @SQL) > 0, SUBSTRING(@SQL, 1, CHARINDEX(NCHAR(13), @SQL) - 1), @SQL)
            SET @SQL = IIF(CHARINDEX(NCHAR(13), @SQL) > 0, SUBSTRING(@SQL, CHARINDEX(NCHAR(13), @SQL) + 2, LEN(@SQL) - CHARINDEX(NCHAR(13), @SQL) + 1), N'')
        END
    END
END
--EXEC [dbo].[ObjectScript] @ID = 1, @Print = 1, @TabStart = 0, @FieldIdentifier = N'@TypeID_Test OUTPUT'