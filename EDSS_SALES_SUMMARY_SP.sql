USE [EDSS]
GO
/****** Object:  StoredProcedure [dbo].[EDSS_SALES_SUMMARY_SP]    Script Date: 1/26/2021 1:33:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[EDSS_SALES_SUMMARY_SP]
	
AS
BEGIN
BEGIN try
BEGIN -- region declaration
DECLARE @MAX_date datetime,
@GetDay int = 0,
	  @queryStgTBL nvarchar(max),
	  @query nvarchar(max),
	  @INDEX nvarchar(max);
	  set @GetDay = (SELECT [No_Days] FROM [Config_db].[dbo].[Decremental_Day_SP_Table] where ID =8);
set @MAX_date  = DATEADD(day , @GetDay*(-1) ,(select  max(DOB) from EDSS_SALES_SUMMAR_TBL)) ;

select * into #CR_STORE  FROM [192.168.0.5].[EDSS].[dbo].[CR_STORE];

CREATE NONCLUSTERED INDEX IX_12 ON #CR_STORE (STR_COMPANY,STR_BRAND,STR_NO);

select * into #CR_EMPLOYEE  FROM [192.168.0.5].[EDSS].[dbo].[CR_EMPLOYEE];

CREATE NONCLUSTERED INDEX IX_11 ON #CR_EMPLOYEE (EMP_ID,EMP_BRAND);

CREATE TABLE #EDSS_SALES_SUMMAR_TBL(
    [BRAND][int] NULL,
	[DOB] [datetime] NOT NULL,
	[STR_NO] [int] NULL,
	[STR_NAME] nvarchar(50) null,
	[CHECKID] [int] NULL,
[VAT] [float] NULL,
[NET_SALES] [float] NULL,
[SALES]  [float] NULL,
[EMPLOYEE] nvarchar(100) null,
[CHECK_COUNT] [float] NULL,
[ORDER_TIME] nvarchar(100) null
)

CREATE TABLE #STG_TABLE(
    [BRAND][int] NULL,
	[DOB] [datetime] NOT NULL,
	[CHECKID] [int] NULL,
	[AMOUNT] [float] NULL,
	[EMPLOYEE] [int] NULL,
	[FIRSTNAME] [nvarchar](35) NULL,
	[LASTNAME] [nvarchar](35) NULL,
	[CLOSEHOUR] [smallint] NULL,
	[CLOSEMIN] [smallint] NULL,
	[STR_NO] [int] NULL,
	[STR_NAME] [nvarchar](50) NULL,
	[STR_COMPANY] [int] NOT NULL,
	[COMPANY] [int] NOT NULL,
	[STR_BRAND] [int] NOT NULL,
	[STR_ID] [int] NOT NULL,
	[EMP_BRAND] [int] NULL,
	[EMP_ID] [int] NULL,
	[TYPE] [smallint] NULL
)

set @queryStgTBL = 'select BRAND,
DOB,CHECKID,AMOUNT,EMPLOYEE,FIRSTNAME,LASTNAME,CLOSEHOUR,CLOSEMIN,STR_NO,STR_NAME,STR_COMPANY,COMPANY,STR_BRAND,CR_GNDSALE.STR_ID,[EMP_BRAND],[EMP_ID],TYPE
FROM
	CR_GNDSALE INNER JOIN
	#CR_STORE ON STR_COMPANY = COMPANY AND STR_BRAND = BRAND AND STR_NO = CR_GNDSALE.STR_ID AND TYPE IN (33,31,11) AND 1=1
	LEFT JOIN #CR_EMPLOYEE ON BRAND= [EMP_BRAND] AND [EMP_ID]=EMPLOYEE';

set @INDEX = 'CREATE NONCLUSTERED INDEX IX_1 ON #STG_TABLE (BRAND,DOB,STR_NO,STR_NAME,CHECKID)';
	set @query = 'SELECT BRAND,
	DOB,
	STR_NO,
	STR_NAME,
	CHECKID,
	SUM(CASE TYPE WHEN 33 THEN AMOUNT ELSE 0 END) AS [VAT],
	SUM(CASE TYPE WHEN 31 THEN AMOUNT ELSE 0 END) AS [NET_SALES],
    SUM(CASE WHEN TYPE IN ( 31, 33) THEN AMOUNT ELSE 0 END) AS [SALES],
	MAX(CONCAT(EMPLOYEE,''-'',CONCAT(RTRIM(LTRIM(FIRSTNAME)),'' '',RTRIM(LTRIM(LASTNAME))))) AS [EMPLOYEE],
	SUM(CASE TYPE WHEN 11 THEN AMOUNT ELSE 0 END) AS CHECK_COUNT,
	CAST(MAX(CLOSEHOUR) AS  varchar(20)) + '' : '' + CAST(MAX(CLOSEMIN) AS varchar(20)) as [ORDER_TIME]
FROM
	#STG_TABLE
GROUP BY
    BRAND,
	DOB,
	STR_NO,
	STR_NAME,
	CHECKID ';
END

if (select count(1) from EDSS_SALES_SUMMAR_TBL) > 0
BEGIN
set @queryStgTBL = CONCAT('insert into #STG_TABLE  ', REPLACE(@queryStgTBL, '1=1',CONCAT( ' CR_GNDSALE.DOB > ''', @MAX_date,''' ')));
EXECUTE ( @queryStgTBL);
EXECUTE ( @INDEX);
set @query = CONCAT('insert into #EDSS_SALES_SUMMAR_TBL  ',@query);
EXECUTE ( @query);

MERGE EDSS_SALES_SUMMAR_TBL AS T
USING #EDSS_SALES_SUMMAR_TBL AS S
ON (     S.STR_NO=T.DOB
     and S.STR_NO=T.STR_NO
     and S.CHECKID=T.CHECKID
	 and S.BRAND=T.BRAND)
WHEN MATCHED 
   THEN UPDATE 
   SET T.[STR_NAME]=S.[STR_NAME]
      ,T.[VAT]=S.[VAT]
      ,T.[NET_SALES]=S.[NET_SALES]
	  ,T.[SALES]=S.[SALES]
      ,T.[EMPLOYEE]=S.[EMPLOYEE]
      ,T.[CHECK_COUNT]=S.[CHECK_COUNT]
      ,T.[ORDER_TIME]=S.[ORDER_TIME]
WHEN NOT MATCHED 
   THEN INSERT values (
      S.BRAND
      ,S.[DOB]
      ,S.[STR_NO]
      ,S.[STR_NAME]
      ,S.[CHECKID]
      ,S.[VAT]
      ,S.[NET_SALES]
	  ,S.[SALES]
      ,S.[EMPLOYEE]
      ,S.[CHECK_COUNT]
      ,S.[ORDER_TIME]);

END
else
BEGIN
BEGIN -- DISABLE INDEX
ALTER INDEX [NonClusteredIndex-BRAND] ON [dbo].EDSS_SALES_SUMMAR_TBL DISABLE
ALTER INDEX  [NonClusteredIndex-CHECKID] ON [dbo].EDSS_SALES_SUMMAR_TBL DISABLE
ALTER INDEX  [NonClusteredIndex-DOB] ON [dbo].EDSS_SALES_SUMMAR_TBL DISABLE
ALTER INDEX   [NonClusteredIndex-STR_NO]ON [dbo].EDSS_SALES_SUMMAR_TBL DISABLE
END
BEGIN -- Insert data IN
set @queryStgTBL= CONCAT('insert into #STG_TABLE  ', @queryStgTBL)
EXECUTE (@queryStgTBL);
EXECUTE ( @INDEX);
set @query = CONCAT('insert into EDSS_SALES_SUMMAR_TBL  ',@query);
EXECUTE ( @query);
END
BEGIN --REBUILD INDEX
ALTER INDEX [NonClusteredIndex-BRAND] ON [dbo].EDSS_SALES_SUMMAR_TBL REBUILD
ALTER INDEX  [NonClusteredIndex-CHECKID] ON [dbo].EDSS_SALES_SUMMAR_TBL REBUILD
ALTER INDEX  [NonClusteredIndex-DOB] ON [dbo].EDSS_SALES_SUMMAR_TBL REBUILD
ALTER INDEX   [NonClusteredIndex-STR_NO]ON [dbo].EDSS_SALES_SUMMAR_TBL REBUILD
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


