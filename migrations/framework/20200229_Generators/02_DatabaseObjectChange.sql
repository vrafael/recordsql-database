--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_02_DatabaseObjectChange logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--DDL триггер уровня базы данных
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER TRIGGER [DatabaseObjectChange] ON DATABASE
FOR
    CREATE_TABLE, ALTER_TABLE, DROP_TABLE,
    CREATE_VIEW, ALTER_VIEW, DROP_VIEW,
    CREATE_FUNCTION, ALTER_FUNCTION, DROP_FUNCTION,
    CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE, RENAME
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

    DECLARE
        @SchemaID bigint
       ,@TypeTag dbo.string
       ,@OBJECT_ID int
       ,@OBJECT_ID_New int
       ,@ObjectID bigint
       ,@ObjectIDNew bigint
       ,@TypeID_Link bigint = dbo.TypeIDByTag(N'Link')
       ,@Name dbo.string
        --EVENTDATA
       ,@SPID int
       ,@EventType dbo.string
       ,@ObjectType dbo.string
       ,@SchemaName dbo.string
       ,@ObjectName dbo.string
       ,@ObjectNameNew dbo.string
       ,@Script nvarchar(max)
       --Link
       ,@CurLinkID bigint
       ,@CurTypeID bigint
       ,@CurOwnerID bigint
       ,@CurCaseID bigint
       ,@CurOrder bigint

    IF @@ERROR <> 0
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Ошибка при обработке DDL события'
    END

    SELECT
        @SPID           = EVENTDATA().value(N'(/EVENT_INSTANCE/SPID)[1]', N'int')
       ,@EventType      = EVENTDATA().value(N'(/EVENT_INSTANCE/EventType)[1]', N'nvarchar(512)')
       ,@ObjectType     = EVENTDATA().value(N'(/EVENT_INSTANCE/ObjectType)[1]', N'nvarchar(512)')
       ,@SchemaName     = EVENTDATA().value(N'(/EVENT_INSTANCE/SchemaName)[1]', N'nvarchar(512)')
       ,@ObjectName     = EVENTDATA().value(N'(/EVENT_INSTANCE/ObjectName)[1]', N'nvarchar(512)')
       ,@ObjectNameNew  = EVENTDATA().value(N'(/EVENT_INSTANCE/NewObjectName)[1]', N'nvarchar(512)')
       ,@Script         = EVENTDATA().value(N'(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', N'nvarchar(max)')

    IF (@ObjectType IN (N'PROCEDURE', N'FUNCTION', N'TABLE', N'VIEW'))
    BEGIN
        SELECT
            @SchemaID = dbo.DirectoryIDByTag(N'Schema', @SchemaName)
           ,@OBJECT_ID = OBJECT_ID(CONCAT(N'[', @SchemaName, N'].[', @ObjectName, N']'))
           ,@OBJECT_ID_New = OBJECT_ID(CONCAT(N'[', @SchemaName, N'].[', @ObjectNameNew, N']'))
           ,@Name = CONCAT(@SchemaName, N'.', ISNULL(@ObjectNameNew, @ObjectName))

        SELECT
            @TypeTag =
                CASE so.[type_desc]
                    WHEN N'SQL_STORED_PROCEDURE' THEN N'StoredProcedure'
                    WHEN N'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN N'InlineFunction'
                    WHEN N'SQL_SCALAR_FUNCTION' THEN N'ScalarFunction'
                    WHEN N'SQL_TABLE_VALUED_FUNCTION' THEN N'TableFunction'
                    WHEN N'USER_TABLE' THEN N'Table'
                    WHEN N'VIEW' THEN N'View'
                    ELSE NULL
                END
        FROM sys.objects so
        WHERE so.[object_id] = ISNULL(@OBJECT_ID, @OBJECT_ID_New);

        IF @TypeTag IS NULL
        BEGIN
            SELECT @TypeTag =
                CASE
                    WHEN @EventType LIKE N'%PROCEDURE' THEN N'StoredProcedure'
                    WHEN @EventType LIKE N'%FUNCTION' THEN  N'Function'
                    WHEN @EventType LIKE N'%TABLE' THEN N'Table'
                    WHEN @EventType LIKE N'%VIEW' THEN N'View'
                END
        END

        BEGIN TRAN

        IF @SchemaID IS NULL
        BEGIN
            EXEC dbo.SchemaSet
	            @ID = @SchemaID OUTPUT
	           ,@TypeTag = N'Schema'
	           ,@Name = @SchemaName
	           ,@Tag = @SchemaName
        END
        ELSE
        BEGIN
            SELECT
                @ObjectID = dbo.DirectoryIDByOwner(@TypeTag, @SchemaName, @ObjectName)
               ,@ObjectIDNew = dbo.DirectoryIDByOwner(@TypeTag, @SchemaName, @ObjectNameNew)
        END

        IF (@EventType LIKE N'CREATE%')
            OR (@EventType LIKE N'ALTER%')
        BEGIN
            EXEC dbo.DatabaseObjectSet
                @ID = @ObjectID OUTPUT
               ,@Name = @Name    
               ,@TypeTag = @TypeTag
               ,@OwnerID = @SchemaID
               ,@Tag = @ObjectName
               ,@object_id = @OBJECT_ID
               ,@Script = @Script

            EXEC dbo.ObjectStatePush
	            @ID = @ObjectID
	           ,@StateTag = N'Formed'
        END
         ELSE IF (@EventType LIKE N'DROP%')
            OR (@EventType = N'RENAME')
        BEGIN
            IF (@ObjectID IS NOT NULL)
            BEGIN
                EXEC dbo.ObjectStatePush
	                @ID = @ObjectID
            END

            IF (@EventType = N'RENAME')
            BEGIN
                EXEC dbo.DatabaseObjectSet
                    @ID = @ObjectIDNew OUT
                   ,@Name = @Name
                   ,@TypeTag = @TypeTag
                   ,@OwnerID = @SchemaID
                   ,@Tag = @ObjectNameNew
                   ,@object_id = @OBJECT_ID_New
                   ,@Script = @Script

                EXEC dbo.ObjectStatePush
	                @ID = @ObjectIDNew
	               ,@StateTag = N'Formed'

                --при переименовании объекта перебиваем ссылки со старого объекта на новый
                IF @ObjectID IS NOT NULL
                BEGIN
                    --------------ReLink---------------
                    DECLARE REFCUR CURSOR LOCAL STATIC FORWARD_ONLY FOR
                        SELECT
                            l.LinkID
                           ,l.TypeID
                           ,l.OwnerID
                           ,l.CaseID
                           ,l.[Order]
                        FROM dbo.DirectoryChildrenInline(@TypeID_Link, N'Type', 0) ct
                            JOIN dbo.TLink l ON l.TargetID = @ObjectID
                    
                    OPEN REFCUR
                    FETCH NEXT FROM REFCUR INTO @CurLinkID, @CurTypeID, @CurOwnerID, @CurCaseID, @CurOrder
                    
                    WHILE @@FETCH_STATUS = 0
                    BEGIN
                        EXEC dbo.LinkSet
                            @LinkID = @CurLinkID
                           ,@TypeID = @CurTypeID
                           ,@OwnerID = @CurOwnerID
                           ,@CaseID = @CurCaseID
                           ,@Order = @CurOrder
                           ,@TargetID = @ObjectIDNew
                        
                        FETCH NEXT FROM REFCUR INTO @CurLinkID, @CurTypeID, @CurOwnerID, @CurCaseID, @CurOrder
                    END
                    
                    CLOSE REFCUR
                    DEALLOCATE REFCUR
                    --------------ReLink---------------
                END
            END
        END
        
        COMMIT TRAN
    END
END
--DISABLE TRIGGER [DatabaseObjectChange] ON DATABASE 
--ENABLE TRIGGER [DatabaseObjectChange] ON DATABASE 