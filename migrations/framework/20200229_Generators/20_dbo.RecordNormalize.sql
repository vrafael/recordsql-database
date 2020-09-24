--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_20_dboRecordNormalize logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
--нормализация базы данных одним скриптом
CREATE OR ALTER PROCEDURE [dbo].[RecordNormalize]
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE 
        @StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
       ,@TypeID_StoredProcedure bigint = dbo.TypeIDByTag(N'StoredProcedure')
       ,@TypeID_InlineFunction bigint = dbo.TypeIDByTag(N'InlineFunction')
       ,@TypeID_ScalarFunction bigint = dbo.TypeIDByTag(N'ScalarFunction')
       ,@TypeID_TableFunction bigint = dbo.TypeIDByTag(N'TableFunction')
       ,@TypeID_Table bigint = dbo.TypeIDByTag(N'Table')
       ,@TypeID_View bigint = dbo.TypeIDByTag(N'View')
       --cur_database_objects
       ,@ID bigint
       ,@StateID bigint
       ,@TypeID bigint
       ,@ObjectName dbo.string
       ,@OwnerID bigint
       ,@OwnerTag dbo.string
       ,@ObjectTag dbo.string
       ,@Description nvarchar(max)
       ,@object_id int
       ,@object_id_new int
       ,@Script nvarchar(max);

    --переформировываем все сформированные типы
    DECLARE cur_form_types CURSOR LOCAL STATIC FORWARD_ONLY FOR
        WITH Tree AS
        (
            SELECT
                o.ID
               ,o.OwnerID
               ,0 as Lvl
            FROM dbo.TObject o
                JOIN dbo.TType t ON t.ID = o.ID
            WHERE (o.OwnerID IS NULL)
            UNION ALL
            SELECT
                o.ID
               ,o.OwnerID
               ,c.Lvl + 1 as Lvl
            FROM [Tree] c
                JOIN dbo.TObject o ON o.OwnerID = c.ID
                JOIN dbo.TType t ON t.ID = o.ID
        )
        SELECT
            tr.ID
        FROM Tree tr 
            JOIN dbo.TObject o ON o.ID = tr.ID 
                AND o.StateID = @StateID_Basic_Formed
        ORDER BY
            tr.Lvl --в порядке наследования

    DECLARE cur_database_objects CURSOR LOCAL STATIC FORWARD_ONLY FOR
        WITH TypeMapping AS 
        (
            SELECT
                dot.TypeID
               ,dot.type_desc
            FROM 
            (
                VALUES
                    (@TypeID_StoredProcedure, N'SQL_STORED_PROCEDURE')
                   ,(@TypeID_InlineFunction, N'SQL_INLINE_TABLE_VALUED_FUNCTION')
                   ,(@TypeID_ScalarFunction, N'SQL_SCALAR_FUNCTION')
                   ,(@TypeID_TableFunction, N'SQL_TABLE_VALUED_FUNCTION')
                   ,(@TypeID_Table, N'USER_TABLE')
                   ,(@TypeID_View, N'VIEW')
            ) dot (TypeID, [type_desc])
        )
        SELECT
            do.ID
           ,do.StateID
           ,tm.TypeID
           ,CONCAT(ss.name, N'.', so.[name]) as [ObjectName]
           ,ss.[name] as OwnerTag
           ,so.[name] as ObjectTag
           ,do.[Description]
           ,do.object_id
           ,so.object_id as object_id_new
           ,asm.[definition] as Script
        FROM sys.objects so
            JOIN TypeMapping tm ON tm.[type_desc] = so.type_desc
            JOIN sys.schemas ss ON ss.schema_id = so.schema_id
            LEFT JOIN sys.all_sql_modules asm ON asm.object_id = so.object_id
            FULL OUTER JOIN
            (
                SELECT
                    o.ID
                   ,o.StateID
                   ,o.TypeID
                   ,o.OwnerID
                   ,od.[Tag] as OwnerTag 
                   ,d.[Tag] as ObjectTag
                   ,d.[Description]
                   ,do.object_id
                FROM dbo.TObject o
                    JOIN dbo.TDirectory d ON d.ID = o.ID
                    JOIN dbo.TDatabaseObject do ON do.ID = d.ID
                    JOIN dbo.TDirectory od ON od.ID = o.OwnerID
                WHERE EXISTS
                    (
                        SELECT 1
                        FROM TypeMapping tps
                        WHERE tps.TypeID = o.TypeID
                    )
            ) do ON do.ObjectTag = so.[name]
                AND do.OwnerTag = ss.[name]
                AND do.TypeID = tm.TypeID
        WHERE so.is_ms_shipped = 0
            AND so.name <> N'database_firewall_rules'

    OPEN cur_form_types;
    OPEN cur_database_objects;
            
    BEGIN TRAN

    --отключение триггеров
    EXEC (N'DISABLE TRIGGER [TypeGenerateBeforeAfter] ON DATABASE')
    EXEC (N'DISABLE TRIGGER [DatabaseObjectChange] ON DATABASE')

    --перегенерирум сформированные типы
    FETCH NEXT FROM cur_form_types INTO @ID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.TypeForm
            @ID = @ID

        FETCH NEXT FROM cur_form_types INTO @ID;
    END;

    --обновляем объекты базы данных
    FETCH NEXT FROM cur_database_objects INTO
        @ID
       ,@StateID
       ,@TypeID
       ,@ObjectName
       ,@OwnerTag
       ,@ObjectTag
       ,@Description
       ,@object_id
       ,@object_id_new
       ,@Script

    WHILE @@FETCH_STATUS = 0
    BEGIN
        --db+ obj-: add 
        IF @ID IS NULL --объект не зарегистрирован
        BEGIN
            SET @OwnerID = dbo.DirectoryIDByTag(N'Schema', @OwnerTag)

            IF @OwnerID IS NULL
            BEGIN
                EXEC dbo.DatabaseObjectSet
                    @ID = @OwnerID OUTPUT
                   ,@TypeTag = @OwnerTag
                   ,@Name = @OwnerTag
                   ,@Tag = @OwnerTag
                   ,@Description = @Description
            END

            EXEC dbo.DatabaseObjectSet
                @ID = @ID OUTPUT
               ,@TypeID = @TypeID
               ,@OwnerID = @OwnerID
               ,@Name = @ObjectName
               ,@Tag = @ObjectTag
               ,@Description = @Description
               ,@object_id = @object_id_new
               ,@Script = @Script

            EXEC dbo.ObjectStatePush
                @ID = @ID
               ,@StateID = @StateID_Basic_Formed
        END
        --db- obj+: state=null, oid=null
        ELSE IF @object_id_new IS NULL
        BEGIN
            EXEC dbo.ObjectStatePush
                @ID = @ID
        END
        ELSE
        --db+ obj+
        BEGIN
            IF @object_id <> @object_id_new
            BEGIN
                EXEC dbo.DatabaseObjectSet
                    @ID = @ID OUTPUT
                   ,@TypeID = @TypeID
                   ,@OwnerID = @OwnerID
                   ,@Name = @ObjectName
                   ,@Tag = @ObjectTag
                   ,@Description = @Description
                   ,@object_id = @object_id_new
                   ,@Script = @Script
            END

            IF @StateID IS NULL
            BEGIN
                EXEC dbo.ObjectStatePush
                    @ID = @ID
                   ,@StateID = @StateID_Basic_Formed
            END 
        END

        FETCH NEXT FROM cur_database_objects INTO 
            @ID
           ,@StateID
           ,@TypeID
           ,@ObjectName
           ,@OwnerTag
           ,@ObjectTag
           ,@Description
           ,@object_id
           ,@object_id_new
           ,@Script
    END;

    --включение триггеров
    EXEC (N'ENABLE TRIGGER [TypeGenerateBeforeAfter] ON DATABASE')
    EXEC (N'ENABLE TRIGGER [DatabaseObjectChange] ON DATABASE')

    COMMIT

    CLOSE cur_form_types;
    DEALLOCATE cur_form_types;

    CLOSE cur_database_objects;
    DEALLOCATE cur_database_objects;
END
--EXEC dbo.RecordNormalize
GO