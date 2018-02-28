CREATE TABLE [dbo].[Person]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[FirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MiddleInitial] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDt] [datetime] NOT NULL CONSTRAINT [DF_Person_CreatedDt] DEFAULT (getdate()),
[LastModifiedDt] [datetime] NOT NULL CONSTRAINT [DF_Person_LastModifiedDt] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:      Mark Brown
-- Create date: 2/26/2018
-- Description:	Set the last modified date
-- =============================================
CREATE TRIGGER [dbo].[trgPerson_Update] 
   ON  [dbo].[Person] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Person]
	SET LastModifiedDt = CURRENT_TIMESTAMP
	FROM [dbo].[Person] t
	INNER JOIN inserted ins ON t.Id = ins.Id
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================================
-- Author:      Mark Brown
-- Created:     2/26/2018
-- Release:     
-- Description: 
--
-- mm/dd/yy  Name     Release  Description
-- =============================================================
CREATE TRIGGER [dbo].[trgPersonSnapShotDelete]      
ON  [dbo].[Person] AFTER DELETE
AS   
BEGIN   
-- SET NOCOUNT ON added to prevent extra result sets from   
-- interfering with SELECT statements.   
SET NOCOUNT ON;     
	UPDATE [SnapShot].Person   
	SET SnapShotEndDt = CURRENT_TIMESTAMP  
	FROM deleted new    
	INNER JOIN [SnapShot].Person old ON new.Id = old.Id AND old.SnapShotEndDt = '12/31/9999 23:59:59.997'  
END  
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================================
-- Author:      Mark Brown
-- Created:     2/26/2018
-- Release:     
-- Description: 
--
-- mm/dd/yy  Name     Release  Description
-- =============================================================
CREATE TRIGGER [dbo].[trgPersonSnapShotInsertUpdate]      
	ON [dbo].[Person] AFTER INSERT, UPDATE  
AS   
BEGIN   
	-- SET NOCOUNT ON added to prevent extra result sets from   -- interfering with SELECT statements.  
	SET NOCOUNT ON;     
	IF UPDATE(LastModifiedDt)   
	BEGIN    
		INSERT INTO [SnapShot].Person (Id, FirstName, MiddleInitial, LastName, CreatedDt, LastModifiedDt)
		SELECT i.Id, i.FirstName, i.MiddleInitial, i.LastName, i.CreatedDt, i.LastModifiedDt    
		FROM inserted i
	END  
END  
GO
ALTER TABLE [dbo].[Person] ADD CONSTRAINT [PK_Person] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
