CREATE TABLE [dbo].[ActionTemplateVersion]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Version] [int] NOT NULL,
[LatestActionTemplateId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ActionType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActionTemplateVersion] ADD CONSTRAINT [PK_ActionTemplateVersion_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ActionTemplateVersion_LatestActionTemplateId] ON [dbo].[ActionTemplateVersion] ([LatestActionTemplateId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActionTemplateVersion] ADD CONSTRAINT [UQ_ActionTemplateVersionUniqueNameVersion] UNIQUE NONCLUSTERED  ([Name], [Version]) ON [PRIMARY]
GO
