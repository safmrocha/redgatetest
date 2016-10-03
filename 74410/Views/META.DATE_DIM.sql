SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [META].[DATE_DIM]
WITH
     SCHEMABINDING
AS
SELECT
      dde.Calendar_Day_Id AS DATE_ID
     ,dde.Date_D AS DATE_D
     ,dde.First_Day_Of_Month_d AS FIRST_DAY_OF_MONTH_D
     ,dde.Last_Day_Of_Month_d AS LAST_DAY_OF_MONTH_D
     ,dde.Days_In_Month_Num AS DAYS_IN_MONTH_NUM
     ,dde.Year_Num AS YEAR_NUM
     ,dde.Quarter_Num AS QUARTER_NUM
     ,dde.Month_Num AS MONTH_NUM
     ,dde.Month_Name AS MONTH_NAME
     ,dde.Week_Of_Year_Num AS WEEK_OF_YEAR_NUM
     ,dde.Full_Week_Of_Month_Num AS FULL_WEEK_OF_MONTH_NUM
     ,dde.Day_Of_Year_Num AS DAY_OF_YEAR_NUM
     ,dde.Day_Of_Month_Num AS DAY_OF_MONTH_NUM
     ,dde.Day_Of_Week_Num AS DAY_OF_WEEK_NUM
     ,dde.Day_Of_Week_Name AS DAY_NAME
     ,dde.Is_Weekday AS IS_WEEKDAY
     ,dde.Semi_Annual_Num AS SemiAnnual_Num
FROM
      meta.Date_Dim_Expd dde
WHERE
      dde.Day_Of_Month_Num = 1

;
GO
