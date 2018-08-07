CREATE TABLE [dbo].[Account]
(
[Id] [nvarchar] (210) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AccountType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EnvironmentIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TenantIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenantTags] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Account] ADD CONSTRAINT [PK_Account_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Account] ADD CONSTRAINT [UQ_AccountUniqueName] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
