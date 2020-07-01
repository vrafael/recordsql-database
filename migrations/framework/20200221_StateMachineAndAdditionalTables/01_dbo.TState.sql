--liquibase formatted sql

--changeset vrafael:framework_20200221_dboTState logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.TState', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[TState]
    (
	    [ID] [dbo].[identifier] NOT NULL FOREIGN KEY REFERENCES dbo.TDirectory(ID),
	    [Color] dbo.string NULL,
	    CONSTRAINT [PK_State_ID] PRIMARY KEY CLUSTERED
        (
	        [ID] ASC
        )
    )
END