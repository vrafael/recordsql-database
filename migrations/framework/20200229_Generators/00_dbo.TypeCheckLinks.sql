--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_00_dboTypeCheckLinks logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
--проверка группы ссылок - заглушка
CREATE OR ALTER PROCEDURE [dbo].[TypeCheckLinks]
    @ID dbo.link
   ,@TypeID dbo.link
   ,@FieldLinks dbo.listKeyValue READONLY
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;

END