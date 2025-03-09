# CREACIÓN BASE DE DATOS

```sql
create database paquitabd
on primary(
	Name = paquitabdData, 
	filename = 'C:\DataNueva\paquitadb.mdf',
	size = 50MB, -- El tamaño minimo es 512kb, el predeterminado es 1MB
	filegrowth = 25%, -- El default es 10%
	maxsize = 400MB 
)
log on (
	Name = paquitabdLog, 
	filename = 'C:\LogNuevo\paquitadb.ldf',
	size = 25MB,
	filegrowth = 25%
)
go

-- Crear un archivo adicional
alter database paquitabd
add file
(
	Name = 'PaquitaDataNDF',
	filename = 'C:\DataNueva\paquitadb2.ndf',
	size = 25MB,
	maxsize = 500MB,
	filegrowth = 10MB
) to filegroup[primary];

--Creacion de un FileGroup Adicional
Alter DATABASE paquitabd
ADD FILEGROUP SECUNDARIO
GO

-- CREACION DE UN ARCHIVO ASOCIADO AL FILEGROUP
ALTER DATABASE paquitabd
ADD FILE (
   NAME= 'paquitabd_parte1',
   FILENAME= 'C:\DataNueva\paquitabd_SECUNDARIO.ndft'
)TO FILEGROUP SECUNDARIO
go

--Crear una tabla en el grupo de archivos (filegroups) Secundario
use paquitabd
go
create table ratadedospatas(
	id int not null identity(1,1),
	nombre nvarchar(100) not null,
	constraint pk_ratadedospatas
	primary key (id),
	constraint unico_nombre
	unique (nombre)
) on SECUNDARIO
go

create table animalrastrero(
	id int not null identity(1,1),
	nombre nvarchar(100) not null,
	constraint pk_animalrastrero
	primary key (id),
	constraint unico_nombre2
	unique (nombre)
)
go

-- Modificar el Grupo Primario
use master
go

alter database paquitabd
modify filegroup [SECUNDARIO] default

use paquitabd
go

create table comparadocontigo(
	id int not null identity (1,1),
	nombredelanimal nvarchar(100) not null,
	defectos nvarchar(max) not null,
	constraint pk_comparadocontigo
	primary key (id),
	constraint unico_nombre3
	unique (nombredelanimal)
)
go
```