--sp_configure 'show advanced options',1  
--reconfigure 

--sp_configure 'Ad Hoc Distributed Queries',1 
--reconfigure

-- https://docs.microsoft.com/en-us/sql/t-sql/functions/openrowset-transact-sql?view=sql-server-ver16 OpenRowSet

SELECT TOP 10 *
FROM OPENROWSET
	(	'MSDASQL'
	   ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};DefaultDir=C:\Users\Downloads\'
	   ,'Select * from "1000000_Sales_Records.csv"') Records;

SELECT TOP 100 * FROM 
OPENROWSET(
	BULK N'C:\Users\Downloads\1000000_Sales_Records.csv',
	SINGLE_CLOB) AS Records

-- https://docs.microsoft.com/en-us/sql/relational-databases/import-export/create-a-format-file-sql-server?view=sql-server-ver16 FMT files
SELECT *
FROM OPENROWSET(
	BULK N'C:\Users\Downloads\1000000_Sales_Records.csv',
    FORMATFILE = N'C:\XChange\test-csv.fmt',
    FIRSTROW=2,
    FORMAT='CSV') AS cars;

SELECT * 
FROM OPENROWSET (
		BULK N'Source3.csv'
		,FORMATFILE = N'RawDataOPENROWSET-FormatFile.xml'
		,FORMAT = 'CSV'
		,CODEPAGE = '65001'
		,FIRSTROW = 2
		,MAXERRORS = 0
	) AS Raw;

-- Temp table
-- How to create temp table #1
SELECT FieldA...FieldN 
INTO #MyTempTable 
FROM MyTable

-- How to create temp table #2
CREATE TABLE #MyTempTable (id INT, name VARCHAR(25))  -- Local scope
CREATE TABLE ##MyGlobalTempTable (id INT, name VARCHAR(25)) -- Global scope
-- Global Temporary Tables are visible to all connections and Dropped when the last connection referencing the table is closed.
-- Global Table Name must have an Unique Table Name.
Drop Table #MyTempTable
Drop Table ##MyGlobalTempTable

DROP TABLE IF EXISTS #SalesRecords;
CREATE TABLE #SalesRecords (
	--Id INT IDENTITY(1,1) NOT NULL,
	Region NVARCHAR(100) NOT NULL,
	Country NVARCHAR(100) NOT NULL,
	ItemType NVARCHAR(100) NOT NULL,
	SalesChannel NVARCHAR(100) NOT NULL,
	OrderPriority NVARCHAR(100) NOT NULL,
	OrderDate NVARCHAR(100) NOT NULL,
	OrderID NVARCHAR(100) NOT NULL,
	ShipDate NVARCHAR(100) NOT NULL,
	UnitsSold NVARCHAR(100) NOT NULL,
	UnitPrice DECIMAL(19, 4) NOT NULL,
	UnitCost DECIMAL(19, 4) NOT NULL,
	TotalRevenue DECIMAL(19, 4) NOT NULL,
	TotalCost DECIMAL(19, 4) NOT NULL,
	TotalProfit DECIMAL(19, 4) NOT NULL,
)

DECLARE @ValidRecordsPath VARCHAR(100) = 'C:\Users\Downloads\1000000_Sales_Records.csv';
DECLARE @InvalidRecordsPath VARCHAR(100) = 'C:\Users\Downloads\1000000 Sales Records\1000000 Sales Records.csv';

BULK INSERT #SalesRecords
FROM 'C:\Users\Downloads\1000000 Sales Records\1000000 Sales Records.csv'
WITH
(
    FORMAT='CSV',
	FIRSTROW=2,
	CODEPAGE = '65001', -- UTF8
	ERRORFILE = 'C:\Users\Downloads\1000000_Sales_Records.ERROR.txt', -- Creates a file if any errors. Throw exception if file already exists
	--FIELDQUOTE='"',
	FIELDTERMINATOR=',',
	ROWTERMINATOR='0x0a',
	MAXERRORS=9999
	--LASTROW=600000
)
GO

Select top 100 * from #SalesRecords;

DROP TABLE IF EXISTS #SalesRecords;
