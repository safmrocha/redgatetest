CREATE TABLE [PrCore].[CaptionType]
(
[CaptionTypeID] [int] NOT NULL,
[CaptionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaptionTypeShort] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [PrCore].[CaptionType] ADD CONSTRAINT [PK_CaptionType] PRIMARY KEY CLUSTERED  ([CaptionTypeID]) ON [PRIMARY]
GO
