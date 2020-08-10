alter View PTS_GSTR3 as

--------------------------------AR INVOICE & DEBIT NOTE----------------
select	inv.docentry 
		,inv.objtype
		,PIndicator
		,datename(month,inv.docdate) 'Month'
		,year(inv.docdate) 'Year'
		,inv.docdate
		,iv1.VisOrder
		,ITM.GstTaxCtg 'Item_Tax_Type'
		,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry =(case when  IV1.SACEntry is  null then  ITM.SACEntry else IV1.SACEntry end))  
		When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where AbsEntry = (case when  IV1.HsnEntry is  null then  ITM.chapterid else IV1.HsnEntry end)) Else '' END) 'HSN Code'
		,CASE when IV1.AssblValue=0 then 
(CASE when INV.DiscPrcnt=0 then isnull(IV1.LineTotal,0) 
else ( isnull(IV1.LineTotal,0) -(isnull(IV1.LineTotal,0)*isnull(INV.DiscPrcnt,0)/100))End)
else (IV1.AssblValue*IV1.Quantity) end 'BaseSum'
		,iv1.VatPrcnt 'VatPercent'
		,(isnull(cgst.taxsum,0))'CGST_Sum'
		,(isnull(sgst.taxsum,0))'SGST_Sum'
		,(isnull(igst.taxsum,0))'IGST_Sum'
		,(isnull(cess.taxsum,0)) 'Cess_Sum'
		,isnull(iv3.linetotal,0) 'freight'
		,isnull(fcgst.TaxSum,0) 'F_CGST'
		,isnull(fsgst.TaxSum,0) 'F_SGST'
		,isnull(figst.TaxSum,0) 'F_IGST'
		,isnull(fcess.TaxSum,0) 'F_CESS'
		,isnull(t1.ImpOrExp, 'N') as ImpOrExp
		,isnull(t1.LocGSTType, 0) as LocGSTType
		,isnull(t1.LocGSTN, '') as LocGSTN
		,isnull(t1.LocStatCod, '') as LocStateCode
		,isnull(t1.LocStaGSTN, '') as LocStateGSTN
		,isnull(t1.BpGSTN, '') as BpGSTN
		,isnull(t1.BpGSTType, 0) as BpGSTType
		,isnull(t1.BpStateCod, cd1.state) as BpStateCode
		,isnull(t1.BpStatGSTN, '') as BpStateGSTN
		--,t4.RvsChrgPrc
		,case when isnull(CGST.RvschrgTax,0) + isnull(SGST.RvschrgTax,0) + isnull(IGST.RvschrgTax,0)<> 0 
		then 'Y' else 'N' end as Reverse_Charge
		,(select distinct case when statype in (-100,-110,-120) then 'Y' else 'N' end from inv4 where docentry=inv.docentry AND IV1.LineNum=LineNum AND RelateType=1 AND ExpnsCode=-1) 'isgsttax'
		,(select distinct case when statype in (-100,-110) then 'CGST' when statype in (-120) then  'IGST' when statype in (-130) then  'CESS' end from inv4 where docentry=inv.docentry AND IV1.LineNum=LineNum AND RelateType=1 AND ExpnsCode=-1) 'TAX_CODE'
		,inv.GSTTranTyp		
		,inv.doctype

from oinv inv
inner join inv1 iv1 on inv.docentry=iv1.docentry
left outer join oitm itm on iv1.itemcode=itm.itemcode
left outer join inv4 cgst On IV1.DocEntry=CGST.DocEntry and IV1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 AND CGST.ExpnsCode=-1
left outer join inv4 Sgst On IV1.DocEntry=SGST.DocEntry and IV1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1 AND SGST.ExpnsCode=-1
left outer join inv4 igst on inv.docentry=igst.docentry and igst.statype=-120 and iv1.linenum=igst.linenum and igst.RelateType=1 AND IGST.ExpnsCode=-1
left outer join inv4 cess on inv.docentry=cess.docentry and cess.statype=-130  and iv1.linenum=cess.linenum and cess.RelateType=1  AND cess.ExpnsCode=-1
inner join INV12 t1 on inv.DocEntry = t1.DocEntry
left outer join (select sum(linetotal) 'linetotal',docentry from inv3 group by docentry) iv3 on inv.docentry=iv3.docentry
left outer join (select sum(taxsum) 'TaxSum',docentry from inv4 where statype=-100 and RelateType=3  group by docentry) Fcgst on iv3.docentry=Fcgst.docentry 
left outer join (select sum(taxsum) 'TaxSum',docentry from inv4 where statype=-110 and RelateType=3  group by docentry) FSgst on iv3.docentry=Fsgst.docentry
left outer join (select sum(taxsum)  'TaxSum',docentry from inv4 where statype=-120 and RelateType=3  group by docentry) Figst on iv3.docentry=Figst.docentry
left outer join (select sum(taxsum)  'TaxSum',docentry from inv4 where statype=-130 and RelateType=3  group by docentry) FCess on iv3.docentry=FCess.docentry
left outer join CRD1 CD1 on CD1.CardCode=INV.CardCode and CD1.AdresType='B' and INV.paytocode=CD1.Address
where inv.canceled<>'Y' and inv.canceled<>'C' --and inv.docentry=27
 union all


 --------------------------------CREDIT NOTE----------------
select	RIN.docentry 
		,RIN.objtype
		,PIndicator
		,datename(month,RIN.docdate) 'Month'
		,year(RIN.docdate) 'Year'
		,RIN.docdate
		,iv1.VisOrder
		,ITM.GstTaxCtg 'Item_Tax_Type'
		,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry =(case when  IV1.SACEntry is  null then  ITM.SACEntry else IV1.SACEntry end))  
		When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where AbsEntry = (case when  IV1.HsnEntry is  null then  ITM.chapterid else IV1.HsnEntry end)) Else '' END) 'HSN Code'
		,CASE when IV1.AssblValue=0 then 
(CASE when RIN.DiscPrcnt=0 then isnull(IV1.LineTotal,0) 
else ( isnull(IV1.LineTotal,0) -(isnull(IV1.LineTotal,0)*isnull(RIN.DiscPrcnt,0)/100))End)
else (IV1.AssblValue*IV1.Quantity) end 'BaseSum'
		,iv1.VatPrcnt 'VatPercent'
		,(isnull(cgst.taxsum,0))'CGST_Sum'
		,(isnull(sgst.taxsum,0))'SGST_Sum'
		,(isnull(igst.taxsum,0))'IGST_Sum'
		,(isnull(cess.taxsum,0)) 'Cess_Sum'
		,isnull(iv3.linetotal,0) 'freight'
		,isnull(fcgst.TaxSum,0) 'F_CGST'
		,isnull(fsgst.TaxSum,0) 'F_SGST'
		,isnull(figst.TaxSum,0) 'F_IGST'
		,isnull(fcess.TaxSum,0) 'F_CESS'
		,isnull(t1.ImpOrExp, 'N') as ImpOrExp
		,isnull(t1.LocGSTType, 0) as LocGSTType
		,isnull(t1.LocGSTN, '') as LocGSTN
		,isnull(t1.LocStatCod, '') as LocStateCode
		,isnull(t1.LocStaGSTN, '') as LocStateGSTN
		,isnull(t1.BpGSTN, '') as BpGSTN
		,isnull(t1.BpGSTType, 0) as BpGSTType
		,isnull(t1.BpStateCod, cd1.state) as BpStateCode
		,isnull(t1.BpStatGSTN, '') as BpStateGSTN
		--,t4.RvsChrgPrc
		,case when isnull(CGST.RvschrgTax,0) + isnull(SGST.RvschrgTax,0) + isnull(IGST.RvschrgTax,0)<> 0
		 then 'Y' else 'N' end as Reverse_Charge
		,(select distinct case when statype in (-100,-110,-120) then 'Y' else 'N' end from RIN4 where docentry=RIN.docentry AND IV1.LineNum=LineNum AND RelateType=1 AND ExpnsCode=-1)  'isgsttax'
		,(select distinct case when statype in (-100,-110) then 'CGST' when statype in (-120) then  'IGST'  end from RIN4 where docentry=RIN.docentry AND IV1.LineNum=LineNum AND RelateType=1 AND ExpnsCode=-1) 'TAX_CODE'
		,RIN.GSTTranTyp		
		,RIN.doctype

from oRIN RIN
inner join RIN1 iv1 on RIN.docentry=iv1.docentry
left outer join oitm itm on iv1.itemcode=itm.itemcode
left outer join RIN4 cgst On IV1.DocEntry=CGST.DocEntry and IV1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 AND CGST.ExpnsCode=-1
left outer join RIN4 Sgst On IV1.DocEntry=SGST.DocEntry and IV1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1 AND SGST.ExpnsCode=-1
left outer join RIN4 igst on RIN.docentry=igst.docentry and igst.statype=-120 and iv1.linenum=igst.linenum and igst.RelateType=1 AND IGST.ExpnsCode=-1
left outer join RIN4 cess on RIN.docentry=cess.docentry and cess.statype=-130  and iv1.linenum=cess.linenum and cess.RelateType=1  AND cess.ExpnsCode=-1
inner join RIN12 t1 on RIN.DocEntry = t1.DocEntry

left outer join (select sum(linetotal) 'linetotal',docentry from RIN3 group by docentry) iv3 on RIN.docentry=iv3.docentry
left outer join (select sum(taxsum) 'TaxSum',docentry from RIN4 where statype=-100 and RelateType=3  group by docentry) Fcgst on iv3.docentry=Fcgst.docentry 
left outer join (select sum(taxsum) 'TaxSum',docentry from RIN4 where statype=-110 and RelateType=3  group by docentry) FSgst on iv3.docentry=Fsgst.docentry
left outer join (select sum(taxsum)  'TaxSum',docentry from RIN4 where statype=-120 and RelateType=3  group by docentry) Figst on iv3.docentry=Figst.docentry
left outer join (select sum(taxsum)  'TaxSum',docentry from rin4 where statype=-130 and RelateType=3  group by docentry) FCess on iv3.docentry=FCess.docentry
left outer join CRD1 CD1 on CD1.CardCode=RIN.CardCode and CD1.AdresType='B' and RIN.paytocode=CD1.Address
where RIN.canceled<>'Y' and RIN.canceled<>'C' --and RIN.docentry=27

UNIOn all

 --------------------------------AR DOWN PAYMENT----------------
select	DPI.docentry 
		,DPI.objtype
		,PIndicator
		,datename(month,DPI.docdate) 'Month'
		,year(DPI.docdate) 'Year'
		,DPI.docdate
		,iv1.VisOrder
		,ITM.GstTaxCtg 'Item_Tax_Type'
		,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry =(case when  IV1.SACEntry is  null then  ITM.SACEntry else IV1.SACEntry end))  
		When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where AbsEntry = (case when  IV1.HsnEntry is  null then  ITM.chapterid else IV1.HsnEntry end)) Else '' END) 'HSN Code'
		,CASE when IV1.AssblValue=0 then 
(CASE when DPI.DiscPrcnt=0 then isnull(IV1.LineTotal,0) 
else ( isnull(IV1.LineTotal,0) -(isnull(IV1.LineTotal,0)*isnull(DPI.DiscPrcnt,0)/100))End)
else (IV1.AssblValue*IV1.Quantity) end 'BaseSum'
		,iv1.VatPrcnt 'VatPercent'
		,(isnull(cgst.taxsum,0))'CGST_Sum'
		,(isnull(sgst.taxsum,0))'SGST_Sum'
		,(isnull(igst.taxsum,0))'IGST_Sum'
		,(isnull(cess.taxsum,0)) 'Cess_Sum'
		,isnull(iv3.linetotal,0) 'freight'
		,isnull(fcgst.TaxSum,0) 'F_CGST'
		,isnull(fsgst.TaxSum,0) 'F_SGST'
		,isnull(figst.TaxSum,0) 'F_IGST'
		,isnull(fcess.TaxSum,0) 'F_CESS'
		,isnull(t1.ImpOrExp, 'N') as ImpOrExp
		,isnull(t1.LocGSTType, 0) as LocGSTType
		,isnull(t1.LocGSTN, '') as LocGSTN
		,isnull(t1.LocStatCod, '') as LocStateCode
		,isnull(t1.LocStaGSTN, '') as LocStateGSTN
		,isnull(t1.BpGSTN, '') as BpGSTN
		,isnull(t1.BpGSTType, 0) as BpGSTType
		,isnull(t1.BpStateCod,cd1.state) as BpStateCode
		,isnull(t1.BpStatGSTN, '') as BpStateGSTN
		--,t4.RvsChrgPrc
		,case when isnull(CGST.RvschrgTax,0) + isnull(SGST.RvschrgTax,0) + isnull(IGST.RvschrgTax,0)<> 0 
		 then 'Y' else 'N' end as Reverse_Charge
		,(select distinct case when statype in (-100,-110,-120) then 'Y' else 'N' end from dpi4 where docentry=dpi.docentry AND IV1.LineNum=LineNum AND RelateType=1 AND ExpnsCode=-1) 'isgsttax'
		,(select distinct case when statype in (-100,-110) then 'CGST' when statype in (-120) then  'IGST'  end from DPI4 where docentry=DPI.docentry AND IV1.LineNum=LineNum AND RelateType=1 AND ExpnsCode=-1) 'TAX_CODE'
		,DPI.GSTTranTyp		
		,DPI.doctype

from oDPI DPI
inner join DPI1 iv1 on DPI.docentry=iv1.docentry
left outer join oitm itm on iv1.itemcode=itm.itemcode
left outer join DPI4 cgst On IV1.DocEntry=CGST.DocEntry and IV1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 AND CGST.ExpnsCode=-1
left outer join DPI4 Sgst On IV1.DocEntry=SGST.DocEntry and IV1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1 AND SGST.ExpnsCode=-1
left outer join DPI4 igst on DPI.docentry=igst.docentry and igst.statype=-120 and iv1.linenum=igst.linenum and igst.RelateType=1 AND IGST.ExpnsCode=-1
left outer join DPI4 cess on DPI.docentry=cess.docentry and cess.statype=-130  and iv1.linenum=cess.linenum and cess.RelateType=1  AND cess.ExpnsCode=-1
inner join DPI12 t1 on DPI.DocEntry = t1.DocEntry

left outer join (select sum(linetotal) 'linetotal',docentry from DPI3 group by docentry) iv3 on DPI.docentry=iv3.docentry
left outer join (select sum(taxsum) 'TaxSum',docentry from DPI4 where statype=-100 and RelateType=3  group by docentry) Fcgst on iv3.docentry=Fcgst.docentry 
left outer join (select sum(taxsum) 'TaxSum',docentry from DPI4 where statype=-110 and RelateType=3  group by docentry) FSgst on iv3.docentry=Fsgst.docentry
left outer join (select sum(taxsum)  'TaxSum',docentry from DPI4 where statype=-120 and RelateType=3  group by docentry) Figst on iv3.docentry=Figst.docentry
left outer join (select sum(taxsum)  'TaxSum',docentry from dpi4 where statype=-130 and RelateType=3  group by docentry) FCess on iv3.docentry=FCess.docentry
left outer join CRD1 CD1 on CD1.CardCode=DPI.CardCode and CD1.AdresType='B' and DPI.paytocode=CD1.Address
where DPI.canceled<>'Y' and DPI.canceled<>'C' and DPI.PaidToDate <>0 --and RIN.docentry=27

union all



 --------------------------------AP INVOICE----------------
select	PCH.docentry 
		,PCH.objtype
		,PIndicator
		,datename(month,PCH.docdate) 'Month'
		,year(PCH.docdate) 'Year'
		,PCH.docdate
		,iv1.VisOrder
		,ITM.GstTaxCtg 'Item_Tax_Type'
		,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry =(case when  IV1.SACEntry is  null then  ITM.SACEntry else IV1.SACEntry end))  
		When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where AbsEntry = (case when  IV1.HsnEntry is  null then  ITM.chapterid else IV1.HsnEntry end)) Else '' END) 'HSN Code'
		,CASE when IV1.AssblValue=0 then 
(CASE when PCH.DiscPrcnt=0 then isnull(IV1.LineTotal,0) 
else ( isnull(IV1.LineTotal,0) -(isnull(IV1.LineTotal,0)*isnull(PCH.DiscPrcnt,0)/100))End)
else (IV1.AssblValue*IV1.Quantity) end 'BaseSum'
		,iv1.VatPrcnt 'VatPercent'
		,(isnull(cgst.taxsum,0))'CGST_Sum'
		,(isnull(sgst.taxsum,0))'SGST_Sum'
		,(isnull(igst.taxsum,0))'IGST_Sum'
		,(isnull(cess.taxsum,0)) 'Cess_Sum'
		,isnull(iv3.linetotal,0) 'freight'
		,isnull(fcgst.TaxSum,0) 'F_CGST'
		,isnull(fsgst.TaxSum,0) 'F_SGST'
		,isnull(figst.TaxSum,0) 'F_IGST'
		,isnull(fcess.TaxSum,0) 'F_CESS'
		,isnull(t1.ImpOrExp, 'N') as ImpOrExp
		,isnull(t1.LocGSTType, 0) as LocGSTType
		,isnull(t1.LocGSTN, '') as LocGSTN
		,isnull(t1.LocStatCod, '') as LocStateCode
		,isnull(t1.LocStaGSTN, '') as LocStateGSTN
		,isnull(t1.BpGSTN, '') as BpGSTN
		,isnull(t1.BpGSTType, 0) as BpGSTType
		,isnull(t1.BpStateCod,cd1.state) as BpStateCode
		,isnull(t1.BpStatGSTN, '') as BpStateGSTN
		--,t4.RvsChrgPrc
		,case when isnull(CGST.RvschrgTax,0) + isnull(SGST.RvschrgTax,0) + isnull(IGST.RvschrgTax,0)<> 0
		then 'Y' else 'N' end as Reverse_Charge
		,(select distinct case when statype in (-100,-110,-120) then 'Y' else 'N' end from pch4 where docentry=pch.docentry AND IV1.LineNum=LineNum AND RelateType=1 AND ExpnsCode=-1) 'isgsttax'
		,(select distinct case when statype in (-100,-110) then 'CGST' when statype in (-120) then  'IGST'  end from PCH4 where docentry=PCH.docentry AND IV1.LineNum=LineNum AND RelateType=1 AND ExpnsCode=-1) 'TAX_CODE'
		,PCH.GSTTranTyp		
		,PCH.doctype

from oPCH PCH
inner join PCH1 iv1 on PCH.docentry=iv1.docentry
left outer join oitm itm on iv1.itemcode=itm.itemcode
left outer join PCH4 cgst On IV1.DocEntry=CGST.DocEntry and IV1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 AND CGST.ExpnsCode=-1
left outer join PCH4 Sgst On IV1.DocEntry=SGST.DocEntry and IV1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1 AND SGST.ExpnsCode=-1
left outer join PCH4 igst on PCH.docentry=igst.docentry and igst.statype=-120 and iv1.linenum=igst.linenum and igst.RelateType=1 AND IGST.ExpnsCode=-1
left outer join PCH4 cess on PCH.docentry=cess.docentry and cess.statype=-130  and iv1.linenum=cess.linenum and cess.RelateType=1  AND cess.ExpnsCode=-1
inner join PCH12 t1 on PCH.DocEntry = t1.DocEntry

left outer join (select sum(linetotal) 'linetotal',docentry from PCH3 group by docentry) iv3 on PCH.docentry=iv3.docentry
left outer join (select sum(taxsum) 'TaxSum',docentry from PCH4 where statype=-100 and RelateType=3  group by docentry) Fcgst on iv3.docentry=Fcgst.docentry 
left outer join (select sum(taxsum) 'TaxSum',docentry from PCH4 where statype=-110 and RelateType=3  group by docentry) FSgst on iv3.docentry=Fsgst.docentry
left outer join (select sum(taxsum)  'TaxSum',docentry from PCH4 where statype=-120 and RelateType=3  group by docentry) Figst on iv3.docentry=Figst.docentry
left outer join (select sum(taxsum)  'TaxSum',docentry from pch4 where statype=-130 and RelateType=3  group by docentry) FCess on iv3.docentry=FCess.docentry
left outer join CRD1 CD1 on CD1.CardCode=PCH.CardCode and CD1.AdresType='B' and PCH.paytocode=CD1.Address
where PCH.canceled<>'Y' and PCH.canceled<>'C' --and RIN.docentry=27

union all



 --------------------------------DEBIT NOTE----------------
select	RPC.docentry 
		,RPC.objtype
		,PIndicator
		,datename(month,RPC.docdate) 'Month'
		,year(RPC.docdate) 'Year'
		,RPC.docdate
		,iv1.VisOrder
		,ITM.GstTaxCtg 'Item_Tax_Type'
		,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry =(case when  IV1.SACEntry is  null then  ITM.SACEntry else IV1.SACEntry end))  
		When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where AbsEntry = (case when  IV1.HsnEntry is  null then  ITM.chapterid else IV1.HsnEntry end)) Else '' END) 'HSN Code'
		,CASE when IV1.AssblValue=0 then 
(CASE when RPC.DiscPrcnt=0 then isnull(IV1.LineTotal,0) 
else ( isnull(IV1.LineTotal,0) -(isnull(IV1.LineTotal,0)*isnull(RPC.DiscPrcnt,0)/100))End)
else (IV1.AssblValue*IV1.Quantity) end 'BaseSum'
		,iv1.VatPrcnt 'VatPercent'
		,(isnull(cgst.taxsum,0))'CGST_Sum'
		,(isnull(sgst.taxsum,0))'SGST_Sum'
		,(isnull(igst.taxsum,0))'IGST_Sum'
		,(isnull(cess.taxsum,0)) 'Cess_Sum'
		,isnull(iv3.linetotal,0) 'freight'
		,isnull(fcgst.TaxSum,0) 'F_CGST'
		,isnull(fsgst.TaxSum,0) 'F_SGST'
		,isnull(figst.TaxSum,0) 'F_IGST'
		,isnull(fcess.TaxSum,0) 'F_CESS'
		,isnull(t1.ImpOrExp, 'N') as ImpOrExp
		,isnull(t1.LocGSTType, 0) as LocGSTType
		,isnull(t1.LocGSTN, '') as LocGSTN
		,isnull(t1.LocStatCod, '') as LocStateCode
		,isnull(t1.LocStaGSTN, '') as LocStateGSTN
		,isnull(t1.BpGSTN, '') as BpGSTN
		,isnull(t1.BpGSTType, 0) as BpGSTType
		,isnull(t1.BpStateCod,cd1.state) as BpStateCode
		,isnull(t1.BpStatGSTN, '') as BpStateGSTN
		--,t4.RvsChrgPrc
		,case when isnull(CGST.RvschrgTax,0) + isnull(SGST.RvschrgTax,0) + isnull(IGST.RvschrgTax,0)<> 0 
		then 'Y' else 'N' end as Reverse_Charge
		,(select distinct case when statype in (-100,-110,-120) then 'Y' else 'N' end from rpc4 where docentry=rpc.docentry AND IV1.LineNum=LineNum AND RelateType=1 AND ExpnsCode=-1) 'isgsttax'
		,(select distinct case when statype in (-100,-110) then 'CGST' when statype in (-120) then  'IGST'  end from RPC4 where docentry=RPC.docentry AND IV1.LineNum=LineNum AND RelateType=1 AND ExpnsCode=-1) 'TAX_CODE'
		,RPC.GSTTranTyp		
		,RPC.doctype

from oRPC RPC
inner join RPC1 iv1 on RPC.docentry=iv1.docentry
left outer join oitm itm on iv1.itemcode=itm.itemcode
left outer join RPC4 cgst On IV1.DocEntry=CGST.DocEntry and IV1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 AND CGST.ExpnsCode=-1
left outer join RPC4 Sgst On IV1.DocEntry=SGST.DocEntry and IV1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1 AND SGST.ExpnsCode=-1
left outer join RPC4 igst on RPC.docentry=igst.docentry and igst.statype=-120 and iv1.linenum=igst.linenum and igst.RelateType=1 AND IGST.ExpnsCode=-1
left outer join RPC4 cess on RPC.docentry=cess.docentry and cess.statype=-130  and iv1.linenum=cess.linenum and cess.RelateType=1  AND cess.ExpnsCode=-1
inner join RPC12 t1 on RPC.DocEntry = t1.DocEntry

left outer join (select sum(linetotal) 'linetotal',docentry from RPC3 group by docentry) iv3 on RPC.docentry=iv3.docentry
left outer join (select sum(taxsum) 'TaxSum',docentry from RPC4 where statype=-100 and RelateType=3  group by docentry) Fcgst on iv3.docentry=Fcgst.docentry 
left outer join (select sum(taxsum) 'TaxSum',docentry from RPC4 where statype=-110 and RelateType=3  group by docentry) FSgst on iv3.docentry=Fsgst.docentry
left outer join (select sum(taxsum)  'TaxSum',docentry from RPC4 where statype=-120 and RelateType=3  group by docentry) Figst on iv3.docentry=Figst.docentry
left outer join (select sum(taxsum)  'TaxSum',docentry from rpc4 where statype=-130 and RelateType=3  group by docentry) FCess on iv3.docentry=FCess.docentry
left outer join CRD1 CD1 on CD1.CardCode=RPC.CardCode and CD1.AdresType='B' and RPC.paytocode=CD1.Address
where RPC.canceled<>'Y' and RPC.canceled<>'C' --and RIN.docentry=27


UNION ALL


 -------------------------------AP DOWNPAYMENT---------------
select	DPO.docentry 
		,DPO.objtype
		,PIndicator
		,datename(month,DPO.docdate) 'Month'
		,year(DPO.docdate) 'Year'
		,DPO.docdate
		,iv1.VisOrder
		,ITM.GstTaxCtg 'Item_Tax_Type'
		,(CASE When ITM.ItemClass = 1 Then (Select ServCode from OSAC Where AbsEntry =(case when  IV1.SACEntry is  null then  ITM.SACEntry else IV1.SACEntry end))  
		When ITM.ItemClass  = 2 Then (select ChapterID  from ochp where AbsEntry = (case when  IV1.HsnEntry is  null then  ITM.chapterid else IV1.HsnEntry end)) Else '' END) 'HSN Code'
		,CASE when IV1.AssblValue=0 then 
(CASE when DPO.DiscPrcnt=0 then isnull(IV1.LineTotal,0) 
else ( isnull(IV1.LineTotal,0) -(isnull(IV1.LineTotal,0)*isnull(DPO.DiscPrcnt,0)/100))End)
else (IV1.AssblValue*IV1.Quantity) end 'BaseSum'
		,iv1.VatPrcnt 'VatPercent'
		,(isnull(cgst.taxsum,0))'CGST_Sum'
		,(isnull(sgst.taxsum,0))'SGST_Sum'
		,(isnull(igst.taxsum,0))'IGST_Sum'
		,(isnull(cess.taxsum,0)) 'Cess_Sum'
		,isnull(iv3.linetotal,0) 'freight'
		,isnull(fcgst.TaxSum,0) 'F_CGST'
		,isnull(fsgst.TaxSum,0) 'F_SGST'
		,isnull(figst.TaxSum,0) 'F_IGST'
		,isnull(fcess.TaxSum,0) 'F_CESS'
		,isnull(t1.ImpOrExp, 'N') as ImpOrExp
		,isnull(t1.LocGSTType, 0) as LocGSTType
		,isnull(t1.LocGSTN, '') as LocGSTN
		,isnull(t1.LocStatCod, '') as LocStateCode
		,isnull(t1.LocStaGSTN, '') as LocStateGSTN
		,isnull(t1.BpGSTN, '') as BpGSTN
		,isnull(t1.BpGSTType, 0) as BpGSTType
		,isnull(t1.BpStateCod,cd1.state) as BpStateCode
		,isnull(t1.BpStatGSTN, '') as BpStateGSTN
		--,t4.RvsChrgPrc
		,case when isnull(CGST.RvschrgTax,0) + isnull(SGST.RvschrgTax,0) + isnull(IGST.RvschrgTax,0)<> 0 
		 then 'Y' else 'N' end as Reverse_Charge
		,(select distinct case when statype in (-100,-110,-120) then 'Y' else 'N' end from dpo4 where docentry=dpo.docentry AND IV1.LineNum=LineNum AND RelateType=1 AND ExpnsCode=-1) 'isgsttax'
		,(select distinct case when statype in (-100,-110) then 'CGST' when statype in (-120) then  'IGST'  end from DPO4 where docentry=DPO.docentry AND IV1.LineNum=LineNum AND RelateType=1 AND ExpnsCode=-1) 'TAX_CODE'
		,DPO.GSTTranTyp		
		,DPO.doctype

from oDPO DPO
inner join DPO1 iv1 on DPO.docentry=iv1.docentry
left outer join oitm itm on iv1.itemcode=itm.itemcode
left outer join DPO4 cgst On IV1.DocEntry=CGST.DocEntry and IV1.LineNum=CGST.LineNum and CGST.staType in (-100) and CGST.RelateType=1 AND CGST.ExpnsCode=-1
left outer join DPO4 Sgst On IV1.DocEntry=SGST.DocEntry and IV1.LineNum=SGST.LineNum and SGST.staType in (-110) and SGST.RelateType=1 AND SGST.ExpnsCode=-1
left outer join DPO4 igst on DPO.docentry=igst.docentry and igst.statype=-120 and iv1.linenum=igst.linenum and igst.RelateType=1 AND IGST.ExpnsCode=-1
left outer join DPO4 cess on DPO.docentry=cess.docentry and cess.statype=-130  and iv1.linenum=cess.linenum and cess.RelateType=1  AND cess.ExpnsCode=-1
inner join DPO12 t1 on DPO.DocEntry = t1.DocEntry

left outer join (select sum(linetotal) 'linetotal',docentry from DPO3 group by docentry) iv3 on DPO.docentry=iv3.docentry
left outer join (select sum(taxsum) 'TaxSum',docentry from DPO4 where statype=-100 and RelateType=3  group by docentry) Fcgst on iv3.docentry=Fcgst.docentry 
left outer join (select sum(taxsum) 'TaxSum',docentry from DPO4 where statype=-110 and RelateType=3  group by docentry) FSgst on iv3.docentry=Fsgst.docentry
left outer join (select sum(taxsum)  'TaxSum',docentry from DPO4 where statype=-120 and RelateType=3  group by docentry) Figst on iv3.docentry=Figst.docentry
left outer join (select sum(taxsum)  'TaxSum',docentry from dpo4 where statype=-130 and RelateType=3  group by docentry) FCess on iv3.docentry=FCess.docentry
left outer join CRD1 CD1 on CD1.CardCode=DPO.CardCode and CD1.AdresType='B' and DPO.paytocode=CD1.Address
where DPO.canceled<>'Y' and DPO.canceled<>'C' and DPO.PaidToDate <>0 --and RIN.docentry=27