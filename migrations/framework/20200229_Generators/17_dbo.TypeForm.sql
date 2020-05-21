--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_17_dboTypeForm logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[TypeForm]
    @ID bigint
   ,@TransitionID bigint = NULL
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @FieldIdentifierID bigint
       ,@FieldIdentifierStateID bigint
       ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
       ,@ProcedureID bigint
       ,@ProcedureName dbo.string
       ,@Message nvarchar(2048)

    IF EXISTS --тип верхнего уровня
    (
        SELECT 1
        FROM dbo.TDirectory d
        WHERE d.ID = @ID
            AND d.OwnerID IS NULL
    )
    BEGIN
        SELECT TOP (1)
            @FieldIdentifierID = f.ID
           ,@FieldIdentifierStateID = f.StateID
        FROM dbo.FieldsByOwnerInline(@ID, 1) f
        WHERE f.TypeTag = N'FieldIdentifier'

        IF @FieldIdentifierID IS NULL
        BEGIN
            EXEC dbo.Error
                @Message = N'Отсутствует идентификатор типа верхнего уровня ID=%s'
               ,@p0 = @ID
        END
        ELSE IF @FieldIdentifierStateID <> @StateID_Basic_Formed
        BEGIN
            EXEC dbo.Error
                @Message = N'Идентификатор ID=%s типа верхнего уровня ID=%s должен быть в состоянии ID=%s'
                ,@p0 = @FieldIdentifierID
                ,@p1 = @ID
                ,@p2 = @StateID_Basic_Formed
        END
    END 
    ELSE IF EXISTS
    (
        SELECT 1
        FROM dbo.DirectoryOwnersInline(@ID, N'Type', 0) ot
            JOIN dbo.TObject o ON o.ID = ot.ID
        WHERE o.StateID IS NULL
    )
    BEGIN
        EXEC dbo.Error
            @Message = N'Все родительские типы ID=%s должны быть в состоянии ID=%s'
           ,@p0 = @ID
           ,@p1 = @StateID_Basic_Formed
    END

    DECLARE CUR CURSOR LOCAL STATIC FORWARD_ONLY FOR
        SELECT
            dbo.DirectoryIDByOwner(N'StoredProcedure', N'dbo', pr.ProcedureName) as ProcedureID
           ,CONCAT('[dbo].[',pr.ProcedureName, ']') as ProcedureName
        FROM 
            (
                VALUES
                    (N'TypeFormGenerateTable', 1)
                   ,(N'TypeFormGenerateView', 2)
                   ,(N'TypeFormGenerateGet', 3)
                   ,(N'TypeFormGenerateFind', 3)
                   ,(N'TypeFormGenerateSet', 5)
                   ,(N'TypeFormGenerateDel', 6)
                   ,(N'TypeFormGenerateViewSet', 7) --ToDo
                   ,(N'TypeFormGenerateViewDel', 8) --ToDo
            ) pr ([ProcedureName], [Order])
        ORDER BY 
            pr.[Order]

    OPEN CUR
    FETCH NEXT FROM CUR INTO @ProcedureID, @ProcedureName

    BEGIN TRAN

    BEGIN TRY
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC @ProcedureName
                @ID = @ID

            FETCH NEXT FROM CUR INTO @ProcedureID, @ProcedureName
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
           ,@Message = N'Ошибка генерации скриптового объекта процедурой ID=%s ("%s") для типа ID=%s. Текст ошибки: %s'
           ,@p0 = @ProcedureID
           ,@p1 = @ProcedureName
           ,@p2 = @ID
           ,@p3 = @Message
    END CATCH
       
    CLOSE CUR
    DEALLOCATE CUR

    COMMIT TRAN
END
--EXEC dbo.TypeForm @ID = 3