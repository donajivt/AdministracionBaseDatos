-- CREANDO UN LOGIN DE SQL
-- Este login da acceso al servidor
use master 
go

-- Login con autenticación sql
create login Donajivt with password = '123456'
go

-- Crear login con autenticación de Windows
create user 'donajivt\vania' for Windows
go

-- Crear un usuario asociado al login y mapearlo a una base de datos
use paquitabd
go

create user Donajivt for login Donajivt with default_schema = informatica
go
-- crear el schema despues de crear el usuario
create schema informatica
authorization Donajivt
go

-- Permisos de manera individual
-- permiso de crear tablas
grant create table to Donajivt
go
--permiso de consultar todas las tablas
grant select to Donajivt
go
--permiso de eliminar todas las tablas
grant delete to Donajivt
go
--permiso de insertar todas las tablas
grant insert to Donajivt
go
-- permisos para insertar, consultar y eliminar
grant insert, select, delete to Donajivt
go
-- lo niega uno de los permiso DENY
deny delete to Donajivt
go
revoke create table to Donajivt
go
-- permiso especifico a una tabla
grant select on tabla to Donajivt
go

-- Roles
--Rol de consultar toda la base de datos
exec sp_addrolemember 'db_datareader', Donajivt