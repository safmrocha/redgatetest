SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------
-- Finally, update the IdsInUse table
------------------------------------------------


CREATE VIEW [dbo].[IdsInUse] AS
  SELECT [Id], 'Account' AS [Type] , [Name] FROM dbo.[Account] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'ActionTemplate' AS [Type] , [Name] FROM dbo.[ActionTemplate] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'ActionTemplateVersion' AS [Type] , [Name] FROM dbo.ActionTemplateVersion WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'ApiKey' AS [Type] , [ApiKeyHashed] as [Name] FROM dbo.[ApiKey] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'Certificate' AS [Type] , [Name] FROM dbo.[Certificate] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'Channel' AS [Type] , [Name] FROM dbo.[Channel] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'CommunityActionTemplate' AS [Type] , [Name] FROM dbo.CommunityActionTemplate WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'ActivityLogStorageConfiguration, ArtifactStorageConfiguration, BuiltInRepositoryConfiguration, FeaturesConfiguration, License, MaintenanceConfiguration, ScheduleConfiguration, ServerConfiguration, SmtpConfiguration, UpgradeAvailability, UpgradeConfiguration' AS [Type] , '' AS [Name] FROM dbo.[Configuration] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'DashboardConfiguration' AS [Type] , '' AS [Name] FROM dbo.[DashboardConfiguration] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'DeploymentEnvironment' AS [Type] , [Name] FROM dbo.[DeploymentEnvironment] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'DeploymentProcess' AS [Type] , '' AS [Name] FROM dbo.[DeploymentProcess] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'Feed' AS [Type] , [Name] FROM dbo.[Feed] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'Interruption' AS [Type] , '' AS [Name] FROM dbo.[Interruption] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'Invitation' AS [Type] , '' AS [Name] FROM dbo.[Invitation] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'LibraryVariableSet' AS [Type] , [Name] FROM dbo.[LibraryVariableSet] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'Lifecycle' AS [Type] , [Name] FROM dbo.[Lifecycle] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'Machine' AS [Type] , [Name] FROM dbo.[Machine] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'MachinePolicy' AS [Type] , [Name] FROM dbo.[MachinePolicy] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'IndexedPackage' AS [Type] , '' AS [Name] FROM dbo.[NuGetPackage] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'OctopusServerNode' AS [Type] , [Name] FROM dbo.[OctopusServerNode] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'Project' AS [Type] , [Name] FROM dbo.[Project] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'ProjectGroup' AS [Type] , [Name] FROM dbo.[ProjectGroup] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'ProjectTrigger' AS [Type] , [Name] FROM dbo.[ProjectTrigger] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'Proxy' AS [Type] , [Name] FROM dbo.[Proxy] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'Release' AS [Type] , '' AS [Name] FROM dbo.[Release] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'Subscription' AS [Type] , [Name] FROM dbo.[Subscription] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'TagSet' AS [Type] , [Name] FROM dbo.[TagSet] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'Team' AS [Type] , [Name] FROM dbo.[Team] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'Tenant' AS [Type] , [Name] FROM dbo.[Tenant] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'User' AS [Type] , [Username] as [Name] FROM dbo.[User] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'UserRole' AS [Type] , [Name] FROM dbo.[UserRole] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'VariableSet' AS [Type] , '' AS [Name] FROM dbo.[VariableSet] WITH (NOLOCK)
  UNION ALL
  SELECT [Id], 'WorkerPool' AS [Type] , '' AS [Name] FROM dbo.[WorkerPool] WITH (NOLOCK)
GO
