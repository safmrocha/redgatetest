CREATE TABLE [dbo].[OctopusServerNode]
(
[Id] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastSeen] [datetimeoffset] NOT NULL,
[Rank] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MaxConcurrentTasks] [int] NOT NULL CONSTRAINT [DF_OctopusServerNode_MaxConTasks] DEFAULT ((5)),
[IsInMaintenanceMode] [bit] NOT NULL CONSTRAINT [DF_OctopusServerNode_IsMaintMode] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OctopusServerNode] ADD CONSTRAINT [PK_OctopusServerNode_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
