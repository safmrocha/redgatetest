SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create FUNCTION [dbo].[DateTimeFromParts] 
( 
@year INT, 
@month INT, 
@day INT, 
@hour INT, 
@minute INT, 
@seconds INT, 
@milliseconds INT 
) 
RETURNS DATETIME 
AS 
BEGIN 
DECLARE @StringDateTime VARCHAR(255) 

SET @StringDateTime = CAST(@year AS VARCHAR) 
+ '-' 
+ CAST(@month AS VARCHAR) 
+ '-' 
+ CAST(@day AS VARCHAR) 
+ ' ' 
+ CAST(@hour AS VARCHAR)	
+ ':' 
+ CAST(@minute AS VARCHAR) 
+ ':' 
+ CAST(@seconds AS VARCHAR) 
+ '.' 
+ CAST(@milliseconds AS VARCHAR)


RETURN CAST(@StringDateTime AS DATETIME)

END

GO
