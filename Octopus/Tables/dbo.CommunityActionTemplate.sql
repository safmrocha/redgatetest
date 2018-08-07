CREATE TABLE [dbo].[CommunityActionTemplate]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternalId] [uniqueidentifier] NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CommunityActionTemplate] ADD CONSTRAINT [PK_CommunityActionTemplate_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CommunityActionTemplate] ADD CONSTRAINT [UQ_CommunityActionTemplateExternalId] UNIQUE NONCLUSTERED  ([ExternalId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CommunityActionTemplate] ADD CONSTRAINT [UQ_CommunityActionTemplateName] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
