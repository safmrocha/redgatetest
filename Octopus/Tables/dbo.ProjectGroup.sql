CREATE TABLE [dbo].[ProjectGroup]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataVersion] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProjectGroup] ADD CONSTRAINT [PK_ProjectGroup_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProjectGroup_DataVersion] ON [dbo].[ProjectGroup] ([DataVersion]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProjectGroup] ADD CONSTRAINT [UQ_ProjectGroupNameUnique] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
