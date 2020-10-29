--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_10_dboTypeFormGenerateView logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[TypeFormGenerateView]
    @ID bigint
   ,@Print bit = 0
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE 
        @Script nvarchar(max)
       ,@SchemaName dbo.string
       ,@ViewName dbo.string
       ,@TypeTag dbo.string
       ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
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

    --если нет полей, то генерировать вьюху не требуется
    IF NOT EXISTS(SELECT 1 FROM @Fields f WHERE f.OwnerID = @ID)
    BEGIN
        RETURN 0
    END

    SELECT
        @SchemaName = N'dbo'
       ,@ViewName = CONCAT(N'V', d.[Tag])
       ,@TypeTag = d.Tag
       ,@Object_ID = OBJECT_ID(CONCAT(QUOTENAME(N'dbo'), N'.', QUOTENAME(N'V' + d.[Tag])), N'V')
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
          + CONCAT(N' VIEW ', QUOTENAME(@SchemaName), N'.', QUOTENAME(@ViewName))

    SELECT
        @Script += N'
AS
    SELECT'

    SELECT
        @Script +=
            ISNULL
            (
                (
                    SELECT 
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2 - 1)
                      + CASE ROW_NUMBER() OVER(ORDER BY f.[Order]) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                      + CONCAT(QUOTENAME(LOWER(CONCAT(@SchemaName, N't', f.OwnerTag))), N'.', QUOTENAME(f.[Column]))
                    FROM @Fields f
                    ORDER BY f.[Order]
                    FOR XML PATH(N'')
                )
               ,N''
            ) + N'
    FROM'
          + ISNULL
            (
                (
                    SELECT 
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2 - 1)
                      + CASE ROW_NUMBER() OVER(ORDER BY MAX(f.[Order])) WHEN 1 THEN N'' ELSE N'JOIN ' END --для первой таблицы не пишем JOIN
                      + CONCAT(N'[', @SchemaName, N'].[T', f.OwnerTag, N'] [', LOWER(CONCAT(@SchemaName, 't', f.OwnerTag)), N']')
                      + CASE ROW_NUMBER() OVER(ORDER BY MAX(f.[Order])) WHEN 1 THEN N'' ELSE CONCAT(N' ON [', LOWER(CONCAT(@SchemaName, 't', f.OwnerTag)), N'].[', @Identifier, N'] = [', LOWER(CONCAT(@SchemaName, 't', @IdentifierOwner)), N'].[', @Identifier, N']') END
                    FROM @Fields f
                    GROUP BY f.OwnerTag
                    ORDER BY MAX(f.[Order])
                    FOR XML PATH(N'')
                )
               ,N''
            )

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
--EXEC dbo.TypeFormGenerateView @ID = 3, @Print = 1
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
                JOIN dbo.TField f ON f.ID = d.ID
            WHERE d.OwnerID = t.ID
        )
    ORDER BY t.ID;
        
OPEN cur_types;
FETCH NEXT FROM cur_types INTO @ID;
        
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @ID
    EXEC dbo.TypeFormGenerateView @ID = @ID, @Print = 1

    FETCH NEXT FROM cur_types INTO @ID;
END;
        
CLOSE cur_types;
DEALLOCATE cur_types;
*/