CREATE TABLE [dbo].[DeploymentRelatedMachine]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[DeploymentId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MachineId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DeploymentRelatedMachine] ADD CONSTRAINT [PK_DeploymentRelatedMachine] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DeploymentRelatedMachine_Deployment] ON [dbo].[DeploymentRelatedMachine] ([DeploymentId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DeploymentRelatedMachine_Machine] ON [dbo].[DeploymentRelatedMachine] ([MachineId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DeploymentRelatedMachine] ADD CONSTRAINT [FK_DeploymentRelatedMachine_DeploymentId] FOREIGN KEY ([DeploymentId]) REFERENCES [dbo].[Deployment] ([Id]) ON DELETE CASCADE
GO
