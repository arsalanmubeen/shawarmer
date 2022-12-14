USE [SDM]
GO
/****** Object:  StoredProcedure [dbo].[ALL_SDM_HIST_ORDERS_TBL_SP]    Script Date: 1/26/2021 1:37:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE  [dbo].[ALL_SDM_HIST_ORDERS_TBL_SP]
	
AS
BEGIN
BEGIN TRY 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN -- region declaration
    DECLARE @MAX_date nvarchar(20),
	@GetDay int = 0 ,
	  @query nvarchar(max);

CREATE TABLE #ALL_SDM_HIST_ORDERS(
	[SDM_ORDER_ID] [numeric](20, 0) Primary Key,
	[Formated_SDM_DOB] [date] NULL,
	[SDM_DOB] [varchar](50) NULL,
	[SDM_ORDR_DOB] [varchar](50) NULL,
	[SDM_ORDR_STORE_DOB] [varchar](50) NULL,
	[SDM_ORDER_SOURCE] [numeric](8, 0) NULL,
	[ALOHA_CHECKNO] [numeric](8, 0) NULL,
	[ORDER_SOURCE] [varchar](100) NULL,
	[NewOrderSourceField] [varchar](1000) NULL,
	[eWallet_Recharge_Amount] [numeric](10, 2) NULL,
	[eWallet_Refund_Amount] [numeric](10, 2) NULL,
	[eWallet_CashBack_Amount] [numeric](10, 2) NULL,
	[Customer_Name] [varchar](101) NULL,
	[Customer_Mobile] [varchar](51) NULL,
	[HS_ORDER_ID] [varchar](1000) NULL,
	[IL_ORDER_ID] [varchar](1000) NOT NULL,
	[SYSTEM_USER_ORDER_ID] [varchar](1000) NULL,
	[UPDATED_TIME] [nvarchar](4000) NULL,
	[STORE] [varchar](72) NOT NULL,
	[STORE_NUM] [varchar](20) NULL,
	[SDM_PAYMENT_METHOD] [varchar](50) NOT NULL,
	[ORDR_PAYMENTMOTHOD] [varchar](50) NULL,
	[SDM_FIRST_AMOUNT] [numeric](14, 4) NULL,
	[SDM_LAST_AMOUNT] [numeric](14, 4) NULL,
	[ORDR_REMARKS] [varchar](2000) NULL,
	[STATUS_NAME] [varchar](100) NULL,
	[ORDR_STATUS] [numeric](4, 0) NULL,
	[CREATION_TIME] [datetime] NULL,
	[SDM_OPEN_TIME] [datetime] NULL,
	[SDM_BUMP_TIME] [datetime] NULL,
	[SDM_CLOSE_TIME] [datetime] NULL)
END

BEGIN -- region assignment
set @GetDay = (SELECT [No_Days] FROM [Config_db].[dbo].[Decremental_Day_SP_Table] where ID =3);
    set @MAX_date  = DATEADD(day , @GetDay*(-1) , (select  max(cast(CREATION_TIME as date)) from ALL_SDM_HIST_ORDERS)) ;
	set @query ='    select   [SDM_ORDER_ID]
      ,[Formated_SDM_DOB]
      ,[SDM_DOB]
      ,[SDM_ORDR_DOB]
      ,[SDM_ORDR_STORE_DOB]
      ,[SDM_ORDER_SOURCE]
      ,[ALOHA_CHECKNO]
      ,[ORDER_SOURCE]
      ,[NewOrderSourceField]
      ,[eWallet_Recharge_Amount]
      ,[eWallet_Refund_Amount]
      ,[eWallet_CashBack_Amount]
      ,[Customer_Name]
      ,[Customer_Mobile]
      ,[HS_ORDER_ID]
      ,[IL_ORDER_ID]
      ,[SYSTEM_USER_ORDER_ID]
      ,[UPDATED_TIME]
      ,[STORE]
      ,[STORE_NUM]
      ,[SDM_PAYMENT_METHOD]
      ,[ORDR_PAYMENTMOTHOD]
      ,[SDM_FIRST_AMOUNT]
      ,[SDM_LAST_AMOUNT]
      ,[ORDR_REMARKS]
      ,[STATUS_NAME]
      ,[ORDR_STATUS]
      ,[CREATION_TIME]
      ,[SDM_OPEN_TIME]
      ,[SDM_BUMP_TIME]
      ,[SDM_CLOSE_TIME]
  FROM [192.168.200.12].[SDM].[dbo].[ALL_SDM_HIST_ORDERS]';
END
--if @SourceTblDate <> @MAX_date
if (select count(1) from ALL_SDM_HIST_ORDERS) > 0
BEGIN
set @query = CONCAT('INSERT INTO #ALL_SDM_HIST_ORDERS ',@query,'where cast(CREATION_TIME as date) > ''', @MAX_date,'''');
EXECUTE ( @query);

MERGE ALL_SDM_HIST_ORDERS AS T
USING #ALL_SDM_HIST_ORDERS AS S
ON (S.[SDM_ORDER_ID] = T.[SDM_ORDER_ID])
WHEN MATCHED 
   THEN UPDATE 
   SET  T.[SDM_ORDER_ID]=S.[SDM_ORDER_ID]
      ,T.[Formated_SDM_DOB]=S.[Formated_SDM_DOB]
      ,T.[SDM_DOB]=S.[SDM_DOB]
      ,T.[SDM_ORDR_DOB]=S.[SDM_ORDR_DOB]
      ,T.[SDM_ORDR_STORE_DOB]=S.[SDM_ORDR_STORE_DOB]
      ,T.[SDM_ORDER_SOURCE]=S.[SDM_ORDER_SOURCE]
      ,T.[ALOHA_CHECKNO]=S.[ALOHA_CHECKNO]
      ,T.[ORDER_SOURCE]=S.[ORDER_SOURCE]
      ,T.[NewOrderSourceField]=S.[NewOrderSourceField]
      ,T.[eWallet_Recharge_Amount]=S.[eWallet_Recharge_Amount]
      ,T.[eWallet_Refund_Amount]=S.[eWallet_Refund_Amount]
      ,T.[eWallet_CashBack_Amount]=S.[eWallet_CashBack_Amount]
      ,T.[Customer_Name]=S.[Customer_Name]
      ,T.[Customer_Mobile]=S.[Customer_Mobile]
      ,T.[HS_ORDER_ID]=S.[HS_ORDER_ID]
      ,T.[IL_ORDER_ID]=S.[IL_ORDER_ID]
      ,T.[SYSTEM_USER_ORDER_ID]=S.[SYSTEM_USER_ORDER_ID]
      ,T.[UPDATED_TIME]=S.[UPDATED_TIME]
      ,T.[STORE]=S.[STORE]
      ,T.[STORE_NUM]=S.[STORE_NUM]
      ,T.[SDM_PAYMENT_METHOD]=S.[SDM_PAYMENT_METHOD]
      ,T.[ORDR_PAYMENTMOTHOD]=S.[ORDR_PAYMENTMOTHOD]
      ,T.[SDM_FIRST_AMOUNT]=S.[SDM_FIRST_AMOUNT]
      ,T.[SDM_LAST_AMOUNT]=S.[SDM_LAST_AMOUNT]
      ,T.[ORDR_REMARKS]=S.[ORDR_REMARKS]
      ,T.[STATUS_NAME]=S.[STATUS_NAME]
      ,T.[ORDR_STATUS]=S.[ORDR_STATUS]
      ,T.[CREATION_TIME]=S.[CREATION_TIME]
      ,T.[SDM_OPEN_TIME]=S.[SDM_OPEN_TIME]
      ,T.[SDM_BUMP_TIME]=S.[SDM_BUMP_TIME]
      ,T.[SDM_CLOSE_TIME]=S.[SDM_CLOSE_TIME]
WHEN NOT MATCHED 
   THEN INSERT values (S.[SDM_ORDER_ID]
      ,S.[Formated_SDM_DOB]
      ,S.[SDM_DOB]
      ,S.[SDM_ORDR_DOB]
      ,S.[SDM_ORDR_STORE_DOB]
      ,S.[SDM_ORDER_SOURCE]
      ,S.[ALOHA_CHECKNO]
      ,S.[ORDER_SOURCE]
      ,S.[NewOrderSourceField]
      ,S.[eWallet_Recharge_Amount]
      ,S.[eWallet_Refund_Amount]
      ,S.[eWallet_CashBack_Amount]
      ,S.[Customer_Name]
      ,S.[Customer_Mobile]
      ,S.[HS_ORDER_ID]
      ,S.[IL_ORDER_ID]
      ,S.[SYSTEM_USER_ORDER_ID]
      ,S.[UPDATED_TIME]
      ,S.[STORE]
      ,S.[STORE_NUM]
      ,S.[SDM_PAYMENT_METHOD]
      ,S.[ORDR_PAYMENTMOTHOD]
      ,S.[SDM_FIRST_AMOUNT]
      ,S.[SDM_LAST_AMOUNT]
      ,S.[ORDR_REMARKS]
      ,S.[STATUS_NAME]
      ,S.[ORDR_STATUS]
      ,S.[CREATION_TIME]
      ,S.[SDM_OPEN_TIME]
      ,S.[SDM_BUMP_TIME]
      ,S.[SDM_CLOSE_TIME]);

END
else
BEGIN
BEGIN -- DISABLE INDEX
ALTER INDEX [NonClusteredIndex-ALOHA_CHECKNO] ON [dbo].ALL_SDM_HIST_ORDERS DISABLE
ALTER INDEX  [NonClusteredIndex-SDM_DOB] ON [dbo].ALL_SDM_HIST_ORDERS DISABLE
ALTER INDEX [NonClusteredIndex-STORE_NUM] ON [dbo].ALL_SDM_HIST_ORDERS DISABLE
ALTER INDEX  [NonClusteredIndex-SDM_ORDR_DOB] ON [dbo].ALL_SDM_HIST_ORDERS DISABLE
ALTER INDEX [NonClusteredIndex-SDM_ORDR_STORE_DOB] ON [dbo].ALL_SDM_HIST_ORDERS DISABLE
ALTER INDEX  [NonClusteredIndex-ORDR_REMARKS] ON [dbo].ALL_SDM_HIST_ORDERS DISABLE
END
BEGIN -- Insert data IN
EXECUTE ('INSERT INTO ALL_SDM_HIST_ORDERS ' + @query )
END
BEGIN --REBUILD INDEX
ALTER INDEX [NonClusteredIndex-ALOHA_CHECKNO] ON [dbo].ALL_SDM_HIST_ORDERS REBUILD
ALTER INDEX  [NonClusteredIndex-SDM_DOB] ON [dbo].ALL_SDM_HIST_ORDERS REBUILD
ALTER INDEX [NonClusteredIndex-STORE_NUM] ON [dbo].ALL_SDM_HIST_ORDERS REBUILD
ALTER INDEX  [NonClusteredIndex-SDM_ORDR_DOB] ON [dbo].ALL_SDM_HIST_ORDERS REBUILD
ALTER INDEX [NonClusteredIndex-SDM_ORDR_STORE_DOB] ON [dbo].ALL_SDM_HIST_ORDERS REBUILD
ALTER INDEX  [NonClusteredIndex-ORDR_REMARKS] ON [dbo].ALL_SDM_HIST_ORDERS REBUILD
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
