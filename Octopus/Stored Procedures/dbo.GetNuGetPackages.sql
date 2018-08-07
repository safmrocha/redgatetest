SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Previously the NuGet package indexer got its logic for pagination wrong. This patch fixes it.

CREATE PROCEDURE [dbo].[GetNuGetPackages](
	@allowPreRelease bit = 0,
	@packageId nvarchar(250) = '',
	@latestOnly bit = 0,
	@minRow int = 0,
	@maxRow int = 30,
	@partialMatch bit = 0
) AS
BEGIN	
	WITH PackagesCTE AS
	(
		SELECT *, ROW_NUMBER() OVER (Order by RowNumber) as FilteredRowNumber FROM 
		(
			SELECT *, 
				ROW_NUMBER() OVER (PARTITION BY PackageId ORDER BY VersionMajor DESC, VersionMinor DESC, VersionBuild DESC, VersionRevision DESC, CASE WHEN VersionSpecial = '' THEN 0 ELSE 1 END, VersionSpecial DESC) Recency,
		        ROW_NUMBER() OVER (ORDER BY PackageId, VersionMajor DESC, VersionMinor DESC, VersionBuild DESC, VersionRevision DESC, CASE WHEN VersionSpecial = '' THEN 0 ELSE 1 END, VersionSpecial DESC) AS RowNumber
			FROM [NuGetPackage]
			WHERE 
				((@allowPreRelease = 1) or (@allowPreRelease = 0 and VersionSpecial = '')) and
				((@packageId is null or @packageId = '') or (@partialMatch = 0 and PackageId = @packageId) or (@partialMatch = 1 and PackageId LIKE '%' + @packageId + '%'))
		) Packages
		WHERE (@latestOnly = 0 OR (@latestOnly = 1 and Recency = 1))
	)

	SELECT *, (SELECT TC=COUNT(*) FROM PackagesCTE) as TotalCount
		FROM PackagesCTE
		WHERE FilteredRowNumber >= @minRow AND FilteredRowNumber <= @maxRow ORDER BY FilteredRowNumber
END
GO
