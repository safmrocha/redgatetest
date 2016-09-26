SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[TrimZeros]
(
	@Amount	DECIMAL(18,2)
)
RETURNS VARCHAR(64)
AS
BEGIN
	
	DECLARE @Result VARCHAR(64)
	
	SET @Result = CAST(@Amount AS varchar(64))
	
	IF (CHARINDEX('.', @Result) = 0)
		SET @Result = @Result + '.'
		
	SET @Result = REPLACE(LTRIM(RTRIM(REPLACE(@Result, '0', ' '))), ' ', '0')
		
	IF (CHARINDEX('.', @Result, LEN(@Result)) = LEN(@Result))
		SET @Result = SUBSTRING(@Result, 1, LEN(@Result) - 1)
				
	RETURN @Result
	
END
GO
GRANT EXECUTE ON  [dbo].[TrimZeros] TO [archon\devservice]
GO
GRANT EXECUTE ON  [dbo].[TrimZeros] TO [Archon\ProductionService]
GO
