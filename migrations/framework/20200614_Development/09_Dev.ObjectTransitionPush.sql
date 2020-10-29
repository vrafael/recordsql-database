--liquibase formatted sql

--changeset vrafael:framework_20200614_Development_09_DevObjectTransitionPush logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER PROCEDURE [Dev].[ObjectTransitionPush]
    @ID bigint
   ,@TransitionID bigint
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    EXEC dbo.ObjectTransitionPush
        @ID = @ID
       ,@TransitionID = @TransitionID
END
GO
EXEC dbo.DatabaseObjectDescription
    @ObjectName = N'Dev.ObjectTransitionPush'
   ,@Description = N'Вызов перехода объекта в другое состояние'