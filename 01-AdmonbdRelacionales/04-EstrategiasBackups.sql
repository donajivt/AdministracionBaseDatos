-- Estrategias de Backups
-- 1. Backups Completos (FULL)
-- 2. Completos + diferenciales
-- 3. Completos + diferenciales + log de transacciones
use Northwind
go
/* Plan de estrategias de backups
 Backup Completo */
backup database northwind
to disk = 'C:\backup\backupNorthwind.bak' -- archivo donde se guardan los backups
with
name = 'BackupCompleto_03_03_2025',
description = 'Backup completo de la base de datos de northwind'
go
-- usamos la bd
use Northwind
go
-- insertamos un nuevo registro
insert into Customers (CustomerID, CompanyName, Country)
values ('ABCD3', 'Pepsi', 'USA'),
	   ('ABCD4', 'Coca', 'Colombia')
go
-- verificar que se agreguen
select * from Customers
where CustomerID in ('ABCD3', 'ABCD4')
go

-- Backup de log de transacciones
backup log northwind -- colocar log
to disk = 'C:\backup\backupNorthwind.bak'
with
name = 'BackupLog1', -- nombre del backup
description = 'Backup de Log de transacciones de la base de datos de northwind 03/03/2025'
go

insert into Customers (CustomerID, CompanyName, Country)
values ('ABCD5', 'Cruz Azul', 'Mexico'),
	   ('ABCD6', 'Super Aguilas', 'Jupiter')
go
select * from Customers
where CustomerID in ('ABCD5', 'ABCD6')
go

-- Backup de log de transacciones
backup log northwind -- colocar log
to disk = 'C:\backup\backupNorthwind.bak'
with
name = 'BackupLog2', -- nombre del backup
description = 'Backup2 de Log de transacciones de la base de datos de northwind 04/03/2025'
go

insert into Customers (CustomerID, CompanyName, Country)
values ('ABCD7', 'Cemex', 'Nigeria'),
	   ('ABCD8', 'GoodYear', 'USA')
go

-- Backup Diferencial
backup database northwind
to disk = 'C:\backup\backupNorthwind.bak' -- archivo donde se guardan los backups
with
name = 'BackupDiferencial1', -- nombre del backup
description = 'Backup diferencial 1 de la base de datos de northwind',
differential
go

-- eliminar los datos para notar las diferencias
delete Customers where CustomerID in ('ABCD7','ABCD8')
go

insert into Customers (CustomerID, CompanyName, Country)
values ('ABCD9', 'LALA', 'Colombia'),
	   ('ABC10', 'LELE', 'Argentina')
go


-- Backup de log de transacciones
backup log northwind -- colocar log
to disk = 'C:\backup\backupNorthwind.bak'
with
name = 'BackupLog3', -- nombre del backup
description = 'Backup3 de Log de transacciones de la base de datos de northwind 04/03/2025'
go

-- usar master
use master
go

-- eliminar la base de datos
drop database northwind
go

-- Restaurar backup completo y de logs
restore database northwind
from disk = 'C:\backup\backupNorthwind.bak'
with file = 1,
norecovery
go

restore log northwind
from disk = 'C:\backup\backupNorthwind.bak'
with file = 2,
norecovery
go

restore database northwind
from disk = 'C:\backup\backupNorthwind.bak'
with file = 3,
norecovery
go

restore log northwind
from disk = 'C:\backup\backupNorthwind.bak'
with file = 4,
recovery
go


-- Revisar el archivo .bak
restore headeronly
from disk = 'C:\backup\backupNorthwind.bak'
go
