-- Функции и хранимые процедуры складского учёта.
-- Совместимо с MS SQL Server 2005 (без MERGE, THROW, DECLARE с инициализацией).

USE WarehouseDB;
GO

IF OBJECT_ID(N'dbo.fn_UserRole', N'FN') IS NOT NULL DROP FUNCTION dbo.fn_UserRole;
GO
CREATE FUNCTION dbo.fn_UserRole (@UserId int)
RETURNS varchar(20)
AS
BEGIN
  DECLARE @Code varchar(20);
  SELECT @Code = r.Code
  FROM dbo.Users u
  JOIN dbo.Roles r ON r.Id = u.RoleId
  WHERE u.Id = @UserId AND u.IsActive = 1;
  RETURN @Code;
END
GO

IF OBJECT_ID(N'dbo.usp_User_SetPassword', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_User_SetPassword;
GO
CREATE PROCEDURE dbo.usp_User_SetPassword
  @UserId   int,
  @Password nvarchar(100)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Salt nvarchar(32);
  SET @Salt = LEFT(REPLACE(CONVERT(nvarchar(36), NEWID()), N'-', N''), 32);
  UPDATE dbo.Users
  SET PasswordSalt = @Salt,
      PasswordHash = HASHBYTES('SHA1', @Salt + @Password)
  WHERE Id = @UserId;
END
GO

IF OBJECT_ID(N'dbo.usp_User_Login', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_User_Login;
GO
CREATE PROCEDURE dbo.usp_User_Login
  @Login    nvarchar(50),
  @Password nvarchar(100)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT u.Id, u.Login, u.FullName, r.Code AS RoleCode, r.Name AS RoleName
  FROM dbo.Users u
  JOIN dbo.Roles r ON r.Id = u.RoleId
  WHERE u.Login = @Login
    AND u.IsActive = 1
    AND u.PasswordHash = HASHBYTES('SHA1', u.PasswordSalt + @Password);
END
GO

IF OBJECT_ID(N'dbo.usp_Document_Create', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Document_Create;
GO
CREATE PROCEDURE dbo.usp_Document_Create
  @DocType        varchar(10),
  @DocDate        datetime,
  @SrcWarehouseId int,
  @DstWarehouseId int,
  @Comment        nvarchar(255),
  @UserId         int
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Role varchar(20), @Id int, @Prefix nvarchar(4);

  SET @Role = dbo.fn_UserRole(@UserId);
  IF @Role IS NULL OR @Role NOT IN ('ADMIN', 'STOREKEEPER')
  BEGIN
    RAISERROR(N'Недостаточно прав для создания документа.', 16, 1);
    RETURN;
  END

  SET @Prefix = CASE @DocType
                  WHEN 'IN'        THEN N'ПР'
                  WHEN 'OUT'       THEN N'РС'
                  WHEN 'MOVE_CELL' THEN N'ПЯ'
                  WHEN 'MOVE_WH'   THEN N'ПС'
                END;

  INSERT INTO dbo.Documents (DocType, DocDate, SrcWarehouseId, DstWarehouseId, Comment, CreatedBy)
  VALUES (@DocType, @DocDate, @SrcWarehouseId, @DstWarehouseId, @Comment, @UserId);

  SET @Id = SCOPE_IDENTITY();

  UPDATE dbo.Documents
  SET DocNumber = @Prefix + N'-' + RIGHT(N'000000' + CAST(@Id AS nvarchar(10)), 6)
  WHERE Id = @Id;

  SELECT Id, DocNumber FROM dbo.Documents WHERE Id = @Id;
END
GO

-- Проверяет, что пользователь может редактировать документ, а документ - черновик.
-- Блокирует строку документа до конца транзакции, чтобы его не провели параллельно.
-- Вызывается только внутри транзакции.
IF OBJECT_ID(N'dbo.usp_Document_LockDraft', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Document_LockDraft;
GO
CREATE PROCEDURE dbo.usp_Document_LockDraft
  @DocumentId int,
  @UserId     int,
  @Msg        nvarchar(400) OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Role varchar(20), @Status varchar(10);
  SET @Msg = NULL;

  SET @Role = dbo.fn_UserRole(@UserId);
  IF @Role IS NULL OR @Role NOT IN ('ADMIN', 'STOREKEEPER')
  BEGIN
    SET @Msg = N'Недостаточно прав для изменения документа.';
    RETURN;
  END

  SELECT @Status = Status
  FROM dbo.Documents WITH (UPDLOCK, HOLDLOCK)
  WHERE Id = @DocumentId;

  IF @Status IS NULL
    SET @Msg = N'Документ не найден.';
  ELSE IF @Status <> 'DRAFT'
    SET @Msg = N'Проведённый документ изменять нельзя.';
END
GO

IF OBJECT_ID(N'dbo.usp_Document_Update', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Document_Update;
GO
CREATE PROCEDURE dbo.usp_Document_Update
  @DocumentId     int,
  @DocDate        datetime,
  @SrcWarehouseId int,
  @DstWarehouseId int,
  @Comment        nvarchar(255),
  @UserId         int
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  DECLARE @Msg nvarchar(400);

  BEGIN TRAN;

  EXEC dbo.usp_Document_LockDraft @DocumentId, @UserId, @Msg OUTPUT;
  IF @Msg IS NOT NULL
  BEGIN
    ROLLBACK TRAN;
    RAISERROR(N'%s', 16, 1, @Msg);
    RETURN;
  END

  UPDATE dbo.Documents
  SET DocDate = @DocDate,
      SrcWarehouseId = @SrcWarehouseId,
      DstWarehouseId = @DstWarehouseId,
      Comment = @Comment
  WHERE Id = @DocumentId;

  COMMIT TRAN;
END
GO

IF OBJECT_ID(N'dbo.usp_DocumentLine_Add', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_DocumentLine_Add;
GO
CREATE PROCEDURE dbo.usp_DocumentLine_Add
  @DocumentId int,
  @MaterialId int,
  @Qty        decimal(18,3),
  @SrcCellId  int,
  @DstCellId  int,
  @UserId     int
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  DECLARE @Msg nvarchar(400);

  BEGIN TRAN;

  EXEC dbo.usp_Document_LockDraft @DocumentId, @UserId, @Msg OUTPUT;
  IF @Msg IS NULL AND (@Qty IS NULL OR @Qty <= 0)
    SET @Msg = N'Количество должно быть больше нуля.';
  IF @Msg IS NOT NULL
  BEGIN
    ROLLBACK TRAN;
    RAISERROR(N'%s', 16, 1, @Msg);
    RETURN;
  END

  INSERT INTO dbo.DocumentLines (DocumentId, MaterialId, Qty, SrcCellId, DstCellId)
  VALUES (@DocumentId, @MaterialId, @Qty, @SrcCellId, @DstCellId);

  COMMIT TRAN;
END
GO

IF OBJECT_ID(N'dbo.usp_DocumentLine_Delete', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_DocumentLine_Delete;
GO
CREATE PROCEDURE dbo.usp_DocumentLine_Delete
  @LineId int,
  @UserId int
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  DECLARE @DocumentId int, @Msg nvarchar(400);

  SELECT @DocumentId = DocumentId FROM dbo.DocumentLines WHERE Id = @LineId;
  IF @DocumentId IS NULL
  BEGIN
    RAISERROR(N'Строка документа не найдена.', 16, 1);
    RETURN;
  END

  BEGIN TRAN;

  EXEC dbo.usp_Document_LockDraft @DocumentId, @UserId, @Msg OUTPUT;
  IF @Msg IS NOT NULL
  BEGIN
    ROLLBACK TRAN;
    RAISERROR(N'%s', 16, 1, @Msg);
    RETURN;
  END

  DELETE FROM dbo.DocumentLines WHERE Id = @LineId AND DocumentId = @DocumentId;

  COMMIT TRAN;
END
GO

-- Применяет движения документа к остаткам. @Reverse = 1 - обратная проводка.
-- При нехватке остатка возвращает текст ошибки в @Msg и ничего не меняет.
-- Вызывается только внутри транзакции.
IF OBJECT_ID(N'dbo.usp_Stock_Apply', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Stock_Apply;
GO
CREATE PROCEDURE dbo.usp_Stock_Apply
  @DocumentId int,
  @Reverse    bit,
  @Msg        nvarchar(400) OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  SET @Msg = NULL;

  DECLARE @Out TABLE (CellId int NOT NULL, MaterialId int NOT NULL, Qty decimal(18,3) NOT NULL,
                      PRIMARY KEY (CellId, MaterialId));
  DECLARE @In  TABLE (CellId int NOT NULL, MaterialId int NOT NULL, Qty decimal(18,3) NOT NULL,
                      PRIMARY KEY (CellId, MaterialId));

  INSERT INTO @Out (CellId, MaterialId, Qty)
  SELECT x.CellId, x.MaterialId, SUM(x.Qty)
  FROM (SELECT CASE WHEN @Reverse = 0 THEN SrcCellId ELSE DstCellId END AS CellId, MaterialId, Qty
        FROM dbo.DocumentLines
        WHERE DocumentId = @DocumentId) x
  WHERE x.CellId IS NOT NULL
  GROUP BY x.CellId, x.MaterialId;

  INSERT INTO @In (CellId, MaterialId, Qty)
  SELECT x.CellId, x.MaterialId, SUM(x.Qty)
  FROM (SELECT CASE WHEN @Reverse = 0 THEN DstCellId ELSE SrcCellId END AS CellId, MaterialId, Qty
        FROM dbo.DocumentLines
        WHERE DocumentId = @DocumentId) x
  WHERE x.CellId IS NOT NULL
  GROUP BY x.CellId, x.MaterialId;

  SELECT TOP 1
    @Msg = N'Недостаточно материала "' + m.Name + N'" в ячейке ' + c.Code
         + N' (склад "' + w.Name + N'"): требуется ' + CONVERT(nvarchar(30), o.Qty)
         + N', в наличии ' + CONVERT(nvarchar(30), ISNULL(b.Qty, 0)) + N'.'
  FROM @Out o
  JOIN dbo.Materials m  ON m.Id = o.MaterialId
  JOIN dbo.Cells c      ON c.Id = o.CellId
  JOIN dbo.Warehouses w ON w.Id = c.WarehouseId
  LEFT JOIN dbo.StockBalances b WITH (UPDLOCK, HOLDLOCK)
    ON b.CellId = o.CellId AND b.MaterialId = o.MaterialId
  WHERE ISNULL(b.Qty, 0) < o.Qty;

  IF @Msg IS NOT NULL RETURN;

  UPDATE b SET Qty = b.Qty - o.Qty
  FROM dbo.StockBalances b
  JOIN @Out o ON o.CellId = b.CellId AND o.MaterialId = b.MaterialId;

  UPDATE b SET Qty = b.Qty + i.Qty
  FROM dbo.StockBalances b WITH (UPDLOCK, HOLDLOCK)
  JOIN @In i ON i.CellId = b.CellId AND i.MaterialId = b.MaterialId;

  INSERT INTO dbo.StockBalances (CellId, MaterialId, Qty)
  SELECT i.CellId, i.MaterialId, i.Qty
  FROM @In i
  WHERE NOT EXISTS (SELECT 1 FROM dbo.StockBalances b
                    WHERE b.CellId = i.CellId AND b.MaterialId = i.MaterialId);

  DELETE b
  FROM dbo.StockBalances b
  JOIN @Out o ON o.CellId = b.CellId AND o.MaterialId = b.MaterialId
  WHERE b.Qty = 0;
END
GO

IF OBJECT_ID(N'dbo.usp_Document_Post', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Document_Post;
GO
CREATE PROCEDURE dbo.usp_Document_Post
  @DocumentId int,
  @UserId     int
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;

  DECLARE @Role varchar(20), @DocType varchar(10), @Status varchar(10),
          @Src int, @Dst int, @Msg nvarchar(400);

  SET @Role = dbo.fn_UserRole(@UserId);
  IF @Role IS NULL OR @Role NOT IN ('ADMIN', 'STOREKEEPER')
  BEGIN
    RAISERROR(N'Недостаточно прав для проведения документа.', 16, 1);
    RETURN;
  END

  BEGIN TRAN;

  SELECT @DocType = DocType, @Status = Status,
         @Src = SrcWarehouseId, @Dst = DstWarehouseId
  FROM dbo.Documents WITH (UPDLOCK, HOLDLOCK)
  WHERE Id = @DocumentId;

  IF @DocType IS NULL
    SET @Msg = N'Документ не найден.';
  ELSE IF @Status <> 'DRAFT'
    SET @Msg = N'Документ уже проведён.';
  ELSE IF NOT EXISTS (SELECT 1 FROM dbo.DocumentLines WHERE DocumentId = @DocumentId)
    SET @Msg = N'В документе нет строк.';
  ELSE IF @DocType = 'IN' AND @Dst IS NULL
    SET @Msg = N'Не указан склад-получатель.';
  ELSE IF @DocType = 'OUT' AND @Src IS NULL
    SET @Msg = N'Не указан склад-отправитель.';
  ELSE IF @DocType = 'MOVE_CELL' AND (@Src IS NULL OR @Dst IS NULL OR @Src <> @Dst)
    SET @Msg = N'Для перемещения между ячейками должен быть указан один склад.';
  ELSE IF @DocType = 'MOVE_WH' AND (@Src IS NULL OR @Dst IS NULL OR @Src = @Dst)
    SET @Msg = N'Для перемещения между складами укажите два разных склада.';
  ELSE IF EXISTS (
    SELECT 1
    FROM dbo.DocumentLines l
    LEFT JOIN dbo.Cells sc ON sc.Id = l.SrcCellId
    LEFT JOIN dbo.Cells dc ON dc.Id = l.DstCellId
    WHERE l.DocumentId = @DocumentId
      AND (   (@DocType IN ('OUT', 'MOVE_CELL', 'MOVE_WH') AND (sc.Id IS NULL OR sc.WarehouseId <> @Src))
           OR (@DocType IN ('IN', 'MOVE_CELL', 'MOVE_WH') AND (dc.Id IS NULL OR dc.WarehouseId <> @Dst))
           OR (@DocType = 'IN'  AND l.SrcCellId IS NOT NULL)
           OR (@DocType = 'OUT' AND l.DstCellId IS NOT NULL)
           OR (@DocType = 'MOVE_CELL' AND l.SrcCellId = l.DstCellId)))
    SET @Msg = N'Строки документа содержат неверные ячейки: ячейка не заполнена, '
             + N'относится к другому складу или совпадает с ячейкой-получателем.';

  IF @Msg IS NULL
    EXEC dbo.usp_Stock_Apply @DocumentId, 0, @Msg OUTPUT;

  IF @Msg IS NOT NULL
  BEGIN
    ROLLBACK TRAN;
    RAISERROR(N'%s', 16, 1, @Msg);
    RETURN;
  END

  UPDATE dbo.Documents
  SET Status = 'POSTED', PostedBy = @UserId, PostedAt = GETDATE()
  WHERE Id = @DocumentId;

  COMMIT TRAN;
END
GO

IF OBJECT_ID(N'dbo.usp_Document_Unpost', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Document_Unpost;
GO
CREATE PROCEDURE dbo.usp_Document_Unpost
  @DocumentId int,
  @UserId     int
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;

  DECLARE @Status varchar(10), @Msg nvarchar(400);

  IF ISNULL(dbo.fn_UserRole(@UserId), '') <> 'ADMIN'
  BEGIN
    RAISERROR(N'Отменить проведение может только администратор.', 16, 1);
    RETURN;
  END

  BEGIN TRAN;

  SELECT @Status = Status
  FROM dbo.Documents WITH (UPDLOCK, HOLDLOCK)
  WHERE Id = @DocumentId;

  IF @Status IS NULL
    SET @Msg = N'Документ не найден.';
  ELSE IF @Status <> 'POSTED'
    SET @Msg = N'Документ не проведён.';

  IF @Msg IS NULL
    EXEC dbo.usp_Stock_Apply @DocumentId, 1, @Msg OUTPUT;

  IF @Msg IS NOT NULL
  BEGIN
    ROLLBACK TRAN;
    RAISERROR(N'%s', 16, 1, @Msg);
    RETURN;
  END

  UPDATE dbo.Documents
  SET Status = 'DRAFT', PostedBy = NULL, PostedAt = NULL
  WHERE Id = @DocumentId;

  COMMIT TRAN;
END
GO
