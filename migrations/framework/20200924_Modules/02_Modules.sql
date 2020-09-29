--liquibase formatted sql

--changeset vrafael:framework_20200924_Modules_02_Modules logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
DECLARE 
    @TypeID_Module bigint = dbo.TypeIDByTag(N'Module')
   ,@OwnerTag nvarchar(512) 
   ,@Tag nvarchar(512)
   ,@Name nvarchar(512)
   ,@OwnerID bigint

DECLARE cur CURSOR LOCAL STATIC FORWARD_ONLY FOR
    SELECT
        m.OwnerTag
       ,m.Tag
       ,m.Name
    FROM
        (
            VALUES 
                (NULL, N'Subject', NULL)
               ,(NULL, N'Framework', NULL)
                   ,(N'Framework', N'Typization', NULL)
                   ,(N'Framework', N'StateMachine', N'State Machine')
                   ,(N'Framework', N'DataBase', NULL)
                   ,(N'Framework', N'ErrorHandling', N'Error handling')
                   ,(N'Framework', N'Security', NULL)
                   ,(N'Framework', N'Storage', NULL)
                   ,(N'Framework', N'History', NULL)
        ) m (OwnerTag, Tag, [Name])
    WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.TDirectory md
                JOIN dbo.TObject mo ON mo.ID = md.ID
                    AND mo.TypeID = @TypeID_Module
            WHERE md.Tag = m.Tag
        )
    ORDER BY m.OwnerTag

OPEN cur
FETCH NEXT FROM cur INTO
    @OwnerTag
   ,@Tag
   ,@Name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @OwnerID = IIF(@OwnerTag IS NULL, NULL, dbo.DirectoryIDByTag(N'Module', @OwnerTag))

    EXEC dbo.DirectorySet
        @TypeTag = N'Module'
       ,@OwnerID = @OwnerID
       ,@Name = @Name
       ,@Tag = @Tag
    
    FETCH NEXT FROM cur INTO
        @OwnerTag
       ,@Tag
       ,@Name
END

CLOSE cur
DEALLOCATE cur
