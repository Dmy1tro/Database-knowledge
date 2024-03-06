
BEGIN TRY
	BEGIN TRANSACTION MigrateReceiverConfig
		-- Create temp table to hold values from ReceiverConsoleConfiguration table
		CREATE TABLE #TempReceiverConsoleConfiguration(
			[Id] [bigint] NOT NULL,
			[CreatedAt] [datetime2](7) NOT NULL,
			[TecComId] [nvarchar](30) NOT NULL,
			[Configuration] [nvarchar](max) NULL,
			[Category] [int] NOT NULL,
		);

		-- Insert values into temp table
		INSERT INTO #TempReceiverConsoleConfiguration (Id, CreatedAt, TecComId, Configuration, Category)
		SELECT Id, CreatedAt, TecComId, Configuration, Category FROM ReceiverConsoleConfiguration;

		-- Clear table
		DELETE FROM ReceiverConsoleConfiguration;

		-- Insert new values with email
		INSERT INTO ReceiverConsoleConfiguration (CreatedAt, TecComId, Configuration, Category, Email)
		(
			SELECT DISTINCT GETUTCDATE(), T.TecComId, T.Configuration, T.Category, R.Email From Receiver AS R
			JOIN #TempReceiverConsoleConfiguration as T on T.TecComId = R.ReceiverTecComId
			WHERE R.Email IS NOT NULL
		);

		DROP TABLE #TempReceiverConsoleConfiguration;
	COMMIT TRANSACTION MigrateReceiverConfig;
END TRY
BEGIN CATCH
	SELECT
		ERROR_NUMBER() AS ErrorNumber  
		,ERROR_SEVERITY() AS ErrorSeverity  
		,ERROR_STATE() AS ErrorState  
		,ERROR_PROCEDURE() AS ErrorProcedure  
		,ERROR_LINE() AS ErrorLine  
		,ERROR_MESSAGE() AS ErrorMessage;

	ROLLBACK TRANSACTION MigrateReceiverConfig;

	DROP TABLE IF EXISTS #TempReceiverConsoleConfiguration;
END CATCH;


select distinct email, ReceiverTecComId from Receiver
order by ReceiverTecComId desc