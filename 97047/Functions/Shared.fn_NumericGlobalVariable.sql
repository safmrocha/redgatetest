SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Shared].[fn_NumericGlobalVariable] (@Variable VARCHAR(101))
RETURNS DECIMAL(28, 6)
AS
  BEGIN
	/******************************************
	SELECT Shared.fn_NumericGlobalVariable('Analytics.LockingTimeout')

	TF 3 Mar 2017
	Standardised code and added this header
	******************************************/
	
	DECLARE @Value DECIMAL(28, 6)
			,@VariableCategory VARCHAR(50)
			,@VariableName VARCHAR(50)

	SELECT @VariableCategory = PARSENAME(@Variable, 2)
		  ,@VariableName = PARSENAME(@Variable, 1)
	
	SELECT @Value = ValueNum
	FROM Management.GlobalVariable2C
	WHERE VariableCategory = @VariableCategory
	  AND Variable = @VariableName
	  AND ClientID = Shared.fn_GetClientID()

	RETURN @Value

  END
GO
