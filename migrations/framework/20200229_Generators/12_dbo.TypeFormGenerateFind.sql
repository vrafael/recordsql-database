--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_12_dboTypeFormGenerateFind logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[TypeFormGenerateFind]
    @ID bigint
   ,@Print bit = 0
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @TypeID_FieldLink bigint = dbo.TypeIDByTag(N'FieldLink')
       ,@TypeID_FieldLinkToType bigint = dbo.TypeIDByTag('FieldLinkToType')
       ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed') 
       ,@SchemaName dbo.string
       ,@Identifier dbo.string
       ,@IdentifierOwner dbo.string
       ,@Script nvarchar(max)
       ,@ProcedureName dbo.string
       ,@TypeTag dbo.string
       ,@Object_ID int
       ,@Tab tinyint = 4

    DECLARE
        @Templates TABLE --шаблоны полей
        (
            [Type] dbo.string NOT NULL
           ,FieldType dbo.string NOT NULL
           ,Template dbo.string NOT NULL
           ,[Order] bigint NOT NULL IDENTITY(1, 1)          
        )

    DECLARE
        @Sources TABLE
        ( 
            ID bigint NOT NULL
           ,Source dbo.string NOT NULL
           ,Pattern dbo.string NOT NULL
           ,[Order] bigint NOT NULL IDENTITY(1, 1)  
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

    --если нет атрибутов типа то генерировать процедуру не требуется
    IF NOT EXISTS(SELECT 1 FROM @Fields f WHERE f.OwnerID = @ID)
    BEGIN
        RETURN 0
    END

    SELECT
        @SchemaName = N'dbo'
       ,@ProcedureName = CONCAT(d.[Tag], N'Find')
       ,@TypeTag = d.Tag
       ,@Object_ID = OBJECT_ID(CONCAT(N'[dbo].[', d.[Tag], N'Find]'), N'P')
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

    INSERT INTO @Templates
        ([Type],FieldType,Template)
    VALUES
      /*(N'Parameter', N'FieldIdentifier', N'@<Column>_ValueFrom bigint = NULL')
       ,(N'Parameter', N'FieldIdentifier', N'@<Column>_ValueTo bigint = NULL')
       ,(N'Parameter', N'FieldLink', N'@<Column> nvarchar(max) = NULL')
       --,(N'Parameter', N'FieldLinkToType', N'@<Tag>Children bit = NULL')
       ,(N'Parameter', N'FieldString', N'@<Tag> <DataType> = NULL')
       ,(N'Parameter', N'FieldBool', N'@<Tag> smallint = NULL')
       ,(N'Parameter', N'FieldInt', N'@<Tag>_ValueFrom <DataType> = NULL')
       ,(N'Parameter', N'FieldInt', N'@<Tag>_ValueTo <DataType> = NULL')
       ,(N'Parameter', N'FieldBigint', N'@<Tag>_ValueFrom <DataType> = NULL')
       ,(N'Parameter', N'FieldBigint', N'@<Tag>_ValueTo <DataType> = NULL')
       ,(N'Parameter', N'FieldMoney', N'@<Tag>_ValueFrom <DataType> = NULL')
       ,(N'Parameter', N'FieldMoney', N'@<Tag>_ValueTo <DataType> = NULL')
       ,(N'Parameter', N'FieldFloat', N'@<Tag>_ValueFrom <DataType> = NULL')
       ,(N'Parameter', N'FieldFloat', N'@<Tag>_ValueTo <DataType> = NULL')
       ,(N'Parameter', N'FieldDatetime', N'@<Tag>_ValueFrom <DataType> = NULL')
       ,(N'Parameter', N'FieldDatetime', N'@<Tag>_ValueTo <DataType> = NULL')
       ,(N'Parameter', N'FieldColor', N'@<Tag> <DataType> = NULL')
       ,(N'Parameter', N'FieldTime', N'@<Tag>_ValueFrom <DataType> = NULL')
       ,(N'Parameter', N'FieldTime', N'@<Tag>_ValueTo <DataType> = NULL')
       ,(N'Parameter', N'FieldDate', N'@<Tag>_ValueFrom <DataType> = NULL')
       ,(N'Parameter', N'FieldDate', N'@<Tag>_ValueTo <DataType> = NULL')*/
        (N'Declare', N'FieldIdentifier', N'@<Tag>_IsNull bit')
       ,(N'Declare', N'FieldIdentifier', N'@<Tag>_ValueFrom bigint')
       ,(N'Declare', N'FieldIdentifier', N'@<Tag>_ValueTo bigint')
       ,(N'Declare', N'FieldLink', N'@<Tag>_IsNull bit')
       ,(N'Declare', N'FieldLink', N'@<Tag>_Value nvarchar(max)')
       ,(N'Declare', N'FieldLinkToType', N'@<Tag>_Children bit')
       ,(N'Declare', N'FieldString', N'@<Tag>_IsNull bit')
       ,(N'Declare', N'FieldString', N'@<Tag>_Value <DataType>')
       ,(N'Declare', N'FieldBool', N'@<Tag>_IsNull bit')
       ,(N'Declare', N'FieldBool', N'@<Tag>_Value nvarchar(10)')
       ,(N'Declare', N'FieldInt', N'@<Tag>_IsNull bit')
       ,(N'Declare', N'FieldInt', N'@<Tag>_ValueFrom <DataType>')
       ,(N'Declare', N'FieldInt', N'@<Tag>_ValueTo <DataType>')
       ,(N'Declare', N'FieldBigint', N'@<Tag>_IsNull bit')
       ,(N'Declare', N'FieldBigint', N'@<Tag>_ValueFrom <DataType>')
       ,(N'Declare', N'FieldBigint', N'@<Tag>_ValueTo <DataType>')
       ,(N'Declare', N'FieldMoney', N'@<Tag>_IsNull bit')
       ,(N'Declare', N'FieldMoney', N'@<Tag>_ValueFrom <DataType>')
       ,(N'Declare', N'FieldMoney', N'@<Tag>_ValueTo <DataType>')
       ,(N'Declare', N'FieldFloat', N'@<Tag>_IsNull bit')
       ,(N'Declare', N'FieldFloat', N'@<Tag>_ValueFrom <DataType>')
       ,(N'Declare', N'FieldFloat', N'@<Tag>_ValueTo <DataType>')
       ,(N'Declare', N'FieldDatetime', N'@<Tag>_IsNull bit')
       ,(N'Declare', N'FieldDatetime', N'@<Tag>_ValueFrom <DataType>')
       ,(N'Declare', N'FieldDatetime', N'@<Tag>_ValueTo <DataType>')
       ,(N'Declare', N'FieldColor', N'@<Tag>_IsNull bit')
       ,(N'Declare', N'FieldColor', N'@<Tag>_Value <DataType>')
       ,(N'Declare', N'FieldTime', N'@<Tag>_IsNull bit')
       ,(N'Declare', N'FieldTime', N'@<Tag>_ValueFrom <DataType>')
       ,(N'Declare', N'FieldTime', N'@<Tag>_ValueTo <DataType>')
       ,(N'Declare', N'FieldDate', N'@<Tag>_IsNull bit')
       ,(N'Declare', N'FieldDate', N'@<Tag>_ValueFrom <DataType>')
       ,(N'Declare', N'FieldDate', N'@<Tag>_ValueTo <DataType>')
       ,(N'Column', N'FieldInt', N'[<Source>].[<Column>] as [<Tag>]')
       ,(N'Column', N'FieldBigint', N'[<Source>].[<Column>] as [<Tag>]')
       ,(N'Column', N'FieldBool', N'[<Source>].[<Column>] as [<Tag>]')
       ,(N'Column', N'FieldString', N'[<Source>].[<Column>] as [<Tag>]')
       ,(N'Column', N'FieldLink', N'[<Link>].[ID] as [<Tag>.ID]')
       ,(N'Column', N'FieldLink', N'[<Link>].[TypeID] as [<Tag>.TypeID]')
       ,(N'Column', N'FieldLink', N'[<Link>].[TypeName] as [<Tag>.TypeName]')
       ,(N'Column', N'FieldLink', N'[<Link>].[TypeIcon] as [<Tag>.TypeIcon]')
       ,(N'Column', N'FieldLink', N'[<Link>].[StateName] as [<Tag>.StateName]')
       ,(N'Column', N'FieldLink', N'[<Link>].[StateColor] as [<Tag>.StateColor]')
       ,(N'Column', N'FieldLink', N'[<Link>].[Name] as [<Tag>.Name]')
       ,(N'Column', N'FieldLinkToType', N'[<LinkToType>].[Icon] as [<Tag>.Icon]')
       ,(N'Column', N'FieldIdentifier', N'[<Source>].[<Column>] as [<Tag>]')
       ,(N'Column', N'FieldColor', N'[<Source>].[<Column>] as [<Tag>]')
       ,(N'Column', N'FieldDatetime', N'[<Source>].[<Column>] as [<Tag>]')
       ,(N'Column', N'FieldMoney', N'[<Source>].[<Column>] as [<Tag>]')
       ,(N'Column', N'FieldFloat', N'[<Source>].[<Column>] as [<Tag>]')
       ,(N'Column', N'FieldTime', N'[<Source>].[<Column>] as [<Tag>]')
       ,(N'Column', N'FieldDate', N'[<Source>].[<Column>] as [<Tag>]')
       ,(N'JsonSelect', N'FieldIdentifier', N'@<Tag>_IsNull = r.[<Tag>_IsNull]')
       ,(N'JsonSelect', N'FieldIdentifier', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]')
       ,(N'JsonSelect', N'FieldIdentifier', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]')
       ,(N'JsonSelect', N'FieldLink', N'@<Tag>_IsNull = r.[<Tag>_IsNull]')
       ,(N'JsonSelect', N'FieldLink', N'@<Tag>_Value = r.[<Tag>_Value]')
       ,(N'JsonSelect', N'FieldLinkToType', N'@<Tag>_Children = ISNULL(r.[<Tag>_Children], 0)')
       --,(N'JsonSelect', N'FieldLinkToType', N'@<Tag>_IsNull = r.[<Tag>_IsNull]')
       --,(N'JsonSelect', N'FieldLinkToType', N'@<Tag>_Value = r.[<Tag>_Value]')
       ,(N'JsonSelect', N'FieldString', N'@<Tag>_IsNull = r.[<Tag>_IsNull]')
       ,(N'JsonSelect', N'FieldString', N'@<Tag>_Value = r.[<Tag>_Value]')
       ,(N'JsonSelect', N'FieldBool', N'@<Tag>_IsNull = r.[<Tag>_IsNull]')
       ,(N'JsonSelect', N'FieldBool', N'@<Tag>_Value = r.[<Tag>_Value]')
       ,(N'JsonSelect', N'FieldInt', N'@<Tag>_IsNull = r.[<Tag>_IsNull]')
       ,(N'JsonSelect', N'FieldInt', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]')
       ,(N'JsonSelect', N'FieldInt', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]')
       ,(N'JsonSelect', N'FieldBigint', N'@<Tag>_IsNull = r.[<Tag>_IsNull]')
       ,(N'JsonSelect', N'FieldBigint', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]')
       ,(N'JsonSelect', N'FieldBigint', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]')
       ,(N'JsonSelect', N'FieldMoney', N'@<Tag>_IsNull = r.[<Tag>_IsNull]')
       ,(N'JsonSelect', N'FieldMoney', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]')
       ,(N'JsonSelect', N'FieldMoney', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]')
       ,(N'JsonSelect', N'FieldFloat', N'@<Tag>_IsNull = r.[<Tag>_IsNull]')
       ,(N'JsonSelect', N'FieldFloat', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]')
       ,(N'JsonSelect', N'FieldFloat', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]')
       ,(N'JsonSelect', N'FieldDatetime', N'@<Tag>_IsNull = r.[<Tag>_IsNull]')
       ,(N'JsonSelect', N'FieldDatetime', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]')
       ,(N'JsonSelect', N'FieldDatetime', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]')
       ,(N'JsonSelect', N'FieldColor', N'@<Tag>_IsNull = r.[<Tag>_IsNull]')
       ,(N'JsonSelect', N'FieldColor', N'@<Tag>_Value = r.[<Tag>_Value]')
       ,(N'JsonSelect', N'FieldTime', N'@<Tag>_IsNull = r.[<Tag>_IsNull]')
       ,(N'JsonSelect', N'FieldTime', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]')
       ,(N'JsonSelect', N'FieldTime', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]')
       ,(N'JsonSelect', N'FieldDate', N'@<Tag>_IsNull = r.[<Tag>_IsNull]')
       ,(N'JsonSelect', N'FieldDate', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]')
       ,(N'JsonSelect', N'FieldDate', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]')
       ,(N'JsonWith', N'FieldIdentifier', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''')
       ,(N'JsonWith', N'FieldIdentifier', N'[<Tag>_ValueFrom] bigint ''$.<Tag>.ValueFrom''')
       ,(N'JsonWith', N'FieldIdentifier', N'[<Tag>_ValueTo] bigint ''$.<Tag>.ValueTo''')
       ,(N'JsonWith', N'FieldLink', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''')
       ,(N'JsonWith', N'FieldLink', N'[<Tag>_Value] nvarchar(max) ''$.<Tag>.Value'' AS JSON')
       ,(N'JsonWith', N'FieldLinkToType', N'[<Tag>_Children] bit ''$.<Tag>.Children''')
       --,(N'JsonWith', N'FieldLinkToType', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''')
       --,(N'JsonWith', N'FieldLinkToType', N'[<Tag>_Value] nvarchar(max) ''$.<Tag>.Value'' AS JSON')
       ,(N'JsonWith', N'FieldString', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''')
       ,(N'JsonWith', N'FieldString', N'[<Tag>_Value] <DataType> ''$.<Tag>.Value''')
       ,(N'JsonWith', N'FieldBool', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''')
       ,(N'JsonWith', N'FieldBool', N'[<Tag>_Value] <DataType> ''$.<Tag>.Value''')
       ,(N'JsonWith', N'FieldInt', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''')
       ,(N'JsonWith', N'FieldInt', N'[<Tag>_ValueFrom] <DataType> ''$.<Tag>.ValueFrom''')
       ,(N'JsonWith', N'FieldInt', N'[<Tag>_ValueTo] <DataType> ''$.<Tag>.ValueTo''')
       ,(N'JsonWith', N'FieldBigint', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''')
       ,(N'JsonWith', N'FieldBigint', N'[<Tag>_ValueFrom] <DataType> ''$.<Tag>.ValueFrom''')
       ,(N'JsonWith', N'FieldBigint', N'[<Tag>_ValueTo] <DataType> ''$.<Tag>.ValueTo''')
       ,(N'JsonWith', N'FieldMoney', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''')
       ,(N'JsonWith', N'FieldMoney', N'[<Tag>_ValueFrom] <DataType> ''$.<Tag>.ValueFrom''')
       ,(N'JsonWith', N'FieldMoney', N'[<Tag>_ValueTo] <DataType> ''$.<Tag>.ValueTo''')
       ,(N'JsonWith', N'FieldFloat', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''')
       ,(N'JsonWith', N'FieldFloat', N'[<Tag>_ValueFrom] <DataType> ''$.<Tag>.ValueFrom''')
       ,(N'JsonWith', N'FieldFloat', N'[<Tag>_ValueTo] <DataType> ''$.<Tag>.ValueTo''')
       ,(N'JsonWith', N'FieldDatetime', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''')
       ,(N'JsonWith', N'FieldDatetime', N'[<Tag>_ValueFrom] <DataType> ''$.<Tag>.ValueFrom''')
       ,(N'JsonWith', N'FieldDatetime', N'[<Tag>_ValueTo] <DataType> ''$.<Tag>.ValueTo''')
       ,(N'JsonWith', N'FieldColor', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''')
       ,(N'JsonWith', N'FieldColor', N'[<Tag>_Value] [varchar](8) ''$.<Tag>.Value''')
       ,(N'JsonWith', N'FieldTime', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''')
       ,(N'JsonWith', N'FieldTime', N'[<Tag>_ValueFrom] <DataType> ''$.<Tag>.ValueFrom''')
       ,(N'JsonWith', N'FieldTime', N'[<Tag>_ValueTo] <DataType> ''$.<Tag>.ValueTo''')
       ,(N'JsonWith', N'FieldDate', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''')
       ,(N'JsonWith', N'FieldDate', N'[<Tag>_ValueFrom] <DataType> ''$.<Tag>.ValueFrom''')
       ,(N'JsonWith', N'FieldDate', N'[<Tag>_ValueTo] <DataType> ''$.<Tag>.ValueTo''')
       ,(N'Filter', N'FieldIdentifier', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)')
       ,(N'Filter', N'FieldIdentifier', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)')
       ,(N'Filter', N'FieldIdentifier', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)')
       ,(N'Filter', N'FieldLink', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)')
       ,(N'Filter', N'FieldLink', N'AND (@<Tag>_Value IS NULL OR (ISJSON(@<Tag>_Value) = 1 AND EXISTS(SELECT 1 FROM OPENJSON(@<Tag>_Value) <Tag>_jsonarray WHERE TRY_CAST(<Tag>_jsonarray.value as bigint) = [<Source>].[<Column>])))')
       ,(N'Filter', N'FieldLinkToType', N'AND (@<Tag>_Value IS NULL OR (ISJSON(@<Tag>_Value) = 1')
       ,(N'Filter', N'FieldLinkToType', REPLICATE(N' ', @Tab) + N'AND ((@<Tag>_Children = 1 AND EXISTS(SELECT 1 FROM OPENJSON(@<Tag>_Value) <Tag>_jsonarray CROSS APPLY dbo.DirectoryChildrenInline(TRY_CAST(<Tag>_jsonarray.value as bigint), ''Type'', 1) dci WHERE dci.ID = [<Source>].[<Column>]))')
       ,(N'Filter', N'FieldLinkToType', REPLICATE(N' ', @Tab * 2) + N'OR (@<Tag>_Children = 0 AND EXISTS(SELECT 1 FROM OPENJSON(@<Tag>_Value) <Tag>_jsonarray WHERE TRY_CAST(<Tag>_jsonarray.value as bigint) = [<Source>].[<Column>])))))')
       ,(N'Filter', N'FieldString', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)')
       ,(N'Filter', N'FieldString', N'AND (@<Tag>_Value IS NULL OR [<Source>].[<Column>] LIKE @<Tag>_Value)')
       ,(N'Filter', N'FieldInt', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)')
       ,(N'Filter', N'FieldInt', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)')
       ,(N'Filter', N'FieldInt', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)')
       ,(N'Filter', N'FieldBigint', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)')
       ,(N'Filter', N'FieldBigint', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)')
       ,(N'Filter', N'FieldBigint', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)')
       ,(N'Filter', N'FieldBool', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)')
       ,(N'Filter', N'FieldBool', N'AND (@<Tag>_Value IS NULL OR [<Source>].[<Column>] = CAST(IIF(UPPER(@<Tag>_Value) = N''TRUE'', 1, 0) as bit))')
       ,(N'Filter', N'FieldMoney', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)')
       ,(N'Filter', N'FieldMoney', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)')
       ,(N'Filter', N'FieldMoney', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)')
       ,(N'Filter', N'FieldFloat', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)')
       ,(N'Filter', N'FieldFloat', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)')
       ,(N'Filter', N'FieldFloat', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)')
       ,(N'Filter', N'FieldDatetime', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)')
       ,(N'Filter', N'FieldDatetime', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)')
       ,(N'Filter', N'FieldDatetime', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)')
       ,(N'Filter', N'FieldColor', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)')
       ,(N'Filter', N'FieldColor', N'AND (@<Tag>_Value IS NULL OR [<Source>].[<Column>] LIKE @<Tag>_Value)')
       ,(N'Filter', N'FieldTime', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)')
       ,(N'Filter', N'FieldTime', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)')
       ,(N'Filter', N'FieldTime', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)')
       ,(N'Filter', N'FieldDate', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)')
       ,(N'Filter', N'FieldDate', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)')
       ,(N'Filter', N'FieldDate', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)');
       
    --заполняем таблицу владельцев
    WITH Sources AS
    (
        SELECT  --типы
            ot.ID
           ,CAST(CONCAT(N'[dbo].[T', d.Tag, N']') as nvarchar(512)) as [Owner]
           ,CAST(LOWER(d.Tag) as nvarchar(512)) as [Source]
           ,ot.Lvl as Lvl1
           ,CAST(0 as bigint) as Lvl2
           ,CASE ot.Lvl
                WHEN 0 THEN CAST(N'<Owner> [<Source>]' as nvarchar(512))
                ELSE CAST(N'JOIN <Owner> [<Source>] ON [<Source>].[<Key>] = [<Main>].[<Key>]' as nvarchar(512))
            END as Pattern
        FROM
            (   --инвертируем сортировку типов
                SELECT
                    ot.ID
                   ,ROW_NUMBER() OVER(ORDER BY ot.Lvl DESC) - 1 as Lvl
                FROM dbo.DirectoryOwnersInline(@ID, N'Type', 1) ot
            ) ot
            JOIN dbo.TDirectory d ON d.ID = ot.ID
        WHERE EXISTS(SELECT 1 FROM @Fields f WHERE f.OwnerID = ot.ID)
        UNION ALL
        SELECT  --источники для Link
            f.ID
           ,CAST(N'[dbo].[ObjectInline]' as nvarchar(512)) as [Owner]
           ,CAST(LOWER(CONCAT(f.Tag, N'_', N'Link')) as nvarchar(512)) as [Source]
           ,oo.Lvl1 as Lvl1
           ,ROW_NUMBER() OVER(ORDER BY f.[Order]) + 1000 as Lvl2
           ,CAST(CONCAT(N'OUTER APPLY <Owner>([', oo.[Source], N'].[', f.[Column], N']) [<Source>]') as nvarchar(512)) as Pattern
        FROM Sources oo
            JOIN @Fields f ON f.OwnerID = oo.ID
        WHERE EXISTS
            (
                SELECT 1
                FROM dbo.DirectoryChildrenInline(@TypeID_FieldLink, N'Type', 1) ft
                WHERE ft.ID = f.TypeID
            )
        UNION ALL
        SELECT--источник для LinkToType
            f.ID
           ,CAST(N'[dbo].[TType]' as nvarchar(512)) as [Owner]
           ,CAST(LOWER(CONCAT(f.Tag, N'_', N'LinkToType')) as nvarchar(512)) as [Source]
           ,oo.Lvl1 as Lvl1
           ,ROW_NUMBER() OVER(ORDER BY f.[Order]) + 2000 as Lvl2
           ,CAST(CONCAT(N'JOIN <Owner> [<Source>] ON [<Source>].[ID] = [', oo.[Source], N'].[', f.[Column], N']') as nvarchar(512)) as Pattern
        FROM Sources oo
            JOIN @Fields f ON f.OwnerID = oo.ID
        WHERE EXISTS
            (
                SELECT 1
                FROM dbo.DirectoryChildrenInline(@TypeID_FieldLinkToType, N'Type', 1) rt
                WHERE rt.ID = f.TypeID
            )
    )
    INSERT INTO @Sources
    (
        ID
       ,[Source]
       ,Pattern
    )
    SELECT
        oo.ID
       ,oo.[Source]
       ,REPLACE
        (
            REPLACE
            (
                oo.Pattern
               ,'<Owner>'
               ,oo.[Owner]
            )
           ,'<Source>'
           ,oo.[Source]
        ) as [Pattern]
    FROM Sources oo
        LEFT JOIN dbo.TDirectory do ON do.ID = oo.ID
        LEFT JOIN dbo.TDirectory ds ON ds.ID = do.OwnerID
    ORDER BY
        oo.Lvl1
       ,oo.Lvl2

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
          + CONCAT(N' PROCEDURE [', @SchemaName, N'].[', @ProcedureName, N']')
          + '
    @PageSize int = 100 OUTPUT
   ,@PageNumber int = 1 OUTPUT';

    /*переменные фильтров в параметрах
    SELECT
        @Script +=
            ISNULL
            (
                (
                    SELECT 
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab - 1) + N','
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
                                CROSS APPLY dbo.DirectoryOwnersInline(f.TypeID, N'Type', 1) ot
                                JOIN dbo.TDirectory td ON td.ID = ot.ID
                                JOIN @Templates p ON p.FieldType = td.Tag
                                    AND p.[Type] = N'Parameter'
                        ) f
                    ORDER BY f.[Order]
                    FOR XML PATH(N'')
                )
               ,N''
            )*/

    SELECT
        @Script += N'
   ,@Find nvarchar(max) = NULL
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;

    SELECT
        @PageSize = ISNULL(@PageSize, 100)
       ,@PageNumber = ISNULL(@PageNumber, 1);

    DECLARE
        @RowFirst int = @PageSize * (@PageNumber - 1 )'

    --перенос переменных фильтров из параметров в блок DECLARE
    SELECT
        @Script +=
            ISNULL
            (
                (
                    SELECT 
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2 - 1) + N','
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
                                CROSS APPLY dbo.DirectoryOwnersInline(f.TypeID, N'Type', 1) ot
                                JOIN dbo.TDirectory td ON td.ID = ot.ID
                                JOIN @Templates p ON p.FieldType = td.Tag
                                    AND p.[Type] = N'Declare'
                        ) f
                    ORDER BY f.[Order]
                    FOR XML PATH(N'')
                )
               ,N''
            )

    SELECT
        @Script += N';

    IF @Find IS NOT NULL
        AND ISJSON(@Find) = 1
    BEGIN
        SELECT TOP (1)' 
           -- @PageSize = r.[PageSize]
           --,@PageNumber = r.[PageNumber]

    SELECT
        @Script +=
            ISNULL
            (
                (
                    SELECT 
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 3 - 1)
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
                                CROSS APPLY dbo.DirectoryOwnersInline(f.TypeID, N'Type', 1) ot
                                JOIN dbo.TDirectory td ON td.ID = ot.ID
                                JOIN @Templates p ON p.FieldType = td.Tag
                                    AND p.[Type] = N'JsonSelect'
                        ) f
                    ORDER BY f.[Order]
                    FOR XML PATH(N'')
                )
               ,N''
            )

    SELECT
        @Script += N'
        FROM OPENJSON(@Find) WITH
            ('
               -- [PageSize] int ''$.Find.PageSize''
               --,[PageNumber] int ''$.Find.PageNumber'''

    SELECT
        @Script +=
            ISNULL
            (
                (
                    SELECT 
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 4 - 1)
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
                                CROSS APPLY dbo.DirectoryOwnersInline(f.TypeID, N'Type', 1) ot
                                JOIN dbo.TDirectory td ON td.ID = ot.ID
                                JOIN @Templates p ON p.FieldType = td.Tag
                                    AND p.[Type] = N'JsonWith'
                        ) f
                    ORDER BY f.[Order]
                    FOR XML PATH(N'')
                )
               ,N''
            )

    SELECT
        @Script += N'
            ) r
    END

    SELECT';

    SELECT
        @Script += 
            ISNULL
            (
                (
                    SELECT 
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2 - 1)
                      + CASE ROW_NUMBER() OVER(ORDER BY f.Ord1, f.Ord2) WHEN 1 THEN N' ' ELSE N',' END --для первого параметра убираем запятую
                      + REPLACE
                        (
                            REPLACE
                            (
                                REPLACE
                                (
                                    REPLACE
                                    (
                                        REPLACE
                                        (
                                            f.Template
                                           ,N'<LinkToType>'
                                           ,LOWER(CONCAT(f.Tag, N'_', N'LinkToType')) 
                                        )
                                       ,N'<Link>'
                                       ,LOWER(CONCAT(f.Tag, N'_', N'Link')) 
                                    )
                                   ,N'<Column>'
                                   ,f.[Column]
                                )
                               ,N'<Tag>'
                               ,f.Tag
                            )
                           ,N'<Source>'
                           ,f.[Source]
                        )
                    FROM 
                        (
                            SELECT  --прямые атрибуты
                                o.[Source] as [Source]
                               ,f.[Tag]
                               ,f.[Column]
                               ,t.Template as Template
                               ,f.[Order] as Ord1
                               ,t.[Order] as Ord2
                            FROM @Fields f
                                JOIN @Sources o ON o.ID = f.OwnerID
                                CROSS APPLY dbo.DirectoryOwnersInline(f.TypeID, N'Type', 1) ot
                                JOIN dbo.TDirectory td ON td.ID = ot.ID
                                JOIN @Templates t ON t.FieldType = td.Tag
                                    AND t.[Type] = N'Column'
                        ) f
                    ORDER BY
                        f.Ord1
                       ,f.Ord2
                    FOR XML PATH(N'')
                )
               ,N''
            )

    SELECT
        @Script += N'
    FROM'

    SELECT
        @Script += 
            ISNULL
            (
                (
                    SELECT 
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2)
                      + REPLACE
                        (
                            REPLACE
                            (
                                s.Pattern
                               ,N'<Key>'
                               ,@Identifier
                            )
                           ,N'<Main>'
                           ,LOWER(@IdentifierOwner)
                        )
                    FROM @Sources s
                    ORDER BY s.[Order]
                    FOR XML PATH(N'')
                )
               ,N''
            );

    SELECT
        @Script += N'
    WHERE (1 = 1)'

    SELECT
        @Script +=
            ISNULL
            (
                (
                    SELECT 
                        CHAR(13) + CHAR(10) + REPLICATE(N' ', @Tab * 2)
                      --+ CASE ROW_NUMBER() OVER(ORDER BY f.[Order]) WHEN 1 THEN N'' ELSE N'AND ' END
                      + REPLACE
                        (
                            REPLACE
                            (
                                REPLACE
                                (
                                    t.Template
                                   ,N'<Tag>'
                                   ,f.[Tag]
                                )
                               ,N'<Column>'
                               ,f.[Column]
                            )
                           ,N'<Source>'
                           ,LOWER(s.[Source])
                        )
                    FROM @Fields f
                        JOIN @Sources s ON s.ID = f.OwnerID
                        CROSS APPLY
                        (
                            SELECT TOP (1)
                                f.TypeTag
                            FROM dbo.DirectoryOwnersInline(f.TypeID, N'Type', 1) ot
                                JOIN dbo.TDirectory td ON td.ID = ot.ID
                                JOIN @Templates t ON t.FieldType = td.Tag
                                    AND t.[Type] = N'Filter'
                            ORDER BY ot.Lvl
                        ) ft
                        JOIN @Templates t ON t.FieldType = ft.TypeTag
                            AND t.[Type] = N'Filter'
                    FOR XML PATH(N'')
                )
               ,N''
            )

    SELECT
        @Script += '
    ORDER BY [' + LOWER(@IdentifierOwner) + '].[' + @Identifier + '] DESC
        OFFSET @RowFirst ROWS
        FETCH NEXT @PageSize ROWS ONLY
    OPTION (RECOMPILE)
    FOR JSON PATH;
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
--EXEC dbo.TypeFormGenerateFind @ID = 197, @Print = 1
--EXEC dbo.GlobalNormalize