SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[UpdateDeploymentHistory] (
	@quick bit = 1
)
as 
begin
	declare @lastCreated datetimeoffset
	
	select @lastCreated = MAX(Created) from DeploymentHistory
	
	if (@quick = 0)
	begin
		set @lastCreated = NULL
	end

	merge DeploymentHistory as target
	using (select 
		d.Id as DeploymentId,
		d.Name as DeploymentName, 
		p.Id as ProjectId, 
		p.Name as ProjectName, 
		p.Slug as ProjectSlug,
		c.Id as ChannelId,
		c.Name as ChannelName,
		tenant.Id as TenantId,
		tenant.Name as TenantName,
		env.Id as EnvironmentId, 
		env.Name as EnvironmentName, 
		r.Id as ReleaseId, 
		r.Version as ReleaseVersion,
		t.Id as TaskId, 
		t.State as TaskState,
		d.Created as Created,
		t.QueueTime as QueueTime,
		t.StartTime as StartTime,
		t.CompletedTime as CompletedTime,
		(case t.CompletedTime 
			when null then null 
			else (DATEDIFF(SECOND, QueueTime, CompletedTime)) 
		end) as DurationSeconds,
		d.DeployedBy as DeployedBy
		from Deployment d
		inner join Release r on (r.Id = d.ReleaseId)
		inner join ServerTask t on (t.Id = d.TaskId)
		inner join Project p on (p.Id = d.ProjectId)
		inner join DeploymentEnvironment env on (env.Id = d.EnvironmentId)
		inner join Channel c on (c.Id = r.ChannelId)
		left join tenant on (d.tenantId = tenant.Id)
		where t.State not in ('Queued', 'Cancelling', 'Canceling', 'Executing')
			and (@lastCreated is null or 
				-- Call the last task ever created 'T'. 
				-- Tasks that finished after T (including T or any other task that started after) should be included.
				-- Tasks that finished before T should have already been caught the last time we updated the history, 
				-- because they must have completed before T-1.
				(d.Created >= @lastCreated or 
				 t.CompletedTime >= @lastCreated)
			)
		) as source(DeploymentId, DeploymentName, ProjectId, ProjectName, ProjectSlug, ChannelId, ChannelName, TenantId, TenantName, EnvironmentId, EnvironmentName, ReleaseId, ReleaseVersion, TaskId, TaskState, Created, QueueTime, StartTime, CompletedTime, DurationSeconds, DeployedBy)
	on (target.DeploymentId = source.DeploymentId)
	when matched then UPDATE SET 
			ProjectId = source.ProjectId,
			ProjectName = source.ProjectName,
			ProjectSlug = source.ProjectSlug,
			ChannelId = source.ChannelId,
			ChannelName = source.ChannelName,
			TenantId = source.TenantId,
			TenantName = source.TenantName,
			EnvironmentId = source.EnvironmentId,
			EnvironmentName = source.EnvironmentName,
			ReleaseVersion = source.ReleaseVersion,
			TaskState = source.TaskState,
			Created = source.Created,
			QueueTime = source.QueueTime,
			StartTime = source.StartTime,
			CompletedTime = source.CompletedTime,
			DurationSeconds = source.DurationSeconds,
			DeployedBy = source.DeployedBy
	when not matched then 
		INSERT (DeploymentId, DeploymentName, ProjectId, ProjectName, ProjectSlug, ChannelId, ChannelName, TenantId, TenantName, EnvironmentId, EnvironmentName, ReleaseId, ReleaseVersion, TaskId, TaskState, Created, QueueTime, StartTime, CompletedTime, DurationSeconds, DeployedBy) 
		VALUES (source.DeploymentId, source.DeploymentName, source.ProjectId, source.ProjectName, source.ProjectSlug,  source.ChannelId, source.ChannelName, source.TenantId, source.TenantName, source.EnvironmentId, source.EnvironmentName, source.ReleaseId, source.ReleaseVersion, source.TaskId, source.TaskState, source.Created, source.QueueTime, source.StartTime, source.CompletedTime, source.DurationSeconds, source.DeployedBy)
	;

	if (@quick = 0)
	begin
		-- Fix up projects, environments and releases that may have been renamed
		update DeploymentHistory set 
			DeploymentHistory.EnvironmentName = env.Name 
			from DeploymentHistory 
			inner join DeploymentEnvironment env on env.Id = DeploymentHistory.EnvironmentId
		update DeploymentHistory set 
			DeploymentHistory.ProjectName = proj.Name, 
			DeploymentHistory.ProjectSlug = proj.Slug 
			from DeploymentHistory 
			inner join Project proj on proj.Id = DeploymentHistory.ProjectId
		update DeploymentHistory set 
			DeploymentHistory.ReleaseVersion = rel.Version
			from DeploymentHistory 
			inner join Release rel on rel.Id = DeploymentHistory.ReleaseId
		update DeploymentHistory set 
			DeploymentHistory.TenantName = rel.Name
			from DeploymentHistory 
			inner join Tenant rel on rel.Id = DeploymentHistory.TenantId
		update DeploymentHistory set 
			DeploymentHistory.ChannelName = rel.Name
			from DeploymentHistory 
			inner join Channel rel on rel.Id = DeploymentHistory.ChannelId
	end
end
GO
