CREATE OR ALTER PROCEDURE sp_CreateDatabase
    @DatabaseName NVARCHAR(128),
    @DataFileName NVARCHAR(128),
    @DataFilePath NVARCHAR(255),
    @DataSize INT,
    @DataFileGrowth NVARCHAR(50),
    @MaxDataSize NVARCHAR(50),
    @LogFileName NVARCHAR(128),
    @LogFilePath NVARCHAR(255),
    @LogSize INT,
    @LogFileGrowth NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF @DatabaseName IS NULL OR @DatabaseName = ''
        THROW 50000, 'El nombre de la base de datos no puede ser nulo o vacío.', 1;

    IF @DataFileName IS NULL OR @DataFileName = ''
        THROW 50001, 'El nombre del archivo de datos no puede ser nulo o vacío.', 1;

    IF @DataFilePath IS NULL OR @DataFilePath = ''
        THROW 50002, 'La ruta del archivo de datos no puede ser nula o vacía.', 1;

    IF @LogFileName IS NULL OR @LogFileName = ''
        THROW 50003, 'El nombre del archivo de log no puede ser nulo o vacío.', 1;

    IF @LogFilePath IS NULL OR @LogFilePath = ''
        THROW 50004, 'La ruta del archivo de log no puede ser nula o vacía.', 1;

    IF @DataSize <= 0
        THROW 50005, 'El tamaño del archivo de datos debe ser mayor a 0 MB.', 1;

    IF @LogSize <= 0
        THROW 50006, 'El tamaño del archivo de log debe ser mayor a 0 MB.', 1;

    DECLARE @Sql NVARCHAR(MAX);

    SET @Sql = 'CREATE DATABASE ' + QUOTENAME(@DatabaseName) + ' 
    ON PRIMARY (
        NAME = ' + QUOTENAME(@DataFileName, '''') + ',
        FILENAME = ' + QUOTENAME(@DataFilePath + '\' + @DatabaseName + '.mdf', '''') + ',
        SIZE = ' + CAST(@DataSize AS NVARCHAR(50)) + 'MB,  -- El tamaño en MB sigue siendo un número
        FILEGROWTH = ' + @DataFileGrowth + ',
        MAXSIZE = ' + @MaxDataSize + '
    )
    LOG ON (
        NAME = ' + QUOTENAME(@LogFileName, '''') + ',
        FILENAME = ' + QUOTENAME(@LogFilePath + '\' + @DatabaseName + '.ldf', '''') + ',
        SIZE = ' + CAST(@LogSize AS NVARCHAR(50)) + 'MB,  -- El tamaño de log también en MB
        FILEGROWTH = ' + @LogFileGrowth + '
    );';

    EXEC sp_executesql @Sql;
END;
GO
