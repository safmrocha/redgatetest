CREATE TABLE [dbo].[ActionTemplate]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Version] [int] NOT NULL,
[ActionType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CommunityActionTemplateId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActionTemplate] ADD CONSTRAINT [PK_ActionTemplate_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActionTemplate] ADD CONSTRAINT [UQ_ActionTemplateUniqueName] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
