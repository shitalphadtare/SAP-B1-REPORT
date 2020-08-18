Create View PTS_Goods_Inword_Note_SupplierRating
as
SELECT 
T0.[DocNum], T0.[DocDate], 
T0.[CardCode], T0.[CardName],
T1.[ItemCode], T1.[Dscription],
T1.[Quantity] 
FROM OPDN T0  
INNER JOIN PDN1 T1 ON T0.[DocEntry] = T1.[DocEntry] 
WHERE T0.[Series] ='99' AND T0.[DocType] ='I'