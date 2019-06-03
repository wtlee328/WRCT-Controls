USE [WRCT]
GO
/****** Object:  StoredProcedure [dbo].[CREATE_MAIN_TABLES]    Script Date: 6/3/2019 12:45:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[CREATE_MAIN_TABLES]
@ALLDATABASE VARCHAR(MAX)
AS

BEGIN

Declare @Script VARCHAR(MAX)
SET @Script =

'
EXEC eGifts_Concat @DATABASE = '''+@ALLDATABASE+'''

IF OBJECT_ID(''dbo.MainTable_Temp'', ''U'') IS NOT NULL 
   DROP TABLE dbo.MainTable_Temp;

--1)Beneficiary_Bank_Country
EXEC dbo.Country_Identifier     	@ACCT_NO = ''[Coal_Beneficiary_Bank_ID]'',
									@NAME = ''[Coal_Beneficiary_Bank_Name]'',
									@ADDRESS = ''[Coal_Beneficiary_Bank_Address]'',
									@Control_Temp_Table = ''Nesting_Receiver_Beneficiary_Bank'',
									@Country = ''Beneficiary_Bank_Country'' 

--2)Receiver_Correspondent_Bank_Country
EXEC dbo.Country_Identifier			@ACCT_NO = ''[Receiving Bank ID]'',
									@NAME = ''[Receiving Bank Name]'',
									@ADDRESS = ''[Receiving Bank Address]'',
									@Control_Temp_Table = ''Nesting_Receiver_Correspondent_Bank'',
									@Country = ''Receiver_Correspondent_Bank_Country''

--3)Sender_Correspondent_Bank_Country
EXEC dbo.Country_Identifier			@ACCT_NO = ''[Sending Bank ID]'',
									@NAME = ''[Sending Bank Name]'',
									@ADDRESS = ''[Sending Bank Address]'',
									@Control_Temp_Table = ''Nesting_Sender_Correspondent_Bank'',
									@Country = ''Sender_Correspondent_Bank_Country'' 

--4)Originator_Bank_Country
EXEC dbo.Country_Identifier  		@ACCT_NO = ''[Coal_Originator_Bank_ID]'',
									@NAME = ''[Coal_Originator_Bank_Name]'',
									@ADDRESS = ''[Coal_Originator_Bank_Address]'',
									@Control_Temp_Table= ''Nesting_Sender_Ordering_Bank'',
									@Country = ''Originator_Bank_Country'' 

--5)Beneficiary_Country
EXEC dbo.Country_Identifier			@ACCT_NO = ''[Coal_Beneficiary_ID]'',
									@NAME = ''[Coal_Beneficiary_Name]'',
									@ADDRESS = ''[Coal_Beneficiary_Address]'',
									@Control_Temp_Table = ''Nesting_Beneficiary'',
									@Country = ''Beneficiary_Country'' 

--6)Originator_Country
EXEC dbo.Country_Identifier 		@ACCT_NO = ''[Coal_Originator_ID]'',
									@NAME = ''[Coal_Originator_Name]'',
									@ADDRESS = ''[Coal_Originator_Address]'',
									@Control_Temp_Table= ''Originator'',
									@Country = ''Originator_Country'' 

--Purpose of Payments
EXEC dbo.Purpose_of_Payments		@DATABASE = '''+@ALLDATABASE+'''



SELECT dbo.Purpose_TempT.[Transaction Number],
	   dbo.Purpose_TempT.[Purpose_of_Payments],
	   dbo.Nesting_Receiver_Beneficiary_Bank.[Coal_Beneficiary_Bank_ID],					        --1
	   dbo.Nesting_Receiver_Correspondent_Bank.[Receiving Bank ID],					        	--2
	   dbo.Nesting_Sender_Correspondent_Bank.[Sending Bank ID],								    --3
	   dbo.Nesting_Sender_Ordering_Bank.[Coal_Originator_Bank_ID],							        --4
	   dbo.Nesting_Beneficiary.[Coal_Beneficiary_ID],										        --5
	   dbo.Originator.[Coal_Originator_ID],														    --6
	   dbo.Nesting_Receiver_Beneficiary_Bank.[Beneficiary_Bank_Country],						--1
	   dbo.Nesting_Receiver_Correspondent_Bank.[Receiver_Correspondent_Bank_Country],			--2
	   dbo.Nesting_Sender_Correspondent_Bank.[Sender_Correspondent_Bank_Country],				--3
	   dbo.Nesting_Sender_Ordering_Bank.[Originator_Bank_Country],								--4
	   dbo.Nesting_Beneficiary.[Beneficiary_Country],											--5
	   dbo.Originator.[Originator_Country],														--6
	   dbo.Purpose_TempT.[QueryDate],
	   [dbo].[eGifts_Concat_Table].[Sender''s Reference], 
	   [dbo].[eGifts_Concat_Table].[Reference for Beneficiary],
	   [dbo].[eGifts_Concat_Table].[Bank to Bank Info_Combined],
	   [dbo].[eGifts_Concat_Table].[Amount],
	   [dbo].[eGifts_Concat_Table].[Originator Name], 
	   [dbo].[eGifts_Concat_Table].[Originator Bank Name],
	   [dbo].[eGifts_Concat_Table].[Instructing Bank Name]

INTO MainTable_Temp
FROM Nesting_Receiver_Beneficiary_Bank 
JOIN Nesting_Receiver_Correspondent_Bank    ON Nesting_Receiver_Beneficiary_Bank.[Transaction Number]       = Nesting_Receiver_Correspondent_Bank.[Transaction Number] 
JOIN Nesting_Sender_Correspondent_Bank		ON Nesting_Receiver_Correspondent_Bank.[Transaction Number]     = Nesting_Sender_Correspondent_Bank.[Transaction Number]
JOIN Nesting_Sender_Ordering_Bank			ON Nesting_Sender_Correspondent_Bank.[Transaction Number]		= Nesting_Sender_Ordering_Bank.[Transaction Number]
JOIN Nesting_Beneficiary					ON Nesting_Sender_Ordering_Bank.[Transaction Number]			= Nesting_Beneficiary.[Transaction Number]
JOIN Purpose_TempT							ON Nesting_Beneficiary.[Transaction Number]						= Purpose_TempT.[Transaction Number]
JOIN Originator								ON Purpose_TempT.[Transaction Number]							= Originator.[Transaction Number]
JOIN [dbo].[eGifts_Concat_Table]            ON [dbo].[eGifts_Concat_Table].[Transaction Number]             = Purpose_TempT.[Transaction Number]

DROP TABLE [dbo].[Nesting_Beneficiary]
DROP TABLE [dbo].[Nesting_Receiver_Beneficiary_Bank]
DROP TABLE [dbo].[Nesting_Receiver_Correspondent_Bank]
DROP TABLE [dbo].[Nesting_Sender_Ordering_Bank]
DROP TABLE [dbo].[Nesting_Sender_Correspondent_Bank]
DROP TABLE [dbo].[Purpose_TempT]
DROP TABLE [dbo].[Originator]
DROP TABLE [dbo].[FULL_TABLE]

IF OBJECT_ID(''dbo.MainTable'', ''U'') IS NULL  --If MainTable is null, pull data from MainTable_Temp into MainTable
   SELECT * INTO MainTable FROM dbo.MainTable_Temp;
ELSE
INSERT INTO dbo.MainTable --If MainTable exists, update MainTable from MainTable_Temp data where Transaction Number is unique
SELECT * FROM dbo.MainTable_Temp	 
WHERE [Transaction Number] NOT IN(SELECT [Transaction Number] FROM dbo.MainTable)

EXEC [dbo].[Create_OutputTable_Temp]

IF OBJECT_ID(''dbo.OutputTable'', ''U'') IS NULL  --If OutputTable is null, pull data from OutputTable_Temp into OutputTable
   SELECT * INTO OutputTable FROM dbo.OutputTable_Temp;
ELSE
INSERT INTO dbo.OutputTable --If OutputTable exists, update OutputTable from OutputTable_Temp data where Transaction Number is unique
SELECT * FROM dbo.OutputTable_Temp	 
WHERE [Transaction Number] NOT IN(SELECT [Transaction Number] FROM dbo.OutputTable)
'

EXEC (@Script)
END
