
CREATE VIEW PTS_Goods_Receipt_Wec
AS
SELECT 
T2.SeriesName,
T1.[DocDate],
T1.[DocNum], 
T0.[DocEntry], 
T0.[ItemCode], 
T0.[Dscription], 
T0.[Quantity],
T0.[WhsCode], 
T0.[StockPrice],
T0.[OcrCode], 
T0.[OcrCode2],
T1.[U_Category],
T1.[U_ErrorCode]
FROM IGN1 T0  
INNER JOIN OIGN T1 ON T0.[DocEntry] = T1.[DocEntry]
INNER JOIN NNM1 T2 ON T1.Series = T2.Series

--WHERE T1.DocDate >= @FromDate
--AND T1.DocDate <= @ToDate