

CREATE VIEW [dbo].[PTS_BALANCE_PER_BANKTOTAL]
AS


select  obnk.AcctCode as 'Mthacctcod',obnk.dueDate as 'Matchdate',(obnk.CredAmnt-obnk.debAmount)as 'totals'	,obnk.AcctName						
from obnk							
Left Join omth on obnk.BankMatch=omth.MatchNum and obnk.acctcode = omth.mthacctcod							


							

GO


