--liquibase formatted sql

--changeset vrafael:framework_20200221_04_dboTLink logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.TLink', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TLink
    (
        [LinkID] [dbo].[identifier] IDENTITY(1,1) NOT NULL,
        [TypeID] dbo.link NULL,
        [OwnerID] dbo.link NULL,
        [TargetID] dbo.link NULL,
        [CaseID] dbo.link NULL,
        [Order] int NULL,
        CONSTRAINT PK_Link_LinkID PRIMARY KEY CLUSTERED
        (
            LinkID ASC
        )
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Link_OwnerID_TypeID_CaseID_Order')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_Link_OwnerID_TypeID_CaseID_Order] ON [dbo].[TLink]
    (
        [OwnerID] ASC,
        [TypeID] ASC,
        [CaseID] ASC,
        [Order] ASC
    )
    INCLUDE
    (
        TargetID
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Link_TypeID_OwnerID_CaseID_Order')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_Link_TypeID_OwnerID_CaseID_Order] ON [dbo].[TLink]
    (
        [TypeID] ASC,
        [OwnerID] ASC, 
        [CaseID] ASC,
        [Order] ASC
    )
    INCLUDE
    (
        TargetID
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Link_TargetID')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_Link_TargetID] ON [dbo].[TLink]
    (
        [TargetID] ASC
    )
END