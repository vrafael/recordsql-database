--liquibase formatted sql

--changeset vrafael:framework_20200215_03_dbo.TObject logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.TObject', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TObject
    (
        ID dbo.identifier IDENTITY(1, 1) NOT NULL,
        TypeID dbo.link NOT NULL,
        StateID dbo.link NULL,
        [Name] dbo.string NULL,
        CONSTRAINT PK_Object_ID PRIMARY KEY CLUSTERED
        (
            ID ASC
        )
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Object_Name')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_Object_Name] ON [dbo].[TObject]
    (
	    [Name] ASC
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes si WHERE si.name = N'NCI_Object_TypeID_StateID')
BEGIN
    CREATE NONCLUSTERED INDEX [NCI_Object_TypeID_StateID] ON [dbo].[TObject]
    (
        [TypeID] ASC,
        [StateID] ASC
    )
END
