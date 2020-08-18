--/*Parameter Area*/
--/* SELECT FROM [dbo].[OINM] T0 */DECLARE @FromDate As Date/* WHERE */SET @FromDate = /* T0.DocDate */ '[%0]'
--/* SELECT FROM [dbo].[OINM] T0 */DECLARE @ToDate As Date/* WHERE */SET @ToDate = /* T0.DocDate */ '[%1]'
--/* SELECT FROM [dbo].[OITM] T1 */DECLARE @FromItem AS nVARCHAR (max)  /* WHERE */SET @FromItem = /* T1.ItemCode*/'[%4]' 
----/* SELECT FROM [dbo].[OITM] T1 */DECLARE @ToItem AS nVARCHAR (max)  /* WHERE */SET   @ToItem = /* T1.ItemCode*/'[%5]' 
--Create View PTS_Inventory_Report_ALLWhse
--as

with op as(select itemcode,Warehouse,docdate
,(sum(isnull(inqty,0))-SUM(isnull(outqty,0))) 'opQty'
,SUM(isnull(IN_Value,0))-SUM(isnull(Out_Value,0)) 'opvalue' from PTS_Inventory_Report
--where docdate<@FromDate 
--where docdate<'20190401' 
group by itemcode,Warehouse
),
Cal as(
select itemcode,b.Warehouse,b.docdate
      ,SUM(isnull(inqty,0)) 'inqty',SUM(ISNULL(outqty,0)) 'outqty'
      ,sum(IN_Value) 'IN_Value',SUM(Out_Value) 'Out_Value'


 from PTS_Inventory_Report B
--where docdate>=@FromDate and docdate<=@ToDate 

group by b.itemcode,b.Warehouse
)



select itm.itemcode,itw.WhsCode
,op.opQty,op.opvalue,
isnull(cal.inqty,0) 'inqty',isnull(cal.IN_Value,0) 'IN_Value',isnull(cal.outqty,0) 'outqty',isnull(cal.Out_Value,0) 'Out_Value'
,isnull(op.opQty,0)+isnull(cal.inqty,0)-isnull(cal.outqty,0) 'Total Qty'
,isnull(op.opvalue,0)+isnull(Cal.IN_Value,0)-isnull(cal.Out_Value,0) 'Total Value'
 from oitm itm
 left outer join oitw itw on itm.ItemCode=itw.ItemCode
 left outer join op on itm.ItemCode=op.ItemCode and op.Warehouse=itw.WhsCode
left outer join Cal on itm.itemcode=cal.itemcode and cal.Warehouse=itw.WhsCode
where  
--itm.ItemCode>=@FromItem and itm.ItemCode<=@ToItem and 
(isnull(op.opQty,0)+isnull(cal.inqty,0)-isnull(cal.outqty,0)<>0
or isnull(op.opvalue,0)+isnull(Cal.IN_Value,0)-isnull(cal.Out_Value,0)<>0)
--order by itemcode,docdate