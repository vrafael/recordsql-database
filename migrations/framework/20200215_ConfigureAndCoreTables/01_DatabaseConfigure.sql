--liquibase formatted sql

--changeset vrafael:framework_20200215_01_DatabaseConfigure logicalFilePath:path-independent splitStatements:true stripComments:false endDelimiter:\nGO runOnChange:true
IF (@@VERSION NOT LIKE '%SQL Azure%')
BEGIN
    EXEC ('
    IF (FULLTEXTSERVICEPROPERTY(''IsFullTextInstalled'') = 1)
    BEGIN
        EXEC [${database}].[dbo].[sp_fulltext_database]
            @action = ''enable'';
    END

    ALTER DATABASE [${database}] SET ANSI_NULLS ON

    ALTER DATABASE [${database}] SET ANSI_PADDING ON

    ALTER DATABASE [${database}] SET ANSI_WARNINGS ON

    ALTER DATABASE [${database}] SET ARITHABORT ON

    ALTER DATABASE [${database}] SET AUTO_CLOSE OFF

    ALTER DATABASE [${database}] SET AUTO_SHRINK OFF

    ALTER DATABASE [${database}] SET AUTO_UPDATE_STATISTICS ON

    ALTER DATABASE [${database}] SET QUOTED_IDENTIFIER ON

    ALTER DATABASE [${database}] SET RECURSIVE_TRIGGERS OFF

    --ALTER DATABASE [${database}] SET DISABLE_BROKER

    --ALTER DATABASE [${database}] SET TRUSTWORTHY OFF

    ALTER DATABASE [${database}] SET ALLOW_SNAPSHOT_ISOLATION ON

    ALTER DATABASE [${database}] SET READ_COMMITTED_SNAPSHOT ON

    ALTER DATABASE [${database}] SET MULTI_USER

    ALTER DATABASE [${database}] SET READ_WRITE
    ');
END
GO
