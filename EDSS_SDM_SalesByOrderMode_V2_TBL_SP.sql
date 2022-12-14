USE [EDSS]
GO
/****** Object:  StoredProcedure [dbo].[EDSS_SDM_SalesByOrderMode_V2_TBL_SP]    Script Date: 1/26/2021 1:34:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[EDSS_SDM_SalesByOrderMode_V2_TBL_SP] 
	
AS
BEGIN
BEGIN try
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN -- region declaration
    DECLARE @MAX_date nvarchar(20),
	@SourceTblDate nvarchar(20),
	@GetDay int =0,
	  @query nvarchar(max);

	  CREATE TABLE #EDSS_SDM_SalesByOrderMode_V2_TBL(
	[REC_ID] [bigint] Primary Key,
	[STORE_ID] [int] NOT NULL,
	[COMPANY] [int] NULL,
	[BRAND] [int] NULL,
	[STORE_NAME] [nvarchar](50) NULL,
	[DOB] [datetime] NOT NULL,
	[CHECK_ID] [int] NULL,
	[ORDER_MODE] [nvarchar](100) NULL,
	[OPENHOUR] [smallint] NULL,
	[PAYMENT_METHOD] [nvarchar](20) NULL,
	[ORDER_MODE_AMOUNT] [float] NULL,
	[ORDER_MODE_NET_AMOUNT] [float] NULL,
	[SDM_FIRST_AMOUNT] [float] NULL,
	[SDM_FIRST_NET_AMOUNT] [float] NULL,
	[SDM_LAST_AMOUNT] [float] NULL,
	[SDM_LAST_NET_AMOUNT] [float] NULL,
	[AMOUNT_MISMATCH_REASON] [varchar](44) NOT NULL,
	[ORDER_TYPE] [varchar](4) NOT NULL,
	[EMPLOYEE] [nvarchar](84) NOT NULL,
	[ORDER_TIME] [varchar](41) NULL,
	[CUSTOMER_NAME] [varchar](101) NOT NULL,
	[CUSTOMER_PHONE_NUMBER] [varchar](51) NOT NULL,
	[STORE_FRIENDLY_NAME] [varchar](100) NOT NULL,
	[STORE_CITY_NAME] [varchar](100) NOT NULL,
	[STORE_LATITUDE] [varchar](100) NOT NULL,
	[STORE_LONGITUDE] [varchar](100) NOT NULL,
	[STORE_LOCATION] [varchar](201) NOT NULL,
	[SDM_ORDER_ID] [numeric](20, 0) NOT NULL,
	[ORDER_SOURCE] [varchar](100) NOT NULL,
	[SDM_ORDER_STATUS] [varchar](100) NOT NULL,
	[SYSTEM_USER_ORDER_ID] [varchar](1000) NOT NULL,
	[STORE_OPENING_DATE] [datetime] NULL,
	[Region] [varchar](50) NOT NULL,
	[eWallet_Recharge_Amount] [numeric](10, 2) NOT NULL,
	[eWallet_Refund_Amount] [numeric](10, 2) NOT NULL,
	[eWallet_CashBack_Amount] [numeric](10, 2) NOT NULL,
	[MOBILE_CREDIT_AMOUNT] [float] NULL,
	[CHANNEL] [varchar](8) NOT NULL);

select * into #CR_STORE from [192.168.0.5].[EDSS].[dbo].CR_STORE
CREATE NONCLUSTERED INDEX IX_3 ON #CR_STORE (STR_NO,STR_BRAND);

select * into #CR_ORDER_MODE from  [192.168.0.5].[EDSS].[dbo].[CR_ORDER_MODE]
CREATE NONCLUSTERED INDEX IX_5 ON #CR_ORDER_MODE ([ORD_ID],ORD_BRAND)

END

BEGIN -- region assignment
set @GetDay = (SELECT [No_Days] FROM [Config_db].[dbo].[Decremental_Day_SP_Table] where ID =6);
    set @MAX_date  = DATEADD(day , @GetDay*(-1) ,(select  max(DOB) from [EDSS_SDM_SalesByOrderMode_V2_TBL])) ;
--	set @SourceTblDate = (select  max(DOB) from CR_GNDITEMS) 
	set @query ='      SELECT 
GND.REC_ID,
GND.STR_ID STORE_ID,
STR_COMPANY AS COMPANY,
STR_BRAND AS BRAND,
STR_NAME AS STORE_NAME,
DOB DOB,
CHECKID CHECK_ID,
CASE WHEN convert(char(32),CHECKID) like ''8%'' AND ORDER_SOURCE IS NOT NULL
THEN LTRIM(RTRIM(isnull(ORDER_SOURCE,ORD_NAME))) COLLATE SQL_Latin1_General_CP1_CI_AS
WHEN ORD_ID in (8,13,16,17) THEN ''HungerStation''
WHEN ORD_ID in (10,11) THEN ''Wassel''
WHEN ORD_ID IN (15) THEN ''Ubereats'' 
WHEN ORD_ID =9 THEN ''Jahez''

ELSE 
LTRIM(RTRIM(ORD_NAME ))
END as ''ORDER_MODE'',

[OPENHOUR],

CASE when convert(char(32),CHECKID) like ''8%'' AND ORDER_SOURCE IS NOT NULL THEN 
(CASE WHEN SDM_ORDER_SOURCE = 1 AND (ORDR_PAYMENTMOTHOD IS NOT NULL) THEN ''CALLCENTER''
ELSE (SELECT TDRT_NAME FROM [192.168.0.5].EDSS.dbo.CR_TDRTYPE 
WHERE TDRT_BRAND = 1 AND TDRT_ID = (CASE WHEN ORDR_PAYMENTMOTHOD IS NULL AND SDM_ORDER_SOURCE =5 THEN 26 WHEN ((ORDR_PAYMENTMOTHOD IS NULL) OR (ORDR_PAYMENTMOTHOD=''Online'')) AND SDM_ORDER_SOURCE =2 THEN 21 
WHEN SDM_ORDER_SOURCE = 1 AND (ORDR_PAYMENTMOTHOD IS NULL) AND (( SELECT TOP 1 NT_ORDERID FROM [192.168.200.12].[SDM].[dbo].CC_HIST_ORDER_NOTE WHERE SDM_ORDER_ID = NT_ORDERID AND NT_FREE_TEXT like ''%HS_Order_ID%'') IS NOT NULL ) THEN 26
ELSE (SELECT case when PAY_STORE_TENDERID = 8 then PAY_SUB_TYPE else PAY_STORE_TENDERID end  FROM [192.168.200.12].[SDM].[dbo].CC_HIST_ORDER_PAYMENT WHERE PAY_ORDRID = SDM_ORDER_ID) END)) END) ELSE '''' END AS PAYMENT_METHOD,

(CASE WHEN DOB > ''2020-06-30'' THEN round((amount * 1.15),1) WHEN year(dob) > 2017 then round((amount * 1.05),1) else AMOUNT end) AS ORDER_MODE_AMOUNT,

AMOUNT  AS ORDER_MODE_NET_AMOUNT,

case when convert(char(32),CHECKID) like ''8%'' AND ORDER_SOURCE IS NOT NULL THEN SDM_FIRST_AMOUNT
ELSE(CASE WHEN DOB > ''2020-06-30'' THEN round((amount * 1.15),1) WHEN year(dob) > 2017 then round((amount * 1.05),1) else AMOUNT end) END AS SDM_FIRST_AMOUNT,

CASE WHEN convert(char(32),CHECKID) like ''8%'' AND ORDER_SOURCE IS NOT NULL 
THEN (CASE WHEN DOB > ''2020-06-30'' THEN (SDM_FIRST_AMOUNT - (round(((SDM_FIRST_AMOUNT/1.15)*0.15),2))) ELSE (SDM_FIRST_AMOUNT - (round(((SDM_FIRST_AMOUNT/1.05)*0.05),2))) END) ELSE AMOUNT END AS ''SDM_FIRST_NET_AMOUNT'',

CASE when convert(char(32),CHECKID) like ''8%'' AND ORDER_SOURCE IS NOT NULL THEN SDM_LAST_AMOUNT
ELSE (case WHEN DOB > ''2020-06-30'' THEN round((amount * 1.15),1) when year(dob) > 2017 then round((amount * 1.05),1) else AMOUNT end) END AS SDM_LAST_AMOUNT,

CASE when convert(char(32),CHECKID) like ''8%'' AND ORDER_SOURCE IS NOT NULL 
THEN  (CASE WHEN DOB > ''2020-06-30'' THEN (SDM_LAST_AMOUNT - (round(((SDM_LAST_AMOUNT/1.15)*0.15),2)))  ELSE (SDM_LAST_AMOUNT - (round(((SDM_LAST_AMOUNT/1.05)*0.05),2))) END)
ELSE AMOUNT END AS SDM_LAST_NET_AMOUNT,

CASE when convert(char(32),CHECKID) like ''8%'' AND ORDER_SOURCE IS NOT NULL THEN
(CASE WHEN SDM_FIRST_AMOUNT > SDM_LAST_AMOUNT THEN ''SOME ITEMS MIGHT BE VOIDED OR PRICE MISMATCH''
WHEN SDM_FIRST_AMOUNT < SDM_LAST_AMOUNT THEN ''SOME ITEMS MIGHT BE ADDED OR PRICE MISMATCH''
ELSE ''Equal'' END)
ELSE '''' END AS AMOUNT_MISMATCH_REASON,
CASE when convert(char(32),CHECKID) like ''8%'' THEN ''SDM'' ELSE ''EDSS'' END AS ORDER_TYPE,
(CONCAT(EMPLOYEE,''-'',CONCAT(RTRIM(LTRIM(FIRSTNAME)),'' '',RTRIM(LTRIM(LASTNAME))))) AS EMPLOYEE,
CAST((CLOSEHOUR) AS  varchar(20)) + '':'' + CAST((CLOSEMIN) AS varchar(20)) as ORDER_TIME,
isnull((odr.Customer_Name),'''') AS CUSTOMER_NAME,
isnull((odr.Customer_Mobile),'''') AS CUSTOMER_PHONE_NUMBER,
isnull((stores.Entry),'''') AS STORE_FRIENDLY_NAME,
isnull((stores.CityName),'''') AS STORE_CITY_NAME,
isnull((stores.Latitude),'''') AS STORE_LATITUDE,
isnull((stores.Longitude),'''') AS  STORE_LONGITUDE,
isnull((stores.Longitude + '','' + stores.Latitude),'''') AS  STORE_LOCATION,
ISNULL((SDM_ORDER_ID),0) AS SDM_ORDER_ID,
ISNULL((ORDER_SOURCE),'''') AS ORDER_SOURCE,
ISNULL((STATUS_NAME),'''') AS SDM_ORDER_STATUS,
ISNULL((SYSTEM_USER_ORDER_ID),'''') AS SYSTEM_USER_ORDER_ID,
(STR_OPENING_DATE)  as STORE_OPENING_DATE,
ISNULL((ProvinceName),'''') AS Region,
ISNULL(([eWallet_Recharge_Amount]),0.0) AS [eWallet_Recharge_Amount],
ISNULL(([eWallet_Refund_Amount]),0.0) AS [eWallet_Refund_Amount],
ISNULL(([eWallet_CashBack_Amount]),0.0) AS [eWallet_CashBack_Amount],
CASE WHEN SDM_ORDER_SOURCE = 2 THEN ((CASE WHEN DOB > ''2020-06-30'' THEN round((amount * 1.15),1) WHEN year(dob) > 2017 then round((amount * 1.05),1) else AMOUNT end)) - ((ISNULL(([eWallet_Recharge_Amount]),0.0)) + (ISNULL(([eWallet_Refund_Amount]),0.0)) + (ISNULL(([eWallet_CashBack_Amount]),0.0)))ELSE 0.0 END as MOBILE_CREDIT_AMOUNT,

CASE WHEN ORD_ID in (1,2,3,4,5,12,18) THEN ''IN-STORE''
ELSE ''DELIVERY'' END AS ''CHANNEL''
FROM dbo.CR_GNDSALE GND
LEFT JOIN 
#CR_STORE STORE ON STR_BRAND = GND.BRAND AND STR_NO = GND.STR_ID
left join
#CR_ORDER_MODE OMODE ON ORD_BRAND = 1 AND TYPEID = ORD_ID LEFT JOIN
	[192.168.0.5].[EDSS].dbo.CR_EMPLOYEE ON BRAND= [EMP_BRAND] AND [EMP_ID]=EMPLOYEE
  LEFT JOIN [192.168.200.12].[SDM].[dbo].[SDMStores] stores ON stores.StoreNumber = GND.STR_ID
  LEFT JOIN (select *,row_number() over(partition by SDM_DOB,STORE_NUM,ALOHA_CHECKNO order by [SDM_ORDER_ID] desc) as rn 
  from  [SDM].[dbo].[ALL_SDM_HIST_ORDERS]) odr ON odr.SDM_DOB = DOB AND ODR.STORE_NUM = GND.STR_ID AND odr.ALOHA_CHECKNO = CHECKID AND rn = 1
WHERE  GND.TYPE=31 AND STR_NO NOT IN (999,9999)
';
END
--if @SourceTblDate <> @MAX_date
if (select count(1) from [EDSS_SDM_SalesByOrderMode_V2_TBL]) > 0
BEGIN
set @query = CONCAT('INSERT INTO #EDSS_SDM_SalesByOrderMode_V2_TBL ',@query,'AND DOB > ''', @MAX_date,'''');
EXECUTE ( @query);

MERGE [EDSS_SDM_SalesByOrderMode_V2_TBL] AS T
USING #EDSS_SDM_SalesByOrderMode_V2_TBL AS S
ON (   S.[REC_ID] =T.[REC_ID]
)
WHEN MATCHED 
   THEN UPDATE 
   SET T.[STORE_ID]= S.[STORE_ID]
           , T.[COMPANY]           = S.[COMPANY]
           , T.[BRAND]           = S.[BRAND]
           , T.[STORE_NAME]           = S.[STORE_NAME]
           , T.[DOB]           = S.[DOB]
           , T.[CHECK_ID]           = S.[CHECK_ID]
           , T.[ORDER_MODE]           = S.[ORDER_MODE]
           , T.[OPENHOUR]           = S.[OPENHOUR]
           , T.[PAYMENT_METHOD]           = S.[PAYMENT_METHOD]
           , T.[ORDER_MODE_AMOUNT]           = S.[ORDER_MODE_AMOUNT]
           , T.[ORDER_MODE_NET_AMOUNT]           = S.[ORDER_MODE_NET_AMOUNT]
           , T.[SDM_FIRST_AMOUNT]           = S.[SDM_FIRST_AMOUNT]
           , T.[SDM_FIRST_NET_AMOUNT]           = S.[SDM_FIRST_NET_AMOUNT]
           , T.[SDM_LAST_AMOUNT]           = S.[SDM_LAST_AMOUNT]
           , T.[SDM_LAST_NET_AMOUNT]           = S.[SDM_LAST_NET_AMOUNT]
           , T.[AMOUNT_MISMATCH_REASON]           = S.[AMOUNT_MISMATCH_REASON]
           , T.[ORDER_TYPE]           = S.[ORDER_TYPE]
           , T.[EMPLOYEE]           = S.[EMPLOYEE]
           , T.[ORDER_TIME]           = S.[ORDER_TIME]
           , T.[CUSTOMER_NAME]           = S.[CUSTOMER_NAME]
           , T.[CUSTOMER_PHONE_NUMBER]           = S.[CUSTOMER_PHONE_NUMBER]
           , T.[STORE_FRIENDLY_NAME]           = S.[STORE_FRIENDLY_NAME]
           , T.[STORE_CITY_NAME]           = S.[STORE_CITY_NAME]
           , T.[STORE_LATITUDE]           = S.[STORE_LATITUDE]
           , T.[STORE_LONGITUDE]           = S.[STORE_LONGITUDE]
           , T.[STORE_LOCATION]           = S.[STORE_LOCATION]
           , T.[SDM_ORDER_ID]           = S.[SDM_ORDER_ID]
           , T.[ORDER_SOURCE]           = S.[ORDER_SOURCE]
           , T.[SDM_ORDER_STATUS]           = S.[SDM_ORDER_STATUS]
           , T.[SYSTEM_USER_ORDER_ID]           = S.[SYSTEM_USER_ORDER_ID]
           , T.[STORE_OPENING_DATE]           = S.[STORE_OPENING_DATE]
           , T.[Region]           = S.[Region]
           , T.[eWallet_Recharge_Amount]           = S.[eWallet_Recharge_Amount]
           , T.[eWallet_Refund_Amount]           = S.[eWallet_Refund_Amount]
           , T.[eWallet_CashBack_Amount]           = S.[eWallet_CashBack_Amount]
           , T.[MOBILE_CREDIT_AMOUNT]           = S.[MOBILE_CREDIT_AMOUNT]
           , T.[CHANNEL]           = S.[CHANNEL]


WHEN NOT MATCHED BY TARGET
   THEN INSERT values (
			 S.[REC_ID]
			,S.[STORE_ID]
           , S.[COMPANY]
           , S.[BRAND]
           , S.[STORE_NAME]
           , S.[DOB]
           , S.[CHECK_ID]
           , S.[ORDER_MODE]
           , S.[OPENHOUR]
           , S.[PAYMENT_METHOD]
           , S.[ORDER_MODE_AMOUNT]
           , S.[ORDER_MODE_NET_AMOUNT]
           , S.[SDM_FIRST_AMOUNT]
           , S.[SDM_FIRST_NET_AMOUNT]
           , S.[SDM_LAST_AMOUNT]
           , S.[SDM_LAST_NET_AMOUNT]
           , S.[AMOUNT_MISMATCH_REASON]
           , S.[ORDER_TYPE]
           , S.[EMPLOYEE]
           , S.[ORDER_TIME]
           , S.[CUSTOMER_NAME]
           , S.[CUSTOMER_PHONE_NUMBER]
           , S.[STORE_FRIENDLY_NAME]
           , S.[STORE_CITY_NAME]
           , S.[STORE_LATITUDE]
           , S.[STORE_LONGITUDE]
           , S.[STORE_LOCATION]
           , S.[SDM_ORDER_ID]
           , S.[ORDER_SOURCE]
           , S.[SDM_ORDER_STATUS]
           , S.[SYSTEM_USER_ORDER_ID]
           , S.[STORE_OPENING_DATE]
           , S.[Region]
           , S.[eWallet_Recharge_Amount]
           , S.[eWallet_Refund_Amount]
           , S.[eWallet_CashBack_Amount]
           , S.[MOBILE_CREDIT_AMOUNT]
           , S.[CHANNEL]

)
WHEN NOT MATCHED BY SOURCE AND T.[DOB] > cast(@MAX_date as date)
THEN DELETE ;

END
else
BEGIN

BEGIN -- DISABLE INDEX
ALTER INDEX [NonClusteredIndex-BRAND] ON [dbo].[EDSS_SDM_SalesByOrderMode_V2_TBL] DISABLE
ALTER INDEX  [NonClusteredIndex-DOB] ON [dbo].[EDSS_SDM_SalesByOrderMode_V2_TBL] DISABLE
ALTER INDEX  [NonClusteredIndex-STORE_ID] ON [dbo].[EDSS_SDM_SalesByOrderMode_V2_TBL] DISABLE
ALTER INDEX  [NonClusteredIndex-STORE_NAME] ON [dbo].[EDSS_SDM_SalesByOrderMode_V2_TBL] DISABLE
END

BEGIN -- Insert data IN

set @query = CONCAT('INSERT INTO EDSS_SDM_SalesByOrderMode_V2_TBL ',@query);
EXECUTE ( @query);

END

BEGIN --REBUILD INDEX
ALTER INDEX [NonClusteredIndex-BRAND] ON [dbo].[EDSS_SDM_SalesByOrderMode_V2_TBL] rebuild
ALTER INDEX  [NonClusteredIndex-DOB] ON [dbo].[EDSS_SDM_SalesByOrderMode_V2_TBL] rebuild
ALTER INDEX  [NonClusteredIndex-STORE_ID] ON [dbo].[EDSS_SDM_SalesByOrderMode_V2_TBL] rebuild
ALTER INDEX  [NonClusteredIndex-STORE_NAME] ON [dbo].[EDSS_SDM_SalesByOrderMode_V2_TBL] rebuild
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
