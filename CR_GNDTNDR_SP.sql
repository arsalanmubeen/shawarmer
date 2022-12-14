USE [EDSS]
GO
/****** Object:  StoredProcedure [dbo].[CR_GNDTNDR_SP]    Script Date: 1/26/2021 1:32:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE  [dbo].[CR_GNDTNDR_SP]
AS
BEGIN
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN -- region declaration
    DECLARE @MAX_date nvarchar(20),
	@GetDay int = 0,
	  @query nvarchar(max);

CREATE TABLE #CR_GNDTNDR(
[REC_ID] int Primary Key 
,[TDR_COMPANY] int null
,[TDR_BRAND] int null
,[TDR_STR_ID] int null
,[TDR_DOB] datetime null
,[TDR_EMPLOYEE] int null
,[TDR_CHECK] int null
,[TDR_TYPE] smallint null
,[TDR_TYPEID] int null
,[TDR_IDENT] nvarchar(20) null
,[TDR_AUTH] nvarchar(20) null
,[TDR_EXP] nvarchar(8) null
,[TDR_NAME] nvarchar(20) null
,[TDR_UNIT] nvarchar(4) null
,[TDR_AMOUNT] float null
,[TDR_TIP] float null
,[TDR_NR] float null
,[TDR_HOUSEID] int null
,[TDR_MANAGER] int null
,[TDR_HOUR] smallint null
,[TDR_MIN] smallint null
,[TDR_ID] int null)
END

BEGIN -- region assignment
set @GetDay = (SELECT [No_Days] FROM [Config_db].[dbo].[Decremental_Day_SP_Table] where ID =13);
    set @MAX_date  = DATEADD(day , @GetDay*(-1) ,(select  max(cast([TDR_DOB] as date)) from CR_GNDTNDR)) ;
	set @query ='       SELECT [REC_ID]
,[TDR_COMPANY]
,[TDR_BRAND]
,[TDR_STR_ID]
,[TDR_DOB]
,[TDR_EMPLOYEE]
,[TDR_CHECK]
,[TDR_TYPE]
,[TDR_TYPEID]
,[TDR_IDENT]
,[TDR_AUTH]
,[TDR_EXP]
,[TDR_NAME]
,[TDR_UNIT]
,[TDR_AMOUNT]
,[TDR_TIP]
,[TDR_NR]
,[TDR_HOUSEID]
,[TDR_MANAGER]
,[TDR_HOUR]
,[TDR_MIN]
,[TDR_ID]
  FROM [192.168.0.5].[EDSS].[dbo].[CR_GNDTNDR]';
END
--if @SourceTblDate <> @MAX_date
if (select count(1) from CR_GNDTNDR) > 0
BEGIN
set @query = CONCAT('INSERT INTO #CR_GNDTNDR ',@query,'where [TDR_DOB]  > cast(''', @MAX_date,''' as date )');
EXECUTE ( @query);

MERGE CR_GNDTNDR AS T
USING #CR_GNDTNDR AS S
ON ( T.[REC_ID]=S.[REC_ID])
WHEN MATCHED 
   THEN UPDATE 
   SET 
T.[TDR_COMPANY]=S.[TDR_COMPANY]
,T.[TDR_BRAND]=S.[TDR_BRAND]
,T.[TDR_STR_ID]=S.[TDR_STR_ID]
,T.[TDR_DOB]=S.[TDR_DOB]
,T.[TDR_EMPLOYEE]=S.[TDR_EMPLOYEE]
,T.[TDR_CHECK]=S.[TDR_CHECK]
,T.[TDR_TYPE]=S.[TDR_TYPE]
,T.[TDR_TYPEID]=S.[TDR_TYPEID]
,T.[TDR_IDENT]=S.[TDR_IDENT]
,T.[TDR_AUTH]=S.[TDR_AUTH]
,T.[TDR_EXP]=S.[TDR_EXP]
,T.[TDR_NAME]=S.[TDR_NAME]
,T.[TDR_UNIT]=S.[TDR_UNIT]
,T.[TDR_AMOUNT]=S.[TDR_AMOUNT]
,T.[TDR_TIP]=S.[TDR_TIP]
,T.[TDR_NR]=S.[TDR_NR]
,T.[TDR_HOUSEID]=S.[TDR_HOUSEID]
,T.[TDR_MANAGER]=S.[TDR_MANAGER]
,T.[TDR_HOUR]=S.[TDR_HOUR]
,T.[TDR_MIN]=S.[TDR_MIN]
,T.[TDR_ID]=S.[TDR_ID]
WHEN NOT MATCHED BY TARGET
   THEN INSERT values (S.[REC_ID]
,S.[TDR_COMPANY]
,S.[TDR_BRAND]
,S.[TDR_STR_ID]
,S.[TDR_DOB]
,S.[TDR_EMPLOYEE]
,S.[TDR_CHECK]
,S.[TDR_TYPE]
,S.[TDR_TYPEID]
,S.[TDR_IDENT]
,S.[TDR_AUTH]
,S.[TDR_EXP]
,S.[TDR_NAME]
,S.[TDR_UNIT]
,S.[TDR_AMOUNT]
,S.[TDR_TIP]
,S.[TDR_NR]
,S.[TDR_HOUSEID]
,S.[TDR_MANAGER]
,S.[TDR_HOUR]
,S.[TDR_MIN]
,S.[TDR_ID])
WHEN NOT MATCHED BY SOURCE AND T.[TDR_DOB] > cast(@MAX_date as date)
THEN DELETE ;

END
else
BEGIN
BEGIN -- DISABLE INDEX
ALTER INDEX [NonClusteredIndex-TDR_CHECK] ON [dbo].CR_GNDTNDR DISABLE
ALTER INDEX  [NonClusteredIndex-TDR_DOB] ON [dbo].CR_GNDTNDR DISABLE
ALTER INDEX [NonClusteredIndex-TDR_EMPLOYEE] ON [dbo].CR_GNDTNDR DISABLE
ALTER INDEX  [NonClusteredIndex-TDR_STR_ID] ON [dbo].CR_GNDTNDR DISABLE
ALTER INDEX [NonClusteredIndex-TDR_TYPE] ON [dbo].CR_GNDTNDR DISABLE
ALTER INDEX [NonClusteredIndex-TDR_TYPEID ]  ON [dbo].CR_GNDTNDR DISABLE
END
BEGIN -- Insert data IN
EXECUTE ('INSERT INTO CR_GNDTNDR ' + @query )
END
BEGIN --REBUILD INDEX
ALTER INDEX [NonClusteredIndex-TDR_CHECK] ON [dbo].CR_GNDTNDR REBUILD
ALTER INDEX  [NonClusteredIndex-TDR_DOB] ON [dbo].CR_GNDTNDR REBUILD
ALTER INDEX [NonClusteredIndex-TDR_EMPLOYEE] ON [dbo].CR_GNDTNDR REBUILD
ALTER INDEX  [NonClusteredIndex-TDR_STR_ID] ON [dbo].CR_GNDTNDR REBUILD
ALTER INDEX [NonClusteredIndex-TDR_TYPE] ON [dbo].CR_GNDTNDR REBUILD
ALTER INDEX  [NonClusteredIndex-TDR_TYPEID ] ON [dbo].CR_GNDTNDR REBUILD
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
