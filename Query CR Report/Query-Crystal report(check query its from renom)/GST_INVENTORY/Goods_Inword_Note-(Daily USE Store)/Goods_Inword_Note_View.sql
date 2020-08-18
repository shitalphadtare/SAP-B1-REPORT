

Alter View PTS_Goods_Inword_Note
as 
SELECT  T0.[DocNum] as 'GRPO No',
T0.DocDate,
--T0.[CardCode] 'Vendor Code', 
T0.[CardName] 'Name of Vendor', 
T1.[ItemCode] 'SAP No', T1.[Dscription] 'Description',
T0.[DocDate] 'Inward Date', 
T0.[DocDate] 'Date of Invoice',  
T1.[Quantity] 'Inword Qty',
T1.[Price] 'Price After Discount',
t1.[WhsCode] 'Warehouse',
T1.[UseBaseUn] 'UOM',
T1.[LineTotal] 'Inword Value' FROM OPDN T0  INNER JOIN PDN1 T1 ON T0.[DocEntry] = T1.[DocEntry] WHERE T0.[Canceled] <>'Y' AND T0.[DocType]='I'
-- and T0.[DocStatus]<>'C'
