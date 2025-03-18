CREATE OR ALTER PROCEDURE sp_CreateLoginAndUser
    @LoginName NVARCHAR(128),
    @Password NVARCHAR(128),
    @UserName NVARCHAR(128),
    @Databases NVARCHAR(MAX) 
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el login ya existe
    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @LoginName)
    BEGIN
        EXEC sp_addlogin @LoginName, @Password;
    END
    ELSE
    BEGIN
        PRINT 'El login ya existe: ' + @LoginName;
    END

    -- Declaración de variables
    DECLARE @Database NVARCHAR(128);
    DECLARE @SQL NVARCHAR(MAX);

    DECLARE db_cursor CURSOR FOR
    SELECT value FROM STRING_SPLIT(@Databases, ',');

    OPEN db_cursor;
    FETCH NEXT FROM db_cursor INTO @Database;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Validar si la base de datos existe
        IF EXISTS (SELECT 1 FROM sys.databases WHERE name = @Database)
        BEGIN
            SET @SQL = 'USE ' + QUOTENAME(@Database) + 
                       '; IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = ''' + @UserName + ''')
                       BEGIN
                           CREATE USER ' + QUOTENAME(@UserName) + ' FOR LOGIN ' + QUOTENAME(@LoginName) + '
                       END
                       ELSE
                       BEGIN
                           PRINT ''El usuario ya existe en la base de datos: ' + @Database + '''
                       END';
            EXEC sp_executesql @SQL;
        END
        ELSE
        BEGIN
            PRINT 'La base de datos no existe: ' + @Database;
        END
        
        FETCH NEXT FROM db_cursor INTO @Database;
    END

    CLOSE db_cursor;
    DEALLOCATE db_cursor;
END
GO

CREATE OR ALTER PROCEDURE sp_AssignServerPermissions
    @LoginName NVARCHAR(50),
    @Permissions NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @LoginName)
    BEGIN
        PRINT 'El login no existe: ' + @LoginName;
        RETURN;
    END
    
    DECLARE @Permission NVARCHAR(50);
    DECLARE perm_cursor CURSOR FOR SELECT value FROM STRING_SPLIT(@Permissions, ',');
    
    OPEN perm_cursor;
    FETCH NEXT FROM perm_cursor INTO @Permission;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @SQL NVARCHAR(MAX) = 'ALTER SERVER ROLE ' + @Permission + ' ADD MEMBER [' + @LoginName + ']';
        EXEC sp_executesql @SQL;
        FETCH NEXT FROM perm_cursor INTO @Permission;
    END
    
    CLOSE perm_cursor;
    DEALLOCATE perm_cursor;
END
GO

CREATE OR ALTER PROCEDURE sp_AssignDatabasePermissions
    @UserName NVARCHAR(50),
    @DatabaseName NVARCHAR(50),
    @Permissions NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @DatabaseName)
    BEGIN
        PRINT 'La base de datos no existe: ' + @DatabaseName;
        RETURN;
    END
    
    DECLARE @Permission NVARCHAR(50);
    DECLARE perm_cursor CURSOR FOR SELECT value FROM STRING_SPLIT(@Permissions, ',');
    
    OPEN perm_cursor;
    FETCH NEXT FROM perm_cursor INTO @Permission;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @SQL NVARCHAR(MAX) = 'USE ' + QUOTENAME(@DatabaseName) + '; ALTER ROLE  ' + @Permission + ' ADD MEMBER [' + @UserName + ']';
        EXEC sp_executesql @SQL;
        FETCH NEXT FROM perm_cursor INTO @Permission;
    END
    
    CLOSE perm_cursor;
    DEALLOCATE perm_cursor;
END
GO

-- OBTENER USUARIOS, LOGINS Y SUS BD CON SUS ROLES DE SERVIDOR Y BD
CREATE OR ALTER PROCEDURE sp_GetAllUserRoles
AS
BEGIN
    DECLARE @Database NVARCHAR(255);
    DECLARE @SQL NVARCHAR(MAX);

    -- Crear tabla temporal para almacenar los resultados
    CREATE TABLE #UserRoles (
        DatabaseName NVARCHAR(255),
        LoginName NVARCHAR(255),
        UserName NVARCHAR(255),
        DatabaseRoles NVARCHAR(MAX),
        ServerRoles NVARCHAR(MAX)
    );

    -- Cursor para recorrer todas las bases de datos del servidor, excluyendo bases de datos del sistema
    DECLARE db_cursor CURSOR FOR
    SELECT name FROM sys.databases
    WHERE state_desc = 'ONLINE'
    AND name NOT IN ('tempdb', 'model', 'msdb', 'DWDiagnostics', 'DWConfiguration', 'DWQueue'); 

    OPEN db_cursor;
    FETCH NEXT FROM db_cursor INTO @Database;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Construir la consulta dinámica en cada base de datos
        SET @SQL = N'
            USE [' + @Database + '];
            INSERT INTO #UserRoles (DatabaseName, LoginName, UserName, DatabaseRoles, ServerRoles)
            SELECT 
                DB_NAME() AS DatabaseName,
                sp.name AS LoginName,
                dp.name AS UserName,
                ISNULL(STUFF(( 
                    SELECT '','' + dr.name 
                    FROM sys.database_role_members drm
                    JOIN sys.database_principals dr ON drm.role_principal_id = dr.principal_id
                    WHERE drm.member_principal_id = dp.principal_id
                    FOR XML PATH(''''), TYPE).value(''(./text())[1]'', ''NVARCHAR(MAX)''), 1, 2, ''''), ''N/A'') AS DatabaseRoles,
                ISNULL(STUFF(( 
                    SELECT '','' + sr.name 
                    FROM sys.server_role_members srm
                    JOIN sys.server_principals sr ON srm.role_principal_id = sr.principal_id
                    WHERE srm.member_principal_id = sp.principal_id
                    FOR XML PATH(''''), TYPE).value(''(./text())[1]'', ''NVARCHAR(MAX)''), 1, 2, ''''), ''N/A'') AS ServerRoles
            FROM sys.database_principals dp
            INNER JOIN sys.server_principals sp ON dp.sid = sp.sid
            WHERE dp.type IN (''S'', ''U'')
            AND sp.name NOT IN (
                ''##MS_PolicyEventProcessingLogin##'',
                ''##MS_PolicyTsqlExecutionLogin##'',
                ''NT AUTHORITY\NETWORK SERVICE'',
                ''NT AUTHORITY\SYSTEM'',
                ''NT Service\MSSQLSERVER'',
                ''NT SERVICE\SQLSERVERAGENT'',
                ''NT SERVICE\SQLTELEMETRY'',
                ''NT SERVICE\SQLWriter'',
                ''NT SERVICE\Winmgmt''
            );';

        EXEC sp_executesql @SQL;

        FETCH NEXT FROM db_cursor INTO @Database;
    END;

    CLOSE db_cursor;
    DEALLOCATE db_cursor;

    -- Mostrar los resultados
    SELECT * FROM #UserRoles;

    -- Eliminar la tabla temporal
    DROP TABLE #UserRoles;
END;
GO

