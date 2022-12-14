USE [EDSS]
GO
/****** Object:  StoredProcedure [dbo].[CR_GNDSALE_TBL_SP]    Script Date: 1/26/2021 1:32:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE  [dbo].[CR_GNDSALE_TBL_SP]
AS
BEGIN
BEGIN try
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN -- region declaration
    DECLARE @MAX_date nvarchar(20),	
	@GetDay int =0,
	  @query nvarchar(max);

CREATE TABLE #CR_GNDSALE(
	[REC_ID] [bigint] Primary Key,
	[COMPANY] [int] NOT NULL,
	[BRAND] [int] NOT NULL,
	[STR_ID] [int] NOT NULL,
	[DOB] [datetime] NOT NULL,
	[EMPLOYEE] [int] NULL,
	[CHECKID] [int] NULL,
	[PERIOD] [int] NULL,
	[TYPE] [smallint] NULL,
	[TYPEID] [int] NULL,
	[AMOUNT] [float] NULL,
	[OPENHOUR] [smallint] NULL,
	[OPENMIN] [smallint] NULL,
	[ORDERHOUR] [smallint] NULL,
	[ORDERMIN] [smallint] NULL,
	[CLOSEHOUR] [smallint] NULL,
	[CLOSEMIN] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[COUNT] [int] NULL,
	[REVENUE] [int] NULL,
	[TIPEMP] [int] NULL,
	[TYPEID2] [int] NULL,
	[OCCASION] [int] NULL,
	[REVID2] [int] NULL)
END

BEGIN -- region assignment
set @GetDay = (SELECT [No_Days] FROM [Config_db].[dbo].[Decremental_Day_SP_Table] where ID =5);
    set @MAX_date  = DATEADD(day , @GetDay*(-1) ,(select  max(DOB)  from CR_GNDSALE)) ;
	set @query ='       SELECT [REC_ID]
      ,[COMPANY]
      ,[BRAND]
      ,[STR_ID]
      ,[DOB]
      ,[EMPLOYEE]
      ,[CHECKID]
      ,[PERIOD]
      ,[TYPE]
      ,[TYPEID]
      ,[AMOUNT]
      ,[OPENHOUR]
      ,[OPENMIN]
      ,[ORDERHOUR]
      ,[ORDERMIN]
      ,[CLOSEHOUR]
      ,[CLOSEMIN]
      ,[SHIFT]
      ,[COUNT]
      ,[REVENUE]
      ,[TIPEMP]
      ,[TYPEID2]
      ,[OCCASION]
      ,[REVID2]
  FROM [192.168.0.5].[EDSS].[dbo].[CR_GNDSALE]';
END
--if @SourceTblDate <> @MAX_date
if (select count(1) from CR_GNDSALE) > 0
BEGIN
set @query = CONCAT('INSERT INTO #CR_GNDSALE ',@query,'where DOB  > cast(''', @MAX_date,''' as datetime)');
EXECUTE ( @query);

MERGE CR_GNDSALE AS T
USING #CR_GNDSALE AS S
ON (S.[REC_ID] = T.[REC_ID])
WHEN MATCHED 
   THEN UPDATE 
   SET T.[COMPANY]=S.[COMPANY]
      ,T.[BRAND]=S.[BRAND]
      ,T.[STR_ID]=S.[STR_ID]
      ,T.[DOB]=S.[DOB]
      ,T.[EMPLOYEE]=S.[EMPLOYEE]
      ,T.[CHECKID]=S.[CHECKID]
      ,T.[PERIOD]=S.[PERIOD]
      ,T.[TYPE]=S.[TYPE]
      ,T.[TYPEID]=S.[TYPEID]
      ,T.[AMOUNT]=S.[AMOUNT]
      ,T.[OPENHOUR]=S.[OPENHOUR]
      ,T.[OPENMIN]=S.[OPENMIN]
      ,T.[ORDERHOUR]=S.[ORDERHOUR]
      ,T.[ORDERMIN]=S.[ORDERMIN]
      ,T.[CLOSEHOUR]=S.[CLOSEHOUR]
      ,T.[CLOSEMIN]=S.[CLOSEMIN]
      ,T.[SHIFT]=S.[SHIFT]
      ,T.[COUNT]=S.[COUNT]
      ,T.[REVENUE]=S.[REVENUE]
      ,T.[TIPEMP]=S.[TIPEMP]
      ,T.[TYPEID2]=S.[TYPEID2]
      ,T.[OCCASION]=S.[OCCASION]
      ,T.[REVID2]=S.[REVID2]
WHEN NOT MATCHED by TARGET
   THEN INSERT values (S.[REC_ID]
      ,S.[COMPANY]
      ,S.[BRAND]
      ,S.[STR_ID]
      ,S.[DOB]
      ,S.[EMPLOYEE]
      ,S.[CHECKID]
      ,S.[PERIOD]
      ,S.[TYPE]
      ,S.[TYPEID]
      ,S.[AMOUNT]
      ,S.[OPENHOUR]
      ,S.[OPENMIN]
      ,S.[ORDERHOUR]
      ,S.[ORDERMIN]
      ,S.[CLOSEHOUR]
      ,S.[CLOSEMIN]
      ,S.[SHIFT]
      ,S.[COUNT]
      ,S.[REVENUE]
      ,S.[TIPEMP]
      ,S.[TYPEID2]
      ,S.[OCCASION]
      ,S.[REVID2])
WHEN NOT MATCHED BY SOURCE AND T.DOB > cast(@MAX_date as date)
THEN DELETE ;

END
else
BEGIN
BEGIN -- DISABLE INDEX
ALTER INDEX [NonClusteredIndex-COMPANY] ON [dbo].CR_GNDSALE DISABLE
ALTER INDEX  [NonClusteredIndex-BRAND] ON [dbo].CR_GNDSALE DISABLE
ALTER INDEX [NonClusteredIndex-STR_ID] ON [dbo].CR_GNDSALE DISABLE
ALTER INDEX  [NonClusteredIndex-DOB] ON [dbo].CR_GNDSALE DISABLE
END
BEGIN -- Insert data IN
EXECUTE ('INSERT INTO CR_GNDSALE ' + @query )
END
BEGIN --REBUILD INDEX
ALTER INDEX [NonClusteredIndex-COMPANY] ON [dbo].CR_GNDSALE REBUILD
ALTER INDEX  [NonClusteredIndex-BRAND] ON [dbo].CR_GNDSALE REBUILD
ALTER INDEX [NonClusteredIndex-STR_ID] ON [dbo].CR_GNDSALE REBUILD
ALTER INDEX  [NonClusteredIndex-DOB] ON [dbo].CR_GNDSALE REBUILD
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
