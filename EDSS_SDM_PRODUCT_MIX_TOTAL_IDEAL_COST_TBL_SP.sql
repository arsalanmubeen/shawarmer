USE [EDSS]
GO
/****** Object:  StoredProcedure [dbo].[EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL_SP]    Script Date: 1/26/2021 1:34:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL_SP] 
	
AS
BEGIN
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN -- region declaration
    DECLARE @MAX_date datetime,
	@GetDay int =0,
	  @queryStgTBL nvarchar(max),
	  @query nvarchar(max),
	  @INDEX nvarchar(max);

CREATE TABLE #STG_TABLE(
	[REC_ID] [int] NOT NULL,
	[COMPANY] [int] NOT NULL,
	[BRAND] [int] NOT NULL,
	[UNIT] [int] NOT NULL,
	[DOB] [datetime] NOT NULL,
	[ITEM] [int] NULL,
	[Parent] [int] NULL,
	[DISCPRIC] [float] NULL,
	[INCLTAX] [float] NULL,
	[CHECKID] [int] NULL,
	[RECIPIES_COST] [float] NULL,
	[TAKE_OUT_COST] [float] NULL,
	[DineIn_COST] [float] NULL,
	[MODEID] [int] NULL,
	[PERIOD] [int] NULL,
	[STR_NAME] [nvarchar](50) NULL,
	[ORD_NAME] [nvarchar](35) NULL,
	[ORD_ID] [int] NOT NULL,
	[ORDER_SOURCE] [varchar](100) NULL
)
CREATE TABLE #EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL(
	[COMPANY] [int] NOT NULL,
	[BRAND] [int] NOT NULL,
	[STORE_ID] [int] NOT NULL,
	[DOB] [datetime] NOT NULL,
	[STR_NAME] [nvarchar](50) NULL,
	[ORDER_MODE] [nvarchar](100) NULL,
	[TOTAL_IDEAL_COST] [float] NULL,
	[NET_TOTAL] [float] NULL,
	[TOTAL] [float] NULL,
	[IDEAL%] [float] NULL,
	[ITEM] [int] NULL,
	[Parent] [int] NULL
);
END

select * into #MENU_ITEMS_TYPES from  [192.168.0.5].[PMA].[dbo].[MENU_ITEMS_TYPES]
CREATE NONCLUSTERED INDEX IX_4 ON #MENU_ITEMS_TYPES (ITEM_ID)

select * into #CR_PERIOD from  [192.168.0.5].[EDSS].[dbo].[CR_PERIOD]
CREATE NONCLUSTERED INDEX IX_6 ON #CR_PERIOD (PRD_ID,PRD_BRAND)

select * into #CR_ORDER_MODE from  [192.168.0.5].[EDSS].[dbo].[CR_ORDER_MODE]
CREATE NONCLUSTERED INDEX IX_5 ON #CR_ORDER_MODE ([ORD_ID],ORD_BRAND)

select * into #CR_STORE from [192.168.0.5].[EDSS].[dbo].CR_STORE
CREATE NONCLUSTERED INDEX IX_3 ON #CR_STORE (STR_NO,STR_BRAND);

select * into #CR_MENUITEM from [192.168.0.5].[EDSS].[dbo].CR_MENUITEM
CREATE NONCLUSTERED INDEX IX_1 ON #CR_MENUITEM (MI_ID,MI_BRAND);

select * into #CR_TOTLCKS from [192.168.0.5].[EDSS].[dbo].CR_TOTLCKS
CREATE NONCLUSTERED INDEX IX_1 ON #CR_TOTLCKS (UNIT,DOB);

BEGIN -- region assignment
set @GetDay = (SELECT [No_Days] FROM [Config_db].[dbo].[Decremental_Day_SP_Table] where ID =7);
    set @MAX_date  = DATEADD(day , @GetDay*(-1) ,(select  max(DOB) from [EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL])) ;
	set @queryStgTBL =
'select GT.REC_ID,GT.[COMPANY],GT.[BRAND],GT.UNIT,GT.[DOB],GT.ITEM,GT.Parent,GT.DISCPRIC,GT.INCLTAX,GT.CHECKID,GT.RECIPIES_COST,Gt.TAKE_OUT_COST,GT.DineIn_COST,GT.MODEID,GT.[PERIOD],
STORE.STR_NAME,B.ORD_NAME,B.ORD_ID,odr.ORDER_SOURCE
from GNDITEM_CUSTOM_VIEW_TBL AS GT
INNER JOIN #CR_MENUITEM MENU on MENU.MI_ID=GT.ITEM AND MENU.MI_BRAND=GT.BRAND AND 1=1
INNER JOIN #CR_STORE STORE on  STORE.STR_NO= GT.UNIT AND MENU.MI_BRAND=STORE.STR_BRAND
INNER JOIN #CR_ORDER_MODE AS B ON GT.MODEID=B.[ORD_ID] AND B.ORD_BRAND=GT.BRAND
INNER JOIN #CR_PERIOD AS C ON GT.[PERIOD]=C.PRD_ID AND GT.BRAND=C.PRD_BRAND 
LEFT JOIN (select *,row_number() over(partition by SDM_DOB,STORE_NUM,ALOHA_CHECKNO order by [SDM_ORDER_ID] desc) as rn 
  from  [SDM].[dbo].[ALL_SDM_HIST_ORDERS]) odr ON odr.SDM_DOB = DOB AND ODR.STORE_NUM = GT.UNIT AND odr.ALOHA_CHECKNO = CHECKID AND rn = 1
LEFT JOIN #MENU_ITEMS_TYPES AS MIT On (CASE WHEN Parent =0 THEN ITEM ELSE Parent END) = MIT.ITEM_ID
';
  set @query = 'select  
COMPANY,
BRAND,
STORE_ID,
DOB,
STR_NAME,
ORDER_MODE,
TOTAL_IDEAL_COST,
NET_TOTAL,
TOTAL 
,(TOTAL_IDEAL_COST /NULLIF((select SUM(Net)  from #CR_TOTLCKS AS TOT where TOT.UNIT = F.STORE_ID AND TOT.DOB=F.DOB),0))* 100 As [IDEAL%],
ITEM,
PARENT
FROM(
SELECT 
COMPANY,
BRAND,
UNIT STORE_ID,
DOB,
STR_NAME,
ORDER_MODE,
SUM(TOTAL_IDEAL_COST) TOTAL_IDEAL_COST,
SUM(NET_TOTAL) NET_TOTAL,
SUM(TOTAL) TOTAL,
PARENT,
ITEM
from
(
Select
COMPANY,
BRAND,
UNIT,
STR_NAME,
DOB,
CASE WHEN SUBSTRING(convert(char(32),CHECKID), 1,1) = 8 AND MAX(ORDER_SOURCE) IS NOT NULL
THEN LTRIM(RTRIM(isnull(MAX(ORDER_SOURCE),ORD_NAME))) COLLATE SQL_Latin1_General_CP1_CI_AS
WHEN ORD_ID in (8,13,16,17) THEN ''HungerStation''
WHEN ORD_ID in (10,11) THEN ''Wassel'' 
WHEN ORD_ID IN (15) THEN ''Ubereats'' 
WHEN ORD_ID =9 THEN ''Jahez''
ELSE 
LTRIM(RTRIM(ORD_NAME))
END as ORDER_MODE,
SUM(DISCPRIC - INCLTAX) AS [NET_TOTAL],
SUM(DISCPRIC) AS [TOTAL],
case when ORD_ID not in (5,1,3) then
((SUM(RECIPIES_COST)+ SUM(TAKE_OUT_COST))) else 0 end AS TAKE_OUT_IDEAL_COST,
case when ORD_ID in (5,1,3 ) then
((SUM(RECIPIES_COST)+ SUM(DineIn_COST))) else 0 end AS DINE_IN_IDEAL_COST,
((case when ORD_ID not in (5,1,3) then
((SUM(RECIPIES_COST)+ SUM(TAKE_OUT_COST))) else 0 end) +
(case when ORD_ID in (5,1,3 ) then
((SUM(RECIPIES_COST)+ SUM(DineIn_COST))) else 0 end)) AS TOTAL_IDEAL_COST,
PARENT,
ITEM
from #STG_TABLE

GROUP BY 
COMPANY,
BRAND,
UNIT,
STR_NAME,
DOB,
CHECKID,
ORD_ID,
ORD_NAME,
PARENT,
ITEM
)c
GROUP BY 
COMPANY,
BRAND,
UNIT,
STR_NAME,
DOB,
ORDER_MODE,
PARENT,
ITEM
)F';
set @INDEX = 'CREATE NONCLUSTERED INDEX IX_1 ON #STG_TABLE (COMPANY, 
BRAND,
UNIT,
STR_NAME,
DOB,
CHECKID,
ORD_ID,
ORD_NAME,
PARENT,
ITEM)';


END
--if @SourceTblDate <> @MAX_date
if (select count(1) from [EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL]) > 0
BEGIN
set @queryStgTBL = CONCAT('insert into #STG_TABLE  ', REPLACE(@queryStgTBL, '1=1',CONCAT( ' GT.DOB > ''', @MAX_date,''' ')));
EXECUTE ( @queryStgTBL);
EXECUTE ( @INDEX);
set @query = CONCAT('insert into #EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL  ',@query);
EXECUTE ( @query);

MERGE [EDSS].dbo.[EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL] AS T
USING #EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL AS S
ON (     S.[BRAND]=T.[BRAND]
     and S.[STORE_ID]=T.[STORE_ID]
     and S.[DOB]=T.[DOB]
     and S.[ORDER_MODE]=T.[ORDER_MODE]
	 and S.PARENT = T.PARENT
	 and S.ITEM = T.ITEM)
WHEN MATCHED 
   THEN UPDATE 
   SET T.[COMPANY]=S.[COMPANY]
      ,T.[BRAND]=S.[BRAND]
      ,T.[STORE_ID]=S.[STORE_ID]
      ,T.[DOB]=S.[DOB]
	  ,T.[STR_NAME]=S.[STR_NAME]
      ,T.[ORDER_MODE]=S.[ORDER_MODE]
      ,T.[TOTAL_IDEAL_COST]=S.[TOTAL_IDEAL_COST]
      ,T.[NET_TOTAL]=S.[NET_TOTAL]
      ,T.[TOTAL]=S.[TOTAL]
      ,T.[IDEAL%]=S.[IDEAL%]
	  ,T.[ITEM]=S.[ITEM]
	  ,T.[Parent]=S.[Parent]
WHEN NOT MATCHED 
   THEN INSERT values (
       S.[COMPANY]
      ,S.[BRAND]
      ,S.[STORE_ID]
      ,S.[DOB]
	  ,S.[STR_NAME]
      ,S.[ORDER_MODE]
      ,S.[TOTAL_IDEAL_COST]
      ,S.[NET_TOTAL]
      ,S.[TOTAL]
      ,S.[IDEAL%]
	  ,S.[ITEM]
	  ,S.[Parent]);

END
else
BEGIN
BEGIN -- DISABLE INDEX
ALTER INDEX [NonClusteredIndex-BRAND] ON [dbo].[EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL] DISABLE
ALTER INDEX  [NonClusteredIndex-DOB] ON [dbo].[EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL] DISABLE
ALTER INDEX  [NonClusteredIndex-STORE_ID] ON [dbo].[EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL] DISABLE
ALTER INDEX  [NonClusteredIndex-STORE_NAME] ON [dbo].[EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL] DISABLE
ALTER INDEX  [NonClusteredIndex-COMPANY] ON [dbo].[EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL] DISABLE
END
BEGIN -- Insert data IN
set @queryStgTBL= CONCAT('insert into #STG_TABLE  ', @queryStgTBL)
EXECUTE (@queryStgTBL);
EXECUTE ( @INDEX);
set @query = CONCAT('insert into [EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL]  ',@query);
EXECUTE ( @query);
END
BEGIN --REBUILD INDEX
ALTER INDEX [NonClusteredIndex-BRAND] ON [dbo].[EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL] REBUILD
ALTER INDEX  [NonClusteredIndex-DOB] ON [dbo].[EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL] REBUILD
ALTER INDEX  [NonClusteredIndex-STORE_ID] ON [dbo].[EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL] REBUILD
ALTER INDEX  [NonClusteredIndex-STORE_NAME] ON [dbo].[EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL] REBUILD
ALTER INDEX  [NonClusteredIndex-COMPANY] ON [dbo].[EDSS_SDM_PRODUCT_MIX_TOTAL_IDEAL_COST_TBL] REBUILD
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
