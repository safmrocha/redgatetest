CREATE TABLE [dbo].[DataExports]
(
[Id] [uniqueidentifier] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Language] [int] NULL,
[Query] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColumnHeaders] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Downloads] [int] NULL CONSTRAINT [DF__DataExpor__Downl__1E87EDEE] DEFAULT ((0)),
[IsVisible] [bit] NULL CONSTRAINT [DF__DataExpor__IsVis__1F7C1227] DEFAULT ((1)),
[FilterQuery] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilterLanguage] [int] NULL CONSTRAINT [DF__DataExpor__Filte__20703660] DEFAULT ((0)),
[FilterLabel] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UseDateRange] [bit] NULL CONSTRAINT [DF__DataExpor__UseDa__21645A99] DEFAULT ((0)),
[MultiTA] [int] NULL CONSTRAINT [DF__DataExpor__Multi__22587ED2] DEFAULT ((0)),
[LastDownloaded] [datetime] NULL,
[GroupByColumns] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubQuery] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataExports] ADD CONSTRAINT [PK_DataExports] PRIMARY KEY CLUSTERED  ([Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataExports] ADD CONSTRAINT [UQ_DataExports_Name] UNIQUE NONCLUSTERED  ([Name]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
