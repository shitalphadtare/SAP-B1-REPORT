--DECLARE
--@StartDate DATETIME,
--@EndDate DATETIME,
--@Dummy INTEGER
--SELECT TOP 1 @Dummy = DocNum FROM  Oinv T0 WHERE T0.DocDate >= [%1] AND T0.DocDate <= [%2]
--SELECT
--@StartDate= '[%1]',
--@EndDate = '[%2]'


Alter View PTS_Sales_Register_Detailed
as 
Select * from (
SELECT T0.DocDate,
T0.Docentry, T0.DocNum as 'Bill No.',  CONVERT(VARCHAR(10), T0.DocDate, 3) AS 'Bill date', 
T0.CardName AS 'Customer Name' ,  T7.TaxId2 'VAT TIN',T7.TaxId1 'CST TIN', T1.Dscription AS 'Item Description', 
T1.Quantity, T1.Price AS 'Price', T1.TaxCode, T1.LineTotal AS 'Basic Line Total' ,
isnull(BED.TaxSum,0) AS 'BED',isnull(Cess.TaxSum,0) AS 'Cess',isnull(HeCess.TaxSum,0) AS 'HeCess',
isnull(VAT.TaxSum,0) AS 'VAT',isnull(CST.TaxSum,0) AS 'CST',
T0.Comments , C7.TaxId2 'Master VAT TIN', C7.TaxId1 'Master CST TIN'
FROM Oinv T0 
Left Join CRD7 C7 On T0.CardCode =C7.CardCode And T0.ShipToCode = C7.Address and C7.AddrType = 'S'
INNER JOIN inv1 T1 ON T0.DocEntry = T1.DocEntry 
INNER JOIN inv12 T7 ON T0.DocEntry = T7.DocEntry 
Left Join inv4 BED ON T1.DocEntry = BED.DocEntry And T1.LineNum = BED.LineNum And BED.StaType = -90 AND BED.ExpnsCode=-1 
Left Join inv4 Cess ON T1.DocEntry = Cess.DocEntry And T1.LineNum = Cess.LineNum And Cess.StaType = -60 AND Cess.ExpnsCode=-1
Left Join inv4 HeCess ON T1.DocEntry = HeCess.DocEntry And T1.LineNum = HeCess.LineNum And HeCess.StaType = -90 AND HeCess.ExpnsCode=-1 
Left Join inv4 VAT ON T1.DocEntry = VAT.DocEntry And T1.LineNum = VAT.LineNum And VAT.StaType = 1 AND VAT.ExpnsCode=-1
Left Join inv4 CST ON T1.DocEntry = CST.DocEntry And T1.LineNum = CST.LineNum And CST.StaType = 4 AND CST.ExpnsCode=-1 
--T0.DocDate >= @StartDate AND T0.DocDate <= @EndDate 
--AND 
WHERE T0.canceled = 'N' 
--AND T1.TargetType < > 14

Union all

SELECT 
 T0.DocDate,T0.Docentry, T0.DocNum as 'Bill No.',  CONVERT(VARCHAR(10), T0.DocDate, 3) AS 'Bill date', 
T0.CardName AS 'Customer Name' ,  T7.TaxId2 'VAT TIN',T7.TaxId1 'CST TIN', T4.ExpnsName  AS 'Item Description', 
Null, NUll AS 'Price', T3.TaxCode, T3.LineTotal AS 'Basic Line Total' ,
null AS 'BED',Null AS 'Cess',NUll AS 'HeCess',
isnull(VAT.TaxSum,0) AS 'VAT',isnull(CST.TaxSum,0) AS 'CST',
T0.Comments , C7.TaxId2 'Master VAT TIN', C7.TaxId1 'Master CST TIN'
FROM Oinv T0 
Left Join CRD7 C7 On T0.CardCode =C7.CardCode And T0.ShipToCode = C7.Address and C7.AddrType = 'S'
INNER JOIN inv3 T3 ON T0.DocEntry = T3.DocEntry 
INNER JOIN inv12 T7 ON T0.DocEntry = T7.DocEntry 
Inner Join  OEXD T4 On T3.ExpnsCode = T4.ExpnsCode
Left Join inv4 VAT ON T3.DocEntry = VAT.DocEntry And T3.ExpnsCode = VAT.ExpnsCode And VAT.StaType = 1 AND VAT.ExpnsCode<>-1
Left Join inv4 CST ON T3.DocEntry = CST.DocEntry And T3.ExpnsCode = CST.ExpnsCode And CST.StaType = 4 AND CST.ExpnsCode<>-1 
WHERE --T0.DocDate >= @StartDate AND T0.DocDate <= @EndDate AND
 T0.canceled = 'N' 
--AND T1.TargetType < > 14

union all


SELECT 
 T0.DocDate,T0.Docentry, T0.DocNum as 'Bill No.',  CONVERT(VARCHAR(10), T0.DocDate, 3) AS 'Bill date', 
T0.CardName AS 'Customer Name' , T7.TaxId2 'VAT TIN',T7.TaxId1 'CST TIN', T1.Dscription AS 'Item Description', 
T1.Quantity*-1, T1.Price*-1 AS 'Price', T1.TaxCode, T1.LineTotal*-1 AS 'Basic Line Total' ,
isnull(BED.TaxSum,0) AS 'BED',isnull(Cess.TaxSum,0) AS 'Cess',isnull(HeCess.TaxSum,0) AS 'HeCess',
isnull(VAT.TaxSum,0)*-1 AS 'VAT',isnull(CST.TaxSum,0)*-1 AS 'CST',
T0.Comments ,  C7.TaxId2 'Master VAT TIN',  C7.TaxId1 'Master CST TIN'
FROM Orin T0 
Left Join CRD7 C7 On T0.CardCode =C7.CardCode And T0.ShipToCode = C7.Address and C7.AddrType = 'S'
INNER JOIN rin1 T1 ON T0.DocEntry = T1.DocEntry 
INNER JOIN rin12 T7 ON T0.DocEntry = T7.DocEntry 
Left Join rin4 BED ON T1.DocEntry = BED.DocEntry And T1.LineNum = BED.LineNum And BED.StaType = -90 AND BED.ExpnsCode=-1 
Left Join rin4 Cess ON T1.DocEntry = Cess.DocEntry And T1.LineNum = Cess.LineNum And Cess.StaType = -60 AND Cess.ExpnsCode=-1
Left Join rin4 HeCess ON T1.DocEntry = HeCess.DocEntry And T1.LineNum = HeCess.LineNum And HeCess.StaType = -90 AND HeCess.ExpnsCode=-1 
Left Join rin4 VAT ON T1.DocEntry = VAT.DocEntry And T1.LineNum = VAT.LineNum And VAT.StaType = 1 AND VAT.ExpnsCode=-1
Left Join rin4 CST ON T1.DocEntry = CST.DocEntry And T1.LineNum = CST.LineNum And CST.StaType = 4 AND CST.ExpnsCode=-1 
WHERE --T0.DocDate >= @StartDate AND T0.DocDate <= @EndDate AND
 T0.canceled = 'N' 
--AND T1.TargetType < > 14

Union all

SELECT 
 T0.DocDate,T0.Docentry, T0.DocNum as 'Bill No.',  CONVERT(VARCHAR(10), T0.DocDate, 3) AS 'Bill date', 
T0.CardName AS 'Customer Name' ,  T7.TaxId2 'VAT TIN',T7.TaxId1 'CST TIN', T4.ExpnsName  AS 'Item Description', 
Null, NUll AS 'Price', T3.TaxCode, T3.LineTotal*-1 AS 'Basic Line Total' ,
null AS 'BED',Null AS 'Cess',NUll AS 'HeCess',
isnull(VAT.TaxSum,0)*-1 AS 'VAT',isnull(CST.TaxSum,0)*-1 AS 'CST',
T0.Comments, C7.TaxId2 'Master VAT TIN', C7.TaxId1 'Master CST TIN'
FROM Orin T0 
Left Join CRD7 C7 On T0.CardCode =C7.CardCode And T0.ShipToCode = C7.Address and C7.AddrType = 'S'
INNER JOIN rin3 T3 ON T0.DocEntry = T3.DocEntry 
INNER JOIN rin12 T7 ON T0.DocEntry = T7.DocEntry 
Inner Join  OEXD T4 On T3.ExpnsCode = T4.ExpnsCode
Left Join rin4 VAT ON T3.DocEntry = VAT.DocEntry And T3.ExpnsCode = VAT.ExpnsCode And VAT.StaType = 1 AND VAT.ExpnsCode<>-1
Left Join rin4 CST ON T3.DocEntry = CST.DocEntry And T3.ExpnsCode = CST.ExpnsCode And CST.StaType = 4 AND CST.ExpnsCode<>-1 
WHERE --T0.DocDate >= @StartDate AND T0.DocDate <= @EndDate AND
 T0.canceled = 'N' 
--AND T1.TargetType < > 14
) a 
--order by a.docentry