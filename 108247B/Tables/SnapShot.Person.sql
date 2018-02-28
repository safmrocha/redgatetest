CREATE TABLE [SnapShot].[Person]
(
[SnapShotID] [int] NOT NULL IDENTITY(1, 1),
[SnapShotCreatedDt] [datetime] NOT NULL CONSTRAINT [DF_SnapShot_Person_SnapShotCreatedDt] DEFAULT (getdate()),
[SnapShotStartDt] [datetime] NOT NULL CONSTRAINT [DF_SnapShot_Person_SnapShotStartDt] DEFAULT (getdate()),
[SnapShotEndDt] [datetime] NOT NULL CONSTRAINT [DF_SnapShot_Person_SnapShotEndDt] DEFAULT (CONVERT([datetime],'12/31/9999 23:59:59.997',(0))),
[Id] [int] NOT NULL,
[FirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MiddleInitial] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDt] [datetime] NOT NULL,
[LastModifiedDt] [datetime] NOT NULL
) ON [PRIMARY]
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
CREATE TRIGGER [SnapShot].[trgPersonInsert]   
   ON  [SnapShot].[Person]   
   AFTER INSERT  
AS   
BEGIN  
	-- SET NOCOUNT ON added to prevent extra result sets from  
	-- interfering with SELECT statements.  
	SET NOCOUNT ON;  
  
	UPDATE [SnapShot].[Person]  
	SET SnapShotEndDt = DATEADD(ms,-3,new.SnapShotStartDt)  
	FROM inserted new  
	INNER JOIN [SnapShot].[Person] old ON new.Id = old.Id AND old.SnapShotEndDt = '12/31/9999 23:59:59.997'  
	WHERE new.SnapShotID <> old.SnapShotID  
END
GO
ALTER TABLE [SnapShot].[Person] ADD CONSTRAINT [PK_SnapShot_Person] PRIMARY KEY CLUSTERED  ([SnapShotID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ui_Person_Id_SnapShotStartDt_SnapShotEndDt] ON [SnapShot].[Person] ([Id], [SnapShotStartDt], [SnapShotEndDt]) ON [PRIMARY]
GO
