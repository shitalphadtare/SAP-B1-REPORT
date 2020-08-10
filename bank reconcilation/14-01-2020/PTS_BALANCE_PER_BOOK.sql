



create VIEW [dbo].[PTS_BALANCE_PER_BOOK]
AS


select 						
 account,Mthdate,refdate,(debit-credit)as Bal_Perbook,( select AcctName from OACT where Acctcode=account) 'Acctname' from jdt1							


							

GO


