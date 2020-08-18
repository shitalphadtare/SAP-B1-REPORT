
Alter View PTS_PCB_SERVICE_DETAIL
AS
select 
T0.DocNum 'Service Order Number',
T1.wareHouse 'Warehouse Code',
T0.StartDate 'Date Of Service',
T0.U_RepairBy 'Service By',
T0.ItemCode 'SAP Code',
T2.ItemName 'Description',
T6.DistNumber 'Item Serial No',
 case when T7.ItemCode ='L0001' then (T7.Quantity/T0.PlannedQty)*T7.Price else 0 end as 'Value',
--Sum(T7.Price) 'Value',
(T7.ItemCode) 'SAPS Code',
(T7.Dscription) 'Descriptions',
(T7.Quantity) /T0.PlannedQty as 'Quantity',
(T7.Price) 'Values',
(T7.Quantity/T0.PlannedQty)*T7.Price as 'Total Overall Value',
--Sum(T1.CompTotal) 'Total Overall Value',
T0.U_WECNO 'PCB Removed WEC',T0.Comments 'Remarks',
case when t0.status='L' then 'Closed' when t0.status='C' then 'Canceled' when t0.status ='R' then 'Released' end as 'Status',
--T0.Status 'Status',
T11.U_Name 'User ID',
T0.U_RecDate  'Date of Received'

from OWOR T0
INNER JOIN WOR1 T1 ON T0.DocEntry = T1.DocEntry
LEFT OUTER JOIN OITM T2 ON T0.ItemCode = T2.ItemCode
LEFT OUTER JOIN IGN1 T3 ON T3.BaseEntry = T0.DocEntry AND T3.BaseType = T0.ObjType 
LEFT OUTER JOIN IGE1 T7 ON T7.BaseEntry = T0.DocEntry AND T7.BaseType = T0.ObjType AND T7.BaseLine = T1.LineNum
LEFT OUTER JOIN OILM T4 ON T4.DocEntry = T3.DocEntry AND T3.ObjType = T4.TransType AND T3.LineNum = T4.DocLineNum
INNER JOIN ILM1 T5 ON T4.MessageID = T5.MessageID 
INNER JOIN OSRN T6 ON T5.ItemCode = T6.ItemCode AND T5.SysNumber = T6.SysNumber
inner join ousr t11 on t11.UserID = T0.UserSign
--Where 
--T0.StartDate >= [%0] 
--AND T0.StartDate <= [%1]

--group by T0.DocNum ,T1.wareHouse,T0.StartDate,
--T0.U_RepairBy,T0.ItemCode,T2.ItemName,T6.DistNumber,
--T0.U_WECNO,T0.Comments,T7.ItemCode,T7.Dscription,T7.Quantity,T7.Price