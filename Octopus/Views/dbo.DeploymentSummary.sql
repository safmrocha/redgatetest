SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[DeploymentSummary]
AS
SELECT
	db.Id as Id,
	db.Created as Created,
	db.ChannelId as ChannelId,
	db.ProjectId as ProjectId,
	db.EnvironmentId as EnvironmentId,
	db.TenantId as TenantId,
	db.ReleaseId as ReleaseId,
	db.TaskId as TaskId,
	db.[State] as [State],
	db.HasPendingInterruptions as HasPendingInterruptions,
	db.HasWarningsOrErrors as HasWarningsOrErrors,
	db.ErrorMessage as ErrorMessage,
	db.QueueTime as QueueTime,
	db.StartTime as StartTime,
	db.CompletedTime as CompletedTime,
	db.[Version] as [Version],
	(CASE WHEN [Rank] = 1 THEN 'C' WHEN [Rank] = 2 THEN 'P' ELSE 'A' END) as CurrentOrPrevious 
	FROM
	(
		SELECT d.Id as Id,
			d.Created as Created,
			d.ProjectId as ProjectId,
			d.EnvironmentId as EnvironmentId,
			d.ReleaseId as ReleaseId,
			d.ChannelId as ChannelId,
			d.TaskId as TaskId,
			t.[State] as [State],
			t.HasPendingInterruptions as HasPendingInterruptions,
			t.HasWarningsOrErrors as HasWarningsOrErrors,
			t.ErrorMessage as ErrorMessage,
			t.QueueTime as QueueTime,
	    t.StartTime as StartTime,
			t.CompletedTime as CompletedTime,
			r.[Version] as [Version],
			d.TenantId as TenantId,
			CASE WHEN p.DiscreteChannelRelease = 1 THEN
				ROW_NUMBER() OVER (PARTITION BY d.EnvironmentId, d.ProjectId, d.TenantId, d.ChannelId ORDER BY Created DESC) 
			ELSE 
				ROW_NUMBER() OVER (PARTITION BY d.EnvironmentId, d.ProjectId, d.TenantId ORDER BY Created DESC)
			END as [Rank]
		FROM [Deployment] d
			INNER JOIN Project p ON p.Id = d.ProjectId
			INNER JOIN [ServerTask] t on t.Id = d.TaskId
			INNER JOIN [Release] r on r.Id = d.ReleaseId
	) db
GO
