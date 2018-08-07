CREATE TABLE [dbo].[RelatedDocument]
(
[Id] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Table] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RelatedDocumentId] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RelatedDocumentTable] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_RelatedDocument_Id] ON [dbo].[RelatedDocument] ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RelatedDocument_RelatedDocumentId] ON [dbo].[RelatedDocument] ([RelatedDocumentId]) INCLUDE ([Id], [Table]) ON [PRIMARY]
GO
