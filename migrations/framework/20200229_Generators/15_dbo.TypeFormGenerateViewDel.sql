--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_15_dboTypeFormGenerateViewDel logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[TypeFormGenerateViewDel]
    @ID bigint
   ,@Print bit = 0
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @SchemaName dbo.string
       ,@TriggerName dbo.string
       ,@ViewName dbo.string
       ,@ProcedureDel dbo.string
       ,@Object_ID int
       ,@Object_ID_View int
       ,@Object_ID_Del int
       ,@Identifier dbo.string
       ,@Script nvarchar(max)
       ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
       ,@Tab tinyint = 4
       ,@FieldLinkToTypeTag dbo.string
       ,@FieldLinkToTypeColumn dbo.string

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
        @SchemaName = N'dbo'
       ,@TriggerName = CONCAT(N'V', d.[Tag], N'Del')
       ,@ViewName = CONCAT(N'V', d.[Tag])
       ,@ProcedureDel = CONCAT(d.[Tag], N'Del')
       ,@Object_ID = OBJECT_ID(CONCAT(N'[dbo].[V', d.[Tag], N'Del]'), N'TR')
       ,@Object_ID_View =  OBJECT_ID(CONCAT(N'[dbo].[V', d.[Tag], N']'), N'V')
       ,@Object_ID_Del = OBJECT_ID(CONCAT(N'[dbo].[', d.[Tag], N'Del]'), N'P')
    FROM dbo.TObject o
        JOIN dbo.TDirectory d ON d.ID = o.ID
        JOIN dbo.TType t ON t.ID = o.ID
    WHERE o.ID = @ID

    --если нет View и Del, то генерировать ViewDel не требуется
    IF @Object_ID_View IS NULL
        OR @Object_ID_Del IS NULL
    BEGIN
        RETURN 0
    END

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
    FROM dbo.FieldsByOwnerInline(@ID, 1) fs
    WHERE fs.StateID = @StateID_Basic_Formed
    ORDER BY
        fs.Lvl DESC
       ,fs.[Order]

    SELECT TOP (1)
        @Identifier = f.[Tag]
    FROM @Fields f
    WHERE f.TypeTag = N'FieldIdentifier'
    ORDER BY f.[Order]

    --находим поле ссылки на тип
    SELECT TOP (1)
        @FieldLinkToTypeTag = f.[Tag]
       ,@FieldLinkToTypeColumn = f.[Column]
    FROM @Fields f
    WHERE (f.TypeTag = N'FieldLinkToType')
    ORDER BY f.[Order]

    SELECT
        @Script = 
N'--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------'

    SELECT
        @Script +=
            CHAR(13) + CHAR(10)  
          + CASE
                WHEN @Object_ID IS NULL THEN N'CREATE'
                ELSE N'ALTER'
            END
          + CONCAT(N' TRIGGER [', @SchemaName, N'].[', @TriggerName, N'] ON [', @SchemaName, N'].[', @ViewName, N']') 

    SELECT
        @Script += N'
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @ProcedureDel dbo.string'

    SELECT
        @Script +=
            ISNULL
            (
                (
                    SELECT 
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2 - 1)
                      + CONCAT(N',@', f.[Tag], N' ', f.DataType)
                    FROM @Fields f
                    WHERE f.TypeTag = N'FieldIdentifier'
                    ORDER BY f.[Order]
                    FOR XML PATH(N'')
                )
               ,N''
            )

    SELECT
        @Script += N'

    DECLARE CUR CURSOR LOCAL STATIC FORWARD_ONLY FOR
        SELECT'

    IF @FieldLinkToTypeTag IS NOT NULL
    BEGIN
        SELECT
            @Script += CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 3)
                + CONCAT(N'ISNULL(p.[ProcedureName], N''[', @SchemaName, N'].[', @ProcedureDel, N']'')')
    END
    ELSE
    BEGIN
        SELECT
            @Script += CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 3)
                + CONCAT(N'''[', @SchemaName, N'].[', @ProcedureDel, N']''')
    END

    SELECT
        @Script +=
            ISNULL
            (
                (
                    SELECT 
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 3 - 1)
                      + CONCAT(N',del.[', f.[Tag], N']')
                    FROM @Fields f
                    WHERE f.TypeTag = N'FieldIdentifier'
                    ORDER BY f.[Order]
                    FOR XML PATH(N'')
                )
               ,N''
            )

    SELECT
        @Script += N'
        FROM deleted del'

    IF EXISTS(SELECT 1 FROM @Fields f WHERE f.[TypeTag] = N'FieldLinkToType')
    BEGIN
        SELECT
            @Script += N'
            OUTER APPLY dbo.TypeProcedureInline(del.[' + @FieldLinkToTypeColumn + N'], N''Del'') p'
    END

    SELECT
        @Script += N';

    OPEN CUR
    FETCH NEXT FROM CUR INTO
        @ProcedureDel'

    SELECT
        @Script +=
            ISNULL
            (
                (
                    SELECT
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2 - 1)
                      + CONCAT(N',@', f.[Tag])
                    FROM @Fields f
                    WHERE f.TypeTag = N'FieldIdentifier'
                    ORDER BY f.[Order]
                    FOR XML PATH(N'')
                )
               ,N''
            )

    SELECT
        @Script += N'

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC @ProcedureDel'

    SELECT
        @Script +=
            ISNULL
            (
                (
                    SELECT 
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 3 - 1)
                      + CASE ROW_NUMBER() OVER(ORDER BY f.[Order]) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                      + CONCAT(N'@', f.[Tag], N' = @', f.[Tag])
                    FROM @Fields f
                    WHERE f.TypeTag = N'FieldIdentifier'
                    ORDER BY f.[Order]
                    FOR XML PATH(N'')
                )
               ,N''
            )

    SELECT
        @Script += N'

        FETCH NEXT FROM CUR INTO
            @ProcedureDel'

    SELECT
        @Script +=
            ISNULL
            (
                (
                    SELECT 
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 3 - 1)
                      + CONCAT(N',@', f.[Tag])
                    FROM @Fields f
                    WHERE f.TypeTag = N'FieldIdentifier'
                    ORDER BY f.[Order]
                    FOR XML PATH(N'')
                )
               ,N''
            )

    SELECT
        @Script += N'
    END

    CLOSE CUR
    DEALLOCATE CUR
END
'

    SELECT
        @Script = REPLACE(REPLACE(REPLACE(@Script, N'&#x0D;', CHAR(13)), N'&lt;', N'<'), N'&gt;', N'>')

    IF @Print = 1
    BEGIN 
        WHILE LEN(@Script) > 0
        BEGIN
            PRINT IIF(CHARINDEX(NCHAR(13), @Script) > 0, SUBSTRING(@Script, 1, CHARINDEX(NCHAR(13), @Script) - 1), @Script)
            SET @Script = IIF(CHARINDEX(NCHAR(13), @Script) > 0, SUBSTRING(@Script, CHARINDEX(NCHAR(13), @Script) + 2, LEN(@Script) - CHARINDEX(NCHAR(13), @Script) + 1), '')
        END
    END
    ELSE
    BEGIN
        EXEC(@Script)
    END
END
--EXEC dbo.TypeFormGenerateViewDel @ID = 3, @Print = 1
GO