CREATE TABLE [dbo].[T1]
(
[C1] [int] NOT NULL,
[C15] [int] NULL,
[C2] [int] NULL,
[C3] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T1] ADD CONSTRAINT [PK_T1] PRIMARY KEY CLUSTERED  ([C1]) ON [PRIMARY]
GO
