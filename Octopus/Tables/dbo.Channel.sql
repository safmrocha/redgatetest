CREATE TABLE [dbo].[Channel]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LifecycleId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TenantTags] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataVersion] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Channel] ADD CONSTRAINT [PK_Channel_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Channel_DataVersion] ON [dbo].[Channel] ([DataVersion]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Channel] ADD CONSTRAINT [UQ_ChannelUniqueNamePerProject] UNIQUE NONCLUSTERED  ([Name], [ProjectId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Channel_ProjectId] ON [dbo].[Channel] ([ProjectId]) ON [PRIMARY]
GO
