--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_09_dboTypeFormGenerateTable.sql logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[TypeFormGenerateTable]
    @ID bigint
   ,@Print bit = 0
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE 
        @Script nvarchar(max)
       ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
       ,@SchemaName dbo.string
       ,@TableName dbo.string
       ,@TypeTag dbo.string
       ,@TypeOwnerTag dbo.string
       ,@Object_ID int
       ,@Identifier dbo.string
       ,@IdentifierOwner dbo.string
       ,@Tab tinyint = 4

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

    --если нет полей, то генерировать таблицу не требуется
    IF NOT EXISTS(SELECT 1 FROM @Fields f WHERE f.OwnerID = @ID)
    BEGIN
        RETURN 0
    END

    SELECT
        @SchemaName = N'dbo'
       ,@TableName = CONCAT(N'T', d.[Tag])
       ,@TypeTag = d.Tag
       ,@Object_ID = OBJECT_ID(CONCAT(N'[dbo].[T', d.[Tag], N']'), N'U')
    FROM dbo.TObject o
        JOIN dbo.TDirectory d ON d.ID = o.ID
        JOIN dbo.TType t ON t.ID = o.ID
    WHERE o.ID = @ID

    --получаем название ближайшего супертипа c полями
    SELECT TOP (1)
        @TypeOwnerTag = f.[OwnerTag]
    FROM @Fields f
    WHERE f.OwnerID <> @ID
    ORDER BY f.[Order]

    --находим тип владелец идентификатора
    SELECT TOP (1)
        @Identifier = f.[Column]
       ,@IdentifierOwner = f.OwnerTag
    FROM @Fields f
    WHERE (f.TypeTag = N'FieldIdentifier')
    ORDER BY f.[Order]

    IF @Identifier IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не найден идентификатор типа ID=%s'
           ,@p0 = @ID
    END

    SELECT
        @Script = 
N'--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------'

    IF EXISTS
    (
        SELECT 1
        FROM @Fields f
        WHERE f.OwnerID = @ID
            AND NOT EXISTS
                (
                    SELECT 1
                    FROM sys.columns sc
                    WHERE sc.object_id = @Object_ID
                        AND sc.name = f.[Column] --COLLATE SQL_Latin1_General_CP1_CI_AS
                )
    )
    BEGIN    
        SELECT
            @Script +=
                CHAR(13) + CHAR(10)  
              + CASE
                    WHEN @Object_ID IS NULL THEN N'CREATE'
                    ELSE N'ALTER'
                END
              + CONCAT(N' TABLE [', @SchemaName, N'].[', @TableName, N']')
              + CASE 
                    WHEN @Object_ID IS NULL THEN N'                    
('
                    ELSE N' ADD'
                END

        SELECT
            @Script +=
                ISNULL
                (
                    (
                        SELECT 
                            CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab - 1)
                          + CASE ROW_NUMBER() OVER(ORDER BY f.[Order]) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                          + CONCAT(N'[', f.[Column], N'] ', f.DataType)
                        FROM 
                            (
                                SELECT
                                    f.[Column]
                                   ,CONCAT(f.DataType, N' NOT NULL') as DataType
                                   ,f.[Order]
                                FROM @Fields f
                                WHERE (@TypeOwnerTag IS NOT NULL)
                                    AND (@Object_ID IS NULL)
                                    AND (f.TypeTag = N'FieldIdentifier')
                                UNION ALL 
                                SELECT
                                    f.[Column]
                                   ,f.DataType
                                      + CASE f.TypeTag
                                            WHEN N'FieldIdentifier' THEN N' NOT NULL IDENTITY(1, 1)'
                                            ELSE N' NULL'
                                        END as DataType
                                   ,f.[Order]
                                FROM @Fields f
                                WHERE f.OwnerID = @ID
                            ) f
                        WHERE NOT EXISTS
                            (
                                SELECT 1
                                FROM sys.columns sc
                                WHERE sc.object_id = @Object_ID
                                    AND sc.name = f.[Column] --COLLATE SQL_Latin1_General_CP1_CI_AS
                            )
                        ORDER BY f.[Order]
                        FOR XML PATH(N'')
                    )
                   ,N''
                )
    END

    IF NOT EXISTS(SELECT 1 FROM sys.key_constraints skc WHERE skc.parent_object_id = @Object_ID)
    BEGIN
        SELECT
            @Script += N'
   ,CONSTRAINT PK_' + CONCAT(@TypeTag, N'_', @Identifier, N' PRIMARY KEY ([', @Identifier, N'])')
    END

    IF @Object_ID IS NULL
    BEGIN
        SELECT
            @Script += N'
);'

        IF @TypeOwnerTag IS NOT NULL
        BEGIN
            SELECT
                @Script += N'

ALTER TABLE [' + @SchemaName + N'].[' + @TableName + N'] WITH CHECK ADD CONSTRAINT [FK_' + @TypeTag + N'_' + @Identifier + N'] FOREIGN KEY([' +@Identifier + N']) REFERENCES [' +@SchemaName + N'].[' + @TableName + N']([' + @Identifier + N']);
ALTER TABLE [' + @SchemaName + N'].[' + @TableName + N'] CHECK CONSTRAINT [FK_' + @TypeTag + N'_' + @Identifier + N'];'
        END
    END

    --инициализируем типизированную таблицу, если она не существовала
    IF @Object_ID IS NULL
        AND @TypeOwnerTag IS NOT NULL
        AND EXISTS (SELECT 1 FROM @Fields f WHERE f.[Column] = N'TypeID')
    BEGIN
        SELECT
            @Script += N'

WITH Types AS
(
    SELECT t.[ID]
    FROM dbo.DirectoryChildrenInline(dbo.TypeIDByTag(''' + @TypeTag + N'''), N''Type'', 1) t
)
INSERT INTO [' + @SchemaName + N'].[' + @TableName + N'] ([' + @Identifier + N'])
SELECT s.[' + @Identifier + N']
FROM [' + @SchemaName + N'].[T' + @IdentifierOwner + N'] s
    JOIN Types t ON t.ID = s.TypeID
WHERE NOT EXISTS(SELECT 1 FROM [' + @SchemaName + N'].[' + @TableName + N'] tg WHERE tg.[' + @Identifier + N'] = s.[' + @Identifier + N']);'
    END

    SELECT
        @Script = REPLACE(REPLACE(REPLACE(@Script, N'&#x0D;', CHAR(13)), N'&lt;', N'<'), N'&gt;', N'>')

    IF @Print = 1
    BEGIN
        --выводим скрипт построчно, т.к. команда PRINT может вывести максимум 4000 символов
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
--EXEC dbo.TypeFormGenerateTable @ID = 3, @Print = 1
/*
DECLARE @ID bigint

DECLARE cur_types CURSOR LOCAL STATIC FORWARD_ONLY FOR
    SELECT t.ID
    FROM dbo.TType t
    WHERE  
        EXISTS
        (
            SELECT 1
            FROM dbo.TDirectory d
                JOIN dbo.TField a ON a.ID = d.ID
            WHERE d.OwnerID = t.ID
        )
    ORDER BY t.ID;
        
OPEN cur_types;
FETCH NEXT FROM cur_types INTO @ID;
        
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @ID
    EXEC dbo.TypeFormGenerateTable @ID = @ID, @Print = 1

    FETCH NEXT FROM cur_types INTO @ID;
END;
        
CLOSE cur_types;
DEALLOCATE cur_types;
*/