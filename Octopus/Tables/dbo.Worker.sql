CREATE TABLE [dbo].[Worker]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDisabled] [bit] NOT NULL,
[WorkerPoolIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MachinePolicyId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Thumbprint] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fingerprint] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CommunicationStyle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataVersion] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Worker] ADD CONSTRAINT [PK_Worker_Id] PRIMARY KEY NONCLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Worker_DataVersion] ON [dbo].[Worker] ([DataVersion]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_Worker_MachinePolicy] ON [dbo].[Worker] ([MachinePolicyId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Worker] ADD CONSTRAINT [UQ_WorkerNameUnique] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
