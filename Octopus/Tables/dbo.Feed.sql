CREATE TABLE [dbo].[Feed]
(
[Id] [nvarchar] (210) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FeedUri] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FeedType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Feed] ADD CONSTRAINT [PK_Feed_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Feed] ADD CONSTRAINT [UQ_FeedNameUnique] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
