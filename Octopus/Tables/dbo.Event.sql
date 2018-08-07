CREATE TABLE [dbo].[Event]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RelatedDocumentIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnvironmentId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Username] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Occurred] [datetimeoffset] NOT NULL,
[Message] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TenantId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AutoId] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Event] ADD CONSTRAINT [PK_Event_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Event_AutoId] ON [dbo].[Event] ([AutoId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Event_Category_AutoId] ON [dbo].[Event] ([Category], [AutoId]) INCLUDE ([Id], [Occurred], [RelatedDocumentIds]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Event_Occurred] ON [dbo].[Event] ([Occurred]) INCLUDE ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Event_CommonSearch] ON [dbo].[Event] ([ProjectId], [EnvironmentId], [Category], [UserId], [Occurred], [TenantId]) INCLUDE ([Id], [RelatedDocumentIds]) ON [PRIMARY]
GO
