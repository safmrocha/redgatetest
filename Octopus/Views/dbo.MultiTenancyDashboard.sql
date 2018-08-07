SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[MultiTenancyDashboard] AS
	SELECT 
		d.Id as Id,
		d.Created as Created,
		d.ProjectId as ProjectId,
		d.EnvironmentId as EnvironmentId,
		d.ReleaseId as ReleaseId,
		d.TenantId as TenantId,
		d.TaskId as TaskId,
		d.ChannelId as ChannelId,
		CurrentOrPrevious,
		t.[State] as [State],
		t.HasPendingInterruptions as HasPendingInterruptions,
		t.HasWarningsOrErrors as HasWarningsOrErrors,
		t.ErrorMessage as ErrorMessage,
		t.QueueTime as QueueTime,
		t.StartTime as StartTime,
		t.CompletedTime as CompletedTime,
		r.[Version] as [Version]
	FROM (
		SELECT 
			'C' AS CurrentOrPrevious,
			d.Id as Id,
			d.Created as Created,
			d.ProjectId as ProjectId,
			d.EnvironmentId as EnvironmentId,
			d.ReleaseId as ReleaseId,
			d.TenantId as TenantId,
			d.TaskId as TaskId,		
			d.ChannelId as ChannelId,
			ROW_NUMBER() OVER (PARTITION BY d.EnvironmentId, d.ProjectId, d.TenantId ORDER BY Created DESC) as [Rank]
		FROM [Deployment] d
		INNER JOIN
		[ServerTask] t ON t.Id = d .TaskId
		WHERE NOT ((t.State = 'Canceled' OR t.State = 'Cancelling') AND t.StartTime IS NULL)
		UNION
		SELECT 
			'P' AS CurrentOrPrevious, 
			d.Id as Id,
			d.Created as Created,
			d.ProjectId as ProjectId,
			d.EnvironmentId as EnvironmentId,
			d.ReleaseId as ReleaseId,
			d.TenantId as TenantId,
			d.TaskId as TaskId,
			d.ChannelId as ChannelId,
			ROW_NUMBER() OVER (PARTITION BY d.EnvironmentId, d.ProjectId, d.TenantId ORDER BY Created DESC) as [Rank]
		FROM [Deployment] d
		INNER JOIN [ServerTask] t on t.Id = d.TaskId
		WHERE 
			t.State = 'Success' AND 
			d.Id NOT IN (
				SELECT Id 
				FROM (
					SELECT 
						d.Id as Id, 
						ROW_NUMBER() OVER (PARTITION BY d.EnvironmentId, d.ProjectId, d.TenantId ORDER BY Created DESC) as [Rank] 
					FROM [Deployment] d
					INNER JOIN
					[ServerTask] t ON t.Id = d .TaskId
					WHERE NOT ((t.State = 'Canceled' OR t.State = 'Cancelling') AND t.StartTime IS NULL)
				) LatestDeployment 
				WHERE [Rank]=1)
	 ) d 
	 INNER JOIN [ServerTask] t on t.Id = d.TaskId
	 INNER JOIN [Release] r on r.Id = d.ReleaseId
	 WHERE ([Rank]=1 AND CurrentOrPrevious='P') OR ([Rank]=1 AND CurrentOrPrevious='C')
GO
