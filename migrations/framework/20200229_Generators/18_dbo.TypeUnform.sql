--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_18_dboTypeUnform logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[TypeUnform]
    @ID bigint
   ,@TransitionID bigint = NULL
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @TypeTag dbo.string
       ,@ObjectName dbo.string
       ,@ChildTypeID bigint
       ,@Message nvarchar(2048)
       ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')

    --курсор по сформированным дочерним типам, начиная с нижних
    DECLARE CUR CURSOR LOCAL STATIC FORWARD_ONLY FOR
        SELECT t.ID
        FROM dbo.DirectoryChildrenInline(@ID, N'Type', 0) ct
            JOIN dbo.TObject o ON o.ID = ct.ID
            JOIN dbo.TType t ON t.ID = o.ID
        WHERE o.StateID = @StateID_Basic_Formed
        ORDER BY
            ct.Lvl DESC

    OPEN CUR
        
    BEGIN TRAN

    --расформировыывем дочерние типы
    FETCH NEXT FROM CUR INTO @ChildTypeID

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.ObjectStatePush
            @ID = @ChildTypeID

        FETCH NEXT FROM CUR INTO @ChildTypeID
    END

    CLOSE CUR
    DEALLOCATE CUR

    --удаляем скриптовые объекты
    BEGIN TRY
        SET @ObjectName = CONCAT(N'[dbo].[V', @TypeTag, N'Del]');
        IF OBJECT_ID(@ObjectName, N'TR') IS NOT NULL
        BEGIN
            EXEC(N'DROP TRIGGER ' + @ObjectName)
        END

        SET @ObjectName = CONCAT(N'[dbo].[V', @TypeTag, N'Set]');
        IF OBJECT_ID(@ObjectName, N'TR') IS NOT NULL
        BEGIN
            EXEC(N'DROP TRIGGER ' + @ObjectName)
        END

        SET @ObjectName = CONCAT(N'[dbo].[V', @TypeTag, N']');
        IF OBJECT_ID(@ObjectName, N'V') IS NOT NULL
        BEGIN
            EXEC(N'DROP VIEW ' + @ObjectName)
        END

        SET @ObjectName = CONCAT(N'[dbo].[', @TypeTag, N'Del]');
        IF OBJECT_ID(@ObjectName, N'P') IS NOT NULL
        BEGIN
            EXEC(N'DROP PROC ' + @ObjectName)
        END

        SET @ObjectName = CONCAT(N'[dbo].[', @TypeTag, N'Set]');
        IF OBJECT_ID(@ObjectName, N'P') IS NOT NULL
        BEGIN
            EXEC(N'DROP PROC ' + @ObjectName)
        END

        SET @ObjectName = CONCAT(N'[dbo].[', @TypeTag, N'Get]');
        IF OBJECT_ID(@ObjectName, N'P') IS NOT NULL
        BEGIN
            EXEC(N'DROP PROC ' + @ObjectName)
        END

        SET @ObjectName = CONCAT(N'[dbo].[', @TypeTag, N'Find]');
        IF OBJECT_ID(@ObjectName, N'P') IS NOT NULL
        BEGIN
            EXEC(N'DROP PROC ' + @ObjectName)
        END
    END TRY
    BEGIN CATCH
        IF XACT_STATE() = -1
        BEGIN
            ROLLBACK TRAN
        END

        SET @Message = ERROR_MESSAGE()

        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Ошибка удаления скриптового объекта "%s" привязанного к типу ID=%s ("%s"). Текст ошибки: %s'
           ,@p0 = @ObjectName
           ,@p1 = @ID
           ,@p2 = @TypeTag
           ,@p3 = @Message
    END CATCH

    COMMIT TRAN
END
GO