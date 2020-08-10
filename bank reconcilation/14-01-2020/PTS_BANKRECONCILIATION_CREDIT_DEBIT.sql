



CREATE VIEW [dbo].[PTS_BANKRECONCILIATION_CREDIT_DEBIT]
AS

select 'Less: Amount debited in books but not credited by bank'as colum,							
 jdt1.account,obnk.duedate as mthdate,jdt1.refdate,debit as 'Add1'	,obnk.Acctname 'Acountname'						
 from jdt1							
left join obnk on obnk.acctcode=jdt1.account and obnk.bankmatch=jdt1.extrmatch							
 where debit<>0						
 							
union all							
							
select 'Add: Amount credited in books not debited by bank' as colum,							
jdt1.account,obnk.duedate as mthdate,jdt1.refdate, credit as 'Add1'	,obnk.Acctname 'Acountname'						
from jdt1							
left join obnk on obnk.acctcode=jdt1.account and obnk.bankmatch=jdt1.extrmatch							
 where credit<>0			
							

GO


