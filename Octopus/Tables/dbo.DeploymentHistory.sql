CREATE TABLE [dbo].[DeploymentHistory]
(
[DeploymentId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DeploymentName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectSlug] [nvarchar] (210) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EnvironmentId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EnvironmentName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReleaseId] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReleaseVersion] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TaskId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TaskState] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Created] [datetimeoffset] NOT NULL,
[QueueTime] [datetimeoffset] NOT NULL,
[StartTime] [datetimeoffset] NULL,
[CompletedTime] [datetimeoffset] NULL,
[DurationSeconds] [int] NULL,
[DeployedBy] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenantId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenantName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChannelId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChannelName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DeploymentHistory] ADD CONSTRAINT [PK_DeploymentHistory_DeploymentId] PRIMARY KEY CLUSTERED  ([DeploymentId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DeploymentHistory_Created] ON [dbo].[DeploymentHistory] ([Created]) ON [PRIMARY]
GO
