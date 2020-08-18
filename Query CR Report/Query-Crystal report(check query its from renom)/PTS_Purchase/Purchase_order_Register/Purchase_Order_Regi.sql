--/* SELECT FROM [dbo].[OPOR] T0 */DECLARE @FromDate As Date/* WHERE */SET @FromDate = /* T0.DocDate */ '[%0]'
--/* SELECT FROM [dbo].[OPOR] T0 */DECLARE @ToDate As Date/* WHERE */SET @ToDate = /* T0.DocDate */ '[%1]'

Create View PTS_Purchase_Order_Register
as
SELECT T0.[DocNum] as 'PO No', T0.[DocDate] as ' PO Date', 
--T0.[CardCode] as 'Vendor Code', 
T0.[CardName] as 'Vendor Name', 
--T0.[Project], 
T1.[ItemCode], T1.[Dscription] as 'Item Description', 
--T1.[U_Make], 
T1.[Quantity], T1.[Price], T1.[Currency], T1.[LineTotal] as 'Total', 
--T1.[Project], 
T1.[WhsCode],T2.[SlpName] as 'Buyer Name' FROM OPOR T0  INNER JOIN POR1 T1 ON T0.[DocEntry] = T1.[DocEntry] INNER JOIN OSLP T2 ON T0.[SlpCode] = T2.[SlpCode]

WHERE-- T0.DocDate >= @FromDate
--AND T0.DocDate <= @ToDate
--AND 
T0.[Canceled] <>'Y' 
--and T0.[DocStatus]<>'C'