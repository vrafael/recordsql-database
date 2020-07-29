--liquibase formatted sql

--changeset vrafael:framework_20200217_04_dboTField logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.TField', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[TField]
    (
	    [ID] [dbo].[identifier] NOT NULL FOREIGN KEY REFERENCES dbo.TDirectory(ID),
        [Order] int NULL,
	    CONSTRAINT [PK_Field_ID] PRIMARY KEY CLUSTERED
        (
	        [ID] ASC
        )
    )
END
