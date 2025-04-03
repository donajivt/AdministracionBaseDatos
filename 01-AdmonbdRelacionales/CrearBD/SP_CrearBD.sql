CREATE OR ALTER PROCEDURE SP_CreateDatabase
    @DatabaseName NVARCHAR(128),
    @DataFilePath NVARCHAR(256),
    @LogFilePath NVARCHAR(256),
    @DataSize INT,
    @LogSize INT,
    @FileGrowthData INT,
    @FileGrowthLog INT,
    @FileGroupAdicional NVARCHAR(128) = NULL
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX)

    -- VALIDACIONES
    IF @DatabaseName IS NULL OR @DatabaseName = ''
    BEGIN
        RAISERROR('El nombre de la base de datos no puede ser nulo o vacío', 16, 1)
        RETURN
    END

    IF @DataFilePath IS NULL OR @DataFilePath = '' OR @LogFilePath IS NULL OR @LogFilePath = ''
    BEGIN
        RAISERROR('Las ubicaciones de los archivos no pueden ser nulas o vacías', 16, 1)
        RETURN
    END

    IF @DataSize <= 0 OR @LogSize <= 0
    BEGIN
        RAISERROR('El tamaño de los archivos debe ser mayor que 0', 16, 1)
        RETURN
    END

    -- CREAR BD DATA
    SET @SQL = 'CREATE DATABASE [' + @DatabaseName + '] 
                ON ( NAME = N''' + @DatabaseName + '_Data'', 
                     FILENAME = N''' + @DataFilePath + '\' + @DatabaseName + '.mdf'', 
                     SIZE = ' + CAST(@DataSize AS NVARCHAR) + 'MB, 
                     FILEGROWTH = ' + CAST(@FileGrowthData AS NVARCHAR) + 'MB ) '

    -- LOG
    SET @SQL = @SQL + ' LOG ON 
                    ( NAME = N''' + @DatabaseName + '_Log'', 
                        FILENAME = N''' + @LogFilePath + '\' + @DatabaseName + '.ldf'', 
                        SIZE = ' + CAST(@LogSize AS NVARCHAR) + 'MB, 
                        FILEGROWTH = ' + CAST(@FileGrowthLog AS NVARCHAR) + 'MB )'

    -- Ejecutar la creación de la base de datos
    EXEC sp_executesql @SQL

    -- FILEGROUP ADICIONAL
    IF @FileGroupAdicional IS NOT NULL
    BEGIN
        -- Agregar FILEGROUP
        SET @SQL = 'ALTER DATABASE [' + @DatabaseName + '] ADD FILEGROUP [' + @FileGroupAdicional + ']'
        EXEC sp_executesql @SQL

        -- Agregar archivo al FILEGROUP
        SET @SQL = 'ALTER DATABASE [' + @DatabaseName + '] ADD FILE (
                        NAME = N''' + @DatabaseName + 'ArchivoAsociado'', 
                        FILENAME = N''' + @DataFilePath + '\' + @DatabaseName + '_SECUNDARIO.ndf''
                    ) TO FILEGROUP [' + @FileGroupAdicional + ']'
        EXEC sp_executesql @SQL
    END
END
GO

CREATE OR ALTER PROCEDURE sp_GetDatabases
AS
BEGIN
	SELECT name as 'Nombre'
	FROM sys.databases 
	WHERE state_desc = 'ONLINE' AND name NOT IN ('tempdb', 'model', 'msdb', 'DWDiagnostics','DWConfiguration', 'DWQueue')
END
GO
