--liquibase formatted sql

--changeset vrafael:framework_20200924_Modules_01_Module_Type logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
DECLARE 
    @TypeID_Module bigint = dbo.TypeIDByTag(N'Module')
   ,@TypeID_DirectoryType bigint = dbo.TypeIDByTag(N'DirectoryType')
   ,@TypeID_Directory bigint = dbo.TypeIDByTag(N'Directory')
   ,@FieldID_Type_Module bigint = dbo.DirectoryIDByOwner(N'Field', N'Type', N'Module')
   ,@StateID_Basic_Formed bigint = dbo.DirectoryIDByOwner(N'State', N'Basic', N'Formed')
   ,@FieldID_Object_Owner bigint = dbo.DirectoryIDByOwner(N'Field', N'Object', N'Owner')
   ,@TypeID_Type bigint = dbo.TypeIDByTag(N'Type')
   ,@TypeID_Relationship bigint = dbo.TypeIDByTag(N'Relationship')
   ,@TypeID bigint

IF @TypeID_Module IS NULL
BEGIN
    EXEC dbo.ObjectTypeSet
        @ID = @TypeID_Module OUTPUT
       ,@TypeID = @TypeID_DirectoryType
       ,@OwnerID = @TypeID_Directory
       ,@Name = N'Module'
       ,@Tag = N'Module'
       ,@Description = N'Hierarhical type groups'
       ,@Abstract = 0
       ,@Icon = N'las la-layer-group'
       ,@StateMachineID = NULL
END

IF dbo.ObjectStateTag(@TypeID_Module) IS NULL
BEGIN
    EXEC dbo.ObjectStatePush
        @ID = @TypeID_Module
       ,@StateTag = N'Formed'
END

IF @FieldID_Type_Module IS NULL
BEGIN
    EXEC dbo.FieldSet 
        @ID = @FieldID_Type_Module OUTPUT
       ,@TypeTag = N'FieldLink'
       ,@StateID = NULL
       ,@OwnerID = @TypeID_Type
       ,@Name = N'Module'
       ,@Tag = N'Module'
       ,@Description = NULL
       ,@Order = 2
END

IF dbo.ObjectStateTag(@FieldID_Type_Module) IS NULL
BEGIN
    EXEC dbo.ObjectStatePush
        @ID = @FieldID_Type_Module
       ,@StateTag = N'Formed'
END

--Type.Module=>ALL=>Module
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Type_Module
        AND l.CaseID IS NULL
        AND l.TargetID = @TypeID_Module
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Type_Module
       ,@CaseID = NULL
       ,@TargetID = @TypeID_Module
END

--Object.Owner=>Module=>Module
IF NOT EXISTS
(
    SELECT 1
    FROM dbo.TLink l
    WHERE l.TypeID = @TypeID_Relationship
        AND l.OwnerID = @FieldID_Object_Owner
        AND l.CaseID = @TypeID_Module
        AND l.TargetID = @TypeID_Module
)
BEGIN
    EXEC dbo.RelationshipSet
        @TypeID = @TypeID_Relationship
       ,@OwnerID = @FieldID_Object_Owner
       ,@CaseID = @TypeID_Module
       ,@TargetID = @TypeID_Module
END