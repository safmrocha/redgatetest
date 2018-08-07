CREATE TABLE [dbo].[Deployment]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Created] [datetimeoffset] NOT NULL,
[EnvironmentId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReleaseId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectGroupId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TaskId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DeployedBy] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TenantId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeployedToMachineIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChannelId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Deployment] ADD CONSTRAINT [PK_Deployment_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Deployment_ChannelId] ON [dbo].[Deployment] ([ChannelId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Deployment_Index] ON [dbo].[Deployment] ([ReleaseId], [TaskId], [EnvironmentId]) INCLUDE ([Created], [Id], [Name], [ProjectGroupId], [ProjectId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Deployment_TenantId] ON [dbo].[Deployment] ([TenantId]) ON [PRIMARY]
GO
