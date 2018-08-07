CREATE TABLE [dbo].[TenantVariable]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TenantId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EnvironmentId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OwnerId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VariableTemplateId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RelatedDocumentId] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TenantVariable] ADD CONSTRAINT [PK_TenantVariable_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TenantVariable_TenantId] ON [dbo].[TenantVariable] ([TenantId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TenantVariable] ADD CONSTRAINT [UQ_TenantVariable] UNIQUE NONCLUSTERED  ([TenantId], [OwnerId], [EnvironmentId], [VariableTemplateId]) ON [PRIMARY]
GO
