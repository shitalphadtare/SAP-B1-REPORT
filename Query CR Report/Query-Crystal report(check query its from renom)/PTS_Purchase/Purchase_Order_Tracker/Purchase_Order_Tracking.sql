--/*Parameter Area*/
--/* SELECT FROM [dbo].[OPDN] T0 */DECLARE @FromDate As Date/* WHERE */SET @FromDate = /* T0.DocDate */ '[%0]'
--/* SELECT FROM [dbo].[OPDN] T0 */DECLARE @ToDate As Date/* WHERE */SET @ToDate = /* T0.DocDate */ '[%1]'

--/* SELECT  FROM [dbo].[OCRD] T10 */DECLARE @CardType AS nVARCHAR (max)  /* WHERE  */SET    @CardType= /*  T10.CardType='S' */'[%2]' 

--/* SELECT FROM [dbo].[OITM] T11 */DECLARE @FromItem AS nVARCHAR (max)  /* WHERE */SET @FromItem = /* T11.ItemCode*/'[%4]' 
--/* SELECT FROM [dbo].[OITM] T11 */DECLARE @ToItem AS nVARCHAR (max)  /* WHERE */SET   @ToItem = /* T11.ItemCode*/'[%5]' 

--/* SELECT FROM [dbo].[OWHS] T12 */DECLARE @FromWhs AS nVARCHAR (max)  /* WHERE */SET @FromWhs = /* T12.WhsName*/'[%6]' 
--/* SELECT FROM [dbo].[OWHS] T12 */DECLARE @ToWhs AS nVARCHAR (max)  /* WHERE */SET @ToWhs = /* T12.WhsName*/'[%7]' 


Create View PTS_Purchase_Order_Tracker
as
SELECT 

PRQ.DocNum 'PI NO',
PRQ.DocDate 'PI Date',
PRQ.ReqDate 'PI Release  Date',
PQ1.ItemCode 'SAP NO',
PQ1.Dscription 'Description',
PQ1.unitMsr 'Unit',
PQ1.Quantity 'PI Qty',
PQ1.WhsCode 'PI WareHouse',
POR.DocNum 'PO No',
POR.CardName 'Vendor Name',
POR.DocDate 'PO date',
PR1.Quantity 'PO Qty',
POR.DocDueDate 'Delivery Date',
PDN.DocNum 'Grn No',
PN1.Quantity 'GRN Quantity',
PN1.WhsCode 'Warehouse',
(PQ1.Quantity-PN1.Quantity) 'DIFFRANCE QTY (PI QTY - GRN QTY)',
PRQ.Comments 'Remarks'
,OCRD.CardType

FROM 
PRQ1 PQ1 
INNER JOIN  OPRQ PRQ ON PQ1.DocEntry=PRQ.DocEntry
LEFT OUTER JOIN OWHS WHS ON PQ1.WHSCODE = WHS.WHSCODE 
LEFT OUTER JOIN OLCT LCT on PQ1.LocCode=LCT.Code
left outer join OCST CST On LCT.State=CST.Code and  LCT.Country=CST.country
LEFT OUTER JOIN PQT1 PT1 ON PT1.BaseEntry = PQ1.DocEntry AND PT1.BaseLine = PQ1.LineNum
LEFT OUTER JOIN OPQT PQ ON PQ1.DocEntry = PQ.DocEntry
LEFT OUTER JOIN POR1 PR1 ON PR1.BaseEntry=PQ1.Docentry AND PR1.BaseLine =PQ1.LineNum
LEFT OUTER JOIN OPOR POR ON PR1.DocEntry=POR.DocEntry
LEFT OUTER JOIN PDN1 PN1 on PR1.DocEntry=PN1.BaseEntry AND PN1.BaseLine=PR1.LineNum
LEFT OUTER JOIN OPDN PDN ON PN1.DocEntry=PDN.DocEntry
LEFT JOIN OCRD ON OCRD.CardCode=POR.CardCode

--WHERE  

--POR.DocDate >= @FromDate
--AND POR.DocDate <= @ToDate

--OR OCRD.CardType =  @CardType

----OR POR.CardCode >=select from OCRD
----AND POR.CardCode <=select CASE when SUBSTRING(@FromCardCode, 1, 1)= 'V' then (select  cardcode from OCRD where CardType='S' and CardCode=@FromCardCode) end  vend from OCRD

--OR PQ1.ItemCode >= @FromItem
--AND PQ1.ItemCode <= @ToItem

--OR PQ1.WhsCode >= @FromWhs
--AND PQ1.WhsCode <= @ToWhs