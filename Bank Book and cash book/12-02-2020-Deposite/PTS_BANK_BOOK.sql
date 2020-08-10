

ALTER PROCEDURE [dbo].[PTS_BANK_BOOK]


@Fromdate datetime
,@ToDate datetime
,@Bank nvarchar(max)
,@Narration bit
,@Cheque bit
,@Daily bit
,@Monthly bit
,@Yearly bit
,@Currency nvarchar(10)
 as
 Begin
;with Query1 as(
select
 T0.AcctCode
,T0.AcctName
, (CASE when T0.ActCurr = 'INR' or T0.ActCurr = '##'  then '(Local)' 
 else '(FC)' end  ) 'Currency'
,T2.RefDate 'Date1'
,(CASE when T2.TransType = 46 then (case  when  (@Currency = 'Local') then isnull(T1.Debit,0) else isnull(T1.FCDebit,0) end)--Outgoing
       when T2.TransType = 24 then (case  when (@Currency = 'Local') then  isnull(T1.Debit,0) else isnull(T1.FCDebit,0) end)--Incoming
       when T2.TransType = 30 then (case when (@Currency = 'Local') then  isnull(T1.Debit,0) else isnull(T1.FCDebit,0) end)--Journal Entry
	   when T2.TransType = 25 then (case when (@Currency = 'Local') then  isnull(T1.Debit,0) else isnull(T1.FCDebit,0) end)--Deposite -----0502
       end ) 'Debit'
,(CASE when T2.TransType = 46 then (CASE when (@Currency = 'Local') then ISNULL(T1.Credit,0) else ISNULL(T1.FCCredit,0)end)--Outgoing
       when T2.TransType = 24 then (CASE when (@Currency = 'Local') then ISNULL(T1.Credit,0) else ISNULL(T1.FCCredit,0)end)--Incoming
       when T2.TransType = 30 then (case when (@Currency = 'Local')then  isnull(T1.Credit,0) else isnull(T1.FCCredit,0) end)--Journal Entry
	   when T2.TransType = 25 then (case when (@Currency = 'Local')then  isnull(T1.Credit,0) else isnull(T1.FCCredit,0) end) --Deposite -----0502
       end ) 'Credit'
,T1.TransId 
,T2.TransType
,(CASE when T2.TransType = 46 then T5.SeriesName + '-'+ CAST (T4.DocNum as CHAR) --Outgoing
       when T2.TransType = 24 then T7.SeriesName + '-'+ CAST (T6.DocNum as CHAR) --Incoming
       when T2.TransType = 30 then T10.SeriesName + '-'+ CAST(T2.Number as CHAR) --Journal Entry
	   when T2.TransType=25 then nm1.seriesname+'-'+cast(dps.deposnum as char)--Deposite -----0502
        End) 'Document No' 
,(CASE when T2.TransType = 30 then 'Journal Entry' when T2.TransType = 140000009 then 'Outgoing Ex Invoice'
       when T2.TransType = 24 then 'Incoming Payment'
	    when t2.transtype=25 then 'Deposite' --Deposite -----0502
		 else 'Outgoing Payment' end ) 'Transction Name'  
,

(CASE when T2.TransType = 24 and  T6.DocType<>'A' then T6.CardName
when T2.TransType = 46 and  T4.DocType<>'A' then T4.CardName
when t2.transtype=25 then chh.cardname --Deposite -----0502
else
(CASE when T3.Segment_0 <> '' then T3.Segment_0 + '  - ' + T3.Segment_1 + ' ' + T3.AcctName 
       
       else T3.AcctCode + '' 
        End)
        end)'BP/GL Code'
        
,case when @Narration= 1 then (CASE when T2.TransType = 46 then T11.Descrip  --outcoming
       when T2.TransType = 24 then T12.Descrip  --incoming
       when T2.TransType = 30 then T2.Memo      --Journal Entry
       end )End 'Description 1' 
,case when @Narration= 1 then (CASE when T2.TransType = 46 then T4.Comments --outcoming
when t2.transtype=25 then rct.comments --Deposite -----0502
       when T2.TransType = 24 then T6.Comments end ) end 'Description 3'  --incoming
,  (case when @Cheque = 1 then 'Ch No.' + cast ( (CASE when T2.TransType = 46 then T8.CheckNum  --outcoming 
       when T2.TransType = 24 then T9.CheckNum 
	   when t2.TransType=25 then chh.checknum End)as CHAR) End)  'Description 2' --incoming
,(CASE when RIGHT (LEFT (right(T2.RefDate,23),5),1) = '' then '0' else RIGHT (LEFT (right(T2.RefDate,23),5),1) end) + 
(CASE when RIGHT (LEFT (right(T2.RefDate,23),6),1) = '' then '0' else RIGHT (LEFT (right(T2.RefDate,23),6),1) end)  'Dt'
,left( CONVERT(VARCHAR(10),T2.RefDate,101),2) as 'Mnth'
,RIGHT (LEFT (right(T2.RefDate,23),12),5) 'yr1'        
    ,(SELECT COUNT("Line_ID") FROM JDT1 WHERE "TransId" = t1."TransId") AS "Count"     
 from OACT T0       
inner join JDT1 T1 on T1.Account = T0.AcctCode 
left outer join OACT T3 on T1.ContraAct = T3.AcctCode

--Journal Entry
inner join OJDT T2 on T1.TransId = T2.TransId and T2.TransType in (30,140000009,24,46,25)
left outer join (Select W1.Series,W1.SeriesName,W2.TransId from NNM1 W1 
inner join OJDT W2 on W1.Series = W2.Series ) T10 on T10.Series = T2.Series  and T2.TransId = T10.TransId

--Outgoing Payment
left outer join OVPM T4 on T4.DocNum =(CASE when  T1.TransType = 46 then T1.BaseRef  else '' end) and T1.RefDate = T4.DocDate
left outer join (Select W1.Series,SeriesName,W2.DocNum from NNM1 W1 inner join OVPM W2 on W1.Series = W2.Series) T5 on T4.Series = T5.Series and T4.DocNum = T5.DocNum
left outer join (select CheckNum,DocNum from VPM1 ) T8 on T8.DocNum = T4.DocEntry
left outer join (select Descrip,DocNum,LineId from VPM4)T11 on T11.DocNum = T4.DocEntry and T11.LineId = 0

--Incoming Payment
left outer join ORCT T6 on T6.DocNum =(CASE when  T1.TransType = 24 then T1.BaseRef  else '' end) and T1.RefDate = T6.DocDate
left outer join (Select W1.Series,SeriesName,W2.DocNum from NNM1 W1 inner join ORCT W2 on W1.Series = W2.Series) T7 on T6.Series = T7.Series and T6.DocNum = T7.DocNum
left outer join (select CheckNum,DocNum from RCT1 ) T9 on T9.DocNum = T6.DocEntry
left outer join (select Descrip,DocNum,LineId from RCT4)T12 on T12.DocNum = T6.DocEntry and T12.LineId = 0

--Deposite changes on 05022020
left outer join ODPS dps on dps.transabs=t1.transid
left outer join NNM1 nm1 on dps.Series=nm1.Series
left outer join DPS1 DS1 on DS1.depositId=DPS.deposId and cast(t1.Ref3Line as varchar)=cast(DS1.CheckKey as varchar)
left outer join OCHH CHH on cast(chh.checkkey as varchar)=cast(ds1.checkkey as varchar) --chaNGES on 12022020
left outer join ORCT RCT on CHH.rcptNum=rct.docentry

where
 case when t2.transtype=25 then (select distinct Finanse from oact where AcctCode= t1.contraact) else T0.Finanse end = 'Y'
 and CASE WHEN T2.TransType=25 THEN (select distinct acctname from oact where AcctCode= t1.contraact) ELSE T0.AcctName END = @Bank -- Change for deposite 05022020
 and T2.RefDate >= @Fromdate 
 and T2.RefDate <= @ToDate

),
--------------------------------------------------------**************************-----------------------------------------------------
Query2 as(

select 
T0.AcctCode,
sum( 
 (case when @Currency = 'Local' then(CASE when T2.RefDate < @Fromdate then isnull(T1.Debit,0) else 0 end ) 
 else ( CASE when T2.RefDate < @Fromdate then isnull(T1.FCDebit,0) else 0 end  )
 end )
 )
- sum( 
   (case when @Currency = 'Local' then (CASE when T2.RefDate < @Fromdate  then isnull(T1.Credit,0) else 0 end)
    else ( CASE when T2.RefDate < @Fromdate  then isnull(T1.FCCredit,0) else 0 end)
     end)
)


'Opening Balance' 

  from OACT T0 
inner join JDT1 T1 on T1.Account = T0.AcctCode
left outer join oact t3 on t1.ContraAct=t3.acctcode --Deposite -----0502
inner join OJDT T2 on T1.TransId = T2.TransId


where
case when t1.transtype=25 then t3.finanse else T0.Finanse end= 'Y'
and case when t1.transtype=25 then t3.acctname else T0.AcctName end = @Bank
 group by T0.AcctCode )


-------------------------------------------------*******************************---------------------------------------------------

select *
 
from 

Query1 C1
inner join Query2 C2 on C1.AcctCode = C2.AcctCode

order by C1.Date1,C1.TransId asc
end



GO


