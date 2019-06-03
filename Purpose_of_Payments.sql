USE [WRCT]
GO
/****** Object:  StoredProcedure [dbo].[Purpose_of_Payments]    Script Date: 6/3/2019 12:56:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Purpose_of_Payments]
@DATABASE VARCHAR(MAX)
AS

BEGIN

Declare @Script VARCHAR(MAX)
SET @Script =
'
IF OBJECT_ID(''dbo.Purpose_TempT'', ''U'') IS NOT NULL 
   DROP TABLE dbo.Purpose_TempT;

Select [Transaction Number], [Purpose_of_Payments],
CONVERT(VARCHAR(10), getdate(), 111) AS QUERYDATE INTO Purpose_TempT 
FROM (
	
	SELECT * ,CASE

	--Interbank Fund Transfers Pattern via Mega Domestic Branches Ref Number for Swift Msg (mmdd+01+C+XXXXXX)

	WHEN [Sender''s Reference]				like ''[0-1][0-9][0-3][0-9]01C%''				THEN ''(Tag 20) Interbank Fund Transfer'' --Accounting  
	WHEN [Sender''s Reference]				like ''[0-1][0-9][0-3][0-9]02C%''				THEN ''(Tag 20) Interbank Fund Transfer'' --Overseas Brancheses and Correspondent Banks Funds Transfer 
	WHEN [Sender''s Reference]				like ''[0-1][0-9][0-3][0-9]03C%''				THEN ''(Tag 20) Interbank Fund Transfer'' --FISC(Note1) CNY Fund Transfer 
	WHEN [Sender''s Reference]				like ''[0-1][0-9][0-3][0-9]04C%''				THEN ''(Tag 20) Interbank Fund Transfer'' --FISC JPY Fund Transfer --mmdd+01+C+XXXXXX
	WHEN [Sender''s Reference]				like ''[0-1][0-9][0-3][0-9]05C%''				THEN ''(Tag 20) Interbank Fund Transfer'' --Taiwan Domestic USD Settlement Mechanism Settlement & Funds Transfer 
	WHEN [Sender''s Reference]				like ''[0-1][0-9][0-3][0-9]07C%''				THEN ''(Tag 20) Interbank Fund Transfer'' --FISC USD Fund Transfer 
	WHEN [Sender''s Reference]				like ''[0-1][0-9][0-3][0-9]09C%''				THEN ''(Tag 20) Interbank Fund Transfer'' --FISC EUR Fund Transfer 
	WHEN [Sender''s Reference]				like ''[0-1][0-9][0-3][0-9]11C%''				THEN ''(Tag 20) Interbank Fund Transfer'' --Taiwan Domestic EUR Settlement Mechanism Settlement & Funds Transfer 
	WHEN [Sender''s Reference]				like ''[0-1][0-9][0-3][0-9]12C%''				THEN ''(Tag 20) Interbank Fund Transfer'' --FISC Other Currencies Fund Transfer 
	WHEN [Sender''s Reference]				like ''[0-1][0-9][0-3][0-9]14C%''				THEN ''(Tag 20) Interbank Fund Transfer'' --Taiwan Domestic Other Foreign Currencies Settlement Mechanism Settlement & Funds Transfer

	WHEN [Reference for Beneficiary]		like ''[0-1][0-9][0-3][0-9]01C%''				THEN ''(Tag 21) Interbank Fund Transfer'' --Accounting  
	WHEN [Reference for Beneficiary]		like ''[0-1][0-9][0-3][0-9]02C%''				THEN ''(Tag 21) Interbank Fund Transfer'' --Acct w/ non-FISC Corr. Bank 
	WHEN [Reference for Beneficiary]		like ''[0-1][0-9][0-3][0-9]03C%''				THEN ''(Tag 21) Interbank Fund Transfer'' --FISC(Note 1) CNY Fund Transfer 
	WHEN [Reference for Beneficiary]		like ''[0-1][0-9][0-3][0-9]04C%''				THEN ''(Tag 21) Interbank Fund Transfer'' --FISC JPY Fund Transfer 
	WHEN [Reference for Beneficiary]		like ''[0-1][0-9][0-3][0-9]05C%''				THEN ''(Tag 21) Interbank Fund Transfer'' --FISC USD Settlement & Fund Transfer 
	WHEN [Reference for Beneficiary]		like ''[0-1][0-9][0-3][0-9]07C%''				THEN ''(Tag 21) Interbank Fund Transfer'' --FISC USD Fund Transfer 
	WHEN [Reference for Beneficiary]		like ''[0-1][0-9][0-3][0-9]09C%''				THEN ''(Tag 21) Interbank Fund Transfer'' --FISC EUR Fund Transfer 
	WHEN [Reference for Beneficiary]		like ''[0-1][0-9][0-3][0-9]11C%''				THEN ''(Tag 21) Interbank Fund Transfer'' --FISC EUR Settlement & Fund Transfer 
	WHEN [Reference for Beneficiary]		like ''[0-1][0-9][0-3][0-9]12C%''				THEN ''(Tag 21) Interbank Fund Transfer'' --FISC Other Currencies Fund Transfer 
	WHEN [Reference for Beneficiary]		like ''[0-1][0-9][0-3][0-9]14C%''				THEN ''(Tag 21) Interbank Fund Transfer'' --FISC Other Currencies Settlement & Fund Transfer 

	--Treasury Transactions Pattern via Mega Domestic Branches Ref Number for Swift Msg (SPT+XXXXXXXXXX+(P or R)+XX)

	WHEN [Sender''s Reference]				like ''SPT__________P%''						THEN ''(Tag 20) Treasury Transaction'' --: FX Spot Payment 
	WHEN [Sender''s Reference]				like ''SPT__________R%''						THEN ''(Tag 20) Treasury Transaction'' --: FX Spot Receive 
	WHEN [Sender''s Reference]				like ''FWD__________P%''						THEN ''(Tag 20) Treasury Transaction'' --: FX Forward Payment 
	WHEN [Sender''s Reference]				like ''FWD__________R%''						THEN ''(Tag 20) Treasury Transaction'' --: FX Forward Receive 
	WHEN [Sender''s Reference]				like ''FXO__________P%''						THEN ''(Tag 20) Treasury Transaction'' --: FX Option Payment 
	WHEN [Sender''s Reference]				like ''FXO__________R%''						THEN ''(Tag 20) Treasury Transaction'' --: FX Option Receive 
	WHEN [Sender''s Reference]				like ''STK__________P%''						THEN ''(Tag 20) Treasury Transaction'' --: Mutual Fund Payment
	WHEN [Sender''s Reference]				like ''STK__________R%''						THEN ''(Tag 20) Treasury Transaction'' --: Mutual Fund Receive
	WHEN [Sender''s Reference]				like ''BOP__________P%''						THEN ''(Tag 20) Treasury Transaction'' --: Bond Option Payment
	WHEN [Sender''s Reference]				like ''BOP__________R%''						THEN ''(Tag 20) Treasury Transaction'' --: Bond Option Receive
	WHEN [Sender''s Reference]				like ''UNK__________P%''						THEN ''(Tag 20) Treasury Transaction'' --: IRS CDS Payment 
	WHEN [Sender''s Reference]				like ''UNK__________R%''						THEN ''(Tag 20) Treasury Transaction'' --: IRS CDS Receive 
	WHEN [Sender''s Reference]				like ''SWP__________P%''						THEN ''(Tag 20) Treasury Transaction'' --: Asset Swap CCS Payment
	WHEN [Sender''s Reference]				like ''SWP__________R%''						THEN ''(Tag 20) Treasury Transaction'' --: Asset Swap CCS Receive
	WHEN [Sender''s Reference]				like ''IRG__________P%''						THEN ''(Tag 20) Treasury Transaction'' --: Interest Rate Payment 
	WHEN [Sender''s Reference]				like ''IRG__________R%''						THEN ''(Tag 20) Treasury Transaction'' --: Interest Rate Receive 
	WHEN [Sender''s Reference]				like ''PMT__________P%''						THEN ''(Tag 20) Treasury Transaction'' --: Deal Payment 
	WHEN [Sender''s Reference]				like ''PMT__________R%''						THEN ''(Tag 20) Treasury Transaction'' --: Deal Receive 
	WHEN [Sender''s Reference]				like ''MM__________P%''							THEN ''(Tag 20) Treasury Transaction'' --: Money Market Payment 
	WHEN [Sender''s Reference]				like ''MM__________R%''							THEN ''(Tag 20) Treasury Transaction'' --: Money Market Receive 
	WHEN [Sender''s Reference]				like ''MGM__________P%''						THEN ''(Tag 20) Treasury Transaction'' --: Margin Exchange for OTC Derivatives Payment 
	WHEN [Sender''s Reference]				like ''MGM__________R%''						THEN ''(Tag 20) Treasury Transaction'' --: Margin Exchange for OTC Derivatives Receive 
	WHEN [Sender''s Reference]				like ''RMG__________P%''						THEN ''(Tag 20) Treasury Transaction'' --: Margin Call for REPO Payment 
	WHEN [Sender''s Reference]				like ''RMG__________R%''						THEN ''(Tag 20) Treasury Transaction'' --: Margin Call for REPO Receive 
	WHEN [Sender''s Reference]				like ''FUT__________P%''						THEN ''(Tag 20) Treasury Transaction'' --: Futures Payment 
	WHEN [Sender''s Reference]				like ''FUT__________R%''						THEN ''(Tag 20) Treasury Transaction'' --: Futures Receive 
	WHEN [Sender''s Reference]				like ''__________P__USD''						THEN ''(Tag 20) Treasury Transaction'' --: FX Swap Payment 
	WHEN [Sender''s Reference]				like ''__________R__USD''						THEN ''(Tag 20) Treasury Transaction'' --: FX Swap Receive 
																																
	WHEN [Reference for Beneficiary]		like ''SPT__________P%''						THEN ''(Tag 21) Treasury Transaction'' --: FX Spot Payment 
	WHEN [Reference for Beneficiary]		like ''SPT__________R%''						THEN ''(Tag 21) Treasury Transaction'' --: FX Spot Receive 
	WHEN [Reference for Beneficiary]		like ''FWD__________P%''						THEN ''(Tag 21) Treasury Transaction'' --: FX Forward Payment
	WHEN [Reference for Beneficiary]		like ''FWD__________R%''						THEN ''(Tag 21) Treasury Transaction'' --: FX Forward Receive
	WHEN [Reference for Beneficiary]		like ''FXO__________P%''						THEN ''(Tag 21) Treasury Transaction'' --: FX Option Payment 
	WHEN [Reference for Beneficiary]		like ''FXO__________R%''						THEN ''(Tag 21) Treasury Transaction'' --: FX Option Receive 
	WHEN [Reference for Beneficiary]		like ''STK__________P%''						THEN ''(Tag 21) Treasury Transaction'' --: Mutual Fund Payment
	WHEN [Reference for Beneficiary]		like ''STK__________R%''						THEN ''(Tag 21) Treasury Transaction'' --: Mutual Fund Receive
	WHEN [Reference for Beneficiary]		like ''BOP__________P%''						THEN ''(Tag 21) Treasury Transaction'' --: Bond Option Payment
	WHEN [Reference for Beneficiary]		like ''BOP__________R%''						THEN ''(Tag 21) Treasury Transaction'' --: Bond Option Receive
	WHEN [Reference for Beneficiary]		like ''UNK__________P%''						THEN ''(Tag 21) Treasury Transaction'' --: IRS CDS Payment 
	WHEN [Reference for Beneficiary]		like ''UNK__________R%''						THEN ''(Tag 21) Treasury Transaction'' --: IRS CDS Receive 
	WHEN [Reference for Beneficiary]		like ''SWP__________P%''						THEN ''(Tag 21) Treasury Transaction'' --: Asset Swap CCS Payment 
	WHEN [Reference for Beneficiary]		like ''SWP__________R%''						THEN ''(Tag 21) Treasury Transaction'' --: Asset Swap CCS Receive 
	WHEN [Reference for Beneficiary]		like ''IRG__________P%''						THEN ''(Tag 21) Treasury Transaction'' --: Interest Rate Payment 
	WHEN [Reference for Beneficiary]		like ''IRG__________R%''						THEN ''(Tag 21) Treasury Transaction'' --: Interest Rate Receive 
	WHEN [Reference for Beneficiary]		like ''PMT__________P%''						THEN ''(Tag 21) Treasury Transaction'' --: Deal Payment 
	WHEN [Reference for Beneficiary]		like ''PMT__________R%''						THEN ''(Tag 21) Treasury Transaction'' --: Deal Receive 
	WHEN [Reference for Beneficiary]		like ''MM__________P%''							THEN ''(Tag 21) Treasury Transaction'' --: Money Market Payment 
	WHEN [Reference for Beneficiary]		like ''MM__________R%''							THEN ''(Tag 21) Treasury Transaction'' --: Money Market Receive 
	WHEN [Reference for Beneficiary]		like ''MGM__________P%''						THEN ''(Tag 21) Treasury Transaction'' --: Margin Exchange for OTC Derivatives Payment 
	WHEN [Reference for Beneficiary]		like ''MGM__________R%''						THEN ''(Tag 21) Treasury Transaction'' --: Margin Exchange for OTC Derivatives Receive 
	WHEN [Reference for Beneficiary]		like ''RMG__________P%''						THEN ''(Tag 21) Treasury Transaction'' --: Margin Call for REPO Payment 
	WHEN [Reference for Beneficiary]		like ''RMG__________R%''						THEN ''(Tag 21) Treasury Transaction'' --: Margin Call for REPO Receive 
	WHEN [Reference for Beneficiary]		like ''FUT__________P%''						THEN ''(Tag 21)	Treasury Transaction'' --: Futures Payment 
	WHEN [Reference for Beneficiary]		like ''FUT__________R%''						THEN ''(Tag 21)	Treasury Transaction'' --: Futures Receive 
	WHEN [Reference for Beneficiary]		like ''__________P__USD''						THEN ''(Tag 21)	Treasury Transaction'' --: FX Swap Payment 
	WHEN [Reference for Beneficiary]		like ''__________R__USD''						THEN ''(Tag 21)	Treasury Transaction'' --: FX Swap Receive
	 																															 
	--Treasury Transactions Part 2 (S+XXXXXXXXXX+(P or R)+XX)																	 
																																 
	WHEN [Sender''s Reference]				like ''S[0-9][0-9]__________P%''				THEN ''(Tag 20) Treasury Transaction '' --: Mutual Fund Payment 
	WHEN [Sender''s Reference]				like ''S[0-9][0-9]__________R%''				THEN ''(Tag 20) Treasury Transaction '' --: Mutual Fund Receive 
	WHEN [Sender''s Reference]				like ''B[0-9][0-9]__________P%''				THEN ''(Tag 20) Treasury Transaction '' --: Bond Investment Payment 
	WHEN [Sender''s Reference]				like ''B[0-9][0-9]__________R%''				THEN ''(Tag 20) Treasury Transaction '' --: Bond Investment Receive 
	WHEN [Sender''s Reference]				like ''R[0-9][0-9]__________P%''				THEN ''(Tag 20) Treasury Transaction '' --: REPO Payment 
	WHEN [Sender''s Reference]				like ''R[0-9][0-9]__________R%''				THEN ''(Tag 20) Treasury Transaction '' --: REPO Receive 
																																 
	WHEN [Reference for Beneficiary]		like ''S[0-9][0-9]__________P%''				THEN ''(Tag 21) Treasury Transaction '' --: Mutual Fund Payment 
	WHEN [Reference for Beneficiary]		like ''S[0-9][0-9]__________R%''				THEN ''(Tag 21) Treasury Transaction '' --: Mutual Fund Receive 
	WHEN [Reference for Beneficiary]		like ''B[0-9][0-9]__________P%''				THEN ''(Tag 21) Treasury Transaction '' --: Bond Investment Payment 
	WHEN [Reference for Beneficiary]		like ''B[0-9][0-9]__________R%''				THEN ''(Tag 21) Treasury Transaction '' --: Bond Investment Receive 
	WHEN [Reference for Beneficiary]		like ''R[0-9][0-9]__________P%''				THEN ''(Tag 21) Treasury Transaction '' --: REPO Payment 
	WHEN [Reference for Beneficiary]		like ''R[0-9][0-9]__________R%''				THEN ''(Tag 21) Treasury Transaction '' --: REPO Receive 


	--CBC Money Market Transaction Pattern via Mega Domestic Branches Ref Number for Swift Msg (DLXXXXXX+XXXX)

	WHEN [Sender''s Reference]				like ''DL[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]''			THEN ''(Tag 20) Treasury Transaction''--CBC MM Transaction 																													
	WHEN [Reference for Beneficiary]		like ''DL[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]''			THEN ''(Tag 21) Treasury Transaction''--CBC MM Transaction 


	--Margin Exchange for Central Clearing Pattern via Mega Domestic Branches Ref Number for Swift Msg (011+YYMMDD+FS+XXXXX)

	WHEN [Sender''s Reference]				like ''011[0-9][0-9][0-1][0-9][0-3][0-9]FS%''							THEN ''(Tag 20) Treasury Transaction'' --Margin Exchange for Central Clearing 
	WHEN [Sender''s Reference]				like ''[0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9]FS__-___''				THEN ''(Tag 20) Treasury Transaction'' --Margin Exchange for Central Clearing
	WHEN [Sender''s Reference]				like ''CBC FINANCING''													THEN ''(Tag 20) Treasury Transaction'' --CBC Interest Payment 

	WHEN [Reference for Beneficiary]		like ''011[0-9][0-9][0-1][0-9][0-3][0-9]FS%''							THEN ''(Tag 21) Treasury Transaction'' --Margin Exchange for Central Clearing 
	WHEN [Reference for Beneficiary]		like ''[0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9]FS__-___''				THEN ''(Tag 21) Treasury Transaction'' --Margin Exchange for Central Clearing
	WHEN [Reference for Beneficiary]		like ''CBC FINANCING''													THEN ''(Tag 21) Treasury Transaction'' --CBC Interest Payment 

	--Foreign Dept. Clearing Transaction (AAXX+TL+8+GD+XXXXX)

	WHEN [Sender''s Reference]				like ''AA[a-z][a-z]TL[0-9]GD%''											THEN ''(Tag 20) Foreign Dept. Clearing Transaction'' --The Clearing of USD Gold Passbook
	WHEN [Sender''s Reference]				like ''AA[a-z][a-z]TL[0-9]BN%''											THEN ''(Tag 20) Foreign Dept. Clearing Transaction'' --The Clearing of Foreign Currency Bank Notes
	WHEN [Sender''s Reference]				like ''AA[a-z][a-z]TL[0-9]TC%''											THEN ''(Tag 20) Foreign Dept. Clearing Transaction'' --The Clearing of Travelers Check
																																										 
	WHEN [Reference for Beneficiary]		like ''AA[a-z][a-z]TL[0-9]GD%''											THEN ''(Tag 21) Foreign Dept. Clearing Transaction'' --The Clearing of USD Gold Passbook
	WHEN [Reference for Beneficiary]		like ''AA[a-z][a-z]TL[0-9]BN%''											THEN ''(Tag 21) Foreign Dept. Clearing Transaction'' --The Clearing of Foreign Currency Bank Notes
	WHEN [Reference for Beneficiary]		like ''AA[a-z][a-z]TL[0-9]TC%''											THEN ''(Tag 21) Foreign Dept. Clearing Transaction'' --The Clearing of Travelers Check


	--Foreign Exchange General Transaction Pattern via Mega Domestic Branches Ref Number for Swift Msg (AAXX+TS+X+XXXXXXX)

	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]TS[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --Outward Remittance 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]IS[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --Inward Remittance 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]TE[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --Outward Remittance through Internet Banking 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]IE[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --Inward Remittance through Internet Banking 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]DD[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --Issuance of Demand Draft 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]ID[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --Receipt of Demand Draft 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]MS[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --Outward Mail Transfer 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]IM[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --Inward Mail Transfer 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]TK[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --OBU Checks Remittance (By Exchange) 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]IT[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --Inward Remittance Manually Activated
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]CK[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --Clean Bill Collection/Purchase 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]PK[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --Clean Bill Collection/Purchase 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]CT[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --Travelers Check Collection/Purchase
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]PT[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --Travelers Check Collection/Purchase 
																																	
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]TS[0-9]%''											THEN ''(Tag 21) Foreign Exchange General Transaction'' --Outward Remittance 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]IS[0-9]%''											THEN ''(Tag 21) Foreign Exchange General Transaction'' --Inward Remittance 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]TE[0-9]%''											THEN ''(Tag 21) Foreign Exchange General Transaction'' --Outward Remittance through Internet Banking 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]IE[0-9]%''											THEN ''(Tag 21) Foreign Exchange General Transaction'' --Inward Remittance through Internet Banking 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]DD[0-9]%''											THEN ''(Tag 21) Foreign Exchange General Transaction'' --Issuance of Demand Draft 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]ID[0-9]%''											THEN ''(Tag 21) Foreign Exchange General Transaction'' --Receipt of Demand Draft 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]MS[0-9]%''											THEN ''(Tag 21) Foreign Exchange General Transaction'' --Outward Mail Transfer
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]IM[0-9]%''											THEN ''(Tag 21) Foreign Exchange General Transaction'' --Inward Mail Transfer 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]TK[0-9]%''											THEN ''(Tag 21) Foreign Exchange General Transaction'' --OBU Checks Remittance (By Exchange) 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]IT[0-9]%''											THEN ''(Tag 21) Foreign Exchange General Transaction'' --Inward Remittance Manually Activated
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]CK[0-9]%''											THEN ''(Tag 21) Foreign Exchange General Transaction'' --Clean Bill Collection/Purchase 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]PK[0-9]%''											THEN ''(Tag 21) Foreign Exchange General Transaction'' --Clean Bill Collection/Purchase
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]CT[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --Travelers Check Collection/Purchase
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]PT[0-9]%''											THEN ''(Tag 20) Foreign Exchange General Transaction'' --Travelers Check Collection/Purchase  

	--L/C Issuance Pattern via Mega Domestic Branches Ref Number for Swift Msg (F/D+X+AAXX+1/2+XXXX/X+XXX)

	WHEN [Sender''s Reference]				like ''[FD][0-9]AA[A-Z][A-Z][12]%''										THEN ''(Tag 20) L/C Issuance''
	WHEN [Reference for Beneficiary]		like ''[FD][0-9]AA[A-Z][A-Z][12]%''										THEN ''(Tag 21) L/C Issuance''

	--Trade Finance Transaction Pattern via Mega Domestic Branches Ref Number for Swift Msg (AAXX+LA+X+XXXXX)

	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]LA[0-9]%''											THEN ''(Tag 20) Trade Finance'' --L/C Advising 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]BP[0-9]%''											THEN ''(Tag 20) Trade Finance'' --L/C Negotiation 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]BB[0-9]%''											THEN ''(Tag 20) Trade Finance'' --Back-to-Back L/C 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]BR[0-9]%''											THEN ''(Tag 20) Trade Finance'' --L/C Re-Negotiation 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]EC[0-9]%''											THEN ''(Tag 20) Trade Finance'' --D/A, D/P, O/A(Export) 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]DA[0-9]%''											THEN ''(Tag 20) Trade Finance'' --Secondary Market D/A Forfaiting --Has been omitted from latest version
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]FT[0-9]%''											THEN ''(Tag 20) Trade Finance'' --Secondary Usance L/C Forfaiting 
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]TR[0-9]%''											THEN ''(Tag 20) Trade Finance'' --Payment on behalf of Financial Institution
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]NS[0-9]%''											THEN ''(Tag 20) Trade Finance'' --Usance L/C Negotiation at Sight
	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]AP[0-9]%''											THEN ''(Tag 20) Trade Finance'' --Assignment of proceeds 
																																	
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]LA[0-9]%''											THEN ''(Tag 21) Trade Finance'' --L/C Advising 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]BP[0-9]%''											THEN ''(Tag 21) Trade Finance'' --L/C Negotiation 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]BB[0-9]%''											THEN ''(Tag 21) Trade Finance'' --Back-to-Back L/C 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]BR[0-9]%''											THEN ''(Tag 21) Trade Finance'' --L/C Re-Negotiation 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]EC[0-9]%''											THEN ''(Tag 21) Trade Finance'' --D/A, D/P, O/A(Export) 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]DA[0-9]%''											THEN ''(Tag 21) Trade Finance'' --Secondary Market D/A Forfaiting --Has been omitted from latest version
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]FT[0-9]%''											THEN ''(Tag 21) Trade Finance'' --Secondary Usance L/C Forfaiting 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]TR[0-9]%''											THEN ''(Tag 21) Trade Finance'' --Payment on behalf of Financial Institution
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]NS[0-9]%''											THEN ''(Tag 21) Trade Finance'' --Usance L/C Negotiation at Sight
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]AP[0-9]%''											THEN ''(Tag 21) Trade Finance'' --Assignment of proceeds
	

	--L/C Confirmation Pattern via Mega Domestic Branches Ref Number for Swift Msg (AAXX+LA+X+XXXXXCM)

	WHEN [Sender''s Reference]				like ''AA[A-Z][A-Z]LA[0-9][0-9][0-9][0-9][0-9][0-9]CM''					THEN ''(Tag 20) L/C Confirmation'' 
	WHEN [Reference for Beneficiary]		like ''AA[A-Z][A-Z]LA[0-9][0-9][0-9][0-9][0-9][0-9]CM''					THEN ''(Tag 21) L/C Confirmation'' 

	--D/A,D/P, or O/A Pattern via Mega Domestic Branches Ref Number for Swift Msg (XXXXXXXXXX+DBPC+#+XXXX)

	WHEN [Sender''s Reference]				like ''[0-9]AA__3%''													THEN ''(Tag 20) D/A - Documents against Acceptance: Import''
	WHEN [Sender''s Reference]				like ''[0-9]AA__4%''													THEN ''(Tag 20) D/P - Documents against Payment: Import'' 
	WHEN [Sender''s Reference]				like ''[0-9]AA__8%''													THEN ''(Tag 20) O/A - Open Account Transaction: Import''
	 
	WHEN [Reference for Beneficiary]		like ''[0-9]AA__3%''													THEN ''(Tag 21) D/A Documents against Acceptance: Import''
	WHEN [Reference for Beneficiary]		like ''[0-9]AA__4%''													THEN ''(Tag 21) D/P Documents against Payment: Import'' 
	WHEN [Reference for Beneficiary]		like ''[0-9]AA__8%''													THEN ''(Tag 21) O/A - Open Account Transaction: Import'' 

	--Loan Pattern via Mega Domestic Branches Ref Number for Swift Msg (DBPC+LN+#+XXXX+XXXX(optional free format)

	WHEN [Sender''s Reference]				like ''AA__LN[0-9]%''													THEN ''(Tag 20) Loan'' -- Direct Loan'' 
	WHEN [Sender''s Reference]				like ''AA__SA[0-9]%''													THEN ''(Tag 20) Loan'' -- Syndicated Loan as Agent''
	WHEN [Sender''s Reference]				like ''AA__SP[0-9]%''													THEN ''(Tag 20) Loan'' -- Syndicated Loan as Participant''

	WHEN [Reference for Beneficiary]		like ''AA__LN[0-9]%''													THEN ''(Tag 21) Loan - Direct Loan'' 
	WHEN [Reference for Beneficiary]		like ''AA__SA[0-9]%''													THEN ''(Tag 21) Loan - Syndicated Loan as Agent''
	WHEN [Reference for Beneficiary]		like ''AA__SP[0-9]%''													THEN ''(Tag 21) Loan - Syndicated Loan as Participant'' 

	--Letter of Guarantee Pattern & Counter Guarantee via Mega Domestic Branches Ref Number for Swift Msg (DBPC+LG+#+XXXX+XXXX(optional free format)

	WHEN [Sender''s Reference]				like ''AA__LG[0-9]%''													THEN ''(Tag 20) Letter of Guarantee'' 
	WHEN [Reference for Beneficiary]		like ''AA__LG[0-9]%''													THEN ''(Tag 21) Letter of Guarantee'' 

	--Factoring Pattern via Mega Domestic Branches Ref Number for Swift Msg (DBPC+FA+#+XXXX+XXXX(optional free format)

	WHEN [Sender''s Reference]				like ''AA__FA[0-9]%''													THEN ''(Tag 20) Factoring'' 
	WHEN [Reference for Beneficiary]		like ''AA__FA[0-9]%''													THEN ''(Tag 21) Factoring'' 

	--Credit Card Settlement Pattern via Mega Domestic Branches Ref Number for Swift Msg (##########+JO)

	WHEN [Sender''s Reference]				like ''[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]JO''			THEN ''(Tag 20) Credit Card Settlement'' 
	WHEN [Reference for Beneficiary]		like ''[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]JO''			THEN ''(Tag 21) Credit Card Settlement'' 

	--Trust Business Pattern via Mega Domestic Branches Ref Number for Swift Msg (XXXX+Fund(or Fee)+yymmdd)

	WHEN [Sender''s Reference]				like ''%Fund[0-9][0-9][0-1][0-9][0-3][0-9]''							THEN ''(Tag 20) Trust Business'' --Fund Transfer
	WHEN [Sender''s Reference]				like ''%Fee[0-9][0-9][0-1][0-9][0-3][0-9]''								THEN ''(Tag 20) Trust Business'' --Fee Deduction
	WHEN [Sender''s Reference]				like ''SK10[0-9]___''													THEN ''(Tag 20) Trust Business'' --Specific Monetary Trust Business --SK+YYY+XXX (YYY is the "Year of ROC Calendar"), XXX is the sequence no.;free format) 
	WHEN [Sender''s Reference]				like ''[0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9]TR%''					THEN ''(Tag 20) Trust Business'' --Specific Monetary Trust Business --yyyymmdd+TR+XX
																																		  
	WHEN [Reference for Beneficiary]		like ''%Fund[0-9][0-9][0-1][0-9][0-3][0-9]''							THEN ''(Tag 21) Trust Business'' --Fund Transfer
	WHEN [Reference for Beneficiary]		like ''%Fee[0-9][0-9][0-1][0-9][0-3][0-9]''								THEN ''(Tag 21) Trust Business'' --Fee Deduction
	WHEN [Reference for Beneficiary]		like ''SK10[0-9]___''													THEN ''(Tag 21) Trust Business'' --Specific Monetary Trust Business --SK+YYY+XXX (YYY is the "Year of ROC Calendar"), XXX is the sequence no.;free format) 
	WHEN [Reference for Beneficiary]		like ''[0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9]TR%''					THEN ''(Tag 21) Trust Business'' --Specific Monetary Trust Business --yyyymmdd+TR+XX

	--Information Providing (without underlying transaction)
	WHEN [Sender''s Reference]				like ''AA__IF[0-9]%''													THEN ''(Tag 20) Information providing (without underlying transaction)'' 
	WHEN [Reference for Beneficiary]		like ''AA__IF[0-9]%''													THEN ''(Tag 20) Information providing (without underlying transaction)'' 

	--Overseas Pattern via Mega Overseas Brancheses Ref Number for Swift Msg

    WHEN LEFT([Reference for Beneficiary],3) IN (''NYA'',''CGO'',''LAC'',''SVB'',''TKY'',''OSA'',''PAR'',''AMS'',''HCM'',''SGP'',''SYD'',''MEL'',''BRI'',''HKG'',''LDN'',''PNM'',''MNL'',
	                                             ''CHO'',''CVR'',''BKK'',''CHB'',''BNA'',''BPO'',''RYO'',''PNH'',''PPA'',''OLY'',''TKK'',''SUZ'',''KUS'',''WUJ'',''NBO'',''LAB'') THEN
		 CASE
			 WHEN [Sender''s Reference]	LIKE ''___TO%'' THEN ''Foreign Exchange'' -- (Overseas Branches) Outward Remittance
			 WHEN [Sender''s Reference]	LIKE ''___TI%'' THEN ''Foreign Exchange'' -- (Overseas Branches) Inward Remittance
			 WHEN [Sender''s Reference]	LIKE ''___GB%'' THEN ''Foreign Exchange'' -- (Overseas Branches) Remittance through Internet Banking
			 WHEN [Sender''s Reference]	LIKE ''___GM%'' THEN ''Foreign Exchange'' -- (Overseas Branches) Remittance through Internet Banking (manually handled)
			 WHEN [Sender''s Reference]	LIKE ''___DD%'' THEN ''Foreign Exchange'' -- (Overseas Branches) Outward Demand Draft
			 WHEN [Sender''s Reference]	LIKE ''___OC%'' THEN ''Foreign Exchange'' -- (Overseas Branches) Outward Clean Bill Collection
			 WHEN [Sender''s Reference]	LIKE ''___IB%'' THEN ''Inward Bills Negotiation''--(Overseas Branches) Inward Bills Negotiation
			 WHEN [Sender''s Reference]	LIKE ''___FE%'' THEN ''Fund Transfer, Money Market, Bond Investment, FX Transaction'' --(Overseas Branches) Foreign Exchange
			 WHEN [Sender''s Reference]	LIKE ''___LC%'' THEN ''Import Business''--(Overseas Branches) L/C Issuance
			 WHEN [Sender''s Reference]	LIKE ''___EL%'' THEN ''Trade Finance Transaction'' --(Overseas Branches) L/C Advising
			 WHEN [Sender''s Reference]	LIKE ''___DA%'' THEN ''D/A, D/P, O/A (Import)'' --(Overseas Branches) Documents against Acceptance (Import)
			 WHEN [Sender''s Reference]	LIKE ''___DP%'' THEN ''D/A, D/P, O/A (Import)'' --(Overseas Branches) Documents against Payment (Import)
			 WHEN [Sender''s Reference]	LIKE ''___SI%'' THEN ''Fund Transfer, Money Market, Bond Investment, FX Transaction''--(Overseas Branches) Debt Securities Investment
			 WHEN [Sender''s Reference]	LIKE ''___RP%'' THEN ''Fund Transfer, Money Market, Bond Investment, FX Transaction''--(Overseas Branches) Repurchase Order
			 WHEN [Sender''s Reference]	LIKE ''___RS%'' THEN ''Fund Transfer, Money Market, Bond Investment, FX Transaction''--(Overseas Branches) Resale Order
			 WHEN [Sender''s Reference]	LIKE ''___FO%'' THEN ''Fund Transfer, Money Market, Bond Investment, FX Transaction''--(Overseas Branches) Forward Exchange Option
			 WHEN [Sender''s Reference]	LIKE ''___IR%'' THEN ''Fund Transfer, Money Market, Bond Investment, FX Transaction''--(Overseas Branches) Interest Rate Swap
			 WHEN [Sender''s Reference]	LIKE ''___FS%'' THEN ''Fund Transfer, Money Market, Bond Investment, FX Transaction''--(Overseas Branches) Overnight Interbank Fund Transfer (Lending to other Financial Institution)
			 WHEN [Sender''s Reference]	LIKE ''___FP%'' THEN ''Fund Transfer, Money Market, Bond Investment, FX Transaction''--(Overseas Branches) Overnight Interbank Fund Transfer (Borrowing from other Financial Institution)
			 WHEN [Sender''s Reference]	LIKE ''___DF%'' THEN ''Fund Transfer, Money Market, Bond Investment, FX Transaction''--(Overseas Branches) Interbank Fund Transfer (Lending to other Financial Institution)
			 WHEN [Sender''s Reference]	LIKE ''___DT%'' THEN ''Fund Transfer, Money Market, Bond Investment, FX Transaction''--(Overseas Branches) Interbank Fund Transfer (Borrowing from other Financial Institution)
			 WHEN [Sender''s Reference]	LIKE ''___DR%'' THEN ''Fund Transfer, Money Market, Bond Investment, FX Transaction''--(Overseas Branches) Own Account Fund Transfer
			 WHEN [Sender''s Reference]	LIKE ''___CL%'' THEN ''Fund Transfer, Money Market, Bond Investment, FX Transaction''--(Overseas Branches) Call Loan
			 WHEN [Sender''s Reference]	LIKE ''___CD%'' THEN ''Fund Transfer, Money Market, Bond Investment, FX Transaction''--(Overseas Branches) Call Deposit
			 WHEN [Sender''s Reference]	LIKE ''___FF%'' THEN ''Second Forfaiting''--(Overseas Branches) Usance L/C Forfaiting
			 WHEN [Sender''s Reference]	LIKE ''___AF%'' THEN ''Export Business''--(Overseas Branches) D/A Forfaiting
			 WHEN [Sender''s Reference]	LIKE ''___LN%'' THEN ''Loan Business''--(Overseas Branches) Loan Transaction
			 WHEN [Sender''s Reference]	LIKE ''___LG%'' THEN ''Letter of Guarantee''--(Overseas Branches) Guarantee
			 WHEN [Sender''s Reference]	LIKE ''___NS%'' THEN ''Usance Letter of Credit Payable at Sight''--(Overseas Branches) Usance L/C Negotiation at Sight
			 WHEN [Sender''s Reference]	LIKE ''___WM%'' THEN ''Wealth Management Business''--(Overseas Branches) Wealth Management
			 WHEN [Sender''s Reference]	LIKE ''___AD%'' THEN ''Operating/Administration fee payment''--(Overseas Branches) Operating/ Administration fee payment
			 WHEN [Sender''s Reference] LIKE ''___TF%'' THEN ''Interbank Fund Transfer For Mega Bank''''s Affiliates and Correspondent Banks''
			 
		 END

	WHEN LEFT([Reference for Beneficiary],3) IN (''NYA'',''CGO'',''LAC'',''SVB'',''TKY'',''OSA'',''PAR'',''AMS'',''HCM'',''SGP'',''SYD'',''MEL'',''BRI'',''HKG'',''LDN'',''PNM'',''MNL'',
	                                             ''CHO'',''CVR'',''BKK'',''CHB'',''BNA'',''BPO'',''RYO'',''PNH'',''PPA'',''OLY'',''TKK'',''SUZ'',''KUS'',''WUJ'',''NBO'',''LAB'') THEN
		 CASE
			 WHEN [Reference for Beneficiary] LIKE ''___IC%'' THEN ''Customer Wire Transfer/USD Demand Draft''--(Overseas Branches) Inward Clean Bill Collection
			 WHEN [Reference for Beneficiary] LIKE ''___NB%'' THEN ''Export Business''--(Overseas Branches) L/C Negotiation  
			 WHEN [Reference for Beneficiary] LIKE ''___EC%'' THEN ''Export Business''--(Overseas Branches) Documents Collection (Export)
			 WHEN [Reference for Beneficiary] LIKE ''___FF%'' THEN ''Second Forfaiting''--(Overseas Branches) Usance L/C Forfaiting
			 WHEN [Reference for Beneficiary] LIKE ''___NS%'' THEN ''Usance Letter of Credit Payable at Sight''--(Overseas Branches) Usance L/C Negotiation at Sight
			 WHEN [Reference for Beneficiary] LIKE ''___TF%'' THEN ''Interbank Fund Transfer For Mega Banks Affiliates and Correspondent Banks''
		 END

	--Central Bank of China (whitelisted)
	WHEN [Sender''s Reference]	LIKE ''[0-9][0-9][0-9][0-9]JUFX%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''[0-9][0-9][0-9][0-9]EUFX%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''[0-9][0-9][0-9][0-9]AUFX%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''[0-9][0-9][0-9][0-9]YUFX%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''[0-9][0-9][0-9][0-9]SUFX%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''[0-9][0-9][0-9][0-9]AUF%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''[0-9][0-9][0-9][0-9]YUF%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''[0-9][0-9][0-9][0-9]YUF%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''0010BL[0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''[0-9][0-9][0-9][0-9]BUY%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''[0-9][0-9][0-9][0-9]RCD%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''[0-9][0-9][0-9][0-9]TL[0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''AS[0-9][0-9][0-9][0-9]%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''NY-202-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''PMT-ON-%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''PMT-RESE%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''PMT-SPOT%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''PMT-SWTR%'' THEN ''CBC''
	WHEN [Sender''s Reference]	LIKE ''PMT-YUF%'' THEN ''CBC''
	WHEN [Beneficiary Name]		LIKE ''%CENTRAL BANK OF CHINA%'' OR [Beneficiary Name] LIKE ''%CBCTTWTP%'' THEN ''CBC''
	WHEN [Originator Name]		LIKE ''%CENTRAL BANK OF CHINA%'' OR [Originator Name] LIKE ''%CBCTTWTP%'' THEN ''CBC''
	
	--Other Tokens
	WHEN [Amount] = 30 THEN ''Wire Transaction Fee''
	WHEN [Bank to Bank Info_Combined] LIKE ''%PURE%'' THEN ''Bank to Bank Certification''
	WHEN [Bank to Bank Info_Combined] LIKE ''%PURE BANK%'' THEN ''Bank to Bank Certification'' 
	WHEN [Bank to Bank Info_Combined] LIKE ''%PURE%'' THEN ''Bank to Bank Certification'' 	
	WHEN [Bank to Bank Info_Combined] LIKE ''%PURE%'' THEN ''Bank to Bank Certification''
	WHEN [Bank to Bank Info_Combined] LIKE ''%/PURE%'' THEN ''Bank to Bank Certification''
	WHEN [Bank to Bank Info_Combined] LIKE ''%PURE/%'' THEN ''Bank to Bank Certification''
	WHEN [Bank to Bank Info_Combined] LIKE ''%BANK TO BANK%'' THEN ''Bank to Bank Certification''
	WHEN [Bank to Bank Info_Combined] LIKE ''%PURE BANK TO BANK%''  THEN ''Bank to Bank Certification''
	WHEN [Bank to Bank Info_Combined] LIKE ''%BK TO BK%''THEN ''Bank to Bank Certification''
	WHEN [Bank to Bank Info_Combined] LIKE ''%ICBCTWTP024%''  THEN ''Trust''
	WHEN [Bank to Bank Info_Combined] LIKE ''%OMGIS RED%'' THEN ''Trust''
	WHEN [Bank to Bank Info_Combined] LIKE ''%MERCURIES LIFE%''THEN ''Trust''
	WHEN [Bank to Bank Info_Combined] LIKE ''%DIVIDEND%'' THEN ''Trust''
	WHEN [Bank to Bank Info_Combined] LIKE ''%REDEMPTION%''THEN ''Trust''
	WHEN [Bank to Bank Info_Combined] LIKE ''%TRUST%''THEN ''Trust''
	WHEN [Bank to Bank Info_Combined] LIKE ''%BOND%''  THEN ''Trust''
	WHEN [Bank to Bank Info_Combined] LIKE ''%[^RE]FUND[^ING]%'' THEN ''Trust''
	WHEN [Bank to Bank Info_Combined] LIKE ''%UT-SCHRODER%''  THEN ''Trust''
	WHEN [Bank to Bank Info_Combined] LIKE ''%REDEXT%''  THEN ''Trust''
	WHEN [Bank to Bank Info_Combined] LIKE ''%FX%''  THEN ''Foreign Exchange''
	WHEN [Bank to Bank Info_Combined] LIKE ''%FX OPTION%''  THEN ''Foreign Exchange''
	WHEN [Bank to Bank Info_Combined] LIKE ''%/FX OPTION%''  THEN ''Foreign Exchange''
	WHEN [Bank to Bank Info_Combined] LIKE ''%FX OPTION/%''  THEN ''Foreign Exchange''
	WHEN [Bank to Bank Info_Combined] LIKE ''%REFUND%''  THEN ''Refund''

	END AS Purpose_of_Payments
	FROM [eGifts_Concat_Table]
)AS DATA
'

EXEC (@Script)
END