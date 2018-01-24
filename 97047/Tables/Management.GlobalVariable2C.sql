CREATE TABLE [Management].[GlobalVariable2C]
(
[ClientID] [int] NOT NULL,
[VariableCategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Variable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ValueTypeFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ValueString] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ValueNum] [decimal] (28, 6) NULL,
[ValueDate] [date] NULL,
[ValueBool] [bit] NULL,
[ReadOnly] [bit] NULL CONSTRAINT [DF_GlobalVariable2Client_ReadOnly] DEFAULT ((0)),
[LastUpdated] [datetime] NULL CONSTRAINT [DF_GlobalVariable2Client_LastUpdate] DEFAULT (getdate()),
[rowguid] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF__GlobalVar__rowgu__51DA19CB] DEFAULT (newsequentialid())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Management].[GlobalVariable2C] ADD CONSTRAINT [PK_GlobalVariable2Client] PRIMARY KEY CLUSTERED  ([ClientID], [VariableCategory], [Variable]) ON [PRIMARY]
GO
