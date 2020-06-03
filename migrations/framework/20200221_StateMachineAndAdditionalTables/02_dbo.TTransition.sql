--liquibase formatted sql

--changeset vrafael:framework_20200221_02_dboTTransition logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.TTransition', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TTransition
    (
        [ID] [dbo].[identifier] NOT NULL FOREIGN KEY REFERENCES dbo.TDirectory(ID),
        SourceStateID dbo.link NULL,
        TargetStateID dbo.link NULL,
        [Priority] int NULL,
        CONSTRAINT PK_Transition_ID PRIMARY KEY CLUSTERED
        (
            ID ASC
        )
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Transition_SourceStateID_Priority')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_Transition_SourceStateID] ON [dbo].[TTransition]
    (
        [SourceStateID] ASC,
        [Priority] DESC
    )
    INCLUDE 
    (
        TargetStateID
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Transition_TargetStateID')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_Transition_TargetStateID] ON [dbo].[TTransition]
    (
        [TargetStateID] ASC
    )
END
