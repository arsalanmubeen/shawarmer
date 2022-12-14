USE [EDSS]
GO
/****** Object:  StoredProcedure [dbo].[GNDITEM_CUSTOM_VIEW_FREE_ITEMS_SP]    Script Date: 1/26/2021 1:36:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[GNDITEM_CUSTOM_VIEW_FREE_ITEMS_SP]
	 
AS
BEGIN
BEGIN TRY
BEGIN -- region declaration
DECLARE @MAX_date nvarchar(50),
@GetDay int =0,
	  @query nvarchar(max);
	  set @GetDay = (SELECT [No_Days] FROM [Config_db].[dbo].[Decremental_Day_SP_Table] where ID =11);
set @MAX_date  = DATEADD(day , @GetDay*(-1) ,(select  max([DOB]) from GNDITEM_CUSTOM_VIEW_FREE_ITEMS)) ;

select * into #View_Packaging_Cost from [192.168.0.5].[EDSS].[dbo].View_Packaging_Cost
select * into #CR_QC_FPMAS from [192.168.0.5].[EDSS].[dbo].CR_QC_FPMAS
select * into #VW_FPDTX from [192.168.0.5].[EDSS].[dbo].VW_FPDTX
select * into #CR_GNDITEM from [CR_GNDITEMS] WHERE(CATEGORY = 14) or (case when (parent=0 and item in (90107,90108,90110,90134,90106)) then 1 else 0 end)=1
CREATE NONCLUSTERED INDEX IX_1 ON #CR_GNDITEM (BRAND);
CREATE NONCLUSTERED INDEX IX_2 ON #CR_GNDITEM (CATEGORY);
CREATE NONCLUSTERED INDEX IX_3 ON #CR_GNDITEM (DOB);
CREATE NONCLUSTERED INDEX IX_4 ON #CR_GNDITEM (ITEM);
CREATE NONCLUSTERED INDEX IX_5 ON #CR_GNDITEM (PARENT);


CREATE TABLE #STAG(
[REC_ID] [int] Primary Key,
	[COMPANY] [int] NULL,
	[BRAND] [int] NULL,
	[UNIT] [int] NULL,
	[DOB] [datetime] NULL,
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
	[RAW_(KG)_CHICKEN_SHAWARMA] [float] NULL,
	[(KG)_FRENCH_FRIS_9MM] [float] NULL,
	[(KG)_POTATO_CUBES_HOME_MCCAIN] [float] NULL,
	[(KG)_LAMB_FAT_SLICED] [float] NULL,
	[(KG)_VEAL_TOPSIDE_MARINATED] [float] NULL,
	[(KG)_VEAL_NECK_MARINATED] [float] NULL,
	[RECIPIES_COST] [float] NULL,
	[TAKE_OUT_COST] [float] NULL,
	[DineIn_COST] [float] NULL,
	[DuoMix_TakeOut] [float] NULL,
	[DuoMix_DineIn] [float] NULL,
	[DuoMixSaji_TakeOut] [float] NULL,
	[DuoMixSaji_DineIn] [float] NULL,
	[Samouli2x_TakeOut] [float] NULL,
	[Samouli2x_DineIn] [float] NULL,
	[Trio_TakeOut] [float] NULL,
	[Trio_DineIn] [float] NULL,
	[Promo3_box_Sandwich_TakeOut] [float] NULL,
	[Promo3_box_Sandwich_DineIn] [float] NULL,
	[PepsiCost_TakeOut] [float] NULL,
	[PepsiCost_DineIn] [float] NULL,
	[FriesCost_TakeOut] [float] NULL,
	[FriesCost_DineIn] [float] NULL
)

set @query = '
SELECT    REC_ID, COMPANY, BRAND, UNIT, DOB, TYPE, EMPLOYEE, CHECKID, ITEM, PARENT, CATEGORY, MODEID, PERIOD, HOUR, MINUTE, TAXID, REVID, TERMID, MENU, ORIGIN, PRICE, MODCODE, SEAT, ENTRYID, OCCASION, 
                         QUANTITY, TAXID2, CASE WHEN PARENT IN (130083, 130084) AND ITEM IN (20253, 20257, 20255, 20259, 20256, 20258, 20272, 20273, 20274, 20275, 20276, 20277) THEN (DISCPRIC + 6) ELSE DISCPRIC END AS DISCPRIC, 
                         REVID2, CONCEPT, CASE WHEN PARENT IN (130083, 130084) AND ITEM IN (20253, 20257, 20255, 20259, 20256, 20258, 20272, 20273, 20274, 20275, 20276, 20277) THEN (INCLTAX + 0.29) ELSE INCLTAX END AS INCLTAX, 
                         EXCLTAX, COST, QCID, CASE WHEN PARENT IN (130021, 130022, 130023, 130024) THEN ((CASE WHEN DOB < ''2019-06-01'' THEN ((2 * (PRICE / QUANTITY)) + 7) ELSE ((PRICE / QUANTITY) + 6) END)) 
                         WHEN ITEM = 130000 THEN (CASE WHEN DOB > ''2018-03-27'' THEN 18 ELSE 17 END) WHEN ITEM = 130001 THEN (CASE WHEN DOB > ''2018-03-27'' THEN 18 ELSE 19 END) 
                         WHEN ITEM = 130009 THEN (CASE WHEN DOB > ''2018-03-27'' THEN 22 ELSE 21 END) WHEN ITEM = 130010 THEN (CASE WHEN DOB > ''2018-03-27'' THEN 22 ELSE 23 END) WHEN ITEM IN (130053, 130054) 
                         THEN 20 WHEN ITEM IN (130055, 130056) THEN 24 WHEN ITEM IN (130059, 130060) THEN 20 WHEN ITEM IN (130063, 130064) THEN 22 WHEN ITEM = 130067 THEN 14 WHEN PARENT IN (130002, 130019, 130004, 130007, 
                         130014, 130013, 130025, 130006, 130003, 130005, 130008, 130020) THEN ((PRICE / QUANTITY) + (CASE WHEN DOB > ''2018-11-20'' THEN 6 ELSE 7 END)) 
                         WHEN item = 140040 THEN 188 WHEN PARENT = 130047 THEN (CASE WHEN DOB > ''2019-04-10'' THEN ((PRICE / QUANTITY) + 7) ELSE ((PRICE / QUANTITY) + 6) END) WHEN PARENT IN (130046, 130044, 130050, 130039, 
                         130038, 130049, 130048, 130045, 130068, 130083, 130084) THEN ((PRICE / QUANTITY) + 6) WHEN PARENT IN (130015, 130016, 130051, 130052) THEN (PRICE / QUANTITY) WHEN PARENT IN (130000, 130001, 130009, 130010, 
                         130053, 130054, 130055, 130056, 130059, 130060, 130063, 130064) THEN 0 WHEN PARENT != 0 AND ((CATEGORY != 10040 AND
                             (SELECT        A.CIT_CATID
                               FROM            [192.168.0.5].[EDSS].[dbo].CR_CIT A LEFT JOIN
                                               [192.168.0.5].[EDSS].[dbo].CR_ITEMCAT B ON B.CIT_BRAND = A.CIT_BRAND AND B.CIT_ID = A.CIT_CATID
                               WHERE        A.CIT_ITEMID = ITEM AND A.CIT_BRAND = BRAND AND B.CIT_SALES = ''Y'') != 10040) AND ITEM NOT IN (130015, 130016, 130051, 130052)) AND PARENT NOT IN (130071, 130072, 130073, 130074, 130079, 
                         130080, 10042, 10046, 10049, 10050, 10053, 10054, 10055, 10056, 10035, 140003, 140029, 140004, 140030, 140011, 140031, 140012, 140032) THEN 0 ELSE (PRICE / QUANTITY) END AS BASE_PRICE,
                             (SELECT        FPD_QTY AS Expr1
                               FROM            #VW_FPDTX
                               WHERE        (GIT.ITEM = FP_ID) AND (FPD_TI = 2210013)) AS [RAW_(KG)_CHICKEN_SHAWARMA],
                             (SELECT        FPD_QTY - FPD_QTY * 0.35 AS Expr1
                               FROM            #VW_FPDTX AS VW_FPDTX_5
                               WHERE        (GIT.ITEM = FP_ID) AND (FPD_TI = 2206003)) AS [(KG)_FRENCH_FRIS_9MM],
                             (SELECT        FPD_QTY - FPD_QTY * 0.35 AS Expr1
                               FROM            #VW_FPDTX AS VW_FPDTX_4
                               WHERE        (GIT.ITEM = FP_ID) AND (FPD_TI = 2206027)) AS [(KG)_POTATO_CUBES_HOME_MCCAIN],
                             (SELECT        FPD_QTY - FPD_QTY * 0.48 AS Expr1
                               FROM            #VW_FPDTX AS VW_FPDTX_3
                               WHERE        (GIT.ITEM = FP_ID) AND (FPD_TI = 2210012)) AS [(KG)_LAMB_FAT_SLICED],
                             (SELECT        FPD_QTY - FPD_QTY * 0.48 AS Expr1
                               FROM            #VW_FPDTX AS VW_FPDTX_2
                               WHERE        (GIT.ITEM = FP_ID) AND (FPD_TI = 2210057)) AS [(KG)_VEAL_TOPSIDE_MARINATED],
                             (SELECT        FPD_QTY - FPD_QTY * 0.48 AS Expr1
                               FROM            #VW_FPDTX AS VW_FPDTX_1
                               WHERE        (GIT.ITEM = FP_ID) AND (FPD_TI = 2210058)) AS [(KG)_VEAL_NECK_MARINATED],
                             (SELECT        FP_COST
                               FROM            #CR_QC_FPMAS
                               WHERE        (FP_BRAND = 1) AND (FP_ID = GIT.ITEM) AND (FP_PARENT = 0)) AS RECIPIES_COST,
                             (SELECT        ISNULL(SUM(ExtCost), 0) AS Expr1
                               FROM            #View_Packaging_Cost
                               WHERE        (ItemID = GIT.ITEM) AND (FPD_MODE = 2)) AS TAKE_OUT_COST,
                             (SELECT        ISNULL(SUM(ExtCost), 0) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_23
                               WHERE        (ItemID = GIT.ITEM) AND (FPD_MODE = 5)) AS DineIn_COST,
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_22
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20190)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_22
                               WHERE        (ItemID = 20190) AND (FPD_MODE = 2))) +
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_21
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20180)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_21
                               WHERE        (ItemID = 20180) AND (FPD_MODE = 2))) AS DuoMix_TakeOut,
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_20
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20190)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_20
                               WHERE        (ItemID = 20190) AND (FPD_MODE = 5))) +
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_19
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20180)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_19
                               WHERE        (ItemID = 20180) AND (FPD_MODE = 5))) AS DuoMix_DineIn,
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_18
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20193)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_18
                               WHERE        (ItemID = 20193) AND (FPD_MODE = 2))) +
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_17
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20186)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_17
                               WHERE        (ItemID = 20186) AND (FPD_MODE = 2))) AS DuoMixSaji_TakeOut,
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_16
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20193)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_16
                               WHERE        (ItemID = 20193) AND (FPD_MODE = 5))) +
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_15
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20186)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_15
                               WHERE        (ItemID = 20186) AND (FPD_MODE = 5))) AS DuoMixSaji_DineIn,
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_14
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20099)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_14
                               WHERE        (ItemID = 20099) AND (FPD_MODE = 2))) +
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_13
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20100)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_13
                               WHERE        (ItemID = 20100) AND (FPD_MODE = 2))) AS Samouli2x_TakeOut,
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_12
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20099)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_12
                               WHERE        (ItemID = 20099) AND (FPD_MODE = 5))) +
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_11
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20100)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_11
                               WHERE        (ItemID = 20100) AND (FPD_MODE = 5))) AS Samouli2x_DineIn,
                             (SELECT        FP_COST
                               FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_10
                               WHERE        (FP_BRAND = 1) AND (FP_ID = 20006)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_10
                               WHERE        (ItemID = 20006) AND (FPD_MODE = 2)) AS Trio_TakeOut,
                             (SELECT        FP_COST
                               FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_9
                               WHERE        (FP_BRAND = 1) AND (FP_ID = 20006)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_9
                               WHERE        (ItemID = 20006) AND (FPD_MODE = 5)) AS Trio_DineIn,
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_8
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20240)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_8
                               WHERE        (ItemID = 20240) AND (FPD_MODE = 2))) +
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_7
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20242)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_7
                               WHERE        (ItemID = 20242) AND (FPD_MODE = 2))) AS Promo3_box_Sandwich_TakeOut,
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_6
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20240)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_6
                               WHERE        (ItemID = 20240) AND (FPD_MODE = 5))) +
                             ((SELECT        FP_COST
                                 FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_5
                                 WHERE        (FP_BRAND = 1) AND (FP_ID = 20242)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_5
                               WHERE        (ItemID = 20242) AND (FPD_MODE = 5))) AS Promo3_box_Sandwich_DineIn,
                             (SELECT        FP_COST
                               FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_4
                               WHERE        (FP_BRAND = 1) AND (FP_ID = 90005)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_4
                               WHERE        (ItemID = 90005) AND (FPD_MODE = 2)) AS PepsiCost_TakeOut,
                             (SELECT        FP_COST
                               FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_3
                               WHERE        (FP_BRAND = 1) AND (FP_ID = 90005)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_3
                               WHERE        (ItemID = 90005) AND (FPD_MODE = 5)) AS PepsiCost_DineIn,
                             (SELECT        FP_COST
                               FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_2
                               WHERE        (FP_BRAND = 1) AND (FP_ID = 90037)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_2
                               WHERE        (ItemID = 90037) AND (FPD_MODE = 2)) AS FriesCost_TakeOut,
                             (SELECT        FP_COST
                               FROM            #CR_QC_FPMAS AS CR_QC_FPMAS_1
                               WHERE        (FP_BRAND = 1) AND (FP_ID = 90037)) +
                             (SELECT        SUM(ExtCost) AS Expr1
                               FROM            #View_Packaging_Cost AS View_Packaging_Cost_1
                               WHERE        (ItemID = 90037) AND (FPD_MODE = 5)) AS FriesCost_DineIn
FROM         #CR_GNDITEM as GIT  ';
END

if (select count(1) from GNDITEM_CUSTOM_VIEW_FREE_ITEMS) > 0
BEGIN
set @query = CONCAT('INSERT INTO #STAG  ',@query,' where GIT.[DOB] > cast(''', @MAX_date,''' as date);');
EXECUTE (@query);

MERGE GNDITEM_CUSTOM_VIEW_FREE_ITEMS AS T
USING #STAG AS S
ON (T.[REC_ID]=S.[REC_ID] )
WHEN MATCHED 
   THEN UPDATE 
   SET  T.[COMPANY]=S.[COMPANY]
, T.[BRAND]=S.[BRAND]
, T.[UNIT]=S.[UNIT]
, T.[DOB]=S.[DOB]
, T.[TYPE]=S.[TYPE]
, T.[EMPLOYEE]=S.[EMPLOYEE]
, T.[CHECKID]=S.[CHECKID]
, T.[ITEM]=S.[ITEM]
, T.[PARENT]=S.[PARENT]
, T.[CATEGORY]=S.[CATEGORY]
, T.[MODEID]=S.[MODEID]
, T.[PERIOD]=S.[PERIOD]
, T.[HOUR]=S.[HOUR]
, T.[MINUTE]=S.[MINUTE]
, T.[TAXID]=S.[TAXID]
, T.[REVID]=S.[REVID]
, T.[TERMID]=S.[TERMID]
, T.[MENU]=S.[MENU]
, T.[ORIGIN]=S.[ORIGIN]
, T.[PRICE]=S.[PRICE]
, T.[MODCODE]=S.[MODCODE]
, T.[SEAT]=S.[SEAT]
, T.[ENTRYID]=S.[ENTRYID]
, T.[OCCASION]=S.[OCCASION]
, T.[QUANTITY]=S.[QUANTITY]
, T.[TAXID2]=S.[TAXID2]
, T.[DISCPRIC]=S.[DISCPRIC]
, T.[REVID2]=S.[REVID2]
, T.[CONCEPT]=S.[CONCEPT]
, T.[INCLTAX]=S.[INCLTAX]
, T.[EXCLTAX]=S.[EXCLTAX]
, T.[COST]=S.[COST]
, T.[QCID]=S.[QCID]
, T.[BASE_PRICE]=S.[BASE_PRICE]
, T.[RAW_(KG)_CHICKEN_SHAWARMA]=S.[RAW_(KG)_CHICKEN_SHAWARMA]
, T.[(KG)_FRENCH_FRIS_9MM]=S.[(KG)_FRENCH_FRIS_9MM]
, T.[(KG)_POTATO_CUBES_HOME_MCCAIN]=S.[(KG)_POTATO_CUBES_HOME_MCCAIN]
, T.[(KG)_LAMB_FAT_SLICED]=S.[(KG)_LAMB_FAT_SLICED]
, T.[(KG)_VEAL_TOPSIDE_MARINATED]=S.[(KG)_VEAL_TOPSIDE_MARINATED]
, T.[(KG)_VEAL_NECK_MARINATED]=S.[(KG)_VEAL_NECK_MARINATED]
, T.[RECIPIES_COST]=S.[RECIPIES_COST]
, T.[TAKE_OUT_COST]=S.[TAKE_OUT_COST]
, T.[DineIn_COST]=S.[DineIn_COST]
, T.[DuoMix_TakeOut]=S.[DuoMix_TakeOut]
, T.[DuoMix_DineIn]=S.[DuoMix_DineIn]
, T.[DuoMixSaji_TakeOut]=S.[DuoMixSaji_TakeOut]
, T.[DuoMixSaji_DineIn]=S.[DuoMixSaji_DineIn]
, T.[Samouli2x_TakeOut]=S.[Samouli2x_TakeOut]
, T.[Samouli2x_DineIn]=S.[Samouli2x_DineIn]
, T.[Trio_TakeOut]=S.[Trio_TakeOut]
, T.[Trio_DineIn]=S.[Trio_DineIn]
, T.[Promo3_box_Sandwich_TakeOut]=S.[Promo3_box_Sandwich_TakeOut]
, T.[Promo3_box_Sandwich_DineIn]=S.[Promo3_box_Sandwich_DineIn]
, T.[PepsiCost_TakeOut]=S.[PepsiCost_TakeOut]
, T.[PepsiCost_DineIn]=S.[PepsiCost_DineIn]
, T.[FriesCost_TakeOut]=S.[FriesCost_TakeOut]
, T.[FriesCost_DineIn]=S.[FriesCost_DineIn]
WHEN NOT MATCHED  BY TARGET 
   THEN INSERT values (
   S.[REC_ID] 
 ,S.[COMPANY]
,S.[BRAND]
,S.[UNIT]
,S.[DOB]
,S.[TYPE]
,S.[EMPLOYEE]
,S.[CHECKID]
,S.[ITEM]
,S.[PARENT]
,S.[CATEGORY]
,S.[MODEID]
,S.[PERIOD]
,S.[HOUR]
,S.[MINUTE]
,S.[TAXID]
,S.[REVID]
,S.[TERMID]
,S.[MENU]
,S.[ORIGIN]
,S.[PRICE]
,S.[MODCODE]
,S.[SEAT]
,S.[ENTRYID]
,S.[OCCASION]
,S.[QUANTITY]
,S.[TAXID2]
,S.[DISCPRIC]
,S.[REVID2]
,S.[CONCEPT]
,S.[INCLTAX]
,S.[EXCLTAX]
,S.[COST]
,S.[QCID]
,S.[BASE_PRICE]
,S.[RAW_(KG)_CHICKEN_SHAWARMA]
,S.[(KG)_FRENCH_FRIS_9MM]
,S.[(KG)_POTATO_CUBES_HOME_MCCAIN]
,S.[(KG)_LAMB_FAT_SLICED]
,S.[(KG)_VEAL_TOPSIDE_MARINATED]
,S.[(KG)_VEAL_NECK_MARINATED]
,S.[RECIPIES_COST]
,S.[TAKE_OUT_COST]
,S.[DineIn_COST]
,S.[DuoMix_TakeOut]
,S.[DuoMix_DineIn]
,S.[DuoMixSaji_TakeOut]
,S.[DuoMixSaji_DineIn]
,S.[Samouli2x_TakeOut]
,S.[Samouli2x_DineIn]
,S.[Trio_TakeOut]
,S.[Trio_DineIn]
,S.[Promo3_box_Sandwich_TakeOut]
,S.[Promo3_box_Sandwich_DineIn]
,S.[PepsiCost_TakeOut]
,S.[PepsiCost_DineIn]
,S.[FriesCost_TakeOut]
,S.[FriesCost_DineIn])
WHEN NOT MATCHED BY SOURCE AND T.[DOB] > cast(@MAX_date as date)
THEN DELETE ;

END
else
BEGIN
 BEGIN -- DISABLE INDEX
ALTER INDEX [NonClusteredIndex-BRAND] ON [dbo].GNDITEM_CUSTOM_VIEW_FREE_ITEMS DISABLE
ALTER INDEX  [NonClusteredIndex-ITEM] ON [dbo].GNDITEM_CUSTOM_VIEW_FREE_ITEMS DISABLE
ALTER INDEX [NonClusteredIndex-MODEID] ON [dbo].GNDITEM_CUSTOM_VIEW_FREE_ITEMS DISABLE
ALTER INDEX  [NonClusteredIndex-PERIOD] ON [dbo].GNDITEM_CUSTOM_VIEW_FREE_ITEMS DISABLE
ALTER INDEX  [NonClusteredIndex-UNIT] ON [dbo].GNDITEM_CUSTOM_VIEW_FREE_ITEMS DISABLE
ALTER INDEX  [NonClusteredIndex-ENTRYID] ON [dbo].GNDITEM_CUSTOM_VIEW_FREE_ITEMS DISABLE
 END

BEGIN -- Insert data IN
set @query = CONCAT('INSERT INTO GNDITEM_CUSTOM_VIEW_FREE_ITEMS  ',@query);
EXECUTE ( @query);
END
BEGIN -- ABLE INDEX
ALTER INDEX [NonClusteredIndex-BRAND] ON [dbo].GNDITEM_CUSTOM_VIEW_FREE_ITEMS REBUILD
ALTER INDEX  [NonClusteredIndex-ITEM] ON [dbo].GNDITEM_CUSTOM_VIEW_FREE_ITEMS REBUILD
ALTER INDEX [NonClusteredIndex-MODEID] ON [dbo].GNDITEM_CUSTOM_VIEW_FREE_ITEMS REBUILD
ALTER INDEX  [NonClusteredIndex-PERIOD] ON [dbo].GNDITEM_CUSTOM_VIEW_FREE_ITEMS REBUILD
ALTER INDEX  [NonClusteredIndex-UNIT] ON [dbo].GNDITEM_CUSTOM_VIEW_FREE_ITEMS REBUILD
ALTER INDEX  [NonClusteredIndex-ENTRYID] ON [dbo].GNDITEM_CUSTOM_VIEW_FREE_ITEMS REBUILD
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


