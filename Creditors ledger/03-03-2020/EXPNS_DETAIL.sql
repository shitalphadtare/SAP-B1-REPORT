alter VIEW  EXPNS_DETAIL  AS ((((((SELECT
	 a."TransId",
	 isnull(d."Segment_0" + '-' + d."Segment_1",
	 d."FormatCode") + ' - ' + d."AcctName" AS "AcctName",
	 c."Credit" - c."Debit" AS "AmountPaid",
	 c."FCCredit" - c."FCDebit" AS "AmountPaidFC" 
						FROM OPCH A 
						INNER JOIN OJDT B ON A."TransId" = B."TransId" 
						INNER JOIN JDT1 C ON B."TransId" = C."TransId" 
						INNER JOIN OACT D ON D."AcctCode" = C."Account" 
						WHERE (c."Debit" <> 0 
							OR c."Credit" <> 0) 
						AND c."ShortName" <> a."CardCode" 
						AND B."TransType" = 18 
						AND a."DocType" = 'S') 
					UNION ALL (SELECT
	 a."TransId",
	 isnull(d."Segment_0" + '-' + d."Segment_1",
	 d."FormatCode") + ' - ' + d."AcctName" AS "AcctName",
	 (c."Credit" - c."Debit") AS "AmountPaid",
	 c."FCCredit" - c."FCDebit" AS "AmountPaidFC" 
						FROM ODPO A 
						INNER JOIN OJDT B ON A."TransId" = B."TransId" 
						INNER JOIN JDT1 C ON B."TransId" = C."TransId" 
						INNER JOIN OACT D ON D."AcctCode" = C."Account" 
						WHERE (c."Debit" <> 0 
							OR c."Credit" <> 0) 
						AND c."ShortName" <> a."CardCode" 
						AND B."TransType" = 204 
						AND a."DocType" = 'S')) 
				UNION ALL (SELECT
	 a."TransId",
	 isnull(d."Segment_0" + '-' + d."Segment_1",
	 d."FormatCode") + ' - ' + d."AcctName" AS "AcctName",
	 c."Credit" - c."Debit" AS "AmountPaid",
	 c."FCCredit" - c."FCDebit" AS "AmountPaidFC" 
					FROM ORPC A 
					INNER JOIN OJDT B ON A."TransId" = B."TransId" 
					INNER JOIN JDT1 C ON B."TransId" = C."TransId" 
					INNER JOIN OACT D ON D."AcctCode" = C."Account" 
					INNER JOIN NNM1 E ON E."Series" = A."Series" 
					WHERE (c."Debit" <> 0 
						OR c."Credit" <> 0) 
					AND c."ShortName" <> a."CardCode" 
					AND B."TransType" = 19 
					AND a."DocType" = 'S')) 
			UNION ALL (SELECT
	 a."TransId",
	 isnull(d."Segment_0" + '-' + d."Segment_1",
	 d."FormatCode") + ' - ' + d."AcctName" AS "ACCTNAME",
	 c."Credit" - c."Debit" AS "AmountPaid",
	 c."FCCredit" - c."FCDebit" AS "AmountPaidFC" 
				FROM OJDT A 
				INNER JOIN NNM1 B ON A."Series" = b."Series" 
				INNER JOIN JDT1 C ON A."TransId" = C."TransId" 
				INNER JOIN OACT d ON d."AcctCode" = c."Account" 
				INNER JOIN OCRD F ON F."CardCode" = C."ContraAct" 
				AND A."TransType" NOT IN (13,
	 14,
	 18,
	 19,
	 24,
	 46,
	 204,
	 321 ---changes on 03-12-2019 for MANUAL RECO.
 ))) 
		UNION ALL (SELECT
	 rc."TransId",
	 'On Account' AS "AcctName",
	 rc."NoDocSum" AS "AmountPaid",
	 rc."NoDocSumFC" AS "AmountPaidFC" 
			FROM OCRD a 
			INNER JOIN ORCT rc ON rc."CardCode" = a."CardCode" 
			WHERE rc."NoDocSum" > 0 
			AND rc."Canceled" = 'N' 
			AND a."CardType" = 'S')) 
	UNION ALL (SELECT
	 pm."TransId",
	 'On Account' AS "AcctName",
	 pm."NoDocSum" AS "AmountPaid",
	 pm."NoDocSumFC" AS "AmountPaidFC" 
		FROM OCRD a 
		INNER JOIN OVPM pm ON pm."CardCode" = a."CardCode" 
		WHERE pm."NoDocSum" > 0 
		AND pm."Canceled" = 'N' 
		AND a."CardType" = 'S')) 