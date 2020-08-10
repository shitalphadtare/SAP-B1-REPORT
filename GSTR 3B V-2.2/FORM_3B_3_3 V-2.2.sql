create PROCEDURE FORM_3B_3_3

@LOCATIONGSTIN  nvarchar(100),
@Month nvarchar(100),
@Year  nvarchar(100)

as
 Begin
  ;with IMPORT_PURCHASE_ITEM_HSN_NOT_NULL as
  (
  select SUM(AP_INVOICE)-SUM(DEBIT_NOTE)+sum(AP_DOWNPAYMENT) 'TOTAL_PURCHASE',
	   SUM(AP_INV_freight)-SUM(DEBIT_NOTE_freight)+sum(AP_DOWN_freight) 'freight',
	   SUM(AP_INV_cgst_sum)-sum(DEBIT_NOTE_cgst_sum)+sum(AP_DOWN_cgst_sum) 'CGST_SUM',
	   SUM(AP_INV_sgst_sum)-sum(DEBIT_NOTE_sgst_sum)+sum(AP_DOWN_sgst_sum) 'SGST_SUM',
	   SUM(AP_INV_igst_sum)-sum(DEBIT_NOTE_igst_sum)+sum(AP_DOWN_igst_sum) 'IGST_SUM',
	   SUM(AP_INV_cess_sum)-sum(DEBIT_NOTE_cess_sum)+sum(AP_DOWN_CESS_sum) 'Cess_sum'
	   ,locgstn,pindicator,month,year
from 
(select DOCENTRY,(case when objtype=18 then sum(basesum) else 0 end) 'AP_INVOICE',
		(case when objtype=19 then sum(basesum) else 0 end) 'DEBIT_NOTE',
		(case when objtype=204 then sum(basesum) else 0 end) 'AP_DOWNPAYMENT',
		---------------------------Freight
		(case when objtype=18 then (freight) else 0 end) 'AP_INV_freight',
		(case when objtype=19 then (freight) else 0 end) 'DEBIT_NOTE_freight',
		(case when objtype=204 then (freight) else 0 end) 'AP_DOWN_freight'
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
	       ,bpgsttype,bpstatecode,bpstategstn,BpGSTN,[HSN Code]
		from PTS_GSTR3
       where  imporexp='Y'  and isnull([HSN Code],'')<>'' 
	     and isgsttax='Y' --changes on 21-08-2019
	   --and Reverse_Charge='N'  --changes on 21-08-2019
	   and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,bpstategstn,year,BpGSTN,[HSN Code])a
group by objtype,locgstn,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,DOCENTRY)b

group by locgstn,pindicator,month,year
  
  ),
  --------------------------------------------
  IMPORT_PURCHASE_SERVICE_SAC_NOT_NULL as 
  (
  select SUM(AP_INVOICE)-SUM(DEBIT_NOTE)+sum(AP_DOWNPAYMENT) 'TOTAL_PURCHASE',
	   SUM(AP_INV_freight)-SUM(DEBIT_NOTE_freight)+sum(AP_DOWN_freight) 'freight',
	   SUM(AP_INV_cgst_sum)-sum(DEBIT_NOTE_cgst_sum)+sum(AP_DOWN_cgst_sum) 'CGST_SUM',
	   SUM(AP_INV_sgst_sum)-sum(DEBIT_NOTE_sgst_sum)+sum(AP_DOWN_sgst_sum) 'SGST_SUM',
	   SUM(AP_INV_igst_sum)-sum(DEBIT_NOTE_igst_sum)+sum(AP_DOWN_igst_sum) 'IGST_SUM',
	   SUM(AP_INV_cess_sum)-sum(DEBIT_NOTE_cess_sum)+sum(AP_DOWN_CESS_sum) 'Cess_sum'
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
	       ,bpgsttype,bpstatecode,bpstategstn,BpGSTN,[HSN Code]
		from PTS_GSTR3
       where  imporexp='Y' and doctype='S' 
	   and isgsttax='Y' --changes on 21-08-2019
	   -- and Reverse_Charge='N' ---changes on 21-08-2019
		and isnull([HSN Code],'')<>'' and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,bpstategstn,year,BpGSTN,[HSN Code])a
group by objtype,locgstn,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,docentry)b
group by locgstn,pindicator,month,year
  
  ),
  ---------------------------------------------------------------
  LOCAL_PURCHASE_NOT_REVERSE_GSTTYPE_NOT_3 as 
  (
  
select SUM(AP_INVOICE)-SUM(DEBIT_NOTE)+sum(AP_DOWNPAYMENT) 'TOTAL_PURCHASE',
	   SUM(AP_INV_freight)-SUM(DEBIT_NOTE_freight)+sum(AP_DOWN_freight) 'freight',
	   SUM(AP_INV_cgst_sum)-sum(DEBIT_NOTE_cgst_sum)+sum(AP_DOWN_cgst_sum) 'CGST_SUM',
	   SUM(AP_INV_sgst_sum)-sum(DEBIT_NOTE_sgst_sum)+sum(AP_DOWN_sgst_sum) 'SGST_SUM',
	   SUM(AP_INV_igst_sum)-sum(DEBIT_NOTE_igst_sum)+sum(AP_DOWN_igst_sum) 'IGST_SUM',
	   SUM(AP_INV_cess_sum)-sum(DEBIT_NOTE_cess_sum)+sum(AP_DOWN_CESS_sum) 'Cess_sum'
	   ,locgstn,pindicator,month,year
from 
(select (case when objtype=18 then sum(basesum) else 0 end) 'AP_INVOICE',
		(case when objtype=19 then sum(basesum) else 0 end) 'DEBIT_NOTE',
		(case when objtype=204 then sum(basesum) else 0 end) 'AP_DOWNPAYMENT',
		---------------------------Freight
		(case when objtype=18 then (freight) else 0 end) 'AP_INV_freight',
		(case when objtype=19 then (freight) else 0 end) 'DEBIT_NOTE_freight',
		(case when objtype=204 then (freight) else 0 end) 'AP_DOWN_freight'
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
,locgstn,pindicator,month,year,docentry
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
	       ,bpgsttype,bpstatecode,bpstategstn,BpGSTN,[HSN Code]
		from PTS_GSTR3
       where  imporexp='N' 	   and reverse_charge='N' 
	   and bpgsttype<>3 and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,bpstategstn,year,BpGSTN,[HSN Code])a
group by objtype,locgstn,pindicator,month,year,f_cgst,f_sgst,F_IGST,freight,F_CESS,docentry)b
--where locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
group by locgstn,pindicator,month,year
),
-------------------------------------------------------------
LOCAL_PURCHASE_REVERSE_CHARGE_TAX as 
(
select SUM(AP_INVOICE)-SUM(DEBIT_NOTE)+sum(AP_DOWNPAYMENT) 'TOTAL_PURCHASE',
	   SUM(AP_INV_freight)-SUM(DEBIT_NOTE_freight)+sum(AP_DOWN_freight) 'freight',
	   SUM(AP_INV_cgst_sum)-sum(DEBIT_NOTE_cgst_sum)+sum(AP_DOWN_cgst_sum) 'CGST_SUM',
	   SUM(AP_INV_sgst_sum)-sum(DEBIT_NOTE_sgst_sum)+sum(AP_DOWN_sgst_sum) 'SGST_SUM',
	   SUM(AP_INV_igst_sum)-sum(DEBIT_NOTE_igst_sum)+sum(AP_DOWN_igst_sum) 'IGST_SUM',
	   SUM(AP_INV_cess_sum)-sum(DEBIT_NOTE_cess_sum)+sum(AP_DOWN_CESS_sum) 'Cess_sum'
	   ,locgstn,pindicator,month,year
from 
(select DOCENTRY,(case when objtype=18 then sum(basesum) else 0 end) 'AP_INVOICE',
		(case when objtype=19 then sum(basesum) else 0 end) 'DEBIT_NOTE',
		(case when objtype=204 then sum(basesum) else 0 end) 'AP_DOWNPAYMENT',
		---------------------------Freight
		(case when objtype=18 then (freight) else 0 end) 'AP_INV_freight',
		(case when objtype=19 then (freight) else 0 end) 'DEBIT_NOTE_freight',
		(case when objtype=204 then (freight) else 0 end) 'AP_DOWN_freight'
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
	       ,freight,f_cgst,f_sgst,f_igst,F_cESS
	       ,imporexp,reverse_charge
	       ,isgsttax,gsttrantyp
	       ,locgsttype,locgstn,locstategstn
	       ,bpgsttype,bpstatecode,bpstategstn,BpGSTN,[HSN Code]
		from PTS_GSTR3
       where  imporexp='N' and reverse_charge='Y' and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_cESS,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,bpstategstn,year,BpGSTN,[HSN Code])a
group by objtype,locgstn,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_cESS,DOCENTRY)b
--where locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
group by locgstn,pindicator,month,year

)



  select distinct C1.IGST_SUM 'C1_IGST_SUM',C1.SGST_SUM 'C1_SGST_SUM'
			   ,C1.CGST_SUM 'C1_CGST_SUM',C1.Cess_sum 'C1_Cess_sum',
			   -----------------------------------------------------------
			    C2.IGST_SUM 'C2_IGST_SUM',C2.SGST_SUM 'C2_SGST_SUM'
			   ,C2.CGST_SUM 'C2_CGST_SUM',C2.Cess_sum 'C2_Cess_sum',
			      -----------------------------------------------------------
			    C3.IGST_SUM 'C3_IGST_SUM',C3.SGST_SUM 'C3_SGST_SUM'
			   ,C3.CGST_SUM 'C3_CGST_SUM',C3.Cess_sum 'C3_Cess_sum',
			      -----------------------------------------------------------
			    C4.IGST_SUM 'C4_IGST_SUM',C4.SGST_SUM 'C4_SGST_SUM'
			   ,C4.CGST_SUM 'C4_CGST_SUM',C4.Cess_sum 'C4_Cess_sum'

   from PTS_GSTR3 C
   left outer join IMPORT_PURCHASE_ITEM_HSN_NOT_NULL C1 on c.locgstn=C1.locgstn and c.pindicator=C1.pindicator and c.month=C1.month
   left outer join IMPORT_PURCHASE_SERVICE_SAC_NOT_NULL C2 on c.locgstn=C2.locgstn and c.pindicator=C2.pindicator and c.month=C2.month
   left outer join  LOCAL_PURCHASE_REVERSE_CHARGE_TAX C3 on c.locgstn=C3.locgstn and c.pindicator=C3.pindicator and c.month=C3.month 
   left outer join LOCAL_PURCHASE_NOT_REVERSE_GSTTYPE_NOT_3 C4   on c.locgstn=C4.locgstn and c.pindicator=C4.pindicator and c.month=C4.month 
   where c.locgstn=@LOCATIONGSTIN and c.month=@month and c.pindicator=@year
 END
 go
 