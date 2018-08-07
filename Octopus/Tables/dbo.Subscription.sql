CREATE TABLE [dbo].[Subscription]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDisabled] [bit] NOT NULL CONSTRAINT [DF__Subscript__IsDis__2BFE89A6] DEFAULT ((0)),
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Subscription] ADD CONSTRAINT [PK_Subscription_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Subscription] ADD CONSTRAINT [UQ_SubscriptionNameUnique] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
