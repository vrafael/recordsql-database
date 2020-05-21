--liquibase formatted sql

--changeset vrafael:framework_20200215_02_Types logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
IF NOT EXISTS(SELECT 1 FROM sys.types st WHERE st.is_user_defined = 1 AND st.name = N'identifier')
BEGIN
    CREATE TYPE [dbo].[identifier] FROM [bigint] NOT NULL
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.types st WHERE st.is_user_defined = 1 AND st.name = N'link')
BEGIN
    CREATE TYPE [dbo].[link] FROM [bigint] NULL
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.types st WHERE st.is_user_defined = 1 AND st.name = N'string')
BEGIN
    CREATE TYPE [dbo].[string] FROM [nvarchar](512) NULL
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.types st WHERE st.is_user_defined = 1 AND st.name = N'color')
BEGIN
    CREATE TYPE [dbo].[color] FROM [varchar](8) NULL --HEX + alpha
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.types st WHERE st.is_user_defined = 1 AND st.name = N'list')
BEGIN
    CREATE TYPE [dbo].[list] AS TABLE
    (
	    [ID] [dbo].[link] NOT NULL,
	    PRIMARY KEY CLUSTERED 
        (
	        [ID] ASC
        ) WITH (IGNORE_DUP_KEY = OFF)
    )
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.types st WHERE st.is_user_defined = 1 AND st.name = N'listKeyValue')
BEGIN
    CREATE TYPE [dbo].[listKeyValue] AS TABLE
    (
	    [KeyID] [dbo].[link] NOT NULL,
	    [ValueID] [dbo].[link] NULL,
        PRIMARY KEY CLUSTERED
        (
	        [KeyID] ASC
        )
    )
END

IF NOT EXISTS(SELECT 1 FROM sys.types st WHERE st.is_user_defined = 1 AND st.name = N'listOrdered')
BEGIN
    CREATE TYPE [dbo].[listOrdered] AS TABLE
    (
	    [Order] int NOT NULL,
	    [ID] [dbo].[link] NULL,
        PRIMARY KEY CLUSTERED
        (
	        [Order] ASC
        )
    )
END