CREATE TABLE [dbo].[T2]
(
[C1] [int] NOT NULL,
[C2] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T2] ADD CONSTRAINT [PK_T2] PRIMARY KEY CLUSTERED  ([C1]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T2] ADD CONSTRAINT [FK1] FOREIGN KEY ([C2]) REFERENCES [dbo].[T1] ([C1])
GO
