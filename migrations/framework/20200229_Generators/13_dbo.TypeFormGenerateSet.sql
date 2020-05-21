--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_13_dboTypeFormGenerateSet logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[TypeFormGenerateSet]
    @ID bigint
   ,@Print bit = 0
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed') 
       ,@SchemaName dbo.string
       ,@Identifier dbo.string
       ,@IdentifierOwner dbo.string
       ,@Script nvarchar(max)
       ,@ProcedureName dbo.string
       ,@TypeTag dbo.string
       ,@Object_ID int
       ,@Tab tinyint = 4
       ,@FieldLinkToTypeTag dbo.string
       ,@FieldLinkToTypeColumn dbo.string
       ,@CursorProcedureOwnerTag dbo.string
       ,@CursorProcedureName dbo.string
       ,@CursorProcedureObject_ID int
       ,@TypeID_FieldLink bigint = dbo.TypeIDByTag(N'FieldLink')
       ,@CursorMergeOwnerID bigint
       ,@CursorMergeOwnerTag dbo.string

    DECLARE
        @Templates TABLE --шаблоны полей
        (
            [Type] dbo.string NOT NULL
           ,FieldType dbo.string NOT NULL
           ,Template dbo.string NOT NULL
           ,[Order] bigint NOT NULL IDENTITY(1, 1)          
        )

    DECLARE
        @Procedures TABLE
        (   
            OwnerID bigint
           ,ProcedureName dbo.string  NOT NULL
           ,[Object_ID] int NOT NULL
           ,[IsAfter] bit NOT NULL
           ,[Order] int NOT NULL IDENTITY(1, 1)
        )

    DECLARE
        @Declarations TABLE
        (
            Variable dbo.string NOT NULL
           ,[Order] int NOT NULL IDENTITY(1, 1)
        )

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

    SELECT
        @SchemaName = N'dbo'
       ,@ProcedureName = CONCAT(d.[Tag], N'Set')
       ,@TypeTag = d.Tag
       ,@Object_ID = OBJECT_ID(CONCAT(N'[dbo].[', d.[Tag], N'Set]'), N'P')
    FROM dbo.TObject o
        JOIN dbo.TDirectory d ON d.ID = o.ID
        JOIN dbo.TType t ON t.ID = o.ID
    WHERE o.ID = @ID

    --находим тип владелец идентификатора
    SELECT TOP (1)
        @Identifier = f.[Column]
       ,@IdentifierOwner = f.OwnerTag
    FROM @Fields f
    WHERE (f.TypeTag = N'FieldIdentifier')
    ORDER BY f.[Order];

    --находим поле ссылки на тип
    SELECT TOP (1)
        @FieldLinkToTypeTag = f.[Tag]
       ,@FieldLinkToTypeColumn = f.[Column]
    FROM @Fields f
    WHERE (f.TypeTag = N'FieldLinkToType')
    ORDER BY f.[Order]

    INSERT INTO @Templates
        ([Type],FieldType,Template)
    VALUES
        (N'Parameter', N'FieldIdentifier', N'@<Column> <DataType> = NULL OUTPUT')
       ,(N'Parameter', N'FieldLink', N'@<Column> <DataType> = NULL')
       ,(N'Parameter', N'FieldLinkToType', N'@<Column> <DataType> = NULL')
       ,(N'Parameter', N'FieldLinkToType', N'@<Tag>Tag dbo.string = NULL')
       ,(N'Parameter', N'FieldString', N'@<Tag> <DataType> = NULL')
       ,(N'Parameter', N'FieldText', N'@<Tag> <DataType> = NULL')
       ,(N'Parameter', N'FieldBit', N'@<Column> tinyint = NULL')
       ,(N'Parameter', N'FieldInt', N'@<Column> <DataType> = NULL')
       ,(N'Parameter', N'FieldBigint', N'@<Column> <DataType> = NULL')
       ,(N'Parameter', N'FieldMoney', N'@<Column> <DataType> = NULL')
       ,(N'Parameter', N'FieldFloat', N'@<Column> <DataType> = NULL')
       ,(N'Parameter', N'FieldDatetime', N'@<Column> <DataType> = NULL')
       ,(N'Parameter', N'FieldUniqueidentifier', N'@<Column> <DataType> = NULL')
       ,(N'Parameter', N'FieldColor', N'@<Column> <DataType> = NULL')
       ,(N'Parameter', N'FieldTime', N'@<Column> <DataType> = NULL')
       ,(N'Parameter', N'FieldVarbinary', N'@<Column> <DataType> = NULL')
       ,(N'Parameter', N'FieldDate', N'@<Column> <DataType> = NULL');

    WITH Sources AS 
    (
        SELECT
            ot.ID
           ,ot.Lvl
        FROM dbo.DirectoryOwnersInline(@ID, N'Type', 1) ot
    )
    INSERT INTO @Procedures
    (
        OwnerID
       ,ProcedureName
       ,[Object_ID]
       ,IsAfter
    )
    SELECT
        p.OwnerID
       ,p.ProcedureName
       ,p.[Object_ID]
       ,p.IsAfter
    FROM
        (    
            SELECT
                pt.OwnerID
               ,pt.ProcedureName
               ,pt.IsAfter
               ,pt.Lvl
               ,OBJECT_ID(pt.ProcedureName, 'P') as [Object_ID]
            FROM 
                (
                    SELECT
                        td.ID as OwnerID
                       ,CONCAT(N'[dbo].[', td.Tag, N'SetBefore]') as [ProcedureName]
                       ,0 AS IsAfter
                       ,ot.Lvl
                    FROM Sources ot
                        JOIN dbo.TDirectory td ON td.ID = ot.ID
                    UNION ALL
                    SELECT
                        td.ID as OwnerID
                       ,CONCAT(N'[dbo].[', td.Tag, N'SetAfter]') as [ProcedureName]
                       ,1 AS IsAfter
                       ,ot.Lvl
                    FROM Sources ot
                        JOIN dbo.TDirectory td ON td.ID = ot.ID
                ) pt
        ) p
    WHERE p.[Object_ID] IS NOT NULL
    ORDER BY p.Lvl

    --если нет атрибутов типа и SetBefore/SetAfter процедуры, то генерировать Set не требуется
    IF NOT EXISTS(SELECT 1 FROM @Fields f WHERE f.OwnerID = @ID)
        AND NOT EXISTS(SELECT 1 FROM @Procedures p WHERE p.OwnerID = @ID)
    BEGIN
        --если есть процедура - удаляем ее
        IF @Object_ID IS NOT NULL
        BEGIN
            EXEC(N'DROP PROCEDURE [' + @SchemaName + N'].[' + @ProcedureName + N']')
        END

        RETURN 0
    END

    INSERT INTO @Declarations
        (Variable)
    SELECT
        CONCAT(N'@TypeID dbo.[link] = ', CAST(@ID as nvarchar(32)), N' --', @TypeTag) as Variable
    WHERE @FieldLinkToTypeTag IS NULL
    UNION ALL
    SELECT
        N'@Inserted dbo.[list]' as Variable
    UNION ALL
    SELECT 
        N'@FieldLinks dbo.[listKeyValue]' as Variable
    WHERE EXISTS(SELECT 1 FROM dbo.DirectoryChildrenInline(@TypeID_FieldLink, N'Type', 1) tc JOIN @Fields f ON f.TypeID = tc.ID)
    UNION ALL
    --добавляем переменные которых нет среди полей для передачи информации из процедуры Before в процедуру After
    SELECT 
        CONCAT(sp.name, N' ', 
            IIF(
                ss.name = N'sys' --COLLATE SQL_Latin1_General_CP1_CI_AS
               ,N''
               , ss.name + N'.'
            ), st.name) as Variable
    FROM @Procedures p
        JOIN sys.parameters sp ON sp.object_id = p.[Object_ID]
        JOIN sys.types st on st.user_type_id = sp.user_type_id
        JOIN sys.schemas ss on ss.schema_id = st.schema_id
    WHERE NOT EXISTS
        (
            SELECT 1
            FROM @Fields f
            WHERE sp.name = CONCAT(N'@', f.[Column])--COLLATE SQL_Latin1_General_CP1_CI_AS = sp.name
        )
        AND (@FieldLinkToTypeTag IS NOT NULL 
            OR sp.name <> N'TypeID')
    GROUP BY
        ss.name
       ,sp.name
       ,st.name

    SELECT
        @Script = 
N'--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------'

    SELECT
        @Script +=
            CHAR(13) + CHAR(10)  
          + CASE
                WHEN @Object_ID IS NULL THEN N'CREATE'
                ELSE N'ALTER'
            END
          + CONCAT(N' PROCEDURE [', @SchemaName, N'].[', @ProcedureName, N']');
          
    SELECT
        @Script +=
            ISNULL
            (
                (
                    SELECT 
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab - 1)
                      + CASE ROW_NUMBER() OVER(ORDER BY f.[Order]) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                      + REPLACE
                        (
                            REPLACE
                            (
                                REPLACE
                                (
                                    f.Template
                                   ,N'<Tag>'
                                   ,f.Tag
                                )
                               ,N'<Column>'
                               ,f.[Column]
                            )
                           ,N'<DataType>'
                           ,f.DataType
                        )
                    FROM 
                        (
                            SELECT
                                p.Template
                               ,f.Tag
                               ,f.[Column]
                               ,f.DataType
                               ,f.[Order]
                            FROM @Fields f
                                JOIN dbo.TDirectory td ON td.ID = f.TypeID
                                JOIN @Templates p ON p.FieldType = td.Tag
                                    AND p.[Type] = N'Parameter'
                        ) f
                    ORDER BY f.[Order]
                    FOR XML PATH(N'')
                )
               ,N''
            )

    SELECT
        @Script += N'
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;'

    IF EXISTS(SELECT 1 FROM @Declarations)
    BEGIN
        SELECT
            @Script += N'

    DECLARE '

        SELECT
            @Script +=
                (
                    SELECT
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2 - 1)
                      + CASE ROW_NUMBER() OVER(ORDER BY d.[Order]) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                      + d.Variable
                    FROM @Declarations d
                    ORDER BY d.[Order]
                    FOR XML PATH(N'')
                ) + N';'
    END

    SELECT
        @Script += N'

    SELECT
' + CONCAT(REPLICATE(N' ', @Tab * 2), N'@', @Identifier, N' = IIF(@', @Identifier, N' > 0, @', @Identifier, N', NULL)')

    IF @FieldLinkToTypeTag IS NOT NULL
    BEGIN
        --проверку что процедура соответствует типу
        SELECT
            @Script += N'
       ,@' + @FieldLinkToTypeColumn + N' = ISNULL(@' + @FieldLinkToTypeColumn + N', IIF(@' + @FieldLinkToTypeTag + N'Tag IS NULL, ' + CAST(@ID as nvarchar(32)) + N', dbo.TypeIDByTag(@' + @FieldLinkToTypeTag + N'Tag))); --' + @TypeTag + N'

    IF @' + @FieldLinkToTypeColumn + N' IS NOT NULL
        OR @' +@FieldLinkToTypeTag + N'Tag IS NOT NULL
    BEGIN
        EXEC dbo.[TypeCheckProcedure]
            @TypeID = @' + @FieldLinkToTypeColumn + N'
           ,@OwnerTypeID = ' + CAST(@ID as nvarchar(32)) + N' --' + @TypeTag + N'
           ,@Operation = N''Set''
    END'
    END

    SELECT
        @Script += N';

    BEGIN TRAN;'

    --SetBefore START - курсор по процедурам, вызываемым до сохранения изменений
    DECLARE CUR CURSOR LOCAL STATIC FORWARD_ONLY FOR
        SELECT
            od.Tag
           ,p.ProcedureName
           ,p.[Object_ID]
        FROM @Procedures p
            JOIN dbo.TDirectory od ON od.ID = p.OwnerID
        WHERE p.IsAfter = 0
        ORDER BY p.[Order]
    
    OPEN CUR
    FETCH NEXT FROM CUR INTO
        @CursorProcedureOwnerTag
       ,@CursorProcedureName
       ,@CursorProcedureObject_ID

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT
            @Script += N'

    ---------BEFORE ' + @CursorProcedureOwnerTag + N'---------
    EXEC ' + @CursorProcedureName

        SELECT
            @Script +=
                ISNULL
                (
                    (
                       SELECT 
                            CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2 - 1)
                            + CASE ROW_NUMBER() OVER(ORDER BY sp.parameter_id) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                            + sp.name + N' = ' + sp.name
                            + CASE sp.is_output WHEN 1 THEN N' OUTPUT' ELSE N'' END
                        FROM sys.parameters sp
                        WHERE (sp.object_id = @CursorProcedureObject_ID)
                        ORDER BY sp.parameter_id
                        FOR XML PATH(N'')
                    )
                   ,N''
                ) + N';'
    
        FETCH NEXT FROM CUR INTO
            @CursorProcedureOwnerTag
           ,@CursorProcedureName
           ,@CursorProcedureObject_ID
    END
    
    CLOSE CUR
    DEALLOCATE CUR
    --SetBefore END

    --TypeCheckLinks START- проверка переменных на соответствие указанным типам после их получения в параметрах и изменения в SetBefore процедурах 
    IF EXISTS(SELECT 1 FROM dbo.DirectoryChildrenInline(@TypeID_FieldLink, N'Type', 1) tc JOIN @Fields f ON f.TypeID = tc.ID)
    BEGIN
        SELECT
            @Script += N'

    ---------CHECK Links---------
    INSERT INTO @FieldLinks
        (KeyID, ValueID)
    VALUES'

        SELECT
            @Script +=
                (
                    SELECT
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2 - 1)
                      + CASE ROW_NUMBER() OVER(ORDER BY f.[Order]) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                      + CONCAT(N'(', CAST(f.ID as nvarchar(32)), N', @', f.[Column], N') --', f.Tag)
                    FROM dbo.DirectoryChildrenInline(@TypeID_FieldLink, N'Type', 1) tc 
                        JOIN @Fields f ON f.TypeID = tc.ID
                    ORDER BY f.[Order]
                    FOR XML PATH(N'')
                ) + N';'

        SELECT
            @Script += N'

    EXEC dbo.[TypeCheckLinks]
        @ID = @' + @Identifier + N'
       ,@TypeID = @TypeID
       ,@FieldLinks = @FieldLinks;'
    END
    --TypeCheckLinks END

    --Merge START
    IF EXISTS(SELECT 1 FROM @Fields f)
    BEGIN
        DECLARE CUR CURSOR LOCAL STATIC FORWARD_ONLY FOR
            SELECT
                f.OwnerID
               ,f.OwnerTag
            FROM @Fields f
            GROUP BY
                f.OwnerID
               ,f.OwnerTag
            ORDER BY MAX(f.[Order])

        OPEN CUR
        FETCH NEXT FROM CUR INTO @CursorMergeOwnerID, @CursorMergeOwnerTag
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            
            SELECT
                @Script += N'

    ---------MERGE ' + @CursorMergeOwnerTag + N'---------
    WITH CTE as 
    (
        SELECT'

            SELECT
                @Script +=
                    ISNULL
                    (
                        (
                            SELECT 
                                CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 3 - 1)
                                + CASE ROW_NUMBER() OVER(ORDER BY f.[Order]) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                                + CONCAT('@', f.[Column], N' as [', f.[Column], N']')
                            FROM 
                                (
                                    SELECT 
                                        @Identifier as [Column]
                                       ,0 as [Order]
                                    UNION ALL
                                    SELECT
                                        f.[Column]
                                       ,f.[Order] 
                                    FROM @Fields f
                                    WHERE (f.OwnerID = @CursorMergeOwnerID)
                                        AND (f.TypeTag <> N'FieldIdentifier')
                                ) f
                            ORDER BY
                                f.[Order]
                            FOR XML PATH(N'')
                        )
                       ,N''
                    )
        
            SELECT
                @Script += N'
    )
    MERGE [' + @SchemaName + N'].[T' + @CursorMergeOwnerTag + N'] [target]
    USING CTE [source] ON [target].[' + @Identifier + N'] = [source].[' + @Identifier + N']
    WHEN MATCHED THEN
        UPDATE
        SET'

            SELECT
                @Script +=
                    ISNULL
                    (
                        (
                            SELECT 
                                CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 3 - 1)
                                + CASE ROW_NUMBER() OVER(ORDER BY f.[Order]) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                                + CONCAT(N'[', f.[Column], N'] = [source].[', f.[Column], N']')
                            FROM @Fields f
                            WHERE (f.OwnerID = @CursorMergeOwnerID)
                                AND (f.TypeTag <> N'FieldIdentifier')
                            ORDER BY f.[Order]
                            FOR XML PATH(N'')
                        )
                       ,N''
                    )
            SELECT
                @Script += N'
    WHEN NOT MATCHED THEN
        INSERT
        ('

            SELECT
                @Script +=
                    ISNULL
                    (
                        (
                            SELECT 
                                CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 3 - 1)
                                + CASE ROW_NUMBER() OVER(ORDER BY f.[Order]) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                                + CONCAT(N'[', f.[Column], N']')
                            FROM 
                                (
                                    SELECT 
                                        @Identifier as [Column]
                                       ,0 as [Order]
                                    WHERE NOT EXISTS(SELECT 1 FROM @Fields f WHERE f.OwnerID = @CursorMergeOwnerID AND f.TypeTag = N'FieldIdentifier')
                                    UNION ALL
                                    SELECT
                                        f.[Column]
                                       ,f.[Order] 
                                    FROM @Fields f
                                    WHERE (f.OwnerID = @CursorMergeOwnerID)
                                        AND (f.TypeTag <> N'FieldIdentifier')
                                ) f
                            ORDER BY f.[Order]
                            FOR XML PATH(N'')
                        )
                       ,N''
                    )

            SELECT
                @Script += N'
        )
        VALUES
        ('

            SELECT
                @Script +=
                    ISNULL
                    (
                        (
                            SELECT 
                                CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 3 - 1)
                                + CASE ROW_NUMBER() OVER(ORDER BY f.[Order]) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                                + CONCAT(N'[source].[', f.[Column], N']')
                            FROM 
                                (
                                    SELECT 
                                        @Identifier as [Column]
                                       ,0 as [Order]
                                    WHERE NOT EXISTS(SELECT 1 FROM @Fields f WHERE f.OwnerID = @CursorMergeOwnerID AND f.TypeTag = N'FieldIdentifier')
                                    UNION ALL
                                    SELECT
                                        f.[Column]
                                       ,f.[Order]
                                    FROM @Fields f
                                    WHERE (f.OwnerID = @CursorMergeOwnerID)
                                        AND (f.TypeTag <> N'FieldIdentifier')
                                ) f
                            ORDER BY f.[Order]
                            FOR XML PATH(N'')
                        )
                       ,N''
                    ) + N'
        )'

            IF EXISTS(SELECT 1 FROM @Fields f WHERE f.OwnerID = @CursorMergeOwnerID AND f.TypeTag = N'FieldIdentifier')
            BEGIN
                SELECT
                    @Script += N'
        OUTPUT inserted.[' + @Identifier + N'] INTO @Inserted;

    SELECT TOP (1) @' + @Identifier + N' = ins.[ID]
    FROM @Inserted ins;'
            END
            ELSE
            BEGIN
                SELECT
                    @Script += N';'
            END

            FETCH NEXT FROM CUR INTO @CursorMergeOwnerID, @CursorMergeOwnerTag
        END
        
        CLOSE CUR
        DEALLOCATE CUR
    END
    --Merge END

    --SetAfter START - курсор по SetAfter процедурам
    DECLARE CUR CURSOR LOCAL STATIC FORWARD_ONLY FOR
        SELECT
            od.Tag
           ,p.ProcedureName
           ,p.[Object_ID]
        FROM @Procedures p
            JOIN dbo.TDirectory od ON od.ID = p.OwnerID
        WHERE p.IsAfter = 1
        ORDER BY p.[Order] DESC
    
    OPEN CUR
    FETCH NEXT FROM CUR INTO
        @CursorProcedureOwnerTag
       ,@CursorProcedureName
       ,@CursorProcedureObject_ID
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT
            @Script += N'

    ---------AFTER ' + @CursorProcedureOwnerTag + N'---------
    EXEC ' + @CursorProcedureName

        SELECT
            @Script +=
                ISNULL
                (
                    (
                        SELECT 
                            CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2 - 1)
                            + CASE ROW_NUMBER() OVER(ORDER BY sp.parameter_id) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                            + CONCAT(sp.name, N' = ', sp.name)
                            + CASE sp.is_output WHEN 1 THEN N' OUTPUT' ELSE N'' END
                        FROM sys.parameters sp
                        WHERE (sp.object_id = @CursorProcedureObject_ID)
                        ORDER BY sp.parameter_id
                        FOR XML PATH(N'')
                    )
                   ,N''
                ) + N';'
    
        FETCH NEXT FROM CUR INTO
            @CursorProcedureOwnerTag
           ,@CursorProcedureName
           ,@CursorProcedureObject_ID
    END
    
    CLOSE CUR
    DEALLOCATE CUR
    --SetAfter END

    SELECT
        @Script += N'

    COMMIT TRAN;
END;'

    SELECT
        @Script = REPLACE(REPLACE(REPLACE(@Script, N'&#x0D;', CHAR(13)), N'&lt;', N'<'), N'&gt;', N'>')

    IF @Print = 1
    BEGIN 
        WHILE LEN(@Script) > 0
        BEGIN
            PRINT IIF(CHARINDEX(NCHAR(13), @Script) > 0, SUBSTRING(@Script, 1, CHARINDEX(NCHAR(13), @Script) - 1), @Script)
            SET @Script = IIF(CHARINDEX(NCHAR(13), @Script) > 0, SUBSTRING(@Script, CHARINDEX(NCHAR(13), @Script) + 2, LEN(@Script) - CHARINDEX(NCHAR(13), @Script) + 1), N'')
        END
    END
    ELSE
    BEGIN
        EXEC(@Script)
    END
END
--EXEC dbo.TypeFormGenerateSet @ID = 59, @Print = 1