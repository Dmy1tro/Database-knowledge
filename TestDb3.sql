
DECLARE @name VARCHAR(50) -- database name 
DECLARE @path VARCHAR(256) -- path for backup files 
DECLARE @fileName VARCHAR(256) -- filename for backup 
DECLARE @fileDate VARCHAR(20) -- used for file name 

SET @path = 'C:\Backup\' 
SET @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 

DECLARE db_cursor CURSOR FOR 
SELECT 
	[name] 
FROM 
	MASTER.dbo.sysdatabases 
WHERE 
	[name] NOT IN ('master','model','msdb','tempdb') 

BEGIN TRY
	OPEN db_cursor
	FETCH NEXT FROM db_cursor INTO @name

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		SET @fileName = @path + @name + '_' + @fileDate + '.BAK'
		SELECT @fileName as [Backup file path];
		BACKUP DATABASE @name TO DISK = @fileName 
		FETCH NEXT FROM db_cursor INTO @name 
	END 

	CLOSE db_cursor  
	DEALLOCATE db_cursor
END TRY
BEGIN CATCH
	CLOSE db_cursor  
	DEALLOCATE db_cursor
END CATCH
