--liquibase formatted sql

--changeset vrafael:framework_20200317_BeforeAfter_01_dboErrorSetBefore logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[ErrorSetBefore]
    @ErrorID bigint
   ,@Message nvarchar(max)
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    SET @ErrorID = IIF(@ErrorID > 0, @ErrorID, NULL)

    IF @ErrorID IS NOT NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SecurityError'
           ,@Message = N'Запрещено изменять зарегистрированную ошибку ErrorID=%s'
           ,@p0 = @ErrorID  
    END

    IF NULLIF(LTRIM(RTRIM(@Message)), N'') IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не указан текст сообщения об ошибке'
    END
END
GO