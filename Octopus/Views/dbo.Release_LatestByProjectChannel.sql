SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[Release_LatestByProjectChannel]
AS
SELECT * FROM (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY ProjectId, ChannelId ORDER BY Assembled desc) as RowNum from Release) rs
	WHERE RowNum = 1
GO
