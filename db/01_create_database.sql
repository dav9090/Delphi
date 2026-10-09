-- Создание базы данных складского учёта.
-- Совместимо с MS SQL Server 2005 и новее.

IF DB_ID(N'WarehouseDB') IS NULL
BEGIN
  CREATE DATABASE WarehouseDB COLLATE Cyrillic_General_CI_AS;
END
GO
