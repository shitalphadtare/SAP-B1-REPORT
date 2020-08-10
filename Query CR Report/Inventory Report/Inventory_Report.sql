
Create procedure Inventory_Report 
 @Fromdate datetime ,
 @ToDate datetime 
 as begin
Select Warehouse as 'Warehouse', a.Itemcode, max(a.Dscription) as ItemName,
sum(a.OpeningBalance) as OpeningBalance, sum(a.INq) as 'IN', sum(a.OUT) as OUT,
((sum(a.OpeningBalance) + sum(a.INq)) - Sum(a.OUT)) as Closing ,
(Select i.InvntryUom from OITM i where i.ItemCode=a.Itemcode) as UOM
from( Select N1.Warehouse, N1.Itemcode, N1.Dscription, (sum(N1.inqty)-sum(n1.outqty))
as OpeningBalance, 0 as INq, 0 as OUT From dbo.OINM N1
Where N1.DocDate < @FromDate 
Group By N1.Warehouse,N1.ItemCode,
N1.Dscription Union All select N1.Warehouse, N1.Itemcode, N1.Dscription, 0 as OpeningBalance,
sum(N1.inqty) , 0 as OUT From dbo.OINM N1 Where N1.DocDate >= @FromDate and N1.DocDate <= @ToDate
and N1.Inqty >0 
Group By N1.Warehouse,N1.ItemCode,N1.Dscription
Union All select N1.Warehouse, N1.Itemcode, N1.Dscription, 0 as OpeningBalance, 0 , sum(N1.outqty) as OUT
From dbo.OINM N1 Where N1.DocDate >= @FromDate and N1.DocDate <=@ToDate and N1.OutQty > 0
Group By N1.Warehouse,N1.ItemCode,N1.Dscription) a, dbo.OITM I1
where a.ItemCode=I1.ItemCode
Group By a.Itemcode,warehouse
 Having sum(a.OpeningBalance) + sum(a.INq) + sum(a.OUT) > 0 Order By a.Itemcode
 end