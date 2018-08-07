CREATE TABLE [dbo].[WorkerTaskLease]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkerId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TaskId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Exclusive] [bit] NOT NULL CONSTRAINT [DF__WorkerTas__Exclu__6CD828CA] DEFAULT ((0)),
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkerTaskLease] ADD CONSTRAINT [PK_WorkerTaskLease_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
