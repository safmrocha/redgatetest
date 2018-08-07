CREATE TABLE [dbo].[TagSet]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SortOrder] [int] NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataVersion] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TagSet] ADD CONSTRAINT [PK_TagSet_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TagSet_DataVersion] ON [dbo].[TagSet] ([DataVersion]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TagSet] ADD CONSTRAINT [UQ_TagSetName] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
