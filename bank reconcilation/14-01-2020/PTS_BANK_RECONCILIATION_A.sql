


create procedure [dbo].[PTS_BANK_RECONCILIATION_A]


(
@Date1 datetime,
@Bank nvarchar(500)
)AS
begin
select 		distinct			
 obnk.statemNo 'No', obnk.Acctcode as MthAcctCod,-- obnk.duedate as matchdate,					
0 totals,obnk.AcctName,					
dsc1.branch,dsc1.account,odsc.bankname					
from obnk					
left join omth on omth.MthAcctCod=obnk.acctcode					
left join dsc1 on obnk.Acctcode=dsc1.glaccount					
left join odsc on odsc.bankcode=dsc1.bankcode	
WHERE oBNK."DueDate"  <= @Date1  and  obnk."AcctName"=@Bank
							
end

GO


