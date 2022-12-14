USE [EDSS]
GO
/****** Object:  StoredProcedure [dbo].[GNDITEM_CUSTOM_VIEW_TBL_SP]    Script Date: 1/26/2021 1:36:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[GNDITEM_CUSTOM_VIEW_TBL_SP] 
	 
AS
BEGIN
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN -- region declaration
    DECLARE @MAX_date nvarchar(20),
	@GetDay int=0 ,
	  @query nvarchar(max);

	  CREATE TABLE #CR_GNDITEM (
	[REC_ID] [int] Primary Key,
	[COMPANY] [int] NOT NULL,
	[BRAND] [int] NOT NULL,
	[UNIT] [int] NOT NULL,
	[DOB] [datetime] NOT NULL,
	[TYPE] [smallint] NULL,
	[EMPLOYEE] [int] NULL,
	[CHECKID] [int] NULL,
	[ITEM] [int] NULL,
	[PARENT] [int] NULL,
	[CATEGORY] [int] NULL,
	[MODEID] [int] NULL,
	[PERIOD] [int] NULL,
	[HOUR] [smallint] NULL,
	[MINUTE] [smallint] NULL,
	[TAXID] [int] NULL,
	[REVID] [int] NULL,
	[TERMID] [int] NULL,
	[MENU] [int] NULL,
	[ORIGIN] [int] NULL,
	[PRICE] [float] NULL,
	[MODCODE] [smallint] NULL,
	[SEAT] [smallint] NULL,
	[ENTRYID] [int] NULL,
	[OCCASION] [int] NULL,
	[QUANTITY] [float] NULL,
	[TAXID2] [int] NULL,
	[DISCPRIC] [float] NULL,
	[REVID2] [int] NULL,
	[CONCEPT] [int] NULL,
	[INCLTAX] [float] NULL,
	[EXCLTAX] [smallint] NULL,
	[COST] [float] NULL,
	[QCID] [int] NULL,
	[BASE_PRICE] [float] NULL,
	[RECIPIES_COST] [float] NULL,
	[TAKE_OUT_COST] [float] NULL,
	[DineIn_COST] [float] NULL);

	SELECT * into #CR_CIT FROM  [192.168.0.5].[EDSS].[dbo].CR_CIT
	CREATE NONCLUSTERED INDEX IX_1 ON #CR_CIT (CIT_BRAND,CIT_CATID,CIT_ITEMID);

	SELECT * into #CR_ITEMCAT FROM  [192.168.0.5].[EDSS].[dbo].CR_ITEMCAT
	CREATE NONCLUSTERED INDEX IX_1 ON #CR_ITEMCAT (CIT_BRAND,CIT_ID,CIT_SALES);

	SELECT * into #CR_QC_FPMAS FROM  [192.168.0.5].[EDSS].[dbo].CR_QC_FPMAS
	CREATE NONCLUSTERED INDEX IX_1 ON #CR_QC_FPMAS (FP_BRAND,FP_ID,FP_PARENT);

	SELECT * into #View_Packaging_Cost FROM  [192.168.0.5].[EDSS].[dbo].View_Packaging_Cost
	CREATE NONCLUSTERED INDEX IX_1 ON #View_Packaging_Cost (ItemID,FPD_MODE);

	
END

BEGIN -- region assignment
set @GetDay = (SELECT [No_Days] FROM [Config_db].[dbo].[Decremental_Day_SP_Table] where ID =2);
    set @MAX_date  = DATEADD(day , @GetDay*(-1) ,(select  max(DOB) from [GNDITEM_CUSTOM_VIEW_TBL])) ;
	--set @SourceTblDate = (select  max(DOB) from CR_GNDITEMS) 
	set @query ='       SELECT REC_ID, COMPANY, BRAND, UNIT, DOB, TYPE, EMPLOYEE, CHECKID, ITEM, PARENT, CATEGORY, MODEID, PERIOD, HOUR, MINUTE, TAXID, REVID, TERMID, MENU, ORIGIN, PRICE, MODCODE, SEAT, ENTRYID, OCCASION, 
                         QUANTITY, TAXID2, CASE WHEN PARENT IN (130083, 130084) AND ITEM IN (20253, 20257, 20255, 20259, 20256, 20258, 20272, 20273, 20274, 20275, 20276, 20277) THEN (DISCPRIC + 6) WHEN PARENT = 10104 THEN 11 ELSE DISCPRIC END AS DISCPRIC, 
                         REVID2, CONCEPT, CASE WHEN PARENT IN (130083, 130084) AND ITEM IN (20253, 20257, 20255, 20259, 20256, 20258, 20272, 20273, 20274, 20275, 20276, 20277) THEN (INCLTAX + 0.29) WHEN PARENT = 10104 THEN 1.43 ELSE INCLTAX END AS INCLTAX, 
                         EXCLTAX, COST, QCID, 

						 CASE 
						WHEN ORIGIN IN (10431,10432,10433,10434,10435,10436,10437,10438,10439,10440,10443,10444,10459,10460,10461,10482,10483,10488,10489,10490,10491,10530,10531,10532,10533,10534) THEN  COALESCE(PRICE / NULLIF(QUANTITY,0), 0)
						 WHEN PARENT IN (130021, 130022, 130023, 130024) THEN (CASE WHEN DOB < convert( datetime ,''2019-06-01 00:00:00.000'') THEN ((2 * COALESCE(PRICE / NULLIF(QUANTITY,0), 0)) + 7) ELSE (COALESCE(PRICE / NULLIF(QUANTITY,0), 0) + 6) END) 
                         WHEN ITEM = 130000 THEN (CASE WHEN DOB > convert( datetime ,''2020-06-30 00:00:00.000'') THEN 22 WHEN DOB > convert( datetime ,''2018-03-27 00:00:00.000'') THEN 18 ELSE 17 END) 
						 WHEN ITEM = 130001 THEN (CASE WHEN DOB > convert( datetime ,''2020-06-30 00:00:00.000'') THEN 22 WHEN DOB > convert( datetime ,''2018-03-27 00:00:00.000'') THEN 18 ELSE 19 END) 
                         WHEN ITEM = 130009 THEN (CASE WHEN DOB > convert( datetime ,''2020-08-17 00:00:00.000'') THEN 26 ELSE (CASE WHEN DOB > convert( datetime ,''2018-03-27 00:00:00.000'') THEN 22 ELSE 21 END) end) 
						 WHEN ITEM = 130010 THEN (CASE WHEN DOB > convert( datetime ,''2020-08-17 00:00:00.000'')THEN 26 ELSE (CASE WHEN DOB > convert( datetime ,''2018-03-27 00:00:00.000'') THEN 22 ELSE 23 END)END) 
						 WHEN ITEM IN (130053, 130054,130059, 130060) THEN 20 
						 WHEN ITEM IN (130055, 130056) THEN 24 
						 WHEN ITEM IN (130133,130134) THEN (CASE WHEN DOB > convert( datetime ,''2020-06-30 00:00:00.000'') THEN 22 ELSE 18 END) 
						 WHEN ITEM IN (130063, 130064) THEN 22 
						 WHEN ITEM = 130067 THEN 14 
						 WHEN PARENT IN (130002, 130019, 130004, 130007,130014, 130013, 130025,130049, 130006, 130003, 130005, 130008, 130020,130075,130076,130077,130123,130124) THEN (COALESCE(PRICE / NULLIF(QUANTITY,0), 0) + (CASE  WHEN DOB > convert( datetime ,''2020-06-30 00:00:00.000'') THEN 8 WHEN DOB > convert( datetime ,''2018-11-20 00:00:00.000'') THEN 6 ELSE 7 END)) 
                         WHEN item = 140040 THEN 188 
						 WHEN PARENT = 130047 THEN (CASE WHEN DOB > convert( datetime ,''2019-04-10 00:00:00.000'') THEN (COALESCE(PRICE / NULLIF(QUANTITY,0), 0) + 7) ELSE (COALESCE(PRICE / NULLIF(QUANTITY,0), 0) + 6) END) 
						 WHEN PARENT IN (130046, 130044, 130050, 130039, 130038, 130048, 130045, 130068, 130083, 130084) THEN (COALESCE(PRICE / NULLIF(QUANTITY,0), 0) + 6) 
						 WHEN PARENT = 130130 THEN (COALESCE(PRICE / NULLIF(QUANTITY,0), 0) + 1) 
						 WHEN PARENT IN (130015, 130016, 130051, 130052) THEN COALESCE(PRICE / NULLIF(QUANTITY,0), 0) 
						 WHEN PARENT = 130118 THEN (COALESCE(PRICE / NULLIF(QUANTITY,0), 0) + 3) 
						 WHEN PARENT = 130119 THEN (COALESCE(PRICE / NULLIF(QUANTITY,0), 0) + 5)
						 WHEN PARENT = 10104 THEN 11
						 WHEN PARENT IN (130000, 130001,130133,130134, 130009, 130010,130053, 130054, 130055, 130056, 130059, 130060, 130063, 130064) THEN 0 
						 WHEN PARENT <> 0 AND ((CATEGORY <> 10040 AND 
						                  (SELECT  A.CIT_CATID
                               FROM            #CR_CIT A LEFT JOIN
                                                         #CR_ITEMCAT B ON B.CIT_BRAND = A.CIT_BRAND AND B.CIT_ID = A.CIT_CATID
                               WHERE        A.CIT_ITEMID = ITEM AND A.CIT_BRAND = BRAND AND B.CIT_SALES = ''Y'') <> 10040) AND
							   ITEM NOT IN (130015, 130016, 130051, 130052)) AND 
							   PARENT NOT IN (130071,130131,130132, 130072, 130073, 130074, 130079,130080, 10042, 10046, 10049,10086,10087,10091,10092, 10050, 10053, 10054, 10055, 10056, 10035, 140003, 140029, 140004,140073,140074, 140030, 140011, 140031, 140012, 140032,40069,40070) THEN 0 
						ELSE COALESCE(PRICE / NULLIF(QUANTITY,0), 0) END AS BASE_PRICE,
                          
                             (SELECT        FP_COST
                               FROM            #CR_QC_FPMAS
                               WHERE        (FP_BRAND = 1) AND (FP_ID = CR_GNDITEM.ITEM) AND (FP_PARENT = 0)) AS RECIPIES_COST,
                             (SELECT        ISNULL(SUM(ExtCost), 0) AS Expr1
                               FROM            #View_Packaging_Cost
                               WHERE        (ItemID = CR_GNDITEM.ITEM) AND (FPD_MODE = 2)) AS TAKE_OUT_COST,
                             (SELECT        ISNULL(SUM(ExtCost), 0) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_23
                               WHERE        (ItemID = CR_GNDITEM.ITEM) AND (FPD_MODE = 5)) AS DineIn_COST
                             
FROM          CR_GNDITEMS CR_GNDITEM
WHERE        (CATEGORY <> 14) and (case when (parent=0 and item in (90107,90108,90110,90134,90106)) then 1 else 0 end)=0';
END
--if @SourceTblDate <> @MAX_date
if (select count(1) from [GNDITEM_CUSTOM_VIEW_TBL]) > 0
BEGIN
set @query = CONCAT('INSERT INTO #CR_GNDITEM ',@query,'AND DOB > ''', @MAX_date,'''');
EXECUTE ( @query);

MERGE [GNDITEM_CUSTOM_VIEW_TBL] AS T
USING #CR_GNDITEM AS S
ON (S.[REC_ID] = T.[REC_ID])
WHEN MATCHED 
   THEN UPDATE 
   SET T.[COMPANY] = S.COMPANY
      ,T.[BRAND] = S.BRAND
      ,T.[UNIT] = S.UNIT
      ,T.[DOB] = S.DOB
      ,T.[TYPE] = S.TYPE
      ,T.[EMPLOYEE] = S.EMPLOYEE
      ,T.[CHECKID] = S.CHECKID
      ,T.[ITEM] = S.ITEM
      ,T.[PARENT] = S.PARENT
      ,T.[CATEGORY] = S.CATEGORY
      ,T.[MODEID] = S.MODEID
      ,T.[PERIOD] = S.PERIOD
      ,T.[HOUR] = S.HOUR
      ,T.[MINUTE] = S.MINUTE
      ,T.[TAXID] = S.TAXID
      ,T.[REVID] = S.REVID
      ,T.[TERMID] = S.TERMID
      ,T.[MENU] = S.MENU
      ,T.[ORIGIN] = S.ORIGIN
      ,T.[PRICE] = S.PRICE
      ,T.[MODCODE] = S.MODCODE
      ,T.[SEAT] = S.SEAT
      ,T.[ENTRYID] = S.ENTRYID
      ,T.[OCCASION] = S.OCCASION
      ,T.[QUANTITY] = S.QUANTITY
      ,T.[TAXID2] = S.TAXID2
      ,T.[DISCPRIC] = S.DISCPRIC
      ,T.[REVID2] = S.REVID2
      ,T.[CONCEPT] = S.CONCEPT
      ,T.[INCLTAX] = S.INCLTAX
      ,T.[EXCLTAX] = S.EXCLTAX
      ,T.[COST] = S.COST
      ,T.[QCID] = S.QCID
      ,T.[BASE_PRICE] = S.BASE_PRICE
      ,T.[RECIPIES_COST] = S.RECIPIES_COST
      ,T.[TAKE_OUT_COST] = S.TAKE_OUT_COST
      ,T.[DineIn_COST] = S.DineIn_COST
WHEN NOT MATCHED BY TARGET
   THEN INSERT values (S.REC_ID
           ,S.COMPANY
           ,S.BRAND
           ,S.UNIT
           ,S.DOB
           ,S.TYPE
           ,S.EMPLOYEE
           ,S.CHECKID
           ,S.ITEM
           ,S.PARENT
           ,S.CATEGORY
           ,S.MODEID
           ,S.PERIOD
           ,S.HOUR
           ,S.MINUTE
           ,S.TAXID
           ,S.REVID
           ,S.TERMID
           ,S.MENU
           ,S.ORIGIN
           ,S.PRICE
           ,S.MODCODE
           ,S.SEAT
           ,S.ENTRYID
           ,S.OCCASION
           ,S.QUANTITY
           ,S.TAXID2
           ,S.DISCPRIC
           ,S.REVID2
           ,S.CONCEPT
           ,S.INCLTAX
           ,S.EXCLTAX
           ,S.COST
           ,S.QCID
           ,S.BASE_PRICE
           ,S.RECIPIES_COST
           ,S.TAKE_OUT_COST
           ,S.DineIn_COST)
 WHEN NOT MATCHED BY SOURCE AND T.[DOB] > cast(@MAX_date as date)
THEN DELETE ;

END
else
BEGIN
BEGIN -- DISABLE INDEX
ALTER INDEX [NonClusteredIndex-BRAND] ON [dbo].[GNDITEM_CUSTOM_VIEW_TBL] DISABLE
ALTER INDEX  [NonClusteredIndex-DOB] ON [dbo].[GNDITEM_CUSTOM_VIEW_TBL] DISABLE
ALTER INDEX  [NonClusteredIndex-ITEM] ON [dbo].[GNDITEM_CUSTOM_VIEW_TBL] DISABLE
ALTER INDEX  [NonClusteredIndex-MODEID] ON [dbo].[GNDITEM_CUSTOM_VIEW_TBL] DISABLE
ALTER INDEX  [NonClusteredIndex-ORIGIN] ON [dbo].[GNDITEM_CUSTOM_VIEW_TBL] DISABLE
ALTER INDEX  [NonClusteredIndex-PARENT] ON [dbo].[GNDITEM_CUSTOM_VIEW_TBL] DISABLE
ALTER INDEX  [NonClusteredIndex-UNIT] ON [dbo].[GNDITEM_CUSTOM_VIEW_TBL] DISABLE
END
BEGIN -- Insert data IN
EXECUTE ('INSERT INTO [GNDITEM_CUSTOM_VIEW_TBL] ' + @query )
END
BEGIN --REBUILD INDEX
ALTER INDEX [NonClusteredIndex-BRAND] ON [dbo].[GNDITEM_CUSTOM_VIEW_TBL] REBUILD
ALTER INDEX  [NonClusteredIndex-DOB] ON [dbo].[GNDITEM_CUSTOM_VIEW_TBL] REBUILD
ALTER INDEX  [NonClusteredIndex-ITEM] ON [dbo].[GNDITEM_CUSTOM_VIEW_TBL] REBUILD
ALTER INDEX  [NonClusteredIndex-MODEID] ON [dbo].[GNDITEM_CUSTOM_VIEW_TBL] REBUILD
ALTER INDEX  [NonClusteredIndex-ORIGIN] ON [dbo].[GNDITEM_CUSTOM_VIEW_TBL] REBUILD
ALTER INDEX  [NonClusteredIndex-PARENT] ON [dbo].[GNDITEM_CUSTOM_VIEW_TBL] REBUILD
ALTER INDEX  [NonClusteredIndex-UNIT] ON [dbo].[GNDITEM_CUSTOM_VIEW_TBL] REBUILD
END
END

END try
BEGIN CATCH
INSERT INTO [Config_db].[dbo].[ERROR_LOG]
           ([DATE]
           ,[ERROR_NUMBER]
           ,[ERROR_STATE]
           ,[ERROR_SEVERITY]
           ,[ERROR_LINE]
           ,[ERROR_PROCEDURE]
           ,[ERROR_MESSAGE]
           ,[SP_NAME])
     VALUES
           (getdate()
           ,ERROR_NUMBER()
           ,ERROR_STATE()
           ,ERROR_SEVERITY()
           ,ERROR_LINE()
           ,ERROR_PROCEDURE()
           ,ERROR_MESSAGE()
           ,OBJECT_NAME(@@PROCID))
select * from [GOTO_ERROR_LOG_TABLE_IN_Config_db]
END CATCH

END
