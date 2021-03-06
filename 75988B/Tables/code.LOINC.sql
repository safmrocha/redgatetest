CREATE TABLE [code].[LOINC]
(
[LOINC_NUM] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[COMPONENT] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SYSTEM] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VersionLastChanged] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RELATEDNAMES2] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHORTNAME] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LONG_COMMON_NAME] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [code].[LOINC] ADD CONSTRAINT [PK_LOIN_NUM] PRIMARY KEY CLUSTERED  ([LOINC_NUM]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161019-161701] ON [code].[LOINC] ([LONG_COMMON_NAME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161019-161638] ON [code].[LOINC] ([SHORTNAME]) ON [PRIMARY]
GO
