CREATE TABLE [PrCore].[Caption]
(
[CaptionID] [int] NOT NULL,
[Caption] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaptionTypeID] [int] NOT NULL,
[IsHeading] [bit] NOT NULL,
[IsSubtotal] [bit] NOT NULL,
[IsTotal] [bit] NOT NULL,
[IsSummary] [bit] NOT NULL,
[IsInverted] [bit] NOT NULL,
[SelectSQL] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileSQL] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [PrCore].[Caption] ADD CONSTRAINT [PK_Caption] PRIMARY KEY CLUSTERED  ([CaptionID]) ON [PRIMARY]
GO
ALTER TABLE [PrCore].[Caption] ADD CONSTRAINT [FK_Caption_CaptionType] FOREIGN KEY ([CaptionTypeID]) REFERENCES [PrCore].[CaptionType] ([CaptionTypeID])
GO
