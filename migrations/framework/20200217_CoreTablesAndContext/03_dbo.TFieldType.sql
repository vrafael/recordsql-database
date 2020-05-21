--liquibase formatted sql

--changeset vrafael:framework_20200217_03_dboTFieldType logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.TFieldType', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[TFieldType]
    (
	    [ID] [dbo].[identifier] NOT NULL FOREIGN KEY REFERENCES dbo.TObjectType (ID),
	    [DataType] dbo.string NULL,
	    CONSTRAINT [PK_FieldType_ID] PRIMARY KEY CLUSTERED 
        (
	        [ID] ASC
        )
    )
END

