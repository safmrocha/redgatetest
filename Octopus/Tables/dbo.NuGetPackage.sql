CREATE TABLE [dbo].[NuGetPackage]
(
[Id] [nvarchar] (450) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PackageId] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Version] [nvarchar] (349) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VersionMajor] [int] NOT NULL,
[VersionMinor] [int] NOT NULL,
[VersionBuild] [int] NOT NULL,
[VersionRevision] [int] NOT NULL,
[VersionSpecial] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NuGetPackage] ADD CONSTRAINT [PK_NuGetPackage_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
