


--Declare @TableGRGI table
--(
--DocDate datetime,
--DocType nvarchar(100),
--Docnum nvarchar(10),
--sapno nvarchar(100),
--itemname nvarchar(250),
--unit nvarchar(10),
--Qty float,
--batch nvarchar(50),
--srno nvarchar(50),
--BatchValuationType nvarchar(30),
--SerialValuationType nvarchar(30),
--price float,
--Total float,
--WhsCode nvarchar(50),
--location nvarchar(150),
--dia1 nvarchar(200),
--dia2 nvarchar(200),
--category nvarchar(200),
--Error_code nvarchar(200),
--Transaction_Id  nvarchar(200)
--)


--insert into  @TableGRGI 
--(
--DocDate ,DocType ,Docnum ,sapno,itemname ,unit,Qty ,batch,BatchValuationType,srno,SerialValuationType,price ,
--Total ,WhsCode ,location ,dia1 ,dia2,category,Error_code,Transaction_Id)

----------------------code for receipt----------
create view PTS_GOODS_CONSUMPTION_RECEIPT_WEC
AS

SELECT 
T1.[DocDate],
'Good Receipt' [Good Issue/Good Receipt],
T1.[DocNum], 
T0.[ItemCode] [SAP No], 
T0.[Dscription], 
T0.UnitMsr[Unit],
(case when ibt1.batchnum is not null then ibt1.Quantity
 when sri.DistNumber is not null then 1
 else
 T0.Quantity end)
 [Quantity],
ibt1.BatchNum[Batch],
case when ibt1.BatchNum is not null then T5.U_ValuationType end BatchValuationType,
sri.DistNumber[Sr No],
case when  sri.DistNumber is not null then sri.U_ValuationType end SerialValuationType,
T0.StockPrice [Unit Price],
(case when ibt1.batchnum is not null then ibt1.Quantity*T0.StockPrice
 when sri.DistNumber is not null then 1*T0.StockPrice
 else
  T0.Quantity*T0.StockPrice  end)
[Total Value],
T0.[WhsCode], 
OLCT.Location [Location],
T0.[OcrCode][COST CENTER 01], 
T0.[OcrCode2][COST CENTER 02] ,
Convert(nvarchar(250),(select DISTINCT Descr  from UFD1 where (FldValue IN(SELECT  U_category FROM dbo.oign WHERE(DocEntry =T1.DocEntry))) and FieldID=12 ) )  as 'Category',
error.name 'Error_code',
'' as [Transaction Id]

FROM OIGN T1 
left outer JOIN IGN1 T0 ON T0.[DocEntry] = T1.[DocEntry]
left Outer join [@REN_ERROR] error on error.code=t1.U_errorcode
INNER JOIN NNM1 T2 ON T1.Series = T2.Series
left outer join OLCT on OLCt.code=T0.LocCode
left join OIBT T5 on T5.ItemCode=T0.ItemCode 
left outer join (select * from ibt1)ibt1 on ibt1.BaseType=59 and  ibt1.baseentry=T1.Docentry and ibt1.ItemCode=T0.ItemCode  and ibt1.WhsCode=T0.WhsCode and ibt1.Baselinnum=T0.linenum
left outer  join 
(
select OSRN.DistNumber,OSRN.U_ValuationType,sri1.WhsCode,sri1.ItemCode,sri1.BaseEntry,sri1.BaseType,sri1.Baselinnum,
OSRN.SysNumber
 from sri1
inner join OSRN on OSRN.SysNumber=sri1.SysSerial and sri1.ItemCode=OSRN.itemcode)
sri on sri.BaseType=59 and sri.baseentry=T1.Docentry and sri.ItemCode=T0.ItemCode  and sri.WhsCode=T0.WhsCode and sri.Baselinnum=T0.linenum
--WHERE T1.DocDate >= @FromDate
--AND T1.DocDate <= @ToDate

union all
-------------------- code for issue---------------
SELECT 
T1.[DocDate],
'Good Issue' [Good Issue/Good Receipt],
T1.[DocNum], 
T0.[ItemCode] [SAP No], 
T0.[Dscription], 
T0.UnitMsr[Unit],
(case when ibt1.batchnum is not null then ibt1.Quantity
 when sri.DistNumber is not null then 1
 else
 T0.Quantity end)
 [Quantity],
ibt1.BatchNum[Batch],
case when ibt1.batchnum is not null then T5.U_ValuationType end BatchValuationType,
sri.DistNumber[Sr No],
case when  sri.DistNumber is not null then sri.U_ValuationType end SerialValuationType,
T0.StockPrice [Unit Price],
(case when ibt1.batchnum is not null then ibt1.Quantity*T0.StockPrice
 when sri.DistNumber is not null then 1*T0.StockPrice
 else
 T0.Quantity*T0.StockPrice end)
[Total Value],
T0.[WhsCode], 
OLCT.Location [Location],
T0.[OcrCode][COST CENTER 01], 
T0.[OcrCode2][COST CENTER 02] ,
Convert(nvarchar(250),(select DISTINCT Descr  from UFD1 where (FldValue IN(SELECT  U_category FROM dbo.oige WHERE(DocEntry =T1.DocEntry))) and FieldID=12 ) )  as 'Category',
error.name 'Error_code',
T1.[U_ConsId] as [Transaction Id]

FROM OIGE T1 
inner JOIN IGE1 T0 ON T0.[DocEntry] = T1.[DocEntry] and T0.ItemCode not in('L0001','L0002','L0004')
left Outer join [@REN_ERROR] error on error.code=t1.U_errorcode
INNER JOIN NNM1 T2 ON T1.Series = T2.Series
left outer join OLCT on OLCt.code=T0.LocCode
left join OIBT T5 on T5.ItemCode=T0.ItemCode
left outer join (select * from ibt1)ibt1 on ibt1.BaseType=60 and ibt1.baseentry=T1.Docentry and ibt1.ItemCode=T0.ItemCode  and ibt1.WhsCode=T0.WhsCode and ibt1.Baselinnum=T0.linenum
left outer  join
(
select OSRN.DistNumber,OSRN.U_ValuationType,sri1.WhsCode,sri1.ItemCode,sri1.BaseEntry,sri1.BaseType,sri1.Baselinnum,
OSRN.SysNumber
 from sri1
inner join OSRN on OSRN.SysNumber=sri1.SysSerial and sri1.ItemCode=OSRN.itemcode)
sri on sri.BaseType=60 and sri.baseentry=T1.Docentry and sri.ItemCode=T0.ItemCode  and sri.WhsCode=T0.WhsCode and sri.Baselinnum=T0.linenum
--WHERE T1.DocDate >= @FromDate
--AND T1.DocDate <= @ToDate
--select 
--DocDate ,DocType 'GOODS ISSUE / GOODS RECIPT' ,Docnum 'Doc No' ,sapno 'SAP NO',itemname 'Description' ,
--unit 'UNIT',Qty 'QTY' ,batch 'Batch',BatchValuationType 'BatchValuationType',srno 'SR NO',SerialValuationType 'SerialValuationType',price 'Unit Price' ,
--Total 'Total Value',WhsCode 'WHS CODE' ,location 'LOCATION',dia1 'COST CENTER 01',dia2 'COST CENTER 02'
--,Error_code,Category,Transaction_Id as [Transaction Id]
-- from @TableGRGI