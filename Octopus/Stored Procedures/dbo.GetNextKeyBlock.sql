SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Alter Procedure GetNextBlock to not return multiple result sets when the first block is requested
CREATE PROCEDURE [dbo].[GetNextKeyBlock] 
(
	@collectionName nvarchar(50),
	@blockSize int
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @result int
	
	UPDATE KeyAllocation
		SET @result = Allocated = (Allocated + @blockSize)
		WHERE CollectionName = @collectionName
	
	if (@@ROWCOUNT = 0)
	begin
		INSERT INTO KeyAllocation (CollectionName, Allocated) values (@collectionName, @blockSize)
		SET @result = @blockSize
	end

	SELECT @result
END
GO
