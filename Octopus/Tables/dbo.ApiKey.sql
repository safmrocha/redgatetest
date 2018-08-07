CREATE TABLE [dbo].[ApiKey]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ApiKeyHashed] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Created] [datetimeoffset] NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ApiKey] ADD CONSTRAINT [PK_ApiKey_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ApiKey] ADD CONSTRAINT [UQ_ApiKeyUnique] UNIQUE NONCLUSTERED  ([ApiKeyHashed]) ON [PRIMARY]
GO
