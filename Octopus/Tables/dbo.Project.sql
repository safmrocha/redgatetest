CREATE TABLE [dbo].[Project]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Slug] [nvarchar] (210) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDisabled] [bit] NOT NULL,
[VariableSetId] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeploymentProcessId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectGroupId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LifecycleId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AutoCreateRelease] [bit] NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IncludedLibraryVariableSetIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiscreteChannelRelease] [bit] NOT NULL CONSTRAINT [DF__Project__Discret__3864608B] DEFAULT ((0)),
[DataVersion] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Project] ADD CONSTRAINT [PK_Project_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Project_DataVersion] ON [dbo].[Project] ([DataVersion]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Project_DiscreteChannelRelease] ON [dbo].[Project] ([Id]) INCLUDE ([DiscreteChannelRelease]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Project] ADD CONSTRAINT [UQ_ProjectNameUnique] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Project] ADD CONSTRAINT [UQ_ProjectSlugUnique] UNIQUE NONCLUSTERED  ([Slug]) ON [PRIMARY]
GO
