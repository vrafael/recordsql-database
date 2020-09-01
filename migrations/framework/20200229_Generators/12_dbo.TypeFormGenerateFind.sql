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
       ,@TypeID_FieldLinkToType bigint = dbo.TypeIDByTag(N'FieldLinkToType')
       ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
       ,@SchemaName dbo.string
       ,@Identifier dbo.string
       ,@IdentifierOwner dbo.string
       ,@Script nvarchar(max)
       ,@ProcedureName dbo.string
       ,@TypeTag dbo.string
       ,@Object_ID int
       ,@Tab tinyint = 4
       ,@TypeID_FieldIdentifier bigint = dbo.TypeIDByTag(N'FieldIdentifier')
       ,@TypeID_Object bigint = dbo.TypeIDByTag(N'Object')

    DECLARE
        @Templates TABLE --шаблоны полей
        (
            [Type] dbo.string NOT NULL
           ,FieldType dbo.string NOT NULL
           ,Template dbo.string NOT NULL
           ,[JsonGroup] int NULL --группировка колонок для объекта JSON
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
        ([Type], FieldType, Template, [JsonGroup])
    VALUES
      /*(N'Parameter', N'FieldIdentifier', N'@<Column>_ValueFrom bigint = NULL', NULL)
       ,(N'Parameter', N'FieldIdentifier', N'@<Column>_ValueTo bigint = NULL', NULL)
       ,(N'Parameter', N'FieldLink', N'@<Column> nvarchar(max) = NULL', NULL)*/
        (N'Parameter', N'FieldLinkToType', N'@TypeID bigint = NULL', NULL)
       /*,(N'Parameter', N'FieldString', N'@<Tag> <DataType> = NULL', NULL)
       ,(N'Parameter', N'FieldBool', N'@<Tag> smallint = NULL', NULL)
       ,(N'Parameter', N'FieldInt', N'@<Tag>_ValueFrom <DataType> = NULL', NULL)
       ,(N'Parameter', N'FieldInt', N'@<Tag>_ValueTo <DataType> = NULL', NULL)
       ,(N'Parameter', N'FieldBigint', N'@<Tag>_ValueFrom <DataType> = NULL', NULL)
       ,(N'Parameter', N'FieldBigint', N'@<Tag>_ValueTo <DataType> = NULL', NULL)
       ,(N'Parameter', N'FieldMoney', N'@<Tag>_ValueFrom <DataType> = NULL', NULL)
       ,(N'Parameter', N'FieldMoney', N'@<Tag>_ValueTo <DataType> = NULL', NULL)
       ,(N'Parameter', N'FieldFloat', N'@<Tag>_ValueFrom <DataType> = NULL', NULL)
       ,(N'Parameter', N'FieldFloat', N'@<Tag>_ValueTo <DataType> = NULL', NULL)
       ,(N'Parameter', N'FieldDatetime', N'@<Tag>_ValueFrom <DataType> = NULL', NULL)
       ,(N'Parameter', N'FieldDatetime', N'@<Tag>_ValueTo <DataType> = NULL', NULL)
       ,(N'Parameter', N'FieldColor', N'@<Tag> <DataType> = NULL', NULL)
       ,(N'Parameter', N'FieldTime', N'@<Tag>_ValueFrom <DataType> = NULL', NULL)
       ,(N'Parameter', N'FieldTime', N'@<Tag>_ValueTo <DataType> = NULL', NULL)
       ,(N'Parameter', N'FieldDate', N'@<Tag>_ValueFrom <DataType> = NULL', NULL)
       ,(N'Parameter', N'FieldDate', N'@<Tag>_ValueTo <DataType> = NULL', NULL)*/
       ,(N'Declare', N'FieldIdentifier', N'@<Tag>_IsNull bit', NULL)
       ,(N'Declare', N'FieldIdentifier', N'@<Tag>_ValueFrom bigint', NULL)
       ,(N'Declare', N'FieldIdentifier', N'@<Tag>_ValueTo bigint', NULL)
       ,(N'Declare', N'FieldLink', N'@<Tag>_IsNull bit', NULL)
       ,(N'Declare', N'FieldLink', N'@<Tag>_Value nvarchar(max)', NULL)
       --,(N'Declare', N'FieldLinkToType', N'@<Tag>_Children bit', NULL)
       ,(N'Declare', N'FieldString', N'@<Tag>_IsNull bit', NULL)
       ,(N'Declare', N'FieldString', N'@<Tag>_Value <DataType>', NULL)
       ,(N'Declare', N'FieldBool', N'@<Tag>_IsNull bit', NULL)
       ,(N'Declare', N'FieldBool', N'@<Tag>_Value nvarchar(10)', NULL)
       ,(N'Declare', N'FieldInt', N'@<Tag>_IsNull bit', NULL)
       ,(N'Declare', N'FieldInt', N'@<Tag>_ValueFrom <DataType>', NULL)
       ,(N'Declare', N'FieldInt', N'@<Tag>_ValueTo <DataType>', NULL)
       ,(N'Declare', N'FieldBigint', N'@<Tag>_IsNull bit', NULL)
       ,(N'Declare', N'FieldBigint', N'@<Tag>_ValueFrom <DataType>', NULL)
       ,(N'Declare', N'FieldBigint', N'@<Tag>_ValueTo <DataType>', NULL)
       ,(N'Declare', N'FieldMoney', N'@<Tag>_IsNull bit', NULL)
       ,(N'Declare', N'FieldMoney', N'@<Tag>_ValueFrom <DataType>', NULL)
       ,(N'Declare', N'FieldMoney', N'@<Tag>_ValueTo <DataType>', NULL)
       ,(N'Declare', N'FieldFloat', N'@<Tag>_IsNull bit', NULL)
       ,(N'Declare', N'FieldFloat', N'@<Tag>_ValueFrom <DataType>', NULL)
       ,(N'Declare', N'FieldFloat', N'@<Tag>_ValueTo <DataType>', NULL)
       ,(N'Declare', N'FieldDatetime', N'@<Tag>_IsNull bit', NULL)
       ,(N'Declare', N'FieldDatetime', N'@<Tag>_ValueFrom <DataType>', NULL)
       ,(N'Declare', N'FieldDatetime', N'@<Tag>_ValueTo <DataType>', NULL)
       ,(N'Declare', N'FieldColor', N'@<Tag>_IsNull bit', NULL)
       ,(N'Declare', N'FieldColor', N'@<Tag>_Value <DataType>', NULL)
       ,(N'Declare', N'FieldTime', N'@<Tag>_IsNull bit', NULL)
       ,(N'Declare', N'FieldTime', N'@<Tag>_ValueFrom <DataType>', NULL)
       ,(N'Declare', N'FieldTime', N'@<Tag>_ValueTo <DataType>', NULL)
       ,(N'Declare', N'FieldDate', N'@<Tag>_IsNull bit', NULL)
       ,(N'Declare', N'FieldDate', N'@<Tag>_ValueFrom <DataType>', NULL)
       ,(N'Declare', N'FieldDate', N'@<Tag>_ValueTo <DataType>', NULL)
       ,(N'Column', N'FieldIdentifier', N'[<Source>].[<Column>] as [<Tag>]', NULL)
       ,(N'ColumnObject', N'FieldIdentifier', N'[_object].[ID] as [_object.ID]', 1)
       ,(N'ColumnObject', N'FieldIdentifier', N'[_object].[TypeID] as [_object.TypeID]', 1)
       ,(N'ColumnObject', N'FieldIdentifier', N'[_object].[TypeName] as [_object.TypeName]', 1)
       ,(N'ColumnObject', N'FieldIdentifier', N'[_object].[TypeTag] as [_object.TypeTag]', 1)
       ,(N'ColumnObject', N'FieldIdentifier', N'[_object].[TypeIcon] as [_object.TypeIcon]', 1)
       ,(N'ColumnObject', N'FieldIdentifier', N'[_object].[StateName] as [_object.StateName]', 1)
       ,(N'ColumnObject', N'FieldIdentifier', N'[_object].[StateColor] as [_object.StateColor]', 1)
       ,(N'ColumnObject', N'FieldIdentifier', N'[_object].[Name] as [_object.Name]', 1)
       ,(N'ColumnObject', N'FieldIdentifier', N'[_transitions].[list] as [_transitions]', 2) --доступные переходы состояний
       ,(N'Column', N'FieldLink', N'[<Link>].[ID] as [<Tag>.ID]', NULL)
       ,(N'Column', N'FieldLink', N'[<Link>].[TypeID] as [<Tag>.TypeID]', NULL)
       ,(N'Column', N'FieldLink', N'[<Link>].[TypeName] as [<Tag>.TypeName]', NULL)
       ,(N'Column', N'FieldLink', N'[<Link>].[TypeTag] as [<Tag>.TypeTag]', NULL)
       ,(N'Column', N'FieldLink', N'[<Link>].[TypeIcon] as [<Tag>.TypeIcon]', NULL)
       ,(N'Column', N'FieldLink', N'[<Link>].[StateName] as [<Tag>.StateName]', NULL)
       ,(N'Column', N'FieldLink', N'[<Link>].[StateColor] as [<Tag>.StateColor]', NULL)
       ,(N'Column', N'FieldLink', N'[<Link>].[Name] as [<Tag>.Name]', NULL)
       ,(N'Column', N'FieldLinkToType', N'[<LinkToType>].[Identifier] as [_record.Identifier]', 0)
       ,(N'Column', N'FieldLinkToType', N'[<LinkToType>].[TypeName] as [_record.TypeName]', 0)
       ,(N'Column', N'FieldLinkToType', N'[<LinkToType>].[TypeTag] as [_record.TypeTag]', 0)
       ,(N'Column', N'FieldLinkToType', N'[<LinkToType>].[TypeIcon] as [_record.TypeIcon]', 0)
       ,(N'Column', N'FieldString', N'[<Source>].[<Column>] as [<Tag>]', NULL)
       ,(N'Column', N'FieldBool', N'[<Source>].[<Column>] as [<Tag>]', NULL)
       ,(N'Column', N'FieldInt', N'[<Source>].[<Column>] as [<Tag>]', NULL)
       ,(N'Column', N'FieldBigint', N'[<Source>].[<Column>] as [<Tag>]', NULL)
       ,(N'Column', N'FieldMoney', N'[<Source>].[<Column>] as [<Tag>]', NULL)
       ,(N'Column', N'FieldFloat', N'[<Source>].[<Column>] as [<Tag>]', NULL)
       ,(N'Column', N'FieldDatetime', N'[<Source>].[<Column>] as [<Tag>]', NULL)
       ,(N'Column', N'FieldColor', N'[<Source>].[<Column>] as [<Tag>]', NULL)
       ,(N'Column', N'FieldTime', N'[<Source>].[<Column>] as [<Tag>]', NULL)
       ,(N'Column', N'FieldDate', N'[<Source>].[<Column>] as [<Tag>]', NULL)
       ,(N'JsonSelect', N'FieldIdentifier', N'@<Tag>_IsNull = r.[<Tag>_IsNull]', NULL)
       ,(N'JsonSelect', N'FieldIdentifier', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]', NULL)
       ,(N'JsonSelect', N'FieldIdentifier', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]', NULL)
       ,(N'JsonSelect', N'FieldLink', N'@<Tag>_IsNull = r.[<Tag>_IsNull]', NULL)
       ,(N'JsonSelect', N'FieldLink', N'@<Tag>_Value = r.[<Tag>_Value]', NULL)
       ,(N'JsonSelect', N'FieldString', N'@<Tag>_IsNull = r.[<Tag>_IsNull]', NULL)
       ,(N'JsonSelect', N'FieldString', N'@<Tag>_Value = r.[<Tag>_Value]', NULL)
       ,(N'JsonSelect', N'FieldBool', N'@<Tag>_IsNull = r.[<Tag>_IsNull]', NULL)
       ,(N'JsonSelect', N'FieldBool', N'@<Tag>_Value = r.[<Tag>_Value]', NULL)
       ,(N'JsonSelect', N'FieldInt', N'@<Tag>_IsNull = r.[<Tag>_IsNull]', NULL)
       ,(N'JsonSelect', N'FieldInt', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]', NULL)
       ,(N'JsonSelect', N'FieldInt', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]', NULL)
       ,(N'JsonSelect', N'FieldBigint', N'@<Tag>_IsNull = r.[<Tag>_IsNull]', NULL)
       ,(N'JsonSelect', N'FieldBigint', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]', NULL)
       ,(N'JsonSelect', N'FieldBigint', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]', NULL)
       ,(N'JsonSelect', N'FieldMoney', N'@<Tag>_IsNull = r.[<Tag>_IsNull]', NULL)
       ,(N'JsonSelect', N'FieldMoney', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]', NULL)
       ,(N'JsonSelect', N'FieldMoney', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]', NULL)
       ,(N'JsonSelect', N'FieldFloat', N'@<Tag>_IsNull = r.[<Tag>_IsNull]', NULL)
       ,(N'JsonSelect', N'FieldFloat', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]', NULL)
       ,(N'JsonSelect', N'FieldFloat', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]', NULL)
       ,(N'JsonSelect', N'FieldDatetime', N'@<Tag>_IsNull = r.[<Tag>_IsNull]', NULL)
       ,(N'JsonSelect', N'FieldDatetime', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]', NULL)
       ,(N'JsonSelect', N'FieldDatetime', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]', NULL)
       ,(N'JsonSelect', N'FieldColor', N'@<Tag>_IsNull = r.[<Tag>_IsNull]', NULL)
       ,(N'JsonSelect', N'FieldColor', N'@<Tag>_Value = r.[<Tag>_Value]', NULL)
       ,(N'JsonSelect', N'FieldTime', N'@<Tag>_IsNull = r.[<Tag>_IsNull]', NULL)
       ,(N'JsonSelect', N'FieldTime', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]', NULL)
       ,(N'JsonSelect', N'FieldTime', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]', NULL)
       ,(N'JsonSelect', N'FieldDate', N'@<Tag>_IsNull = r.[<Tag>_IsNull]', NULL)
       ,(N'JsonSelect', N'FieldDate', N'@<Tag>_ValueFrom = r.[<Tag>_ValueFrom]', NULL)
       ,(N'JsonSelect', N'FieldDate', N'@<Tag>_ValueTo = r.[<Tag>_ValueTo]', NULL)
       ,(N'JsonWith', N'FieldIdentifier', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''', NULL)
       ,(N'JsonWith', N'FieldIdentifier', N'[<Tag>_ValueFrom] bigint ''$.<Tag>.ValueFrom''', NULL)
       ,(N'JsonWith', N'FieldIdentifier', N'[<Tag>_ValueTo] bigint ''$.<Tag>.ValueTo''', NULL)
       ,(N'JsonWith', N'FieldLink', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''', NULL)
       ,(N'JsonWith', N'FieldLink', N'[<Tag>_Value] nvarchar(max) ''$.<Tag>.Value'' AS JSON', NULL)
       --,(N'JsonWith', N'FieldLinkToType', N'[<Tag>_Children] bit ''$.<Tag>.Children''', NULL)
       --,(N'JsonWith', N'FieldLinkToType', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''', NULL)
       --,(N'JsonWith', N'FieldLinkToType', N'[<Tag>_Value] nvarchar(max) ''$.<Tag>.Value'' AS JSON', NULL)
       ,(N'JsonWith', N'FieldString', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''', NULL)
       ,(N'JsonWith', N'FieldString', N'[<Tag>_Value] <DataType> ''$.<Tag>.Value''', NULL)
       ,(N'JsonWith', N'FieldBool', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''', NULL)
       ,(N'JsonWith', N'FieldBool', N'[<Tag>_Value] <DataType> ''$.<Tag>.Value''', NULL)
       ,(N'JsonWith', N'FieldInt', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''', NULL)
       ,(N'JsonWith', N'FieldInt', N'[<Tag>_ValueFrom] <DataType> ''$.<Tag>.ValueFrom''', NULL)
       ,(N'JsonWith', N'FieldInt', N'[<Tag>_ValueTo] <DataType> ''$.<Tag>.ValueTo''', NULL)
       ,(N'JsonWith', N'FieldBigint', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''', NULL)
       ,(N'JsonWith', N'FieldBigint', N'[<Tag>_ValueFrom] <DataType> ''$.<Tag>.ValueFrom''', NULL)
       ,(N'JsonWith', N'FieldBigint', N'[<Tag>_ValueTo] <DataType> ''$.<Tag>.ValueTo''', NULL)
       ,(N'JsonWith', N'FieldMoney', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''', NULL)
       ,(N'JsonWith', N'FieldMoney', N'[<Tag>_ValueFrom] <DataType> ''$.<Tag>.ValueFrom''', NULL)
       ,(N'JsonWith', N'FieldMoney', N'[<Tag>_ValueTo] <DataType> ''$.<Tag>.ValueTo''', NULL)
       ,(N'JsonWith', N'FieldFloat', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''', NULL)
       ,(N'JsonWith', N'FieldFloat', N'[<Tag>_ValueFrom] <DataType> ''$.<Tag>.ValueFrom''', NULL)
       ,(N'JsonWith', N'FieldFloat', N'[<Tag>_ValueTo] <DataType> ''$.<Tag>.ValueTo''', NULL)
       ,(N'JsonWith', N'FieldDatetime', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''', NULL)
       ,(N'JsonWith', N'FieldDatetime', N'[<Tag>_ValueFrom] <DataType> ''$.<Tag>.ValueFrom''', NULL)
       ,(N'JsonWith', N'FieldDatetime', N'[<Tag>_ValueTo] <DataType> ''$.<Tag>.ValueTo''', NULL)
       ,(N'JsonWith', N'FieldColor', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''', NULL)
       ,(N'JsonWith', N'FieldColor', N'[<Tag>_Value] [varchar](8) ''$.<Tag>.Value''', NULL)
       ,(N'JsonWith', N'FieldTime', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''', NULL)
       ,(N'JsonWith', N'FieldTime', N'[<Tag>_ValueFrom] <DataType> ''$.<Tag>.ValueFrom''', NULL)
       ,(N'JsonWith', N'FieldTime', N'[<Tag>_ValueTo] <DataType> ''$.<Tag>.ValueTo''', NULL)
       ,(N'JsonWith', N'FieldDate', N'[<Tag>_IsNull] bit ''$.<Tag>.IsNull''', NULL)
       ,(N'JsonWith', N'FieldDate', N'[<Tag>_ValueFrom] <DataType> ''$.<Tag>.ValueFrom''', NULL)
       ,(N'JsonWith', N'FieldDate', N'[<Tag>_ValueTo] <DataType> ''$.<Tag>.ValueTo''', NULL)
       ,(N'Filter', N'FieldIdentifier', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)', NULL)
       ,(N'Filter', N'FieldIdentifier', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)', NULL)
       ,(N'Filter', N'FieldIdentifier', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)', NULL)
       ,(N'Filter', N'FieldLink', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)', NULL)
       ,(N'Filter', N'FieldLink', N'AND (@<Tag>_Value IS NULL OR (ISJSON(@<Tag>_Value) = 1 AND EXISTS(SELECT 1 FROM OPENJSON(@<Tag>_Value) [_<Tag>_jsonarray] WHERE TRY_CAST([_<Tag>_jsonarray].value as bigint) = [<Source>].[<Column>])))', NULL)
       ,(N'Filter', N'FieldLinkToType', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)', NULL)
       ,(N'Filter', N'FieldLinkToType', N'AND (@<Tag>_Value IS NULL OR (ISJSON(@<Tag>_Value) = 1 AND EXISTS(SELECT 1 FROM OPENJSON(@<Tag>_Value) [_<Tag>_jsonarray] WHERE TRY_CAST([_<Tag>_jsonarray].value as bigint) = [<Source>].[<Column>])))', NULL)
       ,(N'Filter', N'FieldLinkToType', N'AND (@TypeID IS NULL OR EXISTS(SELECT 1 FROM dbo.DirectoryChildrenInline(@TypeID, ''Type'', 1) dci WHERE dci.ID = [<Source>].[<Column>]))', NULL)
       --,(N'Filter', N'FieldLinkToType', N'AND (@<Tag>_Value IS NULL OR (ISJSON(@<Tag>_Value) = 1', NULL)
       --,(N'Filter', N'FieldLinkToType', REPLICATE(N' ', @Tab) + N'AND ((@<Tag>_Children = 1 AND EXISTS(SELECT 1 FROM OPENJSON(@<Tag>_Value) <Tag>_jsonarray CROSS APPLY dbo.DirectoryChildrenInline(TRY_CAST(<Tag>_jsonarray.value as bigint), ''Type'', 1) dci WHERE dci.ID = [<Source>].[<Column>]))', NULL)
       --,(N'Filter', N'FieldLinkToType', REPLICATE(N' ', @Tab * 2) + N'OR (@<Tag>_Children = 0 AND EXISTS(SELECT 1 FROM OPENJSON(@<Tag>_Value) <Tag>_jsonarray WHERE TRY_CAST(<Tag>_jsonarray.value as bigint) = [<Source>].[<Column>])))))', NULL)
       ,(N'Filter', N'FieldString', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)', NULL)
       ,(N'Filter', N'FieldString', N'AND (@<Tag>_Value IS NULL OR [<Source>].[<Column>] LIKE @<Tag>_Value)', NULL)
       ,(N'Filter', N'FieldInt', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)', NULL)
       ,(N'Filter', N'FieldInt', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)', NULL)
       ,(N'Filter', N'FieldInt', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)', NULL)
       ,(N'Filter', N'FieldBigint', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)', NULL)
       ,(N'Filter', N'FieldBigint', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)', NULL)
       ,(N'Filter', N'FieldBigint', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)', NULL)
       ,(N'Filter', N'FieldBool', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)', NULL)
       ,(N'Filter', N'FieldBool', N'AND (@<Tag>_Value IS NULL OR [<Source>].[<Column>] = @<Tag>_Value)', NULL)
       ,(N'Filter', N'FieldMoney', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)', NULL)
       ,(N'Filter', N'FieldMoney', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)', NULL)
       ,(N'Filter', N'FieldMoney', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)', NULL)
       ,(N'Filter', N'FieldFloat', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)', NULL)
       ,(N'Filter', N'FieldFloat', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)', NULL)
       ,(N'Filter', N'FieldFloat', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)', NULL)
       ,(N'Filter', N'FieldDatetime', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)', NULL)
       ,(N'Filter', N'FieldDatetime', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)', NULL)
       ,(N'Filter', N'FieldDatetime', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)', NULL)
       ,(N'Filter', N'FieldColor', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)', NULL)
       ,(N'Filter', N'FieldColor', N'AND (@<Tag>_Value IS NULL OR [<Source>].[<Column>] LIKE @<Tag>_Value)', NULL)
       ,(N'Filter', N'FieldTime', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)', NULL)
       ,(N'Filter', N'FieldTime', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)', NULL)
       ,(N'Filter', N'FieldTime', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)', NULL)
       ,(N'Filter', N'FieldDate', N'AND (@<Tag>_IsNull IS NULL OR @<Tag>_IsNull = 0 OR [<Source>].[<Column>] IS NULL)', NULL)
       ,(N'Filter', N'FieldDate', N'AND (@<Tag>_ValueFrom IS NULL OR [<Source>].[<Column>] >= @<Tag>_ValueFrom)', NULL)
       ,(N'Filter', N'FieldDate', N'AND (@<Tag>_ValueTo IS NULL OR [<Source>].[<Column>] <= @<Tag>_ValueTo)', NULL);
       
    --заполняем таблицу владельцев
    WITH Sources AS
    (
        SELECT  --типы
            ot.ID
           ,CAST(CONCAT(N'[dbo].[T', d.Tag, N']') as nvarchar(512)) as [Owner]
           ,CAST(LOWER(d.Tag) as nvarchar(512)) as [Source]
           ,ot.Lvl as Lvl1
           ,CAST(0 as bigint) as Lvl2
           ,CAST(CASE ot.Lvl
                WHEN 0 THEN N'<Owner> [<Source>]'
                ELSE N'JOIN <Owner> [<Source>] ON [<Source>].[<Key>] = [<Main>].[<Key>]'
            END as nvarchar(512)) as Pattern
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
        SELECT  --источники для FieldLink
            f.ID
           ,CAST(N'[dbo].[ObjectInline]' as nvarchar(512)) as [Owner]
           ,CAST(LOWER(CONCAT(N'_', f.Tag, N'_Link')) as nvarchar(512)) as [Source]
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
        SELECT--источник для FieldLinkToType
            f.ID
           ,CAST(N'[dbo].[TType]' as nvarchar(512)) as [Owner]
           ,CAST(LOWER(CONCAT(N'_', f.Tag, N'_LinkToType')) as nvarchar(512)) as [Source]
           ,oo.Lvl1 as Lvl1
           ,ROW_NUMBER() OVER(ORDER BY f.[Order]) + 2000 as Lvl2
           ,CAST(CONCAT(N'OUTER APPLY (SELECT TOP (1) ri.Identifier, ri.TypeName, ri.TypeTag, ri.TypeIcon FROM [dbo].[RecordInline]([<Main>].[<Key>],[', oo.[Source], N'].[', f.[Column], N']) ri) [<Source>]') as nvarchar(512)) as Pattern
        FROM Sources oo
            JOIN @Fields f ON f.OwnerID = oo.ID
        WHERE EXISTS
            (
                SELECT 1
                FROM dbo.DirectoryChildrenInline(@TypeID_FieldLinkToType, N'Type', 1) rt
                WHERE rt.ID = f.TypeID
            )
        UNION ALL
        SELECT  --источники для FieldIdentifier если тип является наследником объекта
            f.ID
           ,CAST(ows.[Owner] as nvarchar(512)) as [Owner]
           ,CAST(ows.[Source] as nvarchar(512)) as [Source]
           ,oo.Lvl1 as Lvl1
           ,ROW_NUMBER() OVER(ORDER BY f.[Order]) + ows.Lvl2Modifier as Lvl2
           ,CAST(ows.Pattern as nvarchar(512)) as Pattern
        FROM Sources oo
            JOIN @Fields f ON f.OwnerID = oo.ID
            CROSS APPLY
            (
                SELECT
                    N'dbo.ObjectInline' as [Owner]
                   ,N'_object' as [Source]
                   ,1000 as Lvl2Modifier
                   ,CONCAT(N'OUTER APPLY <Owner>([', oo.[Source], N'].[', f.[Column], N']) [<Source>]') as Pattern
                UNION ALL 
                SELECT
                    N'dbo.ObjectTransitionListInline' as [Owner]
                   ,N'_transitions' as [Source]
                   ,1001 as Lvl2Modifier
                   ,CONCAT(N'OUTER APPLY (SELECT (SELECT tr.TransitionID, tr.TransitionName, tr.Description, tr.Color FROM <Owner>([', oo.[Source], N'].[', f.[Column], N']) tr FOR JSON PATH) as list) [<Source>]') as Pattern
            ) ows
        WHERE EXISTS
            (
                SELECT 1
                FROM dbo.DirectoryChildrenInline(@TypeID_FieldIdentifier, N'Type', 1) ft
                WHERE ft.ID = f.TypeID
            )
            AND EXISTS --тип является наследником объекта
            (
                SELECT 1
                FROM dbo.DirectoryOwnersInline(@ID, N'Type', 1) tot
                WHERE tot.ID = @TypeID_Object
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

    --переменные фильтров в параметрах
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
            )

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
                                           ,LOWER(CONCAT(N'_', f.Tag, N'_LinkToType')) 
                                        )
                                       ,N'<Link>'
                                       ,LOWER(CONCAT(N'_', f.Tag, N'_Link')) 
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
                               ,ISNULL(t.JsonGroup, f.[Order]) as Ord1 --JsonGroup используется для группировки полей в один Json объект
                               ,t.[Order] as Ord2
                            FROM @Fields f
                                JOIN @Sources o ON o.ID = f.OwnerID
                                CROSS APPLY dbo.DirectoryOwnersInline(f.TypeID, N'Type', 1) ot
                                JOIN dbo.TDirectory td ON td.ID = ot.ID
                                JOIN @Templates t ON t.FieldType = td.Tag
                                    AND (t.[Type] = N'Column' 
                                        OR (EXISTS(SELECT 1 FROM @Sources s WHERE s.Source = N'_object') AND t.[Type] = N'ColumnObject'))
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