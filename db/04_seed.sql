-- Начальные данные: роли, пользователи, единицы измерения и демо-справочники.
-- Пароли демо-пользователей совпадают с логинами; смените их после первого входа.

USE WarehouseDB;
GO

SET NOCOUNT ON;

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE Code = 'ADMIN')
  INSERT INTO dbo.Roles (Code, Name) VALUES ('ADMIN', N'Администратор');
IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE Code = 'STOREKEEPER')
  INSERT INTO dbo.Roles (Code, Name) VALUES ('STOREKEEPER', N'Кладовщик');
IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE Code = 'VIEWER')
  INSERT INTO dbo.Roles (Code, Name) VALUES ('VIEWER', N'Просмотр');
GO

DECLARE @UserId int;

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Login = N'admin')
BEGIN
  INSERT INTO dbo.Users (Login, FullName, RoleId)
  SELECT N'admin', N'Администратор системы', Id FROM dbo.Roles WHERE Code = 'ADMIN';
  SET @UserId = SCOPE_IDENTITY();
  EXEC dbo.usp_User_SetPassword @UserId, N'admin';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Login = N'sklad')
BEGIN
  INSERT INTO dbo.Users (Login, FullName, RoleId)
  SELECT N'sklad', N'Кладовщик', Id FROM dbo.Roles WHERE Code = 'STOREKEEPER';
  SET @UserId = SCOPE_IDENTITY();
  EXEC dbo.usp_User_SetPassword @UserId, N'sklad';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Login = N'viewer')
BEGIN
  INSERT INTO dbo.Users (Login, FullName, RoleId)
  SELECT N'viewer', N'Наблюдатель', Id FROM dbo.Roles WHERE Code = 'VIEWER';
  SET @UserId = SCOPE_IDENTITY();
  EXEC dbo.usp_User_SetPassword @UserId, N'viewer';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Units)
BEGIN
  INSERT INTO dbo.Units (Code, Name) VALUES (N'кг', N'Килограмм');
  INSERT INTO dbo.Units (Code, Name) VALUES (N'т', N'Тонна');
  INSERT INTO dbo.Units (Code, Name) VALUES (N'шт', N'Штука');
  INSERT INTO dbo.Units (Code, Name) VALUES (N'л', N'Литр');
  INSERT INTO dbo.Units (Code, Name) VALUES (N'м', N'Метр');
  INSERT INTO dbo.Units (Code, Name) VALUES (N'м2', N'Квадратный метр');
  INSERT INTO dbo.Units (Code, Name) VALUES (N'упак', N'Упаковка');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Warehouses)
BEGIN
  DECLARE @W1 int, @W2 int;

  INSERT INTO dbo.Warehouses (Name, Address) VALUES (N'Основной склад', N'Корпус 1');
  SET @W1 = SCOPE_IDENTITY();
  INSERT INTO dbo.Warehouses (Name, Address) VALUES (N'Склад №2', N'Корпус 3');
  SET @W2 = SCOPE_IDENTITY();

  INSERT INTO dbo.Cells (WarehouseId, Code, Name) VALUES (@W1, N'A-01', N'Стеллаж A, ячейка 1');
  INSERT INTO dbo.Cells (WarehouseId, Code, Name) VALUES (@W1, N'A-02', N'Стеллаж A, ячейка 2');
  INSERT INTO dbo.Cells (WarehouseId, Code, Name) VALUES (@W1, N'B-01', N'Стеллаж B, ячейка 1');
  INSERT INTO dbo.Cells (WarehouseId, Code, Name) VALUES (@W2, N'C-01', N'Стеллаж C, ячейка 1');
  INSERT INTO dbo.Cells (WarehouseId, Code, Name) VALUES (@W2, N'C-02', N'Стеллаж C, ячейка 2');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Materials)
BEGIN
  INSERT INTO dbo.Materials (Code, Name, UnitId)
  SELECT N'M-001', N'Гвозди строительные 100 мм', Id FROM dbo.Units WHERE Code = N'кг';
  INSERT INTO dbo.Materials (Code, Name, UnitId)
  SELECT N'M-002', N'Цемент М500', Id FROM dbo.Units WHERE Code = N'т';
  INSERT INTO dbo.Materials (Code, Name, UnitId)
  SELECT N'M-003', N'Перчатки рабочие', Id FROM dbo.Units WHERE Code = N'шт';
  INSERT INTO dbo.Materials (Code, Name, UnitId)
  SELECT N'M-004', N'Краска белая', Id FROM dbo.Units WHERE Code = N'л';
  INSERT INTO dbo.Materials (Code, Name, UnitId)
  SELECT N'M-005', N'Кабель ВВГ 3x2.5', Id FROM dbo.Units WHERE Code = N'м';
END
GO

-- Демо-приход на основной склад, чтобы отчёт по остаткам был не пустым.
IF NOT EXISTS (SELECT 1 FROM dbo.Documents)
BEGIN
  DECLARE @Admin int, @Wh int, @DocId int;
  DECLARE @Doc TABLE (Id int, DocNumber nvarchar(20));

  SELECT @Admin = Id FROM dbo.Users WHERE Login = N'admin';
  SELECT @Wh = Id FROM dbo.Warehouses WHERE Name = N'Основной склад';

  INSERT INTO @Doc (Id, DocNumber)
  EXEC dbo.usp_Document_Create 'IN', '20260101', NULL, @Wh, N'Начальные остатки', @Admin;
  SELECT @DocId = Id FROM @Doc;

  INSERT INTO dbo.DocumentLines (DocumentId, MaterialId, Qty, DstCellId)
  SELECT @DocId, m.Id, 250, c.Id
  FROM dbo.Materials m, dbo.Cells c
  WHERE m.Code = N'M-001' AND c.WarehouseId = @Wh AND c.Code = N'A-01';

  INSERT INTO dbo.DocumentLines (DocumentId, MaterialId, Qty, DstCellId)
  SELECT @DocId, m.Id, 12.5, c.Id
  FROM dbo.Materials m, dbo.Cells c
  WHERE m.Code = N'M-002' AND c.WarehouseId = @Wh AND c.Code = N'B-01';

  INSERT INTO dbo.DocumentLines (DocumentId, MaterialId, Qty, DstCellId)
  SELECT @DocId, m.Id, 400, c.Id
  FROM dbo.Materials m, dbo.Cells c
  WHERE m.Code = N'M-003' AND c.WarehouseId = @Wh AND c.Code = N'A-02';

  EXEC dbo.usp_Document_Post @DocId, @Admin;
END
GO
