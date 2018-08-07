CREATE TABLE [dbo].[ServerTask]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QueueTime] [datetimeoffset] NOT NULL,
[StartTime] [datetimeoffset] NULL,
[CompletedTime] [datetimeoffset] NULL,
[ErrorMessage] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConcurrencyTag] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HasPendingInterruptions] [bit] NOT NULL,
[HasWarningsOrErrors] [bit] NOT NULL,
[ServerNodeId] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnvironmentId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TenantId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DurationSeconds] [int] NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ServerTask] ADD CONSTRAINT [PK_ServerTask_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ServerTask_TaskQueue_PopTask] ON [dbo].[ServerTask] ([QueueTime], [State], [ConcurrencyTag], [HasPendingInterruptions], [ServerNodeId]) INCLUDE ([CompletedTime], [Description], [DurationSeconds], [EnvironmentId], [ErrorMessage], [HasWarningsOrErrors], [JSON], [Name], [ProjectId], [StartTime], [TenantId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ServerTask_TaskQueue_GetActiveConcurrencyTags] ON [dbo].[ServerTask] ([State], [ConcurrencyTag]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ServerTask_Common] ON [dbo].[ServerTask] ([State], [Name], [ProjectId], [EnvironmentId], [TenantId], [ServerNodeId]) INCLUDE ([CompletedTime], [ConcurrencyTag], [Description], [DurationSeconds], [ErrorMessage], [HasPendingInterruptions], [HasWarningsOrErrors], [JSON], [QueueTime], [StartTime]) ON [PRIMARY]
GO
