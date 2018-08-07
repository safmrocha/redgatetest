CREATE TABLE [dbo].[Configuration]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Configuration] ADD CONSTRAINT [PK_Configuration_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
