CREATE TABLE [dbo].[LibraryVariableSet]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VariableSetId] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContentType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LibraryVariableSet] ADD CONSTRAINT [PK_LibraryVariableSet_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LibraryVariableSet] ADD CONSTRAINT [UQ_LibraryVariableSetNameUnique] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
