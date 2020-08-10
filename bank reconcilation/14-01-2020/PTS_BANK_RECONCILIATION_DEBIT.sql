
alter PROCEDURE [dbo].[PTS_BANK_RECONCILIATION_DEBIT]
	-- Add the parameters for the stored procedure here
	
	
AS
BEGIN

	SET NOCOUNT ON;


  select
jdt1.account,obnk.duedate as mthdate,							
jdt1.refdate,jdt1.transid,jdt1.debit,							
jdt1.ref3line as 'chqNo',jdt1.Duedate as 'chqDate',jdt1.extrmatch,							
CASE when  OVPM.Address is null OR OVPM.Address='' then oact.acctname else OVPM.Address end acctname, 							
 ocrd.CardName  'CardName',
  crd.cardname 'Cheque Cardname',
(select AcctName from OACT	where Acctcode=	jdt1.account) 	'Acountname',
jdt1.Ref1 'Docnum'	,jdt1.TransType							
from jdt1							
left join oact  on jdt1.contraact = oact.acctcode							
left join ocrd  on jdt1.contraact = ocrd.cardcode							
left join obnk on obnk.acctcode=jdt1.account and obnk.bankmatch=jdt1.extrmatch							
left join OJDT on jdt1.TransId=ojdt.TransId							
left join OVPM on OVPM.TransId=ojdt.TransId and OVPM.DocType='A'	
left join OCHH CHH on chh.TransNum=jdt1.TransId and cast(JDT1.Ref3Line as varchar)= cast(chh.CheckNum as varchar)						
left outer join OCRD crd on crd.CardCode=chh.CardCode	
where debit<>0 
order by jdt1.Duedate asc
END
GO


