alter Procedure Inventory_AGING 
@Todate Datetime,
@ITMGRP As varchar(28),
@Location As varchar(28),
@WhsName As varchar(28)
as begin
select B.ItemGroup,B.Warehouse,B.ItemCode,B.ItemName,round(B.Total_Stock,2) as Stock,round(B.Stockvalue,2)as StockValue,

case when ((B.BT3060INDEBIT+(B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) >= 0 Then round(B.LT30INDEBIT,2)
when ((B.BT3060INDEBIT+(B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY)))))< 0 AND (B.LT30INDEBIT+(B.BT3060INDEBIT+(B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) > 0
then round((B.LT30INDEBIT+(B.BT3060INDEBIT+(B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))),2) else 0 end 'Stock 30 days',

round((case when ((B.BT3060INDEBIT+(B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) >= 0 Then B.LT30INDEBIT
when ((B.BT3060INDEBIT+(B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY)))))< 0 AND (B.LT30INDEBIT+(B.BT3060INDEBIT+(B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) > 0
then (B.LT30INDEBIT+(B.BT3060INDEBIT+(B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) else 0 end )*(B.Stockvalue/B.Total_Stock),2) 'Stock 30 days Value',

case when (((B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) >= 0 Then round(B.BT3060INDEBIT,2)
when (((B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY)))))< 0 AND ((B.BT3060INDEBIT+(B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) > 0
then round(((B.BT3060INDEBIT+(B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))),2) else 0 end 'Stock 30 to 60 days',

round((case when (((B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) >= 0 Then B.BT3060INDEBIT
when (((B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY)))))< 0 AND ((B.BT3060INDEBIT+(B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) > 0
then ((B.BT3060INDEBIT+(B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) else 0 end) *(B.Stockvalue/B.Total_Stock),2) 'Stock 30 to 60 days Value', 



case when ((((B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) >= 0 Then round(B.BT6090INDEBIT,2)
when ((((B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY)))))< 0 AND (((B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) > 0
then round((((B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))),2) else 0 end 'Stock 60 to 90 days',

round((case when ((((B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) >= 0 Then B.BT6090INDEBIT
when ((((B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY)))))< 0 AND (((B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) > 0
then (((B.BT6090INDEBIT+(B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) else 0 end)* (B.Stockvalue/B.Total_Stock),2) 'Stock 60 to 90 days Value',

case when (((((B.GT120INDEBIT-B.OUTQTY))))) >= 0 Then round(B.BT90120INDEBIT,2)
when (((((B.GT120INDEBIT-B.OUTQTY)))))< 0 AND ((((B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) > 0
then round(((((B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))),2) else 0 end 'Stock 90 to 120 days',

round((case when (((((B.GT120INDEBIT-B.OUTQTY))))) >= 0 Then B.BT90120INDEBIT
when (((((B.GT120INDEBIT-B.OUTQTY)))))< 0 AND ((((B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) > 0
then ((((B.BT90120INDEBIT+(B.GT120INDEBIT-B.OUTQTY))))) else 0 end)*(B.Stockvalue/B.Total_Stock),2) 'Stock 90 to 120 days Value',

CASE WHEN (B.GT120INDEBIT- B.OUTQTY) >= 0 THEN round((B.GT120INDEBIT -  B.OUTQTY),2) ELSE 0 END 'Stock  120 days ',
round((CASE WHEN (B.GT120INDEBIT- B.OUTQTY) >= 0 THEN (B.GT120INDEBIT -  B.OUTQTY) ELSE 0 END)*(B.Stockvalue/B.Total_Stock),2) 'Stock  120 days Value '

from(select A.Warehouse,A.ItemGroup, A.ItemCode,A.ItemName,A.Total_Stock,A.Stockvalue,
A.LT30INDEBIT,A.BT3060INDEBIT,A.BT6090INDEBIT,A.BT90120INDEBIT,A.GT120INDEBIT,
A.LT30INVALUE,A.BT3060INVALUE,A.BT6090INVALUE,A.BT90120INVALUE,A.GT120INVALUE,
A.LT30OUTDEBIT+A.BT3060OUTDEBIT+A.BT6090OUTDEBIT+A.BT90120OUTDEBIT+A.GT120OUTDEBIT as OUTQTY,
A.LT30OUTVALUE+A.BT3060OUTVALUE+A.BT6090OUTVALUE+A.BT90120OUTVALUE+A.GT120OUTVALUE as OUTVALUE
from
(SELECT distinct  T0.WhsCode as Warehouse,T6.ItmsGrpNam as ItemGroup,T5.ItemCode,T1.ItemName,(select case when (cast(sum(InQty)as numeric(16,2))-cast(sum(OutQty)as numeric(16,2)))<0 then  (cast(sum(InQty)as numeric(16,2))-cast(sum(OutQty)as numeric(16,2)))*-1 else (cast(sum(InQty)as numeric(16,2))-cast(sum(OutQty)as numeric(16,2))) end from OIVL where ItemCode=T5.ItemCode and LocCode=T5.LocCode and DocDate<=@ToDate)Total_Stock,
--T0.OnHand as Total_Stock,
(select cast(sum(SumStock)as numeric(16,2)) from OIVL where ItemCode=T5.ItemCode and LocCode=T5.LocCode and DocDate<=@ToDate)as Stockvalue,

SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 30 AND T5.DOCDATE <= @ToDate THEN  isnull(T5.inqty, 0) else 0 end )LT30INDEBIT,
SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 30 AND T5.DOCDATE <= @ToDate AND  T5.SumStock > 0 THEN  isnull(SumStock, 0) else 0 end ) LT30INVALUE,
SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 30 AND T5.DOCDATE <= @ToDate AND  T5.SumStock < 0 THEN  isnull(SumStock, 0) else 0 end ) LT30OUTVALUE,
SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 30 AND T5.DOCDATE <= @ToDate THEN isnull(T5.OutQty, 0) else 0 end )LT30OUTDEBIT,

SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 30 AND  DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 60 AND T5.DOCDATE <= @ToDate THEN  isnull(T5.inqty, 0) else 0 end )BT3060INDEBIT,
SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 30 AND  DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 60 AND T5.DOCDATE <= @ToDate AND  T5.SumStock > 0 THEN  isnull(SumStock, 0) else 0 end ) BT3060INVALUE,
SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 30 AND  DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 60 AND T5.DOCDATE <= @ToDate AND  T5.SumStock < 0 THEN  isnull(SumStock, 0) else 0 end ) BT3060OUTVALUE,
SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 30 AND  DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 60 AND T5.DOCDATE <= @ToDate THEN  isnull(T5.OutQty, 0) else 0 end )BT3060OUTDEBIT,

SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 60 AND  DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 90 AND T5.DOCDATE <= @ToDate THEN  isnull(T5.inqty, 0) else 0 end )BT6090INDEBIT,
SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 60 AND  DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 90 AND T5.DOCDATE <= @ToDate AND  T5.SumStock > 0 THEN  isnull(SumStock, 0) else 0 end ) BT6090INVALUE,
SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 60 AND  DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 90 AND T5.DOCDATE <= @ToDate AND  T5.SumStock < 0 THEN  isnull(SumStock, 0) else 0 end ) BT6090OUTVALUE,
SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 60 AND  DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 90 AND T5.DOCDATE <= @ToDate THEN  isnull(T5.OutQty, 0) else 0 end )BT6090OUTDEBIT,

SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 90 AND  DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 120 AND T5.DOCDATE <= @ToDate THEN  isnull(T5.inqty, 0) else 0 end )BT90120INDEBIT,
SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 90 AND  DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 120 AND T5.DOCDATE <= @ToDate AND  T5.SumStock > 0 THEN  isnull(SumStock, 0) else 0 end ) BT90120INVALUE,
SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 90 AND  DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 120 AND T5.DOCDATE <= @ToDate AND  T5.SumStock < 0 THEN  isnull(SumStock, 0) else 0 end ) BT90120OUTVALUE,
SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 90 AND  DATEDIFF(DAY , T5.DOCDATE ,@ToDate) < 120 AND T5.DOCDATE <= @ToDate THEN  isnull(T5.OutQty, 0) else 0 end )BT90120OUTDEBIT,

SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 120 AND T5.DOCDATE <= @ToDate THEN  isnull(T5.inqty, 0) else 0 end )GT120INDEBIT,
SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 120  AND T5.DOCDATE <= @ToDate AND T5.SumStock > 0 THEN  isnull(SumStock, 0) else 0 end ) GT120INVALUE,
SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 120  AND T5.DOCDATE <= @ToDate AND T5.SumStock < 0 THEN  isnull(SumStock, 0) else 0 end ) GT120OUTVALUE,
SUM(CASE WHEN DATEDIFF(DAY , T5.DOCDATE ,@ToDate) >= 120 AND T5.DOCDATE <= @ToDate THEN  isnull(T5.OutQty, 0) else 0 end )GT120OUTDEBIT

from OITW T0
inner join OITM T1 on T0.ItemCode=T1.ItemCode
inner join OITB T6 on T1.ItmsGrpCod=T6.ItmsGrpCod
inner join OWHS T3 on T0.WhsCode=T3.WhsCode
inner join OLCT T4 on T3.Location=T4.Code
inner join OIVL T5 on T5.ItemCode=T0.ItemCode and T5.LocCode=T0.WhsCode
where T0.OnHand > 0 AND T6.ItmsGrpNam in (select case when  @ITMGRP=' ' then ItmsGrpNam else  @ITMGRP  end from OITB) and T4.Location=@Location  and  T3.WhsName in (select case when  @WhsName=' ' then WhsName else  @WhsName  end from OWHS)
group by T5.ItemCode,T1.ItemName,T5.LocCode,T0.WhsCode,T6.ItmsGrpNam 
)A)B
WHERE B.Total_Stock<> 0 and B.Total_Stock > 0
group by  B.Warehouse,B.ItemGroup, B.ItemCode,B.ItemName,B.Total_Stock,B.Stockvalue,B.LT30INDEBIT,B.BT3060INDEBIT,B.BT6090INDEBIT,B.BT90120INDEBIT,B.GT120INDEBIT,
B.BT3060INVALUE,B.BT6090INVALUE,B.LT30INVALUE,B.BT90120INVALUE,B.GT120INVALUE,B.OUTQTY,B.OUTVALUE
order by B.ItemGroup, B.Warehouse, B.ItemCode
end