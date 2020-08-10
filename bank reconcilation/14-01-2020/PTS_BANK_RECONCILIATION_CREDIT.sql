


alter PROCEDURE [dbo].[PTS_BANK_RECONCILIATION_CREDIT]
	-- Add the parameters for the stored procedure here
	
	
AS
BEGIN
--	-- SET NOCOUNT ON added to prevent extra result sets from
--	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select 							
jdt1.account,obnk.duedate as mthdate,							
jdt1.refdate,jdt1.transid,jdt1.Credit,							
jdt1.ref3line as 'chqNo',jdt1.Duedate as 'chqDate',jdt1.extrmatch,							
case when ovpm.Address is null or ovpm.Address='' then oact.acctname else ovpm.Address end acctname, 							
  ocrd.CardName  cardname
, (select AcctName from OACT	where Acctcode=	jdt1.account)  'Acountname'
,jdt1.Ref1 'Docnum'										
,crd.cardname	'Cheque Cardname'	
,JDT1.TRANSTYPE					
from jdt1							
left join oact  on jdt1.contraact = oact.acctcode							
left join ocrd  on jdt1.contraact = ocrd.cardcode							
left join obnk on obnk.acctcode=jdt1.account and obnk.bankmatch=jdt1.extrmatch							
left join  ojdt on jdt1.TransId=ojdt.TransId							
left join OVPM on ovpm.TransId=ojdt.TransId and ovpm.DocType='A'	
left join OCHH CHH on chh.TransNum=jdt1.TransId and cast(JDT1.Ref3Line as varchar)= cast(chh.CheckNum as varchar)
left outer join OCRD crd on crd.CardCode=chh.CardCode						
where jdt1.Credit<>0  order by jdt1.Duedate asc
END





GO


