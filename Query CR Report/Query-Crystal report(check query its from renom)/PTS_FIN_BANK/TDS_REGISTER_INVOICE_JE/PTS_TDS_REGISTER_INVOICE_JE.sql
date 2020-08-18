
CREATE VIEW PTS_TDS_REGISTER_INVOICE_JE
as
SELECT 
'INVOICE' as 'Category'
,cast(MONTH(T0.[DocDate]) as nvarchar(2))+'/'+cast(YEAR(T0.[DocDate]) as nvarchar(4))as 'Month',  T4.[WTName],OSEC.Code as Section ,OACT.AcctName as Particular,
T0.[CardCode]as BPCode,  T0.[CardName] as 'Party Name',T3.[TaxId0]as 'PAN No.', 
case when T5.[TypWTReprt] ='P' then 'Others' else   case when    T5.[TypWTReprt] = 'C' then 'Company'    end end  [Status], 
isnull(T0.[NumAtCard],'')+' - ' + cast(convert(date,T0.[TaxDate],103) as varchar) as 'Bill No & Date' , T0.[DocDate] EntryDate,T0.[DocNum] as 'A/P Num',
T2.[LineTotal]as 'Amount Debited to P&L',
(case when T1.BaseType='G' then (T2.LineVatS+T2.LineTotal) else T2.LineTotal end)  as 'Amount Chargeable to TDS' , 


T1. [Rate] as 'TDS Rate', 
(case when T1.BaseType='G' then Round ( (((T2.LineVatS+T2.LineTotal) *T1.Rate)/100),0) else Round( ((T2.LineTotal *T1.Rate)/100) ,0)end ) as TDS ,

T1.[WTCode] 
FROM OPCH T0   INNER JOIN PCH5 T1 ON T0.DocEntry = T1.AbsEntry  INNER JOIN PCH1 T2 ON T0.DocEntry = T2.DocEntry  
INNER JOIN PCH12 T3 ON T0.DocEntry = T3.DocEntry  INNER JOIN OWHT T4 ON T1.WTCode = T4.WTCode  
INNER JOIN OCRD T5 ON T0.CardCode = T5.CardCode LEFT JOIN OWHT on OWHT.WTCode=T1.WTCode      
LEFT JOIN OSEC on OSEC.AbsId=OWHT.Section left JOIN OACT on T2.AcctCode=OACT.AcctCode 
where --T0.[DocDate] >= [%0] and T0.[DocDate] <= [%1] AND 
T2.[WtLiable]='Y' and T0.canceled <> 'C' and T0.canceled <> 'Y'

union

SELECT 
'JE' as 'Category'
,cast(MONTH(T0.RefDate) as nvarchar(2))+'/'+cast(YEAR(T0.RefDate) as nvarchar(4))as 'Month'
,T2.FrgnName 'WTax Name'
,T2.PlngLevel 'Section'
,T2.Details 'Particular'
,T2.segment_0+'-'+T2.segment_1 'BPCode'
,T2.AcctName 'Party Name'
,'' 'PAN No'
,T2.ValidComm 'Status'
,cast(convert(date,T0.RefDate,103) as varchar) 'Bill No & Date'
,T0.RefDate 'Entry Date'
,T0.Number 'A/P Num'
,Cast (T1.Ref3Line as float) 'Amount Debited to P&L'
,Cast (T1.Ref3Line as float) 'Amount Chargeable to TDS'
,cast (T1.Ref1 as int) 'TDS Rate'
,CASE WHEN T1.Debit = 0 THEN T1.Credit ELSE T1.Debit END 'TDS'
,T1.Ref2 'WT Code'
--,T0.Transid

FROM OJDT T0
INNER JOIN JDT1 T1 ON T0.TransId = T1.TransId And T0.TransType = 30
INNER JOIN OACT T2 ON T2.AcctCode = T1.Account AND T2.FatherNum IN('25751000','11661100')
where 
T0.TransId not in (select stornoToTr from ojdt where  TransType = 30 And stornoToTr is not null or stornoToTr <> '')
and T0.TransId not in (select transid from ojdt where TransType = 30 And stornoToTr is not null or stornoToTr <> '')
--and  T0.RefDate >= [%0] and T0.RefDate <= [%1]