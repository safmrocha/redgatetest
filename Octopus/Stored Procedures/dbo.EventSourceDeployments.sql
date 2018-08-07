SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[EventSourceDeployments]
(
    @startId bigint,
    @endId bigint
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
		StartEvent.[AutoId] AS StartAutoId,
		StartEvent.[Occurred] AS StartTime,
		EndEvent.EndAutoId,
		EndEvent.EndTime,
		EndEvent.Deployment_Id,
		EndEvent.Deployment_Name,
		EndEvent.Deployment_Created,
		EndEvent.Deployment_EnvironmentId,
		EndEvent.Deployment_ProjectId,
		EndEvent.Deployment_ReleaseId,
		EndEvent.Deployment_ProjectGroupId,
		EndEvent.Deployment_TaskId,
		EndEvent.Deployment_JSON,
		EndEvent.Deployment_DeployedBy,
		EndEvent.Deployment_TenantId,
		EndEvent.Deployment_DeployedToMachineIds,
		EndEvent.Deployment_ChannelId
		FROM (
		SELECT EndEvent.[AutoId] AS EndAutoId
			,EndEvent.[Occurred] AS EndTime
			,Deployment.[Id] AS Deployment_Id
			,Deployment.[Name] AS Deployment_Name
			,Deployment.[Created] AS Deployment_Created
			,Deployment.[EnvironmentId] AS Deployment_EnvironmentId
			,Deployment.[ProjectId] AS Deployment_ProjectId
			,Deployment.[ReleaseId] AS Deployment_ReleaseId
			,Deployment.[ProjectGroupId] AS Deployment_ProjectGroupId
			,Deployment.[TaskId] AS Deployment_TaskId
			,Deployment.[JSON] AS Deployment_JSON
			,Deployment.[DeployedBy] AS Deployment_DeployedBy
			,Deployment.[TenantId] AS Deployment_TenantId
			,Deployment.[DeployedToMachineIds] AS Deployment_DeployedToMachineIds
			,Deployment.[ChannelId] AS Deployment_ChannelId
			,EndEvent.RelatedDocumentIds
		FROM [Event] AS EndEvent
		INNER JOIN EventRelatedDocument
		ON EndEvent.Id = EventRelatedDocument.EventId
		INNER JOIN Deployment
		ON Deployment.Id = EventRelatedDocument.RelatedDocumentId
		WHERE EndEvent.Category IN ('DeploymentSucceeded', 'DeploymentFailed')
		AND EndEvent.AutoId > @startId
		AND EndEvent.AutoId <= @endId
	) EndEvent
	CROSS APPLY
	(
		-- Find the equivalent StartEvent (DeploymentQueued) for our EndEvent (DeploymentSucceeded)
		SELECT TOP 1 *
		FROM [Event]
		WHERE Category = 'DeploymentQueued'
		AND [Event].RelatedDocumentIds = EndEvent.RelatedDocumentIds
		AND [Event].AutoId < EndEvent.EndAutoId
		AND [Event].ProjectId = EndEvent.Deployment_ProjectId
		ORDER BY [Event].AutoId DESC
	) StartEvent
END
GO
