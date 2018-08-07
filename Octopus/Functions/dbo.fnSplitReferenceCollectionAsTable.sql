SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Thanks to: http://stackoverflow.com/questions/5487961/splitting-of-comma-separated-values
CREATE FUNCTION [dbo].[fnSplitReferenceCollectionAsTable] 
(
    @inputString nvarchar(MAX)
)
RETURNS 
@Result TABLE 
(
    Value nvarchar(200)
)
AS
BEGIN
    DECLARE @chIndex int
    DECLARE @item nvarchar(200)

    WHILE CHARINDEX('|', @inputString, 0) <> 0
    BEGIN
        -- Get the index of the first delimiter.
        SET @chIndex = CHARINDEX('|', @inputString, 0)

        -- Get all of the characters prior to the delimiter and insert the string into the table.
        SELECT @item = SUBSTRING(@inputString, 1, @chIndex - 1)

        IF LEN(@item) > 0
        BEGIN
            INSERT INTO @Result(Value)
            VALUES (@item)
        END

        -- Get the remainder of the string.
        SELECT @inputString = SUBSTRING(@inputString, @chIndex + 1, LEN(@inputString))
    END

    -- If there are still characters remaining in the string, insert them into the table.
    IF LEN(@inputString) > 0
    BEGIN
        INSERT INTO @Result(Value)
        VALUES (@inputString)
    END

    RETURN 
END
GO
