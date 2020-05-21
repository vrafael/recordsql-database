--liquibase formatted sql

--changeset vrafael:framework_20200221_06_dboTString logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.TString', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TString
    (
        [ValueID] [dbo].[identifier] FOREIGN KEY REFERENCES dbo.TValue (ValueID),
        [String] dbo.string NULL,
        CONSTRAINT PK_String_ValueID PRIMARY KEY CLUSTERED
        (
            ValueID ASC
        )
    )
END