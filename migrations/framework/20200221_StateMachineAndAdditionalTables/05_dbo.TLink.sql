--liquibase formatted sql

--changeset vrafael:framework_20200221_05_dboTLink logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.TLink', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TLink
    (
        [ValueID] [dbo].[identifier] FOREIGN KEY REFERENCES dbo.TValue (ValueID),
        [LinkedID] dbo.link NULL,
        CONSTRAINT PK_Link_ValueID PRIMARY KEY CLUSTERED
        (
            ValueID ASC
        )
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Link_LinkedID')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_Link_LinkedID] ON [dbo].[TLink]
    (
        [LinkedID] ASC
    )
END