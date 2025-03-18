CREATE OR ALTER PROCEDURE sp_BackupDatabase
    @DatabaseName NVARCHAR(128),
    @BackupType NVARCHAR(20)
AS
BEGIN
    DECLARE @Timestamp NVARCHAR(20)
    DECLARE @BackupDirectory NVARCHAR(256)
    DECLARE @FullBackupDirectory NVARCHAR(256)
    DECLARE @DifferentialBackupDirectory NVARCHAR(256)
    DECLARE @LogBackupDirectory NVARCHAR(256)
    DECLARE @BackupFileName NVARCHAR(256)
    DECLARE @BackupPath NVARCHAR(256)
    DECLARE @IsValidDatabase INT
    DECLARE @BackupCommand NVARCHAR(MAX)
	DECLARE @FullBackupExists INT
    -- Validar si la base de datos existe
    SELECT @IsValidDatabase = COUNT(*)
    FROM sys.databases
    WHERE name = @DatabaseName

    IF @IsValidDatabase = 0
    BEGIN
        RAISERROR('La base de datos no existe.', 16, 1)
        RETURN
    END

    -- Obtener el timestamp para evitar sobrescribir los archivos
    SET @Timestamp = REPLACE(CONVERT(NVARCHAR, GETDATE(), 120), ':', '_')

    SET @BackupDirectory = 'C:\Backups\' + @DatabaseName
    SET @FullBackupDirectory = @BackupDirectory + '\Full'
    SET @DifferentialBackupDirectory = @BackupDirectory + '\Differential'
    SET @LogBackupDirectory = @BackupDirectory + '\Log'

	-- Verificar si existe un backup FULL en `msdb.dbo.backupset`
    IF @BackupType IN ('DIFFERENTIAL', 'LOG')
    BEGIN
        SELECT @FullBackupExists = COUNT(*)
        FROM msdb.dbo.backupset
        WHERE database_name = @DatabaseName AND type = 'D' -- 'D' indica FULL

        IF @FullBackupExists = 0
        BEGIN
            RAISERROR('No se puede realizar un backup de %s ya que no existe un backup completo previo.', 16, 1, @BackupType)
            RETURN
        END
    END
    -- Realizar el Backup según el tipo proporcionado
    IF @BackupType = 'FULL'
    BEGIN
		 IF NOT EXISTS (SELECT * FROM sys.master_files WHERE physical_name = @FullBackupDirectory)
		BEGIN
			EXEC xp_create_subdir @FullBackupDirectory
		END
        SET @BackupFileName = @FullBackupDirectory + '\BackupFull_' + @Timestamp + '.bak'
        SET @BackupPath = @BackupFileName

        -- Construir la cadena del comando de Backup completo
        SET @BackupCommand = 'BACKUP DATABASE ' + QUOTENAME(@DatabaseName) + 
                             ' TO DISK = ''' + @BackupPath + ''' ' +
                             'WITH NAME = ''BackupCompleto_' + @Timestamp + ''', ' +
                             'DESCRIPTION = ''Backup completo de la base de datos ' + @DatabaseName + ''''
        
        -- Ejecutar el comando de Backup completo
        EXEC sp_executesql @BackupCommand
    END
    ELSE IF @BackupType = 'DIFFERENTIAL'
    BEGIN
		IF NOT EXISTS (SELECT * FROM sys.master_files WHERE physical_name = @DifferentialBackupDirectory)
		BEGIN
			EXEC xp_create_subdir @DifferentialBackupDirectory
		END
        SET @BackupFileName = @DifferentialBackupDirectory + '\BackupDifferential_' + @Timestamp + '.bak'
        SET @BackupPath = @BackupFileName

        -- Construir la cadena del comando de Backup diferencial
        SET @BackupCommand = 'BACKUP DATABASE ' + QUOTENAME(@DatabaseName) + 
                             ' TO DISK = ''' + @BackupPath + ''' ' +
                             'WITH NAME = ''BackupDiferencial_' + @Timestamp + ''', ' +
                             'DESCRIPTION = ''Backup diferencial de la base de datos ' + @DatabaseName + ''', ' +
                             'DIFFERENTIAL'
        
        -- Ejecutar el comando de Backup diferencial
        EXEC sp_executesql @BackupCommand
    END
    ELSE IF @BackupType = 'LOG'
    BEGIN
		IF NOT EXISTS (SELECT * FROM sys.master_files WHERE physical_name = @LogBackupDirectory)
		BEGIN
			EXEC xp_create_subdir @LogBackupDirectory
		END
        SET @BackupFileName = @LogBackupDirectory + '\BackupLog_' + @Timestamp + '.bak'
        SET @BackupPath = @BackupFileName

        -- Construir la cadena del comando de Backup de log
        SET @BackupCommand = 'BACKUP LOG ' + QUOTENAME(@DatabaseName) + 
                             ' TO DISK = ''' + @BackupPath + ''' ' +
                             'WITH NAME = ''BackupLog_' + @Timestamp + ''', ' +
                             'DESCRIPTION = ''Backup de log de la base de datos ' + @DatabaseName + ''''
        
        -- Ejecutar el comando de Backup de log
        EXEC sp_executesql @BackupCommand
    END
    ELSE
    BEGIN
        RAISERROR('Tipo de backup no válido. Utiliza FULL, DIFFERENTIAL o LOG.', 16, 1)
    END
END
GO

CREATE OR ALTER PROCEDURE sp_GetDatabasesWithBackups
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        bs.database_name AS DatabaseName,
        CASE 
            WHEN bs.type = 'D' THEN 'FULL'
            WHEN bs.type = 'I' THEN 'DIFFERENTIAL'
            WHEN bs.type = 'L' THEN 'LOG'
            ELSE 'DESCONOCIDO'
        END AS BackupType,
        bs.backup_start_date AS BackupStartDate,
        bs.backup_finish_date AS BackupFinishDate
    FROM msdb.dbo.backupset bs
    INNER JOIN msdb.dbo.backupmediafamily bmf
        ON bs.media_set_id = bmf.media_set_id
    ORDER BY bs.database_name, bs.backup_start_date DESC;
END;
GO


