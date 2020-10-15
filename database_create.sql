USE [master];

DECLARE @query nvarchar(max) = N''

SELECT @query = COALESCE(@query, N',') + 'KILL ' + CONVERT(nvarchar, ssp.spid) + N'; '
FROM sys.sysprocesses ssp WHERE ssp.dbid = DB_ID(N'record')

IF LEN(@query) > 0
BEGIN
    EXEC (@query)
END

DROP DATABASE IF EXISTS [record];
GO
CREATE DATABASE [record];
GO
USE [record]
GO
CREATE USER [**username**] FOR LOGIN [**username**]
GO
ALTER ROLE [db_owner] ADD MEMBER [**username**]
GO
USE [master]
