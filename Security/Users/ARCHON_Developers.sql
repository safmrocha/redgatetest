IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ARCHON\Developers')
CREATE LOGIN [ARCHON\Developers] FROM WINDOWS
GO
CREATE USER [ARCHON\Developers] FOR LOGIN [ARCHON\Developers]
GO
