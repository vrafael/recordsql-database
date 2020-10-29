--liquibase formatted sql

--changeset vrafael:framework__ logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
--запись для генераторов
CREATE OR ALTER FUNCTION [dbo].[RecordInline]
(
    @Identifier bigint
   ,@TypeID bigint
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (1)
        @Identifier as [Identifier]
       ,ot.Name as TypeName
       ,dt.Tag as TypeTag
       ,tt.Icon as TypeIcon 
    FROM dbo.TObject ot
        JOIN dbo.TDirectory dt ON dt.ID = ot.ID 
        JOIN dbo.TType tt ON tt.ID = ot.ID
    WHERE ot.[ID] = @TypeID
)
GO