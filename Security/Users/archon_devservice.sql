IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'archon\devservice')
CREATE LOGIN [archon\devservice] FROM WINDOWS
GO
CREATE USER [archon\devservice] FOR LOGIN [archon\devservice] WITH DEFAULT_SCHEMA=[archon\devservice]
GO
REVOKE CONNECT TO [archon\devservice]
