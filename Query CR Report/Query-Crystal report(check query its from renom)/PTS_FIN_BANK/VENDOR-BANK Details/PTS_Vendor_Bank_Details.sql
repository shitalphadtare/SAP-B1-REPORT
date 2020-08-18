
Create View PTS_Vendor_Bank_Details
as
SELECT
 T0.[CardCode], 
 T0.[CardName], T0.[BankCountr], 
 T0.[BankCode], T0.[DflAccount],
  T0.[DflSwift], T0.[DflBranch], 
  T0.[DflIBAN] FROM OCRD T0 
  WHERE T0.[CardType] ='S'