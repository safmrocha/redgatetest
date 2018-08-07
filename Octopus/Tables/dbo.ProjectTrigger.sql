CREATE TABLE [dbo].[ProjectTrigger]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TriggerType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDisabled] [bit] NOT NULL CONSTRAINT [DF__ProjectTr__IsDis__634EBE90] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProjectTrigger] ADD CONSTRAINT [PK_ProjectTrigger_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProjectTrigger_Project] ON [dbo].[ProjectTrigger] ([ProjectId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProjectTrigger] ADD CONSTRAINT [UQ_ProjectTriggerNameUnique] UNIQUE NONCLUSTERED  ([ProjectId], [Name]) ON [PRIMARY]
GO
