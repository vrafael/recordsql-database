--liquibase formatted sql

--changeset vrafael:framework_20200218_06_dboDirectoryOwnersInline logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
CREATE OR ALTER FUNCTION [dbo].[DirectoryOwnersInline]
(
    @ID bigint
   ,@TypeTag dbo.string = NULL
   ,@WithSelf bit = NULL   --в выборку добавляем сам объект элемент
)
RETURNS TABLE
AS
RETURN
(
    WITH [Types] (ID) AS
    (
        SELECT TOP (1) 
            t.ID 
        FROM dbo.TDirectory d 
            JOIN dbo.TType t ON t.ID = d.ID
        WHERE d.[Tag] = @TypeTag
        UNION ALL
        SELECT
            o.ID as ID
        FROM [Types] c
            JOIN dbo.TObject o ON o.OwnerID = c.ID
            JOIN dbo.TType t ON t.ID = o.ID
    )
    ,[CTE] (ID, Lvl) AS   --Объекты
    (
        SELECT
            @ID         as ID
           ,0           as Lvl
        UNION ALL
        SELECT
            o.OwnerID   as ID
           ,c.Lvl + 1   as Lvl
        FROM [CTE] c
            JOIN dbo.TObject o ON o.ID = c.ID
        WHERE (o.OwnerID IS NOT NULL)
            AND EXISTS(SELECT 1 FROM [Types] t WHERE t.ID = o.TypeID)
    )
    SELECT
        c.ID
       ,c.Lvl
    FROM [CTE] c
    WHERE (c.ID IS NOT NULL)
        AND((@WithSelf = 1)OR(c.ID <> @ID))
)