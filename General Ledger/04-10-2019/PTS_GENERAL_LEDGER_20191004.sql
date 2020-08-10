
alter PROCEDURE [dbo].[PTS_GENERAL_LEDGER_20190211]

@Fromdate datetime
,@ToDate datetime
,@FromGLAcc nvarchar(100)
,@ToGLAcc nvarchar(100)
,@Narration bit
,@Print bit
,@ZeroBalance bit
,@NoPosting bit
,@Daily bit
,@Monthly bit
,@Yearly bit
,@Currency nvarchar(5)

as
 Begin
 
;with Query1 as(
select 
		act.AcctCode
		,CASE when act.Segment_0 <>'' then act.Segment_0 + '-' + act.Segment_1 else act.AcctCode  end 'AcctCode1'
		,act.AcctName
		,(CASE when act.ActCurr = 'INR' or act.ActCurr = '##'  then '(Local)' 
		else '(FC)' end ) 'Currency'
		,jdt.RefDate 'Date1'
		,(CASE when JT1.TransType = 46 then (case  when @Currency='LC' then isnull(JT1.Debit,0) else isnull(JT1.FCDebit,0) end )--Outgoing
			   when JT1.TransType = 24 then (case  when @Currency='LC' then isnull(JT1.Debit,0) else isnull(JT1.FCDebit,0) end )--Incoming
               when JT1.TransType = 13 then (case  when @Currency='LC' then isnull(JT1.Debit,0) else isnull(JT1.FCDebit,0) end )--A/R Invoice
               when JT1.TransType = 18 then (case  when @Currency='LC' then isnull(JT1.Debit,0) else isnull(JT1.FCDebit,0) end )--A/P Invoice
               when JT1.TransType = 14 then (case  when @Currency='LC' then isnull(JT1.Debit,0) else isnull(JT1.FCDebit,0) end )--A/R Credit Memo
               when JT1.TransType = 19 then (case  when @Currency='LC' then isnull(JT1.Debit,0) else isnull(JT1.FCDebit,0) end )--A/P Credit Memo
               else (case when @Currency='LC' then jt1.Debit else jt1.FCDebit end)
         End) 'Debit'
         		,(CASE when JT1.TransType = 46 then (case  when @Currency='LC' then isnull(JT1.Credit,0) else isnull(JT1.FCCredit,0) end )--Outgoing
			   when JT1.TransType = 24 then (case  when @Currency='LC' then isnull(JT1.Credit,0) else isnull(JT1.FCCredit,0) end )--Incoming
               when JT1.TransType = 13 then (case  when @Currency='LC' then isnull(JT1.Credit,0) else isnull(JT1.FCCredit,0) end )--A/R Invoice
               when JT1.TransType = 18 then (case  when @Currency='LC' then isnull(JT1.Credit,0) else isnull(JT1.FCCredit,0) end )--A/P Invoice
               when JT1.TransType = 14 then (case  when @Currency='LC' then isnull(JT1.Credit,0) else isnull(JT1.FCCredit,0) end )--A/R Credit Memo
               when JT1.TransType = 19 then (case  when @Currency='LC' then isnull(JT1.Credit,0) else isnull(JT1.FCCredit,0) end )--A/P Credit Memo
               else (case when @Currency='LC' then jt1.Credit else jt1.FCCredit end)
         End) 'Credit'
		,JT1.TransId 
		,JT1.TransType
		,(CASE when JT1.TransType = 46 then isnull(NM6.SeriesName,'')  + '/' + CAST (VPM.DocNum as CHAR) --Outgoing
			   when JT1.TransType = 24 then isnull(NM5.SeriesName,'')  + '/' + CAST (RCT.DocNum as CHAR) --Incoming
               when JT1.TransType = 13 then isnull(NM1.SeriesName,'')  + '/' + CAST(INV.DocNum as CHAR)--A/R Invoice
               when JT1.TransType = 18 then isnull(NM2.SeriesName,'')  + '/' + CAST(PCH.DocNum as CHAR)--A/P Invoice
               when JT1.TransType = 14 then isnull(NM3.SeriesName,'')  + '/' + CAST(RIN.DocNum as CHAR)--A/R Credit Memo
               when JT1.TransType = 19 then isnull(NM4.SeriesName,'')  + '/' + CAST(RPC.DocNum as CHAR)--A/P Credit Memo
               when JT1.TransType = 30 then isnull(NM7.SeriesName,'') + '/' + CAST(JDT.BaseRef as CHAR) 
               ELSE JDT.BaseRef--Journal Entry
         End) 'Document No' 
         ,(CASE when JT1.TransType = 46 then 'Outgoing Payment'
			   when JT1.TransType = 24 then 'Incoming Payment'
               when JT1.TransType = 13 then 'A/R Invoice'
               when JT1.TransType = 18 then 'A/P Invoice'
               when JT1.TransType = 14 then 'A/R Credit Memo'
               when JT1.TransType = 19 then 'A/P Credit Memo'
               when JT1.TransType = 30 then 'Manual JE'
               ELSE 'Other'
         End) 'Transction Name'  
			,case when jdt.TransType <> 30 then (CASE when act1.Segment_0 <> '' then act1.Segment_0 + '  - ' + act1.Segment_1 + ' ' + act1.AcctName 
       when act1.AcctCode IS null OR act1.AcctCode = '' and act1.Segment_0 IS NULL   then 
      (CASE when JT1.TransType = 46 then VPM.CardCode+'-'+VPM.CardName --Outgoing
			   when JT1.TransType = 24 then RCT.CardCode+'-'+RCT.CardName --Incoming
               when JT1.TransType = 13 then INV.CardCode+'-'+INV.CardName --A/R Invoice
               when JT1.TransType = 18 then PCH.CardCode+'-'+PCH.CardName --A/P Invoice
               when JT1.TransType = 14 then RIN.CardCode+'-'+RIN.CardName --A/R Credit Memo
               when JT1.TransType = 19 then RPC.CardCode+'-'+RPC.CardName --A/P Credit Memo
         End)
             else act1.AcctCode + ' - '+act1.AcctName   End)
             else jdt.Memo --Journal Entry
             end 'BP/GL Code'
             ,case when @Narration= 1 then
             (CASE when JT1.TransType = 46 then VPM.Comments --Outgoing
			   when JT1.TransType = 24 then RCT.Comments --Incoming
               when JT1.TransType = 13 then INV.Comments --A/R Invoice
               when JT1.TransType = 18 then PCH.Comments --A/P Invoice
               when JT1.TransType = 14 then RIN.Comments --A/R Credit Memo
               when JT1.TransType = 19 then RPC.Comments  --A/P Credit Memo
               else jdt.Memo
			  End) End 'Description 1' 
			  ,Case when JT1.Transtype in (46,24) then  
					('Ch No.' + cast ( (CASE when JT1.TransType = 46 then VM1.CheckNum  --outcoming Ch no
					when JT1.TransType = 24 then RT1.CheckNum End)as CHAR))  --incoming Ch No
					when JT1.TransType = 13 then INV.NumAtCard               --A/R Invoice Ref No
					when JT1.TransType = 18 then PCH.NumAtCard               --A/P Invoice Ref No
					when JT1.TransType = 14 then RIN.NumAtCard               --A/R Credit Memo Ref No
					when JT1.TransType = 19 then RPC.NumAtCard        --A/P Credit Memo Ref No
					End  'Cheque No/BP Ref'
					,jdt.RefDate 'Date2'
					,(CASE when RIGHT (LEFT (right(jdt.RefDate,23),5),1) = '' 
					       then '0' 
					       else RIGHT (LEFT (right(jdt.RefDate,23),5),1) end) + 
					 (CASE when RIGHT (LEFT (right(jdt.RefDate,23),6),1) = '' 
						   then '0' 
					       else RIGHT (LEFT (right(jdt.RefDate,23),6),1) end)  'Dt'
					,left( CONVERT(VARCHAR(10),jdt.RefDate,101),2) as 'Mnth'
					,RIGHT (LEFT (right(jdt.RefDate,23),12),5) 'yr1' 
					,OA.Name 'Segment'
from OACT ACT 
inner join JDT1 JT1 on JT1.Account = ACT.AcctCode 
left outer join OASC OA on act.Segment_1 = OA.Code
left outer join OACT act1 on JT1.ContraAct = act1.AcctCode
left outer join OJDT jdt on jt1.TransId=jdt.TransId
LEFT OUTER JOIN NNM1 NM7 ON JDT.Series=NM7.Series
----------AR INVOICE
left outer join OINV INV on inv.TransId=jt1.TransId
LEFT OUTER JOIN NNM1 NM1 ON INV.Series=NM1.Series
----------AP INVOICE
left outer join OPCH PCH ON PCH.TransId=JT1.TransId
LEFT OUTER JOIN NNM1 NM2 ON PCH.Series=NM2.Series
-----------AR CREDIT MEMO
LEFT OUTER JOIN ORIN RIN ON RIN.TransId=JT1.TransId
LEFT OUTER JOIN NNM1 NM3 ON NM3.Series=RIN.Series
----------AP CREDIT MEMO
left outer join ORPC RPC ON RPC.TransId=JT1.TransId
LEFT OUTER JOIN NNM1 NM4 ON NM4.Series=RPC.Series
---------INCOMING PAYMENT
LEFT OUTER JOIN ORCT RCT ON RCT.TransId=JT1.TransId
LEFT OUTER JOIN NNM1 NM5 ON NM5.Series=RCT.Series
left outer join (select CheckNum,DocNum from RCT1 ) RT1 on RT1.DocNum = RCT.DocEntry
---------OUTGOING PAYMENT
LEFT OUTER JOIN OVPM VPM ON VPM.TransId=JT1.TransId
LEFT OUTER JOIN NNM1 NM6 ON NM6.Series=VPM.Series
left outer join (select CheckNum,DocNum from VPM1 ) VM1 on VM1.DocNum = VPM.DocEntry

where
 jdt.RefDate >= @Fromdate
 and jdt.RefDate <= @ToDate
 --and OA.Name = @Segment
 and act.AcctName >= @FromGLAcc
 and act.AcctName <= @ToGLAcc
),
--------------------------------------------------------**************************-----------------------------------------------------
Query2 as(select 
CASE when T0.Segment_0 <>'' then T0.Segment_0 + '-' + T0.Segment_1 else T0.AcctCode  end 'AcctCode1',
sum(CASE when T2.RefDate < @Fromdate then isnull(T1.Debit,0) else 0 end)
- sum(CASE when T2.RefDate < @Fromdate
  then isnull(T1.Credit,0) else 0 end)'Opening Balance' 

  from OACT T0 
inner join JDT1 T1 on T1.Account = T0.AcctCode
inner join OJDT T2 on T1.TransId = T2.TransId 
 where T0.AcctName >= @FromGLAcc
 and T0.AcctName <= @ToGLAcc
 group by CASE when T0.Segment_0 <>'' then T0.Segment_0 + '-' + T0.Segment_1 else T0.AcctCode  end
)


-------------------------------------------------*******************************---------------------------------------------------
select * from 
Query1 C1
inner join Query2 C2 on C1.AcctCode1 = C2.AcctCode1
-------------------------------------------------*******************************---------------------------------------------------
union all

select distinct 
T0.AcctCode,CASE when T0.Segment_0 <>'' then T0.Segment_0 else T0.AcctCode  end 'AcctCode1',
T0.AcctName,(CASE when T0.ActCurr = 'INR' or T0.ActCurr = '##'  then '(Local)' 
 else '(FC)' end  ) 'Currency','',0,0,'','',null,null,'','','','','','','','','',T0.CurrTotal 
from OACT T0 
where T0.Postable = 'Y' and  T0.AcctCode not in (select distinct Account from JDT1 
inner join OACT on JDT1.Account = OACT.AcctCode
where JDT1.RefDate >= @Fromdate
 and JDT1.RefDate <= @ToDate
 and OACT.AcctName >= @FromGLAcc
 and OACT.AcctName <= @ToGLAcc )
  and T0.AcctName >=  @FromGLAcc
 and T0.AcctName <= @ToGLAcc

end 


GO


