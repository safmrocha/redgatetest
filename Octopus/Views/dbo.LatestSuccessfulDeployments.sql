SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[LatestSuccessfulDeployments]
AS
SELECT * FROM (
	SELECT [Deployment].*, ROW_NUMBER() OVER (PARTITION BY [Deployment].EnvironmentId, [Deployment].ProjectId, [Deployment].TenantId ORDER BY [Event].[Occurred] DESC) AS [Rank]
	FROM [Deployment]
	INNER JOIN [EventRelatedDocument]
	ON [Deployment].Id = [EventRelatedDocument].RelatedDocumentId
	INNER JOIN [Event]
	ON [EventRelatedDocument].EventId = [Event].Id
	WHERE [Event].Category = 'DeploymentSucceeded'
) d
WHERE [Rank] = 1
GO
