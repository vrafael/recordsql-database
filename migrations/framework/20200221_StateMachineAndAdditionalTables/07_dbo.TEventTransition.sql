--liquibase formatted sql

--changeset vrafael:framework_20200221_07_dboTEventTransition logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.TEventTransition', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TEventTransition
    (
        [EventID] [dbo].[identifier] FOREIGN KEY REFERENCES dbo.TEvent (EventID),
        [TransitionID] dbo.link NULL,
        CONSTRAINT PK_EventTransition_EventID PRIMARY KEY CLUSTERED
        (
            EventID ASC
        )
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_EventTransition_TransitionID')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_EventTransition_TransitionID] ON [dbo].[TEventTransition]
    (
        [TransitionID] ASC
    )
END