CREATE TABLE [dbo].[Invitation]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InvitationCode] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Invitation] ADD CONSTRAINT [PK_Invitation_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
