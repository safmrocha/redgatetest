CREATE TABLE [dbo].[WorkerPool]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SortOrder] [int] NOT NULL,
[IsDefault] [bit] NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataVersion] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkerPool] ADD CONSTRAINT [PK_WorkerPool_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WorkerPool_DataVersion] ON [dbo].[WorkerPool] ([DataVersion]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkerPool] ADD CONSTRAINT [UQ_WorkerPoolNameUnique] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
