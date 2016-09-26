INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('be51a458-ce3c-4314-b5c4-017e2b8ec736', 'Sale Distribution - Step 1', 'A list of auctions for which funds should be distributed', 0, N'select	case 
			when s.StartTime is not null then convert(varchar(10), s.StartTime, 20) 
			else ''Research'' 
		end [Sale], 
		p.AccountNumber, 
		case 
			when a.state = 20 then ''Cancelled'' 
			when a.state = 30 then ''Sold'' 
			else ''Not Sold'' 
		end Status,
		(select top 1 fromstate from cvs.auctionstatehistory h where h.taxsalepropertyid = a.auctionid and tostate = 20 order by createdon desc) CanceledFromState,  
		a.Price,
		(select	amountunpaid
		from	cvs.PrimaryMarketPurchases pmp
				inner join cvs.Purchases pur
					on pur.purchaseid = pmp.purchaseid
		where	pur.status = 0 and pmp.auctionid = a.auctionid) [Amount Due],
		c.ClosingDate,
		coalesce(c.Status, ''Not Scheduled'') [Closing Status],
		a.DistributedToCivicSource,
		a.DistributedToInsurance,
		a.DistributedToClient,
		(SELECT SUM(Revenue) FROM acc.Receivable r WHERE r.Auction = a.AuctionId and DeletedBy is null) AS TotalRevenue,
		p.Address1+'' ''+p.Address2 AS Address,
		p.City
from	cvs.Auctions a
		inner join cvs.Properties p
			on a.PropertyId = p.Id
		left outer join cvs.Sales s
			on a.SaleId = s.SaleId AND SaleType = ''Adj''
		left outer join prodclosing.closing.dbo.package c
			on c.auctionid = a.auctionid		
		left outer join cvs.PrimaryMarketPurchases pmp
			on pmp.auctionid = a.auctionid
		left outer join cvs.Purchases pur
			on pur.purchaseid = pmp.purchaseid 
--where	a.auctiontype = ''adjudication'' and a.state in (20, 30, 40) and a.invoicedon is null and a.auctionid in (select taxsalepropertyid from cvs.auctionstatehistory where tostate > 0)
where a.AuctionType = ''adjudication'' and a.invoicedon is null and ((a.SaleId is not null and a.state in (10, 30, 40) and (a.state = 40 or pur.status = 0)) or a.state = 20)
order by s.StartTime, a.[State], p.accountnumber', 'Sale,Account Number,Status,CanceledFromStatus,Price,Amount Due,Closing Date,Closing Status,DistributedToCivicSource,DistributedToInsurance,DistributedToClient,TotalRevenue,Address,City', 102, 1, NULL, 0, NULL, 0, 1, '2016-08-05 13:14:11.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('b9f750d9-f716-4ded-9768-07134b7cfd08', 'Scheduled but in research adj', 'Accounts that are in research, but scheduled for a sale, possibly erroneously', 0, N'declare @prefix varchar(3)
set @prefix = (select Prefix from civicsource.dbo.taxauthorities ta where safename = REPLACE(db_name(),''CivicSource_'',''''))

select p.accountnumber, cast(s.starttime as date), q.name, res.status
from cvs.auctions a
inner join cvs.Properties p on p.id = a.propertyid
inner join prodresearch.research.res.accounts acc on acc.accountnumber = p.AccountNumber and acc.groupname = @prefix
inner join prodresearch.research.res.researches res on res.propertyid = acc.propertyid
inner join prodresearch.research.res.queues q on q.id = res.queueid
inner join cvs.sales s on s.saleid = a.saleid
where res.Status <> ''Complete'' and a.state = 10 and a.auctiontype = ''Adjudication''
order by p.AccountNumber, q.name', 'Account Number,Sale Date,Research Queue,Research Status', 2, 1, NULL, 0, NULL, 0, 1, '2016-06-06 20:19:07.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('9f946f81-dc73-45a8-95df-073bd75e9edf', 'Campaign Details', 'All letters in the campaign', 0, N'SELECT l.InternalTrackingNumber, ''"''+l.PostalTrackingNumber+''"'', l.Name1, l.Name2, l.Address1, l.Address2, l.City, l.State, l.PostalCode, l.MailedOn, l.ReturnedOn, l.ReturnReason 
from [mail].[Letters] l 
where l.CampaignId = ''<FILTER>''
order by l.InternalTrackingNumber', 'Archon Tracking Number,Postal Tracking Number,Name 1, Name2, Address1, Address2, City, State, Postal Code, Mailed On, Returned On, Return Reason', 27, 1, N'SELECT Name, CampaignID from mail.Campaigns order by CreatedOn desc', 0, 'Campaign', 0, 0, '2016-06-21 13:27:09.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('54186f4a-c998-480d-ab60-0faa3cf4726a', 'Change Order', 'All change orders for each tax authority for the current tax roll', 0, N'/* Movables */
      (SELECT 
         reverse(left(reverse(DB_Name()), charindex(''_'', reverse(DB_Name())) -1)) as DatabaseName,
		 ''"'' + AccountNumber + ''"'',
         Case
            When P.Status = 0 Then ''Paid''
            When P.Status = 1 Then ''Due''
            When P.Status = 2 Then ''Delinquent''
         End,
         P.Type as Type,
         ReferenceNumber,
         BatchNumber,
         PCO.Version,
         RevisedAssessment,
         TaxYear,
         OriginalDescription,
         OriginalExempt,
         OriginalAssessment,
         OriginalExemption,
         OriginalOwnerShare,
         OriginalUnits,
         OriginalQuantity,
         RevisedDescription,
         RevisedExempt,
         RevisedExemption,
         RevisedOwnerShare,
         RevisedUnits,
         RevisedQuantity,
         Replace(Replace(ChangeReason,Char(13),''''),Char(10),'''') as ChangeReason,
         Replace(Replace(PropertyDescription,Char(13),''''),Char(10),'''') as PropertyDescription,
         StatusChangedAt,
         StatusChangedBy,
         SubmittedOn,
         SubmittedBy
      FROM cvs.PropertyChangeOrders as PCO
      Join cvs.Properties as p
         On P.ID = PCO.PropertyID
      where YEAR(StatusChangedAt) = YEAR(GetDate()) and P.PropertyType = 1 and P.Status = 2 and
      accountnumber not in (Select accountnumber From cvs.PropertyExclusions Where ExpiresOn > GetDate())
	  )
	  UNION
      /* Immovables */
      (SELECT 
         reverse(left(reverse(DB_Name()), charindex(''_'', reverse(DB_Name())) -1)) as DatabaseName,
		 ''"'' + AccountNumber + ''"'',
         Case
            When P.Status = 0 Then ''Paid''
            When P.Status = 1 Then ''Due''
            When P.Status = 2 Then ''Delinquent''
         End,
         P.Type as Type,
         ReferenceNumber,
         BatchNumber,
         PCO.Version,
         RevisedAssessment,
         TaxYear,
         OriginalDescription,
         OriginalExempt,
         OriginalAssessment,
         OriginalExemption,
         OriginalOwnerShare,
         OriginalUnits,
         OriginalQuantity,
         RevisedDescription,
         RevisedExempt,
         RevisedExemption,
         RevisedOwnerShare,
         RevisedUnits,
         RevisedQuantity,
         Replace(Replace(ChangeReason,Char(13),''''),Char(10),'''') as ChangeReason,
         Replace(Replace(PropertyDescription,Char(13),''''),Char(10),'''') as PropertyDescription,
         StatusChangedAt,
         StatusChangedBy,
         SubmittedOn,
         SubmittedBy
      FROM cvs.PropertyChangeOrders as PCO
      Join cvs.Properties as p
         On P.ID = PCO.PropertyID
      Join cvs.Auctions as A
         On A.PropertyID = P.ID
	   where YEAR(StatusChangedAt) = YEAR(GetDate()) and A.State = 10 and P.Status = 2
	  )
	  order by DatabaseName, Type', 'DatabaseName, Account Number, Property Status, Property Type, Reference Number, Batch Number, Version, Revised Assessment, Tax Year, Original Description, Original Exempt, Original Assessment, Original Exemption, Original Owner Share, Original Units, Original Quantity, Revised Description, Revised Exempt, Revised Exemption, Revised Owner Share, Revised Units, Revised Quantity, Change Reason, Property Description, Status ChangedAt, Status ChangedBy, SubmittedOn, SubmittedBy', 106, 1, NULL, 0, NULL, 0, 1, '2016-04-27 19:00:18.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('ae25cdb7-4814-407e-9708-11afcd7248bd', 'Sale status summary', 'Sale status summary', 0, N'
SELECT  s.SaleId ,
		s.SaleType,
        CONVERT(VarChar(10),s.StartTime,101) AS StartTime ,
        SUM(CASE WHEN State = 20 THEN 1
                 ELSE 0
            END) AS CanceledCnt ,
        SUM(CASE WHEN State = 30 THEN 1
                 ELSE 0
            END) AS SoldCnt ,
        SUM(CASE WHEN State = 40 THEN 1
                 ELSE 0
            END) AS NotSoldCnt
FROM    cvs.Sales s
        INNER JOIN cvs.Auctions a ON a.SaleId = s.SaleId
WHERE   a.State IN ( 20, 30, 40 )
GROUP BY s.SaleId ,
		s.SaleType,
        s.StartTime;
', 'SaleId,SaleType,StartTime,CanceledCnt,SoldCnt,NotSoldCnt', 4, 1, NULL, 0, NULL, 0, 1, '2016-08-23 21:42:27.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('517aef7f-afd0-4b05-badc-18b536c1d696', '# Properties 4 Sale', 'Number of properties for sale in each TA', 0, N'select count(*) from cvs.auctions where state=10', 'Count', 38, 1, NULL, 0, NULL, 0, 1, '2016-06-28 20:32:37.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('2a131891-8eff-408c-b5ec-1bb2d2d4c359', 'Public Accounts with Occupancy Report Status', 'Report showing account numbers and if there is an occupancy report for that account', 0, N'
SELECT ''"'' + P.AccountNumber + ''"''
,Case
      When (SELECT Count(Da.AttributeValue) 
	           FROM [doc].[Documents] d
               Join doc.DocumentAttributes da On da.DocumentId = d.DocumentId and Da.AttributeName = ''Account Number''
               where d.DocumentTypeId = (Select DocumentTypeID 
			                                From doc.DocumentTypes DT 
											Where DT.Name = ''Occupancy Report'')  and Da.AttributeValue = P.AccountNumber) > 0 Then ''X''
	  Else ''''
  End [Occupancy Report]
  FROM [cvs].[Auctions] A
  Join cvs.Properties P on P.ID = A.PropertyID
  Where A.State = 1
  ', 'AccountNumber,Occupancy Report', 3, 1, NULL, 0, NULL, 0, 1, '2016-07-11 17:21:07.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('f9999da7-3230-4d88-8531-1f99a7fcc1b4', 'Campaign Letter Count Report', 'Shows all accounts that were sent letters and a count of how many letters per account', 0, N'
SELECT ''"'' + Replace(DataAccountNumber,''.i'','''') + ''"'' [Account Number],
       CONVERT(VarChar(10),MailedOn,101),
       Count(*) [Letter Count]
  FROM [mail].[Letters]
  where CampaignID = ''<FILTER>''
  group by DataAccountNumber,MailedOn
  Order by DataAccountNumber,MailedOn
  ', 'AccountNumber,Mailed On,Letter Count', 13, 1, N'
SELECT Name, CampaignID from mail.Campaigns order by CreatedOn desc
  ', 0, 'Mail Campaign', 0, 0, '2016-05-20 20:50:29.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('0d2624ab-5b6f-4af2-9380-24b5231126db', 'Current month campaigns count', 'Count of current month campaigns (not cancelled), by type', 0, N'select Iscertified, state, sum(expectedcount) from mail.campaigns
		where year(shouldbemailedby) = year(getdate()) and month(shouldbemailedby) = month(getdate())
		and state <> 8
		group by iscertified, state', 'IsCertified,State,Count', 12, 1, NULL, 0, NULL, 0, 1, '2016-08-19 20:34:20.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('116cd310-788e-43e9-a4ac-2a6b573417e2', 'Auctioneer Users Created', 'Count of # of Auctioneer user profiles created per day (after 10/9/2014)', 0, N'/****** Script for SelectTopNRows command from SSMS  ******/
SELECT CAST(CAST(CreatedOn AS DATE) AS VARCHAR(10)), COUNT(*)
  FROM [CivicSource].[dbo].[AuctioneerProfiles]
  GROUP BY CAST(CAST(CreatedOn AS DATE) AS VARCHAR(10))
  ORDER BY CAST(CAST(CreatedOn AS DATE) AS VARCHAR(10)) DESC', 'Day,Count', 25, 1, NULL, 0, NULL, 0, 0, '2016-07-06 20:05:26.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('8108688c-3fe5-4b6f-9c13-30291c9d2e14', 'Not sold auctions with depositors', 'Shows who placed a deposit, then didn''t bid', 0, N'select ''"'' + p.accountnumber + ''"'' as ''Account Number'', 
civicsource.dbo.getemail(purch.username) as ''Depositor'', 
convert(varchar(10), cast(s.StartTime as date), 101) as ''Sale Date'', 
a.lotnumber as ''Lot Number'', 
case when b.canceledby is null then ''No'' else ''Yes'' END ''Bid Placed'', 
case when b.canceledby is null then '''' else b.canceledby END ''Bid Canceled By'', 
case when b.canceledreason is null then '''' else b.canceledreason END ''Bid Cancellation Reason''
from cvs.auctions a
inner join cvs.properties p on p.id = a.propertyid
inner join cvs.deposits d on d.auctionid = a.auctionid
inner join cvs.sales s on s.saleid = a.saleid
inner join cvs.purchasers purch on purch.purchaserid = d.PurchaserId
left join (select auctionid, bidder, max(createdat) createdat, canceledby, canceledreason
		   from PRODAUCTION.auction.dbo.bid
		   group by auctionid, canceledby, canceledreason, bidder) b on b.bidder = purch.username and b.auctionid = a.auctionid
where a.state = 40 and d.cancelledby is null
order by accountnumber, s.starttime
', 'Account Number,Depositor,Sale Date,Lot Number,Bid Placed,Bid Canceled BY,Bid Cancellation Reason', 2, 1, NULL, 0, NULL, 0, 1, '2016-08-01 16:22:43.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('9b69d3cf-b922-4330-b418-347adabfc697', 'Adjudicated Deposit History', 'All adjudicated property auction deposits since the beginning.', 0, N'Select	
   P.AccountNumber,
   P.Address1 + '' '' + P.Address2 [Address], 
   LTrim(P.City + '' '' + P.State + '' '' + P.PostalCode), 
   IsNull(Convert(VarChar(10),r.DepositMadeOn,101),'''') [Deposit Date]
From cvs.Auctions a 
inner join cvs.Properties p on a.PropertyId = p.Id 
inner join cvs.Deposits r on r.AuctionId = a.AuctionId 
Where	a.AuctionType = ''Adjudication'' 
order by r.depositmadeon', 'Account Number,Address,,Deposit Date', 26, 1, NULL, 0, NULL, 0, 1, '2016-08-29 14:15:46.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('34515d54-68a7-40c8-9127-34aee6d368ba', '# Adj Purchasers by State', 'Louisiana-based adjudication purchasers', 0, N'select ap.state, count(distinct ap.username)
from CivicSource.dbo.AuctioneerProfiles ap
inner join cvs.purchasers pu on pu.username = ap.username
inner join cvs.Purchases purch on purch.Purchaser = pu.PurchaserId
inner join cvs.primarymarketpurchases pmp on pmp.PurchaseId = purch.PurchaseId
inner join cvs.Auctions a on a.auctionid = pmp.auctionid
inner join cvs.Properties p on p.id = a.propertyid
where a.auctiontype = ''adjudication'' and a.state = 30
and purch.Status = 0
group by ap.State', 'State,Count', 9, 1, NULL, 0, NULL, 0, 1, '2016-08-10 15:11:12.000', '1', NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('99ff9bcd-195c-46ac-b6b1-488cdf564022', 'Adjudication Purchasers', 'Total purchases for users across all TAs', 0, N'select ap.FirstName, ap.LastName, ap.Email, count(*)
from cvs.auctions a
inner join cvs.PrimaryMarketPurchases pmp on pmp.auctionid = a.auctionid
inner join cvs.Purchases purch on pmp.purchaseid = purch.PurchaseId
inner join cvs.Purchasers purchaster on purch.Purchaser = purchaster.PurchaserId
inner join CivicSource.dbo.auctioneerprofiles ap on ap.username = purchaster.username
where a.auctiontype = ''adjudication'' and purch.status = 0
group by ap.FirstName, ap.LastName, ap.Email
order by count(*) desc', 'First Name,Last Name,Email,#Purchases', 8, 1, NULL, 0, NULL, 0, 1, '2016-08-10 15:11:24.000', '1,2,3', NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('f896512a-39f1-4c23-b3c7-55fb827193d2', 'Movable Status Changes', 'Movable status changes, filtered by a date range', 0, N'SELECT p.AccountNumber, pn.StatusChangeName, pn.Note, pn.CreatedOn
  FROM [cvs].[PropertyNotes] pn
  inner join cvs.Properties p
  on p.Id = pn.PropertyId
  where StatusChangeName is not null and p.PropertyType = 1
  and CreatedOn >= ''<START>'' and CreatedOn <= ''<END>''
  order by AccountNumber, CreatedOn', 'Account Number,Status,Note,Date', 27, 1, NULL, 0, NULL, 1, 0, '2016-08-10 15:38:06.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('f06c1b53-aebc-4747-8d97-5c3f1f15fda5', 'Expired Bankruptcy Exclusions', 'Expired Bankruptcy Exclusions', 0, N'select 
replace(db_name(),''civicsource_'',''''), AccountNumber, case propertytype when 0 then ''Immovable'' else ''Movable'' end, ExpiresOn, Source
  FROM [cvs].[PropertyExclusions]
  where type like ''%Bankruptcy%'' and ExpiresOn < getDate()
  order by propertyType, AccountNumber', 'Taxing Authority,Account Number,Property Type,Expiration,Source', 6, 1, NULL, 0, NULL, 0, 1, '2016-04-27 19:02:00.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('81452706-8214-42f5-9bb3-6a574563230b', 'Archon From The Beginning', 'Auctions Listed, Sold Auctions, Number of Bids since Archon started', 0, N'SELECT  ( SELECT    SUM(cnt.cnt) cnt
          FROM      ( SELECT    COUNT(DISTINCT ( p.AccountNumber )) cnt
                      FROM      [mail].[Campaigns] c
                                INNER JOIN mail.Letters l ON l.CampaignId = c.CampaignId
                                INNER JOIN doc.DocumentEntityRelationships der ON der.DocumentId = l.CreatedDocument
                                INNER JOIN cvs.Properties p ON p.Id = der.PropertyId
                      WHERE     c.State = 7
                                AND Name NOT LIKE ''%party%''
                                AND Name NOT LIKE ''% movable%''
                                AND Name NOT LIKE ''%post%''
                                AND Name NOT LIKE ''%statement%%''
                      GROUP BY  YEAR(c.MailedOn)
                    ) cnt
        ) ,
        ( SELECT    COUNT(*)
          FROM      cvs.Auctions a
                    INNER JOIN cvs.Sales ts ON ts.SaleId = a.SaleId
                                               AND ts.SaleType = ''Tax''
        ) ,
        ( SELECT    COUNT(*) total
          FROM      cvs.Auctions a2
                    INNER JOIN cvs.Sales ts2 ON ts2.SaleId = a2.SaleId
                                                AND ts2.SaleType = ''Tax''
          WHERE     State IN ( 30, 40 )
                    OR ( State = 20
                         AND a2.AuctionId IN (
                         SELECT TaxSalePropertyId
                         FROM   cvs.AuctionStateHistory
                         WHERE  TaxSalePropertyId = a2.AuctionId
                                AND CreatedOn > ts2.StartTime )
                       )
                    OR ( State = 20
                         AND YEAR(ts2.StartTime) < 2009
                       )
        ) ,
        ( SELECT    COUNT(*) one
          FROM      cvs.Auctions sold
          WHERE     sold.State = 30
        ) ,
        ( SELECT    COUNT(*) total
          FROM      PRODAUCTION.auction.dbo.bid bids
                    INNER JOIN cvs.Auctions a WITH (FORCESEEK) ON bids.AuctionId = a.AuctionId
                    INNER JOIN cvs.Sales ts WITH (FORCESEEK) ON ts.SaleId = a.SaleId
                                               AND ts.SaleType = ''Tax''
        )', 'Properties Noticed, Auctions Created, Auctions In Sale, Sold Auctions, Number of Bids', 38, 1, NULL, 0, NULL, 0, 1, '2016-08-10 23:59:25.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('449eba1d-3b42-40e6-bafc-6a86dff9183c', 'Adjudicated Deposit Aging', 'Adjudication property auctions in the researching and research complete stage with deposit date and hold status', 0, N'
Select	
   ''"'' + P.AccountNumber + ''"'', 
   P.Address1 + '' '' + P.Address2,
   P.Latitude, 
   P.Longitude, 
   LTrim(P.City + '' '' + P.State + '' '' + P.PostalCode), 
   IsNull(Convert(VarChar(10),r.DepositMadeOn,101),''''), 
   IsNull(ap.Email,''''), 
   Case When a.IsHeld = 1 then ''Yes'' 
        Else ''No'' 
   End, 
   Case When a.IsHeld = 1 then Convert(VarChar(10),h.TriggeredOn,101) 
        Else '''' 
   End, 
   Case When a.IsHeld = 1 then h.Reason 
        Else '''' 
   End, 
   Case When a.IsHeld = 1 then h.Username 
        Else '''' 
   End, 
   Case When r.IsAdjoiningLandowner = 1 Then ''Yes'' 
        Else ''No'' 
   End, 
   Case When A.State = 0 Then ''Candidate''
        When A.State = 1 Then ''Public''
        When A.State = 2 Then ''Researching''
        When A.State = 3 Then ''Research Complete''
		When A.State = 10 Then ''For Sale'' 
   End, 
   IsNull(Convert(VarChar(10),ads.StartTime,101),'''') 
From cvs.Auctions a 
inner join cvs.Properties p on a.PropertyId = p.Id 
Left join cvs.Deposits r on r.AuctionId = a.AuctionId 
Left join cvs.Purchasers pur on pur.PurchaserId = r.PurchaserId 
Left join CivicSource.dbo.AuctioneerProfiles ap on ap.Username = pur.Username 
left outer join (select	row_number() over(Partition by AuctionId order by TriggeredOn desc) Num, HoldHistoryId, AuctionId, Reason, Username, TriggeredOn from cvs.HoldHistory) h on h.AuctionId = a.AuctionId and h.Num = 1 
Join CivicSource.dbo.TaxAuthorities TA On TA.SafeName = (Select Replace(DB_Name(),''CivicSource_'','''')) 
left outer Join cvs.Sales ads On ads.SaleID = A.SaleID AND SaleType = ''Adj''
Where	a.AuctionType = ''Adjudication'' and a.[State] in (0,1,2,3,10) and (ads.StartTime is Null or ads.StartTime >= GetDate()) 
Order by r.DepositMadeOn
  ', 'Account Number,Property Address,Latitude,Longitude,Property City,Deposit Made On,Deposit Made By,Is Held,Held On,Reason,Held By,Adjoining,Auction State,Sale Date', 317, 1, NULL, 0, NULL, 0, 1, '2016-08-08 15:50:16.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('3ed23a22-257b-4975-b732-6ceb27df911e', 'Not Sold Properties', 'All not sold properties by year', 0, N'SELECT CONVERT(VARCHAR(10), s.StartTime, 101) AS [Sale Date],''"'' + P.AccountNumber + ''"'' AS [Account Number],p.Address1 AS [Address],''$'' + CONVERT(varchar(20), CONVERT(money,ISNULL(SUM(pt.Total),0)),1) AS [Delinquency Amount] FROM cvs.Auctions a
inner join cvs.Properties p on p.Id = a.PropertyId
INNER JOIN cvs.Sales s ON s.SaleId = a.SaleId
left join cvs.PropertyTaxes pt  on pt.PropertyId = p.Id AND pt.Status = 2  
WHERE a.state = 40 
AND a.AuctionType = ''Adjudication''
AND year(s.StartTime) = ''<FILTER>''
GROUP BY s.StartTime, p.AccountNumber, p.Address1', 'Sale Date,Account Number,Address,Delinquency Amount', 3, 1, N'with yearlist as 
(
    select 2013 as year
    union all
    select yl.year + 1 as year
    from yearlist yl
    where yl.year + 1 <= YEAR(GetDate())
)
select cast(year as varchar(50)) AS name, year as year from yearlist order by year DESC', 0, 'Year', 0, 1, '2016-08-09 16:32:43.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('51efc434-e995-4a6a-ab60-6fcf274e0dd3', 'Tax Sale Cost - Verification', 'Compairs tax sale cost on the auctions to tax sale cost on the properties', 0, N'
Select
   ''"'' + P.AccountNumber + ''"'',
   Case
      When A.State = 10 Then ''For Sale''
	  When A.State = 30 Then ''Sold''
	  When A.State = 40 Then ''Not Sold''
   End [AuctionState],
   TT.TaxCode,
   TT.Name,
   ST.Year,
   ST.Total [TTotal],
   (Select Top 1 PTV.Total 
                 From cvs.PropertyTaxVersions PTV 
                 Join cvs.PropertyTaxes PT on PT.Id = PTV.TaxId
                 Where PT.PropertyID = P.ID and 
				       PT.Year = ST.Year and 
					   PT.TaxTypeID = TT.TaxTypeId and 
					   PTV.Status = 2
			     Order by ChangeDate Desc)
FROM [cvs].[Auctions] A
Join cvs.SellableTaxes ST on ST.TaxSalePropertyID = A.AuctionID
Join cvs.Properties P on P.ID = A.PropertyID
Join cvs.TaxTypes TT on TT.TaxTypeId = ST.TaxTypeID
Where A.SaleID = ''<FILTER>'' and A.State In (10,30,40) and TT.Category = 5
Order by AccountNumber, ST.Year, TaxCode
', 'Account Number,Auction State,Tax Code,Tax Name,Tax Year,Tax Sale Total,Property Total', 108, 1, N'SELECT LEFT(DATENAME(m, ts.StartTime), 3) + '' '' + DATENAME(yyyy, StartTime)
        + '' Tax Sale'' AS Name ,
        ts.SaleId
FROM    cvs.Sales ts
WHERE   SaleType = ''tax''
ORDER BY EndTime DESC', 0, 'Tax Sale', 0, 0, '2016-08-30 19:11:28.000', NULL, NULL)
EXEC(N'INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES (''18835eba-d545-409d-91bf-745204cfc56e'', ''Research Progress'', ''Counts of research items completed going back 30 days per queue type'', 0, N''
  SELECT ''''Date'''' as QueueType
  ,cast(dateadd(day,-30,CONVERT(date, getdate())) AS VARCHAR(10)) as [-30] 
  ,cast(dateadd(day,-29,CONVERT(date, getdate())) AS VARCHAR(10)) as [-29]
  ,cast(dateadd(day,-28,CONVERT(date, getdate())) AS VARCHAR(10)) as [-28]
  ,cast(dateadd(day,-27,CONVERT(date, getdate())) AS VARCHAR(10)) as [-27]
  ,cast(dateadd(day,-26,CONVERT(date, getdate())) AS VARCHAR(10)) as [-26]
  ,cast(dateadd(day,-25,CONVERT(date, getdate())) AS VARCHAR(10)) as [-25]
  ,cast(dateadd(day,-24,CONVERT(date, getdate())) AS VARCHAR(10)) as [-24]
  ,cast(dateadd(day,-23,CONVERT(date, getdate())) AS VARCHAR(10)) as [-23]
  ,cast(dateadd(day,-22,CONVERT(date, getdate())) AS VARCHAR(10)) as [-22]
  ,cast(dateadd(day,-21,CONVERT(date, getdate())) AS VARCHAR(10)) as [-21]
  ,cast(dateadd(day,-20,CONVERT(date, getdate())) AS VARCHAR(10)) as [-20]
  ,cast(dateadd(day,-19,CONVERT(date, getdate())) AS VARCHAR(10)) as [-19]
  ,cast(dateadd(day,-18,CONVERT(date, getdate())) AS VARCHAR(10)) as [-18]
  ,cast(dateadd(day,-17,CONVERT(date, getdate())) AS VARCHAR(10)) as [-17]
  ,cast(dateadd(day,-16,CONVERT(date, getdate())) AS VARCHAR(10)) as [-16]
  ,cast(dateadd(day,-15,CONVERT(date, getdate())) AS VARCHAR(10)) as [-15]
  ,cast(dateadd(day,-14,CONVERT(date, getdate())) AS VARCHAR(10)) as [-14]
  ,cast(dateadd(day,-13,CONVERT(date, getdate())) AS VARCHAR(10)) as [-13]
  ,cast(dateadd(day,-12,CONVERT(date, getdate())) AS VARCHAR(10)) as [-12]
  ,cast(dateadd(day,-11,CONVERT(date, getdate())) AS VARCHAR(10)) as [-11]
  ,cast(dateadd(day,-10,CONVERT(date, getdate())) AS VARCHAR(10)) as [-10]
  ,cast(dateadd(day,-9,CONVERT(date, getdate())) AS VARCHAR(10)) as [-9]
  ,cast(dateadd(day,-8,CONVERT(date, getdate())) AS VARCHAR(10)) as [-8]
  ,cast(dateadd(day,-7,CONVERT(date, getdate())) AS VARCHAR(10)) as [-7]
  ,cast(dateadd(day,-6,CONVERT(date, getdate())) AS VARCHAR(10)) as [-6]
  ,cast(dateadd(day,-5,CONVERT(date, getdate())) AS VARCHAR(10)) as [-5]
  ,cast(dateadd(day,-4,CONVERT(date, getdate())) AS VARCHAR(10)) as [-4]
  ,cast(dateadd(day,-3,CONVERT(date, getdate())) AS VARCHAR(10)) as [-3]
  ,cast(dateadd(day,-2,CONVERT(date, getdate())) AS VARCHAR(10)) as [-2]
  ,cast(dateadd(day,-1,CONVERT(date, getdate())) AS VARCHAR(10)) as [-1]
  ,CAST(CONVERT(date, getdate()) AS varchar(10)) as Today
  union
  SELECT ''''Abstractors'''' as QueueType
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-30,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-30]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-29,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-29]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-28,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-28]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-27,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-27]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-26,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-26]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-25,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-25]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-24,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-24]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-23,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-23]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-22,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-22]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-21,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-21]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-20,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-20]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = datead'', ''QueueType,-30,-29,-28,-27,-26,-25,-24,-23,-22,-21,-20,-19,-18,-17,-16,-15,-14,-13,-12,-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1'', 9, 1, NULL, 0, NULL, 0, 2, ''2016-08-13 23:39:17.000'', NULL, NULL)')
EXEC(N'UPDATE [dbo].[DataExports] SET [Query].WRITE(N''d(day,-19,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-19]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-18,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-18]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-17,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-17]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-16,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-16]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-15,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-15]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-14,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-14]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-13,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-13]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-12,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-12]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-11,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-11]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-10,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-10]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-9,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-9]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-8,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-8]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-7,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-7]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-6,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-6]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-5,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-5]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-4,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-4]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-3,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-3]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-2,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-2]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-1,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-1]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = CONVERT(date, getdate()) then 1 else 0 end)AS VARCHAR(10)) as Today
  from PRODRESEARCH.research.[res].[Researches] r inner join PRODRESEARCH.research.[res].[Queues] q on q.id = r.queueid
  where q.name like ''''%Abstractors%''''
  union 
  select ''''Examiners'''' as QueueType
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-30,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-30]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-29,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-29]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-28,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-28]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-27,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-27]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-26,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-26]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-25,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-25]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-24,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-24]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-23,CONVERT(date, getdate())) then 1 else 0 en'',NULL,NULL) WHERE [Id] = ''18835eba-d545-409d-91bf-745204cfc56e''
UPDATE [dbo].[DataExports] SET [Query].WRITE(N''d)AS VARCHAR(10)) as [-23]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-22,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-22]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-21,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-21]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-20,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-20]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-19,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-19]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-18,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-18]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-17,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-17]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-16,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-16]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-15,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-15]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-14,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-14]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-13,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-13]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-12,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-12]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-11,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-11]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-10,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-10]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-9,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-9]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-8,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-8]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-7,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-7]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-6,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-6]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-5,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-5]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-4,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-4]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-3,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-3]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-2,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-2]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-1,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-1]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = CONVERT(date, getdate()) then 1 else 0 end)AS VARCHAR(10)) as Today
  from PRODRESEARCH.research.[res].[Researches] r inner join PRODRESEARCH.research.[res].[Queues] q on q.id = r.queueid
  where q.name like ''''%Examiners%''''
  union 
  select ''''Skiptracers'''' as QueueType
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-30,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-30]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-29,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-29]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-28,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-28]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-27,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-27]
  , CAST(SUM(case when C'',NULL,NULL) WHERE [Id] = ''18835eba-d545-409d-91bf-745204cfc56e''
UPDATE [dbo].[DataExports] SET [Query].WRITE(N''ONVERT(date, r.CompletedOn) = dateadd(day,-26,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-26]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-25,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-25]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-24,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-24]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-23,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-23]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-22,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-22]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-21,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-21]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-20,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-20]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-19,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-19]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-18,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-18]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-17,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-17]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-16,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-16]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-15,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-15]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-14,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-14]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-13,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-13]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-12,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-12]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-11,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-11]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-10,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-10]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-9,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-9]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-8,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-8]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-7,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-7]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-6,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-6]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-5,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-5]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-4,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-4]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-3,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-3]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-2,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-2]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-1,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-1]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = CONVERT(date, getdate()) then 1 else 0 end)AS VARCHAR(10)) as Today
  from PRODRESEARCH.research.[res].[Researches] r inner join PRODRESEARCH.research.[res].[Queues] q on q.id = r.queueid
  where q.name like ''''%Skiptracers%''''
  union 
  select ''''IP Researchers'''' as QueueType
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-30,C'',NULL,NULL) WHERE [Id] = ''18835eba-d545-409d-91bf-745204cfc56e''
UPDATE [dbo].[DataExports] SET [Query].WRITE(N''ONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-30]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-29,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-29]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-28,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-28]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-27,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-27]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-26,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-26]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-25,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-25]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-24,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-24]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-23,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-23]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-22,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-22]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-21,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-21]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-20,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-20]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-19,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-19]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-18,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-18]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-17,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-17]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-16,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-16]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-15,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-15]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-14,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-14]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-13,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-13]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-12,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-12]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-11,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-11]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-10,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-10]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-9,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-9]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-8,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-8]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-7,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-7]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-6,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-6]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-5,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-5]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-4,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-4]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-3,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-3]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = dateadd(day,-2,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-2]
  , CAST(SUM('
+N'case when CONV'',NULL,NULL) WHERE [Id] = ''18835eba-d545-409d-91bf-745204cfc56e''
UPDATE [dbo].[DataExports] SET [Query].WRITE(N''ERT(date, r.CompletedOn) = dateadd(day,-1,CONVERT(date, getdate())) then 1 else 0 end)AS VARCHAR(10)) as [-1]
  , CAST(SUM(case when CONVERT(date, r.CompletedOn) = CONVERT(date, getdate()) then 1 else 0 end)AS VARCHAR(10)) as Today
  from PRODRESEARCH.research.[res].[Researches] r inner join PRODRESEARCH.research.[res].[Queues] q on q.id = r.queueid
  where q.name like ''''%IP Researchers%''''
'',NULL,NULL) WHERE [Id] = ''18835eba-d545-409d-91bf-745204cfc56e''
')
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('f90e193e-c982-4ff1-8f26-7608a4eec1ff', 'Delinquent Movable Taxes by Year', 'All delinquent taxes for movable properties, including year.', 0, N'SELECT   p.AccountNumber,   p.Address1,   p.Address2,  
dbo.GetPropertyOwnerName(o.PropertyOwnerId),
poa.Address1,  poa.Address2,  poa.City,  poa.PostalCode,  pt.Year,  ''$'' + CONVERT(varchar(20), CONVERT(money,pt.Total),1)  
FROM cvs.Properties p  inner JOIN cvs.PropertyOwners o  on o.PropertyId = p.Id  
inner join cvs.PropertyOwnerAddresses poa   on poa.PropertyOwnerId = o.PropertyOwnerId and poa.Source = 2  
inner join cvs.PropertyTaxes pt  on pt.PropertyId = p.Id  WHERE p.PropertyType = 1 AND p.AmountDue > 0 and pt.Status = 2  
ORDER BY p.AccountNumber, pt.Year', 'Account Number,Property Address,Property Address2,Owner Names,Owner Address1,Owner Address2,Owner City,Owner Zip,Tax Year,Delinquency', 82, 1, NULL, 0, NULL, 0, 0, '2016-07-15 16:29:25.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('23b8ac48-cfd8-4358-b73e-76b323500682', 'Letter Count', 'A count of mailed letters grouped by sale type, month, year and mail class.', 0, N'with sales as (select LetterId, l.CampaignId, case when SaleType is NULL 
	then ''Tax Sale''
	else ''Adjudication Sale''
	end SaleType
 from mail.Letters l left join cvs.Sales adj on adj.CampaignId = l.CampaignId OR adj.CertifiedCampaignId = l.CampaignId)
select 
	s.SaleType,
	datepart(m, MailedOn) [Month], 
	datepart(yy, MailedOn) [Year],
	case c.IsCertified
	when 1 then ''Certified''
	else ''First Class''
	end MailClass,
	count(LetterId) MailCount
 from sales s join mail.Campaigns c on s.CampaignId = c.CampaignId 
 where c.[State] in (6,7) --Sent to mailhouse or mailed
 group by SaleType, datepart(m, MailedOn), datepart(yy, MailedOn), c.IsCertified
 order by [Year], [Month]', 'Sale Type, Month, Year, Mail Class, Mail Count', 31, 1, NULL, 0, NULL, 0, 1, '2016-08-22 15:34:47.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('b78b812b-c507-4e08-906f-7a74197d1091', 'Sale Distribution - Step 2', 'A list of auctions and associated costs to be distributed', 0, N'-- =================================================================
-- Build columns that sum each activity''s revenue for selects later in this script.
-- =================================================================
DECLARE @Cols CURSOR;
DECLARE @Col varchar(max);
DECLARE @Sql nvarchar(max);
set @Sql = ''''
BEGIN
    SET @Cols = CURSOR FOR
		select	''(select cast(isnull(sum(r.Revenue), 0) as varchar(500)) from acc.Receivable r where r.Auction = a.AuctionId and r.Code = '''''' + cast(a.Code as varchar(10)) + '''''' and (a.State = 30 or r.IncurredOn is not null)) ['' + cast(a.Code as varchar(10)) + '' '' + a.Name + ''],''
		from CivicSource.acc.Activity a
		order by Code   
    OPEN @Cols 
    FETCH NEXT FROM @Cols 
    INTO @Col
    WHILE @@FETCH_STATUS = 0
    BEGIN
		SET @Sql = @Sql + @Col
		FETCH NEXT FROM @Cols 
		INTO @Col 
    END; 
    CLOSE @Cols ;
    DEALLOCATE @Cols;
END;
-- Remove trailing comma
set @Sql = substring(@Sql, 0, len(@Sql))

DECLARE @AllValues NVARCHAR(max)
SELECT @AllValues = COALESCE(@AllValues + '','', '''') + ''''''''+CAST(code AS VARCHAR(50))+'' ''+REPLACE(name,'''''''','''''''''''')+'''''''' 
FROM  CivicSource.acc.Activity ORDER BY code
SELECT @AllValues = ''Select ''''Sale'''',''''AuctionNumber'''',''''AccountNumber'''',''''Status'''',''''CanceledFromState'''',''''Price'''',''''AmountDue'''',''''DistributedToCivicSource'''',''''DistributedToInsurance'''',''''DistributedToClient'''',''''Costs'''','' +@AllValues +''
UNION
''

--==================================================================
-- Build sold, not sold and canceled sql
--==================================================================
 set @Sql = @AllValues+''select	isnull(convert(varchar(10), s.starttime, 20), ''''None'''') Sale,
		a.LotNumber,
		p.AccountNumber,
		case 
			when a.state = 20 then ''''Canceled'''' 
			when a.state in (10, 30) then ''''Sold''''
			else ''''Not Sold'''' 
		end Status, 
		CAST(ISNULL((select top 1 fromstate from cvs.auctionstatehistory h where h.taxsalepropertyid = a.auctionid and tostate = 20 order by createdon desc), 0) AS VARCHAR(500)) CanceledFromState,  
		CAST(case when pur.PurchaseId is null then 0 else a.Price END AS VARCHAR(500)) Price,
		CAST(ISNULL(pur.AmountUnpaid, 0) AS VARCHAR(500)) AmountDue,
		CAST(a.DistributedToCivicSource AS VARCHAR(500)),
		CAST(a.DistributedToInsurance AS VARCHAR(500)),
		CAST(a.DistributedToClient AS VARCHAR(500)),
		'''''''' Costs,
'' + @Sql + ''
from	cvs.Auctions a
		inner join cvs.Properties p
			on a.PropertyId = p.Id
		left outer join cvs.Sales s
			on s.saleid = a.saleid AND SaleType = ''''Adj''''
		left outer join cvs.PrimaryMarketPurchases pmp
			on pmp.auctionid = a.auctionid
		left outer join cvs.Purchases pur
			on pur.purchaseid = pmp.purchaseid 
where a.AuctionType = ''''adjudication'''' and a.invoicedon is null and ((a.SaleId is not null and a.state in (10, 30, 40) and (a.state = 40 or pur.status = 0)) or a.state = 20)
order by 1 desc,4,3''
--select @Sql
exec sp_executesql @Sql

', '', 43, 1, NULL, 0, NULL, 0, 0, '2016-08-30 22:11:16.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('34c92823-001a-4129-ba2e-81a7dd4f1a56', 'Public auctions with active exclusions', 'Auctions in a public-facing status with active exclusions', 0, N'
select ''"'' + p.AccountNumber + ''"'',
case when a.state = 1 then ''Public''
     when a.state = 2 then ''Researching''
	 when a.state = 3 then ''Research Complete''
	 when a.state = 10 then ''For Sale''
else ''Unkown Status'' END
from cvs.Properties p
inner join cvs.auctions a on a.propertyid = p.id and a.auctiontype = ''Adjudication''
where a.state not in (0,20,30,40)
and exists (select pe.AccountNumber from cvs.PropertyExclusions pe
            where pe.accountnumber = p.accountnumber
			      and pe.PropertyType = p.PropertyType
				  and pe.ExpiresOn > getdate())
', 'Account Number,Auction Status', 15, 1, NULL, 0, NULL, 0, 1, '2016-05-25 16:33:59.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('a7629a8b-f0e4-4564-8296-86487543ae58', 'Delinquent Immovable Properties - Call Lists', 'All immovable properties that have an amount due greater than zero with owner contact information', 0, N'/****** Script for SelectTopNRows command from SSMS ******/
SELECT p.AccountNumber,
dbo.GetPropertyOwnerName(p.PropertyOwnerId) ''Owner Name'',
CASE WHEN poa.Address1 is null or LEN(poa.Address1) = 0 then '''' else poa.Address1 + '', '' end
+ CASE WHEN poa.Address2 is null or LEN(poa.Address2) = 0 then '''' else poa.Address2 + '', '' end
+ CASE WHEN poa.City is null or LEN(poa.City) = 0 then '''' else poa.City + '', '' end
+ CASE WHEN poa.State is null or LEN(poa.State ) = 0 then '''' else poa.State + '' '' end
+ CASE WHEN poa.PostalCode is null or LEN(poa.PostalCode) = 0 then '' '' else poa.PostalCode + '', '' end
+ CASE WHEN poa.Country is null or LEN(poa.Country ) = 0 then '' '' else poa.Country end ''Owner Address'',
coll.Balance ''Balance'',
CASE WHEN coll.PropertyId is null then ''No'' else ''Yes'' END ''Collection Fee''
  FROM [cvs].[Properties] p
  inner join cvs.PropertyOwners po on po.PropertyOwnerId = p.PropertyOwnerId
  inner join cvs.PropertyOwnerAddresses poa on poa.PropertyOwnerId = po.PropertyOwnerId and poa.AddressIndex = 0
  left outer join (
select pt.PropertyId, SUM(pt.Balance) as ''Balance'' from cvs.PropertyTaxes pt
inner join cvs.TaxTypes tt on tt.TaxTypeId = pt.TaxTypeId
where tt.Category = 5 or pt.Collection > 0
group by pt.PropertyId) coll on coll.PropertyId = p.Id
  where p.PropertyType = 0 and p.Status = 2 and p.IsBankrupt = 0 and p.IsAdjudicated = 0
  order by p.AccountNumber', 'Account Number, Owner Name, Owner Address, Balance, Collection Fee', 446, 1, NULL, 0, NULL, 0, 0, '2016-05-10 13:31:31.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('d2b947d4-3939-4b81-81cf-868a7a3ea2f8', 'CNO Revenue & Expense for Terminal State Auctions', 'Revenue and expense by cost code for each auction in a terminal state, i.e., sold, not sold or canceled', 0, N'select	p.accountnumber, a.invoicedon, a.invoicedas, r.Code, r.Name, r.Cost, r.Expense
from	cvs.properties p
		inner join cvs.auctions a
			on a.propertyid = p.id
		inner join (select	auction, code, name, sum(revenue) Cost, sum(actualexpense) Expense from acc.Receivable group by auction, code, name) r
			on r.auction = a.auctionid
where	a.invoicedon is not null
order by p.accountnumber, r.code', 'AccountNumber,InvoicedOn,InvoicedAs,Code,Name,Cost,Expense', 19, 0, NULL, 0, NULL, 0, 0, '2016-04-27 18:37:41.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('0ef930a3-b186-47f1-abb3-86bc302a9d9f', 'Refunds applied to purchase', 'Users where deposit payments were applied to purchases', 0, N'select sum(disb.amount),  s.starttime, s.code, civicsource.dbo.getEmail(purchaser.username)
from cvs.auctions a
inner join cvs.sales s on s.saleid = a.saleid
inner join cvs.primarymarketpurchases pmp on pmp.auctionid = a.auctionid
inner join cvs.purchases purchase on purchase.purchaseid = pmp.purchaseid and purchase.status = 0
inner join cvs.purchasers purchaser on purchaser.purchaserid = purchase.purchaser
inner join fin.disbursals disb on disb.totransactionid = purchase.purchaseid
inner join fin.achpayments payment on payment.achpaymentid = disb.fromtransactionid
inner join fin.financialtransactions ft on ft.financialtransactionid = payment.AchPaymentId
where ft.createdon < s.starttime and disb.iscancelled = 0 and s.starttime > ''<START>'' and s.starttime < ''<END>''
group by s.starttime, s.code, civicsource.dbo.getEmail(purchaser.username)
order by civicsource.dbo.getEmail(purchaser.username), s.starttime desc', 'Amount,Sale Date,SaleCode,Purchaser Email', 8, 1, NULL, 0, NULL, 1, 1, '2016-08-17 15:32:28.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('21db5b2b-0bad-4360-b84f-8a8e7c1cf8a0', 'Sale Distribution - Step 3', 'A list of auctions for which funds have been distributed', 0, N'select	case 
			when s.StartTime is not null then convert(varchar(10), s.StartTime, 20) 
			else ''Research'' 
		end [Sale], 
		convert(varchar(10), a.InvoicedOn, 20) InvoicedOn, 
		p.AccountNumber, 
		case 
			when a.state = 20 then ''Canceled'' 
			when a.state = 30 then ''Sold'' 
			else ''Not Sold'' 
		end [Status], 
		a.InvoicedAs,
		a.Price,
		(select	amountunpaid
		from	cvs.PrimaryMarketPurchases pmp
				inner join cvs.Purchases pur
					on pur.purchaseid = pmp.purchaseid
		where	pur.status = 0 and pmp.auctionid = a.auctionid) AmountDue,
		c.ClosingDate,
		coalesce(c.Status, ''Not Scheduled'') [Closing Status],
		a.DistributedToCivicSource,
		a.DistributedToInsurance,
		a.DistributedToClient
from	cvs.Auctions a
		inner join cvs.Properties p
			on a.PropertyId = p.Id
		left outer join cvs.sales s
			on a.saleid = s.saleid AND SaleType = ''Adj''
		left outer join prodclosing.closing.dbo.package c
			on c.auctionid = a.auctionid
where	a.auctiontype = ''adjudication'' and a.state in (20, 30, 40) and a.invoicedon is not null and a.auctionid in (select taxsalepropertyid from cvs.auctionstatehistory where tostate = 2)
order by a.invoicedon, a.invoicedas, s.starttime, a.[State], p.accountnumber', 'Sale,Invoiced On,Account Number,Status,Invoiced Status,Price,Amount Due,Closing Date,Closing Status,DistributedToCivicSource,DistributedToInsurance,DistributedToClient', 16, 1, NULL, 0, NULL, 0, 1, '2016-06-10 16:43:00.000', NULL, NULL)
EXEC(N'INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES (''f4888649-7c2b-4645-892f-8f65f5cf293a'', ''Adjudication Client Report'', ''Multi-TA query of adj sales counts'', 0, N''
declare @prefix varchar(3)
declare @taName varchar(100)
declare @month1 int
declare @month2 int
declare @month3 int
declare @month4 int
declare @month5 int
declare @year1 int
declare @year2 int
declare @year3 int
declare @year4 int
declare @year5 int
declare @monthLabel1 varchar(20)
declare @monthLabel2 varchar(20)
declare @monthLabel3 varchar(20)
declare @monthLabel4 varchar(20)
declare @monthLabel5 varchar(20)

set @month1 = MONTH(GETDATE())
set @year1 = YEAR(GETDATE())
set @month2 = MONTH(DATEADD(mm, 1, GETDATE()))
set @month3 = MONTH(DATEADD(mm, 2, GETDATE()))
set @month4 = MONTH(DATEADD(mm, 3, GETDATE()))
set @month5 = MONTH(DATEADD(mm, 4, GETDATE()))

set @year2 = YEAR(DATEADD(mm, 1, GETDATE()))
set @year3 = YEAR(DATEADD(mm, 2, GETDATE()))
set @year4 = YEAR(DATEADD(mm, 3, GETDATE()))
set @year5 = YEAR(DATEADD(mm, 4, GETDATE()))

set @monthLabel1 = DATENAME(mm,GETDATE())
set @monthLabel2 = DATENAME(mm,DATEADD(mm, 1, GETDATE()))
set @monthLabel3 = DATENAME(mm,DATEADD(mm, 2, GETDATE()))
set @monthLabel4 = DATENAME(mm,DATEADD(mm, 3, GETDATE()))
set @monthLabel5 = DATENAME(mm,DATEADD(mm, 4, GETDATE()))

set @prefix = (select Prefix from civicsource.dbo.taxauthorities ta where safename = REPLACE(db_name(),''''CivicSource_'''',''''''''))

select 
	sum(counts.candidates) as ''''Candidates'''',
	sum(counts.ispublic) as ''''Public'''',
	sum(counts.pending) as ''''Deposit Pending Action'''',
	sum(counts.abstracting) as ''''In Abstracting'''',
	sum(counts.examining) as ''''In Title Examination'''',
	sum(counts.ipresearch) as ''''In IP Research'''',
	sum(counts.skiptracing) as ''''In Skiptracing'''',
	sum(counts.researchcomplete) as ''''Research Complete'''',
	CASE WHEN sum(counts.Sale1) + sum(counts.Sale1Adjoining) > 0 then @monthlabel1 end ''''Sale 1 Month'''',
	sum(counts.Sale1) as ''''Sale 1'''',
	sum(counts.Sale1Adjoining) as ''''Sale 1 Adjoining'''',
	CASE WHEN sum(counts.Sale2) + sum(counts.Sale2Adjoining) > 0 then @monthlabel2 end ''''Sale 2 Month'''',
	sum(counts.Sale2) as ''''Sale 2'''',
	sum(counts.Sale2Adjoining) as ''''Sale 2 adjoining'''',
	CASE WHEN sum(counts.Sale3) + sum(counts.Sale3Adjoining) > 0 then @monthlabel3 end ''''Sale 3 Month'''',
	sum(counts.Sale3) as ''''Sale 3'''',
	sum(counts.Sale3Adjoining) as ''''Sale 3 Adjoining'''',
	CASE WHEN sum(counts.Sale4) + sum(counts.Sale4Adjoining) > 0 then @monthlabel4 end ''''Sale 4 Month'''',
	sum(counts.Sale4) as ''''Sale 4'''',
	sum(counts.Sale4Adjoining) as ''''Sale 4 Adjoining'''',
	CASE WHEN sum(counts.Sale5) + sum(counts.Sale5Adjoining) > 0 then @monthlabel5 end ''''Sale 5 Month'''',
	sum(counts.Sale5) as ''''Sale 5'''',
	sum(counts.Sale5Adjoining) as ''''Sale 5 Adjoining'''',
	sum(counts.sale_pending) as ''''Sale Pending'''',
	sum(counts.closed) as ''''Closed'''',
	sum(counts.notsold) as ''''Not Sold'''',
	sum(counts.canceled) as ''''Canceled'''',
	sum(counts.held) as ''''Held''''

from
(
select distinct
    acct,
	case when main.auctionstate = 0 then 1 else 0 end candidates,
	case when main.auctionstate = 1 then 1 else 0 end  ispublic,
	CASE WHEN depositstate = 0 then 1 else 0 end pending,
	CASE when main.auctionstate = 2 and queuename like ''''%Abstractors'''' and researchstate not in (''''Complete'''') then 1 else 0 end abstracting,
	CASE when main.auctionstate = 2 and queuename like ''''%Examiners'''' and researchstate not in (''''Complete'''') then 1 else 0 end examining,
	CASE when main.auctionstate = 2 and queuename like ''''%IP Researchers'''' and researchstate not in (''''Complete'''') then 1 else 0 end ipresearch,
	CASE when main.auctionstate = 2 and queuename like ''''%Skiptracers'''' and researchstate not in (''''Complete'''') then 1 else 0 end skiptracing,
	case when main.auctionstate = 3 then 1 else 0 end researchcomplete,
	case when main.auctionstate = 10 and month(main.starttime) = @month1 and year(main.StartTime) = @year1 and main.Type = 0 then 1 else 0 end Sale1,
	case when main.auctionstate = 10 and month(main.starttime) = @month1 and year(main.StartTime) = @year1 and main.Type = 1 then 1 else 0 end Sale1Adjoining,
	case when main.auctionstate = 10 and month(main.starttime) = @month2 and'', ''Candidates,Public,Deposit Pending Action,In Abstracting,In Title Examination,In IP Research,In Skiptracing,Research Complete,Sale 1 Month,Sale 1,Sale 1 Adjoining,Sale 3 Month,Sale 2,Sale 2 Adjoining,Sale 3 Month,Sale 3,Sale 3 Adjoining,Sale 4 Month,Sale 4,Sale 4 Adjoining,Sale 5 Month,Sale 5,Sale 5 Adjoining,Sale Pending,Closed,Not Sold,Canceled,Held'', 150, 1, NULL, 0, NULL, 0, 1, ''2016-08-29 14:15:32.000'', NULL, NULL)')
UPDATE [dbo].[DataExports] SET [Query].WRITE(N' year(main.StartTime) = @year2 and main.Type = 0 then 1 else 0 end Sale2,
	case when main.auctionstate = 10 and month(main.starttime) = @month2 and year(main.StartTime) = @year2 and main.Type = 1 then 1 else 0 end Sale2Adjoining,
	case when main.auctionstate = 10 and month(main.starttime) = @month3 and year(main.StartTime) = @year3 and main.Type = 0 then 1 else 0 end Sale3,
	case when main.auctionstate = 10 and month(main.starttime) = @month3 and year(main.StartTime) = @year3 and main.Type = 1 then 1 else 0 end Sale3Adjoining,
	case when main.auctionstate = 10 and month(main.starttime) = @month4 and year(main.StartTime) = @year4 and main.Type = 0 then 1 else 0 end Sale4,
	case when main.auctionstate = 10 and month(main.starttime) = @month4 and year(main.StartTime) = @year4 and main.Type = 1 then 1 else 0 end Sale4Adjoining,
	case when main.auctionstate = 10 and month(main.starttime) = @month5 and year(main.StartTime) = @year5 and main.Type = 0 then 1 else 0 end Sale5,
	case when main.auctionstate = 10 and month(main.starttime) = @month5 and year(main.StartTime) = @year5 and main.Type = 1 then 1 else 0 end Sale5Adjoining,
	case when main.auctionstate = 30 and main.isclosed = 0 then 1 else 0 end sale_pending,
	case when main.auctionstate = 30 and main.isclosed = 1 then 1 else 0 end closed,
	case when main.auctionstate = 40 then 1 else 0 end notsold,
	case when main.auctionstate = 20 then 1 else 0 end canceled,
	case when ((main.auctionstate = 2 and main.queuename is not null) or (main.auctionstate = 3))  and main.isholding = 1 then 1 else 0 end held
from 
	(select distinct p.AccountNumber acct, a.State auctionstate, d.Status depositstate, q.name queuename, r.status researchstate, s.StartTime, s.Type, a.IsClosed, isholding
	from cvs.properties p
	inner join cvs.auctions a on a.propertyid = p.id and a.auctiontype = ''Adjudication''
	left join cvs.Deposits d on d.auctionid = a.auctionid and d.Status <> 2
	left join prodresearch.research.res.accounts acc on acc.accountnumber = p.AccountNumber and acc.groupname = @prefix
	left join prodresearch.research.res.researches r on r.propertyid = acc.propertyid and r.iscancelled = 0 and r.status not in (''Complete'')
	left join prodresearch.research.res.queues q on q.id = r.queueid
	left join cvs.Sales s on s.SaleId = a.SaleId
	left join (SELECT hh.auctionid, hh.isholding FROM cvs.HoldHistory hh INNER JOIN (select auctionid, max(triggeredon) triggeredon FROM cvs.HoldHistory GROUP by AuctionId) AS maxholdhistory ON maxholdhistory.AuctionId = hh.AuctionId AND maxholdhistory.triggeredon = hh.TriggeredOn) hold on hold.AuctionId = a.AuctionId 
	group by p.AccountNumber, a.state, d.status, q.name, r.Status, s.StartTime, s.Type, a.IsClosed, isholding ) main
) counts
',NULL,NULL) WHERE [Id] = 'f4888649-7c2b-4645-892f-8f65f5cf293a'
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('03269563-aaeb-41a3-9540-93f1b4f65e55', 'Adjudication Sales Not Scheduled Report', 'Multi-TA query of all adjudication sales with research complete without a schedule closing date', 0, N'SELECT 
   ''"'' + p.accountnumber + ''"'' [Account Number],
   p.Address1 + '' '' + p.Address2 + '' ''+ P.City + '' '' + P.State + '' '' + P.PostalCode [Property Address],
   P.LegalDescription,
   PO.UnParsedNameAndAddress,
   IsNull(Convert(VarChar(10),P.AdjudicationDate,101),'''') As [Adjudication Date],
   IsNull((Select Convert(VarChar(15),A.ClosingDate,101) From cvs.Auctions A Where A.State = 3 and A.PropertyId = P.ID and A.CreatedOn = (Select Max(A1.CreatedOn) From cvs.Auctions A1 Where A1.State = 3 and A1.PropertyID = P.ID)),''Not Scheduled'') As [Closing Date],
   Case 
	  When (Select Count(*) From cvs.Auctions A Where A.State = 0 and A.PropertyId = P.ID and A.CreatedOn = (Select Max(A1.CreatedOn) From cvs.Auctions A1 Where A1.State = 0 and A1.PropertyID = P.ID)) > 0 Then ''Candidate''
	  When (Select Count(*) From cvs.Auctions A Where A.State = 1 and A.PropertyId = P.ID and A.CreatedOn = (Select Max(A1.CreatedOn) From cvs.Auctions A1 Where A1.State = 1 and A1.PropertyID = P.ID)) > 0 Then ''Public''
	  When (Select Count(*) From cvs.Auctions A Where A.State = 2 and A.PropertyId = P.ID and A.CreatedOn = (Select Max(A1.CreatedOn) From cvs.Auctions A1 Where A1.State = 2 and A1.PropertyID = P.ID)) > 0 Then ''Researching''
	  When (Select Count(*) From cvs.Auctions A Where A.State = 3 and A.PropertyId = P.ID and A.CreatedOn = (Select Max(A1.CreatedOn) From cvs.Auctions A1 Where A1.State = 3 and A1.PropertyID = P.ID)) > 0 Then ''Research Complete''
	  When (Select Count(*) From cvs.Auctions A Where A.State = 10 and A.PropertyId = P.ID and A.CreatedOn = (Select Max(A1.CreatedOn) From cvs.Auctions A1 Where A1.State = 10 and A1.PropertyID = P.ID)) > 0 Then ''For Sale''
	  When (Select Count(*) From cvs.Auctions A Where A.State = 15 and A.PropertyId = P.ID and A.CreatedOn = (Select Max(A1.CreatedOn) From cvs.Auctions A1 Where A1.State = 15 and A1.PropertyID = P.ID)) > 0 Then ''Requires Review''
	  When (Select Count(*) From cvs.Auctions A Where A.State = 20 and A.PropertyId = P.ID and A.CreatedOn = (Select Max(A1.CreatedOn) From cvs.Auctions A1 Where A1.State = 20 and A1.PropertyID = P.ID)) > 0 Then ''Canceled''
	  When (Select Count(*) From cvs.Auctions A Where A.State = 30 and A.PropertyId = P.ID and A.CreatedOn = (Select Max(A1.CreatedOn) From cvs.Auctions A1 Where A1.State = 30 and A1.PropertyID = P.ID)) > 0 Then ''Sold''
	  When (Select Count(*) From cvs.Auctions A Where A.State = 40 and A.PropertyId = P.ID and A.CreatedOn = (Select Max(A1.CreatedOn) From cvs.Auctions A1 Where A1.State = 40 and A1.PropertyID = P.ID)) > 0 Then ''Not Sold''
	  Else ''''
	End as [Auction State]
From cvs.Properties P
Inner Join cvs.PropertyOwners PO On PO.PropertyOwnerID = P.PropertyOwnerID
Inner Join cvs.Auctions A2 On A2.PropertyID = P.Id
Where P.IsAdjudicated = 1 and A2.ClosingDate is Null and A2.State = 3', 'AccountNumber,Property Address,Legal Description,Owner,Adjudication Date,Closing Date,Auction State', 5, 1, NULL, 0, NULL, 0, 1, '2016-05-19 16:54:24.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('607042e8-ad9c-4d2a-b714-9b8995651a99', 'Revenue Schedule', 'List of cost activities and how they are scheduled to be added to accounts in adjudicated property and tax sale auctions', 0, N'select	AuctionType Process, TaxAuthority, code, name, case when IsBorrowerCost = 1 then ''Buyer'' else ''Seller'' end ChargedTo, AddEvent, IncurEvent, RemoveEvent, PerType Per, Revenue, ExpectedExpense
from	civicsource.acc.activity a
		left join civicsource.acc.revenuescheduleitem i
			on i.activity = a.activityid
		left join civicsource.acc.revenueschedule s
			on s.revenuescheduleid = i.revenuescheduleid
order by AuctionType, TaxAuthority, code', 'Code,Name,ChargedTo,Process,Event,Per,Revenue,ExpectedExpense', 25, 1, NULL, 0, NULL, 0, 0, '2016-08-18 15:54:38.000', NULL, NULL)
EXEC(N'INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES (''f71bb10f-35c9-4855-b5a5-9d60b7a80d07'', ''Summary Report'', ''Summary of collections and calls'', 0, N''SELECT a.MonthTxt + ''''-'''' + CONVERT(varchar(4),a.Year) "Month/Year",   case when b.del is null then ''''No Data'''' else CONVERT(varchar(20),b.del) end "Delinquent Start of Month",   a.Number "Number Paid",   a.Principal "Taxes (including costs)",   a.Interest "Interest",   a.Penalty "Penalty",   a.Collection "Collection",   a.Total "Total",    a.av "Avg $/payment",    case when c.inbound is null then ''''No Data'''' else convert(varchar(20),c.inbound) end "inbound calls",    case when c.outbound is null then ''''No Data'''' else convert(varchar(20),c.outbound) end "outbound calls",    case when c.inboundvoice is null then ''''No Data'''' else convert(varchar(20),c.inboundvoice) end "Inbound Voicemail"  from  (  SELECT   YEAR(AppliedAt) Year,   DateName(month,AppliedAt) MonthTxt,  MONTH(AppliedAt) month,   count(*) Number,   ''''$'''' + CONVERT(varchar(20), CONVERT(money,SUM(Balance)),1) Principal,   ''''$'''' + CONVERT(varchar(20), CONVERT(money,SUM(Interest)),1) Interest,   ''''$'''' + CONVERT(varchar(20), CONVERT(money,SUM(PEnalty)),1) Penalty,  ''''$'''' + CONVERT(varchar(20), CONVERT(money,SUM(Collection)),1) Collection,   ''''$'''' + CONVERT(varchar(20), CONVERT(money,SUM(Total)),1) Total,  ''''$'''' + CONVERT(varchar(20), CONVERT(money,SUM(Total)/(count(*))),1) av      FROM [cvs].[PropertyPayments]    group by DateName(month,AppliedAt), Year(AppliedAt), MONTH(AppliedAt)    ) a    left outer join(  select pis.Unchanged + pis.Additions del, YEAR(start.dt) yr, datename(month,start.dt) monthtxt, MONTH(dt) month  from [rpt].[PropertyImportSnapshot] pis  inner join  (SELECT MIN(Date) dt          FROM [rpt].[PropertyImportSnapshot]       WHERE Type = 0         group by DateName(month,Date),YEAR(Date),MONTH(Date) ) start  on start.dt = pis.Date and pis.Type = 0    ) b  on b.yr = a.Year and b.month = a.Month  left outer join  (SELECT YEAR(CallDate) Year, DateName(month,CallDate) MonthTxt, Month(CallDate) month, ISNULL(inbound.cnt,0) inbound, ISNULL(outbound.cnt,0) outbound, ISNULL(inboundvoice.cnt, 0) inboundvoice, ISNULL(thirdparty.cnt, 0) thirdparty  FROM tel.Calls   full outer join  (SELECT YEAR(CallDate) [Year] ,MONTH(CallDate) [Month], CallType [Type], COUNT(*) cnt  FROM [tel].[Calls] WHERE CallType = 0 AND TalkTime > 0 GROUP BY YEAR(CallDate),MONTH(CallDate), CallType) inbound  on YEAR(CallDate) = inbound.Year and Month(CallDate) = inbound.Month   full outer join  (SELECT YEAR(CallDate) Year, MONTH(CallDate) Month, CallType type, COUNT(*) cnt  FROM [tel].[Calls] WHERE CallType = 1 AND TalkTime > 0 GROUP BY YEAR(CallDate),MONTH(CallDate), CallType) outbound  on YEAR(CallDate)= outbound.Year and MONTH(CallDate) = outbound.Month   full outer join  (SELECT YEAR(CallDate) Year, MONTH(CallDate) Month, CallType type, COUNT(*) cnt  FROM [tel].[Calls] WHERE CallType = 2 GROUP BY YEAR(CallDate),MONTH(CallDate), CallType) inboundvoice  on YEAR(CallDate)= inboundvoice.Year and MONTH(CallDate) = inboundvoice.Month   full outer join  (SELECT YEAR(CallDate) Year, MONTH(CallDate) Month, CallType type, COUNT(*) cnt  FROM [tel].[Calls] WHERE CallType = 3  AND TalkTime > 0 GROUP BY YEAR(CallDate),MONTH(CallDate), CallType) thirdparty   on YEAR(CallDate)= thirdparty.Year and MONTH(CallDate) = thirdparty.Month   where (Year(CallDate) > 2010) or (Year(CallDate) = 2010 and Month(CallDate) > 4)  GROUP BY YEAR(CallDate),MONTH(CallDate),DateName(month,CallDate),inbound.cnt,outbound.cnt,inboundvoice.cnt, thirdparty.cnt  )c  on c.Year = a.Year and c.Month = a.Month  order by a.Year desc, a.month desc'', ''Month/Year,Delinquent At Start of Month,Number Paid,Taxes (including costs),Interest,Penalty,Collection,Total,Avg $/payment,Inbound Calls,Outbound Calls,Inbound Voicemail'', 76, 1, NULL, 0, NULL, 0, 0, ''2016-06-29 20:18:18.000'', NULL, NULL)')
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('21733be7-60d1-4eef-aeb3-9efbffd8e115', 'Scrubbing Summary', 'All scrubbing statistics separated by agent.', 0, N'-- Scrubbing Summary
declare @ScrubbingSummary table (
	AgentName varchar(max),
	TotalScrubbed int,
	TotalAutoSkiptraced int,
	TotalManualSkiptraced int
)

insert into @ScrubbingSummary (AgentName)
(select distinct ScrubbedBy as AgentName
from cvs.PropertyOwners po
where ScrubbedBy is not null)

union 

(select distinct createdBy as AgentName from cvs.SkiptraceAttempts
where CreatedBy is not null and LEN(CreatedBy) > 0)

update ss
set TotalScrubbed = q.TotalSrubbed
from @ScrubbingSummary ss
	inner join (select ScrubbedBy as AgentName, COUNT(*) as TotalSrubbed
					from cvs.PropertyOwners po
				where ScrubbedBy is not null and ScrubbedOn >= ''<START>'' and ScrubbedOn <= ''<END>''
				group by ScrubbedBy)q
	on q.AgentName = ss.AgentName


update ss
set TotalAutoSkiptraced = q.TotalAutoSkiptraced
from @ScrubbingSummary ss
	inner join (select CreatedBy as AgentName, COUNT(*) as TotalAutoSkiptraced
				from cvs.SkiptraceAttempts
				where CreatedBy is not null and Service <> ''Manual'' and CreatedOn >= ''<START>'' and CreatedOn <= ''<END>''
				group by CreatedBy)q
	on q.AgentName = ss.AgentName
	

update ss
set TotalManualSkiptraced = q.TotalManualSkiptraced
from @ScrubbingSummary ss
	inner join (select CreatedBy as AgentName, COUNT(*) as TotalManualSkiptraced
				from cvs.SkiptraceAttempts
				where CreatedBy is not null and Service = ''Manual'' and CreatedOn >= ''<START>'' and CreatedOn <= ''<END>''
				group by CreatedBy)q
	on q.AgentName = ss.AgentName

select * from @ScrubbingSummary', 'Agent Name, Total # Scrubbed, # Sent to Auto Skip Tracing, # Sent to Manual Skip Tracing', 13, 1, NULL, 0, NULL, 1, 0, '2016-04-27 18:48:50.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('aa58f357-7be6-4f28-a0ef-9fa2f2c2a724', 'CNO Tax Collection Invoice', 'For CNO only. Data for the tax collection invoice, which excludes adjudicated auctions marked as invoiced', 0, N'SELECT	AppliedAt, p.AccountNumber, p.PropertyType, pp.Year, tt.TaxCode, pp.LienNumber, 
		case when tt.TaxCode IN (''66'', ''51'', ''67'') then interest + penalty else balance + interest + penalty end Tax, 
		case when tt.TaxCode  = ''51'' then balance else 0 end [TC51],  
		case when tt.TaxCode  = ''66'' then balance else 0 end [TC66], 
		case when tt.TaxCode  = ''67'' then balance else 0 end [TC67],   
		[collection] [Collection Fee], total Total
from	cvs.propertypayments pp
		INNER JOIN cvs.TaxTypes tt 
			ON tt.TaxTypeId = pp.TaxTypeId
		left OUTER JOIN cvs.propertypaymenttypes ppt 
			ON ppt.propertypaymenttypeid = pp.propertypaymenttypeid
		left join cvs.properties p
			on pp.accountnumber = p.accountnumber and pp.propertytype = p.propertytype
		left join (select auctionid, propertyid, invoicedon, invoicedas
					from	cvs.auctions
					where	auctiontype = ''adjudication'' and state in (20, 30, 40)) a
			on a.propertyid = p.id	

WHERE (ppt.TransactionCode IS NULL OR ppt.TransactionCode NOT IN (''090'')) and a.invoicedon is null and AppliedAt >= ''1/1/2015''
order by AppliedAt, AccountNumber, p.propertytype, year, TaxCode, LienNumber', 'AppliedAt,AccountNumber,PropertyType,Year,TaxCode,LienNumber,Tax,TC51,TC66,TC67,CollectionFee,Total', 24, 1, NULL, 0, NULL, 0, 0, '2016-08-09 03:41:40.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('6274909a-8126-425e-a548-a26a75787486', 'All Deposits', 'Deposit and auction status of all deposits placed', 0, N'SELECT p.accountnumber, p.Address1, 
CivicSource.dbo.GetEmail(purch.Username) AS ''Depositor'',
CAST(d.DepositMadeOn AS DATE) AS ''Deposit Placed'',
CASE WHEN d.Status = 0 THEN ''Awaiting Verification''
     WHEN d.Status = 1 THEN ''Verified''
	 WHEN d.Status = 2 THEN ''Canceled''
	 WHEN d.status = 3 THEN ''Refunded for Purchase''
END AS ''Deposit Status'',
CASE WHEN a.state = 0 THEN ''Candidate''
     WHEN A.state = 1 THEN ''Public''
	 WHEN a.state = 2 THEN ''Researching''
	 WHEN a.state = 3 THEN ''Research Complete''
	 WHEN a.state = 10 THEN ''Scheduled''
	 WHEN a.state = 20 THEN ''Canceled''
	 WHEN a.state = 30 THEN ''Sold''
	 WHEN a.state = 40 THEN ''Not Sold''
END AS ''Auction Status''
FROM cvs.Properties p
INNER JOIN cvs.auctions a ON a.PropertyId = p.Id
INNER JOIN cvs.Deposits d ON d.AuctionId = a.AuctionId
INNER JOIN cvs.Purchasers purch ON purch.PurchaserId = d.PurchaserId
ORDER BY a.state, p.AccountNumber, d.Status', 'Account Number,Address,Depositor,Placed On,Deposit Status,Auction Status', 35, 1, N'', 0, '', 0, 1, '2016-07-18 14:46:59.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('4c105252-1301-4837-b166-a62fc3da7d19', 'Skip Traced Accounts', 'Accounts successfully skiptraced and ready to call', 0, N'select p.AccountNumber, CASE WHEN p.PropertyType = 0 THEN ''Immovable'' ELSE ''Movable'' END ''Property Type''  
,   dbo.GetPropertyOwnerNames(po.PropertyOwnerId) ''Owner Names''      , a.tot      
, dbo.GetPropertyOwnerPhoneNumbers(po.PropertyOwnerId) ''Phones''
, maxskip.SkipTraceCompleted
FROM [cvs].[Properties] p            
inner join (SELECT p.AccountNumber, CAST(SUM(pt.Total) as Decimal(9,2)) tot  FROM cvs.PropertyTaxes pt                
inner join cvs.Properties p on p.Id = pt.PropertyId where   pt.Status = 2 group by p.AccountNumber ) a        
on p.AccountNumber = a.AccountNumber    inner join cvs.PropertyOwners po   on po.PropertyId = p.Id            
left outer join cvs.PropertyOwnerPhones pop on pop.PropertyOwnerId = po.PropertyOwnerId and pop.PhoneIndex = 0        
inner join (select OwnerId, MAX(CompletedAt) as SkipTraceCompleted           
from [cvs].[SkiptraceAttempts]
where State=2           
GROUP By OwnerID) maxSkip   on maxSkip.OwnerId = po.PropertyOwnerId    
WHERE    p.AmountDue > 0    and p.Status = 1  
AND p.AccountNumber NOT IN (select excl.AccountNumber          
from cvs.PropertyExclusions excl          
where excl.Accountnumber = p.AccountNumber         
and excl.PropertyType = p.PropertyType         
and excl.ExpiresOn > GETDATE())  
order by
maxskip.SkipTraceCompleted DESC', 'Account Number, Property Type, Owner Names, Delinquent Balance, Contact Phone, SkipTrace Completed', 143, 1, NULL, 0, NULL, 0, 1, '2016-05-10 15:47:40.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('f0706151-31c4-413c-9028-a7bd109b170e', 'Sold properties', 'Properties that were sold in tax sale, including purchaser information.', 0, N'select ''"'' + p.AccountNumber + ''"'', p.Address1, p.LegalDescription, au.FirstName + '' '' + au.LastName,
pu.NameOnDeed,au.Address1, au.Address2, au.City, au.State, au.PostalCode,
''('' + au.AreaCode + '') '' +  au.Prefix + ''-'' + au.Suffix, au.Email,
''$'' + CONVERT(varchar(20), CONVERT(money,a.Price),1),
case when b.amount is null then CONVERT(varchar(20), CONVERT(int,pur.bidAmount * 100), 1) + ''%''
	 else CONVERT(varchar(20), CONVERT(int,b.Amount * -100), 1) + ''%'' end
from  cvs.Auctions a
	inner join cvs.Properties p
		on a.PropertyId = p.Id
	inner join cvs.PrimaryMarketPurchases pu
		on pu.AuctionId = a.AuctionId
	inner join cvs.Purchases pur
		on pur.PurchaseId = pu.PurchaseId
	inner join cvs.Purchasers purchasers  
		on purchasers.PurchaserId = pur.Purchaser
	LEFT JOIN PRODAUCTION.auction.dbo.bid b 
		ON b.id = pur.BidId 
	inner join CivicSource.dbo.AuctioneerProfiles au 
		ON au.Username = purchasers.Username
where a.SaleId = ''<FILTER>''
	and a.State = 30 and pur.Status <> 1  
order by p.AccountNumber', 'Account Number,Property Address,Legal Description,Purchaser Name,Name on Deed,Address1,Address2,City,State,Postal Code,Phone Number,Email Address,Auction Price,Percentage Bid', 501, 1, N'SELECT  LEFT(DATENAME(m, StartTime), 3) + '' '' + DATENAME(yyyy, StartTime)
        + '' Tax Sale'' AS Name ,
        ts.SaleId
FROM    cvs.Sales ts
        INNER JOIN ( SELECT MAX(EndTime) ed ,
                            SaleId
                     FROM   cvs.Sales
                     WHERE  SaleType = ''Tax''
                     GROUP BY SaleId
                   ) x ON x.SaleId = ts.SaleId
WHERE   SaleType = ''Tax''
AND GETDATE() > EndTime
ORDER BY x.ed DESC', 0, 'Tax Sale', 0, 0, '2016-08-30 20:00:12.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('1ebed16e-a06b-426b-b181-a9440f428689', 'Notorious bidders in latest Tax Sale', 'This export returns information on all bidders in the current/latest tax sale where their bidding average is below 50%.', 0, N'Declare @latestTaxSale 
	uniqueidentifier = (select top 1 t.TaxSaleId 
		from cvs.taxsales t   
		join cvs.TaxSaleActiveTimes ts on t.TaxSaleId = ts.TaxSaleId where t.Status != 20 order by ts.EndDate desc )          
		
declare @taPrefix 
	varchar(3) = (select top 1 SUBSTRING(l.InternalTrackingNumber,1,3) from   
	cvs.Auctions a join mail.Letters l on a.NoticeOfTaxSaleId = l.LetterId where a.taxsaleid = @latestTaxSale)    
	
Select au.Email Email, COUNT(au.Email) Bids, (sum(b.PercentValue)/(COUNT(au.Email))) * 100 AveragePercentage,
	''https://admin.civicsource.com/LA/'' + @taPrefix + ''/purchaser/bids/'' + convert(varchar(50), au.AuctioneerUserSearchItemId) BidderPage,        
Case Au.IsBanned When 0 Then ''Normal'' else ''Banned'' End As IsBanned,
Case Au.IsBiddingDisabled When 0 Then ''Normal'' else ''Bidding Disabled'' End As IsBiddingDisabled
From cvs.Bids b   Join cvs.Auctions a      
on a.AuctionId = b.AuctionId   
Join CivicSource_Auctioneer_webprod05.sch.AuctioneerUserSearchItems au      
on b.CreatedBy = au.Username      
Where a.TaxSaleId = @latestTaxSale      
Group by au.Name, au.Email,  au.BusinessAreaCode + au.BusinessPrefix + au.BusinessSuffix, au.AuctioneerUserSearchItemId,
Au.IsBanned, Au.IsBiddingDisabled
Having ((sum(b.PercentValue)/(COUNT(au.Email))) * 100) < 50      
Order by  Bids desc,  AveragePercentage asc', 'Email, Bids, Avg Percent, BidderPage, IsBanned, IsBiddingDisabled', 70, 1, NULL, 0, NULL, 0, 0, '2016-04-27 18:42:55.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('920dc56d-d096-4c97-a115-b26808f1263a', 'Refunds applied to purchase (overage)', 'Users where too manydeposit payments were applied to purchases', 0, N'select sum(purchase.purchaseprice), sum(disb.amt), sum(disb.amt - purchase.purchaseprice), civicsource.dbo.getEmail(purchaser.username), s.starttime
from cvs.auctions a
inner join cvs.sales s on s.saleid = a.saleid
inner join cvs.primarymarketpurchases pmp on pmp.auctionid = a.auctionid
inner join cvs.purchases purchase on purchase.purchaseid = pmp.purchaseid and purchase.status = 0
inner join cvs.purchasers purchaser on purchaser.purchaserid = purchase.purchaser
inner join (select sum(disb.amount) amt, disb.totransactionid, s.starttime
			from fin.disbursals disb 
			inner join fin.achpayments payment on payment.achpaymentid = disb.fromtransactionid
			inner join fin.financialtransactions ft on ft.financialtransactionid = payment.AchPaymentId
			inner join cvs.purchases purchase on purchase.purchaseid = disb.totransactionid and purchase.status = 0
			inner join cvs.primarymarketpurchases pmp on pmp.purchaseid = purchase.purchaseid
			inner join cvs.auctions a on a.auctionid = pmp.auctionid
			inner join cvs.sales s on s.saleid = a.saleid
			where disb.iscancelled = 0 and ft.createdon < s.starttime
			group by disb.totransactionid, s.starttime) disb on disb.totransactionid = purchase.purchaseid
where disb.amt > purchase.purchaseprice and s.starttime > ''<START>'' and s.starttime < ''<END>''
group by s.starttime, civicsource.dbo.getEmail(purchaser.username)
order by s.starttime, civicsource.dbo.getEmail(purchaser.username)', 'Purchase Price Total,Disbursement Total,Overage,Sale Date', 1, 0, NULL, 0, NULL, 1, 1, '2016-07-19 15:40:13.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('85412ca6-53df-4ead-b624-ba47aa93dfef', 'Bankrupt Properties Details', 'Property details link for bankrupt properties in each TA', 0, N'declare @url nvarchar(1000), @dbName nvarchar(1000), @safeName nvarchar(500), @environment nvarchar(500), @start int, @length int,
	@taState nvarchar(500), @taPrefix nvarchar(500), @sql nvarchar(2000)

set @dbName = DB_NAME()
set @length = CHARINDEX(''_'', REVERSE(@dbName))
set @start = LEN(@dbName) - @length  + 2

set @safeName = SUBSTRING(@dbName, @start, @length)
set @environment = SUBSTRING(@dbName, 1, @start - 2)

set @sql = N''select @taStateParam = LOWER([State]), @taPrefixParam = Prefix from '' + @environment + ''.dbo.TaxAuthorities where SafeName = @safeNameParam''
EXECUTE sp_executesql
	@sql,
	N''@safeNameParam nvarchar(500),
	@taStateParam nvarchar(500) OUTPUT,
	@taPrefixParam nvarchar(500) OUTPUT'',
	@safeNameParam = @safeName,
	@taStateParam = @taState OUTPUT,
	@taPrefixParam = @taPrefix OUTPUT

set @url = ''https://admin.civicsource.com/'' + LOWER(@taState) + ''/'' + LOWER(@taPrefix) + ''/''

select AccountNumber, (@url + AccountNumber + ''.'' + LOWER(SUBSTRING([Type], 1, 1))) as link from cvs.properties
where (IsBankrupt = 1) or Id in (select distinct PropertyId from cvs.Bankruptcies where IsActive = 1)', 'Account Number, Property Details Link', 5, 1, NULL, 0, NULL, 0, 1, '2016-04-27 18:59:57.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('d9d76461-9e66-42a3-b7ac-bb04f8258756', 'Failed Processes', 'Processes that have recently failed', 0, N'Select 
   id,
   R.Name,
  R.Count,
   I.Name,
   State,
   Schedule,
   Series,
   I.QueuedOn,
   I.QueuedBy,
   I.QueuedAt,
   I.RunningOn,
   I.RunningAs,
   I.AcquiredAt,
   I.StartedAt,
   I.StoppedAt,
   Convert(Time,I.StoppedAt)
From BatchProcess.dbo.Instance as I
  left outer join BatchProcess.dbo.Result as r
  on r.Instance = i.id
Where State = 4 and Convert(VarChar(10),I.StoppedAt,121) = Convert(VarChar(10),GetDate(),121) and 
      Not I.Name In (''Ach Status Processor - CPJ'',
                     ''Ach Status Processor - SMO'',
                     ''Ach Status Processor - JAA'',
                     ''Ach Status Processor - VAA'')
Order by I.StoppedAt', 'id,Name,Count,Name,State,Schedule,Series,QueuedOn,QueuedBy,QueuedAt,RunningOn,RunningAs,AcquiredAt,StartedAt,StoppedAt,StoppedAtLocal', 16, 1, NULL, 0, NULL, 0, 0, '2016-08-01 21:19:48.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('ae303c88-ac7c-4dee-9472-bd548c6712a2', 'Canceled Auction Report', 'Report to show all auctions canceled in an active tax sale', 0, N'
SELECT ''"'' + P.AccountNumber + ''"'', S.Code, CONVERT(VarChar(10),ASH.CreatedOn,101)
  FROM [cvs].[Auctions] A
  Join cvs.Sales S on S.SaleID = A.SaleId
  Join cvs.Properties P on P.ID = A.PropertyID
  Join cvs.AuctionStateHistory ASH on ASH.AuctionStateHistoryID = (Select Top 1 ASH1.AuctionStateHistoryID From cvs.AuctionStateHistory ASH1 Where ASH1.ToState = 20 and ASH.TaxSalePropertyId = A.AuctionId and ASH1.TaxSalePropertyId = ASH.TaxSalePropertyID Order by CreatedOn Desc)
  Where S.EndTime >= GetDate()
  Order by ASH.CreatedOn
', 'Account Number,Sale Code,Canceled Date', 12, 1, NULL, 0, NULL, 0, 0, '2016-08-30 15:27:16.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('6e238496-db42-4ad4-9057-bdbdb9598501', 'Sold Taxes', 'Taxes sold at tax sale for each bill number', 0, N'SELECT p.AccountNumber, st.Year, typ.TaxCode,   ''$'' + CONVERT(varchar(20), CONVERT(money,st.Balance),1),  ''$'' + CONVERT(varchar(20), CONVERT(money,st.Interest),1),  ''$'' + CONVERT(varchar(20), CONVERT(money,st.Penalty),1),  ''$'' + CONVERT(varchar(20), CONVERT(money,st.Collection),1)    FROM [cvs].[SellableTaxes] st    inner join cvs.Auctions a on a.AuctionId = st.TaxSalePropertyId    inner join cvs.sales ts on ts.SaleId = a.SaleId AND SaleType = ''Tax'' inner join cvs.Properties p on p.Id = a.PropertyId    inner join cvs.TaxTypes typ on typ.TaxTypeId = st.TaxTypeId    where a.State = 30 and ts.SaleId = ''<FILTER>''    order by p.AccountNumber, st.Year, typ.TaxCode', 'Acount Number, Year, Tax Code, Tax, Interest, Penalty, Collection', 120, 1, N'SELECT  LEFT(DATENAME(m, StartTime), 3) + '' '' + DATENAME(yyyy, StartTime)
        + '' Tax Sale'' AS Name ,
        ts.SaleId
FROM    cvs.Sales ts
        INNER JOIN ( SELECT MAX(EndTime) ed ,
                            SaleId
                     FROM   cvs.Sales
                     WHERE  SaleType = ''Tax''
                     GROUP BY SaleId
                   ) x ON x.SaleId = ts.SaleId
WHERE   SaleType = ''Tax''
AND GETDATE() > EndTime
ORDER BY x.ed DESC', 0, 'Tax Sale', 0, 0, '2016-06-24 14:21:32.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('2d87e597-4665-4781-9412-bdd70a40ceaa', 'Immovable Delinquency Count', 'Immovable Delinquency Count', 0, N'select count(*)
from cvs.properties p
where p.propertytype = 0
and p.IsBankrupt = 0
and p.IsAdjudicated = 0
and p.taxclass <> 3
and p.status = 2
and p.amountdue > 0
and p.accountnumber not in (select accountnumber from cvs.propertyexclusions
							where accountnumber = p.accountnumber and propertytype = p.propertytype and ExpiresOn > getdate())', 'Immovable Delinquency Count', 6, 1, NULL, 0, NULL, 0, 1, '2016-04-27 19:02:19.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('7469a841-8508-4f23-a66d-be457986114a', 'Call counts', 'Sum of inbound and outbound calls in current year to date', 0, N'SELECT ''Calls'', count(*)
  FROM [tel].[Calls]
  where year(calldate) = 2016 and calltype in (0,1)', 'Count', 1, 1, NULL, 0, NULL, 0, 1, '2016-06-30 15:03:21.000', '1', NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('e0d7a673-282e-47f9-9678-c1939acb34ad', 'Public auctions with occupancy report status', 'Report showing account numbers and if there is an occupancy report for that account', 0, N'
SELECT ''"'' + P.AccountNumber + ''"''
,Case
      When (SELECT Count(Da.AttributeValue) 
	           FROM [doc].[Documents] d
               Join doc.DocumentAttributes da On da.DocumentId = d.DocumentId and Da.AttributeName = ''Account Number''
               where d.DocumentTypeId = (Select DocumentTypeID 
			                                From doc.DocumentTypes DT 
											Where DT.Name = ''Occupancy Report'')  and Da.AttributeValue = P.AccountNumber) > 0 Then ''X''
	  Else ''''
  End [Occupancy Report]
  FROM [cvs].[Auctions] A
  Join cvs.Properties P on P.ID = A.PropertyID
  Where A.State = 1
  ', 'AccountNumber,Occupancy Report', 9, 1, NULL, 0, NULL, 0, 1, '2016-07-11 17:21:57.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('b1f36589-db93-4bc4-91ad-c44a43939b72', 'Adjudication Adjoining Land Owner Report', 'Multi-TA query of Adjoining Land Owners', 0, N'
SELECT Distinct
   ''"'' + P.AccountNumber + ''"'',
   P.Address1, 
   P.City, 
   P.State, 
   P.PostalCode,
   AP.NameOnDeed,
   AP.Email,
   ''('' + AP.AreaCode + '') '' + AP.Prefix + ''-'' + AP.Suffix,
   CONVERT(VarChar(10),AR.DepositMadeOn,101),
   CONVERT(VarChar(10),DateAdd(Day,60,L.MailedOn),101),
   CONVERT(VarChar(10),DateAdd(Day,180,L.MailedOn),101),
   Cast(AR.DepositPrice As Money),
   IsNull(CONVERT(VarChar(10),L.MailedOn,101),''''),
   CONVERT(VarChar(10),P.AdjudicationDate,101)
  FROM cvs.Properties P 
  Join cvs.Auctions a On A.PropertyId = P.ID 
  Left Join cvs.Deposits AR on AR.AuctionID = A.AuctionID and AR.Status Not In (2,3)
  Left Join cvs.Purchasers Pur on Pur.PurchaserId = AR.PurchaserId
  Left Join CivicSource.dbo.AuctioneerProfiles AP on AP.Username = Pur.Username
  Left Join Mail.Letters L On Replace(L.DataAccountNumber,''.i'','''') = P.AccountNumber and L.MailedOn = (Select Max(L1.MailedOn) From Mail.Letters L1 Where Replace(L1.DataAccountNumber,''.i'','''') = P.AccountNumber)
  Where AR.IsAdjoiningLandowner = 1 and A.State In (1,2,3,10,15)
  ', 'AccountNumber,Address,City,State,PostalCode,Depositor,Depositor Email,Depositor Phone,Deposit Date,Notice Date + 60,Notice Date + 180,Deposit Amount,Notice Mail Date,Adjudication Date', 61, 1, NULL, 0, NULL, 0, 1, '2016-08-04 15:14:21.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('cfcaf18e-f731-4576-ad44-c4a54ff0d494', 'Campaign Summary', 'Summary of campaign notices and return reason', 0, N'SELECT c.Name, count(*), ReturnReason 
  FROM [mail].[Letters] l 
  inner join mail.Campaigns c 
  on l.CampaignId = c.CampaignId 
  where l.CampaignId = ''<FILTER>'' 
  group by l.ReturnReason, c.Name 
  order by ReturnReason', 'Campaign Name, Count, Return Reason', 27, 1, N'SELECT Name, CampaignID from mail.Campaigns order by CreatedOn desc', 0, 'Campaign', 0, 0, '2016-06-21 13:27:35.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('1e78e7ea-259a-4cbf-a825-cac53b8f593b', 'Adjudicated Deposit Monthly Counts', 'Number of adjudicated property auction deposits by month.', 0, N'select	datepart(yy, r.depositmadeon), datepart(mm, r.depositmadeon), count(*)
From cvs.Auctions a 
inner join cvs.Properties p on a.PropertyId = p.Id 
inner join cvs.Deposits r on r.AuctionId = a.AuctionId 
Where	a.AuctionType = ''Adjudication'' 
group by datepart(yy, r.depositmadeon), datepart(mm, r.depositmadeon)
Order by datepart(yy, r.depositmadeon), datepart(mm, r.depositmadeon)', 'Year,Month,Count', 10, 1, NULL, 0, NULL, 0, 1, '2016-08-08 15:50:39.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('dbcbb6ba-2338-4612-a79c-cc678ae85a8b', 'All Immovable Properties', 'All immovable properties with owner contact information', 0, N'
SELECT p.AccountNumber, p.Address1 + CASE p.Address2 WHEN null then '' '' ELSE '' '' + p.Address2 END ''Address''  
, p.LegalDescription, dbo.GetPropertyOwnerName(po.PropertyOwnerId) ''Owner''  
, CASE WHEN poa.Address1 is null or LEN(poa.Address1) = 0 then '''' else poa.Address1 + '', '' end 
+ CASE WHEN poa.Address2 is null or LEN(poa.Address2) = 0 then '''' else poa.Address2 + '', '' end 
+ CASE WHEN poa.City is null or LEN(poa.City) = 0  then '''' else poa.City + '', '' end 
+ CASE WHEN poa.State  is null or LEN(poa.State ) = 0  then '''' else poa.State + '' '' end 
+ CASE  WHEN poa.PostalCode is null or LEN(poa.PostalCode) = 0  then '''' else poa.PostalCode + '', '' end
+ CASE WHEN poa.Country is null or LEN(poa.Country ) = 0  then '''' else poa.Country end  ''Owner Address''
, CASE p.Status
	WHEN 0 THEN ''Due''
	WHEN 1 THEN ''Delinquent''
	WHEN 2 THEN ''Paid''
	ELSE '' ''
  END ''Status'', 
CASE WHEN p.IsAdjudicated = 1 THEN ''True'' ELSE ''False'' END ''IsAdjudicated''  , 
CASE WHEN p.IsBankrupt = 1 THEN ''True'' ELSE ''False'' END ''IsBankrupt''  , 
p.AmountDue  FROM [cvs].[Properties] p  inner join cvs.PropertyOwners po   on po.PropertyId = p.Id     
inner join cvs.PropertyOwnerAddresses poa  on poa.PropertyOwnerId = po.PropertyOwnerId     
and poa.AddressIndex = 0  WHERE p.AmountDue > 0 and p.PropertyType = 0 order by p.AccountNumber', 'Account Number, Address, Legal, Owner Name, Owner Address, Status, Bankrupt, Amount Due', 137, 1, NULL, 0, NULL, 0, 0, '2016-08-15 19:43:34.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('a309f3e4-c0e1-4711-8df7-cd7144d6cd01', 'ACH Transactions', 'ACH Transactions', 0, N'SELECT ap.Email, ft.Name, ft.Amount, ft.ReferenceId, ach.ProcessorReferenceNumber, ach.SentToProcessorOn, ach.ReturnedOn, ach.ReturnedReason
FROM fin.AchTransactions ach
INNER JOIN fin.FinancialTransactions ft ON ft.FinancialTransactionId = ach.AchTransactionId
INNER JOIN fin.AccountEntries ae ON ae.TransactionId = ft.FinancialTransactionId
INNER JOIN fin.Accounts acc ON acc.AccountId = ae.AccountId
INNER JOIN CivicSource.dbo.AuctioneerProfiles ap ON ap.Username = acc.Name
WHERE YEAR(SentToProcessorOn) = 2015 AND SentToProcessorOn >= ''2015-08-10''
ORDER BY AchState
', 'Email,Name,Amount,ReferenceId,Processor Reference, Sent to Processor,Returned, Returned Reason', 2, 0, NULL, 0, NULL, 0, 1, '2016-04-08 15:22:18.000', NULL, NULL)
EXEC(N'INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES (''ef9353c6-1b5b-4822-b315-d3c92f8066c6'', ''Import Report Card'', ''Import Report Card'', 0, N''
Declare @ltCustUploads Table
(
 Name varchar(40),
 TA_Code varchar(3),
 ImportDate DateTime, 
 ImportType VarChar(25),
 Delq_Cnt Int,
 Delq_Cnt2 Int,
 ImmovableDelq Int,
 MovableDelq Int,
 ServiceProvider VarChar(256),
 ServiceRep VarChar(256),
 Auction_ForSale Int,
 File_Move_ID Int,
 Property_Import_ID Int
)
Declare @lcName varchar(40)
Declare @lcPrefix varchar(3)
Declare @llOk Bit
Declare @lcDBName varchar(256)
Declare @lcServiceProvider VarChar(256)
Declare @lcServiceRep VarChar(256)
Declare @lcSQL VarChar(max) 
Declare @ldMaxDate DateTime
Declare @lnDelinquent Int
Declare @lnProvider_Count Int
Declare @lcImportID UniqueIdentifier
Declare @lcImportID2 UniqueIdentifier
Declare @lnDelq_Cnt Int
Declare @lnDelq_Cnt2 Int
Declare @lnAuction_ForSale Int
Declare @lnFile_Move_ID Int
Declare @lnProperty_Import_ID Int
Declare csrTaxAuthorities Cursor For
Select
   TA.Name,
   TA.Prefix
   From civicsource.dbo.TaxAuthorities As TA
   Where IsActive = 1
Open csrTaxAuthorities
Fetch Next From csrTaxAuthorities Into @lcName,@lcPrefix
While @@FETCH_STATUS = 0 Begin
   Set @llOk = 1
   SEt @lcServiceRep = ''''Not Assigned''''
   If @lcPrefix = ''''CNO''''
      Begin
         Use civicsource_NewOrleans
         Set @lcServiceProvider = ''''New Orleans/Inhouse''''
      End
   Else If @lcPrefix = ''''CDS''''
      Begin
         Use civicsource_CaddoParishSheriff
         Set @lcServiceProvider = ''''Hamer Enterprises''''
      End
   Else If @lcPrefix = ''''SMS''''
      Begin
         Use civicsource_StMaryParishSheriff
         Set @lcServiceProvider = ''''Software and Services''''
      End
   Else If @lcPrefix = ''''IBS''''
      Begin
         Use civicsource_IberiaParishSheriff
         Set @lcServiceProvider = ''''Software and Services''''
      End
   Else If @lcPrefix = ''''LFS''''
      Begin
         Use civicsource_LafourcheParishSheriff
         Set @lcServiceProvider = ''''Software and Services''''
      End
   Else If @lcPrefix = ''''LOR''''
      Begin
         Use civicsource_Loreauville
         Set @lcServiceProvider = ''''''''
         Set @lcServiceRep = ''''Kay''''
      End
   Else If @lcPrefix = ''''PAT''''
      Begin
         Use civicsource_Patterson
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Kay''''
      End
   Else If @lcPrefix = ''''JEN''''
      Begin
         Use civicsource_Jeanerette
         Set @lcServiceProvider = ''''CSDC''''
      End
   Else If @lcPrefix = ''''WAL''''
      Begin
         Use civicsource_WallaWalla
         Set @lcServiceProvider = ''''''''
      End
   Else If @lcPrefix = ''''SLG''''
      Begin
         Use civicsource_StLandryParishGovernment
         Set @lcServiceProvider = ''''''''
      End
   Else If @lcPrefix = ''''IBG''''
      Begin
         Use civicsource_IberiaParishGovernment
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''Alyssa''''
      End
   Else If @lcPrefix = ''''SMG''''
      Begin
         Use civicsource_StMaryParishGovernment
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''Alyssa''''
      End
   Else If @lcPrefix = ''''OCS''''
      Begin
         Use civicsource_OuachitaParishSheriff
         Set @lcServiceProvider = ''''Software and Services''''
      End
   Else If @lcPrefix = ''''WMR''''
      Begin
         Use civicsource_WestMonroe
         Set @lcServiceProvider = ''''SunGuard''''
      End
   Else If @lcPrefix = ''''SHR''''
      Begin
         Use civicsource_Shreveport
         Set @lcServiceProvider = ''''Shreveport/Inhouse''''
      End
   Else If @lcPrefix = ''''JDS''''
      Begin
         Use civicsource_JeffersonDavisParishSheriff
         Set @lcServiceProvider = ''''GeoManage/Generic''''
      End
   Else If @lcPrefix = ''''PCS''''
      Begin
         Use civicsource_PointeCoupeeParishSheriff
         Set @lcServiceProvider = ''''Software and Services''''
      End
   Else If @lcPrefix = ''''TPS''''
      Begin
         Use civicsource_TangipahoaParishSheriff
         Set @lcServiceProvider = ''''Software a'', ''TA Name,TA Code,Imort Disabled,File Move,Import ID,Service Provider,Last Import Received,Days Since Last Import,Current Delinquent Count,Prior Delinquent Count, % Change'', 18, 1, NULL, 0, NULL, 0, 2, ''2016-08-30 14:07:15.000'', NULL, NULL)')
EXEC(N'UPDATE [dbo].[DataExports] SET [Query].WRITE(N''nd Services''''
         Set @lcServiceRep = ''''Matt''''
      End
   Else If @lcPrefix = ''''UPS''''
      Begin
         Use civicsource_UnionParishSheriff
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''Matt''''
      End
   Else If @lcPrefix = ''''VPS''''
      Begin
         Use civicsource_VernonParishSheriff
         Set @lcServiceProvider = ''''Tyler Technologies''''
         Set @lcServiceRep = ''''Kay''''
      End
   Else If @lcPrefix = ''''MPS''''
      Begin
         Use civicsource_MorehouseParishSheriff
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''Matt''''
      End
   Else If @lcPrefix = ''''LPS''''
      Begin
         Use civicsource_LincolnParishSheriff
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''Matt''''
      End
   Else If @lcPrefix = ''''GRA''''
      Begin
         Use civicsource_GrantParishSheriff
         Set @lcServiceProvider = ''''Excel Software''''
      End
   Else If @lcPrefix = ''''WES''''
      Begin
         Use civicsource_Westwego
         Set @lcServiceProvider = ''''Westwego/Inhouse''''
         Set @lcServiceRep = ''''Kay''''
      End
   Else If @lcPrefix = ''''PON''''
      Begin
         Use civicsource_Ponchatoula
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Matt''''
      End
   Else If @lcPrefix = ''''HAM''''
      Begin
         Use civicsource_Hammond
         Set @lcServiceProvider = ''''Hammond/Inhouse''''
      End
   Else If @lcPrefix = ''''FRA''''
      Begin
         Use civicsource_Franklin
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Kay''''
      End
   Else If @lcPrefix = ''''COP''''
      Begin
         Use civicsource_Opelousas
         Set @lcServiceProvider = ''''CSDC''''
      End
   Else If @lcPrefix = ''''GRE''''
      Begin
         Use civicsource_Gretna
         Set @lcServiceProvider = ''''Tyler Technologies''''
         Set @lcServiceRep = ''''Matt''''
      End
   Else If @lcPrefix = ''''EBR''''
      Begin
         Use civicsource_EastBatonRougeParishSheriff
         Set @lcServiceProvider = ''''Software and Services''''
      End
   Else If @lcPrefix = ''''THI''''
      Begin
         Use civicsource_Thibodaux
         Set @lcServiceProvider = ''''Tyler Technologies''''
         Set @lcServiceRep = ''''Kay''''
      End
   Else If @lcPrefix = ''''CPS''''
      Begin
         Use civicsource_ConcordiaParishSheriff
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''Kay''''
      End
   Else If @lcPrefix = ''''CNI''''
      Begin
         Use civicsource_NewIberia
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''Kay''''
      End
   Else If @lcPrefix = ''''NPS''''
      Begin
         Use civicsource_NatchitochesParishSheriff
         Set @lcServiceProvider = ''''Software and Services''''
      End
   Else If @lcPrefix = ''''BOG''''
      Begin
         Use civicsource_Bogalusa
         Set @lcServiceProvider = ''''Inhouse/Generic''''
         Set @lcServiceRep = ''''Kay''''
      End
   Else If @lcPrefix = ''''MAD''''
      Begin
         Use civicsource_MadisonParishSheriff
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''Matt''''
      End
   Else If @lcPrefix = ''''LSP''''
      Begin
         Use civicsource_LasalleParishSheriff
         Set @lcServiceProvider = ''''Software and Services''''
      End
   Else If @lcPrefix = ''''COG''''
      Begin
         Use civicsource_Grambling
         Set @lcServiceProvider = ''''Inhouse/Generic''''
      End   
   Else If @lcPrefix = ''''CAL''''
      Begin
         Use civicsource_CaldwellParishSheriff
         Set @lcServiceProvider = ''''GeoManage/Generic''''
         Set @lcServiceRep = ''''Kay''''
      End   
   Else If @lcPrefix = ''''BPS''''
      Begin
         Use civicsource_BossierParishSheriff
         Set @lcServiceProvider = ''''Inhouse/Generic''''
         Set @lcServiceRep = ''''Matt''''
      End      
   Else If @lcPrefix = ''''TOF''''
      Begin
         Use civicso'',NULL,NULL) WHERE [Id] = ''ef9353c6-1b5b-4822-b315-d3c92f8066c6''
UPDATE [dbo].[DataExports] SET [Query].WRITE(N''urce_Franklinton
         Set @lcServiceProvider = ''''Inhouse/Generic''''
         Set @lcServiceRep = ''''Kay''''
      End      
   Else If @lcPrefix = ''''BAS''''
      Begin
         Use civicsource_Bastrop
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''Matt''''
      End     
   Else If @lcPrefix = ''''TOV''''
      Begin
         Use civicsource_Vivian
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Kay''''
      End     
   Else If @lcPrefix = ''''TOH''''
      Begin
         Use civicsource_Haughton
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Matt''''
      End        
   Else If @lcPrefix = ''''TOS''''
      Begin
         Use civicsource_Sarepta
         Set @lcServiceProvider = ''''CSDC''''
      End   
    Else If @lcPrefix = ''''TOG''''
      Begin
         Use civicsource_GoldenMeadow
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Kay''''
      End
    Else If @lcPrefix = ''''TOB''''
      Begin
         Use civicsource_Blanchard
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Matt''''
      End                
    Else If @lcPrefix = ''''TAC''''
      Begin
         Use civicsource_Amite
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Matt''''
      End                
    Else If @lcPrefix = ''''TGW''''
      Begin
         Use civicsource_Greenwood
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Matt''''
      End                
    Else If @lcPrefix = ''''VAA''''
      Begin
         Use civicsource_VillePlatte
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Kay''''
      End              
    Else If @lcPrefix = ''''MAA''''
      Begin
         Use civicsource_MorehouseParishPoliceJury
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''Alyssa''''
      End              
    Else If @lcPrefix = ''''IAA''''
      Begin
         Use civicsource_NewIberiaCityCouncil
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''Alyssa''''
      End              
    Else If @lcPrefix = ''''JAA''''
      Begin
         Use civicsource_JeffersonDavisPoliceJury
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''Alyssa''''
      End              
    Else If @lcPrefix = ''''CPJ''''
      Begin
         Use civicsource_ConcordiaParishPoliceJury
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''Alyssa''''
      End              
    Else If @lcPrefix = ''''DAA''''
      Begin
         Use civicsource_DesotoParishPoliceJury
         Set @lcServiceProvider = ''''Inhouse/Generic''''
         Set @lcServiceRep = ''''Alyssa''''
      End              
    Else If @lcPrefix = ''''TLP''''
      Begin
         Use civicsource_TownOfLakeProvidence
         Set @lcServiceProvider = ''''Inhouse/Generic''''
         Set @lcServiceRep = ''''Alyssa''''
      End              
    Else If @lcPrefix = ''''OCO''''
      Begin
         Use civicsource_OrangeCountyTaxCollector
         Set @lcServiceProvider = ''''Inhouse/Generic''''
         Set @lcServiceRep = ''''Alyssa''''
      End              
    Else If @lcPrefix = ''''PAA''''
      Begin
         Use civicsource_PointeCoupeeParishPoliceJury
         Set @lcServiceProvider = ''''Inhouse/Generic''''
         Set @lcServiceRep = ''''Alyssa''''
      End              
    Else If @lcPrefix = ''''SMO''''
      Begin
         Use civicsource_StBernardParishGovernment
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''Alyssa''''
      End              
    Else If @lcPrefix = ''''TAA''''
      Begin
         Use civicsource_TangipahoaParishGovernment
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''Alyssa''''
      End              
    Else If @lcPrefix = ''''BAA''''
      Begin
         Use civicsource_Berwick
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServic'',NULL,NULL) WHERE [Id] = ''ef9353c6-1b5b-4822-b315-d3c92f8066c6''
UPDATE [dbo].[DataExports] SET [Query].WRITE(N''eRep = ''''Kay''''
      End              
    Else If @lcPrefix = ''''BSL''''
      Begin
         Use civicsource_Basile
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Kay''''
      End              
    Else If @lcPrefix = ''''BPP''''
      Begin
         Use civicsource_BossierParishPoliceJury
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Kay''''
      End              
    Else If @lcPrefix = ''''EBG''''
      Begin
         Use civicsource_EastBatonRougeParishGovernment
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Kay''''
      End              
    Else If @lcPrefix = ''''EPJ''''
      Begin
         Use civicsource_EvangelineParishPoliceJury
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Kay''''
      End              
    Else If @lcPrefix = ''''KNT''''
      Begin
         Use civicsource_Kentwood
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Kay''''
      End              
    Else If @lcPrefix = ''''MAB''''
      Begin
         Use civicsource_Mamou
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Kay''''
      End              
    Else If @lcPrefix = ''''PBR''''
      Begin
         Use civicsource_PorteBarre
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Kay''''
      End              
    Else If @lcPrefix = ''''SHB''''
      Begin
         Use civicsource_ShelbyCounty
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Kay''''
      End              
    Else If @lcPrefix = ''''SAB''''
      Begin
         Use civicsource_StJohnTheBaptistParishDistrictAttorney
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Kay''''
      End              
    Else If @lcPrefix = ''''WAB''''
      Begin
         Use civicsource_WestBatonRougeParish
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''Kay''''
      End              
    Else If @lcPrefix = ''''SPS''''
      Begin
         Use [civicsource_StBernardParishSheriff]
         Set @lcServiceProvider = ''''Software and Services''''
         Set @lcServiceRep = ''''''''
      End              
    Else If @lcPrefix = ''''PBR''''
      Begin
         Use [civicsource_PorteBarre]
         Set @lcServiceProvider = ''''CSDC''''
         Set @lcServiceRep = ''''''''
      End              
    Else If @lcPrefix = ''''COL''''
      Begin
         Use [civicsource_Leesville]
         Set @lcServiceProvider = ''''Inhouse/Generic''''
         Set @lcServiceRep = ''''''''
      End              
    Else If @lcPrefix = ''''STG''''
      Begin
         Use [civicsource_StTammanyParishGovernment]
         Set @lcServiceProvider = ''''Inhouse/Generic''''
         Set @lcServiceRep = ''''''''
      End              
    Else If @lcPrefix = ''''CMN''''
      Begin
         Use [civicsource_Mandeville]
         Set @lcServiceProvider = ''''''''
         Set @lcServiceRep = ''''''''
      End              
    Else If @lcPrefix = ''''TOI''''
      Begin
         Use [civicsource_Independence]
         Set @lcServiceProvider = ''''''''
         Set @lcServiceRep = ''''''''
      End              
    Else If @lcPrefix = ''''HAR''''
      Begin
         Use [civicsource_Harahan]
         Set @lcServiceProvider = ''''Tyler Technologies''''
         Set @lcServiceRep = ''''''''
      End              
    Else If @lcPrefix = ''''CPG''''
      Begin
         Use [civicsource_CaddoParishGovernment]
         Set @lcServiceProvider = ''''Hamer Enterprises''''
         Set @lcServiceRep = ''''''''
      End              
    Else
      Set @llOk = 0
   If @llOk = 1 
      Begin
		  Set @lcImportID = (SELECT Top 1 ImportID From cvs.PropertyImport Where DelinquentCount Is Not Null Order by StartDate Desc)
		  Set @lcImportID2 = (SELECT Top 1 ImportID From cvs.PropertyImport Where ImportID <> @lcImportID and DelinquentCount Is Not Null Order by StartDate Desc)
		  Set @ldMaxDate = (SELECT StartDate FROM cvs.PropertyImport Where ImportID = @lcImportID)
		  Set @lnDelq_Cnt = (Select DelinquentCo'',NULL,NULL) WHERE [Id] = ''ef9353c6-1b5b-4822-b315-d3c92f8066c6''
UPDATE [dbo].[DataExports] SET [Query].WRITE(N''unt From cvs.PropertyImport Where ImportID = @lcImportID)
		  Set @lnDelq_Cnt2 = (Select DelinquentCount From cvs.PropertyImport Where ImportID = @lcImportID2)
		  Set @lnAuction_ForSale = (Select Count(*) From cvs.Auctions Where State = 10)
		  Set @lnFile_Move_ID = (Select ID From batchprocess.dbo.Schedule S Where S.[Group] = @lcPrefix and S.Name Like ''''File Move%'''' and S.ScheduleType = 2)
		  Set @lnProperty_Import_ID = (Select ID From batchprocess.dbo.Schedule S Where S.[Group] = @lcPrefix and S.Name Like ''''Property Import%'''')
		   INSERT INTO @ltCustUploads 
			 (Name,TA_Code,ImportDate,Delq_Cnt,Delq_Cnt2,ServiceProvider,ServiceRep,Auction_ForSale,File_Move_ID,Property_Import_ID) 
		  Values 
			 (@lcName,@lcPrefix,@ldMaxDate,@lnDelq_Cnt,@lnDelq_Cnt2,@lcServiceProvider,@lcServiceRep,@lnAuction_ForSale,@lnFile_Move_ID,@lnProperty_Import_ID)
		  --Update @ltCustUploads Set ImportDate = @ldMaxDate Where TA_Code = @lcPrefix
		  --Set @lnDelinquent = (Select COUNT(*) From cvs.properties Where AmountDue > 0 and PropertyType = 0)
		  --Update @ltCustUploads Set ImmovableDelq = @lnDelinquent Where TA_Code = @lcPrefix
		  --Set @lnDelinquent = (Select COUNT(*) From cvs.properties Where AmountDue > 0 and  PropertyType = 1)
		  --Update @ltCustUploads Set MovableDelq = @lnDelinquent Where TA_Code = @lcPrefix
		  --Update @ltCustUploads Set ServiceProvider = @lcServiceProvider Where TA_Code = @lcPrefix
      End
   Else
      Begin 
         Print @lcPrefix + '''' is missing'''' 
      End 
   Fetch Next From csrTaxAuthorities Into @lcName,@lcPrefix
End--While
Close csrTaxAuthorities
Deallocate csrTaxAuthorities
--Add one date to TA''''s that process before midnight
Update @ltCustUploads
   Set ImportDate = DateAdd(day,1,ImportDate)
   Where TA_Code In (''''XXX'''')
Update @ltCustUploads
   Set ImportType = ''''Automatic''''
Update @ltCustUploads
   Set ImportType = ''''Manual''''
   Where TA_Code In (''''COL'''')
Update @ltCustUploads
   Set ImportType = ''''Out of Contract''''
   Where TA_Code In (Select Prefix From CivicSource.dbo.TaxAuthorities Where IsActive = 0)
--(''''TOS'''',''''OCS'''',''''SHR'''',''''JDS'''',''''GRA'''',''''EBR'''',''''WAL'''',''''HAM'''',''''PCS'''',''''JEN'''',''''COP'''',''''WMR'''',''''NPS'''',''''LSP'''',''''OCO'''')
Update @ltCustUploads
   Set ImportType = ''''Adjudication Import''''
   Where TA_Code In (Select Prefix From CivicSource.dbo.TaxAuthorities Where TaxAuthorityMode = 1)
--   (''''TAA'''',''''IBG'''',''''IAA'''',''''SMG'''',''''MAA'''',''''CPJ'''',''''SMO'''',''''BPP'''',''''EBG'''',''''EPJ'''',''''SHB'''',''''SAB'''',''''WAB'''',''''STG'''',''''TOI'''')
--Exclude all TA''''s that do not submit a file overnight  
SELECT 
   CUL.Name As [TA Name],
   TA_Code As [TA Code],
   Case
      When IsEnabled = 1 Then ''''''''
	  Else ''''Yes ''''
   End [Importer Disabled],
   IsNull(Cast(File_Move_ID as VarChar(4)),''''N/A'''') [File_Move_ID],
   Property_Import_ID,
   ServiceProvider As [Service Provider],
   CONVERT(VarChar(10),ImportDate,101) As [Last Import Received],
   DATEDIFF(dd,CONVERT(VarChar(10),ImportDate,101),GETDATE()) As [Days Since Last Import],
   Delq_Cnt As [Current Delinquent Count],
   IsNull(Delq_Cnt2,0) As [Prior Delinquent Count],
   cast (CASE WHEN IsNull(Delq_Cnt2,0) = 0 AND Delq_Cnt = 0 THEN 0 when IsNull(Delq_Cnt2,0) = 0 THEN 100 ELSE ABS(CONVERT(decimal(5,2),((convert(float,Delq_Cnt) / convert(float,Delq_Cnt2)) - 1) * 100)) END AS VARCHAR(10)) + ''''%'''' as [% Change]
FROM @ltCustUploads CUL
Join batchprocess.dbo.Schedule S On S.[Group] = TA_Code and S.Name Like ''''Property Import%''''
Where ImportDate Is Not Null and ImportType In (''''Automatic'''')
Order by ImportType,[Days Since Last Import] Desc, Delq_Cnt, CUL.Name
  '',NULL,NUL'
+N'L) WHERE [Id] = ''ef9353c6-1b5b-4822-b315-d3c92f8066c6''
')
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('763a969e-a05a-4ea8-acd6-d7ada4074585', 'Resolutions', 'Summary of Resolutions by Month', 0, N'select 
case start.Type WHEN 0 THEN ''Immovable'' WHEN 1 THEN ''Movable'' END typ, 
start.yr yr, start.mn_text mn,
start.tot - ending.tot resolved_cnt,
''$'' + CONVERT(varchar(20), CONVERT(money, (start.Principal - ending.Principal)), 1) resolve_prin_dol,
''$'' + CONVERT(varchar(20), CONVERT(money, (start.Interest - ending.Interest)), 1) resolve_int_dol,
''$'' + CONVERT(varchar(20), CONVERT(money, (start.Collection - ending.Collection)), 1) resolve_coll_dol,
''$'' + CONVERT(varchar(20), CONVERT(money, (start.Other - ending.Other)), 1) resolve_other_dol
from
	(SELECT pis.Type, YEAR(pis.Date) yr, MONTH(pis.Date) mn, DATENAME(month,pis.Date) mn_text, (pis.Unchanged + pis.Additions) tot, 
	pis.Principal, pis.Interest, pis.Collection, pis.Other 
		FROM
		[rpt].[PropertyImportSnapshot] pis 
		inner join
		(SELECT MIN(Date) dt, Type
		  FROM [rpt].[PropertyImportSnapshot] 
		  group by MONTH(Date),YEAR(Date),Type) start
		on start.dt = pis.Date and start.Type = pis.Type
		WHERE pis.Type in (0,1)) start
inner join 
	(SELECT pis.Type, YEAR(pis.Date) yr, MONTH(pis.Date) mn, DATENAME(month,pis.Date) mn_text, (pis.Unchanged + pis.Additions) tot, 
	pis.Principal, pis.Interest, pis.Collection, pis.Other
		FROM
		[rpt].[PropertyImportSnapshot] pis 
		inner join
		(SELECT MAX(Date) dt, Type
		  FROM [rpt].[PropertyImportSnapshot] 
		  group by MONTH(Date),YEAR(Date),Type) ending
		on ending.dt = pis.Date and ending.Type = pis.Type
		WHERE pis.Type in (0,1)) ending
on start.mn = ending.mn and start.yr = ending.yr and start.Type = ending.Type
order by start.Type, start.yr desc, start.mn desc', 'Type,Year,Month,#Resolved,Principal Resolved,Interest Resolved,Collection Resolved,Other Resolved', 45, 1, NULL, 0, NULL, 0, 0, '2016-06-13 19:03:23.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('e51ead23-63b2-4e9e-b4fc-d8625ab56c1d', 'Adjudicated tax sale properties', 'Properties in the current tax sale that did not sell in prior years', 0, N'
Select ''"'' + P.AccountNumber + ''"'',P.LegalDescription,P.Address1
From cvs.Auctions A
Join cvs.Properties P On P.ID = A.PropertyID
Where A.State = 10 and A.AuctionType = ''TaxSale'' and P.ID In (
Select Distinct A.PropertyID
From cvs.Auctions A
Where A.State = 40 and A.AuctionType = ''TaxSale'' and A.IsRedeemed = 0
)
', 'AccountNumber,Legal Description,Property Address', 24, 1, NULL, 0, NULL, 0, 0, '2016-07-19 19:12:45.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('332224d2-087f-4c26-8803-d8718714a545', 'Banned or Disabled Users', 'List of users that have been flagged as banned or disabled', 0, N'
Select Name, Email, Address1 + '' '' + Address2 + '' '' + City + '', '' + State + '' '' + PostalCode As Address,
BusinessAreaCode + ''-'' + BusinessPrefix + ''-'' + BusinessSuffix As Phone,
Case IsBanned When 1 Then ''Yes'' Else ''No'' End As Banned,
Case IsBiddingDisabled When 1 Then ''Yes'' Else ''No'' End As BiddingDisabled
From CivicSource_Auctioneer_webprod05.sch.AuctioneerUserSearchItems     
Where IsBiddingDisabled = 1 or IsBanned = 1
', 'Name,Email,Address,Phone,Banned,Bidding Disabled', 43, 1, NULL, 0, NULL, 0, 0, '2016-07-19 14:28:07.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('d011efc8-d91d-4b09-9339-d9b550fb8f87', 'No-Go report', 'All Adjudication sales that have been No-Go''d showing their most recent no-go details', 0, N'Select	
   ''"'' + P.AccountNumber + ''"'' AS [Account Number],
   CASE WHEN P.Address1 = '''' THEN ''NO ADDRESS'' ELSE P.Address1 end AS [Address],
   ISNULL(CONVERT(VARCHAR(10), s.StartTime, 101),''TBA'') AS [Sale Date],
      Case WHEN a.state = 0 THEN ''Candidate''
     WHEN A.state = 1 THEN ''Public''
	 WHEN a.state = 2 THEN ''Researching''
	 WHEN a.state = 3 THEN ''Research Complete''
	 WHEN a.state = 10 THEN ''Scheduled''
	 WHEN a.state = 20 THEN ''Canceled''
	 WHEN a.state = 30 THEN ''Sold''
	 WHEN a.state = 40 THEN ''Not Sold''
   END AS [Current Status],
   CONVERT(VARCHAR(10), h.TriggeredOn, 101) AS [No-Go date],
   h.Username AS [No-Go''d by],
   h.Reason
From cvs.Auctions a 
inner join cvs.Properties p on a.PropertyId = p.Id 
LEFT join cvs.Sales s ON s.SaleId = a.SaleId
inner join (select	row_number() over(Partition by AuctionId order by TriggeredOn desc) Num, HoldHistoryId, AuctionId, Reason, Username, TriggeredOn from cvs.HoldHistory WHERE IsHolding = 1) h on h.AuctionId = a.AuctionId and h.Num = 1 
where a.AuctionType = ''Adjudication''
', 'Account Number, Address, Sale Date, Current Status, No-Go date, No-Go''d by, Reason', 2, 1, NULL, 0, NULL, 0, 1, '2016-08-04 17:08:11.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('4c03d4dd-9cc1-4c7b-bbe1-dd97f902b9d8', 'Adjudicated Holds', '', 0, N'
Select	
   ''"'' + P.AccountNumber + ''"'', 
   P.Address1 + '' '' + P.Address2,
   LTrim(P.City + '' '' + P.State + '' '' + P.PostalCode), 
   IsNull(Convert(VarChar(10),r.DepositMadeOn,101),''''), 
   IsNull(ap.Email,''''), 
   Case When a.IsHeld = 1 then ''Yes'' 
        Else ''No'' 
   End, 
   Case When a.IsHeld = 1 then Convert(VarChar(10),h.TriggeredOn,101) 
        Else '''' 
   End, 
   Case When a.IsHeld = 1 then h.Reason 
        Else '''' 
   End, 
   Case When a.IsHeld = 1 then h.Username 
        Else '''' 
   End, 
   Case When r.IsAdjoiningLandowner = 1 Then ''Yes'' 
        Else ''No'' 
   End, 
   Case When A.State = 0 Then ''Candidate''
        When A.State = 1 Then ''Public''
        When A.State = 2 Then ''Researching''
        When A.State = 3 Then ''Research Complete''
		When A.State = 10 Then ''For Sale'' 
   End, 
   IsNull(Convert(VarChar(10),ads.StartTime,101),'''') 
From cvs.Auctions a 
inner join cvs.Properties p on a.PropertyId = p.Id 
Left join cvs.Deposits r on r.AuctionId = a.AuctionId 
Left join cvs.Purchasers pur on pur.PurchaserId = r.PurchaserId 
Left join CivicSource.dbo.AuctioneerProfiles ap on ap.Username = pur.Username 
left outer join (select	row_number() over(Partition by AuctionId order by TriggeredOn desc) Num, HoldHistoryId, AuctionId, Reason, Username, TriggeredOn from cvs.HoldHistory) h on h.AuctionId = a.AuctionId and h.Num = 1 
Join CivicSource.dbo.TaxAuthorities TA On TA.SafeName = (Select Replace(DB_Name(),''CivicSource_'','''')) 
left outer Join cvs.Sales ads On ads.SaleID = A.SaleID AND SaleType = ''Adj''
Where	a.AuctionType = ''Adjudication'' and a.[State] in (2,3,10) and (ads.StartTime is Null or ads.StartTime >= GetDate()) and a.IsHeld = 1
Order by r.DepositMadeOn', 'Account Number,Property Address,Property City,Deposit Made On,Deposit Made By,Is Held,Held On,Reason,Held By,Adjoining,Auction State,Sale Date', 6, 1, NULL, 0, NULL, 0, 1, '2016-08-15 14:57:07.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('27e1ac95-be32-4bee-9f22-e31ce2ab0dee', 'Adjudicated Immovable Properties', 'All adjudicated immovable properties with owner contact information', 0, N'
SELECT p.AccountNumber, p.Address1 + CASE p.Address2 WHEN null then '' '' ELSE '' '' + p.Address2 END ''Address''  
, p.LegalDescription, dbo.GetPropertyOwnerName(po.PropertyOwnerId) ''Owner''  
, CASE WHEN poa.Address1 is null or LEN(poa.Address1) = 0 then '''' else poa.Address1 + '', '' end 
+ CASE WHEN poa.Address2 is null or LEN(poa.Address2) = 0 then '''' else poa.Address2 + '', '' end 
+ CASE WHEN poa.City is null or LEN(poa.City) = 0  then '''' else poa.City + '', '' end 
+ CASE WHEN poa.State  is null or LEN(poa.State ) = 0  then '''' else poa.State + '' '' end 
+ CASE  WHEN poa.PostalCode is null or LEN(poa.PostalCode) = 0  then '''' else poa.PostalCode + '', '' end
+ CASE WHEN poa.Country is null or LEN(poa.Country ) = 0  then '''' else poa.Country end  ''Owner Address''
, CASE WHEN p.IsAdjudicated = 1 THEN ''True'' ELSE ''False'' END ''IsAdjudicated'' 
, CASE WHEN p.IsBankrupt = 1 THEN ''True'' ELSE ''False'' END ''IsBankrupt''  
, p.AmountDue  FROM [cvs].[Properties] p  inner join cvs.PropertyOwners po   on po.PropertyId = p.Id     
inner join cvs.PropertyOwnerAddresses poa  on poa.PropertyOwnerId = po.PropertyOwnerId     
and poa.AddressIndex = 0  WHERE p.AmountDue > 0 and p.PropertyType = 0 and p.IsAdjudicated = 1 order by p.AccountNumber', 'Account Number, Address, Legal, Owner Name, Owner Address, Status, Bankrupt, Amount Due', 105, 1, NULL, 0, NULL, 0, 0, '2016-08-11 18:44:53.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('44086559-1884-4cd5-b57d-e50aa65cea59', 'ACH Refunds', 'ACH REFUNDS', 0, N'SELECT ap.Email, ft.Name, ft.Amount, ft.ReferenceId, ach.ProcessorReferenceNumber, rt.ProcessorReferenceNumber, ach.SentToProcessorOn, rt.SentToProcessorOn,  rt.AchState, rt.ReturnedReason
FROM fin.AchRefunds ar
INNER JOIN fin.AchTransactions rt ON rt.AchTransactionId = ar.AchRefundId
INNER JOIN fin.AchTransactions ach ON ach.AchTransactionId = ar.AchPaymentId
INNER JOIN fin.FinancialTransactions ft ON ft.FinancialTransactionId = ach.AchTransactionId
INNER JOIN fin.AccountEntries ae ON ae.TransactionId = ft.FinancialTransactionId
INNER JOIN fin.Accounts acc ON acc.AccountId = ae.AccountId
INNER JOIN CivicSource.dbo.AuctioneerProfiles ap ON ap.Username = acc.Name
WHERE (ach.SentToProcessorOn >= ''2015-08-10 00:00:00.000'') OR (rt.SentToProcessorOn >= ''2015-08-10 00:00:00.000'')
ORDER BY AchState', 'Email,Name,Amount,ReferenceId,Processor Reference - payment, Processor Reference - refund, Payment Set, Refund sent, Refund state, Refund return', 5, 0, NULL, 0, NULL, 0, 1, '2016-04-27 18:53:11.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('06da07f0-b56a-4ea3-a3fb-e84dd234909b', 'Delinquent Movable Properties - Call Lists', 'All movable delinquent properties that have an amount due greater than zero with owner contact information', 0, N'/****** Script for SelectTopNRows command from SSMS ******/
SELECT p.AccountNumber,
dbo.GetPropertyOwnerName(p.PropertyOwnerId) ''Owner Name'',
CASE WHEN poa.Address1 is null or LEN(poa.Address1) = 0 then '''' else poa.Address1 + '', '' end
+ CASE WHEN poa.Address2 is null or LEN(poa.Address2) = 0 then '''' else poa.Address2 + '', '' end
+ CASE WHEN poa.City is null or LEN(poa.City) = 0 then '''' else poa.City + '', '' end
+ CASE WHEN poa.State is null or LEN(poa.State ) = 0 then '''' else poa.State + '' '' end
+ CASE WHEN poa.PostalCode is null or LEN(poa.PostalCode) = 0 then '' '' else poa.PostalCode + '', '' end
+ CASE WHEN poa.Country is null or LEN(poa.Country ) = 0 then '' '' else poa.Country end ''Owner Address'',
coll.Balance ''Balance'',
CASE WHEN coll.PropertyId is null then ''No'' else ''Yes'' END ''Collection Fee''
  FROM [cvs].[Properties] p
  inner join cvs.PropertyOwners po on po.PropertyOwnerId = p.PropertyOwnerId
  inner join cvs.PropertyOwnerAddresses poa on poa.PropertyOwnerId = po.PropertyOwnerId and poa.AddressIndex = 0
  left outer join (
select pt.PropertyId, SUM(pt.Balance) ''Balance'' from cvs.PropertyTaxes pt
inner join cvs.TaxTypes tt on tt.TaxTypeId = pt.TaxTypeId
where tt.Category = 5 or pt.Collection > 0
group by pt.PropertyId ) coll on coll.PropertyId = p.Id
  where p.PropertyType = 1 and p.Status = 2 and p.IsBankrupt = 0 and p.IsAdjudicated = 0
  order by p.AccountNumber', 'Account Number, Owner Name, Owner Address, Balance, Collection Fee', 496, 1, NULL, 0, NULL, 0, 0, '2016-08-30 15:44:21.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('78a41929-914a-4a8b-84b1-e9ec2aa1de81', 'Properties in Tax Sale - All', 'All properties in the tax sale displays auction state and cancel date if canceled', 0, N'
Select 
   ''"'' + P.AccountNumber + ''"'', 
   Case
      When a.State = 10 Then ''For Sale''
	  When a.State = 20 Then ''Canceled''
	  When a.State = 30 Then ''Sold''
	  When a.State = 40 Then ''Not Sold''
   End ''Auction State'',
   Case
      When a.State = 20 Then (Select Top 1 CONVERT(VarChar(10),CreatedOn,101) 
	                          From cvs.AuctionStateHistory as ASH 
							  Where ASH.TaxSalePropertyID = A.AuctionID and
							        ASH.FromState = 10 and ASH.ToState = 20
							  Order by CreatedOn Asc)
	  Else Null
   End ''Canceled Date''
From cvs.Auctions a
Join cvs.Properties P on P.id = a.PropertyId
Where a.SaleId = ''<FILTER>''
  ', 'AccountNumber,Auction State,Cancel Date', 28, 1, N'
SELECT LEFT(DATENAME(m, ts.StartTime), 3) + '' '' + DATENAME(yyyy, StartTime)
        + '' Tax Sale'' AS Name ,
        ts.SaleId
FROM    cvs.Sales ts
WHERE   SaleType = ''tax''
ORDER BY EndTime DESC
', 0, 'Tax Sale', 0, 0, '2016-08-30 15:43:10.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('a8f7de33-57ab-4229-8521-ee310065fdb1', 'Campaign Sanity Check', 'List of letters that MAY have issues requiring investigation. Can include false positives', 0, N'declare @campaignid uniqueidentifier
set @campaignid = ''<FILTER>''

declare @isNewOrleans bit
set @isNewOrleans = (case when (db_name() like ''%NewOrleans%'') then 1 else 0 end)

-- Various flavors of malformed or unwanted addresses. can past into spreadsheet for Ops to determine.
select distinct crap.accountnumber, SUBSTRING(crap.reason,1,len(crap.reason)-1), crap.Name1, crap.name2, crap.Address1, crap.Address2, crap.City, crap.State, crap.PostalCode, crap.Country
from cvs.Properties p
inner join
(
    SELECT distinct Replace(l.DataAccountNumber,''.i'','''') as AccountNumber,

	CASE WHEN Name2 like ''%C/O C/O%'' THEN ''Stuttering C/O, '' ELSE '''' END + 

	CASE WHEN (Name1 like ''%Parish%'' and db_name() like ''%Parish%'') or (Name1 like ''%City of%'' and db_name() not like ''%parish%'') then ''Municipality, '' ELSE '''' END + 

	CASE WHEN (Len(POstalCode) > 5 and Len(PostalCode) <> 10 and Country = ''US'') THEN ''Bad Zip, '' ELSE '''' END +
	
	CASE WHEN Name1 like ''%UNDEFINED%'' or Name2 like ''%UNDEFINED%'' or Replace(Name1,'' '','''') = ''THEESTATEOF'' or Replace(Name2,'' '','''') = ''THEESTATEOF'' THEN ''Estate Undefined, '' ELSE '''' END + 
	
	CASE WHEN LEN(Name1) > 0 and Name2 like (''%'' + Name1 + ''%'') and name2 like ''%C/O%'' THEN ''C/O Identical, '' ELSE '''' END +
	
	CASE WHEN (Len(Address1) = 0 or Address1 like ''0%'' or Address1 = ''NONE'' or Address1 is null) THEN ''Leading Zero, '' ELSE '''' END +
	
	CASE WHEN (Address1 like ''%N/A%'' or Address1 like ''%Address%'') THEN ''N/A Address, '' ELSE '''' END + 
	
	CASE WHEN Address1 not like ''%[0-9]%'' and Address2 not like ''%[0-9]%'' and Address1 not like ''%N/A%'' and Address1 Not Like ''%Address%'' THEN ''No Street Number, '' ELSE '''' END +
	
	CASE WHEN COUNTRY <> ''US'' then ''International, '' ELSE '''' END +

	CASE WHEN  (l.City like ''%APO%'' and len(l.City) < 5)  or ( l.Address2 like ''%APO%'' and len(l.Address2) < 5) or ( l.Address1 like ''%APO%'' and len(l.Address1) < 5) or l.State in (''AE'',''AA'',''AP'') then ''Armed Forces, '' ELSE '''' END + 

	CASE WHEN @isNewOrleans = 1 AND (l.Address1 like ''%1300%Perdido%'' or l.Address1 like ''%1340%Poydra%'' or l.Address1 like ''6%4311%Perlita%'' or l.Address1 like ''%421%Loyola%'' OR name1 LIKE ''%city of new orleans%'' ) then ''CNO Address, '' else '''' END +

	CASE WHEN @isNewOrleans = 1 and (l.name1 like ''New Orleans redevelopment%'' or l.name1 = ''NORA'' or l.name1 = ''NORU'') then ''NORA-related, '' else '''' end 


	as Reason,
	REPLACE(REPLACE(l.Name1,char(10),'' ''),char(13),'' '') Name1,
	REPLACE(REPLACE(l.Name2,char(10),'' ''),char(13),'' '') Name2,
	REPLACE(REPLACE(l.Address1,char(10),'' ''),char(13),'' '') Address1,
	REPLACE(REPLACE(l.Address2,char(10),'' ''),char(13),'' '') Address2,
	l.City, l.State, l.POstalCode, l.Country
	  FROM [mail].[Campaigns] c
		inner join mail.Letters l on l.CampaignId = c.CampaignId
	where l.campaignid = @campaignid
) crap on crap.AccountNumber = p.AccountNumber
where crap.Reason <> ''''
  order by SUBSTRING(crap.reason,1,len(crap.reason)-1), crap.AccountNumber', 'Accoun Number,Reason,Name1,Name2,Address1,Address2,City,State,PostalCode,Country', 88, 1, N'SELECT Name, CampaignID from mail.Campaigns 
where state < 6 and state > 2
order by createdon desc', 0, 'Campaign', 0, 0, '2016-08-17 21:02:22.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('d79a9bc4-6af5-4243-a571-efbadc218a4c', 'Tax Sale Properties with sellable taxes', 'All properties in a tax sale with the status of each property and the sellable taxes', 0, N'SELECT 
   ''"'' + P.AccountNumber + ''"'' [Account Number],
   tt.name [Tax Type],
   CONVERT(VarChar(10),a.ModifiedOn,101) [Last Modified],
   Case
      When a.State = 20 Then ''Canceled''
	  When a.State = 10 Then ''For Sale''
	  Else ''Other''
   End [Auction Status],
   Cast(st.Balance as Money) [Balance],
   Cast(st.Interest as Money) [Interest],
   Cast(st.Penalty as Money) [Penalty],
   Cast(st.Collection as Money) [Collection]
  FROM [cvs].[Auctions] a
  Join cvs.SellableTaxes st On st.TaxSalePropertyId = a.AuctionId
  Join cvs.Properties P on P.ID = a.PropertyID
  Join cvs.TaxTypes tt on tt.TaxTypeId = st.TaxTypeId
  Where a.SaleID = ''<FILTER>''
  Order by AccountNumber', 'AccountNumber,Tax Type,Last Modified,Auction Status,Balance,Interest,Penalty,Collection', 14, 1, N'SELECT TOP 1
        LEFT(DATENAME(m, ts.StartTime), 3) + '' '' + DATENAME(yyyy, StartTime)
        + '' Tax Sale'' AS Name ,
        ts.SaleId
FROM    cvs.Sales ts
WHERE   SaleType = ''tax''
ORDER BY EndTime DESC', 0, 'Tax Sale', 0, 0, '2016-08-10 20:20:30.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('de39c17f-668e-46ce-a98a-f2061a4d5caa', 'All Movable Properties', 'All movable properties with owner contact information', 0, N'SELECT p.AccountNumber, p.Address1 + (CASE p.Address2 WHEN null then '' '' ELSE '' '' + p.Address2 END) ''Address''  
, p.LegalDescription, dbo.GetPropertyOwnerName(po.PropertyOwnerId) ''Owner''  
, CASE WHEN poa.Address1 is null or LEN(poa.Address1) = 0 then '''' else poa.Address1 + '', '' end 
+ CASE WHEN poa.Address2 is null or LEN(poa.Address2) = 0 then '''' else poa.Address2 + '', '' end 
+ CASE WHEN poa.City is null or LEN(poa.City) = 0  then '''' else poa.City + '', '' end 
+ CASE WHEN poa.State  is null or LEN(poa.State ) = 0  then '''' else poa.State + '' '' end 
+ CASE  WHEN poa.PostalCode is null or LEN(poa.PostalCode) = 0  then '''' else poa.PostalCode + '', '' end
+ CASE WHEN poa.Country is null or LEN(poa.Country ) = 0  then '''' else poa.Country end  ''Owner Address''
, CASE p.Status
	WHEN 0 THEN ''Due''
	WHEN 1 THEN ''Delinquent''
	WHEN 2 THEN ''Paid''
	ELSE '' ''
  END ''Status'',
CASE WHEN p.IsAdjudicated = 1 THEN ''True'' ELSE ''False'' END ''IsAdjudicated''  , 
CASE WHEN p.IsBankrupt = 1 THEN ''True'' ELSE ''False'' END ''IsBankrupt'' , 
p.AmountDue  FROM [cvs].[Properties] p  inner join cvs.PropertyOwners po   on po.PropertyId = p.Id     
inner join cvs.PropertyOwnerAddresses poa  on poa.PropertyOwnerId = po.PropertyOwnerId     
and poa.AddressIndex = 0  WHERE p.AmountDue > 0 and p.PropertyType = 1 order by p.AccountNumber', 'Account Number, Address, Legal, Owner Name, Owner Address, Status, Bankrupt, Amount Due', 96, 1, NULL, 0, NULL, 0, 0, '2016-08-12 20:48:21.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('c66e9dd5-b997-4ca5-8404-f567df349c5f', 'Tax Sale Property - Verification', 'Properties that remained in a tax sale after payment was accepted by the TA', 0, N'SELECT 
   ''"'' + P.AccountNumber + ''"'',
   Case
      When A.State = 10 Then ''For Sale''
	  When A.State = 30 Then ''Sold''
	  When A.State = 40 Then ''Not Sold''
   End [AuctionState]
  FROM [cvs].[Auctions] A 
  Join cvs.Properties P On P.ID = A.PropertyID 
  where A.SaleID = ''<FILTER>'' and A.State In (30,40) and P.Status != 2', 'AccountNumber,Auction State', 2, 1, N'SELECT LEFT(DATENAME(m, ts.StartTime), 3) + '' '' + DATENAME(yyyy, StartTime)
        + '' Tax Sale'' AS Name ,
        ts.SaleId
FROM    cvs.Sales ts
WHERE   SaleType = ''tax''
ORDER BY EndTime DESC', 0, 'Tax Sale', 0, 0, '2016-08-09 20:46:25.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('e214f490-25a0-4df2-942a-f711431ab4f6', 'Deposits to Transfer to Operating', 'A list of deposits that can be transferred from escrow to operating', 0, N'select	a.lotnumber AuctionNumber, d.depositprice Amount, d.depositmadeon [Date], a.distributedtocivicsource
from	cvs.auctions a
		inner join cvs.deposits d
			on d.auctionid = a.auctionid
where	d.status = 1 and a.state between 2 and 10 and d.amountunpaid = 0 ', 'Auction No.,Amount,Date,Already Transferred', 2, 1, NULL, 0, NULL, 0, 1, '2016-06-20 16:41:01.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('e59e11b9-a6e7-41ea-9896-faa4f323dc67', 'Deposits Held in Escrow', 'All Deposits not canceled for auctions that have not ended', 0, N'select	p.accountnumber, a.lotnumber, d.depositmadeon, d.depositprice
from	cvs.Auctions a
		inner join cvs.deposits d
			on d.auctionid = a.auctionid
		inner join cvs.properties p
			on p.id = a.propertyid
where	d.cancelledby is null and a.state < 20
order by	p.accountnumber', 'Account Number, Made On, Price', 35, 1, NULL, 0, NULL, 0, 1, '2016-08-29 14:21:01.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('84f82378-a4b8-4cb6-b97d-06a83d376895', 'Sold Adjudication Auctions', 'Sale Date and Closing Date for all sold adjudication auctions', 0, N'
  SELECT 
   ''"'' + p.accountnumber + ''"'',
   P.Address1,
   CONVERT(VarChar(10),sale.EndTime,101),
   Convert(VarChar(10),a.ClosingDate,101),
   Cast(A.Price as Money),
   Cast(A.StartingPrice as Money)
FROM cvs.Properties p
INNER JOIN cvs.auctions a ON a.PropertyId = p.Id
INNER JOIN cvs.Sales sale ON sale.SaleId = a.SaleId AND SaleType = ''Adj''
WHERE a.state = 30 AND a.AuctionType = ''adjudication''
ORDER BY sale.EndTime, p.AccountNumber
', 'Account Number,Address,Sale Date,Closing Date,Winning Bid,Starting Price', 57, 1, N'', 0, '', 0, 1, '2016-08-28 21:27:30.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('6bed0863-b195-4f1b-853d-15c57c972f77', 'Adjudication Sale Results for Jonah', 'Adjudication Sale Results for Jonah', 0, N'SELECT p.AccountNumber ''Tax Bill Number'',			
p.Address1 + CASE WHEN p.Address2 IS NOT NULL THEN '' '' + p.Address2 ELSE '''' END ''Address'',			
a2.currentPrice ''Price'', 					
res.name ''Abstract queue'', 			
res.username ''Abstractor''			
FROM cvs.Properties p			
INNER JOIN cvs.auctions a ON a.PropertyId = p.Id			
INNER JOIN cvs.Sales sale ON sale.SaleId = a.SaleId	AND SaleType = ''Adj''	
INNER JOIN PRODAUCTION.auction.dbo.auction a2 ON a2.id = a.AuctionId			
INNER JOIN CivicSource.dbo.TaxAuthorities ta ON ''civicsource_'' + ta.SafeName = DB_NAME()
LEFT JOIN (SELECT r.propertyid, q.name, agent.username, acc.accountnumber, acc.groupname FROM 			
			PRODRESEARCH.research.res.researches r
			INNER JOIN PRODRESEARCH.research.res.accounts acc ON acc.propertyid = r.propertyid
			INNER JOIN PRODRESEARCH.research.res.queues q ON q.id = r.queueid AND (q.name LIKE ''%abstract%'' OR q.name LIKE ''%legacy%'')
			INNER JOIN PRODRESEARCH.research.res.agents agent ON agent.id = r.assigneeid) res ON res.accountnumber = p.AccountNumber AND res.groupname = ta.Prefix
WHERE a.state = 30 AND a.SaleId = ''<FILTER>''				
', 'Tax Bill Number,Address,Price,Abstract Queue,Abstractor', 136, 1, N'SELECT
CONVERT(VARCHAR(100), StartTime, 106) + '' Sale'',
SaleId
FROM cvs.Sales
WHERE EndTime < GETDATE()
AND SaleType = ''Adj''
ORDER BY StartTime desc', 0, 'Adjudication Sale', 0, 0, '2016-08-04 17:00:56.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('a84c5d1d-0970-45e4-8d87-2605b9c2d3aa', 'CNO Payment File Summary', '**Works only for CNO** Sums owner payments by month and year for invoicing', 0, N'SELECT	DATEPART(m, appliedat) [Month], datepart(yy, appliedat) [Year], 
		SUM(case when tt.TaxCode IN (''66'', ''51'', ''67'') then interest + penalty else balance + interest + penalty end) Tax, 
		sum(case when tt.TaxCode  = ''51'' then balance else 0 end) [TC51],  
		sum(case when tt.TaxCode  = ''66'' then balance else 0 end) [TC66], 
		sum(case when tt.TaxCode  = ''67'' then balance else 0 end) [TC67],   
		sum([collection]) [Collection Fee], sum(total) Total
from  cvs.propertypayments pp
INNER JOIN cvs.TaxTypes tt ON tt.TaxTypeId = pp.TaxTypeId
left OUTER JOIN cvs.propertypaymenttypes ppt ON ppt.propertypaymenttypeid = pp.propertypaymenttypeid
WHERE ppt.TransactionCode IS NULL OR ppt.TransactionCode NOT IN (''090'')
group by datepart(yy, appliedat), datepart(m, appliedat)
order by [Year], [Month]', 'Month,Year,Tax,TC51,TC66,TC67,Collection Fee,Total', 110, 1, NULL, 0, NULL, 0, 0, '2016-05-31 19:24:39.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('afed8a41-eda3-4a4f-b9aa-36c239e939eb', 'CNO 2015 Immovable Properties - Call Lists', 'CNO April 2015 tax sale immovable properties that have an amount due greater than zero with owner contact information', 0, N'with Accounts (accountnumber) AS (
	select accountnumber from (
	select	p.accountnumber, p.id, p.amountdue
	from	cvs.properties p
	where	p.status = 2 and p.isadjudicated = 0 and p.taxclass != 3 and
			p.propertytype = 0 and accountnumber not in (
				select accountnumber from cvs.propertyexclusions where propertytype = 0 and (expireson is null or expireson > getdate())) and
			p.isbankrupt = 0 and p.id not in (
				select propertyid from cvs.propertytaxes pt inner join cvs.taxtypes tt on pt.taxtypeid = tt.taxtypeid where pt.total > 0 and tt.category = 1) and
			(p.id in (
				select	propertyid
				from	cvs.propertytaxes pt
						inner join cvs.taxtypes tt
							on tt.taxtypeid = pt.taxtypeid
				where	tt.category in (0,3) and pt.year between 2014 and 2014 and pt.total > 0
				group by propertyid
				having sum(total) >= 100) or
			(p.id in (
				select	propertyid
				from	cvs.propertytaxes pt
						inner join cvs.taxtypes tt
							on tt.taxtypeid = pt.taxtypeid
				where	tt.category in (0,3) and pt.year between 2012 and 2014 and pt.total > 0
				group by propertyid
				having sum(total) >= 100) and 
			p.id not in (
				select propertyid
				from	cvs.auctions
				where	saleid = ''937FED1E-C413-45F5-8DB3-A2F90108B55C'' and state = 10))) 
				) a
)

SELECT '' '' + p.AccountNumber + '' '',
dbo.GetPropertyOwnerName(p.PropertyOwnerId) ''Owner Name'',
CASE WHEN poa.Address1 is null or LEN(poa.Address1) = 0 then '''' else poa.Address1 + '', '' end
+ CASE WHEN poa.Address2 is null or LEN(poa.Address2) = 0 then '''' else poa.Address2 + '', '' end
+ CASE WHEN poa.City is null or LEN(poa.City) = 0 then '''' else poa.City + '', '' end
+ CASE WHEN poa.State is null or LEN(poa.State ) = 0 then '''' else poa.State + '' '' end
+ CASE WHEN poa.PostalCode is null or LEN(poa.PostalCode) = 0 then '' '' else poa.PostalCode + '', '' end
+ CASE WHEN poa.Country is null or LEN(poa.Country ) = 0 then '' '' else poa.Country end ''Owner Address'',
coll.Balance ''Balance'',
CASE WHEN coll.PropertyId is null then ''No'' else ''Yes'' END ''Collection Fee''
  FROM [cvs].[Properties] p
  inner join Accounts on Accounts.accountnumber = p.AccountNumber
  inner join cvs.PropertyOwners po on po.PropertyOwnerId = p.PropertyOwnerId
  inner join cvs.PropertyOwnerAddresses poa on poa.PropertyOwnerId = po.PropertyOwnerId and poa.AddressIndex = 0
  left outer join (
select pt.PropertyId, SUM(pt.Balance) ''Balance'' from cvs.PropertyTaxes pt
inner join cvs.TaxTypes tt on tt.TaxTypeId = pt.TaxTypeId
where tt.Category = 5 or pt.Collection > 0
group by pt.PropertyId ) coll on coll.PropertyId = p.Id

  order by p.AccountNumber', 'Account Number, Owner Name, Owner Address, Balance, Collection Fee', 26, 1, NULL, 0, NULL, 0, 0, '2016-04-27 18:36:49.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('f793cb7f-0a21-47b9-bfe2-4601864cbcd9', 'CNO Payment File Summary (with payment types)', '**Works only for CNO** Sums owner payments by month, year, and payment type (On time, late with interest, etc.)', 0, N'SELECT	DATEPART(m, appliedat) [Month], datepart(yy, appliedat) [Year], 
	SUM(CASE WHEN ppt.transactioncode = ''090'' THEN pp.Total ELSE 0 END) [090 Temporary credit],
	SUM(CASE WHEN ppt.transactioncode = ''100'' THEN pp.Total ELSE 0 END) [100 Timely payment],
	SUM(CASE WHEN ppt.transactioncode = ''110'' THEN pp.Total ELSE 0 END) [110 Late payment with interest],
	SUM(CASE WHEN ppt.transactioncode = ''160'' THEN pp.Total ELSE 0 END) [160 Tax sale],
	SUM(CASE WHEN ppt.transactioncode = ''170'' THEN pp.Total ELSE 0 END) [170 Redemption Payment],
	SUM(CASE WHEN ppt.transactioncode IS null THEN pp.Total ELSE 0 END) [NULL Unknown]
from  cvs.propertypayments pp
left OUTER JOIN cvs.propertypaymenttypes ppt ON ppt.propertypaymenttypeid = pp.propertypaymenttypeid
group by datepart(yy, appliedat), datepart(m, appliedat)
order by [Year], [Month]', 'Year,090 Temporary credit,100 Timely payment,110 Late payment with interest,160 Tax sale,170 Redemption Payment,NULL Unknown', 9, 1, NULL, 0, NULL, 0, 0, '2016-05-22 01:53:22.000', NULL, NULL)
EXEC(N'INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES (''a18ed863-b074-47ad-84d8-46351249aaf9'', ''Verify Encoded Fees and Cost'', ''Report showing encodings to date for a selected tax sale'', 0, N''Declare @ltFeesandCost Table
(
PropertyID UniqueIdentifier,
AccountNumber VarChar(500),
IsAdjudicated VarChar(3),
IsExcluded VarChar(3),
IsBankrupt VarChar(3),
IsMobileHome VarChar(3),
TaxSale VarChar(500),
TaxSaleState VarChar(25),
PropertyType VarChar(25),
ProType Int,
TaxYear Int,
TaxesDue Money,
Interest Money,
ArchonFee Money,
CurrentCost Money,
CurrentDate DateTime
)
 
Insert Into @ltFeesandCost 
 Select
    P.ID, 
    ''''"'''' + p.AccountNumber + ''''"'''', 
	Case
	   When p.IsAdjudicated = 1 Then ''''Yes''''
	   Else ''''No''''
	End,
	Null,
	Case
	   When p.IsBankrupt = 1 Then ''''Yes''''
	   Else ''''No''''
    End,
	Case
	   When p.IsMobileHome = 1 Then ''''Yes''''
	   Else ''''No ''''
	End,
	Null,
	Null,
	Case
      When P.PropertyType = 0 Then ''''Real Estate''''
      When P.PropertyType = 1 Then ''''Personal Property''''
    End,
	P.PropertyType,
	PT.Year,
	Null,
	Null,
	Null,
	Null,
	Null
From cvs.Properties P
Join cvs.PropertyTaxes PT On PT.PropertyId = P.Id
Where PT.Status != 0
Group by P.ID, P.AccountNumber,P.PropertyType,PT.Year, P.IsAdjudicated, P.IsBankrupt, P.IsMobileHome

Update @ltFeesAndCost
Set TaxesDue = 0,
    Interest = 0,
    ArchonFee = 0,
    CurrentCost = 0

Update FC
   Set TaxSale = IsNull((Select Top 1 Upper(Left(DateName(MM,TS.StartTime),3)) + '''' '''' + DateName(YYYY,TS.StartTime) + '''' '''' + Upper(TS.SaleType) + '''' SALE ('''' + TS.Code + '''')''''
                     From cvs.Sales As TS
                     Join cvs.Auctions As A On A.SaleID = TS.SaleId
                     Where GetDate() <= TS.EndTime and A.PropertyID = FC.PropertyID and
                     A.State In (10,20,30,40) and A.PropertyID = FC.PropertyID),''''No'''')
From @ltFeesAndCost as FC

Update FC
   Set TaxSaleState = IsNull((Select Top 1 
                     Case
					    When A.State = 10 Then ''''For Sale''''
						When A.State = 20 Then ''''Canceled''''
						When A.State = 40 Then ''''Not Sold''''
						When A.State = 20 Then ''''Sold''''
						Else ''''Unknown''''
					 End
                     From cvs.Sales As TS
                     Join cvs.Auctions As A On A.SaleID = TS.SaleId
                     Where GetDate() <= TS.EndTime and A.PropertyID = FC.PropertyID and
                     A.State In (10,20,30,40) and A.PropertyID = FC.PropertyID),'''''''')
From @ltFeesAndCost as FC

Update FC
   Set IsExcluded = IsNull((Select Top 1 ''''Yes''''
                       From cvs.PropertyExclusions as PE
                       Where PE.AccountNumber = FC.AccountNumber and 
                       PE.PropertyType = FC.ProType and 
                       PE.ExpiresOn >= GetDate()
                       Order By PE.ExpiresOn),''''No'''')
From @ltFeesAndCost as FC

Update FC
   Set TaxesDue = (Select IsNull(Sum(Balance), 0.00)
                   From cvs.PropertyTaxes PT
                   Join cvs.TaxTypes as TT On TT.TaxTypeID = PT.TaxTypeID
                   Where PT.PropertyID = FC.PropertyID and
                         PT.Year = FC.TaxYear and
                         TT.Category In (0,2,3))
From @ltFeesAndCost as FC

Update FC
   Set Interest = (Select IsNull(Sum(Interest), 0.00)
                   From cvs.PropertyTaxes PT
                   Join cvs.TaxTypes as TT On TT.TaxTypeID = PT.TaxTypeID
                   Where PT.PropertyID = FC.PropertyID and
                         PT.Year = FC.TaxYear) + FC.Interest
From @ltFeesAndCost as FC

Update FC
   Set Interest = (Select IsNull(Sum(Balance), 0.00)
                   From cvs.PropertyTaxes PT
                   Join cvs.TaxTypes as TT On TT.TaxTypeID = PT.TaxTypeID
                   Where PT.PropertyID = FC.PropertyID and
                         TT.Category = 7 and
                         PT.Year = FC.TaxYear) + FC.Interest
From @ltFeesAndCost as FC

Update FC
   Set ArchonFee = (Select IsNull(Sum(Collection),0.00)
                   From cvs.PropertyTaxes PT
                   Join cvs.TaxTypes as TT On TT.TaxTypeID = PT.TaxTypeID
                   Where PT.PropertyID = FC.PropertyID and
                '', ''Account Number,Is Adjudicated,Is Excluded,Is Bankrupt,Is MobileHome,Tax Sale,Tax Sale State,Property Type,Tax Year,Taxes Due,Interest,Archon 10% Fee,Encoding to date,Last Encoded'', 47, 1, NULL, 0, NULL, 0, 0, ''2016-08-30 19:04:27.000'', NULL, NULL)')
UPDATE [dbo].[DataExports] SET [Query].WRITE(N'         PT.Year = FC.TaxYear) + FC.ArchonFee
From @ltFeesAndCost as FC

Update FC
   Set ArchonFee = (Select IsNull(Sum(Balance),0.00)
                   From cvs.PropertyTaxes PT
                   Join cvs.TaxTypes as TT On TT.TaxTypeID = PT.TaxTypeID
                   Where PT.PropertyID = FC.PropertyID and
                         PT.Year = FC.TaxYear and
                         TT.Category = 6) + FC.ArchonFee
From @ltFeesAndCost as FC

Update FC
   Set CurrentCost = IsNull((Select Sum(PT.Balance)
                     From cvs.PropertyTaxes PT
                     Join cvs.TaxTypes as TT On TT.TaxTypeID = PT.TaxTypeID
                     Where PT.PropertyID = FC.PropertyID and
                     PT.Year = FC.TaxYear and TT.Category = 5),0.00)
From @ltFeesAndCost as FC

Update FC
   Set CurrentDate = (Select Top 1 PTV.ChangeDate
                     From cvs.PropertyTaxVersions PTV
                     Join cvs.PropertyTaxes as PT On PT.ID = PTV.TaxID
                     Join cvs.TaxTypes as TT On TT.TaxTypeID = PT.TaxTypeID
                     Where PT.PropertyID = FC.PropertyID and
                     PT.Year = FC.TaxYear and
                     TT.Category = 5
                     Order By PTV.ChangeDate Desc)
From @ltFeesAndCost as FC
	

Select
   AccountNumber,
   IsAdjudicated,
   IsExcluded,
   IsBankrupt,
   IsMobileHome,
   TaxSale,
   TaxSaleState,
   PropertyType,
   TaxYear,
   TaxesDue,
   Interest,
   ArchonFee,
   CurrentCost,
   CONVERT(VarChar(10),CurrentDate,101)
From @ltFeesandCost',NULL,NULL) WHERE [Id] = 'a18ed863-b074-47ad-84d8-46351249aaf9'
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('abec9002-b1c2-4d80-b270-4a6151229ac8', 'Tax Sale Count with total due', 'Multi-TA query of tax sale with property counts and total due', 0, N'SELECT 
			   LEFT(DATENAME( m, StartTime),3) +'' ''+ DATENAME(yyyy,StartTime) + '' Tax Sale'' AS Name,
			   Count(P.AccountNumber),
			   IsNull(Cast(Sum(A.Price) As Money),0.00) [Amount Due]
			FROM [cvs].[Properties] P
			Join cvs.Auctions A On A.PropertyID = P.ID
			Join cvs.sales TS On TS.SaleId = A.SaleId AND SaleType = ''Tax''
			Where A.State = 10 and A.AuctionType = ''TaxSale''  
			Group By LEFT(DATENAME( m, StartTime),3) +'' ''+ DATENAME(yyyy,StartTime) + '' Tax Sale'' ', 'Tax Sale,For Sale Count,Total Due', 11, 1, NULL, 0, NULL, 0, 1, '2016-06-29 14:21:55.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('06045590-90a0-4eb3-898d-5b03c56bbb48', 'Change Orders By Tax Sale', 'Change orders details filtered by tax sale', 0, N'select p.AccountNumber, 
 p.Address1 [Address], 
 case a.[State]
 when 0 then ''Not For Sale''
 when 10 then ''For Sale''
 when 20 then ''Canceled''
 when 30 then ''Sold''
 when 40 then ''Not Sold''
 end AuctionStatus,
 case pco.[Status]
 when 0 then ''Pending''
 when 1 then ''Approved''
 when 2 then ''Rejected''
 end [Status], 
 pco.SubmittedOn, 
 pco.TaxYear,
 Replace(Replace(pco.ChangeReason,Char(13),''''),Char(10),'''') ChangeReason
 from cvs.Auctions a 
 join cvs.Properties p 
 on a.PropertyId = p.Id 
 join cvs.PropertyChangeOrders pco 
 on pco.PropertyId = p.Id 
 where a.SaleId = ''<FILTER>''
 order by p.AccountNumber, pco.TaxYear', 'Account Number, Property Address, Auction Status, Status, Submitted On, Tax Year, Change Reason', 113, 1, N'SELECT  LEFT(DATENAME(m, StartTime), 3) + '' '' + DATENAME(yyyy, StartTime)
        + '' Tax Sale'' AS Name ,
        ts.SaleId
FROM    cvs.Sales ts
        INNER JOIN ( SELECT MAX(EndTime) ed ,
                            SaleId
                     FROM   cvs.Sales
                     WHERE  SaleType = ''Tax''
                     GROUP BY SaleId
                   ) x ON x.SaleId = ts.SaleId
WHERE   SaleType = ''Tax''
ORDER BY x.ed DESC', 0, 'Tax Sale', 0, 0, '2016-08-30 13:49:04.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('9bff5381-7479-491c-89f0-62df8d817a79', 'Scheduled Adjudication Sales', 'Multi-TA query of properties scheduled for adj sales', 0, N'      
SELECT ''"'' + p.AccountNumber + ''"'',
p.Address1 + CASE WHEN p.address2 IS NOT NULL AND LEN(p.Address2) > 0 THEN '' '' + p.Address2 ELSE '''' END ''Address'',
a.Price ''Current Price'',
CAST(sale.StartTime AS DATE) ''Sale Date'',
d.Name ''Depositor Name'',
d.NameOnDeed ''Depositor Name on Deed'',
d.phone ''Depositor Phone'',
d.DepositMadeOn ''Deposit Made On'',
CONVERT(VarChar(10),Sale.LockedOn,101),
Case
      When (SELECT Count(Da.AttributeValue) 
	           FROM [doc].[Documents] d
               Join doc.DocumentAttributes da On da.DocumentId = d.DocumentId and Da.AttributeName = ''Account Number''
               where d.DocumentTypeId = (Select DocumentTypeID 
			                                From doc.DocumentTypes DT 
											Where DT.Name = ''Occupancy Report'')  and Da.AttributeValue = P.AccountNumber) > 0 Then ''Yes''
	  Else ''No''
End,
Case
      When (SELECT Count(Da.AttributeValue) 
	           FROM [doc].[Documents] d
               Join doc.DocumentAttributes da On da.DocumentId = d.DocumentId and Da.AttributeName = ''Account Number''
               where d.DocumentTypeId = (Select DocumentTypeID 
			                                From doc.DocumentTypes DT 
											Where DT.Name = ''Constructive Notice Signs'')  and Da.AttributeValue = P.AccountNumber) > 0 Then ''Yes''
	  Else ''No''
End
FROM cvs.Properties p
INNER JOIN cvs.auctions a ON a.PropertyId = p.Id
INNER JOIN cvs.Sales sale ON sale.SaleId = a.SaleId AND SaleType = ''Adj''
left join (select d.auctionid, ap.FirstName + '' '' + ap.LastName as name, ap.NameOnDeed, ''(''+ ap.AreaCode+ '') '' + ap.Prefix + ''-'' + ap.Suffix as phone, d.DepositMadeOn
			from cvs.deposits d
			inner join cvs.Purchasers pu on d.PurchaserId = pu.PurchaserId
			inner join CivicSource.dbo.AuctioneerProfiles ap on ap.username = pu.username
			where d.status <> 2 ) d on d.auctionid = a.auctionid

WHERE a.State = 10
ORDER BY sale.StartTime, p.AccountNumber', 'Tax Bill Number,Address,Current Price,Sale Date,Depositor Name,Depositor Name On Deed,Depositor Phone,Deposit Made On,Lock Date,Occupancy Report,Constructive Notice Sign', 132, 1, NULL, 0, NULL, 0, 1, '2016-08-29 16:14:52.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('6bedcc1d-74da-4da2-a9ed-631210c5fca1', 'Combined skiptracing report', 'Research and forwarding skiptrace report', 0, N'declare @datestart as date
set @datestart = CAST(''<START>'' as DATE) 

select ForwardingAddressModifiedBy, 0, 0, count(*) fwdAddr, cast(@datestart as varchar(10))
from mail.Letters l
where ForwardingAddressModifiedBy is not null
and cast(ForwardingAddressModifiedOn as date) >= @datestart and cast(ForwardingAddressModifiedOn as date) < DATEADD(day,7,@datestart)
group by ForwardingAddressModifiedBy', 'AGENT,RESEARCH ACCOUNT #,RESEARCH ADDRESSES #,FORWARDING ADDRESSES #,WEEK STARTING', 4, 1, NULL, 0, NULL, 1, 1, '2016-06-15 16:47:09.000', '1,5', N'declare @datestart as date
set @datestart = CAST(''<START>'' as DATE) 

select addresses.createdby, 
properties.cntprop,
addresses.cntaddr,
0,
cast(@datestart as varchar(10))
from (select createdby, count(*) cntaddr
	from prodresearch.research.res.recipients
	where cast(createdon as date) >= @datestart and cast(createdon as date) < DATEADD(day,7,@datestart)
	group by createdby) addresses
inner join (select createdby, count(distinct(propertyid)) cntprop
	from prodresearch.research.res.recipients
	where cast(createdon as date) >= @datestart and cast(createdon as date) < DATEADD(day,7,@datestart)
	group by createdby) properties on properties.createdby = addresses.createdby')
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('7311418b-c70c-4ce9-8428-649620027aa7', 'Unsold Taxes', 'Unsold taxes at tax sale for each bill number', 0, N'SELECT p.AccountNumber, st.Year, typ.TaxCode,
''$'' + CONVERT(varchar(20), CONVERT(money,st.Balance),1),  ''$'' + CONVERT(varchar(20), CONVERT(money,st.Interest),1),  ''$'' + CONVERT(varchar(20), CONVERT(money,st.Penalty),1),  ''$'' + CONVERT(varchar(20), CONVERT(money,st.Collection),1)
FROM [cvs].[SellableTaxes] st
inner join cvs.Auctions a on a.AuctionId = st.TaxSalePropertyId
inner join cvs.Sales ts on ts.SaleId = a.SaleId AND SaleType = ''Tax''
inner join cvs.Properties p on p.Id = a.PropertyId
inner join cvs.TaxTypes typ on typ.TaxTypeId = st.TaxTypeId
where a.State = 40 and ts.SaleId = ''<FILTER>''
order by p.AccountNumber, st.Year, typ.TaxCode	', 'Acount Number, Year, Tax Code, Tax, Interest, Penalty, Collection', 26, 1, N'SELECT  LEFT(DATENAME(m, StartTime), 3) + '' '' + DATENAME(yyyy, StartTime)
        + '' Tax Sale'' AS Name ,
        ts.SaleId
FROM    cvs.Sales ts
        INNER JOIN ( SELECT MAX(EndTime) ed ,
                            SaleId
                     FROM   cvs.Sales
                     WHERE  SaleType = ''Tax''
                     GROUP BY SaleId
                   ) x ON x.SaleId = ts.SaleId
WHERE   SaleType = ''Tax''
AND GETDATE() > EndTime
ORDER BY x.ed DESC', 0, 'Tax Sale', 0, 0, '2016-08-30 19:03:48.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('a0e41f82-78a2-4194-a143-6da8c2c461f4', 'Adjudication Sale Properties Results', 'Results of past adjudication sales for Brian / Walter', 0, N'
SELECT p.AccountNumber,
p.Address1 + CASE WHEN p.Address2 IS NOT NULL THEN '' '' + p.Address2 ELSE '''' END,
a.startingprice,
a.Price,
pmp.NameOnDeed,
ap.FirstName + '' '' + ap.LastName,
 ap.Email,
''('' + ap.AreaCode + '') '' + ap.Prefix + ''-'' + ap.Suffix
FROM cvs.Properties p
INNER JOIN cvs.auctions a ON a.PropertyId = p.Id
INNER JOIN cvs.Sales sale ON sale.SaleId = a.SaleId AND SaleType = ''Adj''
INNER JOIN cvs.PrimaryMarketPurchases pmp ON pmp.AuctionId = a.AuctionId
INNER JOIN cvs.Purchases pur ON pur.PurchaseId = pmp.PurchaseId and pur.status = 0
INNER JOIN cvs.Purchasers puser ON puser .PurchaserId = pur.Purchaser
INNER JOIN civicsource.dbo.auctioneerprofiles ap ON ap.username = puser.username
WHERE a.state = 30 AND a.SaleId = ''<FILTER>''
  ', 'Tax Bill Number,Address,Starting Price,Price,Winner Name on Deed,Winner,Winner Email,Winner Telephone', 135, 1, N'SELECT
CONVERT(VARCHAR(100), StartTime, 106) + '' Sale'',
SaleId
FROM cvs.Sales
WHERE EndTime < GETDATE()
AND SaleType = ''Adj''
ORDER BY StartTime desc', 0, 'Adjudication Sale', 0, 0, '2016-08-09 16:27:02.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('a292fd6d-3e51-4a8c-850d-704316f33e42', 'Properties in Tax Sale', 'All uncanceled properties in a tax sale', 0, N'
SELECT distinct LEFT(DATENAME( m, StartTime),3) +'' ''+ DATENAME(yyyy,StartTime) + '' Tax Sale'' AS Name  , ''"'' + p.AccountNumber + ''"''   ,p.Address1 + CASE p.Address2 WHEN null then '' '' ELSE '' '' + p.Address2 END ''Address''  ,p.LegalDescription   ,dbo.GetPropertyOwnerName(o.PropertyOwnerId)  , CASE WHEN poa.Address1 is null or LEN(poa.Address1) = 0 then '''' else poa.Address1 + '', '' end   + CASE WHEN poa.Address2 is null or LEN(poa.Address2) = 0 then '''' else poa.Address2 + '', '' end   + CASE WHEN poa.City is null or LEN(poa.City) = 0  then '''' else poa.City + '', '' end   + CASE WHEN poa.State  is null or LEN(poa.State ) = 0  then '''' else poa.State + '' '' end   + CASE  WHEN poa.PostalCode is null or LEN(poa.PostalCode) = 0  then '''' else poa.PostalCode + '', '' end  + CASE WHEN poa.Country is null or LEN(poa.Country ) = 0  then '''' else poa.Country end  ''Owner Address''   , p.AmountDue         FROM cvs.Auctions a INNER JOIN cvs.Sales ts on a.SaleId = ts.SaleId AND SaleType = ''Tax'' INNER JOIN cvs.Properties p on a.PropertyId = p.Id  INNER JOIN cvs.PropertyOwners o on p.PropertyOwnerId = o.PropertyOwnerId  INNER JOIN cvs.PropertyOwnerAddresses poa on o.PropertyOwnerId = poa.PropertyOwnerId    WHERE ts.SaleId = ''<FILTER>''   AND a.State !=20  AND poa.Source = 2
', 'Tax Sale, AccountNumber, Address, Legal, Owner Name, Owner Address, Amount Due', 1094, 1, N'SELECT  LEFT(DATENAME(m, StartTime), 3) + '' '' + DATENAME(yyyy, StartTime)
        + '' Tax Sale'' AS Name ,
        ts.SaleId
FROM    cvs.Sales ts
        INNER JOIN ( SELECT MAX(EndTime) ed ,
                            SaleId
                     FROM   cvs.Sales
                     WHERE  SaleType = ''Tax''
                     GROUP BY SaleId
                   ) x ON x.SaleId = ts.SaleId
WHERE   SaleType = ''Tax''
ORDER BY x.ed DESC', 0, 'Tax Sale', 0, 0, '2016-08-23 22:05:57.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('2bb82391-6011-4bb8-bf24-7b2981dcadce', 'Auctions For Sale (All TAs)', 'TA Prefix and Account Number for all for sale auctions.', 0, N'SELECT ts.TaxAuthorityPrefix, p.AccountNumber, ts.*, a.* 
FROM cvs.properties p inner join cvs.auctions a on a.propertyid = p.id inner join cvs.sales ts on ts.saleid = a.saleid AND SaleType = ''Tax'' where a.state = 10 
AND a.AuctionType = ''TaxSale'' AND NOT( ts.StartTime < GETDATE())', 'TaxAuthorityPrefix,AccountNumber,TaxSaleId,Version,Name,TaxAuthorityPrefix,OrderPrefix,BiddingStrategyId,SelectionStrategyId,Status,Type,StartDate,EndDate,PaymentWindowEnd,IsPublic,NtsSentOn,AutoUpdate,SalePaymentDate,IsRefreshing,IsOffline,Location,ResearchQueueId,DiscountedResearchQueueId,CertificateSettingsId,DiscountedResearchQueueCutoffDate,AuctionId,AuctionType,Version,PropertyId,Price,State,LegalDescription,PreserveLegalDescription,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn,PrimaryOwnerId,TaxSaleId,TotalDelinquency,NoticeOfTaxSaleId,CertificateId,ResearchStatus,LinkToAccountNumber,LinkToPropertyType,LinkToTaxAuthorityPrefix,LinkToTaxSaleCode,LinkToTaxSaleName,IsRedeemed,PolicyId,AdjudicationDate,IsClosed,ClosingDate,HudDocumentId,AdjudicationSaleId,IsHeld,IsConfirmed,ConfirmedBy,ConfirmedOn,IsBiddingDone,StartingBidOverride,BidMessageSeqNum,DepositAmount,ClosingStatus,ClosingMessageSeqNum,IsPriceOverridden,StartingPrice,InvoicedOn,InvoicedAs,LotNumberIncrement,LotNumber', 34, 1, NULL, 0, NULL, 0, 1, '2016-08-09 18:56:46.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('c5bc99eb-7697-46fc-8f38-881705c548e4', 'Press Release Tax Sale Summary', 'Press Release Tax Sale Summary', 0, N'SELECT distinct ts.TaxAuthorityPrefix + '' '' + CAST(YEAR(GETDATE()) AS varchar(4)) + '' Tax Sale'', cnt.cnt as ''# Properties'', CAST(lowest.Price AS MONEY) as ''Lowest Delinquent Balance'', CAST(highest.Price AS MONEY) as ''Highest Delinquent Balance''
  from 
  [cvs].[Sales] ts
  inner join 
			(select count(*) cnt, TaxAuthorityPrefix
				from cvs.auctions a 
				inner join cvs.sales ts on ts.saleid = a.SaleId AND SaleType = ''Tax''
				where a.State in (10,30,40) and DATENAME(yyyy,StartTime) = CAST(YEAR(GETDATE()) AS varchar(4))	
					group by ts.TaxAuthorityPrefix) cnt on cnt.TaxAuthorityPrefix = ts.TaxAuthorityPrefix
  inner join (select top 1 a2.price, ts2.TaxAuthorityPrefix
				from cvs.Auctions a2
				inner join cvs.Sales ts2 on ts2.SaleId = a2.SaleId AND SaleType = ''Tax''
				where a2.State in (10,30,40) and DATENAME(yyyy,StartTime) = CAST(YEAR(GETDATE()) AS varchar(4))	
				order by a2.price) lowest on lowest.TaxAuthorityPrefix = ts.TaxAuthorityPrefix  
  inner join (select top 1 a2.Price, ts2.TaxAuthorityPrefix
				from cvs.Auctions a2
				inner join cvs.Sales ts2 on ts2.SaleId = a2.SaleId AND SaleType = ''Tax''
				where a2.State in (10,30,40) and DATENAME(yyyy,StartTime) = CAST(YEAR(GETDATE()) AS varchar(4))	
				order by a2.price desc) highest on highest.TaxAuthorityPrefix = ts.TaxAuthorityPrefix  
  where DATENAME(yyyy,StartTime) = CAST(YEAR(GETDATE()) AS varchar(4))', 'Sale,Properties in Current Tax Sale,Lowest Total Delinquent Balance,Highest Total Delinquent Balance', 26, 1, NULL, 0, NULL, 0, 1, '2016-06-28 20:32:58.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('7ede6a1e-3ec5-40a6-9a6c-9bd07edc69b4', 'Costs for current tax sale accounts', 'Account number and cost balance for properties that are in a current tax sale', 0, N'
  select ''"'' + x.AccountNumber + ''"'', y.Year, ISNULL(''$'' + CONVERT(varchar(20), CONVERT(money,Sum(y.Total)),1), ''FEE MISSING'')
  from 
	  (select p.AccountNumber, p.Id, a.State, a.SaleId, p.PropertyType
	  from [cvs].Properties p
		inner join cvs.Auctions a
			on a.PropertyId = p.Id where a.State = 10 and a.SaleId = ''<FILTER>''
	  )x
	 left outer join (select pt.PropertyId, pt.Status, tt.Category, pt.Total, pt.Year 
					from cvs.PropertyTaxes pt
						inner join cvs.TaxTypes tt
					on pt.TaxTypeId = tt.TaxTypeId where pt.Status = 2 and tt.Category = 5)y
	on y.PropertyId = x.Id
	Group by AccountNumber,Year
	Order by AccountNumber,Year
  ', 'Account Number, Tax Year, Cost Total', 771, 1, N'SELECT TOP 1
        LEFT(DATENAME(m, ts.StartTime), 3) + '' '' + DATENAME(yyyy, StartTime)
        + '' Tax Sale'' AS Name ,
        ts.SaleId
FROM    cvs.Sales ts
WHERE   SaleType = ''tax''
ORDER BY EndTime DESC', 0, 'Tax Sale', 0, 0, '2016-08-23 21:55:31.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('705c4cd4-8887-416f-8127-9d298e3c0e16', 'Revenue & Expense for Terminal State Auctions', 'Revenue and expense by cost code for each auction in a terminal state, i.e., sold, not sold or canceled', 0, N'
select	p.accountnumber, convert(varchar(10), s.StartTime, 20) [Date], case when a.state = 30 then ''Sold'' when a.state = 40 then ''Not Sold'' when a.state = 20 then ''Canceled'' end State ,/*a.invoicedon, a.invoicedas,*/ r.Code, r.Name, r.Cost, r.Expense		
from	cvs.properties p		
		inner join cvs.auctions a	
			on a.propertyid = p.id
		inner join cvs.sales s
			on a.saleid = s.saleid AND SaleType = ''Adj''
		inner join (select	auction, code, name, sum(revenue) Cost, sum(actualexpense) Expense from acc.Receivable group by auction, code, name) r
			on r.auction = a.auctionid	
where	a.state > 10		
order by p.accountnumber, r.code', 'AccountNumber,Date,State,Code,Name,Cost,Expense', 15, 1, NULL, 0, NULL, 0, 1, '2016-04-27 19:05:22.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('e0f72d79-3df9-4a82-b781-a88df0ca66db', 'Bankruptcy (Business) List', 'List of Business owners of properties (with active auctions) to send for bankruptcy check', 0, N'select ts.TaxAuthorityPrefix + p.accountnumber, 
	'''', --CASE WHEN LEN(po.NameFirst) > 0 THEN po.namefirst ELSE '''' END,
	'''', --CASE WHEN LEN(po.namelast) > 0 THEN po.namelast ELSE '''' END, 
	CASE WHEN LEN(po.NameBusiness) > 0 THEN po.NameBusiness ELSE '''' END, 
	CASE WHEN LEN(poa.Address1) > 0 THEN poa.Address1 ELSE '''' END, 
	CASE WHEN LEN(poa.Address2) > 0 THEN poa.Address2 ELSE '''' END, 
	CASE WHEN LEN(poa.City) > 0 THEN poa.City ELSE '''' END, 
	poa.State,
	poa.PostalCode,
	poa.Country,
	CASE WHEN LEN(p.Address1) > 0 THEN p.Address1 ELSE '''' END,
	CASE WHEN LEN(p.Address2) > 0 THEN p.Address2 ELSE '''' END,
	CASE WHEN LEN(p.City) > 0 THEN p.City ELSE '''' END,
	p.State,
	p.PostalCode,
	p.Country
	FROM [cvs].[Auctions] a
  inner join cvs.Sales ts on ts.saleid = a.saleid AND SaleType = ''Tax''
  inner join cvs.Properties p on p.id = a.propertyid
  inner join cvs.propertyowners po on po.propertyownerid = a.PrimaryOwnerId
  LEFT OUTER JOIN
	(SELECT propertyownerid, Address1, Address2, City, State, PostalCode, Country,
			ROW_NUMBER() OVER (PARTITION BY PropertyOwnerId ORDER BY Status ASC, AddressIndex DESC) rownum
	 FROM cvs.PropertyOwnerAddresses) poa ON poa.propertyownerid = po.PropertyOwnerId AND poa.rownum = 1
  where NameBusiness IS NOT NULL AND LEN(NameBusiness) > 0
  and a.State in (10)', 'Tax Bill Number,Owner First,Owner Last,Owner Business,Owner Address 1,Owner Address 2,Owner City,Owner State,Owner Postal Code,Owner Country,Parcel Address 1,Parcel Address 2,Parcel City,Parcel State,Parcel Postal Code,Parcel Country', 67, 1, NULL, 0, NULL, 0, 0, '2016-08-10 15:40:32.000', NULL, NULL)
EXEC(N'INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES (''3e5c434c-f131-47bd-bd4e-aa687ae4bfb8'', ''Press release numbers'', ''Monthly press release numbers for Danos'', 0, N''DECLARE @results TABLE
(
	Label varchar(200),
	Info varchar(500),
	OrderIndex int
)

DECLARE @saleDate DATETIME
SET @saleDate = (SELECT StartTime FROM cvs.Sales WHERE saleid = ''''<FILTER>'''' AND SaleType = ''''Adj'''')

DECLARE @prevSaleDate DATETIME
SET @prevSaleDate = (SELECT TOP 1 StartTime FROM cvs.Sales WHERE StartTime < @saleDate AND SaleType = ''''Adj'''' ORDER BY EndTime DESC)

DECLARE @totalCanceled int
SET @totalCanceled = (SELECT COUNT(*)
	FROM cvs.auctions a
	WHERE a.AuctionType = ''''Adjudication'''' AND a.State IN (20)
	AND a.AuctionId IN (SELECT taxsalepropertyid 
						FROM cvs.AuctionStateHistory ash 
						WHERE ash.ToState = 1 AND ash.TaxSalePropertyId = a.AuctionId)
	AND a.AuctionId IN (SELECT taxsalepropertyid
						FROM cvs.AuctionStateHistory ash
						where ash.tostate = 20 AND ash.taxsalepropertyid = a.AuctionId AND ash.CreatedOn > @prevSaleDate))

DECLARE @redemptions TABLE
(
	total int,
	value_del decimal(19,5)
)

insert into @redemptions
SELECT COUNT(DISTINCT(p.id)), SUM(pp.tot)
FROM cvs.auctions a
INNER JOIN cvs.Properties p ON p.Id = a.PropertyId
INNER JOIN (SELECT pt.propertyid, SUM(pt.total) AmountDue
                   FROM cvs.PropertyTaxes pt
				   WHERE pt.Year <> 2015
				   GROUP BY pt.PropertyId) pt_2 ON pt_2.PropertyId = p.id
inner JOIN (SELECT pp.AccountNumber, pp.PropertyType, SUM(pp.Total) tot
			FROM cvs.PropertyPayments pp
			WHERE source <> ''''TEMP''''
			GROUP BY pp.AccountNumber, pp.PropertyType) pp ON pp.AccountNumber = p.AccountNumber AND pp.PropertyType = p.PropertyType
WHERE a.AuctionType = ''''Adjudication'''' AND a.State IN (20) AND pt_2.amountdue = 0
AND EXISTS (SELECT taxsalepropertyid 
					FROM cvs.AuctionStateHistory ash 
					WHERE ash.ToState = 1 AND ash.TaxSalePropertyId = a.AuctionId)
AND EXISTS (SELECT taxsalepropertyid
					FROM cvs.AuctionStateHistory ash
					where ash.tostate = 20 AND ash.taxsalepropertyid = a.AuctionId AND ash.CreatedOn > @prevSaleDate)						
										

DECLARE @topAuctions TABLE
(
	label VARCHAR(500),
	amount nvarchar(12)
)
INSERT INTO @topAuctions
        ( label, amount )
SELECT * FROM (SELECT TOP 1 p.Address1 + '''' ('''' + p.AccountNumber + '''')'''' hp, CAST(b.amount AS NVARCHAR(12)) hs
FROM cvs.Auctions a 
INNER JOIN cvs.Properties p ON p.Id = a.PropertyId
INNER JOIN cvs.Sales sale ON sale.SaleId = a.SaleId AND SaleType = ''''Adj''''
INNER JOIN PRODAUCTION.auction.dbo.auction a2 ON a2.id = a.AuctionId
INNER JOIN PRODAUCTION.auction.dbo.bid b ON b.id = a2.winningbidid
WHERE a.state = 30 AND sale.SaleId = ''''<FILTER>''''
ORDER BY b.amount DESC) m

insert into @results
-- Label
SELECT ''''Selected Sale: '''', CAST(@saleDate AS nvarchar(30)), 1 
insert into @results
-- Previous Sale
SELECT ''''Previous Sale: '''', CAST(@prevSaleDate AS nvarchar(30)), 2
insert into @results
-- Sale count
SELECT ''''#Properties in Sale: '''', CAST(COUNT(*) as nvarchar(12)) AS saleCount, 3
FROM cvs.auctions a
INNER JOIN cvs.Sales sale ON sale.SaleId = a.SaleId AND SaleType = ''''Adj''''
WHERE a.State in (10,30,40) AND sale.saleid = ''''<FILTER>''''
insert into @results
-- Vacant Count
SELECT ''''#Possible vacant lots in Sale: '''', CAST(COUNT(DISTINCT a.AuctionId) as nvarchar(12)) AS ''''Vacant'''', 4
FROM cvs.auctions a 
INNER JOIN cvs.Sales sale ON sale.SaleId = a.SaleId AND SaleType = ''''Adj''''
WHERE  a.AuctionType = ''''Adjudication''''
AND a.State in (10,30,40) AND sale.saleid = ''''<FILTER>''''
AND a.PropertyId IN (SELECT ass.PropertyId FROM 
						cvs.Assessments ass
						INNER JOIN cvs.AssessmentTypes asst ON asst.AssessmentTypeId = ass.AssessmentTypeId
						WHERE ass.PropertyId = a.PropertyId AND ass.IsDeleted = 0 AND asst.Name = ''''Improvement'''' AND ass.Amount = 0)
AND a.PropertyId IN (SELECT ass.PropertyId FROM 
						cvs.Assessments ass
						INNER JOIN cvs.AssessmentTypes asst ON asst.AssessmentTypeId = ass.AssessmentTypeId
						WHERE ass.PropertyId = a.PropertyId AND ass.IsDeleted = 0 AND asst.Name = ''''Land'''' AND ass.Amount > 0)
insert into @results
-- Letters COUNT
SELECT ''''Mail notifications sent: '''', cast(COUNT(*) as nvarchar(12)) as ''''Mail Sent'''', 5
FROM ma'', ''Press Release Numbers'', 101, 1, N''SELECT
CONVERT(VARCHAR(100), StartTime, 106) + '''' Sale'''',
SaleId
FROM cvs.Sales
WHERE EndTime < GETDATE()
AND SaleType = ''''Adj''''
ORDER BY StartTime desc'', 0, ''Adjudication Sale'', 0, 0, ''2016-05-04 13:27:58.000'', NULL, NULL)')
EXEC(N'UPDATE [dbo].[DataExports] SET [Query].WRITE(N''il.Campaigns c
INNER JOIN mail.letters l  on l.campaignid = c.CampaignId
INNER JOIN cvs.Auctions a ON a.AuctionId = l.PrimaryDataId
INNER JOIN cvs.Sales sale ON sale.SaleId = a.SaleId AND SaleType = ''''Adj''''
WHERE CampaignType = ''''EditableAuctionBasedNas'''' AND sale.saleid = ''''<FILTER>''''						
insert into @results
-- Average delinquency
SELECT ''''Average tax delinquency: '''', cast(AVG(del.tot) as nvarchar(12)) as ''''Avg tax'''', 6
FROM cvs.auctions a 
INNER JOIN cvs.Sales sale ON sale.SaleId = a.SaleId AND SaleType = ''''Adj''''
INNER JOIN cvs.Properties p ON p.Id = a.PropertyId
LEFT OUTER JOIN (SELECT pt.PropertyId, SUM(pt.Total) tot
				FROM cvs.PropertyTaxes pt
				INNER JOIN cvs.TaxTypes tt ON tt.TaxTypeId = pt.TaxTypeId
				WHERE pt.Status = 2 AND tt.TaxCode <> ''''67''''
				GROUP BY pt.PropertyId) del ON del.PropertyId = p.Id
WHERE sale.saleid = ''''<FILTER>''''
insert into @results
-- Average years delinquent
SELECT ''''Average years delinquent'''', CAST(AVG(main.years_delinquent) AS NVARCHAR(12)) AS ''''Avg years'''', 7
FROM(
	SELECT p.AccountNumber, YEAR(GETDATE()) - MIN(pt.Year) years_delinquent
	FROM cvs.auctions a 
	INNER JOIN cvs.Properties p ON p.Id = a.PropertyId
	INNER JOIN cvs.PropertyTaxes pt ON pt.PropertyId = p.Id
	INNER JOIN cvs.Sales sale ON sale.SaleId = a.SaleId AND SaleType = ''''Adj''''
	WHERE a.AuctionType = ''''Adjudication'''' AND pt.Status = 2 AND sale.saleid = ''''<FILTER>''''
	AND a.AuctionId IN (SELECT taxsalepropertyid 
					FROM cvs.AuctionStateHistory ash 
					WHERE ash.ToState = 1 AND ash.TaxSalePropertyId = a.AuctionId)
	GROUP BY p.AccountNumber
) main
insert into @results
-- Average assessement
SELECT ''''Average assessment: ''''	, cast(AVG(main.amt) as nvarchar(12)) as ''''Avg assessment'''', 8
 FROM
(
	SELECT SUM(ass.Amount) amt
	FROM cvs.auctions a 
	INNER JOIN cvs.Properties p ON p.Id = a.PropertyId
	INNER JOIN cvs.Assessments ass ON ass.PropertyId = p.Id
	INNER JOIN cvs.Sales sale ON sale.SaleId = a.SaleId AND SaleType = ''''Adj''''
	WHERE a.AuctionType = ''''Adjudication''''  AND ass.IsDeleted = 0
	AND a.State in (10,30,40) AND sale.saleid = ''''<FILTER>''''
	GROUP BY p.Id
) main
insert into @results
-- Number sold
SELECT ''''Number sold'''', CAST(COUNT(*) AS NVARCHAR(12)) AS ''''# Sold'''', 9
FROM cvs.Auctions a 
INNER JOIN cvs.Sales sale ON sale.SaleId = a.SaleId AND SaleType = ''''Adj''''
WHERE a.state = 30 AND sale.SaleId = ''''<FILTER>''''
insert into @results
-- Value of winning bids
SELECT ''''Winning bids total'''', CAST(SUM(b.amount) AS nvarchar(12)) AS ''''Total bids'''', 10
FROM cvs.Auctions a 
INNER JOIN cvs.Sales sale ON sale.SaleId = a.SaleId AND SaleType = ''''Adj''''
INNER JOIN PRODAUCTION.auction.dbo.auction a2 ON a2.id = a.AuctionId
INNER JOIN PRODAUCTION.auction.dbo.bid b ON b.id = a2.winningbidid
WHERE a.state = 30 AND sale.SaleId = ''''<FILTER>''''
insert into @results
-- Number not sold
SELECT ''''Number not sold'''', CAST(COUNT(*) AS NVARCHAR(12)) AS ''''# Not Sold'''', 11
FROM cvs.Auctions a 
INNER JOIN cvs.Sales sale ON sale.SaleId = a.SaleId AND SaleType = ''''Adj''''
WHERE a.state = 40 AND sale.SaleId = ''''<FILTER>''''
insert into @results
-- Highest seller
SELECT TOP 1 ''''Highest selling property address'''' , label, 12 FROM @topAuctions
insert into @results
SELECT TOP 1 ''''Highest selling property amount'''', amount, 13 FROM @topAuctions
insert into @results
-- Cancelled since prior sale
SELECT ''''Canceled (non-redemption) since '''' +  CAST(@prevSaleDate AS nvarchar(30)), CAST((select @totalCanceled - (select top 1 total from @redemptions)) AS NVARCHAR(15)), 14
insert into @results
-- Redeemed since prior sale
SELECT ''''#Redeemed since '''' +  CAST(@prevSaleDate AS nvarchar(30)), CAST((select top 1 total from @redemptions) AS NVARCHAR(15)), 15
insert into @results
-- $Value to City of redemptions since prior sale
SELECT ''''$Redeemed since '''' +  CAST(@prevSaleDate AS nvarchar(30)), CAST((select top 1 value_del from @redemptions) AS NVARCHAR(15)), 16
insert into @results
-- Deposits since prior sale
SELECT ''''#Deposits since '''' +  CAST(@prevSaleDate AS nvarchar(30)), CAST(COUNT(DISTINCT a.AuctionId) as nvarchar(15)),16
FROM cvs.auctions a 
I'',NULL,NULL) WHERE [Id] = ''3e5c434c-f131-47bd-bd4e-aa687ae4bfb8''
UPDATE [dbo].[DataExports] SET [Query].WRITE(N''NNER JOIN cvs.AuctionStateHistory ash ON ash.TaxSalePropertyId = a.AuctionId
WHERE a.AuctionType = ''''Adjudication'''' AND ash.ToState = 2 AND CAST(ash.CreatedOn AS DATE) > @prevSaleDate
insert into @results
-- LA deposits sinct prior sale
SELECT ''''#LA Deposits since '''' +  CAST(@prevSaleDate AS nvarchar(30)), CAST(COUNT(DISTINCT a.AuctionId) as nvarchar(15)),17
FROM cvs.auctions a 
INNER JOIN cvs.AuctionStateHistory ash ON ash.TaxSalePropertyId = a.AuctionId
WHERE a.AuctionType = ''''Adjudication'''' AND ash.ToState = 2 AND CAST(ash.CreatedOn AS DATE) > @prevSaleDate
AND a.AuctionId IN (SELECT ar.AuctionId
					FROM cvs.Deposits ar
					INNER JOIN cvs.Purchasers pu ON pu.PurchaserId = ar.PurchaserId
					INNER JOIN CivicSource.dbo.AuctioneerProfiles ap ON ap.Username = pu.Username
					WHERE ar.AuctionId = a.AuctionId AND ar.Status <> 3 AND ap.State = ''''LA'''')

SELECT Label,Info from @results order by OrderIndex'',NULL,NULL) WHERE [Id] = ''3e5c434c-f131-47bd-bd4e-aa687ae4bfb8''
')
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('af2c4bb5-a2e6-47c5-8e05-bfa3c37a5860', 'Bankruptcy (Person) List', 'List of person owners of properties (with active auctions) to send for bankruptcy check', 0, N'select ts.TaxAuthorityPrefix + p.accountnumber, 
	CASE WHEN LEN(po.NameFirst) > 0 THEN po.namefirst ELSE '''' END,
	CASE WHEN LEN(po.namelast) > 0 THEN po.namelast ELSE '''' END, 
	'''', --CASE WHEN LEN(po.NameBusiness) > 0 THEN po.NameBusiness ELSE '''' END, 
	CASE WHEN LEN(poa.Address1) > 0 THEN poa.Address1 ELSE '''' END, 
	CASE WHEN LEN(poa.Address2) > 0 THEN poa.Address2 ELSE '''' END, 
	CASE WHEN LEN(poa.City) > 0 THEN poa.City ELSE '''' END, 
	poa.State,
	poa.PostalCode,
	poa.Country,
	CASE WHEN LEN(p.Address1) > 0 THEN p.Address1 ELSE '''' END,
	CASE WHEN LEN(p.Address2) > 0 THEN p.Address2 ELSE '''' END,
	CASE WHEN LEN(p.City) > 0 THEN p.City ELSE '''' END,
	p.State,
	p.PostalCode,
	p.Country
	FROM [cvs].[Auctions] a
  inner join cvs.Sales ts on ts.saleid = a.saleid AND SaleType = ''Tax''
  inner join cvs.Properties p on p.id = a.propertyid
  inner join cvs.propertyowners po on po.propertyownerid = a.PrimaryOwnerId
  LEFT OUTER JOIN
	(SELECT propertyownerid, Address1, Address2, City, State, PostalCode, Country,
			ROW_NUMBER() OVER (PARTITION BY PropertyOwnerId ORDER BY Status ASC, AddressIndex DESC) rownum
	 FROM cvs.PropertyOwnerAddresses) poa ON poa.propertyownerid = po.PropertyOwnerId AND poa.rownum = 1
  where NameLast IS NOT NULL AND LEN(NameLast) > 0
  and a.State in (10)', 'Tax Bill Number,Owner First,Owner Last,Owner Business,Owner Address 1,Owner Address 2,Owner City,Owner State,Owner Postal Code,Owner Country,Parcel Address 1,Parcel Address 2,Parcel City,Parcel State,Parcel Postal Code,Parcel Country', 68, 1, NULL, 0, NULL, 0, 0, '2016-06-21 18:19:57.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('7a260099-833c-4521-a317-c2a514ad2a2e', 'Mobile Home Report', 'Properties that contain an improvement without land', 0, N'Select 
   ''"'' + accountnumber + ''"'', 
   REPLACE(REPLACE(REPLACE(P.legaldescription,char(10),'' ''),char(13),'' ''),''  '','' ''),
   Case
      When IsMobileHome = 1 Then ''Yes''
	  When IsMobileHome = 0 Then ''No''
   End,
   LEFT(DATENAME( m, StartTime),3) +'' ''+ DATENAME(yyyy,StartTime) + '' Tax Sale'' AS Name
From cvs.Properties P
Left Join cvs.Auctions A on A.PropertyID = P.ID and A.State = 10
Left Join cvs.Sales TS on TS.SaleID = A.SaleID AND SaleType = ''Tax''
Where IsMobileHome = 1 or (P.Status = 2 and 
(P.legaldescription like ''%IMP ON%'') or
(P.legaldescription like ''%IMPROVEMENT ON%'') or
(P.legaldescription like ''%MOBILE HOME ON%'') or
(P.legaldescription like ''%TRAILER ON%'') or
(P.legaldescription like ''%LOCATED ON LAND%'') or 
(P.legaldescription like ''%ON LAND OF%'') or
(P.legaldescription like ''%ON LAND ASSESSED TO%'') or
(P.legaldescription like ''%ON THE PROPERTY OF%'') or
(P.legaldescription like ''%MOBILE @%'')
)', 'Account Number,Legal Description,Mobile Home Flag,Tax Sale', 95, 1, NULL, 0, NULL, 0, 0, '2016-08-17 14:24:34.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('6e1a8233-c2f8-45dc-aba6-c4fc84ea6098', 'Properties Excluded From Tax Sale', 'List of all properties canceled from the current tax sale due to an exclusion', 0, N'
/* Auction States */
Declare @Auction_Candidate         Int = 0
Declare @Auction_Public            Int = 1
Declare @Auction_Researching       Int = 2
Declare @Auction_Research_Complete Int = 3
Declare @Auction_For_Sale          Int = 10
Declare @Auction_Requires_Review   Int = 15
Declare @Auction_Canceled          Int = 20
Declare @Auction_Sold              Int = 30
Declare @Auction_Not_Sold          Int = 40

SELECT 
   ''"'' + PE.AccountNumber + ''"'',
   PE.Type,
   PE.Source, 
   PE.CreatedBy,
   Convert(VarChar(10),PE.ExpiresOn,101),
   LEFT(DATENAME( m, StartTime),3) +'' ''+ DATENAME(yyyy,StartTime) + '' Tax Sale'' AS Name
  FROM [cvs].[Auctions] A
  Join cvs.Sales TS on TS.SaleId = A.SaleID AND SaleType = ''Tax''
  Join cvs.Properties P on P.Id = A.PropertyID
  Join cvs.PropertyExclusions PE on PE.PropertyType = P.PropertyType and PE.AccountNumber = P.AccountNumber
  Where (TS.IsRefreshing = 1 OR GETDATE() < TS.EndTime) and
        A.State = @Auction_Canceled and
		PE.ExpiresOn >= A.CreatedOn  
  ', 'Account Number,Exclusion Type,Exclusion Source,Created By,Expires On,Tax Sale', 33, 1, NULL, 0, NULL, 0, 0, '2016-08-22 18:39:02.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('ad714e70-b5e9-4de0-bb9b-c652b0b787b2', 'Auctions without calls', 'Current auctions where no calls have been made', 0, N'DECLARE @currentTaxSaleID AS uniqueidentifier    select TOP 1 @currentTaxSaleID = ts.SaleId from cvs.Sales ts where SaleType = ''tax'' ORDER BY EndTime desc      
IF (@currentTaxSaleID is not null)    BEGIN     
DECLARE @db VARCHAR(50)
SELECT  @db = CASE WHEN SUBSTRING(DB_NAME(), 0,
                                  CHARINDEX(''_'', DB_NAME(),
                                            CHARINDEX(''_'', DB_NAME(), 0) + 1)) = ''''
                   THEN ''CivicSource''
                   ELSE SUBSTRING(DB_NAME(), 0,
                                  CHARINDEX(''_'', DB_NAME(),
                                            CHARINDEX(''_'', DB_NAME(), 0) + 1))
              END
DECLARE @sql NVARCHAR(500)
SET @sql = ''SELECT @TAPrefix = ta.Prefix FROM '' + @db + ''.dbo.TaxAuthorities ta WHERE ''''''
    + @db + ''_'''' + ta.SafeName = DB_NAME()''
DECLARE @TaxAuthorityPrefix VARCHAR(3)
EXEC sp_executesql @sql, N''@TAPrefix VARCHAR(3) OUTPUT'', @TAPrefix = @TaxAuthorityPrefix OUTPUT
SELECT    @TaxAuthorityPrefix AS TaxAuthorityPrefix,    p.AccountNumber,  
--CASE po.NamePrefix when null then '''' ELSE po.NamePrefix END + CASE po.NameFirst when null then '''' ELSE '' '' + po.NameFirst END + CASE po.NameMiddle when null then '''' ELSE '' '' + po.NameMiddle END + CASE po.NameLast when null then '''' ELSE '' '' + po.NameLast END + CASE po.NameSuffix when null then '''' ELSE '' '' + po.NameSuffix END,
--CASE po.SpousePrefix when null then '''' ELSE po.SpousePrefix END + CASE po.SpouseFirst when null then '''' ELSE '' '' + po.SpouseFirst END + CASE po.SpouseMiddle when null then '''' ELSE '' '' + po.SpouseMiddle END + CASE po.SpouseLast when null then '''' ELSE '' '' + po.SpouseLast END + CASE po.SpouseSuffix when null then '''' ELSE '' '' + po.SpouseSuffix END,
--CASE po.CareOfPrefix when null then '''' ELSE po.CareOfPrefix END + CASE po.CareOfFirst when null then '''' ELSE '' '' + po.CareOfFirst END + CASE po.CareOfMiddle when null then '''' ELSE '' '' + po.CareOfMiddle END + CASE po.CareOfLast when null then '''' ELSE '' '' + po.CareOfLast END + CASE po.CareOfSuffix when null then '''' ELSE '' '' + po.CareOfSuffix END,
--po.Business,REPLACE(po.UnparsedNameAndAddress, char(13) + char(10),'' ''),
dbo.GetPropertyOwnerName(po.PropertyOwnerId),
poa.City,    poa.[State],    poa.PostalCode,    poa.Country     from    cvs.Auctions a     left join cvs.Properties p on a.PropertyId = p.Id     
 left join cvs.PropertyOwners po on po.PropertyId = p.Id     left join cvs.Sales ts on ts.SaleId = a.SaleId AND SaleType = ''Tax''
 left join cvs.PropertyOwnerAddresses poa on poa.PropertyOwnerId = po.PropertyOwnerId and poa.Source = 2  where    a.[State] = 0    
 and    (select COUNT(*) from tel.Calls c where c.AccountNumber = p.AccountNumber) = 0    END    ELSE      select ''No Results'' as [Return]', 'Tax Authority,Account Number,Owner Names,City, State, Postal Code, Country', 152, 1, NULL, 0, NULL, 0, 0, '2016-04-27 18:33:13.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('ae9cbbef-0bc2-4b73-8491-d6a187e4c1f2', 'Adjudication Sale Results', 'Results of past adjudication sales', 0, N'
SELECT ''"'' + p.AccountNumber + ''"'',
a.LotNumber,
CONVERT(VARCHAR(100), StartTime, 106) + '' Sale'',
CONVERT(VarChar(10),StartTime,101),
p.Address1 + CASE WHEN p.Address2 IS NOT NULL THEN '' '' + p.Address2 ELSE '''' END,
a.startingprice,
a.Price,
pmp.NameOnDeed,
ap.FirstName + '' '' + ap.LastName,
 ap.Email,
''('' + ap.AreaCode + '') '' + ap.Prefix + ''-'' + ap.Suffix
FROM cvs.Properties p
INNER JOIN cvs.auctions a ON a.PropertyId = p.Id
INNER JOIN cvs.Sales sale ON sale.SaleId = a.SaleId AND SaleType = ''Adj''
INNER JOIN cvs.PrimaryMarketPurchases pmp ON pmp.AuctionId = a.AuctionId
INNER JOIN cvs.Purchases pur ON pur.PurchaseId = pmp.PurchaseId and pur.status = 0
INNER JOIN cvs.Purchasers puser ON puser .PurchaserId = pur.Purchaser
INNER JOIN civicsource.dbo.auctioneerprofiles ap ON ap.username = puser.username
WHERE a.state = 30 AND Sale.EndTime < GETDATE()
', 'Tax Bill Number,Auction ID,Adjudication Sale,Sale Date,Address,Starting Price,Price,Winner Name on Deed,Winner,Winner Email,Winner Telephone', 24, 1, NULL, 0, NULL, 0, 1, '2016-08-22 21:03:35.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('73f944e9-147c-4980-a22a-dc37e464907b', 'Revenue & Expense Detail with Dates', 'Each revenue and expense line item, not grouped or summarized, for each auction in a terminal state, i.e., sold, not sold or canceled', 0, N'select	p.accountnumber, convert(varchar(10), s.StartTime, 20) [Date], case when a.state = 30 then ''Sold'' when a.state = 40 then ''Not Sold'' when a.state = 20 then ''Canceled'' end State ,/*a.invoicedon, a.invoicedas,*/ r.Code, r.Name, r.Revenue [Cost], convert(varchar(10), r.CreatedOn, 20) [CostDate], r.ActualExpense [Expense], convert(varchar(10), e.CreatedOn, 20) [ExpenseDate]
from	cvs.properties p		
		inner join cvs.auctions a	
			on a.propertyid = p.id
		inner join cvs.sales s
			on a.saleid = s.saleid AND SaleType = ''Adj''
		inner join acc.Receivable r
			on r.auction = a.auctionid
		left join acc.expense e
			on e.receivable = r.receivableid
where	a.state > 10		
order by p.accountnumber, r.code', 'Account Number,Date,State,Code,Name,Cost,Cost Date,Expense Date', 20, 1, NULL, 0, NULL, 0, 1, '2016-05-05 00:34:01.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('bcdd4ea0-50be-4f8f-b5c4-f29787f5ee14', 'Tax Sale Fees', 'Displays both percent and itemized fees associated with a tax sale', 0, N'SELECT	SUM(case WHEN tt.Category NOT IN (5,6) THEN pt.Balance ELSE 0 END) [Tax],
		SUM(pt.Interest) [Int],
		SUM(pt.Penalty) [Pen],
		SUM(pt.Collection) [9.5% Fee],
		SUM(case WHEN tt.Category IN (5,6) THEN pt.Balance ELSE 0 END) [Itemized Fee]
FROM	cvs.Auctions a
		INNER JOIN cvs.SellableTaxes pt
			ON pt.TaxSalePropertyId = a.AuctionId
		INNER JOIN cvs.TaxTypes tt
			ON tt.TaxTypeId = pt.TaxTypeId
WHERE	a.State = 10 AND a.SaleId = ''<FILTER>''', 'Tax, Interest, Penalty, 9.5% Fee, Itemized Fee', 15, 1, N'SELECT TOP 1
        LEFT(DATENAME(m, ts.StartTime), 3) + '' '' + DATENAME(yyyy, StartTime)
        + '' Tax Sale'' AS Name ,
        ts.SaleId
FROM    cvs.Sales ts
WHERE   SaleType = ''tax''
ORDER BY EndTime DESC', 0, 'Tax Sale', 0, 0, '2016-06-24 16:27:24.000', NULL, NULL)
INSERT INTO [dbo].[DataExports] ([Id], [Name], [Description], [Language], [Query], [ColumnHeaders], [Downloads], [IsVisible], [FilterQuery], [FilterLanguage], [FilterLabel], [UseDateRange], [MultiTA], [LastDownloaded], [GroupByColumns], [SubQuery]) VALUES ('493dbf2a-2ee9-4019-9da2-fbe33679a7cb', 'Unsold properties', 'Properties that did not sell in the last tax sale.', 0, N'select p.AccountNumber, p.Address1, ''$'' + CONVERT(varchar(20), CONVERT(money,a.Price),1), p.LegalDescription
from
cvs.Auctions a
inner join cvs.Properties p
on a.PropertyId = p.Id
where a.SaleId = ''<FILTER>''
and a.State = 40
order by p.AccountNumber', 'Account Number,Property Address,Auction Price, Legal Description', 300, 1, N'SELECT  LEFT(DATENAME(m, StartTime), 3) + '' '' + DATENAME(yyyy, StartTime)
        + '' Tax Sale'' AS Name ,
        ts.SaleId
FROM    cvs.Sales ts
        INNER JOIN ( SELECT MAX(EndTime) ed ,
                            SaleId
                     FROM   cvs.Sales
                     WHERE  SaleType = ''Tax''
                     GROUP BY SaleId
                   ) x ON x.SaleId = ts.SaleId
WHERE   SaleType = ''Tax''
AND GETDATE() > EndTime
ORDER BY x.ed DESC', 0, 'Tax Sale', 0, 0, '2016-08-30 19:04:24.000', NULL, NULL)
