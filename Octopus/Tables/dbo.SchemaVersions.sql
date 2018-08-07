CREATE TABLE [dbo].[SchemaVersions]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[ScriptName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Applied] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SchemaVersions] ADD CONSTRAINT [PK_SchemaVersions_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
