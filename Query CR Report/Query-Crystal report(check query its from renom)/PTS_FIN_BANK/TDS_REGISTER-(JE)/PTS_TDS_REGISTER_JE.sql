cREATE vIEW PTS_TDS_REGISTER_JE
AS
SELECT 
cast(MONTH(T0.RefDate) as nvarchar(2))+'/'+cast(YEAR(T0.RefDate) as nvarchar(4))as 'Month'
,T2.FrgnName 'WTax Name'
,T2.ExportCode 'Section'
,T2.Details 'Particular'
,T2.segment_0+'-'+T2.segment_1 'BPCode'
,T2.AcctName 'Party Name'
,'' 'PAN No'
,T2.ValidComm 'Status'
,T0.RefDate 'Bill No & Date'
,T0.RefDate 'Entry Date'
,T0.Number 'A/P Num'
,T1.Ref3Line 'Amount Debited to P&L'
,T1.Ref3Line 'Amount Chargeable to TDS'
,T1.Ref1 'TDS Rate'
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