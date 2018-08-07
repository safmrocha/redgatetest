CREATE TABLE [dbo].[VariableSet]
(
[Id] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OwnerId] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Version] [int] NOT NULL,
[IsFrozen] [bit] NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RelatedDocumentIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VariableSet] ADD CONSTRAINT [PK_VariableSet_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
