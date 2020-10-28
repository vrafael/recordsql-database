--liquibase formatted sql

--changeset vrafael:framework_20201026_ScriptGenerator_03_dboStateMachineScript logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
--генератор скрипта конечного автомата
CREATE OR ALTER PROCEDURE [dbo].[StateMachineScript]
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
        @Tab tinyint = 4
       ,@StateMachineScript nvarchar(max)
       ,@StateMachineVariable dbo.string
       ,@StateMachineVariableOutput dbo.string
       ,@TypeTag dbo.string
       ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
       ,@ChildScript nvarchar(max)
       ,@ChildID bigint
       ,@ChildOwnerTag dbo.string
       ,@ChildTypeTag dbo.string
       ,@ChildTag dbo.string
       ,@ChildVariable dbo.string
       ,@ChildVariableOutput dbo.string
       ,@TypeID_LinkToStoredProcedure bigint = dbo.TypeIDByTag(N'LinkToStoredProcedure')

    DECLARE
        @Children TABLE -- состояния и переходы
        (
            [ID] bigint NOT NULL
           ,[OwnerTag] dbo.string NULL
           ,[TypeTag] dbo.string NOT NULL
           ,[Tag] dbo.string NOT NULL
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


    SET @ID = ISNULL(@ID, dbo.DirectoryIDByTag(N'StateMachine', @Tag))

    IF @ID IS NULL
    BEGIN
        IF @Tag IS NULL
        BEGIN
            EXEC dbo.Error
                @Message = N'Не указан генерируемый конечный автомат'
        END
        ELSE 
        BEGIN
            EXEC dbo.Error
                @Message = N'Не найден конечный автомат для генерации по тегу "%s"'
               ,@p0 = @Tag
        END
    END  

    SELECT TOP (1)
        @Tag = d.Tag
       ,@TypeTag = td.Tag
       ,@StateMachineVariable = CONCAT(N'@', td.Tag, N'ID_', d.Tag)
       ,@StateMachineVariableOutput = CONCAT(N'@', td.Tag, N'ID_', d.Tag, N' OUTPUT')
       ,@Script = ISNULL(@Script, N'')
    FROM dbo.TObject o
        JOIN dbo.TDirectory d ON d.ID = o.ID
        JOIN dbo.TDirectory td ON td.ID = o.TypeID
    WHERE o.ID = @ID

    --заполняем таблицу с состояниями и переходами
    INSERT INTO @Children
    (
        [ID]
       ,[OwnerTag]
       ,[TypeTag]
       ,[Tag]
    )
    SELECT
        c.[ID]
       ,od.[Tag]
       ,c.[TypeTag]
       ,c.[Tag]
    FROM
        (
            SELECT DISTINCT
                s.[ID]
               ,s.[OwnerID]
               ,td.[Tag] as TypeTag
               ,s.[Tag]
               ,1 as [Order]
            FROM dbo.VTransition tr
                JOIN dbo.VState s
                    JOIN dbo.TDirectory td ON td.ID = s.TypeID
                ON (s.ID = tr.SourceStateID OR s.ID = tr.TargetStateID)
                    AND s.StateID = @StateID_Basic_Formed
            WHERE tr.OwnerID = @ID
                AND tr.StateID = @StateID_Basic_Formed
            UNION ALL
            SELECT DISTINCT
                tr.[ID]
               ,tr.[OwnerID]
               ,td.[Tag] as TypeTag
               ,tr.[Tag]
               ,2 as [Order]
            FROM dbo.VTransition tr
                JOIN dbo.TDirectory td ON td.ID = tr.TypeID
            WHERE tr.OwnerID = @ID
                AND tr.StateID = @StateID_Basic_Formed
        ) c
        JOIN dbo.TDirectory od ON od.ID = c.OwnerID
    ORDER BY
        c.[Order];

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
    FROM @Children c
        JOIN dbo.TLink l 
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
        ON l.OwnerID = c.ID
    WHERE
        EXISTS 
        (
            SELECT 1
            FROM dbo.DirectoryChildrenInline(@TypeID_LinkToStoredProcedure, N'Type', 1) dcl
            WHERE dcl.ID = l.TypeID
        )
    ORDER BY
        c.[Order]
       ,l.[Order]

    EXEC [dbo].[ObjectScript]
        @ID = @ID
       ,@FieldIdentifier = @StateMachineVariableOutput
       ,@Script = @StateMachineScript OUTPUT
       ,@TabStart = 1

    SELECT
        @Script += N'--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
----------- ' + @TypeTag + N' "' + @Tag + N'" -----------
DECLARE
    ' + @StateMachineVariable + N' bigint = dbo.DirectoryIDByTag(N''' + @TypeTag + N''', N''' + @Tag + N''') --' + @Tag

    IF EXISTS(SELECT 1 FROM @Children)
    BEGIN
        SELECT
            @Script +=
                (
                    SELECT
                        CONCAT(CHAR(13), CHAR(10), REPLICATE(N' ', @Tab - 1), N',@', c.TypeTag, N'ID_', IIF(c.OwnerTag IS NULL, c.Tag, CONCAT(c.OwnerTag, N'_', c.Tag)), N' bigint = '
                           ,IIF(c.OwnerTag IS NULL
                                ,CONCAT('dbo.DirectoryIDByTag(N''', c.TypeTag, N''', N''', c.Tag, N''')')
                                ,CONCAT('dbo.DirectoryIDByOwner(N''', c.TypeTag, N''', N''', c.OwnerTag, N''', N''', c.Tag, N''')'))
                           ,N' --', c.Tag)
                    FROM @Children c
                    FOR XML PATH(N'')
                )
    END

    SELECT
        @Script += N'

BEGIN TRAN

IF ' + @StateMachineVariable + N' IS NULL
BEGIN
' + @StateMachineScript + N'
END

'

    IF EXISTS(SELECT 1 FROM @Children)
    BEGIN
        SELECT
            @Script += N'----------- States and Transitions for state machine "' + @Tag + N'" -----------
'
        DECLARE cur CURSOR LOCAL STATIC FORWARD_ONLY FOR
            SELECT
                c.ID
               ,c.OwnerTag
               ,c.TypeTag
               ,c.Tag
            FROM @Children c
            ORDER BY
                c.[Order]
    
        OPEN cur
        FETCH NEXT FROM cur INTO @ChildID, @ChildOwnerTag, @ChildTypeTag, @ChildTag

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT 
                @ChildVariable = CONCAT(N'@', @ChildTypeTag, N'ID_', IIF(@ChildOwnerTag IS NULL, @ChildTag, CONCAT(@ChildOwnerTag, N'_', @ChildTag)))
               ,@ChildVariableOutput = CONCAT(N'@', @ChildTypeTag, N'ID_', IIF(@ChildOwnerTag IS NULL, @ChildTag, CONCAT(@ChildOwnerTag, N'_', @ChildTag)), N' OUTPUT')
               ,@ChildScript = NULL

            EXEC [dbo].[ObjectScript]
                @ID = @ChildID
               ,@FieldIdentifier = @ChildVariableOutput
               ,@Script = @ChildScript OUTPUT
               ,@TabStart = 1

            SELECT
                @Script += N'-- ' + @ChildTypeTag + N' "' + @ChildTag + N'"
IF ' + @ChildVariable + N' IS NULL
BEGIN
' + @ChildScript + N'
END

EXEC dbo.ObjectStatePush
    @ID = ' + @ChildVariable + N'
   ,@StateTag = N''Formed''

'
            FETCH NEXT FROM cur INTO @ChildID, @ChildOwnerTag, @ChildTypeTag, @ChildTag
        END

        CLOSE cur
        DEALLOCATE cur
    END

    IF EXISTS(SELECT 1 FROM @LinkToStoredProcedures)
    BEGIN
        SELECT
            @Script += N'----------- Links to procedures on ' + @TypeTag + N' "' + @Tag + N'" -----------
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
        @Script += N'COMMIT
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
--EXEC dbo.StateMachineScript @Tag = N'Session', @Print = 1
GO