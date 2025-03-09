-- Backup Completo
backup database northwind
to disk = 'C:\backup\backupNorthwind.bak' -- archivo donde se guardan los backups
with
name = 'Backupcompleto_03_03_2025', -- nombre del backup
description = 'Backup completo de la base de datos de northwind'
go

-- Backup Diferencial
backup database northwind
to disk = 'C:\backup\backupNorthwind.bak' -- archivo donde se guardan los backups
with
name = 'BackupDiferencial1_04_03_2025', -- nombre del backup
description = 'Backup diferencial 1 de la base de datos de northwind',
differential
go

-- Backup de log de transacciones
backup log northwind -- colocar log
to disk = 'C:\backup\backupNorthwind.bak'
with
name = 'BackupLog1', -- nombre del backup
description = 'Backup de Log de transacciones de la base de datos de northwind'
go

-- Backup de Solo Copia
backup database northwind
to disk = 'C:\backup\backupNorthwind.bak'
with
copy_only,
name = 'BackupSoloCopia', -- nombre del backup
description = 'Backup de solo copia de la base de datos de northwind'
go

-- Backup de un fileGroup o Backup Parciales
backup database northwind
filegroup = 'Primary'
to disk = 'C:\backup\backupNorthwind.bak'
with
name = 'BackupParcialFilenamePrimary', -- nombre del backup
description = 'Backup parcial del filename Primary de la base de datos de northwind'
go

-- Backup de la cola de log
backup log northwind
to disk = 'C:\backup\backupNorthwind.bak'
with
recovery,
name = 'BackupColaLog1', -- nombre del backup
description = 'Backup de cola de log de la base de datos de northwind'
go
-- se necesita estar abajo la base de datos, ya que este tronando o dañada.