Create View PTS_TDS_REGISTER
as
SELECT
T0.DocDate,
 cast(MONTH(T0.[DocDate]) as nvarchar(2))+'/'+cast(YEAR(T0.[DocDate]) as nvarchar(4))as 'Month',  T4.[WTName],OSEC.Code as Section ,OACT.AcctName as Particular,
T0.[CardCode]as BPCode,  T0.[CardName] as 'Party Name',T3.[TaxId0]as 'PAN No.', 
case when T5.[TypWTReprt] ='P' then 'Others' else   case when    T5.[TypWTReprt] = 'C' then 'Company'    end end  [Status], 
isnull(T0.[NumAtCard],'')+' - ' + cast(convert(date,T0.[TaxDate],103) as varchar) as 'Bill No & Date' , T0.[DocDate] EntryDate,T0.[DocNum] as 'A/P Num',
T0.[DocTotal]as 'Amount Debited to P&L',  T1.[TaxbleAmnt] as 'Amount Chargeable to TDS' , T1. [Rate] as 'TDS Rate', T1.[WTAmnt] as TDS ,T1.[WTCode] 
FROM OPCH T0   INNER JOIN PCH5 T1 ON T0.DocEntry = T1.AbsEntry  INNER JOIN PCH1 T2 ON T0.DocEntry = T2.DocEntry  
INNER JOIN PCH12 T3 ON T0.DocEntry = T3.DocEntry  INNER JOIN OWHT T4 ON T1.WTCode = T4.WTCode  
INNER JOIN OCRD T5 ON T0.CardCode = T5.CardCode LEFT JOIN OWHT on OWHT.WTCode=T1.WTCode      
LEFT JOIN OSEC on OSEC.AbsId=OWHT.Section left JOIN OACT on T2.AcctCode=OACT.AcctCode 
--where T0.[DocDate] >= [%0] and T0.[DocDate] <= [%1]