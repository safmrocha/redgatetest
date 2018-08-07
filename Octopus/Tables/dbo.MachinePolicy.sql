CREATE TABLE [dbo].[MachinePolicy]
(
[Id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDefault] [bit] NOT NULL CONSTRAINT [DF__MachinePo__IsDef__0F624AF8] DEFAULT ((0)),
[JSON] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MachinePolicy] ADD CONSTRAINT [PK_MachinePolicy_Id] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MachinePolicy] ADD CONSTRAINT [UQ_MachinePolicy] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
