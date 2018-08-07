CREATE TABLE [dbo].[Team]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MemberUserIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EnvironmentIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TenantIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenantTags] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectGroupIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Team] ADD CONSTRAINT [PK_Team_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Team] ADD CONSTRAINT [UQ_TeamNameUnique] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
