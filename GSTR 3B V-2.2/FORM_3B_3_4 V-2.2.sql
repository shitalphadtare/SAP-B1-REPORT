ALTER PROCEDURE FORM_3B_3_4

@LOCATIONGSTIN  nvarchar(100),
@Month nvarchar(100),
@Year  nvarchar(100)

as
 Begin
 ;with PURCHASE_INTERSTATE_GSTINTYPE_COMPO_ITEM_NILRATED as
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
		,(case when objtype=18 then sum(cess_sum)+F_ceSS  else 0 end) 'AP_INV_cess_sum' 
		,(case when objtype=19 then sum(cess_sum)+F_ceSS   else 0 end) 'DEBIT_NOTE_cess_sum' 
		,(case when objtype=204 then sum(cess_sum)+F_ceSS   else 0 end) 'AP_DOWN_cess_sum' 
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
       where (Item_Tax_Type in ('E','N') OR bpgsttype=3 ) and LocStateCode<>billingState and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,bpstategstn,year,BpGSTN,[HSN Code])a
group by objtype,locgstn,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,docentry)b
group by locgstn,pindicator,month,year 
 ),
 -----------------------------------------------------
 PURCHASE_INTRASTATE_GSTINTYPE_COMPO_ITEM_NILRATED as
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
       where (Item_Tax_Type in ('E','N') or bpgsttype=3) and LocStateCode=billingState  and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,bpstategstn,year,BpGSTN,[HSN Code])a
group by objtype,locgstn,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,docentry)b
group by locgstn,pindicator,month,year
 ),
 PURCHASE_INTERSTATE_NONGST as
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
       where isgsttax='N' and 
     /**10-09-2019  LocStateCode<>BpStateCode  **/
      LocStateCode<> billingState  /**10-09-2019 **/
        and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,bpstategstn,year,BpGSTN,[HSN Code])a
group by objtype,locgstn,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,docentry)b
group by locgstn,pindicator,month,year
 
 ),
 ----------------------------------------------------------------------
 PURCHASE_INTRASTATE_NONGST as (
 select SUM(AP_INVOICE)-SUM(DEBIT_NOTE)+sum(AP_DOWNPAYMENT) 'TOTAL_PURCHASE',
	   SUM(AP_INV_freight)-SUM(DEBIT_NOTE_freight)+sum(AP_DOWN_freight) 'freight',
	   SUM(AP_INV_cgst_sum)-sum(DEBIT_NOTE_cgst_sum)+sum(AP_DOWN_cgst_sum) 'CGST_SUM',
	   SUM(AP_INV_sgst_sum)-sum(DEBIT_NOTE_sgst_sum)+sum(AP_DOWN_sgst_sum) 'SGST_SUM',
	   SUM(AP_INV_igst_sum)-sum(DEBIT_NOTE_igst_sum)+sum(AP_DOWN_igst_sum) 'IGST_SUM',
	   SUM(AP_INV_cess_sum)-sum(DEBIT_NOTE_cess_sum)+sum(AP_DOWN_igst_sum) 'Cess_sum'
	   ,locgstn,pindicator,month,year
from 
(select DOCENTRY,(case when objtype=18 then sum(basesum) else 0 end) 'AP_INVOICE',
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
       where isgsttax='N' and
       /**10-09-2019  LocStateCode=isnull(BpStateCode,LocStateCode) **/
        LocStateCode=isnull(billingState,LocStateCode) /**10-09-2019 **/
       and locgstn=@LOCATIONGSTIN and month=@month and pindicator=@year
		group by docentry,objtype,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,imporexp,reverse_charge,isgsttax,gsttrantyp
		,locgsttype,locgstn,locstategstn,bpgsttype,bpstatecode,bpstategstn,year,BpGSTN,[HSN Code])a
group by objtype,locgstn,pindicator,month,year,freight,f_cgst,f_sgst,f_igst,F_CESS,docentry)b
group by locgstn,pindicator,month,year
 
 
 )

 Select distinct 
 --changes on 20-09-2019
 a1.TOTAL_PURCHASE 'A1.IGST_SUM',a2.TOTAL_PURCHASE 'A2_CGST_SUM',0 'A2_SGST_SUM'
 -------------------------
 ,A3.Total_Purchase 'A3_Total_Purchase'
 ,A4.Total_Purchase 'A4_Total_Purchase'

  from PTS_GSTR3 C
left outer join PURCHASE_INTERSTATE_GSTINTYPE_COMPO_ITEM_NILRATED A1 on c.locgstn=a1.locgstn and c.pindicator=a1.pindicator and c.month=a1.month
left outer join  PURCHASE_INTRASTATE_GSTINTYPE_COMPO_ITEM_NILRATED A2 on c.locgstn=c.locgstn and c.pindicator=c.pindicator and c.month=A2.month
left outer join  PURCHASE_INTERSTATE_NONGST A3 on c.locgstn=A3.locgstn and c.pindicator=A3.pindicator and c.month=A3.month
left outer join PURCHASE_INTRASTATE_NONGST A4 on c.locgstn=A4.locgstn and c.pindicator=A4.pindicator and c.month=A4.month
where c.locgstn=@LOCATIONGSTIN and c.month=@month and c.pindicator=@year

end 
GO