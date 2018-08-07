CREATE TABLE [dbo].[DeploymentProcess]
(
[Id] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OwnerId] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsFrozen] [bit] NOT NULL,
[Version] [int] NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RelatedDocumentIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DeploymentProcess] ADD CONSTRAINT [PK_DeploymentProcess_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
