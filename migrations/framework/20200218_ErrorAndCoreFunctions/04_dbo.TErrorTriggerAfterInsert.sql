--liquibase formatted sql

--changeset vrafael:framework_20200218_04_dboTErrorTriggerAfterInsert logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER TRIGGER [dbo].[TErrorTriggerAfterInsert]
ON [dbo].[TError]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @TypeID dbo.[link]
       ,@ProcedureID dbo.[link]
       ,@Message nvarchar(max)
       ,@MessageRaise nvarchar(max)
       ,@Nestlevel int
	   ,@Callstack nvarchar(max)
       ,@LoginID bigint --DELETE 

    SELECT
        @TypeID = ins.TypeID
       ,@LoginID = ins.LoginID --DELETE 
       ,@ProcedureID = ins.ProcedureID
       ,@Message = ins.[Message]
       ,@MessageRaise = ins.[Message]
       ,@Nestlevel = ins.Nestlevel
	   ,@Callstack = ins.Callstack
    FROM inserted ins;

    IF (@@ROWCOUNT > 1)
    BEGIN
        SELECT
            @TypeID = dbo.TypeIDByTag(N'SystemError')
           ,@Message = N'ERROR! Неправильное использование таблицы сброса ошибки'
    END

    SET @MessageRaise = CONCAT(@Message, CHAR(10), CHAR(10), N'Callstack:', CHAR(10), @Callstack) -- стек вызова процедур в конец сообщения

    RAISERROR (@MessageRaise, 16, 1);

    ROLLBACK TRAN;

    INSERT INTO dbo.TError
    (
        TypeID
       ,LoginID
       ,ProcedureID
       ,Moment
       ,[Message]
       ,Context
       ,Nestlevel
	   ,Callstack
    )
    VALUES
    (
        @TypeID
       ,@LoginID --IIF(SUSER_SNAME() = N'LoginAPI', ISNULL(dbo.ContextLoginApiID(), dbo.LoginSqlID()), dbo.LoginSqlID()) --TODO RESTORE
       ,@ProcedureID
       ,GETDATE()
       ,@Message
       ,@Nestlevel
	   ,@Callstack
    )
END
GO

ALTER TABLE [dbo].[TError] ENABLE TRIGGER [TErrorTriggerAfterInsert]
GO


