CREATE TABLE [dbo].[Lifecycle]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataVersion] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Lifecycle] ADD CONSTRAINT [PK_Lifecycle_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Lifecycle_DataVersion] ON [dbo].[Lifecycle] ([DataVersion]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Lifecycle] ADD CONSTRAINT [UQ_LifecycleNameUnique] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
