--liquibase formatted sql

--changeset vrafael:framework_20200221_07_dboTEvent logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.TEvent', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TEvent
    (
        [EventID] [dbo].[identifier] IDENTITY(1,1) NOT NULL,
        [TypeID] dbo.link NULL,
        [ObjectID] dbo.link NULL,
        [LoginID] dbo.link NULL,
        [Moment] datetime2 NULL,
        CONSTRAINT PK_Event_EventID PRIMARY KEY CLUSTERED
        (
            EventID ASC
        )
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Event_ObjectID_Moment')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_Event_ObjectID_Moment] ON [dbo].[TEvent]
    (
        [ObjectID] ASC,
        [Moment] ASC
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Event_TypeID')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_Event_TypeID] ON [dbo].[TEvent]
    (
        [TypeID] ASC
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Event_LoginID')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_Event_LoginID] ON [dbo].[TEvent]
    (
        [LoginID] ASC
    )
END