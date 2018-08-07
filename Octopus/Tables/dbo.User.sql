CREATE TABLE [dbo].[User]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Username] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsActive] [bit] NOT NULL,
[IsService] [bit] NOT NULL,
[IdentificationToken] [uniqueidentifier] NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailAddress] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternalId] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternalIdentifiers] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[User] ADD CONSTRAINT [PK_User_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_User_DisplayName] ON [dbo].[User] ([DisplayName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_User_EmailAddress] ON [dbo].[User] ([EmailAddress]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_User_ExternalId] ON [dbo].[User] ([ExternalId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_User_IdentificationToken] ON [dbo].[User] ([IdentificationToken]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[User] ADD CONSTRAINT [UQ_UserUsernameUnique] UNIQUE NONCLUSTERED  ([Username]) ON [PRIMARY]
GO
