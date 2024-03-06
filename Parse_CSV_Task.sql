---------------------------------------------------------------------------------
-- Create temp table

DROP TABLE IF EXISTS #JewelrySalesRecords;
CREATE TABLE #JewelrySalesRecords (
	Data NVARCHAR(50) NOT NULL,
	DocNum INT NOT NULL,
	Status NVARCHAR(100) NOT NULL,
	ClientsName NVARCHAR(50) NOT NULL,
	BarCode BIGINT NOT NULL,
	ArtNum NVARCHAR(50) NOT NULL,
	ProductName NVARCHAR(50) NOT NULL,
	Type NVARCHAR(50) NOT NULL,
	Size NVARCHAR(50) NOT NULL,
	StoneWgh NVARCHAR(50) NOT NULL,
	Weight NVARCHAR(50) NOT NULL,
	DateIncome NVARCHAR(50) NOT NULL,
	Price NVARCHAR(50) NOT NULL
)

BULK INSERT #JewelrySalesRecords
FROM 'Source3.csv'
WITH
(
    --FORMAT = 'CSV',
	DATAFILETYPE = 'char',
	FIRSTROW = 2,
	CODEPAGE = '65001', -- UTF8
	ERRORFILE = 'Source.ERROR.txt',
	FIELDTERMINATOR=  '\t',
	MAXERRORS = 2
	--ROWTERMINATOR='0x0a'
)
GO

SELECT COUNT(*) From #JewelrySalesRecords
Select top 100 * from #JewelrySalesRecords

----------------------------------------------------------------------------------------------
-- Modeling

-- ProductType
-- Id, Name(ProductName)

-- Product
-- Id (BarCode), ArtNum, ProductTypeId, Type, Size, StoneWgh, Weight, DateIncome, Price

-- InvoiceProduct
-- Id, InvoiceId, ProductId

-- Invoice
-- Id (DocNum), ClientId, Status, Data

-- Client
-- Id, Name (ClientName)

Select top 100 * from #JewelrySalesRecords
order by DocNum


Select Count(Distinct BarCode) from #JewelrySalesRecords
Select Count(*) from #JewelrySalesRecords
Select Distinct BarCode from #JewelrySalesRecords

Select top 100 [BarCode], COUNT([BarCode]) as BarCodeCount from #JewelrySalesRecords
Group By [BarCode]
Having COUNT([BarCode]) > 1

Select top 100 * from [#JewelrySalesRecords]
Where [BarCode] = '200303918838'

Select Distinct top 100 ProductName from #JewelrySalesRecords

Select distinct top 100 [Type] from #JewelrySalesRecords

Select top 100 * from [#JewelrySalesRecords]
Where CONVERT(datetime, [DateIncome], 104) < CONVERT(datetime, [Data], 104)

Select top 100 * from [#JewelrySalesRecords]
Where CONVERT(datetime, [DateIncome], 104) > CONVERT(datetime, [Data], 104)

Select Distinct top 500 ArtNum from [#JewelrySalesRecords]

Select distinct top 100 DocNum from [#JewelrySalesRecords]

DECLARE @DecimalValue Decimal(18, 4) = TRY_PARSE('26,5' as Decimal(18, 4) USING 'El-GR')
SELECT @DecimalValue

------------------------------------------------------------------------------------------------
-- Creating tables

CREATE TABLE [ProductType](
	[Id] INT IDENTITY(1, 1) NOT NULL,
	[Name] NVARCHAR(100) NOT NULL,

	CONSTRAINT [PR_ProductType] PRIMARY KEY ([Id])
)

CREATE TABLE [Product](
	[Id] BIGINT IDENTITY(1, 1) NOT NULL,
	[ArtNum] NVARCHAR(50) NOT NULL,
	[ProductTypeId] INT NOT NULL,
	[Type] NVARCHAR(50) NOT NULL,
	[Size] DECIMAL(18, 4) NULL,
	[StoneWgh] DECIMAL(18, 4) NOT NULL,
	[Weight] DECIMAL(18, 4) NOT NULL,
	[DateIncome] DATETIME NOT NULL,
	[Price] DECIMAL(18, 4) NOT NULL,

	CONSTRAINT [PR_Product] PRIMARY KEY ([Id]),
	CONSTRAINT [FK_ProductType] FOREIGN KEY ([ProductTypeId]) REFERENCES [ProductType]([Id])
)

CREATE TABLE [Client](
	[Id] INT IDENTITY(1, 1) NOT NULL,
	[Name] NVARCHAR(100) NOT NULL,

	CONSTRAINT [PR_Client] PRIMARY KEY ([Id])
)

CREATE TABLE [Invoice](
	[Id] INT IDENTITY(1, 1) NOT NULL,
	[DocNum] INT NOT NULL,
	[ClientId] INT NOT NULL,
	[Status] NVARCHAR(100) NOT NULL,
	[Data] DATETIME NOT NULL,

	CONSTRAINT [PR_Invoice] PRIMARY KEY ([Id]),
	CONSTRAINT [FK_Client] FOREIGN KEY ([ClientId]) REFERENCES [Client]([Id])
)

CREATE TABLE [InvoiceProduct](
	[Id] INT IDENTITY(1, 1) NOT NULL,
	[InvoiceId] INT NOT NULL,
	[ProductId] BIGINT NOT NULL,

	CONSTRAINT [PK_InvoiceProduct] PRIMARY KEY ([Id]),
	CONSTRAINT [FK_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [Invoice]([Id]),
	CONSTRAINT [FK_Product] FOREIGN KEY ([ProductId]) REFERENCES [Product]([Id])
)

--------------------------------------------------------------------------------------------
-- Populate tables

-- [ProductType]
INSERT INTO [ProductType] ([Name])
SELECT DISTINCT ProductName From #JewelrySalesRecords

SELECT TOP 100 * FROM [ProductType]

-- [Product]
SET IDENTITY_INSERT [Product] ON
GO

INSERT INTO [Product] ([Id], [ArtNum], [ProductTypeId], [Type], [Size], [StoneWgh], [Weight], [DateIncome], [Price])
SELECT DISTINCT 
	[BarCode], 
	[ArtNum], 
	[pd].[Id],
	[Type], 
	TRY_PARSE([Size] as Decimal(18, 4) USING 'El-GR'), 
	TRY_PARSE([StoneWgh] as Decimal(18, 4) USING 'El-GR'), 
	TRY_PARSE([Weight] as Decimal(18, 4) USING 'El-GR'), 
	CONVERT(DATETIME, [DateIncome], 104),
	TRY_PARSE([Price] as Decimal(18, 4) USING 'El-GR')
FROM 
	#JewelrySalesRecords AS [temp]
JOIN 
	[ProductType] as [pd] ON [pd].[Name] = [temp].[ProductName]

SET IDENTITY_INSERT [Product] OFF
GO

SELECT * FROM [ProductType]

SELECT TOP 5 * FROM [Product]
ORDER BY [Id] asc

SELECT TOP 5 * from #JewelrySalesRecords
ORDER BY BarCode asc

-- [Client]
INSERT INTO [Client] ([Name])
SELECT DISTINCT ClientsName FROM #JewelrySalesRecords

SELECT TOP 100 * from [Client]

-- [Invoice]
INSERT INTO [Invoice] ([DocNum], [ClientId], [Status], [Data])
SELECT DISTINCT 
	[DocNum],
	[c].Id,
	[Status],
	CONVERT(DATETIME, [Data], 104)
FROM 
	#JewelrySalesRecords as [temp]
JOIN 
	[Client] as [c] on [c].[Name] = [temp].ClientsName

Select top 100 * from [Invoice]

Select top 100 * from #JewelrySalesRecords
Order by [DocNum]

-- [InvoiceProduct]
INSERT INTO [InvoiceProduct] (InvoiceId, ProductId)
SELECT DISTINCT
	[i].Id, 
	[p].Id
FROM
	#JewelrySalesRecords as [temp]
JOIN
	[Client] as [c] on [c].[Name] = [temp].ClientsName
JOIN
	[Invoice] as [i] on [i].[DocNum] = [temp].DocNum AND 
						[i].[Data] = CONVERT(DATETIME, [temp].[Data], 104) AND
						[i].[Status] = [temp].[Status] AND
						[i].[ClientId] = [c].[id]
JOIN
	[Product] as [p] on [p].Id = [temp].[BarCode]

Select top 100 * from [InvoiceProduct]


Select [InvoiceId], COUNT([InvoiceId]) from [InvoiceProduct]
GROUP BY [InvoiceId]
ORDER BY COUNT([InvoiceId])


SELECT * From [Invoice] as [i]
JOIN [InvoiceProduct] as [ip] on [ip].InvoiceId = [i].Id
JOIN [Product] as [p] on [p].Id = [ip].ProductId
WHERE [i].[Id] = 386

--------------------------------------------------------------------
-- Creating Format file

-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1
GO
-- To update the currently configured value for advanced options.
RECONFIGURE
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1
GO
-- To update the currently configured value for this feature.
RECONFIGURE
GO

DECLARE @createFormatFileCommand VARCHAR(100)
SET @createFormatFileCommand = 'bcp Invoice format nul -c -x -f JewelrySalesRecords.xml -t, -T'
EXEC xp_cmdshell @createFormatFileCommand
GO
--
