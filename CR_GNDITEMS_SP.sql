USE [EDSS]
GO
/****** Object:  StoredProcedure [dbo].[CR_GNDITEMS_SP]    Script Date: 1/26/2021 1:31:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE  [dbo].[CR_GNDITEMS_SP]
	
AS
BEGIN
BEGIN TRY 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN -- region declaration
    DECLARE @MAX_date nvarchar(20),
	  @query nvarchar(max),
	  @GetDay int=0 ;

CREATE TABLE #CR_GNDITEMS(
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
	[QCID] [int] NULL)
END

BEGIN -- region assignment
set @GetDay = (SELECT [No_Days] FROM [Config_db].[dbo].[Decremental_Day_SP_Table] where ID =1);
    set @MAX_date  = DATEADD(day , @GetDay*(-1) , (select  max(DOB) from CR_GNDITEMS)) ;
	set @query ='       SELECT  [REC_ID]
      ,[COMPANY]
      ,[BRAND]
      ,[UNIT]
      ,[DOB]
      ,[TYPE]
      ,[EMPLOYEE]
      ,[CHECKID]
      ,[ITEM]
      ,[PARENT]
      ,[CATEGORY]
      ,[MODEID]
      ,[PERIOD]
      ,[HOUR]
      ,[MINUTE]
      ,[TAXID]
      ,[REVID]
      ,[TERMID]
      ,[MENU]
      ,[ORIGIN]
      ,[PRICE]
      ,[MODCODE]
      ,[SEAT]
      ,[ENTRYID]
      ,[OCCASION]
      ,[QUANTITY]
      ,[TAXID2]
      ,[DISCPRIC]
      ,[REVID2]
      ,[CONCEPT]
      ,[INCLTAX]
      ,[EXCLTAX]
      ,[COST]
      ,[QCID]
  FROM [192.168.0.5].[EDSS].[dbo].[CR_GNDITEM]';
END
--if @SourceTblDate <> @MAX_date
if (select count(1) from CR_GNDITEMS) > 0
BEGIN
set @query = CONCAT('INSERT INTO #CR_GNDITEMS ',@query,'where [DOB]  > cast (''', @MAX_date,''' as date)');
EXECUTE ( @query);

MERGE CR_GNDITEMS AS T
USING #CR_GNDITEMS AS S
ON (S.[REC_ID] = T.[REC_ID])
WHEN MATCHED 
   THEN UPDATE 
   SET   T.[COMPANY]=S.[COMPANY]
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
WHEN NOT MATCHED BY TARGET
   THEN INSERT values (S.[REC_ID] 
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
      ,S.[QCID])
WHEN NOT MATCHED BY SOURCE AND T.DOB > cast(@MAX_date as date)
THEN DELETE ;

END
else
BEGIN
BEGIN -- DISABLE INDEX
ALTER INDEX [NonClusteredIndex-BRAND] ON [dbo].CR_GNDITEMS DISABLE
ALTER INDEX   [NonClusteredIndex-CATEGORY]ON [dbo].CR_GNDITEMS DISABLE
ALTER INDEX [NonClusteredIndex-DOB] ON [dbo].CR_GNDITEMS DISABLE
ALTER INDEX  [NonClusteredIndex-ITEM] ON [dbo].CR_GNDITEMS DISABLE
ALTER INDEX   [NonClusteredIndex-PARENT]ON [dbo].CR_GNDITEMS DISABLE
END
BEGIN -- Insert data IN
EXECUTE ('INSERT INTO CR_GNDITEMS ' + @query )
END
BEGIN --REBUILD INDEX
ALTER INDEX [NonClusteredIndex-BRAND] ON [dbo].CR_GNDITEMS REBUILD
ALTER INDEX   [NonClusteredIndex-CATEGORY]ON [dbo].CR_GNDITEMS REBUILD
ALTER INDEX [NonClusteredIndex-DOB] ON [dbo].CR_GNDITEMS REBUILD
ALTER INDEX  [NonClusteredIndex-ITEM] ON [dbo].CR_GNDITEMS REBUILD
ALTER INDEX   [NonClusteredIndex-PARENT]ON [dbo].CR_GNDITEMS REBUILD
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
