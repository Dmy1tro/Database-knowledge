-- https://docs.microsoft.com/en-us/sql/relational-databases/system-compatibility-views/sys-sysobjects-transact-sql?view=sql-server-ver16

IF EXISTS (SELECT * FROM sysobjects WHERE Name = 'SalesRecords' AND XTYPE = 'u')
	DROP TABLE SalesRecords;
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE Name = 'SalesRecords' AND XTYPE = 'u')
	CREATE TABLE SalesRecords (
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
GO

BULK INSERT SalesRecords
FROM 'C:\Users\Downloads\1000000_Sales_Records.csv'
WITH
(
    FORMAT='CSV',
	FIRSTROW=2,
	--FIELDQUOTE='"',
	FIELDTERMINATOR=',',
	ROWTERMINATOR='0x0a'
	--MAXERRORS=9999,
	--LASTROW=400000
)
GO

Select Count(*) From [SalesRecords]

-- select *
-- into #T
-- from openrowset('MSDASQL', 'Driver={Microsoft Text Driver (.txt; .csv)};
-- DefaultDir={C:\Users\Downloads};Extensions=csv;',
-- 'select * from 1000000_Sales_Records.csv') Test;

-- Select Count(*) FROM #T;
