USE [EDSS]
GO
/****** Object:  StoredProcedure [dbo].[EDSS_VOIDS_SUMMARY_SP]    Script Date: 1/26/2021 1:36:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[EDSS_VOIDS_SUMMARY_SP]
	 
AS
BEGIN
BEGIN try
BEGIN -- region declaration
DECLARE @MAX_date datetime,
@GetDay int = 0,
	  @queryStgTBL nvarchar(max),
	  @query nvarchar(max),
	  @INDEX nvarchar(max);
	  set @GetDay = (SELECT [No_Days] FROM [Config_db].[dbo].[Decremental_Day_SP_Table] where ID =9);
set @MAX_date  = DATEADD(day , @GetDay*(-1) ,(select  max(VD_DATE) from EDSS_VOIDS_SUMMARY_TBL)) ;

select * into #CR_GNDVOID  FROM [192.168.0.5].[EDSS].[dbo].[CR_GNDVOID];
CREATE NONCLUSTERED INDEX IX_12 ON #CR_GNDVOID (VD_COMPANY,VD_BRAND,VD_REASON);
CREATE NONCLUSTERED INDEX IX_14 ON #CR_GNDVOID (VD_COMPANY,VD_BRAND,VD_ITEM);
CREATE NONCLUSTERED INDEX IX_15 ON #CR_GNDVOID (VD_BRAND,VD_DATE,VD_STR_ID,VD_CHECK);

select * into #CR_RSN  FROM [192.168.0.5].[EDSS].[dbo].[CR_RSN];
CREATE NONCLUSTERED INDEX IX_11 ON #CR_RSN (COMPANY,BRAND,ID);

select * into #CR_MENUITEM  FROM [192.168.0.5].[EDSS].[dbo].[CR_MENUITEM];
CREATE NONCLUSTERED INDEX IX_13 ON #CR_MENUITEM (MI_COMPANY,MI_BRAND,MI_ID);

CREATE TABLE #EDSS_VOIDS_SUMMARY_TBL(
	[VD_BRAND] [int] NOT NULL,
	[VD_DATE] [datetime] NOT NULL,
	[VD_STR_ID] [int] NOT NULL,
	[VD_CHECK] [int] NULL,
	[VD_REASON] [int] NULL,
	[VD_ITEM] [int] NULL,
	[ITEM_NAME] nvarchar(50) null,
	[VOID_REASON] nvarchar(15) null,	
	[VOID_AMOUNT] [float] NULL,
	[EMPLOYEE] [int] NULL,
	[VOID_TIME] varchar(15) null,
	[VD_HOUR] smallint null,
	[VD_MINUTE] smallint null,
	[COMPLETELY_VOIDED] nvarchar(15) null
)

CREATE TABLE #STG_TABLE(
	[VD_BRAND] [int] NOT NULL,
	[VD_DATE] [datetime] NOT NULL,
	[VD_STR_ID] [int] NOT NULL,
	[VD_CHECK] [int] NULL,
	[VD_REASON] [int] NULL,
	[VD_ITEM] [int] NULL,
	[MI_SHORTNAME] nvarchar(25) null,
	[NAME] nvarchar(15) null,
	[VD_PRICE] [float] NULL,
	[VD_EMPLOYEE] [int] NULL,
	[VD_HOUR] [smallint] NULL,
	[VD_MINUTE] [smallint] NULL,
    [CHECKID] [int] NULL
)

set @queryStgTBL = 'select A.VD_BRAND,A.VD_DATE,A.VD_STR_ID,A.VD_CHECK,A.VD_REASON,A.VD_ITEM,MI_SHORTNAME,NAME,A.VD_PRICE,A.VD_EMPLOYEE,A.VD_HOUR,A.VD_MINUTE,S.CHECKID
	FROM
	#CR_GNDVOID A LEFT JOIN 
	#CR_RSN ON COMPANY = A.VD_COMPANY AND BRAND = A.VD_BRAND AND ID = A.VD_REASON AND 1=1 LEFT JOIN
	#CR_MENUITEM ON MI_COMPANY = A.VD_COMPANY AND MI_BRAND = A.VD_BRAND AND MI_ID = A.VD_ITEM LEFT JOIN
	EDSS_SALES_SUMMAR_TBL S ON A.VD_BRAND = S.BRAND AND A.VD_DATE = S.DOB AND A.VD_STR_ID=S.[STR_NO] AND A.VD_CHECK = S.CHECKID';

set @INDEX = 'CREATE NONCLUSTERED INDEX IX_1 ON #STG_TABLE (VD_BRAND,VD_DATE,VD_STR_ID,VD_CHECK,VD_ITEM,VD_REASON,NAME)';

	set @query = 'SELECT 
    VD_BRAND,
	VD_DATE,
	VD_STR_ID,
	VD_CHECK,
	VD_REASON as VOID_REASON_ID,
	VD_ITEM,
	max(MI_SHORTNAME) ITEM_NAME,
	LTRIM(RTRIM(NAME)) AS VOID_REASON,
	SUM(VD_PRICE) AS VOID_AMOUNT,
	MAX(VD_EMPLOYEE) EMPLOYEE,
	CAST(MAX(VD_HOUR) AS  varchar(20)) + '':'' + CAST(MAX(VD_MINUTE) AS varchar(20)) as VOID_TIME,
	MAX(VD_HOUR) VD_HOUR,
	MAX(VD_MINUTE) VD_MINUTE,
	CASE WHEN ISNULL(MAX(CHECKID), 0) =0 THEN ''YES'' ELSE ''NO'' END AS [COMPLETELY_VOIDED] 

FROM
#STG_TABLE
GROUP BY
    VD_BRAND,
	VD_DATE,
	VD_STR_ID,
	VD_CHECK,
	VD_ITEM,
	VD_REASON,
	NAME';
END

if (select count(1) from EDSS_VOIDS_SUMMARY_TBL) > 0
BEGIN
set @queryStgTBL = CONCAT('insert into #STG_TABLE  ', REPLACE(@queryStgTBL, '1=1',CONCAT( ' VD_DATE > ''', @MAX_date,''' ')));
EXECUTE ( @queryStgTBL);
EXECUTE ( @INDEX);
set @query = CONCAT('insert into #EDSS_VOIDS_SUMMARY_TBL  ',@query);
EXECUTE ( @query);

MERGE EDSS_VOIDS_SUMMARY_TBL AS T
USING #EDSS_VOIDS_SUMMARY_TBL AS S
ON (     T.[VD_BRAND]=S.[VD_BRAND]
      and T.[VD_DATE]=S.[VD_DATE]
      and T.[VD_STR_ID]=S.[VD_STR_ID]
      and T.[VD_CHECK]=S.[VD_CHECK]
      and T.[VD_ITEM]=S.[VD_ITEM]
	  and T.[VD_REASON] =S.[VD_REASON])
WHEN MATCHED 
   THEN UPDATE 
   SET T.[VD_REASON]=S.[VD_REASON]
      ,T.[ITEM_NAME]=S.[ITEM_NAME]
      ,T.[VOID_REASON]=S.[VOID_REASON]
      ,T.[VOID_AMOUNT]=S.[VOID_AMOUNT]
      ,T.[EMPLOYEE]=S.[EMPLOYEE]
      ,T.[VOID_TIME]=S.[VOID_TIME]
      ,T.[VD_HOUR]=S.[VD_HOUR]
      ,T.[VD_MINUTE]=S.[VD_MINUTE]
      ,T.[COMPLETELY_VOIDED]=S.[COMPLETELY_VOIDED]
WHEN NOT MATCHED 
   THEN INSERT values (
      S.[VD_BRAND]
      ,S.[VD_DATE]
      ,S.[VD_STR_ID]
      ,S.[VD_CHECK]
      ,S.[VD_REASON]
      ,S.[VD_ITEM]
      ,S.[ITEM_NAME]
      ,S.[VOID_REASON]
      ,S.[VOID_AMOUNT]
      ,S.[EMPLOYEE]
      ,S.[VOID_TIME]
      ,S.[VD_HOUR]
      ,S.[VD_MINUTE]
      ,S.[COMPLETELY_VOIDED]);

END
else
BEGIN
BEGIN -- DISABLE INDEX
ALTER INDEX [NonClusteredIndex-VD_STR_ID] ON [dbo].EDSS_VOIDS_SUMMARY_TBL DISABLE
ALTER INDEX  [NonClusteredIndex-VD_DATE] ON [dbo].EDSS_VOIDS_SUMMARY_TBL DISABLE
ALTER INDEX  [NonClusteredIndex-VD_ITEM] ON [dbo].EDSS_VOIDS_SUMMARY_TBL DISABLE
END
BEGIN -- Insert data IN
set @queryStgTBL= CONCAT('insert into #STG_TABLE  ', @queryStgTBL)
EXECUTE (@queryStgTBL);
EXECUTE ( @INDEX);
set @query = CONCAT('insert into EDSS_VOIDS_SUMMARY_TBL  ',@query);
EXECUTE ( @query);
END
BEGIN --REBUILD INDEX
ALTER INDEX [NonClusteredIndex-VD_STR_ID] ON [dbo].EDSS_VOIDS_SUMMARY_TBL REBUILD
ALTER INDEX  [NonClusteredIndex-VD_DATE] ON [dbo].EDSS_VOIDS_SUMMARY_TBL REBUILD
ALTER INDEX  [NonClusteredIndex-VD_ITEM] ON [dbo].EDSS_VOIDS_SUMMARY_TBL REBUILD
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


