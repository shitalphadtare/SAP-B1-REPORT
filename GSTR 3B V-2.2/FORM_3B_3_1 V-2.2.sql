alter PROCEDURE FORM_3B_3_1

@LOCATIONGSTIN  nvarchar(100),
@Month nvarchar(100),
@Year  nvarchar(100)

as
 Begin
 ;with LOCAL_SALES_TAXR_0 as
 (	
select SUM(AR_INVOICE)-SUM(CREdit_NOTE)+sum(AR_DOWNPAYMENT) 'TOTAL_SALE',
	   SUM(AR_INV_freight)-SUM(CREDIT_NOTE_freight)+sum(AR_DOWN_freight) 'freight',
	   SUM(AR_INV_cgst_sum)-sum(CREDIT_NOTE_cgst_sum)+sum(AR_DOWN_cgst_sum) 'CGST_SUM',
	   SUM(AR_INV_sgst_sum)-sum(CREDIT_NOTE_sgst_sum)+sum(AR_DOWN_sgst_sum) 'SGST_SUM',
	   SUM(AR_INV_igst_sum)-sum(CREDIT_NOTE_igst_sum)+sum(AR_DOWN_igst_sum) 'IGST_SUM',
	   SUM(AR_INV_cess_sum)-sum(CREDIT_NOTE_cess_sum)+sum(AR_DOWN_cess_sum) 'Cess_sum'
	   ,locgstn,pindicator,month,year
from 
(select docentry,(case when objtype=13 then sum(basesum) else 0 end) 'AR_INVOICE',
		(case when objtype=14 then sum(basesum) else 0 end) 'CREDIT_NOTE',
		(case when objtype=203 then sum(basesum) else 0 end) 'AR_DOWNPAYMENT',
		---------------------------Freight
		(case when objtype=13 then sum(freight) else 0 end) 'AR_INV_freight',
		(case when objtype=14 then sum(freight) else 0 end) 'CREDIT_NOTE_freight',
		(case when objtype=203 then sum(freight) else 0 end) 'AR_DOWN_freight'
		---------------------------CGST
		,(case when objtype=13 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AR_INV_cgst_sum'
		,(case when objtype=14 then sum(cgst_sum)+(f_cgst)  else 0 end) 'CREDIT_NOTE_cgst_sum'
		,(case when objtype=203 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AR_DOWN_cgst_sum'
		---------------------------SGST
		,(case when objtype=13 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'AR_INV_sgst_sum'
		,(case when objtype=14 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'CREDIT_NOTE_sgst_sum'
		,(case when objtype=203 then sum(sgst_sum)+(f_sgst)  else 0 end) 'AR_DOWN_sgst_sum'
		----------------------------IGST
		,(case when objtype=13 then sum(igst_sum)+(f_igst)   else 0 end) 'AR_INV_igst_sum' 
		,(case when objtype=14 then sum(igst_sum)+(f_igst)   else 0 end) 'CREDIT_NOTE_igst_sum' 
		,(case when objtype=203 then sum(igst_sum)+(f_igst)   else 0 end) 'AR_DOWN_igst_sum' 
				----------------------------CESS
		,(case when objtype=13 then sum(cess_sum)+f_cess  else 0 end) 'AR_INV_cess_sum' 
		,(case when objtype=14 then sum(cess_sum)+f_cess   else 0 end) 'CREDIT_NOTE_cess_sum' 
		,(case when objtype=203 then sum(cess_sum)+f_cess   else 0 end) 'AR_DOWN_cess_sum' 
,locgstn,pindicator,month,year
from
	
	(select docentry,objtype,pindicator,month,year
		   ,sum(basesum) 'basesum'
		   ,sum(cgst_sum) 'cgst_sum'
		   ,sum(sgst_sum) 'sgst_sum'
		   ,sum(igst_sum) 'igst_sum'
		   ,sum(cess_sum) 'cess_sum'
	       ,freight,f_cgst,f_sgst,f_igst,f_cess
	       ,imporexp,reverse_charge
	       ,isgsttax,gsttrantyp
	       ,locgsttype,locgstn,locstategstn
	       ,bpgsttype,bpstatecode,bpstategstn
		from PTS_GSTR3
        where VatPercent<>0 and ImpOrExp='N' and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,bpstategstn,year)a
group by objtype,locgstn,pindicator,month,year,docentry,f_cgst,f_sgst,f_igst,F_CESS)b
--where locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
group by locgstn,pindicator,month,year
),
-------------------------------------------------------------------------------------------------------------------------------------
LOCAL_SALES_TAXRATE0_ITEM_0 as
(
select SUM(AR_INVOICE)-SUM(CREdit_NOTE)+sum(AR_DOWNPAYMENT) 'TOTAL_SALE',
	   SUM(AR_INV_freight)-SUM(CREDIT_NOTE_freight)+sum(AR_DOWN_freight) 'freight',
	   SUM(AR_INV_cgst_sum)-sum(CREDIT_NOTE_cgst_sum)+sum(AR_DOWN_cgst_sum) 'CGST_SUM',
	   SUM(AR_INV_sgst_sum)-sum(CREDIT_NOTE_sgst_sum)+sum(AR_DOWN_sgst_sum) 'SGST_SUM',
	   SUM(AR_INV_igst_sum)-sum(CREDIT_NOTE_igst_sum)+sum(AR_DOWN_igst_sum) 'IGST_SUM',
	   SUM(AR_INV_cess_sum)-sum(CREDIT_NOTE_cess_sum)+sum(AR_DOWN_cess_sum) 'Cess_sum'
	   ,locgstn,pindicator,month,year
from 
(select docentry,(case when objtype=13 then sum(basesum) else 0 end) 'AR_INVOICE',
		(case when objtype=14 then sum(basesum) else 0 end) 'CREDIT_NOTE',
		(case when objtype=203 then sum(basesum) else 0 end) 'AR_DOWNPAYMENT',
		---------------------------Freight
		(case when objtype=13 then sum(freight) else 0 end) 'AR_INV_freight',
		(case when objtype=14 then sum(freight) else 0 end) 'CREDIT_NOTE_freight',
		(case when objtype=203 then sum(freight) else 0 end) 'AR_DOWN_freight'
		---------------------------CGST
		,(case when objtype=13 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AR_INV_cgst_sum'
		,(case when objtype=14 then sum(cgst_sum)+(f_cgst)  else 0 end) 'CREDIT_NOTE_cgst_sum'
		,(case when objtype=203 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AR_DOWN_cgst_sum'
		---------------------------SGST
		,(case when objtype=13 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'AR_INV_sgst_sum'
		,(case when objtype=14 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'CREDIT_NOTE_sgst_sum'
		,(case when objtype=203 then sum(sgst_sum)+(f_sgst)  else 0 end) 'AR_DOWN_sgst_sum'
		----------------------------IGST
		,(case when objtype=13 then sum(igst_sum)+(f_igst)   else 0 end) 'AR_INV_igst_sum' 
		,(case when objtype=14 then sum(igst_sum)+(f_igst)   else 0 end) 'CREDIT_NOTE_igst_sum' 
		,(case when objtype=203 then sum(igst_sum)+(f_igst)   else 0 end) 'AR_DOWN_igst_sum' 
				----------------------------CESS
		,(case when objtype=13 then sum(cess_sum)+f_cess  else 0 end) 'AR_INV_cess_sum' 
		,(case when objtype=14 then sum(cess_sum)+f_cess   else 0 end) 'CREDIT_NOTE_cess_sum' 
		,(case when objtype=203 then sum(cess_sum)+f_cess   else 0 end) 'AR_DOWN_cess_sum' 
,locgstn,pindicator,month,year
from
	
	(select docentry,objtype,pindicator,month,year
		   ,sum(basesum) 'basesum'
		   ,sum(cgst_sum) 'cgst_sum'
		   ,sum(sgst_sum) 'sgst_sum'
		   ,sum(igst_sum) 'igst_sum'
		   ,sum(cess_sum) 'cess_sum'
	       ,freight,f_cgst,f_sgst,f_igst,f_cess
	       ,imporexp,reverse_charge
	       ,isgsttax,gsttrantyp
	       ,locgsttype,locgstn,locstategstn
	       ,bpgsttype,bpstatecode,bpstategstn
		from PTS_GSTR3
        where VatPercent=0 and ImpOrExp='N' and Item_Tax_Type in ('N') and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,f_cess,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,bpstategstn,year)a
group by objtype,locgstn,pindicator,month,year,docentry,f_cgst,f_sgst,f_igst,f_cess)b
--where locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
group by locgstn,pindicator,month,year
),
-------------------------------------------------------------------------------------------------------------------------------------
EXPORT_SALES_TAXRATE0 as
(
select SUM(AR_INVOICE)-SUM(CREdit_NOTE)+sum(AR_DOWNPAYMENT) 'TOTAL_SALE',
	   SUM(AR_INV_freight)-SUM(CREDIT_NOTE_freight)+sum(AR_DOWN_freight) 'freight',
	   SUM(AR_INV_cgst_sum)-sum(CREDIT_NOTE_cgst_sum)+sum(AR_DOWN_cgst_sum) 'CGST_SUM',
	   SUM(AR_INV_sgst_sum)-sum(CREDIT_NOTE_sgst_sum)+sum(AR_DOWN_sgst_sum) 'SGST_SUM',
	   SUM(AR_INV_igst_sum)-sum(CREDIT_NOTE_igst_sum)+sum(AR_DOWN_igst_sum) 'IGST_SUM',
	   SUM(AR_INV_cess_sum)-sum(CREDIT_NOTE_cess_sum)+sum(AR_DOWN_cess_sum) 'Cess_sum'
	   ,locgstn,pindicator,month,year
from 
(select docentry,(case when objtype=13 then sum(basesum) else 0 end) 'AR_INVOICE',
		(case when objtype=14 then sum(basesum) else 0 end) 'CREDIT_NOTE',
		(case when objtype=203 then sum(basesum) else 0 end) 'AR_DOWNPAYMENT',
		---------------------------Freight
		(case when objtype=13 then sum(freight) else 0 end) 'AR_INV_freight',
		(case when objtype=14 then sum(freight) else 0 end) 'CREDIT_NOTE_freight',
		(case when objtype=203 then sum(freight) else 0 end) 'AR_DOWN_freight'
		---------------------------CGST
		,(case when objtype=13 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AR_INV_cgst_sum'
		,(case when objtype=14 then sum(cgst_sum)+(f_cgst)  else 0 end) 'CREDIT_NOTE_cgst_sum'
		,(case when objtype=203 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AR_DOWN_cgst_sum'
		---------------------------SGST
		,(case when objtype=13 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'AR_INV_sgst_sum'
		,(case when objtype=14 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'CREDIT_NOTE_sgst_sum'
		,(case when objtype=203 then sum(sgst_sum)+(f_sgst)  else 0 end) 'AR_DOWN_sgst_sum'
		----------------------------IGST
		,(case when objtype=13 then sum(igst_sum)+(f_igst)   else 0 end) 'AR_INV_igst_sum' 
		,(case when objtype=14 then sum(igst_sum)+(f_igst)   else 0 end) 'CREDIT_NOTE_igst_sum' 
		,(case when objtype=203 then sum(igst_sum)+(f_igst)   else 0 end) 'AR_DOWN_igst_sum' 
				----------------------------CESS
		,(case when objtype=13 then sum(cess_sum)+F_CESS  else 0 end) 'AR_INV_cess_sum' 
		,(case when objtype=14 then sum(cess_sum)+F_CESS   else 0 end) 'CREDIT_NOTE_cess_sum' 
		,(case when objtype=203 then sum(cess_sum)+F_CESS   else 0 end) 'AR_DOWN_cess_sum' 
,locgstn,pindicator,month,year
from
	
	(select docentry,objtype,pindicator,month,year
		   ,sum(basesum) 'basesum'
		   ,sum(cgst_sum) 'cgst_sum'
		   ,sum(sgst_sum) 'sgst_sum'
		   ,sum(igst_sum) 'igst_sum'
		   ,sum(cess_sum) 'cess_sum'
	       ,freight,f_cgst,f_sgst,f_igst,f_cess
	       ,imporexp,reverse_charge
	       ,isgsttax,gsttrantyp
	       ,locgsttype,locgstn,locstategstn
	       ,bpgsttype,bpstatecode,bpstategstn
		from PTS_GSTR3
        where VatPercent=0 and ImpOrExp='Y' and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,bpstategstn,year)a
group by objtype,locgstn,pindicator,month,year,docentry,f_cgst,f_sgst,f_igst,f_cess)b
--where locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
group by locgstn,pindicator,month,year
),
------------------------------------------------------------------------------------------------------------
LOCAL_PURCHASE_REVERSE as
(

select SUM(AP_INVOICE)-SUM(DEBIT_NOTE)+sum(AP_DOWNPAYMENT) 'TOTAL_PURCHASE',
	   SUM(AP_INV_freight)-SUM(DEBIT_NOTE_freight)+sum(AP_DOWN_freight) 'freight',
	   SUM(AP_INV_cgst_sum)-sum(DEBIT_NOTE_cgst_sum)+sum(AP_DOWN_cgst_sum) 'CGST_SUM',
	   SUM(AP_INV_sgst_sum)-sum(DEBIT_NOTE_sgst_sum)+sum(AP_DOWN_sgst_sum) 'SGST_SUM',
	   SUM(AP_INV_igst_sum)-sum(DEBIT_NOTE_igst_sum)+sum(AP_DOWN_igst_sum) 'IGST_SUM',
	   SUM(AP_INV_cess_sum)-sum(DEBIT_NOTE_cess_sum)+sum(AP_DOWN_cess_sum) 'Cess_sum'
	   ,locgstn,pindicator,month,year
from 
(select (case when objtype=18 then sum(basesum) else 0 end) 'AP_INVOICE',
		(case when objtype=19 then sum(basesum) else 0 end) 'DEBIT_NOTE',
		(case when objtype=204 then sum(basesum) else 0 end) 'AP_DOWNPAYMENT',
		---------------------------Freight
		(case when objtype=18 then sum(freight) else 0 end) 'AP_INV_freight',
		(case when objtype=19 then sum(freight) else 0 end) 'DEBIT_NOTE_freight',
		(case when objtype=204 then sum(freight) else 0 end) 'AP_DOWN_freight'
		---------------------------CGST
		,(case when objtype=18 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AP_INV_cgst_sum'
		,(case when objtype=19 then sum(cgst_sum)+(f_cgst)  else 0 end) 'DEBIT_NOTE_cgst_sum'
		,(case when objtype=204 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AP_DOWN_cgst_sum'
		---------------------------SGST
		,(case when objtype=18 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'AP_INV_sgst_sum'
		,(case when objtype=19 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'DEBIT_NOTE_sgst_sum'
		,(case when objtype=204 then sum(sgst_sum)+(f_sgst)  else 0 end) 'AP_DOWN_sgst_sum'
		----------------------------IGST
		,(case when objtype=18 then sum(igst_sum)+(f_igst)   else 0 end) 'AP_INV_igst_sum' 
		,(case when objtype=19 then sum(igst_sum)+(f_igst)   else 0 end) 'DEBIT_NOTE_igst_sum' 
		,(case when objtype=204 then sum(igst_sum)+(f_igst)   else 0 end) 'AP_DOWN_igst_sum' 
				----------------------------CESS
		,(case when objtype=18 then sum(cess_sum)+F_CESS  else 0 end) 'AP_INV_cess_sum' 
		,(case when objtype=19 then sum(cess_sum)+F_CESS   else 0 end) 'DEBIT_NOTE_cess_sum' 
		,(case when objtype=204 then sum(cess_sum)+F_CESS   else 0 end) 'AP_DOWN_cess_sum' 
,locgstn,pindicator,month,year
from
	
	(select docentry,objtype,pindicator,month,year
		   ,sum(basesum) 'basesum'
		   ,sum(cgst_sum) 'cgst_sum'
		   ,sum(sgst_sum) 'sgst_sum'
		   ,sum(igst_sum) 'igst_sum'
		   ,sum(cess_sum) 'cess_sum'
	       ,freight,f_cgst,f_sgst,f_igst,F_CESS
	       ,imporexp,reverse_charge
	       ,isgsttax,gsttrantyp
	       ,locgsttype,locgstn,locstategstn
	       ,bpgsttype,bpstatecode,bpstategstn
		from PTS_GSTR3
       where  ImpOrExp='N' and  reverse_charge='Y' and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,bpstategstn,year)a
group by objtype,locgstn,pindicator,month,year,docentry,f_cgst,f_sgst,f_igst,F_CESS)b
--where locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
group by locgstn,pindicator,month,year
),
------------------------------------------------------------------------------------------------------------------------------
SALES_NOTGST as
(
select SUM(AR_INVOICE)-SUM(CREdit_NOTE)+sum(AR_DOWNPAYMENT) 'TOTAL_SALE',
	   SUM(AR_INV_freight)-SUM(CREDIT_NOTE_freight)+sum(AR_DOWN_freight) 'freight',
	   SUM(AR_INV_cgst_sum)-sum(CREDIT_NOTE_cgst_sum)+sum(AR_DOWN_cgst_sum) 'CGST_SUM',
	   SUM(AR_INV_sgst_sum)-sum(CREDIT_NOTE_sgst_sum)+sum(AR_DOWN_sgst_sum) 'SGST_SUM',
	   SUM(AR_INV_igst_sum)-sum(CREDIT_NOTE_igst_sum)+sum(AR_DOWN_igst_sum) 'IGST_SUM',
	   SUM(AR_INV_cess_sum)-sum(CREDIT_NOTE_cess_sum)+sum(AR_DOWN_igst_sum) 'Cess_sum'
	   ,locgstn,pindicator,month,year
from 
(select DOCENTRY,(case when objtype=13 then sum(basesum) else 0 end) 'AR_INVOICE',
		(case when objtype=14 then sum(basesum) else 0 end) 'CREDIT_NOTE',
		(case when objtype=203 then sum(basesum) else 0 end) 'AR_DOWNPAYMENT',
		---------------------------Freight
		(case when objtype=13 then sum(freight) else 0 end) 'AR_INV_freight',
		(case when objtype=14 then sum(freight) else 0 end) 'CREDIT_NOTE_freight',
		(case when objtype=203 then sum(freight) else 0 end) 'AR_DOWN_freight'
		---------------------------CGST
		,(case when objtype=13 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AR_INV_cgst_sum'
		,(case when objtype=14 then sum(cgst_sum)+(f_cgst)  else 0 end) 'CREDIT_NOTE_cgst_sum'
		,(case when objtype=203 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AR_DOWN_cgst_sum'
		---------------------------SGST
		,(case when objtype=13 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'AR_INV_sgst_sum'
		,(case when objtype=14 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'CREDIT_NOTE_sgst_sum'
		,(case when objtype=203 then sum(sgst_sum)+(f_sgst)  else 0 end) 'AR_DOWN_sgst_sum'
		----------------------------IGST
		,(case when objtype=13 then sum(igst_sum)+(f_igst)   else 0 end) 'AR_INV_igst_sum' 
		,(case when objtype=14 then sum(igst_sum)+(f_igst)   else 0 end) 'CREDIT_NOTE_igst_sum' 
		,(case when objtype=203 then sum(igst_sum)+(f_igst)   else 0 end) 'AR_DOWN_igst_sum' 
				----------------------------CESS
		,(case when objtype=13 then sum(cess_sum)+F_CESS  else 0 end) 'AR_INV_cess_sum' 
		,(case when objtype=14 then sum(cess_sum)+F_CESS   else 0 end) 'CREDIT_NOTE_cess_sum' 
		,(case when objtype=203 then sum(cess_sum)+F_CESS   else 0 end) 'AR_DOWN_cess_sum' 
,locgstn,pindicator,month,year
from
	
	(select docentry,objtype,pindicator,month,year
		   ,sum(basesum) 'basesum'
		   ,sum(cgst_sum) 'cgst_sum'
		   ,sum(sgst_sum) 'sgst_sum'
		   ,sum(igst_sum) 'igst_sum'
		   ,sum(cess_sum) 'cess_sum'
	       ,freight,f_cgst,f_sgst,f_igst,F_CESS
	       ,imporexp,reverse_charge
	       ,isgsttax,gsttrantyp
	       ,locgsttype,locgstn,locstategstn
	       ,bpgsttype,bpstatecode,bpstategstn
		from PTS_GSTR3 
        where isgsttax='N' and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,bpstategstn,year)a
group by objtype,locgstn,pindicator,month,year,f_cgst,f_sgst,f_igst,F_CESS,DOCENTRY)b
--where locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
group by locgstn,pindicator,month,year


)





select distinct a1.TOTAL_SALE 'a1_TOTAL_SALE',a1.freight 'a1_freight'
			   ,a1.IGST_SUM 'a1_IGST_SUM',a1.SGST_SUM 'a1_SGST_SUM'
			   ,a1.CGST_SUM 'A1_CGST_SUM',a1.Cess_sum 'a1_Cess_sum'
			   --------------
			   ,a2.TOTAL_SALE 'a2_TOTAL_SALE',a2.freight 'a2_freight'
			   ,a2.IGST_SUM 'a2_IGST_SUM',a2.SGST_SUM 'a2_SGST_SUM'
			   ,a2.CGST_SUM 'a3_CGST_SUM',a2.Cess_sum 'a2_Cess_sum'
			   -------------------
			   ,a3.TOTAL_SALE 'a3_TOTAL_SALE',a3.freight 'a3_freight'
			   ,a3.IGST_SUM 'a3_IGST_SUM',a3.SGST_SUM 'a3_SGST_SUM'
			   ,a3.CGST_SUM 'a3_CGST_SUM',a3.Cess_sum 'a3_Cess_sum'
			   -------------------
			   ,a4.TOTAL_PURCHASE 'a4_TOTAL_PURCHASE',a4.freight 'a4_freight'
			   ,a4.IGST_SUM 'a4_IGST_SUM',a4.SGST_SUM 'a4_SGST_SUM'
			   ,a4.CGST_SUM 'a4_CGST_SUM',a4.Cess_sum 'a4_Cess_sum'
			   -------------------
			   ,a5.TOTAL_SALE 'a5_TOTAL_SALE',a5.freight 'a5_freight'
			   ,a5.IGST_SUM 'a5_IGST_SUM',a5.SGST_SUM 'a5_SGST_SUM'
			   ,a5.CGST_SUM 'a5_CGST_SUM',a5.Cess_sum 'a5_Cess_sum'

 from PTS_GSTR3 C
left outer join LOCAL_SALES_TAXR_0 A1 on c.locgstn=a1.locgstn and c.pindicator=a1.pindicator and c.month=a1.month
left outer join  LOCAL_SALES_TAXRATE0_ITEM_0 A2 on c.locgstn=c.locgstn and c.pindicator=c.pindicator and c.month=A2.month
left outer join  EXPORT_SALES_TAXRATE0 A3 on c.locgstn=A3.locgstn and c.pindicator=A3.pindicator and c.month=A3.month
left outer join LOCAL_PURCHASE_REVERSE A4 on c.locgstn=A4.locgstn and c.pindicator=A4.pindicator and c.month=A4.month
left outer join SALES_NOTGST A5 on c.locgstn=A5.locgstn and c.pindicator=A5.pindicator and c.month=A5.month
where c.locgstn=@LOCATIONGSTIN and c.month=@month and c.pindicator=@year
 END
 go
 