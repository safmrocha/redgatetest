CREATE TABLE [dbo].[Tenant]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TenantTags] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataVersion] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Tenant] ADD CONSTRAINT [PK_Tenant_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Tenant_DataVersion] ON [dbo].[Tenant] ([DataVersion]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Tenant] ADD CONSTRAINT [UQ_TenantName] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
