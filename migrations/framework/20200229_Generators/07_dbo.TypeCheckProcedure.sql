--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_07_dboTypeCheckProcedure logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- framework "RecordSQL" v2 (https://github.com/vrafael/recordsql-database) ---------
--проверка что для работы с указанным типом используется процедура правильного супертипа 
CREATE OR ALTER PROCEDURE dbo.[TypeCheckProcedure]
    @TypeID bigint
   ,@OwnerTypeID bigint = NULL
   ,@Operation dbo.string = NULL
AS
EXEC [dbo].[ContextProcedurePush]
    @ProcID = @@PROCID
BEGIN
    SET NOCOUNT ON
    
    DECLARE
        @ProcedureOwnerTypeID bigint

    IF @TypeID IS NULL
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не указан тип'
    END

    IF (@OwnerTypeID IS NULL)
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Не указан родительский тип'
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.DirectoryOwnersInline(@TypeID, N'Type', 1) pt
        WHERE pt.ID = @OwnerTypeID
    )
    BEGIN
        EXEC dbo.Error
            @TypeTag = N'SystemError'
           ,@Message = N'Тип ID=%s не является наследником типа ID=%s'
           ,@p0 = @TypeID
           ,@p1 = @OwnerTypeID;
    END

    SELECT @ProcedureOwnerTypeID = p.OwnerTypeID
    FROM dbo.TypeProcedureInline(@TypeID, @Operation) p

    IF @OwnerTypeID <> @ProcedureOwnerTypeID
    BEGIN
        EXEC dbo.Error
            @Message = N'Для операции "%s" экземпляра типа ID=%s должна использоваться соответствующая процедура родительского типа ID=%s вместо процедуры родительского типа ID=%s'
           ,@p0 = @Operation
           ,@p1 = @TypeID
           ,@p2 = @ProcedureOwnerTypeID
           ,@p3 = @OwnerTypeID
    END
END
GO