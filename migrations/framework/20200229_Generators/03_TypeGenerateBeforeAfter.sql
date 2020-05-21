--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_03_TypeGenerateBeforeAfter logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER TRIGGER [TypeGenerateBeforeAfter] ON DATABASE
FOR
    CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE, RENAME
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

    DECLARE
        @TypeID bigint
       ,@Generator dbo.string
       ,@GeneratorProcedureName dbo.string
        --EVENTDATA
       ,@ObjectType dbo.string
       ,@EventType dbo.string
       ,@SchemaName dbo.string
       ,@ObjectName dbo.string
       ,@ObjectNameNew dbo.string
    
    SELECT
        @ObjectType     = EVENTDATA().value(N'(/EVENT_INSTANCE/ObjectType)[1]', N'nvarchar(512)')
       ,@EventType      = EVENTDATA().value(N'(/EVENT_INSTANCE/EventType)[1]', N'nvarchar(512)')
       ,@SchemaName     = EVENTDATA().value(N'(/EVENT_INSTANCE/SchemaName)[1]', N'nvarchar(512)')
       ,@ObjectName     = EVENTDATA().value(N'(/EVENT_INSTANCE/ObjectName)[1]', N'nvarchar(512)')
       ,@ObjectNameNew  = EVENTDATA().value(N'(/EVENT_INSTANCE/NewObjectName)[1]', N'nvarchar(512)')

    IF (@SchemaName = N'dbo')
        AND (@ObjectType = N'PROCEDURE')
    BEGIN
        WHILE 1 = 1
        BEGIN
            SET @Generator =
                CASE
                    WHEN @ObjectName LIKE N'%Set%' THEN N'Set'
                    WHEN @ObjectName LIKE N'%Del%' THEN N'Del'
                    ELSE NULL
                END

            SET @GeneratorProcedureName = CONCAT(N'dbo.TypeFormGenerate', @Generator)

            IF @Generator IS NOT NULL 
            BEGIN
                SELECT TOP (1)
                    @TypeID = o.ID
                FROM dbo.TObject o
                    JOIN TDirectory d ON d.ID = o.ID
                    JOIN dbo.TType t ON t.ID = o.ID
                    JOIN dbo.TDirectory sd ON sd.ID = o.StateID
                        AND (sd.Tag = N'Formed')
                WHERE (@ObjectName IN (CONCAT(d.Tag, @Generator, N'After'), CONCAT(d.Tag, @Generator, N'Before')))
            
                IF @TypeID IS NOT NULL
                BEGIN
                    --перегенерируем все процедуры дочерних типов 
                    DECLARE CUR CURSOR LOCAL STATIC FORWARD_ONLY FOR
                        SELECT ct.ID
                        FROM dbo.DirectoryChildrenInline(@TypeID, N'Type', 1) ct
                            JOIN dbo.TObject o ON o.ID = ct.ID
                            JOIN dbo.TDirectory sd ON sd.ID = o.StateID
                                AND (sd.Tag = N'Formed')
                        ORDER BY ct.Lvl

                    OPEN CUR
                    FETCH NEXT FROM CUR INTO @TypeID

                    WHILE @@FETCH_STATUS = 0
                    BEGIN
                        EXEC @GeneratorProcedureName
                            @ID = @TypeID

                        FETCH NEXT FROM CUR INTO @TypeID
                    END

                    CLOSE CUR
                    DEALLOCATE CUR
                END
            END

            --для события переименования повторяем все с новым именем
            IF (@EventType = N'RENAME')
                AND(@ObjectName <> @ObjectNameNew)
            BEGIN
                SELECT
                    @TypeID = NULL
                   ,@ObjectName = @ObjectNameNew
            END
            ELSE
            BEGIN
                BREAK;
            END;
        END
    END
END
--DISABLE TRIGGER [TypeGenerateBeforeAfter] ON DATABASE
--ENABLE TRIGGER [TypeGenerateBeforeAfter] ON DATABASE