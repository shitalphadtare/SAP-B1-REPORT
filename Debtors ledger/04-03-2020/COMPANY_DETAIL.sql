CREATE VIEW COMPANY_DETAIL AS SELECT
	 isnull("Block" + ' ',
	 '') + isnull("Street" + ' ',
	 '') + isnull("StreetNo" + ' ',
	 '') + isnull("Building" + ' ',
	 '') + isnull("City" + ' ',
	 '') + isnull(OCRY."Name" + ' - ',
	 '') + isnull("ZipCode" + ' ',
	 '') AS "Address" 
FROM ADM1 
LEFT OUTER JOIN OCRY ON OCRY."Code" = ADM1."Country" 