--liquibase formatted sql

--changeset vrafael:framework_20200317_BeforeAfter_01_dboFieldIdentifierSetBefore logicalFilePath:path-independent splitStatements:true endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-db) ---------
CREATE OR ALTER PROCEDURE [dbo].[FieldIdentifierSetBefore]
    @ID bigint
   ,@TypeID bigint
   ,@OwnerID bigint
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON

    DECLARE
        @ExistFieldIdentifierID bigint

    --может быть только один идентификатор на типе верхнего уровня
    IF EXISTS
    (
        SELECT 1
        FROM dbo.TDirectory d
        WHERE d.ID = @OwnerID
            AND d.OwnerID IS NOT NULL
    )
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Владелец ID=%s поля типа ID=%s должен располагаться на верхнем уровне'
           ,@p0 = @OwnerID
           ,@p1 = @TypeID
    END

    SELECT TOP (1)
        @ExistFieldIdentifierID = o.ID
    FROM dbo.TObject o
        JOIN dbo.TDirectory d ON d.ID = o.ID
    WHERE d.OwnerID = @OwnerID
        AND (@ID IS NULL OR o.ID <> @ID)
        AND o.TypeID = @TypeID
        
    IF @ExistFieldIdentifierID IS NOT NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Владелец ID=%s уже имеет ID=%s типа ID=%s'
           ,@p0 = @OwnerID
           ,@p1 = @ExistFieldIdentifierID
           ,@p2 = @TypeID
    END
END
GO