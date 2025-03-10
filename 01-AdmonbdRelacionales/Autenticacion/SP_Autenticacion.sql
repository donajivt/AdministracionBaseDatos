CREATE OR ALTER PROCEDURE sp_CreateLoginAndUser
    @LoginName NVARCHAR(128),
    @Password NVARCHAR(128),
    @UserName NVARCHAR(128),
    @Databases NVARCHAR(MAX) -- Lista de bases de datos separadas por coma
AS
BEGIN
    -- Crear Login
    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @LoginName)
    BEGIN
        EXEC sp_addlogin @LoginName, @Password;
    END

    -- Crear el Usuario y asignarlo a las bases de datos
    DECLARE @Database NVARCHAR(128)
    DECLARE @SQL NVARCHAR(MAX)

    DECLARE db_cursor CURSOR FOR
    SELECT value FROM STRING_SPLIT(@Databases, ',');

    OPEN db_cursor;
    FETCH NEXT FROM db_cursor INTO @Database;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Crear Usuario en la base de datos específica
        SET @SQL = 'USE ' + @Database + '; CREATE USER ' + @UserName + ' FOR LOGIN ' + @LoginName;
        EXEC sp_executesql @SQL;

        -- Asignar permisos básicos (por ejemplo, db_datareader y db_datawriter)
        SET @SQL = 'USE ' + @Database + '; EXEC sp_addrolemember ''db_datareader'', ''' + @UserName + ''';';
        EXEC sp_executesql @SQL;

        SET @SQL = 'USE ' + @Database + '; EXEC sp_addrolemember ''db_datawriter'', ''' + @UserName + ''';';
        EXEC sp_executesql @SQL;

        FETCH NEXT FROM db_cursor INTO @Database;
    END

    CLOSE db_cursor;
    DEALLOCATE db_cursor;
END
GO 

CREATE OR ALTER PROCEDURE sp_AssignServerPermissions
    @LoginName NVARCHAR(50),
    @Permission NVARCHAR(50)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    
    SET @SQL = 'GRANT ' + @Permission + ' TO [' + @LoginName + ']';
    
    EXEC sp_executesql @SQL;
END
GO

CREATE OR ALTER PROCEDURE sp_AssignDatabasePermissions
    @UserName NVARCHAR(50),
    @DatabaseName NVARCHAR(50),
    @Permission NVARCHAR(50)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    
    SET @SQL = 'USE ' + @DatabaseName + '; GRANT ' + @Permission + ' TO [' + @UserName + ']';
    
    EXEC sp_executesql @SQL;
END
GO

CREATE OR ALTER PROCEDURE sp_AssignTablePermissions
    @UserName NVARCHAR(50),
    @DatabaseName NVARCHAR(50),
    @TableName NVARCHAR(50),
    @Permission NVARCHAR(50)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    
    SET @SQL = 'USE ' + @DatabaseName + '; GRANT ' + @Permission + ' ON ' + @TableName + ' TO [' + @UserName + ']';
    
    EXEC sp_executesql @SQL;
END
GO

CREATE OR ALTER PROCEDURE sp_GetUserLoginDetails
AS
BEGIN
    -- Obtener todos los logins y usuarios asociados, junto con las bases de datos asignadas
    SELECT 
        sp.name AS LoginName,
        ISNULL(dp.name, 'N/A') AS UserName,
        ISNULL((
            SELECT STUFF((
                SELECT ', ' + db.name
                FROM sys.databases db
                WHERE EXISTS (
                    SELECT 1
                    FROM sys.database_principals dbp
                    WHERE dbp.sid = sp.sid
                    AND dbp.name = dp.name
                    AND dbp.type IN ('S', 'U')
                )
                FOR XML PATH(''), TYPE
            ).value('(./text())[1]', 'NVARCHAR(MAX)'), 1, 2, '')
        ), 'N/A') AS AssignedDatabases
    FROM sys.server_principals sp
    LEFT JOIN sys.database_principals dp 
        ON sp.sid = dp.sid
    WHERE sp.type IN ('S', 'U') -- Filtra solo logins de tipo SQL y Windows
    ORDER BY sp.name;
END
GO

CREATE OR ALTER PROCEDURE sp_GetTablesForDatabase
    @DatabaseName NVARCHAR(128)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX)

    SET @SQL = 'USE ' + @DatabaseName + '; SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = ''BASE TABLE'';'

    EXEC sp_executesql @SQL;
END
GO

-- Para obtener los permisos a nivel de servidor
CREATE OR ALTER PROCEDURE sp_GetServerPermissions
AS
BEGIN
    SELECT permission_name
    FROM sys.server_permissions
    WHERE class = 0 -- Permisos a nivel de servidor
END
GO

-- Para obtener los permisos a nivel de base de datos
CREATE OR ALTER PROCEDURE sp_GetDatabasePermissions
AS
BEGIN
    SELECT permission_name
    FROM sys.database_permissions
    WHERE class = 0 -- Permisos a nivel de base de datos
END
GO


CREATE OR ALTER PROCEDURE sp_AssignServerPermissions
    @LoginName NVARCHAR(128),
    @Permission NVARCHAR(128)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    
    -- Asegúrate de que el permiso sea válido
    IF @Permission IN ('bulkadmin', 'dbcreator', 'diskadmin', 'processadmin', 'public', 'securityadmin', 'serveradmin', 'setupadmin', 'sysadmin')
    BEGIN
        SET @SQL = 'ALTER SERVER ROLE ' + QUOTENAME(@Permission) + ' ADD MEMBER ' + QUOTENAME(@LoginName);
        EXEC sp_executesql @SQL;
    END
    ELSE
    BEGIN
        RAISERROR('Permiso no válido: %s', 16, 1, @Permission);
    END
END
GO

CREATE OR ALTER PROCEDURE sp_AssignDatabasePermissions
    @UserName NVARCHAR(128),
    @DatabaseName NVARCHAR(128),
    @Permission NVARCHAR(128)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    
    -- Asegúrate de que el permiso sea válido
    IF @Permission IN ('db_accessadmin', 'db_backupoperator', 'db_datareader', 'db_datawriter', 'db_ddladmin', 'db_denydatareader', 'db_denydatawriter', 'db_owner', 'db_securityadmin', 'public')
    BEGIN
        SET @SQL = 'USE ' + QUOTENAME(@DatabaseName) + '; EXEC sp_addrolemember @rolename = ' + QUOTENAME(@Permission) + ', @membername = ' + QUOTENAME(@UserName);
        EXEC sp_executesql @SQL;
    END
    ELSE
    BEGIN
        RAISERROR('Permiso no válido: %s', 16, 1, @Permission);
    END
END
GO

CREATE OR ALTER PROCEDURE sp_AssignDatabasePermissions
    @UserName NVARCHAR(128),
    @DatabaseName NVARCHAR(128),
    @Permission NVARCHAR(128)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    
    -- Asegúrate de que el permiso sea válido y no sea 'public'
    IF @Permission IN ('db_accessadmin', 'db_backupoperator', 'db_datareader', 'db_datawriter', 'db_ddladmin', 'db_denydatareader', 'db_denydatawriter', 'db_owner', 'db_securityadmin')
    BEGIN
        SET @SQL = 'USE ' + QUOTENAME(@DatabaseName) + '; EXEC sp_addrolemember @rolename = ' + QUOTENAME(@Permission) + ', @membername = ' + QUOTENAME(@UserName);
        EXEC sp_executesql @SQL;
    END
    ELSE IF @Permission = 'public'
    BEGIN
        -- No hacer nada, ya que todos los usuarios pertenecen automáticamente al rol 'public'
        PRINT 'El rol "public" no puede ser asignado manualmente.';
    END
    ELSE
    BEGIN
        RAISERROR('Permiso no válido: %s', 16, 1, @Permission);
    END
END
GO

CREATE OR ALTER PROCEDURE sp_GetTablesForDatabase
    @DatabaseName NVARCHAR(128)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);

    -- Construir la consulta dinámica para obtener las tablas de la base de datos seleccionada
    SET @SQL = 'USE ' + QUOTENAME(@DatabaseName) + '; ' +
               'SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = ''BASE TABLE'';';

    -- Ejecutar la consulta dinámica
    EXEC sp_executesql @SQL;
END
GO