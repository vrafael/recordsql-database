--liquibase formatted sql

--changeset vrafael:framework_20200217_01_dboTType logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.TType', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TType
    (
        [ID] [dbo].[identifier] NOT NULL FOREIGN KEY REFERENCES dbo.TDirectory (ID),
	    [Abstract] bit NULL,
        [Icon] [dbo].[string] NULL, --Font Awesome icon name 
        CONSTRAINT [PK_Type_ID] PRIMARY KEY CLUSTERED
        (
	        [ID] ASC
        )
    )
END