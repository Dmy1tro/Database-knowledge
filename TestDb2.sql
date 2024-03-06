SET TRANSACTION ISOLATION LEVEL READ COMMITTED

-- List of pedning transactions
SELECT * FROM sys.sysprocesses WHERE open_tran <> 0;
SELECT @@TRANCOUNT
DBCC OPENTRAN;

-- Transaction usage
BEGIN TRANSACTION T1
	UPDATE Projects
	SET Name='Transaction Project'
	Where Id = 11
COMMIT TRANSACTION T1;

-- Try/catch with transaction
BEGIN TRY
	BEGIN TRANSACTION T2
		UPDATE Projects
		SET Name='Transaction Project'
		Where Id = 11
	COMMIT TRANSACTION T2;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION T2
END CATCH;

-- Try/catch with transaction and reading error
BEGIN TRY
	BEGIN TRANSACTION T3
		UPDATE Projects
		SET Name=NULL
		Where Id = 11
	COMMIT TRANSACTION T3;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION T3

	SELECT   
        ERROR_NUMBER() AS ErrorNumber
	   ,ERROR_LINE() as ErrorLine
       ,ERROR_MESSAGE() AS ErrorMessage
END CATCH;

--------
-- Check if transaction exists
BEGIN TRY
	UPDATE Projects
	SET Name=NULL
	Where Id = 11

	BEGIN TRANSACTION T3
		UPDATE Projects
		SET Name=NULL
		Where Id = 11
	COMMIT TRANSACTION T3;
END TRY
BEGIN CATCH
	-- If @@TRANCOUNT > 0
	-- Rollback all transactions
	ROLLBACK TRANSACTION

	SELECT   
        ERROR_NUMBER() AS ErrorNumber
	   ,ERROR_LINE() as ErrorLine
       ,ERROR_MESSAGE() AS ErrorMessage
END CATCH;
--------

-- It is important to commit or rollback transaction
-- https://stackoverflow.com/questions/4896479/what-happens-if-you-dont-commit-a-transaction-to-a-database-say-sql-server

-- Opened transactions
SELECT
	trans.session_id AS [SESSION ID]
   ,ESes.host_name AS [HOST NAME],login_name AS [Login NAME]
   ,trans.transaction_id AS [TRANSACTION ID]
   ,tas.name AS [TRANSACTION NAME],tas.transaction_begin_time AS [TRANSACTION BEGIN TIME]
   ,tds.database_id AS [DATABASE ID]
   ,DBs.name AS [DATABASE NAME]
FROM 
	sys.dm_tran_active_transactions tas
JOIN 
	sys.dm_tran_session_transactions trans ON (trans.transaction_id=tas.transaction_id)
LEFT OUTER JOIN 
	sys.dm_tran_database_transactions tds ON (tas.transaction_id = tds.transaction_id)
LEFT OUTER JOIN 
	sys.databases AS DBs ON tds.database_id = DBs.database_id
LEFT OUTER JOIN 
	sys.dm_exec_sessions AS ESes ON trans.session_id = ESes.session_id
WHERE 
	ESes.session_id IS NOT NULL

-- Global variables
SELECT
	@@CONNECTIONS as 'Connections'
   ,@@ERROR as 'ERROR'
   ,@@IDENTITY as 'Identity'
   ,@@IDLE as 'Idle'
   ,@@CPU_BUSY as 'CPU busy'
   ,@@LANGUAGE as 'Language'
   ,@@ROWCOUNT as 'Row count'
   ,@@SERVERNAME as 'Server name'
   ,@@TOTAL_ERRORS as 'Total errors'
   ,@@VERSION as 'Version'
   ,@@TRANCOUNT as 'Tran count'
