--DECLARE
--@StartDate DATETIME,
--@EndDate DATETIME,

--/* SELECT FROM [dbo].[Oinv] T4 */DECLARE @StartDate As DATETIME)/* WHERE */SET @StartDate = /* T4.DocDate */ '[%1]'
--/* SELECT FROM [dbo].[Oinv] T5 */DECLARE @EndDate As DATETIME/* WHERE */SET @EndDate = /* T5.DocDate */ '[%2]'

--@Dummy INTEGER
--SELECT TOP 1 @Dummy = DocNum FROM  Oinv T0 WHERE T0.DocDate >= [%1] AND ----T0.DocDate <= [%2]
--SELECT
--@StartDate= '[%1]',
--@EndDate = '[%2]'
Create View PTS_Sales_Register_ItemWise
AS
Select * from (
SELECT
T0.DocDate, T0.Docentry, 
(CASE  T0.gsttrantyp when 'GA' then 'Gst Tax Invoice'
when 'GD' then 'Gst Debit Memo'
when '--' then 'Bill Of Supply' 
  end) 'GST Transaction Type',     
CONVERT(VARCHAR(10), T0.DocDate, 3) AS 'Invoice Date', T0.DocNum as 'Invoice No',  
N1.SeriesName 'DocSeries',  N1.BeginStr 'DocSeriesPrefix', N1.EndStr 'DocSeriesSuffix',
SLP.SLPNAME 'SALES PERSON NAME',
T0.CardName AS 'Customer Billing Name', T7.BPGSTN 'Billing GSTIN', T7.LocStaGSTN 'State POS',  
(CASE WHEN T0.DocType = 'I' AND ITM.ItemClass = 2 THEN 'G' ELSE 'S' END) ItemType,
t1.itemcode 'Item Code',
T1.Dscription AS 'Item Description',  
(Case When T0.Doctype = 'I' Then 
   (CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry = ITM.SACEntry)  
         When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where Absentry=ITM.chapterid) End)       
  Else (Case When T0.DocType = 'S' Then (Select ServCode from OSAC Where AbsEntry = T1.SACEntry) END)
END) 'HSN/SAC Code' ,
(case when T0.doctype='S' then 1 else T1.Quantity end)'Quantity',  
(case when doctype='S' then T1.LineTotal else (T1.PriceBefDi*(case when T1.Rate = 0 then 1 else T1.Rate end)) end)  'Unit Price',
(case when T0.doctype='S' then (T1.LineTotal) else (t1.Quantity*(T1.PriceBefDi*(case when T1.Rate = 0 then 1 else T1.Rate end))) end) 'ItemTotalBefDi',
(case when T0.doctype='S' then ((t1.Quantity*T1.linetotal)* T1.DiscPrcnt/100)+ (T1.Linetotal *T0.DiscPrcnt/100) else ((t1.Quantity*(T1.PriceBefDi*(case when T1.Rate = 0 then 1 else T1.Rate end)))* T1.DiscPrcnt/100)+ (T1.Linetotal *T0.DiscPrcnt/100) end)  'Item Discount',
(case when T0.doctype='S' then (T1.LineTotal)-(T1.Linetotal *T0.DiscPrcnt/100) else ((t1.Quantity*(T1.PriceBefDi*(case when T1.Rate = 0 then 1 else T1.Rate end))) - (((t1.Quantity*(T1.PriceBefDi*(case when T1.Rate = 0 then 1 else T1.Rate end))) * T1.DiscPrcnt/100) + (T1.Linetotal *T0.DiscPrcnt/100))) end)  ' Item Total After Discount',
T1.LineTotal AS 'Basic Line Total',
(CASE WHEN  (T1.AssblValue > 0) THEN (T1.Quantity*T1.AssblValue) ELSE  T1.Linetotal end) 'Taxable Value',
T1.TaxCode,
isnull(CGST.taxRate,0) as 'CGST Rate',
isnull(CGST.TaxSum,0) AS 'CGST',
isnull(SGST.taxRate,0) as 'SGST Rate',
isnull(SGST.TaxSum,0) AS 'SGST', 
isnull(IGST.taxRate,0) as 'IGST Rate',
isnull(IGST.TaxSum,0) AS 'IGST',
(case when isnull(CGST.RvschrgTax,0) + isnull(SGST.RvschrgTax,0) + isnull(IGST.RvschrgTax,0)<> 0 then 'Y' else 'N' end) as 'Reverse Charge Flag',
isnull(CGST.RvschrgTax,0) as 'CGST Rev Tax',
isnull(SGST.RvschrgTax,0) as 'SGST Rev Tax',
isnull(IGST.RvschrgTax,0) as 'IGST Rev Tax',
((case when T0.doctype='S' then (T1.Linetotal)-(T1.Linetotal*T0.DiscPrcnt/100) else ((t1.Quantity*(T1.PriceBefDi*(case when T1.Rate = 0 then 1 else T1.Rate end))) - (((t1.Quantity*(T1.PriceBefDi*(case when T1.Rate = 0 then 1 else T1.Rate end))) * T1.DiscPrcnt/100) + (T1.Linetotal *T0.DiscPrcnt/100))) end) +isnull(CGST.TaxSum,0)+isnull(SGST.TaxSum,0)+isnull(IGST.TaxSum,0) ) as 'Total Incl GST',
T0.RevRefNo 'Original Invoice No', T0.RevRefDate 'Original Invoice Date', T7.BPGSTN 'Original Customer GSTIN',
T0.EComerGSTN 'ECommGSTN',               
CONVERT(VARCHAR(10),iv9.BsDocDate, 3) 'AdvancePaymentDocDate',
iv9.BaseDocNum 'AdvancePaymentDocNum',
T7.ImpORExp 'Flag Export Invoice',
Null as 'Export Type',
  T7.ImpExpNo 'Export No', T7.ImpExpDate 'Export Date' , T7.BPCountry 'Customer Country',  
T7.BPGSTN 'Customer GSTNo',
T0.Address 'Billing Address' , 
T7.CityB 'Billing City', T7.ZipCodeB 'Billing Pin Code' , T7.StateB 'Billing State', T0.ShipToCode 'Shipping Name', 
T0.Address2 'Shipping Address',
T7.CityS 'Shipping City', T7.ZipCodeS 'Shipping Pin Code', T7.BPStateCod 'Shipping State', T7.BPStatGSTN 'Shipping State Code', 
MONTH(T0.RevRefDate) as 'Revision_Month',
(CASE WHEN T0.DutyStatus = 'Y' THEN 'WPAY'
  ELSE 'WOPAY' 
  END ) 'Duty_Status',
Null as 'Port Code',
(select GSTType from OGTY where absentry=T7.BPGSTType ) as 'Customer GST Type',
T7.LocGSTN 'Location GSTNo',  T7.LocStatCod 'Location State' , 
'AR Invoice' as 'Doc Type',
T0.DocDueDate 'Invoice Due Date',
T0.Comments 
,itb.itmsgrpnam 'item group'
,t1.acctcode 'G/L Account'

FROM Oinv T0 
left outer join OCRD on OCRD.CardCode=T0.CardCode
left outer join OCRG on OCRG.GroupCode=OCRD.GroupCode
Left Join CRD7 C7 On T0.CardCode =C7.CardCode And T0.ShipToCode = C7.Address and C7.AddrType = 'S'
INNER JOIN inv1 T1 ON T0.DocEntry = T1.DocEntry
LEFT OUTER JOIN OITM ITM on (ITM.ItemCode = T1.ItemCode)
inner join oitb ITB on ITM.itmsgrpcod=ITB.itmsgrpcod
LEFT OUTER JOIN OSLP SLP ON SLP.SLPCODE=T0.SLPCODE
left outer join NNM1 N1 on N1.Series=T0.Series 
left outer join inv9 iv9 on t0.docentry=iv9.docentry and iv9.objtype='203' --and t1.linenum=iv9.linenum
INNER JOIN inv12 T7 ON T0.DocEntry = T7.DocEntry 
Left Join inv4 CGST ON T1.DocEntry = CGST.DocEntry And T1.LineNum = CGST.LineNum And CGST.StaType = -100 AND CGST.RelateType = 1 AND CGST.ExpnsCode=-1
Left Join inv4 SGST ON T1.DocEntry = SGST.DocEntry And T1.LineNum = SGST.LineNum And SGST.StaType = -110 AND SGST.RelateType = 1 AND SGST.ExpnsCode=-1
Left Join inv4 IGST ON T1.DocEntry = IGST.DocEntry And T1.LineNum = IGST.LineNum And IGST.StaType =-120 AND IGST.RelateType = 1 AND IGST.ExpnsCode=-1
WHERE --T0.DocDate >= [%1]AND T0.DocDate <= [%2] AND
 T0.canceled = 'N'  

-----------------------------------------------------------
Union all

SELECT 
T0.DocDate,T0.Docentry,
(CASE  T0.gsttrantyp when 'GA' then 'Gst Tax Invoice'
when 'GD' then 'Gst Debit Memo'
when '--' then 'Bill Of Supply' 
  end) 'GST Transaction Type',
CONVERT(VARCHAR(10), T0.DocDate, 3) AS 'Invoice Date', T0.DocNum as 'Invoice No',
N1.SeriesName 'DocSeries',  N1.BeginStr 'DocSeriesPrefix', N1.EndStr 'DocSeriesSuffix',
SLP.SLPNAME 'SALES PERSON NAME',
T0.CardName AS 'Customer Billing Name', T7.BPGSTN 'Billing GSTIN', T7.LocStaGSTN 'State POS',  
'S' as 'ItemType',
'' 'Item Code',
T4.ExpnsName  AS 'Item Description', 
 (select SacCode from OEXD where T4.ExpnsName = OEXD.EXPNSNAME) as 'HSN/SAC Code',
1  'Quantity', 
T3.LineTotal  'Unit Price', T3.LineTotal  'ItemTotalBefDi',
Null 'Item Discount', T3.LineTotal 'Item Total After Discount',
T3.LineTotal AS 'Basic Line Total', 
T3.Linetotal  'Taxable Value',
T3.TaxCode,
isnull(CGST.taxRate,0) as 'CGST Rate',
isnull(CGST.TaxSum,0) AS 'CGST',
isnull(SGST.taxRate,0) as 'SGST Rate',
isnull(SGST.TaxSum,0) AS 'SGST', 
isnull(IGST.taxRate,0) as 'IGST Rate',
isnull(IGST.TaxSum,0) AS 'IGST',
(case when isnull(CGST.RvschrgTax,0) + isnull(SGST.RvschrgTax,0) + isnull(IGST.RvschrgTax,0)<> 0 then 'Y' else 'N' end) as 'Reverse Charge Flag',
isnull(CGST.RvschrgTax,0) as 'CGST Rev Tax',
isnull(SGST.RvschrgTax,0) as 'SGST Rev Tax',
isnull(IGST.RvschrgTax,0) as 'IGST Rev Tax',
isnull(T3.LineTotal,0)+isnull(CGST.TaxSum,0)+isnull(SGST.TaxSum,0)+isnull(IGST.TaxSum,0) as 'Total Incl GST',
T0.RevRefNo 'Original Invoice No', T0.RevRefDate 'Original Invoice Date', T7.BPGSTN 'Original Customer GSTIN',
null 'ECommGSTN',                         
null 'AdvancePaymentDocDate',               
null 'AdvancePaymentDocNum',
T7.ImpORExp 'Flag Export Invoice',
Null as 'Export Type',
T7.ImpExpNo 'Export No', T7.ImpExpDate 'Export Date' , T7.BPCountry 'Customer Country',  
T7.BPGSTN 'Customer GSTNo', 
T0.Address 'Billing Address' , 
 T7.CityB 'Billing City', T7.ZipCodeB 'Billing Pin Code' , T7.StateB 'Billing State', T0.ShipToCode 'Shipping Name', 
T0.Address2 'Shipping Address',
T7.CityS 'Shipping City', T7.ZipCodeS 'Shipping Pin Code', T7.BPStateCod 'Shipping State', T7.BPStatGSTN 'Shipping State Code', 
MONTH(T0.RevRefDate) as 'Revision_Month',
(CASE WHEN T0.DutyStatus = 'Y' THEN 'WPAY'
  ELSE 'WOPAY' 
  END ) 'Duty_Status',
Null as 'Port Code',
(select GSTType from OGTY where absentry=T7.BPGSTType ) as 'Customer GST Type',
T7.LocGSTN 'Location GSTNo', T7.LocStatCod 'Location State' , 
'AR Invoice' as 'Doc Type',
T0.DocDueDate 'Invoice Due Date',  
T0.Comments 
,'' 'item group'
,'' 'G/L Account'
FROM Oinv T0 
left outer join OCRD on OCRD.CardCode=T0.CardCode
left outer join OCRG on OCRG.GroupCode=OCRD.GroupCode
Left Join CRD7 C7 On T0.CardCode =C7.CardCode And T0.ShipToCode = C7.Address and C7.AddrType = 'S'
LEFT OUTER JOIN OSLP SLP ON SLP.SLPCODE=T0.SLPCODE
inner join NNM1 N1 on N1.Series=T0.Series 
INNER JOIN inv3 T3 ON T0.DocEntry = T3.DocEntry 
INNER JOIN inv12 T7 ON T0.DocEntry = T7.DocEntry 
Inner Join  OEXD T4 On T3.ExpnsCode = T4.ExpnsCode
Left Join inv4 CGST ON T3.DocEntry = CGST.DocEntry And T3.ExpnsCode = CGST.ExpnsCode And CGST.StaType = -100 AND CGST.ExpnsCode<>-1
Left Join inv4 SGST ON T3.DocEntry = SGST.DocEntry And T3.ExpnsCode = SGST.ExpnsCode And SGST.StaType = -110 AND SGST.ExpnsCode<>-1
Left Join inv4 IGST ON T3.DocEntry = IGST.DocEntry And T3.ExpnsCode = IGST.ExpnsCode And IGST.StaType = -120 AND IGST.ExpnsCode<>-1
WHERE --T0.DocDate >= [%1]AND T0.DocDate <= [%2]AND
 T0.canceled = 'N' 


--------------------------------------------------------------------------------
union all
SELECT
T0.DocDate, T0.Docentry,
(CASE  T0.gsttrantyp when 'GA' then 'Gst Tax Invoice'
when 'GD' then 'Gst Debit Memo'
when '--' then 'Bill Of Supply' 
  end) 'GST Transaction Type',
CONVERT(VARCHAR(10), T0.DocDate, 3) AS 'Invoice Date', T0.DocNum as 'Invoice No',
N1.SeriesName 'DocSeries',  N1.BeginStr 'DocSeriesPrefix', N1.EndStr 'DocSeriesSuffix',
SLP.SLPNAME 'SALES PERSON NAME',
T0.CardName AS 'Customer Billing Name', T7.BPGSTN 'Billing GSTIN', T7.LocStaGSTN 'State POS',  
(CASE WHEN T0.DocType = 'I' AND ITM.ItemClass = 2 THEN 'G' ELSE 'S' END) ItemType,
t1.itemcode 'Item Code',
T1.Dscription AS 'Item Description', 
(Case When T0.Doctype = 'I' Then 
(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry = ITM.SACEntry)  
         When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where Absentry=ITM.chapterid) End)       
  Else (Case When T0.DocType = 'S' Then (Select ServCode from OSAC Where AbsEntry = T1.SACEntry) END)
END) 'HSN/SAC Code' ,
(case when T0.doctype='S' then 1*(-1) else T1.Quantity*(-1) end)'Quantity', 
(case when doctype='S' then T1.LineTotal else (T1.PriceBefDi*(case when T1.Rate = 0 then 1 else T1.Rate end)) end)  'Unit Price',
(case when T0.doctype='S' then T1.LineTotal*(-1) else (t1.Quantity*(T1.PriceBefDi*(case when T1.Rate = 0 then 1 else T1.Rate end)))*(-1) end) 'ItemTotalBefDi',
(case when T0.doctype='S' then ((t1.Quantity*T1.linetotal)* T1.DiscPrcnt/100)+ (T1.Linetotal *T0.DiscPrcnt/100) else ((t1.Quantity*(T1.PriceBefDi*(case when T1.Rate = 0 then 1 else T1.Rate end)))* T1.DiscPrcnt/100)+ (T1.Linetotal *T0.DiscPrcnt/100) end)*(-1)  'Item Discount',
(case when T0.doctype='S' then (T1.LineTotal)-(T1.Linetotal *T0.DiscPrcnt/100) else ((t1.Quantity*(T1.PriceBefDi*(case when T1.Rate = 0 then 1 else T1.Rate end))) - (((t1.Quantity*(T1.PriceBefDi*(case when T1.Rate = 0 then 1 else T1.Rate end))) * T1.DiscPrcnt/100) + (T1.Linetotal *T0.DiscPrcnt/100))) end)*(-1)  ' Item Total After Discount',
T1.LineTotal*-1 AS 'Basic Line Total',
(CASE WHEN  (T1.AssblValue > 0) THEN (T1.Quantity*T1.AssblValue*-1) ELSE  (T1.Linetotal*-1) end) 'Taxable Value',
T1.TaxCode,
isnull(CGST.taxRate,0) as 'CGST Rate',
isnull(CGST.TaxSum,0)*(-1) AS 'CGST',
isnull(SGST.taxRate,0) as 'SGST Rate',
isnull(SGST.TaxSum,0)*(-1) AS 'SGST', 
isnull(IGST.taxRate,0)  as 'IGST Rate',
isnull(IGST.TaxSum,0)*(-1) AS 'IGST',
(case when isnull(CGST.RvschrgTax,0) + isnull(SGST.RvschrgTax,0) + Isnull(IGST.RvschrgTax,0)<> 0 then 'Y' else 'N' end) as 'Reverse Charge Flag',
isnull(CGST.RvschrgTax,0)*(-1) as 'CGST Rev Tax',
isnull(SGST.RvschrgTax,0)*(-1) as 'SGST Rev Tax',
isnull(IGST.RvschrgTax,0)*(-1) as 'IGST Rev Tax',
((case when T0.doctype='S' then (T1.Linetotal)-(T1.Linetotal *T0.DiscPrcnt/100) else ((t1.Quantity*(T1.PriceBefDi*(case when T1.Rate = 0 then 1 else T1.Rate end))) - (((t1.Quantity*(T1.PriceBefDi*(case when T1.Rate = 0 then 1 else T1.Rate end))) * T1.DiscPrcnt/100) + (T1.Linetotal *T0.DiscPrcnt/100))) end) +isnull(CGST.TaxSum,0)+isnull(SGST.TaxSum,0)+isnull(IGST.TaxSum,0) )*(-1) as 'Total Incl GST',
T0.RevRefNo 'Original Invoice No', T0.RevRefDate 'Original Invoice Date', T7.BPGSTN 'Original Customer GSTIN',
null 'ECommGSTN',                         
null 'AdvancePaymentDocDate',               
null 'AdvancePaymentDocNum',
T7.ImpORExp 'Flag Export Invoice',
Null as 'Export Type',
T7.ImpExpNo 'Export No', T7.ImpExpDate 'Export Date' , T7.BPCountry 'Customer Country',  
T7.BPGSTN 'Customer GSTNo', 
T0.Address 'Billing Address' , 
 T7.CityB 'Billing City', T7.ZipCodeB 'Billing Pin Code' , T7.StateB 'Billing State', T0.ShipToCode 'Shipping Name', 
T0.Address2 'Shipping Address',
T7.CityS 'Shipping City', T7.ZipCodeS 'Shipping Pin Code', T7.BPStateCod 'Shipping State', T7.BPStatGSTN 'Shipping State Code', 
MONTH(T0.RevRefDate) as 'Revision_Month',
(CASE WHEN T0.DutyStatus = 'Y' THEN 'WPAY'
  ELSE 'WOPAY' 
  END ) 'Duty_Status',
Null as 'Port Code',
(select GSTType from OGTY where absentry=T7.BPGSTType ) as 'Customer GST Type',
T7.LocGSTN 'Location GSTNo',  T7.LocStatCod 'Location State' , 
'AR Credit Memo' as 'Doc Type',
T0.DocDueDate 'Invoice Due Date',  
T0.Comments 
,itb.itmsgrpnam 'item group'
,t1.acctcode 'G/L Account'
FROM Orin T0 
left outer join OCRD on OCRD.CardCode=T0.CardCode
left outer join OCRG on OCRG.GroupCode=OCRD.GroupCode
Left Join CRD7 C7 On T0.CardCode =C7.CardCode And T0.ShipToCode = C7.Address and C7.AddrType = 'S'
INNER JOIN rin1 T1 ON T0.DocEntry = T1.DocEntry 
LEFT OUTER JOIN OSLP SLP ON SLP.SLPCODE=T0.SLPCODE
LEFT OUTER JOIN OITM ITM on (ITM.ItemCode = T1.ItemCode)
inner join oitb ITB on ITM.itmsgrpcod=ITB.itmsgrpcod
inner join NNM1 N1 on N1.Series=T0.Series 
INNER JOIN rin12 T7 ON T0.DocEntry = T7.DocEntry 
Left Join rin4 CGST ON T1.DocEntry = CGST.DocEntry And T1.LineNum = CGST.LineNum And CGST.StaType = -100 AND CGST.RelateType = 1 AND CGST.ExpnsCode=-1
Left Join rin4 SGST ON T1.DocEntry = SGST.DocEntry And T1.LineNum = SGST.LineNum And SGST.StaType = -110 AND SGST.RelateType =1 AND SGST.ExpnsCode=-1
Left Join rin4 IGST ON T1.DocEntry = IGST.DocEntry And T1.LineNum = IGST.LineNum And IGST.StaType = -120 AND IGST.RelateType = 1 AND IGST.ExpnsCode=-1
WHERE --T0.DocDate >= [%1]AND T0.DocDate <= [%2]AND
 T0.canceled = 'N'  

--------------------------------------------------------------------------
Union all

SELECT 
T0.DocDate,T0.Docentry,
(CASE  T0.gsttrantyp when 'GA' then 'Gst Tax Invoice'
when 'GD' then 'Gst Debit Memo'
when '--' then 'Bill Of Supply' 
  end) 'GST Transaction Type',
CONVERT(VARCHAR(10), T0.DocDate, 3) AS 'Invoice Date', T0.DocNum as 'Invoice No',
N1.SeriesName 'DocSeries',  N1.BeginStr 'DocSeriesPrefix', N1.EndStr 'DocSeriesSuffix',
SLP.SLPNAME 'SALES PERSON NAME',
T0.CardName AS 'Customer Billing Name', T7.BPGSTN 'Billing GSTIN', T7.LocStaGSTN 'State POS',  
'S' as 'ItemType',
'' 'Item Code',
  T4.ExpnsName  AS 'Item Description', 
  (select SacCode from OEXD where T4.ExpnsName = OEXD.EXPNSNAME) as 'HSN/SAC Code',
-1  'Quantity', 
T3.LineTotal  'Unit Price', T3.LineTotal*-1 'ItemTotalBefDi',
Null 'Item Discount', T3.LineTotal*-1 'Item Total After Discount',
T3.LineTotal*-1 AS 'Basic Line Total',
(T3.Linetotal *-1) 'Taxable Value',
T3.TaxCode, 
isnull(CGST.taxRate,0)  as 'CGST Rate',
isnull(CGST.TaxSum,0)*(-1) AS 'CGST',
isnull(SGST.taxRate,0)  as 'SGST Rate',
isnull(SGST.TaxSum,0)*(-1) AS 'SGST', 
isnull(IGST.taxRate,0)  as 'IGST Rate',
isnull(IGST.TaxSum,0)*(-1) AS 'IGST',
(case when isnull(CGST.RvschrgTax,0) + isnull(SGST.RvschrgTax,0) + isnull(IGST.RvschrgTax,0)<> 0 then 'Y' else 'N' end) as 'Reverse Charge Flag',
isnull(CGST.RvschrgTax,0)*(-1) as 'CGST Rev Tax',             
isnull(SGST.RvschrgTax,0)*(-1) as 'SGST Rev Tax',
isnull(IGST.RvschrgTax,0)*(-1) as 'IGST Rev Tax',
(isnull(T3.LineTotal,0)+isnull(CGST.TaxSum,0)+isnull(SGST.TaxSum,0)+isnull(IGST.TaxSum,0))*(-1) as 'Total Incl GST',
T0.RevRefNo 'Original Invoice No', T0.RevRefDate 'Original Invoice Date', T7.BPGSTN 'Original Customer GSTIN', 
null 'ECommGSTN',                         
null 'AdvancePaymentDocDate',               
null 'AdvancePaymentDocNum',
T7.ImpORExp 'Flag Export Invoice',
Null as 'Export Type',
T7.ImpExpNo 'Export No', T7.ImpExpDate 'Export Date' , T7.BPCountry 'Customer Country',  
T7.BPGSTN 'Customer GSTNo',
T0.Address 'Billing Address' , 
 T7.CityB 'Billing City', T7.ZipCodeB 'Billing Pin Code' , T7.StateB 'Billing State', T0.ShipToCode 'Shipping Name', 
T0.Address2 'Shipping Address',
T7.CityS 'Shipping City', T7.ZipCodeS 'Shipping Pin Code', T7.BPStateCod 'Shipping State', T7.BPStatGSTN 'Shipping State Code', 
MONTH(T0.RevRefDate) as 'Revision_Month',
(CASE WHEN T0.DutyStatus = 'Y' THEN 'WPAY'
  ELSE 'WOPAY' 
  END ) 'Duty_Status',
Null as 'Port Code',
(select GSTType from OGTY where absentry=T7.BPGSTType ) as 'Customer GST Type',
T7.LocGSTN 'Location GSTNo',  T7.LocStatCod 'Location State' , 
'AR Credit Memo' as 'Doc Type',
T0.DocDueDate 'Invoice Due Date',  
T0.Comments
,'' 'item group'
,'' 'G/L Account'
FROM Orin T0 
left outer join OCRD on OCRD.CardCode=T0.CardCode
left outer join OCRG on OCRG.GroupCode=OCRD.GroupCode
Left Join CRD7 C7 On T0.CardCode =C7.CardCode And T0.ShipToCode = C7.Address and C7.AddrType = 'S'
LEFT OUTER JOIN OSLP SLP ON SLP.SLPCODE=T0.SLPCODE
inner join NNM1 N1 on N1.Series=T0.Series 
INNER JOIN rin3 T3 ON T0.DocEntry = T3.DocEntry 
INNER JOIN rin12 T7 ON T0.DocEntry = T7.DocEntry 
Inner Join  OEXD T4 On T3.ExpnsCode = T4.ExpnsCode
Left Join rin4 CGST ON T3.DocEntry = CGST.DocEntry And T3.ExpnsCode = CGST.ExpnsCode And CGST.StaType = -100 AND CGST.ExpnsCode<>-1
Left Join rin4 SGST ON T3.DocEntry = SGST.DocEntry And T3.ExpnsCode = SGST.ExpnsCode And SGST.StaType = -110 AND SGST.ExpnsCode<>-1 
Left Join rin4 IGST ON T3.DocEntry = IGST.DocEntry And T3.ExpnsCode = IGST.ExpnsCode And IGST.StaType = -120 AND IGST.ExpnsCode<>-1
WHERE --T0.DocDate >= [%1]AND T0.DocDate <= [%2]AND
T0.canceled = 'N' 
) a 
--order by a.docentry