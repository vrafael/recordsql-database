--liquibase formatted sql

--changeset vrafael:framework_20200319_BeforeAfter_01_dboEventSetBefore logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [dbo].[EventSetBefore]
    @EventID bigint
   --,@LoginID bigint OUTPUT
   ,@Moment datetime2 OUTPUT
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    IF @EventID > 0
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Запрещено изменять событие EventID=%s'
           ,@p0 = @EventID
    END

    --ToDo добавить авторизация
    /*EXEC dbo.LoginCurrentGet
        @LoginID = @LoginID OUTPUT*/

    SET @Moment = GETDATE()
END
GO