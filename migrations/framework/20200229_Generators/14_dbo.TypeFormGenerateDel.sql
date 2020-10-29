--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_14_dboTypeFormGenerateDel logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[TypeFormGenerateDel]
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
       ,@OwnerTag dbo.string

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
        @Parameters TABLE
        (
            [Object_ID] int NOT NULL
           ,ParameterName dbo.string NOT NULL
           ,DataType dbo.string NOT NULL
           ,[Output] bit NOT NULL
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
       ,@ProcedureName = CONCAT(d.[Tag], N'Del')
       ,@TypeTag = d.Tag
       ,@Object_ID = OBJECT_ID(CONCAT(N'[dbo].[', d.[Tag], N'Del]'), N'P')
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
    ORDER BY f.[Order];

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
                       ,CONCAT(N'[dbo].[', td.Tag, N'DelBefore]') as [ProcedureName]
                       ,0 AS IsAfter
                       ,ot.Lvl
                    FROM Sources ot
                        JOIN dbo.TDirectory td ON td.ID = ot.ID
                    UNION ALL
                    SELECT
                        td.ID as OwnerID
                       ,CONCAT(N'[dbo].[', td.Tag, N'DelAfter]') as [ProcedureName]
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

    INSERT INTO @Parameters
    (
        [Object_ID]
       ,ParameterName
       ,DataType
       ,[Output]
    )
    SELECT
        p.[Object_ID]
       ,sp.name as ParameterName
       ,IIF(ss.name = N'sys', N'', ss.name + N'.') + st.name as DataType
       ,sp.is_output
    FROM @Procedures p
        JOIN sys.parameters sp ON sp.object_id = p.[Object_ID]
        JOIN sys.types st on st.user_type_id = sp.user_type_id
        JOIN sys.schemas ss on ss.schema_id = st.schema_id
    
    INSERT INTO @Declarations
        (Variable)
    SELECT --на случай если нет ссылки на тип
        CONCAT(N'@TypeID dbo.[link] = ', CAST(@ID as nvarchar(32)), N' --', @TypeTag) as Variable
    WHERE @FieldLinkToTypeTag IS NULL
    UNION ALL
    SELECT --если ссылка на тип есть
        CONCAT(N'@', f.[Column], N' ', f.DataType) as Variable
    FROM @Fields f
    WHERE f.Tag = @FieldLinkToTypeTag
    UNION ALL
    --добавляем переменные
    SELECT 
        CONCAT(p.ParameterName, N' ', p.DataType) as Variable
    FROM @Parameters p
    WHERE p.ParameterName <> CONCAT(N'@', @Identifier)
        AND (@FieldLinkToTypeTag IS NOT NULL 
            OR p.ParameterName <> CONCAT(N'@', N'TypeID'))
        /*AND NOT EXISTS
        (
            SELECT 1
            FROM @Fields f
            WHERE p.ParameterName = CONCAT(N'@', f.[Column])--COLLATE SQL_Latin1_General_CP1_CI_AS = sp.name
        )*/
    GROUP BY
        p.ParameterName
       ,p.DataType

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
          + CONCAT(N' PROCEDURE [', @SchemaName, N'].[', @ProcedureName, N']');
        
    SELECT
        @Script += N' 
    @' + @Identifier + N' dbo.string
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

        SELECT
            @Script +=
                ISNULL
                (N'

    SELECT'
                  + (
                        SELECT 
                            CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2 - 1)
                          + CASE ROW_NUMBER() OVER(ORDER BY f.[Order]) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                          + CONCAT(N'@', f.[Column], N' = [', LOWER(@SchemaName + f.[OwnerTag]), N'].[', f.[Column], N']')
                        FROM @Fields f
                        WHERE (f.TypeTag <> N'FieldIdentifier')
                            AND
                            (
                                f.TypeTag = N'FieldLinkToType'
                                OR EXISTS(SELECT 1 FROM @Parameters p WHERE p.ParameterName = CONCAT(N'@', f.[Column]))
                            )
                        ORDER BY f.[Order]
                        FOR XML PATH(N'')
                    )
                  + N'
    FROM'
                  + (
                        SELECT 
                            CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2)
                          + CASE ROW_NUMBER() OVER(ORDER BY MIN(f.[Order])) WHEN 1 THEN N'' ELSE N'JOIN ' END
                          + CONCAT(N'[', @SchemaName, N'].[T', f.[OwnerTag], N'] [', LOWER(@SchemaName + f.OwnerTag), N']')
                          + CASE ROW_NUMBER() OVER(ORDER BY MIN(f.[Order])) WHEN 1 THEN N'' ELSE CONCAT(N' ON [', LOWER(@SchemaName + f.OwnerTag), N'].[', @Identifier, N'] = [', LOWER(@SchemaName + @IdentifierOwner), N'].[', @Identifier, N']') END
                        FROM @Fields f
                        WHERE (f.TypeTag = N'FieldIdentifier')
                            OR (f.TypeTag = N'FieldLinkToType')
                            OR EXISTS(SELECT 1 FROM @Parameters p WHERE p.ParameterName = CONCAT(N'@', f.[Column]))
                        GROUP BY f.OwnerTag
                        FOR XML PATH(N'')
                    )
                  + N'
    WHERE [' + CONCAT(LOWER(@SchemaName + @IdentifierOwner), N'].[', @Identifier, N'] = @', @Identifier) + N';
    
    IF @@ROWCOUNT = 0
    BEGIN
        EXEC dbo.Error
            @TypeTag = N''SystemError''
           ,@Message = N''Не найдена запись %s=%s подтипа ID=%s''
           ,@p0 = N''' + @Identifier + N'''
           ,@p1 = @' + @Identifier + N'
           ,@p2 = ' + CAST(@ID as nvarchar(32)) + N' --' + @TypeTag + N'
    END;'
                   ,N''
                )
    END

    IF @FieldLinkToTypeTag IS NOT NULL
    BEGIN
        --проверку что процедура соответствует типу
        SELECT
            @Script += N'

    EXEC dbo.[TypeCheckProcedure]
        @TypeID = @' + @FieldLinkToTypeColumn + N'
       ,@OwnerTypeID = ' + CAST(@ID as nvarchar(32)) + N' --' + @TypeTag + N'
       ,@Operation = N''Del'''
    END

    SELECT
        @Script += N'

    BEGIN TRAN;'

    --DelBefore START - курсор по процедурам, вызываемым до удаления
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
                            + CASE ROW_NUMBER() OVER(ORDER BY p.[Order]) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                            + CONCAT(p.ParameterName, N' = ', p.ParameterName)
                            + CASE p.[Output] WHEN 1 THEN N' OUTPUT' ELSE N'' END
                        FROM @Parameters p
                        WHERE (p.object_id = @CursorProcedureObject_ID)
                        ORDER BY p.[Order]
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
    --DelBefore END

    --Delete
    IF EXISTS(SELECT 1 FROM @Fields f)
    BEGIN
        DECLARE CUR CURSOR LOCAL STATIC FORWARD_ONLY FOR
            SELECT
                f.OwnerTag
            FROM @Fields f
            GROUP BY f.OwnerTag
            ORDER BY MAX(f.[Order]) DESC

        OPEN CUR
        FETCH NEXT FROM CUR INTO @OwnerTag
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT
            @Script += N'

    ---------DELETE ' + @OwnerTag + N'---------
    DELETE FROM [' + @SchemaName + N'].[T' + @OwnerTag + N']
    WHERE [' + @Identifier + N'] = @' + @Identifier + N';'

            FETCH NEXT FROM CUR INTO @OwnerTag
        END

        CLOSE CUR
        DEALLOCATE CUR
    END

    --DelAfter START - курсор по процедурам, вызываемым до удаления
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
                            + CASE ROW_NUMBER() OVER(ORDER BY p.[Order]) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                            + CONCAT(p.ParameterName, N' = ', p.ParameterName)
                            + CASE p.[Output] WHEN 1 THEN N' OUTPUT' ELSE N'' END
                        FROM @Parameters p
                        WHERE (p.object_id = @CursorProcedureObject_ID)
                        ORDER BY p.[Order]
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
    --DelAfter END

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
--EXEC dbo.TypeFormGenerateDel @ID = 7, @Print = 1