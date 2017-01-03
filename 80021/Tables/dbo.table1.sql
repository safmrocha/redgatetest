CREATE TABLE [dbo].[table1]
(
[Month] [date] NOT NULL CONSTRAINT [DF_tblName_Month] DEFAULT (dateadd(day,(-1),dateadd(month,(1),datetimefromparts(datepart(year,getdate()),datepart(month,getdate()),(1),(0),(0),(0),(0)))))
) ON [PRIMARY]
GO
