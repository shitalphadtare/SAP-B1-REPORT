Create View PTS_Purchase_Request_Register
as

SELECT 

T0.DocNum, 
T0.DocEntry,
T0.DocDate, 
T0.DocDueDate,
--TO_DATE(CURRENT_DATE, 'DDMMYYYY'), 
T0.ReqName, 
T0.Requester, 
T1.ItemCode, 
T1.Dscription, 
T1.Quantity, 
T1.OpenQty, 
T1.ShipDate, 
T1.WhsCode 

FROM 

OPRQ T0  INNER JOIN PRQ1 T1 ON T0.DocEntry = T1.DocEntry 

WHERE 
T1.OpenQty >0 
--and (T0.DocDate )=(ADD_DAYS (TO_DATE (CURRENT_DATE, 'DD-MM-YYYY'), -1))

--ORDER BY T0.[DocEntry]