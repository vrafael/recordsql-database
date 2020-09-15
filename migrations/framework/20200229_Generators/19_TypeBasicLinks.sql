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
    FROM dbo.TLink l
    WHERE l.OwnerID = @TransitionID_Basic_Form
        AND l.CaseID = @TypeID_Type
        AND l.TargetID = @StoredProcedureID_dbo_TypeForm
)
BEGIN
    EXEC dbo.LinkSet
        @LinkID = NULL
       ,@TypeTag = N'LinkToStoredProcedureOnTransition'
       ,@OwnerID = @TransitionID_Basic_Form
       ,@CaseID = @TypeID_Type
       ,@Order = 1
       ,@TargetID = @StoredProcedureID_dbo_TypeForm
END

--добавляем ссылку на переход Unform
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.OwnerID = @TransitionID_Basic_Unform
        AND l.CaseID = @TypeID_Type
        AND l.TargetID = @StoredProcedureID_dbo_TypeUnform
)
BEGIN
    EXEC dbo.LinkSet
        @LinkID = NULL
       ,@TypeTag = N'LinkToStoredProcedureOnTransition'
       ,@OwnerID = @TransitionID_Basic_Unform
       ,@TargetID = @StoredProcedureID_dbo_TypeUnform
       ,@CaseID = @TypeID_Type
       ,@Order = 1
END