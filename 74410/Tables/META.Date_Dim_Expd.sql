CREATE TABLE [META].[Date_Dim_Expd]
(
[Calendar_Day_Id] [date] NOT NULL,
[Date_D] [date] NOT NULL,
[First_Day_Of_Month_d] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Last_Day_Of_Month_d] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Days_In_Month_Num] [int] NULL,
[Year_Num] [int] NULL,
[Quarter_Num] [int] NULL,
[Month_Num] [int] NULL,
[Month_Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Week_Of_Year_Num] [int] NULL,
[Full_Week_Of_Month_Num] [int] NULL,
[Day_Of_Year_Num] [int] NULL,
[Day_Of_Month_Num] [int] NULL,
[Day_Of_Week_Num] [int] NULL,
[Day_Of_Week_Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Is_Weekday] [bit] NULL,
[Semi_Annual_Num] [int] NULL
) ON [PRIMARY]
GO
