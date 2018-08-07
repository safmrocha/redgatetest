SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[LatestSuccessfulDeploymentsToMachine]
(
	@machineId NVARCHAR(MAX)
)
AS
BEGIN (
	SELECT * FROM (
		SELECT [Deployment].*, ROW_NUMBER() OVER (PARTITION BY [Deployment].EnvironmentId, [Deployment].ProjectId, [Deployment].TenantId ORDER BY [Event].[Occurred] DESC) AS [Rank]
		FROM [Deployment]
		INNER JOIN [DeploymentRelatedMachine]
		ON [Deployment].Id = [DeploymentRelatedMachine].DeploymentId
		INNER JOIN [EventRelatedDocument]
		ON [EventRelatedDocument].RelatedDocumentId = [Deployment].Id
		INNER JOIN [Event]
		ON [Event].Id = [EventRelatedDocument].EventId
		WHERE [DeploymentRelatedMachine].MachineId = @machineId
		AND [Event].Category = 'DeploymentSucceeded'
	) d
	WHERE [Rank] = 1
)
END
GO
