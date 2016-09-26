IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'Archon\ProductionService')
CREATE LOGIN [Archon\ProductionService] FROM WINDOWS
GO
CREATE USER [Archon\ProductionService] FOR LOGIN [Archon\ProductionService]
GO
