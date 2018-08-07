CREATE TABLE [dbo].[Machine]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDisabled] [bit] NOT NULL,
[Roles] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EnvironmentIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MachinePolicyId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenantIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenantTags] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Thumbprint] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fingerprint] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CommunicationStyle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataVersion] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Machine] ADD CONSTRAINT [PK_Machine_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Machine_DataVersion] ON [dbo].[Machine] ([DataVersion]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Machine_MachinePolicy] ON [dbo].[Machine] ([MachinePolicyId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Machine] ADD CONSTRAINT [UQ_MachineNameUnique] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
