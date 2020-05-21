--liquibase formatted sql

--changeset vrafael:framework_20200221_04_dboTValue logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.TValue', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TValue
    (
        [ValueID] [dbo].[identifier] IDENTITY(1,1) NOT NULL,
        [TypeID] dbo.link NULL,
        [OwnerID] dbo.link NULL,
        [CaseID] dbo.link NULL,
        [Order] int NULL,
        CONSTRAINT PK_Value_ValueID PRIMARY KEY CLUSTERED
        (
            ValueID ASC
        )
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Value_OwnerID_TypeID_CaseID_Order')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_Value_OwnerID_TypeID_CaseID_Order] ON [dbo].[TValue]
    (
        [OwnerID] ASC,
        [TypeID] ASC,
        [CaseID] ASC,
        [Order] ASC
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Value_TypeID')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_Value_TypeID] ON [dbo].[TValue]
    (
        [TypeID] ASC
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Value_CaseID')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_Value_CaseID] ON [dbo].[TValue]
    (
        [CaseID] ASC
    )
END