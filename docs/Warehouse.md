# Складской учёт

Delphi 7 (ADO / SQLOLEDB) + MS SQL Server ≥ 2005, БД `WarehouseDB` (collation `Cyrillic_General_CI_AS`).

Автор: Дряхлов А. В., Курганстальмост.

Данные — в SQL Server. Клиент: `Warehouse.exe` + `Warehouse.ini` рядом с ним.

## Стек

| | |
|--|--|
| Клиент | `src/Warehouse/Warehouse.dpr` (Delphi 7 IDE) |
| SQL | `db/01`…`04` |
| Deploy | `tools/Deploy-Database.ps1` (`sqlcmd -f 65001`) |
| Сборка | `tools/Build-Project.ps1 -Project .\src\Warehouse\Warehouse.dpr` |

## Deploy / build

```powershell
.\tools\Deploy-Database.ps1
.\tools\Deploy-Database.ps1 -Server .\SQLEXPRESS
.\tools\Deploy-Database.ps1 -Server HOST -User sa -Password ***
.\tools\Build-Project.ps1 -Project .\src\Warehouse\Warehouse.dpr -Rebuild
```

Либо SSMS: `db\01` → `02` → `03` → `04` по порядку. Повторный deploy идемпотентен.

## Warehouse.ini

```ini
[Database]
Server=.
Database=WarehouseDB
Auth=Windows
User=
Password=
```

`Auth=SQL` — заполнить `User`/`Password`. Образец: `src/Warehouse/Warehouse.ini.example`.

## Роли (seed)

| Login | Password | Role |
|-------|----------|------|
| admin | admin | ADMIN — всё, включая Unpost и пользователей |
| sklad | sklad | STOREKEEPER — справочники + документы |
| viewer | viewer | VIEWER — чтение + отчёт |

## Предметная область

Справочники: склады, ячейки, ед. изм., материалы, пользователи.

Документы (`DRAFT`/`POSTED`): `IN`, `OUT`, `MOVE_CELL`, `MOVE_WH`. Проведение — `usp_Document_Post` (остаток ≥ 0); отмена — `usp_Document_Unpost` (ADMIN).

Отчёт: экран с ячейками; печать — агрегат склад / материал / количество.

## Целостность данных

- Все изменения документов идут через процедуры: `usp_Document_Create`, `usp_Document_Update`, `usp_DocumentLine_Add`, `usp_DocumentLine_Delete`, `usp_Document_Post`, `usp_Document_Unpost`. Они проверяют роль пользователя и то, что документ — черновик, и блокируют документ на время изменения.
- Триггер `TR_DocumentLines_DraftOnly` запрещает менять строки проведённого документа даже прямым SQL, поэтому отмена проведения всегда возвращает остатки точно.
- Остаток не может стать отрицательным: `CHECK (Qty >= 0)` в `StockBalances` плюс проверка в `usp_Stock_Apply`.

## Ограничения и безопасность

- Архитектура двухзвенная: все клиенты подключаются к БД одной учётной записью (Windows или SQL из `Warehouse.ini`). Роли ADMIN / STOREKEEPER / VIEWER — роли приложения, а не SQL Server.
- Процедуры документов проверяют роль по `@UserId`, который передаёт клиент. Справочники редактируются напрямую через таблицы, права на них проверяет только клиент. Пользователь с прямым доступом к БД (SSMS) эти проверки обходит. Для промышленной эксплуатации нужны отдельные SQL-логины / роли БД с `GRANT EXECUTE` только на процедуры либо сервер приложений.
- Пароли хранятся как `SHA1(соль + пароль)`. SQL Server 2005–2008 R2 не поддерживает `HASHBYTES('SHA2_256')` (появился в 2012), поэтому выбран SHA1 с солью; при переходе на новую версию сервера алгоритм стоит заменить.
- Пароли из seed (`admin/admin` и др.) — только для демонстрации, после развёртывания их нужно сменить.
