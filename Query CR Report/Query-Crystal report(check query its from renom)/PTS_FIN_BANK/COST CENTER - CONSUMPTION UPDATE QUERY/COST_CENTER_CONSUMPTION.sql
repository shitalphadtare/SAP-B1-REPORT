

Create View PTS_COST_CENTER_CONSUMPTION
as

SELECT  
T0.[DocNum] as 'Issue Number', T0.[DocType], T0.[DocDate],T2.Number as 'JE Number',(select SeriesName from NNM1 where Series=T2.series and ObjectCode='30') as 'JE Series',
(select top 1 OcrCode from IGN1 where DocEntry=T1.DocEntry)+';'+(select top 1 OcrCode2 from IGN1 where DocEntry=T1.DocEntry) as 'Division',
 (select SeriesName from NNm1 where Series=T0.[U_Receiptseries] and ObjectCode='59' ) as SeriesName,
T1.DocNum as 'Receipt Number' FROM OIGE T0
inner join OIGN T1 on T1.DocNum=T0.U_Receiptdocnum and T1.Series=T0.[U_Receiptseries]
inner join OJDT T2 on T2."Createdby"=T0.DocEntry and T2.TransType=60