--liquibase formatted sql

--changeset vrafael:framework_20200217_02_dboTObjectType logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.TObjectType', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[TObjectType]
    (
	    [ID] [dbo].[identifier] NOT NULL FOREIGN KEY REFERENCES dbo.TType(ID),
	    [StateMachineID] [dbo].[link] NULL,
	    CONSTRAINT [PK_ObjectType_ID] PRIMARY KEY CLUSTERED
        (
	        [ID] ASC
        )
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_ObjectType_StateMachineID')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_ObjectType_StateMachineID] ON [dbo].[TObjectType]
    (
	    [StateMachineID] ASC
    )
END