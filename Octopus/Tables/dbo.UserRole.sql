CREATE TABLE [dbo].[UserRole]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserRole] ADD CONSTRAINT [PK_UserRole_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserRole] ADD CONSTRAINT [UQ_UserRoleNameUnique] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
