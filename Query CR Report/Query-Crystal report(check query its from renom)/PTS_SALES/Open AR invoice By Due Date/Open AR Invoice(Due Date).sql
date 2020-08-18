USE [Renom_Live]
GO

/****** Object:  View [dbo].[Open_AR_Invoice]    Script Date: 03/03/2020 10:37:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER View [dbo].[Open_AR_Invoice]
as


SELECT 'Open Invoice' as 'Doc Type', T0.[Docentry], T0.[DocNum],T0.[DocDate], T0.[TaxDate], T0.[DocDueDate] as [Due Date],
T0.[CardCode], T0.[CardName], T0.[DocTotal], T0.[DocTotalFC] ,T0.[DocCur],   T0.[Comments]
FROM OINV T0 WHERE T0.[DocStatus]  = 'O'
--FOR BROWSE
GO


