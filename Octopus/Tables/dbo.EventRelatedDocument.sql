CREATE TABLE [dbo].[EventRelatedDocument]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[RelatedDocumentId] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EventRelatedDocument] ADD CONSTRAINT [PK_EventRelatedDocument] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EventRelatedDocument_EventId] ON [dbo].[EventRelatedDocument] ([EventId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EventRelatedDocument_RelatedDocumentId] ON [dbo].[EventRelatedDocument] ([RelatedDocumentId]) INCLUDE ([EventId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EventRelatedDocument] ADD CONSTRAINT [FK_EventRelatedDocument_EventId] FOREIGN KEY ([EventId]) REFERENCES [dbo].[Event] ([Id]) ON DELETE CASCADE
GO
