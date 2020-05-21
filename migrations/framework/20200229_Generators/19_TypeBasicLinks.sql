--liquibase formatted sql

--changeset vrafael:framework_20200229_Generators_19_TypeBasicLinks logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
DECLARE
    @TransitionID_Basic_Form bigint = dbo.DirectoryIDByOwner(N'Transition', N'Basic', N'Form')
   ,@TransitionID_Basic_Unform bigint = dbo.DirectoryIDByOwner(N'Transition', N'Basic', N'Unform')
   ,@TypeID_Type bigint = dbo.TypeIDByTag(N'Type')
   ,@StoredProcedureID_dbo_TypeForm bigint = dbo.DirectoryIDByOwner(N'StoredProcedure', N'dbo', N'TypeForm')
   ,@StoredProcedureID_dbo_TypeUnform bigint = dbo.DirectoryIDByOwner(N'StoredProcedure', N'dbo', N'TypeUnform')

--добавляем ссылку на переход Form 
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.OwnerID = @TransitionID_Basic_Form
        AND v.CaseID = @TypeID_Type
        AND l.LinkedID = @StoredProcedureID_dbo_TypeForm
)
BEGIN
    EXEC dbo.LinkSet
        @ValueID = NULL
       ,@TypeTag = N'LinkToStoredProcedureOnTransition'
       ,@OwnerID = @TransitionID_Basic_Form
       ,@CaseID = @TypeID_Type
       ,@Order = 1
       ,@LinkedID = @StoredProcedureID_dbo_TypeForm
END

--добавляем ссылку на переход Unform
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TValue v
        JOIN dbo.TLink l ON l.ValueID = v.ValueID
    WHERE v.OwnerID = @TransitionID_Basic_Unform
        AND v.CaseID = @TypeID_Type
        AND l.LinkedID = @StoredProcedureID_dbo_TypeUnform
)
BEGIN
    EXEC dbo.LinkSet
        @ValueID = NULL
       ,@TypeTag = N'LinkToStoredProcedureOnTransition'
       ,@OwnerID = @TransitionID_Basic_Unform
       ,@CaseID = @TypeID_Type
       ,@Order = 1
       ,@LinkedID = @StoredProcedureID_dbo_TypeUnform
END