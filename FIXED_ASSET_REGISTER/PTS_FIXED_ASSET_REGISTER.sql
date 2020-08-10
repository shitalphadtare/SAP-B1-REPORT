Create view PTS_FIXED_ASSET_REGISTER as
Select
 A."PeriodCat",
 A."ItemType",
 A."Asset Class",
 A."Asset Class Name",
 A."ItemCode",
 A."ItemName",
 A."Capitalization Date",
 A."OcrCode",
 A."Project",
 A."UseFull Life",
 A."Add/Deletion",
 A."Used life (months)",
 A."Remaining Life",
 A."Opening Gross Block",
 A."Additions during the period", 
 A."Deductions/ Adjustments",
 A."Closing Gross Block",
 A."Opening Acc. Depreciation",
 A."Depreciation during the period",
 A."Deletions/ Adjustments",
 A."Closing Acc. Depreication",
 A."Opening NBV",
 A."Closing Net Book Value",
 A."Attribute1",
 A."Attribute2",
 A."Attribute3",
 A."Attribute4",
 A."Attribute5",
 A."Attribute6",
 A."Attribute7",
 A."Attribute8",
 A."Attribute9",
 A."DprArea",
 A."PeriodCat" "PeriodCat_1",
 A."CompnyName",
 --A."Capitalization Date",
A."Salvage Value"
 from
(
select O1."ItemType",O1."AssetClass" as "Asset Class",
O2."Name" as "Asset Class Name",
O1."ItemCode" as "ItemCode",
O1."ItemName" as "ItemName",
O4."DocDate" as "DocDate",
O1."CapDate" as "Capitalization Date",
O9."SalvageVal" as "Salvage Value",
O10."OcrCode" as "OcrCode",
O5."Project" as "Project",
O6."UsefulLife" as "UseFull Life",
(select sum("OINV"."DocTotal") from OINV OINV 
inner Join INV1 INV on OINV."DocEntry"=INV."DocEntry" 
inner join OITM O2 on O2."ItemCode"=INV."ItemCode" and O2."ItemCode"=O1."ItemCode"
inner join NNM1 N1 on N1."ObjectCode"='13'
inner join OFPR F on F."Indicator"=N1."Indicator" and Inv."DocDate" Between F."F_RefDate" and F."T_RefDate"
where O2."ItemType"='F' and F."Category"<O6."PeriodCat") as "Add/Deletion",
O6."UsefulLife"-O6."RemainLife" as "Used life (months)",
O6."RemainLife" as "Remaining Life",
(select isnull(sum(APC),0) from ITM8 where "ItemCode"=O1."ItemCode" and "PeriodCat"=O6."PeriodCat" and "DprArea"=O6."DprArea")
 as "Opening Gross Block",
 
(
isnull((select sum("LineTotal") from "ACQ1" T1 inner join "OACQ" T2 on T1."DocEntry"=T2."DocEntry" where "ItemCode"=O1."ItemCode" and T2."PeriodCat"=O6."PeriodCat" and  T2."DocStatus"!='C'),0)
)
-
isnull((select sum((isnull("LineTotal",0))) from "ACD1" T6
inner join "OACD" T7 on T6."DocEntry"=T7."DocEntry"
 and T6."ItemCode"=O1."ItemCode" and T7."PeriodCat"=O6."PeriodCat" ),0
 ) as "Additions during the period", 
 
 isnull((select sum(T."APC") from "FIX1" T where T."ItemCode"=O1."ItemCode" and T."PeriodCat"=o6."PeriodCat" and T."APC"<0),0)
+isnull(( SELECT SUM(ACD1."LineTotal") FROM OACD OACD INNER JOIN ACD1 ACD1 ON OACD."DocEntry" = ACD1."DocEntry" WHERE OACD."PeriodCat"=o6."PeriodCat" AND ACD1."ItemCode"=O1."ItemCode"),0)

 as "Deductions/ Adjustments",
(
(select isnull(sum(APC),0) from ITM8 where "ItemCode"=O1."ItemCode" and "PeriodCat"=O6."PeriodCat" and "DprArea"=O6."DprArea")
+
(
(
isnull((select sum("LineTotal") from "ACQ1" T1 inner join "OACQ" T2 on T1."DocEntry"=T2."DocEntry" where "ItemCode"=O1."ItemCode" and T2."PeriodCat"=O6."PeriodCat" and  T2."DocStatus"!='C'),0)
)
-
isnull((select sum((isnull("LineTotal",0))) from "ACD1" T6
inner join "OACD" T7 on T6."DocEntry"=T7."DocEntry"
 and T6."ItemCode"=O1."ItemCode" and T7."PeriodCat"=O6."PeriodCat" ),0
 )
+
(
 isnull((select sum(T."APC") from "FIX1" T where T."ItemCode"=O1."ItemCode" and T."PeriodCat"=o6."PeriodCat" and T."APC"<0),0)
+isnull(( SELECT SUM(ACD1."LineTotal") FROM OACD OACD INNER JOIN ACD1 ACD1 ON OACD."DocEntry" = ACD1."DocEntry" WHERE OACD."PeriodCat"=o6."PeriodCat" AND ACD1."ItemCode"=O1."ItemCode"),0)
)
)

)

 as "Closing Gross Block",

isnull((select isnull(sum("OrDpAcc"),0) from ITM8 where "ItemCode"=O1."ItemCode" and "PeriodCat"=O6."PeriodCat"),0)
as "Opening Acc. Depreciation",
 
(isnull((select sum("OrdDprPost") from "ODPV" where "ItemCode"=O1."ItemCode" and "PeriodCat"=o6."PeriodCat" and "DprArea"=O6."DprArea"),0)
+
isnull((select sum(P1."LineTotal") from OMDP P inner Join MDP1 P1 on P."DocEntry"=P1."DocEntry" and "PeriodCat"=O6."PeriodCat" and "ItemCode"=O1."ItemCode"),0)
)
as "Depreciation during the period",
isnull((select sum(T."OrdDpr") from "FIX1" T where T."ItemCode"=O1."ItemCode" and T."PeriodCat"=o6."PeriodCat" and T."OrdDpr"<0),0) as "Deletions/ Adjustments",
(
(
isnull((select sum("OrdDprPost") from "ODPV" where "ItemCode"=O1."ItemCode" and "PeriodCat"=o6."PeriodCat" and "DprArea"=O6."DprArea"),0)
+
isnull((select isnull(sum("OrDpAcc"),0) from ITM8 where "ItemCode"=O1."ItemCode" and "PeriodCat"=O6."PeriodCat"),0)
+
isnull((select sum(P1."LineTotal") from OMDP P inner Join MDP1 P1 on P."DocEntry"=P1."DocEntry" and "PeriodCat"=O6."PeriodCat" and "ItemCode"=O1."ItemCode"),0)
)
+
(
isnull((select sum(T."OrdDpr") from "FIX1" T where T."ItemCode"=O1."ItemCode" and T."PeriodCat"=o6."PeriodCat" and T."OrdDpr"<0),0)
)
) as "Closing Acc. Depreication",

(select isnull(sum(APC),0) from ITM8 where "ItemCode"=O1."ItemCode" and "PeriodCat"=O6."PeriodCat" and "DprArea"=O6."DprArea")
-
isnull((select isnull(sum("OrDpAcc"),0) from ITM8 where "ItemCode"=O1."ItemCode" and "PeriodCat"=O6."PeriodCat"),0)
as "Opening NBV",

(
(
(select isnull(sum(APC),0) from ITM8 where "ItemCode"=O1."ItemCode" and "PeriodCat"=O6."PeriodCat" and "DprArea"=O6."DprArea")
+
(
(
isnull((select sum("LineTotal") from "ACQ1" T1 inner join "OACQ" T2 on T1."DocEntry"=T2."DocEntry" where "ItemCode"=O1."ItemCode" and T2."PeriodCat"=O6."PeriodCat" and  T2."DocStatus"!='C'),0)
)
-
isnull((select sum((isnull("LineTotal",0))) from "ACD1" T6
inner join "OACD" T7 on T6."DocEntry"=T7."DocEntry"
 and T6."ItemCode"=O1."ItemCode" and T7."PeriodCat"=O6."PeriodCat" ),0
 )
+
(
 isnull((select sum(T."APC") from "FIX1" T where T."ItemCode"=O1."ItemCode" and T."PeriodCat"=o6."PeriodCat" and T."APC"<0),0)
+isnull(( SELECT SUM(ACD1."LineTotal") FROM OACD OACD INNER JOIN ACD1 ACD1 ON OACD."DocEntry" = ACD1."DocEntry" WHERE OACD."PeriodCat"=o6."PeriodCat" AND ACD1."ItemCode"=O1."ItemCode"),0)
)
)

)
-

(
(
isnull((select sum("OrdDprPost") from "ODPV" where "ItemCode"=O1."ItemCode" and "PeriodCat"=o6."PeriodCat" and "DprArea"=O6."DprArea"),0)
+
isnull((select isnull(sum("OrDpAcc"),0) from ITM8 where "ItemCode"=O1."ItemCode" and "PeriodCat"=O6."PeriodCat"),0)
+
isnull((select sum(P1."LineTotal") from OMDP P inner Join MDP1 P1 on P."DocEntry"=P1."DocEntry" and "PeriodCat"=O6."PeriodCat" and "ItemCode"=O1."ItemCode"),0)
)
+
(
isnull((select sum(T."OrdDpr") from "FIX1" T where T."ItemCode"=O1."ItemCode" and T."PeriodCat"=o6."PeriodCat" and T."OrdDpr"<0),0)
)
)


)
 as "Closing Net Book Value",
O8."AttriTxt1" as "Attribute1",
O8."AttriTxt2" as "Attribute2",
O8."AttriTxt3" as "Attribute3",
O8."AttriTxt4" as "Attribute4",
O8."AttriTxt5" as "Attribute5",
O8."AttriTxt6" as "Attribute6",
O8."AttriTxt7" as "Attribute7",
O8."AttriTxt8" as "Attribute8",
O8."AttriTxt9" as "Attribute9",
O6."DprArea" as "DprArea",
O6."PeriodCat",
OADM."CompnyName"
from "OITM" O1 
left outer JOIN "OACS" O2  on O1."AssetClass"=O2."Code"
left outer join "ACQ1" O3 on O3."ItemCode"=O1."ItemCode"
left outer join "OACQ" O4 on O4."DocEntry"=O3."DocEntry" 
left outer join "ITM5" O5 on O5."ItemCode"=O1."ItemCode"
left outer join "ITM6" O10 on O10."ItemCode"=O1."ItemCode"
left outer join "ITM7" O6 on O6."ItemCode"=O1."ItemCode"
left outer join "ODTP" O7 on O7."Code"=O6."DprType"
left outer Join "ITM13" O8 on O8."ItemCode"=O1."ItemCode" 
left outer join "ITM8" O9 on O9."ItemCode"=O1."ItemCode" and O6."PeriodCat"=O9."PeriodCat"
cross join "OADM" "OADM"
where  O1."ItemType"='F' 
) as "A"
group by 
A."ItemType",
A."Asset Class",
 A."Asset Class Name",
 A."ItemCode",
 A."ItemName" ,
 A."Capitalization Date",
 A."OcrCode",
 A."Project",
 A."UseFull Life",
 A."Add/Deletion",
 A."Used life (months)",
 A."Remaining Life",
 A."Opening Gross Block",
 A."Deletions/ Adjustments",
 A."Additions during the period", A."Deductions/ Adjustments",
 A."Closing Gross Block",
 A."Opening Acc. Depreciation",
 A."Depreciation during the period",
 A."Closing Acc. Depreication",
 A."Opening NBV",
 A."Closing Net Book Value",
 A."Attribute1",
 A."Attribute2",
 A."Attribute3",
 A."Attribute4",
 A."Attribute5",
 A."Attribute6",
 A."Attribute7",
 A."Attribute8",
 A."Attribute9",
 A."DprArea",
 A."PeriodCat",
 A."CompnyName" ,
 A."Capitalization Date",
A."Salvage Value"
 --order by A."ItemCode",A."PeriodCat" asc 









