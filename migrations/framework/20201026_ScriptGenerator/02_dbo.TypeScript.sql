--liquibase formatted sql

--changeset vrafael:framework_20201026_ScriptGenerator_02_dboTypeScript logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
--генератор скрипта типа
CREATE OR ALTER PROCEDURE [dbo].[TypeScript]
    @ID bigint = NULL
   ,@Tag dbo.string = NULL
   ,@Script nvarchar(max) = N'' OUTPUT
   ,@Print bit = 0
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @TypeTag dbo.string
       ,@TypeVariable dbo.string
       ,@TypeScript nvarchar(max)
       ,@TypeVariableOutput dbo.string
       ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
       ,@FieldID bigint
       ,@FieldTag dbo.string
       ,@FieldScript nvarchar(max)
       ,@FieldVariable dbo.string
       ,@FieldVariableOutput dbo.string
       ,@FieldTypeTag dbo.string
       ,@Tab tinyint = 4
       ,@TypeID_Relationship bigint = dbo.TypeIDByTag(N'Relationship')
       ,@TypeID_LinkToStoredProcedure bigint = dbo.TypeIDByTag(N'LinkToStoredProcedure')

    DECLARE
        @Fields TABLE --поля
        (
            [ID] bigint NOT NULL
           ,[TypeTag] dbo.string NOT NULL
           ,[Tag] dbo.string NOT NULL
           ,[Order] bigint NOT NULL IDENTITY(1, 1)
        )

    DECLARE
        @Relationships TABLE
        (
            [FieldTypeTag] dbo.string NOT NULL
           ,[FieldOwnerTag] dbo.string NOT NULL
           ,[FieldTag] dbo.string NOT NULL
           ,[TargetTypeTag] dbo.string NOT NULL
           ,[CaseTypeTag] dbo.string NULL
           ,[Order] int NOT NULL IDENTITY(1, 1)
        )

    DECLARE
        @LinkToStoredProcedures TABLE
        (
            [TypeTag] dbo.string NOT NULL
           ,[OwnerTypeTag] dbo.string NOT NULL
           ,[OwnerOwnerTag] dbo.string NOT NULL
           ,[OwnerTag] dbo.string NOT NULL
           ,[ProcedureTypeTag] dbo.string NOT NULL
           ,[ProcedureOwnerTag] dbo.string NOT NULL
           ,[ProcedureTag] dbo.string NOT NULL
           ,[CaseTypeTag] dbo.string NULL
           ,[CaseTag] dbo.string NULL
           ,[Order] int NOT NULL IDENTITY(1, 1)
        )  

    SET @ID = ISNULL(@ID, dbo.TypeIDByTag(@Tag))

    IF @ID IS NULL
    BEGIN
        IF @Tag IS NULL
        BEGIN
            EXEC dbo.Error
                @Message = N'Не указан генерируемый тип'
        END
        ELSE 
        BEGIN
            EXEC dbo.Error
                @Message = N'Не найден тип для генерации по тегу "%s"'
               ,@p0 = @Tag
        END
    END
    
    SELECT TOP (1)
        @Tag = d.Tag
       ,@TypeTag = td.Tag
       ,@TypeVariable = CONCAT(N'@', td.Tag, N'ID_', d.Tag)
       ,@TypeVariableOutput = CONCAT(N'@', td.Tag, N'ID_', d.Tag, N' OUTPUT')
       ,@Script = ISNULL(@Script, N'')
    FROM dbo.TObject o
        JOIN dbo.TDirectory d ON d.ID = o.ID
        JOIN dbo.TDirectory td ON td.ID = o.TypeID
    WHERE o.ID = @ID

    --заполняем таблицу с полями
    INSERT INTO @Fields
    (
        [ID]
       ,[TypeTag]
       ,[Tag]
    )
    SELECT 
        fs.[ID]
       ,fs.[TypeTag]
       ,fs.[Tag]
    FROM dbo.FieldsByOwnerInline(@ID, 0) fs
    WHERE fs.StateID = @StateID_Basic_Formed
    ORDER BY
        fs.Lvl DESC
       ,fs.[Order]

    --заполняем таблицу отношений
    INSERT INTO @Relationships
    (
        [FieldTypeTag]
       ,[FieldOwnerTag]
       ,[FieldTag]
       ,[TargetTypeTag]
       ,[CaseTypeTag]
    )
    SELECT
        tfd.Tag as FieldTypeTag
       ,ofd.Tag as FieldOwnerTag
       ,fd.Tag as FieldTag
       ,tgd.Tag as TargetTypeTag
       ,csd.Tag as CaseTypeTag
    FROM dbo.FieldsByOwnerInline(@ID, 1) fs
        JOIN dbo.TLink l 
            JOIN dbo.TObject fo 
                JOIN dbo.TDirectory fd ON fd.ID = fo.ID
                JOIN dbo.TDirectory ofd ON ofd.ID = fo.OwnerID
                JOIN dbo.TDirectory tfd ON tfd.ID = fo.TypeID
            ON fo.ID = l.OwnerID 
            JOIN dbo.TDirectory tgd ON tgd.ID = l.TargetID
            LEFT JOIN dbo.TDirectory csd ON csd.ID = l.CaseID
        ON l.OwnerID = fs.ID
            AND l.TypeID = @TypeID_Relationship
            AND ((l.CaseID IS NULL AND fs.OwnerID = @ID)
                OR (l.CaseID = @ID))
    WHERE fs.StateID = @StateID_Basic_Formed
        AND fs.TypeTag = N'FieldLink'
    GROUP BY
        tfd.Tag
       ,ofd.Tag
       ,fd.Tag
       ,tgd.Tag
       ,csd.Tag
    ORDER BY
        MAX(fs.Lvl) DESC
       ,MAX(fs.[Order])
       ,MAX(l.[Order])

    --заполняем таблицу с ссылками на процедуры
    INSERT INTO @LinkToStoredProcedures
    (
        [TypeTag]
       ,[OwnerTypeTag]
       ,[OwnerOwnerTag]
       ,[OwnerTag]
       ,[ProcedureTypeTag]
       ,[ProcedureOwnerTag]
       ,[ProcedureTag]
       ,[CaseTypeTag]
       ,[CaseTag]
    )
    SELECT
        tl.Tag as [TypeTag]
       ,tod.Tag as [OwnerTypeTag]
       ,ood.Tag as [OwnerOwnerTag]
       ,od.Tag as [OwnerTag]
       ,tpd.Tag as [ProcedureTypeTag]
       ,opd.Tag as [ProcedureOwnerTag]
       ,pd.Tag as [ProcedureTag]
       ,tcd.Tag as [CaseTypeTag]
       ,cd.Tag as [CaseTag]
    FROM dbo.TLink l 
        JOIN dbo.TDirectory tl ON tl.ID = l.TypeID
        JOIN dbo.TObject oo 
            JOIN dbo.TDirectory od ON od.ID = oo.ID
            JOIN dbo.TDirectory ood ON ood.ID = oo.OwnerID
            JOIN dbo.TDirectory tod ON tod.ID = oo.TypeID
        ON oo.ID = l.OwnerID
        JOIN dbo.TObject po
            JOIN dbo.TDirectory pd ON pd.ID = po.ID
            JOIN dbo.TDirectory opd ON opd.ID = po.OwnerID
            JOIN dbo.TDirectory tpd ON tpd.ID = po.TypeID
        ON po.ID = l.TargetID
        JOIN dbo.TObject co
            JOIN dbo.TDirectory cd ON cd.ID = co.ID
            JOIN dbo.TDirectory tcd ON tcd.ID = co.TypeID 
        ON co.ID = l.CaseID
    WHERE l.CaseID = @ID
        AND EXISTS 
        (
            SELECT 1
            FROM dbo.DirectoryChildrenInline(@TypeID_LinkToStoredProcedure, N'Type', 1) dcl
            WHERE dcl.ID = l.TypeID
        )
    ORDER BY
        l.[Order]

    EXEC [dbo].[ObjectScript]
        @ID = @ID
       ,@FieldIdentifier = @TypeVariableOutput
       ,@Script = @TypeScript OUTPUT
       ,@TabStart = 1

    SELECT
        @Script = N'--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
----------- Type "' + @Tag + N'" -----------
DECLARE
    ' + @TypeVariable + N' bigint = dbo.TypeIDByTag(N''' + @Tag + N''') --' + @Tag

    IF EXISTS(SELECT 1 FROM @Fields)
    BEGIN
        SELECT
            @Script +=
                (
                    SELECT
                        CONCAT(CHAR(13), CHAR(10), REPLICATE(N' ', @Tab - 1), N',@', fs.TypeTag, N'ID_', fs.Tag, N' bigint = dbo.DirectoryIDByOwner(N''', fs.TypeTag, N''', N''', @Tag, N''', N''', fs.Tag, N''') --', fs.Tag)
                    FROM @Fields fs
                    ORDER BY fs.[Order]
                    FOR XML PATH(N'')
                )
    END

    SELECT
        @Script += N'

BEGIN TRAN

----------- Record of type "' + @Tag + N'" -----------
IF ' + @TypeVariable + N' IS NULL
BEGIN
' + @TypeScript + N'
END

'

    IF EXISTS(SELECT 1 FROM @Fields)
    BEGIN
        SELECT
            @Script += N'----------- Fields for type "' + @Tag + N'" -----------
'

        DECLARE CUR CURSOR LOCAL STATIC FORWARD_ONLY FOR
            SELECT
                fs.ID
               ,fs.Tag
               ,fs.TypeTag
            FROM @Fields fs 

        OPEN CUR
        FETCH NEXT FROM CUR INTO @FieldID, @FieldTag, @FieldTypeTag
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT 
                @FieldVariable = CONCAT(N'@', @FieldTypeTag, N'ID_', @FieldTag)
               ,@FieldVariableOutput = CONCAT(N'@', @FieldTypeTag, N'ID_', @FieldTag, N' OUTPUT')
               ,@FieldScript = NULL

            EXEC [dbo].[ObjectScript]
                @ID = @FieldID
               ,@FieldIdentifier = @FieldVariableOutput
               ,@Script = @FieldScript OUTPUT
               ,@TabStart = 1
        
            SELECT
                @Script += N'-- ' + @FieldTypeTag + N' "' + @FieldTag + N'"
IF ' + @FieldVariable + N' IS NULL
BEGIN
' + @FieldScript + N'
END

EXEC dbo.ObjectStatePush
    @ID = ' + @FieldVariable + N'
   ,@StateTag = N''Formed''

'
            FETCH NEXT FROM CUR INTO @FieldID, @FieldTag, @FieldTypeTag
        END
        
        CLOSE CUR
        DEALLOCATE CUR
    END

    IF EXISTS(SELECT 1 FROM @Relationships)
    BEGIN
        SELECT
            @Script += N'----------- Relations of type "' + @Tag + N'" -----------
DECLARE
    @TypeID_Relationship bigint = dbo.TypeIDByTag(N''Relationship'')
   ,@OwnerID bigint
   ,@TargetID bigint
   ,@CaseID bigint

DECLARE cur CURSOR LOCAL STATIC FORWARD_ONLY FOR
    SELECT
        rsp.OwnerID
       ,rsp.TargetID
       ,rsp.CaseID
    FROM 
        (
            VALUES'

        SELECT
            @Script += 
                (
                    SELECT
                        CONCAT(CHAR(13), CHAR(10), REPLICATE(N' ', 4 * @Tab - 1), IIF(ROW_NUMBER() OVER(ORDER BY rsp.[Order]) = 1, N' ', N',')
                           ,N'(dbo.DirectoryIDByOwner(N''', rsp.FieldTypeTag, N''', N''', rsp.FieldOwnerTag, N''', N''', rsp.FieldTag, N'''), '
                           ,N'dbo.TypeIDByTag(N''', rsp.TargetTypeTag, N'''), '
                           ,IIF(rsp.CaseTypeTag IS NULL, N'NULL', CONCAT(N'dbo.TypeIDByTag(N''', rsp.CaseTypeTag, N''')')), N')')
                    FROM @Relationships rsp
                    ORDER BY rsp.[Order]
                    FOR XML PATH(N'')
                )

        SELECT
            @Script += N'
        ) rsp ([OwnerID], [TargetID], [CaseID])
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [dbo].[TLink] l
        WHERE l.[TypeID] = @TypeID_Relationship
            AND l.[OwnerID] = rsp.[OwnerID]
            AND l.[TargetID] = rsp.[TargetID]
            AND ((l.CaseID IS NULL AND rsp.CaseID IS NULL) OR (l.[CaseID] = rsp.[CaseID]))
    )

OPEN cur
FETCH NEXT FROM cur INTO @OwnerID, @TargetID, @CaseID

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @OwnerID
       ,@TargetID = @TargetID
       ,@CaseID = @CaseID
    
    FETCH NEXT FROM cur INTO @OwnerID, @TargetID, @CaseID
END

CLOSE cur
DEALLOCATE cur

'
    END

IF EXISTS(SELECT 1 FROM @LinkToStoredProcedures)
    BEGIN
        SELECT
            @Script += N'----------- Links to procedures on basic form/unform of ' + @TypeTag + N' "' + @Tag + N'" -----------
DECLARE
    @LinkTypeID bigint
   ,@LinkOwnerID bigint
   ,@LinkStoredProcedureID bigint
   ,@LinkCaseID bigint

DECLARE cur CURSOR LOCAL STATIC FORWARD_ONLY FOR
    SELECT
        lsp.TypeID
       ,lsp.OwnerID
       ,lsp.TargetID
       ,lsp.CaseID
    FROM 
        (
            VALUES'

        SELECT
            @Script += 
                (
                    SELECT
                        CONCAT(CHAR(13), CHAR(10), REPLICATE(N' ', 4 * @Tab - 1), IIF(ROW_NUMBER() OVER(ORDER BY lsp.[Order]) = 1, N' ', N',')
                           ,N'(dbo.TypeIDByTag(N''', lsp.TypeTag, N'''), '
                           ,N'dbo.DirectoryIDByOwner(N''', lsp.OwnerTypeTag, N''', N''', lsp.OwnerOwnerTag, N''', N''', lsp.OwnerTag, N'''), '
                           ,N'dbo.DirectoryIDByOwner(N''', lsp.ProcedureTypeTag, N''', N''', lsp.ProcedureOwnerTag, N''', N''', lsp.ProcedureTag, N'''), '
                           ,N'dbo.DirectoryIDByTag(N''', lsp.CaseTypeTag, N''', N''', lsp.CaseTag, N'''))')
                    FROM @LinkToStoredProcedures lsp
                    ORDER BY lsp.[Order]
                    FOR XML PATH(N'')
                )

        SELECT
            @Script += N'
        ) lsp ([TypeID], [OwnerID], [TargetID], [CaseID])
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [dbo].[TLink] l
        WHERE l.[TypeID] = lsp.[TypeID]
            AND l.[OwnerID] = lsp.[OwnerID]
            AND l.[TargetID] = lsp.[TargetID]
            AND (l.[CaseID] = lsp.[CaseID])
    )

OPEN cur
FETCH NEXT FROM cur INTO @LinkTypeID, @LinkOwnerID, @LinkTargetID, @LinkCaseID

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC dbo.LinkSet
        @TypeID = @LinkTypeID
       ,@OwnerID = @LikOwnerID
       ,@TargetID = @LinkTargetID
       ,@CaseID = @LinkCaseID
    
    FETCH NEXT FROM cur INTO @LinkTypeID, @LinkOwnerID, @LinkTargetID, @LinkCaseID
END

CLOSE cur
DEALLOCATE cur

'
    END

    SELECT
        @Script += N'----------- Form type "' + @Tag + N'" -----------
EXEC dbo.ObjectStatePush
    @ID = ' + @TypeVariable + N'
   ,@StateTag = N''Formed''

COMMIT
-- generated by ' + CONVERT(nvarchar(512), GETDATE(), 121) + N' at ' + DB_NAME() + N'
'

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
--EXEC dbo.TypeScript @Tag = N'Type', @Print = 1
GO