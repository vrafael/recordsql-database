--liquibase formatted sql

--changeset vrafael:framework_20200221_03_dboTDatabaseObject logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.TDatabaseObject', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TDatabaseObject
    (
        [ID] [dbo].[identifier] NOT NULL FOREIGN KEY REFERENCES dbo.TDirectory(ID),
        object_id int NULL,
        Script [nvarchar](max) NULL,
        CONSTRAINT PK_DatabaseObject_ID PRIMARY KEY CLUSTERED
        (
            ID ASC
        )
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_DatabaseObject_object_id')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_DatabaseObject_object_id] ON [dbo].[TDatabaseObject]
    (
        [object_id] ASC
    )
END