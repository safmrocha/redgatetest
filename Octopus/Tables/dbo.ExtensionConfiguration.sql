CREATE TABLE [dbo].[ExtensionConfiguration]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtensionAuthor] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ExtensionConfiguration] ADD CONSTRAINT [PK_ExtensionConfiguration_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
