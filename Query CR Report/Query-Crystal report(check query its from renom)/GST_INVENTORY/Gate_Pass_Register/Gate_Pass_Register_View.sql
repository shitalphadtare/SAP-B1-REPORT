--DECLARE @FROMDATE DATETIME
--DECLARE @TODATE DATETIME
--SET @FROMDATE = (SELECT MIN(S0.DOCDATE) FROM OWTR S0 WHERE S0.DOCDATE >= '[%0]')
--SET @TODATE = (SELECT MAX(S1.DOCDATE) FROM OWTR  S1 WHERE S1.DOCDATE <='[%1]')
Create View PTS_GATE_PASS_REGISTER
AS
Select * from (
select OWTR.DocNum as  'Gate Pass No',OWTR.DocDate as 'DocDate',WTR1.ItemCode as 'SAP No',WTR1.Dscription as 'Description',
WTR1.Quantity as 'Quantity',WTR1.stockprice as 'Value Per PC',isnull(WTR1.Quantity,0)*isnull(WTR1.stockprice,0) as 'Total Value',IBT1.BatchNum as 'BatchNum',
OWTR.Filler AS 'From Whs', WTR1.WhsCode AS 'To Whs'
FROM OWTR as OWTR INNER JOIN WTR1 ON OWTR.DocEntry=WTR1.DocEntry AND OWTR.DocEntry = WTR1.DocEntry 
left JOIN IBT1 ON  WTR1.ItemCode = IBT1.ItemCode and IBT1.BaseLinNum=wtr1.LineNum and IBT1.basetype=67
)as A
--where A.DocDate between @FromDate and @ToDate
--group by A.[Gate Pass No],A.[DocDate],A.[SAP No],A.[Description],A.[Quantity],A.[Value Per PC],A.[Total Value],A.[BatchNum],A.[From Whs],A.[To Whs]