CREATE TABLE [dbo].[ads]
(
[rsn] [int] NOT NULL IDENTITY(1, 1),
[image] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ads_filename] DEFAULT (''),
[url] [nvarchar] (350) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ads_url] DEFAULT (''),
[target] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ads_target] DEFAULT (''),
[alt] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ads_alt] DEFAULT (''),
[dept] [bigint] NOT NULL CONSTRAINT [DF_ads_dept] DEFAULT ((0)),
[ordershow] [int] NOT NULL CONSTRAINT [DF_ads_ordershow] DEFAULT ((0)),
[sitearea] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ads_istop] DEFAULT (''),
[active] [tinyint] NOT NULL CONSTRAINT [DF_ads_active] DEFAULT ((0)),
[oid] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ads_oid] DEFAULT (''),
[pos] [int] NOT NULL CONSTRAINT [DF_ads_pos] DEFAULT ((0)),
[title] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ads_title_1] DEFAULT (''),
[brand] [bigint] NOT NULL CONSTRAINT [DF_ads_brand] DEFAULT ((0)),
[bcss] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ads_bcss] DEFAULT (''),
[brt] [bigint] NOT NULL CONSTRAINT [DF_ads_brt] DEFAULT ((0)),
[br] [bigint] NOT NULL CONSTRAINT [DF_ads_br] DEFAULT ((0)),
[adtext] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ads_adtext] DEFAULT (''),
[sku] [bigint] NOT NULL CONSTRAINT [DF_ads_sku_1] DEFAULT ((0)),
[vidlink] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ads_vidlink_1] DEFAULT (''),
[rolltitle] [nvarchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ads_rolltitle] DEFAULT (''),
[rollsubtitle] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ads_rollsubtitle] DEFAULT (''),
[gender] [tinyint] NOT NULL CONSTRAINT [DF_ads_gender] DEFAULT ((0)),
[buttontext] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ads_buttontext] DEFAULT (''),
[landing] [int] NOT NULL CONSTRAINT [DF_ads_landing] DEFAULT ((0)),
[hide_overlay] [tinyint] NOT NULL CONSTRAINT [DF_ads_hide_overlay] DEFAULT ((0)),
[hide_addtobag] [tinyint] NOT NULL CONSTRAINT [DF__ads__hide_addtob__4E88ABD4] DEFAULT ((0)),
[mp_exclusion] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_from] [datetime] NULL,
[date_to] [datetime] NULL,
[mp_site_handling] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[border_colour_hex_value] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subsku] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ads] ADD CONSTRAINT [PK_ads] PRIMARY KEY CLUSTERED  ([rsn]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sitearea] ON [dbo].[ads] ([sitearea]) WITH (FILLFACTOR=90, ALLOW_PAGE_LOCKS=OFF) ON [PRIMARY]
GO
ALTER INDEX [sitearea] ON [dbo].[ads] DISABLE
GO
