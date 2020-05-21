--liquibase formatted sql

--changeset vrafael:framework_20200218_03_dboTError logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.TError', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[TError]
    (
    	[ErrorID] [dbo].[identifier] IDENTITY(1,1) NOT NULL,
    	[TypeID] [dbo].[link] NULL,
    	[ProcedureID] [dbo].[link] NULL,
    	[LoginID] [dbo].[link] NULL,
    	[Message] [nvarchar](max) NULL,
    	[Moment] [datetime2] NULL,
    	[Context] [varbinary](max) NULL,
    	[Nestlevel] [int] NULL,
    	[Callstack] [nvarchar](max) NULL,
        CONSTRAINT [PK_Error_ErrorID] PRIMARY KEY CLUSTERED 
        (
    	    [ErrorID] ASC
        )
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Error_LoginID_Moment')
BEGIN
	CREATE NONCLUSTERED INDEX [NCI_Error_LoginID_Moment] ON [dbo].[TError]
	(
		[LoginID] ASC,
		[Moment] ASC
	)
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Error_ProcedureID_Moment')
BEGIN
	CREATE NONCLUSTERED INDEX [NCI_Error_ProcedureID_Moment] ON [dbo].[TError]
	(
		[ProcedureID] ASC,
		[Moment] ASC
	)
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Error_TypeID')
BEGIN
	CREATE NONCLUSTERED INDEX [NCI_Error_TypeID] ON [dbo].[TError]
	(
		[TypeID] ASC
	)
END