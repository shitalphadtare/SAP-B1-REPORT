Create View PTS__Open_Purchase_Order_ItemWise
as
select T0.CardCode [Supp Code],T0.CardName [Supplier], t0.NumAtCard [Supp Ref No], 
(select SlpName from OSLP t7 where t7.slpcode = t0.slpcode)as [Buyer], T0.Docentry, T1.SeriesName+'/'+cast( T0.docnum AS char(20)) [Order Doc Number], T0.Docdate [Doc Date],
T4.ItemCode,T4.Dscription, T0.doccur [Currency] ,T4.quantity as [Ordered Qty], T4.price [Unit Price],(T4.quantity*T4.price) as [Order Value], T0.DocDueDate [Order Due Date],
T4.openqty as [Pending Qty],(T4.openqty*T4.price) as [Pending Value]
from POR1 T4 
left join (select baseentry,baseline,itemcode,sum(quantity) as InvQty from PCH1 group by baseentry,baseline,itemcode) T6 
on T4.docentry=T6.baseentry and T4.itemcode=T6.itemcode and T4.linenum=T6.baseline
left join OPOR T0 on T4.docentry=T0.docentry
left join nnm1 T1 on T0.series=T1.series
left join OPCH T2 on T4.Trgetentry=T2.docentry
--left join (select docentry,sum(quantity) as SQty,sum(openqty) as PQty
--from POR1 group by docentry) T5 on T4.docentry=T5.docentry where T4.LineStatus = 'O' order by T4.itemcode
--FOR BROWSE