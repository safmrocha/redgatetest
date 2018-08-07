CREATE TABLE [dbo].[Certificate]
(
[Id] [varchar] (210) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Thumbprint] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NotAfter] [datetimeoffset] (0) NOT NULL,
[Subject] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EnvironmentIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenantIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenantTags] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [datetimeoffset] (0) NULL,
[Created] [datetimeoffset] (0) NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataVersion] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Certificate] ADD CONSTRAINT [PK_Certificate_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Certificate_Created] ON [dbo].[Certificate] ([Created]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Certificate_DataVersion] ON [dbo].[Certificate] ([DataVersion]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Certificate_NotAfter] ON [dbo].[Certificate] ([NotAfter]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Certificate_Thumbprint] ON [dbo].[Certificate] ([Thumbprint]) ON [PRIMARY]
GO
