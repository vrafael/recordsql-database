--liquibase formatted sql

--changeset vrafael:framework_20200614_Development_08_DevSwagger logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
--Список доступных процедур (методов) и их параметров в схемах Dev, Api, Auth
CREATE OR ALTER PROCEDURE [Dev].[Swagger]
AS
EXEC dbo.ContextProcedurePush
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON;
    
    DECLARE
        --@Environment dbo.string = dbo.ParameterValueByNamE(N'Environment')
        @StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')

    /*IF @Environment NOT IN (N'Development', N'Testing')
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SecurityError'
           ,@Message = N'Использование процедуры разршено только "Development" и "Testing" окружении'
    END*/

    SELECT
        CONCAT(ss.name, N'.', sp.name) as Method
       ,(
            SELECT
                RIGHT(spr.name, LEN(spr.name)-1) as [Name]
               ,st.name as [Type]
               --,spr.is_nullable as [IsNullable]
               --,spr.is_output as [IsOutput]
            FROM sys.parameters spr
                LEFT JOIN sys.types st ON st.system_type_id = spr.system_type_id
                    AND st.user_type_id = spr.user_type_id
            WHERE spr.object_id = sp.object_id
            ORDER BY spr.parameter_id
            FOR JSON PATH
        ) as Params
       ,dbd.[Description]
    FROM sys.procedures sp
        JOIN sys.schemas ss ON ss.schema_id = sp.schema_id
        LEFT JOIN dbo.TDataBaseObject db
            JOIN dbo.TObject odb ON odb.ID = db.ID
                AND odb.StateID = @StateID_Basic_Formed
            JOIN dbo.TDirectory dbd ON dbd.ID = odb.ID
        ON db.object_id = sp.object_id
    WHERE ss.name IN (N'Api', N'Dev', N'Auth')
        AND sp.is_ms_shipped = 0
    ORDER BY
        ss.name
       ,sp.name
    FOR JSON PATH
END
--EXEC Dev.Swagger
GO
EXEC dbo.DatabaseObjectDescription
    @ObjectName = N'Dev.Swagger'
   ,@Description = N'Список всех методов API с кратким описанием и списком параметров'