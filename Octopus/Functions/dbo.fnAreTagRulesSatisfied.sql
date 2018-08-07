SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fnAreTagRulesSatisfied]
(
	@tags NVARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN (
	SELECT * FROM Tenant
	WHERE EXISTS (
		SELECT * FROM
		(
			SELECT COUNT(*) TagSetCount, SUM(HasTag) TagSetsPresent 
			FROM (
				SELECT DISTINCT SUBSTRING(VALUE, 0, CHARINDEX('/', VALUE, 0)) AS TagSetId 
				FROM [fnSplitReferenceCollectionAsTable](@tags)
			) TagSets
			LEFT JOIN (
				SELECT DISTINCT TagSetId, 1 AS HasTag 
				FROM (
					SELECT Value as TagId, SUBSTRING(V.VALUE, 0, CHARINDEX('/', V.VALUE, 0)) as TagSetId
					FROM [fnSplitReferenceCollectionAsTable](TenantTags) AS V
				) AS F
				WHERE TagId IN (
					SELECT Value 
					FROM [fnSplitReferenceCollectionAsTable](@tags)
				)
				GROUP BY TagSetId
			) T ON T.TagSetId =  TagSets.TagSetId
		) X
		WHERE TagSetCount = TagSetsPresent
	)
)
GO
