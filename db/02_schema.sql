-- Таблицы складского учёта. Скрипт можно запускать повторно:
-- существующие таблицы не пересоздаются.

USE WarehouseDB;
GO

IF OBJECT_ID(N'dbo.Roles', N'U') IS NULL
CREATE TABLE dbo.Roles (
  Id   int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Roles PRIMARY KEY,
  Code varchar(20)   NOT NULL CONSTRAINT UQ_Roles_Code UNIQUE,
  Name nvarchar(100) NOT NULL
);
GO

IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
CREATE TABLE dbo.Users (
  Id           int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Users PRIMARY KEY,
  Login        nvarchar(50)  NOT NULL CONSTRAINT UQ_Users_Login UNIQUE,
  FullName     nvarchar(150) NOT NULL,
  RoleId       int           NOT NULL CONSTRAINT FK_Users_Roles REFERENCES dbo.Roles(Id),
  PasswordSalt nvarchar(32)  NULL,
  PasswordHash varbinary(20) NULL,
  IsActive     bit           NOT NULL CONSTRAINT DF_Users_IsActive DEFAULT (1)
);
GO

IF OBJECT_ID(N'dbo.Warehouses', N'U') IS NULL
CREATE TABLE dbo.Warehouses (
  Id      int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Warehouses PRIMARY KEY,
  Name    nvarchar(100) NOT NULL CONSTRAINT UQ_Warehouses_Name UNIQUE,
  Address nvarchar(255) NULL
);
GO

IF OBJECT_ID(N'dbo.Cells', N'U') IS NULL
CREATE TABLE dbo.Cells (
  Id          int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Cells PRIMARY KEY,
  WarehouseId int           NOT NULL CONSTRAINT FK_Cells_Warehouses REFERENCES dbo.Warehouses(Id),
  Code        nvarchar(30)  NOT NULL,
  Name        nvarchar(100) NULL,
  CONSTRAINT UQ_Cells_Warehouse_Code UNIQUE (WarehouseId, Code)
);
GO

IF OBJECT_ID(N'dbo.Units', N'U') IS NULL
CREATE TABLE dbo.Units (
  Id   int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Units PRIMARY KEY,
  Code nvarchar(10) NOT NULL CONSTRAINT UQ_Units_Code UNIQUE,
  Name nvarchar(50) NOT NULL
);
GO

IF OBJECT_ID(N'dbo.Materials', N'U') IS NULL
CREATE TABLE dbo.Materials (
  Id     int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Materials PRIMARY KEY,
  Code   nvarchar(30)  NULL,
  Name   nvarchar(150) NOT NULL CONSTRAINT UQ_Materials_Name UNIQUE,
  UnitId int           NOT NULL CONSTRAINT FK_Materials_Units REFERENCES dbo.Units(Id)
);
GO

-- DocType: IN - приход, OUT - расход, MOVE_CELL - перемещение между ячейками
-- одного склада, MOVE_WH - перемещение между складами.
IF OBJECT_ID(N'dbo.Documents', N'U') IS NULL
CREATE TABLE dbo.Documents (
  Id             int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Documents PRIMARY KEY,
  DocType        varchar(10)   NOT NULL
    CONSTRAINT CK_Documents_DocType CHECK (DocType IN ('IN', 'OUT', 'MOVE_CELL', 'MOVE_WH')),
  DocNumber      nvarchar(20)  NULL,
  DocDate        datetime      NOT NULL,
  Status         varchar(10)   NOT NULL CONSTRAINT DF_Documents_Status DEFAULT ('DRAFT')
    CONSTRAINT CK_Documents_Status CHECK (Status IN ('DRAFT', 'POSTED')),
  SrcWarehouseId int           NULL CONSTRAINT FK_Documents_SrcWarehouse REFERENCES dbo.Warehouses(Id),
  DstWarehouseId int           NULL CONSTRAINT FK_Documents_DstWarehouse REFERENCES dbo.Warehouses(Id),
  Comment        nvarchar(255) NULL,
  CreatedBy      int           NOT NULL CONSTRAINT FK_Documents_CreatedBy REFERENCES dbo.Users(Id),
  CreatedAt      datetime      NOT NULL CONSTRAINT DF_Documents_CreatedAt DEFAULT (GETDATE()),
  PostedBy       int           NULL CONSTRAINT FK_Documents_PostedBy REFERENCES dbo.Users(Id),
  PostedAt       datetime      NULL
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Documents_DocDate')
  CREATE INDEX IX_Documents_DocDate ON dbo.Documents (DocDate);
GO

IF OBJECT_ID(N'dbo.DocumentLines', N'U') IS NULL
CREATE TABLE dbo.DocumentLines (
  Id         int IDENTITY(1,1) NOT NULL CONSTRAINT PK_DocumentLines PRIMARY KEY,
  DocumentId int            NOT NULL
    CONSTRAINT FK_DocumentLines_Documents REFERENCES dbo.Documents(Id) ON DELETE CASCADE,
  MaterialId int            NOT NULL CONSTRAINT FK_DocumentLines_Materials REFERENCES dbo.Materials(Id),
  Qty        decimal(18,3)  NOT NULL CONSTRAINT CK_DocumentLines_Qty CHECK (Qty > 0),
  SrcCellId  int            NULL CONSTRAINT FK_DocumentLines_SrcCell REFERENCES dbo.Cells(Id),
  DstCellId  int            NULL CONSTRAINT FK_DocumentLines_DstCell REFERENCES dbo.Cells(Id)
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DocumentLines_DocumentId')
  CREATE INDEX IX_DocumentLines_DocumentId ON dbo.DocumentLines (DocumentId);
GO

-- Строки проведённого документа менять нельзя: иначе отмена проведения
-- спишет не те количества и остатки разойдутся.
IF OBJECT_ID(N'dbo.TR_DocumentLines_DraftOnly', N'TR') IS NOT NULL
  DROP TRIGGER dbo.TR_DocumentLines_DraftOnly;
GO

CREATE TRIGGER dbo.TR_DocumentLines_DraftOnly
ON dbo.DocumentLines
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
  SET NOCOUNT ON;
  IF EXISTS (
    SELECT 1
    FROM (SELECT DocumentId FROM inserted
          UNION
          SELECT DocumentId FROM deleted) x
    JOIN dbo.Documents d ON d.Id = x.DocumentId
    WHERE d.Status <> 'DRAFT')
  BEGIN
    RAISERROR(N'Строки проведённого документа изменять нельзя.', 16, 1);
    ROLLBACK TRAN;
  END
END
GO

IF OBJECT_ID(N'dbo.StockBalances', N'U') IS NULL
CREATE TABLE dbo.StockBalances (
  CellId     int           NOT NULL CONSTRAINT FK_StockBalances_Cells REFERENCES dbo.Cells(Id),
  MaterialId int           NOT NULL CONSTRAINT FK_StockBalances_Materials REFERENCES dbo.Materials(Id),
  Qty        decimal(18,3) NOT NULL CONSTRAINT CK_StockBalances_Qty CHECK (Qty >= 0),
  CONSTRAINT PK_StockBalances PRIMARY KEY (CellId, MaterialId)
);
GO

IF OBJECT_ID(N'dbo.vw_StockByCell', N'V') IS NOT NULL
  DROP VIEW dbo.vw_StockByCell;
GO

CREATE VIEW dbo.vw_StockByCell
AS
SELECT w.Id   AS WarehouseId,
       w.Name AS WarehouseName,
       c.Id   AS CellId,
       c.Code AS CellCode,
       m.Id   AS MaterialId,
       m.Name AS MaterialName,
       u.Code AS UnitCode,
       b.Qty
FROM dbo.StockBalances b
JOIN dbo.Cells c      ON c.Id = b.CellId
JOIN dbo.Warehouses w ON w.Id = c.WarehouseId
JOIN dbo.Materials m  ON m.Id = b.MaterialId
JOIN dbo.Units u      ON u.Id = m.UnitId
WHERE b.Qty > 0;
GO

IF OBJECT_ID(N'dbo.vw_StockByWarehouse', N'V') IS NOT NULL
  DROP VIEW dbo.vw_StockByWarehouse;
GO

CREATE VIEW dbo.vw_StockByWarehouse
AS
SELECT WarehouseId, WarehouseName, MaterialId, MaterialName, UnitCode,
       SUM(Qty) AS Qty
FROM dbo.vw_StockByCell
GROUP BY WarehouseId, WarehouseName, MaterialId, MaterialName, UnitCode;
GO
