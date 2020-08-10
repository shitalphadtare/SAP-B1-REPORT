alter PROCEDURE FORM_3B_3_2

@LOCATIONGSTIN  nvarchar(100),
@Month nvarchar(100),
@Year  nvarchar(100)

as
 Begin
  ;with LOCAL_SALES_BPGSTN_NULL_IGST as
  (
  select SUM(AR_INVOICE)-SUM(CREdit_NOTE)+sum(AR_DOWNPAYMENT) 'TOTAL_SALE',
	   SUM(AR_INV_freight)-SUM(CREDIT_NOTE_freight)+sum(AR_DOWN_freight) 'freight',
	   SUM(AR_INV_cgst_sum)-sum(CREDIT_NOTE_cgst_sum)+sum(AR_DOWN_cgst_sum) 'CGST_SUM',
	   SUM(AR_INV_sgst_sum)-sum(CREDIT_NOTE_sgst_sum)+sum(AR_DOWN_sgst_sum) 'SGST_SUM',
	   SUM(AR_INV_igst_sum)-sum(CREDIT_NOTE_igst_sum)+sum(AR_DOWN_igst_sum) 'IGST_SUM',
	   SUM(AR_INV_cess_sum)-sum(CREDIT_NOTE_cess_sum)+sum(AR_DOWN_CESS_sum) 'Cess_sum'
	   ,locgstn,pindicator,month,year
from 
(select DOCENTRY,(case when objtype=13 then sum(basesum) else 0 end) 'AR_INVOICE',
		(case when objtype=14 then sum(basesum) else 0 end) 'CREDIT_NOTE',
		(case when objtype=203 then sum(basesum) else 0 end) 'AR_DOWNPAYMENT',
		---------------------------Freight
		(case when objtype=13 then (freight) else 0 end) 'AR_INV_freight',
		(case when objtype=14 then (freight) else 0 end) 'CREDIT_NOTE_freight',
		(case when objtype=203 then (freight) else 0 end) 'AR_DOWN_freight'
		---------------------------CGST
		,(case when objtype=13 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AR_INV_cgst_sum'
		,(case when objtype=14 then sum(cgst_sum)+(f_cgst)  else 0 end) 'CREDIT_NOTE_cgst_sum'
		,(case when objtype=203 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AR_DOWN_cgst_sum'
		---------------------------SGST
		,(case when objtype=13 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'AR_INV_sgst_sum'
		,(case when objtype=14 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'CREDIT_NOTE_sgst_sum'
		,(case when objtype=203 then sum(sgst_sum)+(f_sgst)  else 0 end) 'AR_DOWN_sgst_sum'
		---------------------------IGST
		,(case when objtype=13 then sum(igst_sum)+(f_igst)   else 0 end) 'AR_INV_igst_sum' 
		,(case when objtype=14 then sum(igst_sum)+(f_igst)   else 0 end) 'CREDIT_NOTE_igst_sum' 
		,(case when objtype=203 then sum(igst_sum)+(f_igst)   else 0 end) 'AR_DOWN_igst_sum' 
				----------------------------CESS
		,(case when objtype=13 then sum(cess_sum)+ F_CESS else 0 end) 'AR_INV_cess_sum' 
		,(case when objtype=14 then sum(cess_sum)+ F_CESS   else 0 end) 'CREDIT_NOTE_cess_sum' 
		,(case when objtype=203 then sum(cess_sum)+ F_CESS   else 0 end) 'AR_DOWN_cess_sum' 
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
	       ,bpgsttype,bpstatecode,BpGSTN,BpStateGSTN
		from PTS_GSTR3
        where BpGSTN='' and imporexp='N' and tax_code='IGST' and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,BpGSTN,year,BpStateGSTN)a
group by objtype,locgstn,pindicator,month,year,f_cgst,f_sgst,f_igst,F_CESS,docentry,freight)b
--where locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
group by locgstn,pindicator,month,year    
  ),
  ------------------------------------------------------------------------------------------
LOCAL_SALES_BPGSTTYPE_COMPOSITE_LEVY_IGST as
  (
  select SUM(AR_INVOICE)-SUM(CREdit_NOTE)+sum(AR_DOWNPAYMENT) 'TOTAL_SALE',
	   SUM(AR_INV_freight)-SUM(CREDIT_NOTE_freight)+sum(AR_DOWN_freight) 'freight',
	   SUM(AR_INV_cgst_sum)-sum(CREDIT_NOTE_cgst_sum)+sum(AR_DOWN_cgst_sum) 'CGST_SUM',
	   SUM(AR_INV_sgst_sum)-sum(CREDIT_NOTE_sgst_sum)+sum(AR_DOWN_sgst_sum) 'SGST_SUM',
	   SUM(AR_INV_igst_sum)-sum(CREDIT_NOTE_igst_sum)+sum(AR_DOWN_igst_sum) 'IGST_SUM',
	   SUM(AR_INV_cess_sum)-sum(CREDIT_NOTE_cess_sum)+sum(AR_DOWN_CESS_sum) 'Cess_sum'
	   ,locgstn,pindicator,month,year
from 
(select DOCENTRY,(case when objtype=13 then sum(basesum) else 0 end) 'AR_INVOICE',
		(case when objtype=14 then sum(basesum) else 0 end) 'CREDIT_NOTE',
		(case when objtype=203 then sum(basesum) else 0 end) 'AR_DOWNPAYMENT',
		---------------------------Freight
		(case when objtype=13 then (freight) else 0 end) 'AR_INV_freight',
		(case when objtype=14 then (freight) else 0 end) 'CREDIT_NOTE_freight',
		(case when objtype=203 then (freight) else 0 end) 'AR_DOWN_freight'
		---------------------------CGST
		,(case when objtype=13 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AR_INV_cgst_sum'
		,(case when objtype=14 then sum(cgst_sum)+(f_cgst)  else 0 end) 'CREDIT_NOTE_cgst_sum'
		,(case when objtype=203 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AR_DOWN_cgst_sum'
		---------------------------SGST
		,(case when objtype=13 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'AR_INV_sgst_sum'
		,(case when objtype=14 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'CREDIT_NOTE_sgst_sum'
		,(case when objtype=203 then sum(sgst_sum)+(f_sgst)  else 0 end) 'AR_DOWN_sgst_sum'
		---------------------------IGST
		,(case when objtype=13 then sum(igst_sum)+SUM(f_igst)   else 0 end) 'AR_INV_igst_sum' 
		,(case when objtype=14 then sum(igst_sum)+SUM(f_igst)   else 0 end) 'CREDIT_NOTE_igst_sum' 
		,(case when objtype=203 then sum(igst_sum)+SUM(f_igst)   else 0 end) 'AR_DOWN_igst_sum' 
				----------------------------CESS
		,(case when objtype=13 then sum(cess_sum)+F_CESS  else 0 end) 'AR_INV_cess_sum' 
		,(case when objtype=14 then sum(cess_sum)+F_CESS   else 0 end) 'CREDIT_NOTE_cess_sum' 
		,(case when objtype=203 then sum(cess_sum)+F_CESS  else 0 end) 'AR_DOWN_cess_sum' 
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
	       ,bpgsttype,bpstatecode,BpGSTN,BpStateGSTN
		from PTS_GSTR3
        where  imporexp='N' and bpgsttype=3 AND TAX_CODE='IGST' and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,BpGSTN,year,BpStateGSTN)a
group by objtype,locgstn,pindicator,month,year,f_cgst,f_sgst,f_igst,F_CESS,DOCENTRY,freight)b
--where locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
group by locgstn,pindicator,month,year
  ),
--------------------------------------------------------------------------------------------
LOCAL_SALES_BPGSTTYPE_UN_AGENCY as
(

select SUM(AR_INVOICE)-SUM(CREdit_NOTE)+sum(AR_DOWNPAYMENT) 'TOTAL_SALE',
	   SUM(AR_INV_freight)-SUM(CREDIT_NOTE_freight)+sum(AR_DOWN_freight) 'freight',
	   SUM(AR_INV_cgst_sum)-sum(CREDIT_NOTE_cgst_sum)+sum(AR_DOWN_cgst_sum) 'CGST_SUM',
	   SUM(AR_INV_sgst_sum)-sum(CREDIT_NOTE_sgst_sum)+sum(AR_DOWN_sgst_sum) 'SGST_SUM',
	   SUM(AR_INV_igst_sum)-sum(CREDIT_NOTE_igst_sum)+sum(AR_DOWN_igst_sum) 'IGST_SUM',
	   SUM(AR_INV_cess_sum)-sum(CREDIT_NOTE_cess_sum)+sum(AR_DOWN_CESS_sum) 'Cess_sum'
	   ,locgstn,pindicator,month,year
from 
(select DOCENTRY,(case when objtype=13 then sum(basesum) else 0 end) 'AR_INVOICE',
		(case when objtype=14 then sum(basesum) else 0 end) 'CREDIT_NOTE',
		(case when objtype=203 then sum(basesum) else 0 end) 'AR_DOWNPAYMENT',
		---------------------------Freight
		(case when objtype=13 then (freight) else 0 end) 'AR_INV_freight',
		(case when objtype=14 then (freight) else 0 end) 'CREDIT_NOTE_freight',
		(case when objtype=203 then (freight) else 0 end) 'AR_DOWN_freight'
		---------------------------CGST
		,(case when objtype=13 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AR_INV_cgst_sum'
		,(case when objtype=14 then sum(cgst_sum)+(f_cgst)  else 0 end) 'CREDIT_NOTE_cgst_sum'
		,(case when objtype=203 then sum(cgst_sum)+(f_cgst)  else 0 end) 'AR_DOWN_cgst_sum'
		---------------------------SGST
		,(case when objtype=13 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'AR_INV_sgst_sum'
		,(case when objtype=14 then  sum(sgst_sum)+(f_sgst)  else 0 end) 'CREDIT_NOTE_sgst_sum'
		,(case when objtype=203 then sum(sgst_sum)+(f_sgst)  else 0 end) 'AR_DOWN_sgst_sum'
		---------------------------IGST
		,(case when objtype=13 then sum(igst_sum)+(f_igst)   else 0 end) 'AR_INV_igst_sum' 
		,(case when objtype=14 then sum(igst_sum)+(f_igst)   else 0 end) 'CREDIT_NOTE_igst_sum' 
		,(case when objtype=203 then sum(igst_sum)+(f_igst)   else 0 end) 'AR_DOWN_igst_sum' 
				----------------------------CESS
		,(case when objtype=13 then sum(cess_sum)+F_CESS  else 0 end) 'AR_INV_cess_sum' 
		,(case when objtype=14 then sum(cess_sum)+F_CESS   else 0 end) 'CREDIT_NOTE_cess_sum' 
		,(case when objtype=203 then sum(cess_sum)+F_CESS  else 0 end) 'AR_DOWN_cess_sum' 
,locgstn,pindicator,month,year
from
	
	(select docentry,objtype,pindicator,month,year
		   ,sum(basesum) 'basesum'
		   ,sum(cgst_sum) 'cgst_sum'
		   ,sum(sgst_sum) 'sgst_sum'
		   ,sum(igst_sum) 'igst_sum'
		   ,sum(cess_sum) 'cess_sum'
	       ,freight,f_cgst,f_sgst,f_igst,F_cESS
	       ,imporexp,reverse_charge
	       ,isgsttax,gsttrantyp
	       ,locgsttype,locgstn,locstategstn
	       ,bpgsttype,bpstatecode,BpGSTN,BpStateGSTN
		from PTS_GSTR3
        where  imporexp='N' and bpgsttype=6 AND TAX_CODE='IGST' and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,BpGSTN,year,BpStateGSTN)a
group by objtype,locgstn,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,DOCENTRY)b
--where locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
group by locgstn,pindicator,month,year
)
-------------------------------------------------------------------------------------


  select distinct b1.TOTAL_SALE 'b1_TOTAL_SALE',b1.freight 'b1_freight' ,b1.IGST_SUM 'b1_IGST_SUM',
				  b2.TOTAL_SALE 'b2_TOTAL_SALE',b2.freight 'b2_freight' ,b2.IGST_SUM 'b2_IGST_SUM',
				  b3.TOTAL_SALE 'b3_TOTAL_SALE',b3.freight 'b3_freight' ,b3.IGST_SUM 'b3_IGST_SUM'

   from PTS_GSTR3 C
   left Outer join LOCAL_SALES_BPGSTN_NULL_IGST B1  on c.locgstn=B1.locgstn and c.pindicator=B1.pindicator and c.month=B1.month
   left outer join LOCAL_SALES_BPGSTTYPE_COMPOSITE_LEVY_IGST B2 on c.locgstn=B2.locgstn and c.pindicator=B2.pindicator and c.month=B2.month
   left outer join LOCAL_SALES_BPGSTTYPE_UN_AGENCY B3 on c.locgstn=B3.locgstn and c.pindicator=B3.pindicator and c.month=B3.month
   where c.locgstn=@LOCATIONGSTIN and c.month=@month and c.pindicator=@year

   end
   go