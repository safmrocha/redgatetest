CREATE TABLE [dbo].[KeyAllocation]
(
[CollectionName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Allocated] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KeyAllocation] ADD CONSTRAINT [PK_KeyAllocation_CollectionName] PRIMARY KEY CLUSTERED  ([CollectionName]) ON [PRIMARY]
GO
