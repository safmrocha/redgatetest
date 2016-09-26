SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetEmail]
(
	@username varchar(200)
)
RETURNS varchar(200)
AS
BEGIN
	
	DECLARE @email as varchar(200)

	SELECT @email = email from dbo.auctioneerprofiles where username = @username

	RETURN @email

END

GO
