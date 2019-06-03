USE [WRCT]
GO
/****** Object:  StoredProcedure [dbo].[DROP_RECREATE]    Script Date: 6/3/2019 12:53:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DROP_RECREATE]
@ALLDATABASE VARCHAR(MAX)
AS
BEGIN
Declare @Script VARCHAR(MAX)
SET @Script = '
IF OBJECT_ID(''dbo.MainTable'', ''U'') IS NOT NULL 
   DROP TABLE dbo.MainTable;
IF OBJECT_ID(''dbo.MainTable_Temp'', ''U'') IS NOT NULL 
   DROP TABLE dbo.MainTable_Temp;
IF OBJECT_ID(''dbo.OutputTable'', ''U'') IS NOT NULL 
   DROP TABLE dbo.OutputTable;
IF OBJECT_ID(''dbo.OutputTable_Temp'', ''U'') IS NOT NULL 
   DROP TABLE dbo.OutputTable_Temp;

EXEC CREATE_MAIN_TABLES @ALLDATABASE = '''+@ALLDATABASE+'''
'
EXEC (@Script)
END
