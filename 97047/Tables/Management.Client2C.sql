CREATE TABLE [Management].[Client2C]
(
[ClientID] [int] NOT NULL,
[ReplicationCode] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowguid] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF__Client2C__rowgui__4E0988E7] DEFAULT (newsequentialid())
) ON [PRIMARY]
GO
ALTER TABLE [Management].[Client2C] ADD CONSTRAINT [PK_ClientID2C] PRIMARY KEY CLUSTERED  ([ClientID]) ON [PRIMARY]
GO
