Alter View PTS_Fixed_Asset_Registers
as

select 'Invoice' as Type, I1.CardName as'Supplier Name'
,N1.SeriesName+'/'+CAST (I1.docNum as CHAR(20))  as 'Bill No'
,I1.DocDate 'Bill Date'
, I2.ItemCode as 'Asset Code'
,I2.Dscription as 'Asset Description'
,OITM.Assetclass as 'Types of Asset '
, I2.Quantity as 'Asset Quantity'
,I2.PriceBefDi as 'Rate'
,isnull(I2.LineTotal,0) as' Basic Value'
,isnull(IExDuty.IExDuty,0) 'Excise'
,isnull(ICST.ICST,0) 'CST/VAT' 
,isnull(I2.LineTotal,0)+isnull(IExDuty.IExDuty,0)+isnull(ICST.ICST,0) 'Total Value'
,isnull(Capital.LineTotal,0) 'Capitalization Value'
,Capital.PostDate 'Capitalization Date'
,(select (DprTypID) from ACS1 where DprAreaId=Capital.DprArea and Code=OITM.Assetclass ) 'Depriciation Type'
, null 'Depriciation Amount'
, isnull(Capital.LineTotal,0)'Net Book Asset'
from OPCH I1
inner join PCH1 I2 on I2.DocEntry=I1.DocEntry
inner join NNM1 N1 on N1.Series=I1.Series
inner join OITM on OITM.ItemCode=I2.ItemCode
left outer join(select PCH4.docentry, PCH4.LineNum, sum(isnull((PCH4.TaxSum),0)) as IExDuty 		
from PCH4 inner join ostt on PCH4.statype=ostt.absid where ostt.AbsId =-90   Group by PCH4.docentry, PCH4.LineNum	
) IExDuty  on I1.docentry=IExDuty.docentry and I2.LineNum=IExDuty.LineNum --and IExDuty.TaxType IN (-90) 
left outer join(select PCH4.docentry, PCH4.LineNum,  sum(isnull((PCH4.TaxSum),0)) as ICST		
from PCH4 inner join ostt on PCH4.statype=ostt.absid where ostt.AbsId in(1,4)    Group by PCH4.docentry,  PCH4.LineNum
) ICST  on I1.docentry=ICST.docentry and I2.LineNum=ICST.LineNum 
left Outer join (select A3.DprArea 'DprArea',A1.PostDate 'PostDate', A1.Pindicator 'Pindicator',A1.ObjType 'ObjType',A1.TransId 'TransId',A1.DocTotal'DocTotal',A1.TransType 'TransType',A1.CreatedBy 'CreatedBy',A1.DocType 'DocType',A1.BaseRef 'BaseRef',
A2.ItemCode 'ItemCode',A2.LineTotal 'LineTotal'
from OACQ A1
inner join ACQ1 A2 on A1.DocEntry=A2.DocEntry 
inner join ACQ2 A3 on A3.Docentry=A1.Docentry
where A1.DocType='PL' and A1.TransType=18)Capital on Capital.CreatedBy=I1.Docentry and Capital.ItemCode=I2.ItemCode
where OITM.ItemType ='F' and I1.canceled <> 'C' and I1.canceled <> 'Y' 
and --I1.DocDate>='[%0]' and I1.DocDate<='[%1]' and 
I2.Targettype<>19
union all
select 'Direct Capitalization' as Type,'' as'Supplier Name',O4.SeriesName+'/'+CAST (O1.docNum as CHAR(20))  as 'Bill No',
null as 'Bill Date',O2.ItemCode as 'Asset Code',
O3.ItemName as 'Asset Description',O3.Assetclass as 'Types of Asset'
,O2.Quantity as 'Asset Quantity',null as 'Rate',isnull(O2.LineTotal,0) as' Basic Value',
0 'Excise',0 'CST/VAT',isnull(O2.LineTotal,0)*O2.Quantity as 'Total Value',
isnull(O2.LineTotal,0) 'Capitalization Value',O1.PostDate 'Capitalization Date'
,(select (DprTypID) from ACS1 where DprAreaId=O2.DprArea and Code=O3.Assetclass ) 'Depriciation Type'
,0 'Depriciation Amount'
, isnull(O2.LineTotal,0)'Net Book Asset'
from OACQ O1 
inner join ACQ1 O2 on O1.DocEntry=O2.DocEntry
inner join OITM O3 on O2.ItemCode=O3.ItemCode
inner join NNM1 O4 on O1.Series=O4.Series and O4.ObjectCode='1470000049'
where 
O3.ItemType ='F' and 
--O1.DocDate>='[%0]' and O1.DocDate<='[%1]' and 
O1.TransType='1470000049'
group by O4.SeriesName,O1.docNum ,O2.ItemCode,O3.ItemName,O3.Assetclass,O2.Quantity,O2.LineTotal,O1.PostDate,O2.DprArea,O3.Assetclass
--order by I1.[Supplier Name]