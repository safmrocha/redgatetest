CREATE TABLE [dbo].[OctopusServerInstallationHistory]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Node] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Version] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Installed] [datetimeoffset] NOT NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
