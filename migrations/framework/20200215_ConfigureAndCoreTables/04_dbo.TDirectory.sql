--liquibase formatted sql

--changeset vrafael:framework_20200215_04_dboTDirectory logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.TDirectory', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[TDirectory]
    (
        [ID] [dbo].[identifier] NOT NULL FOREIGN KEY REFERENCES dbo.TObject(ID),
        [Tag] dbo.string NULL,
        [Description] nvarchar(max) NULL,
        CONSTRAINT [PK_Directory_ID] PRIMARY KEY CLUSTERED 
        (
            [ID] ASC
        )
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Directory_Tag')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_Directory_Tag] ON [dbo].[TDirectory]
    (
        [Tag] ASC
    )
END