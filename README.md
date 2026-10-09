# Delphi 7

Win32 / Borland Delphi 7. Приложение — складской учёт: [docs/Warehouse.md](docs/Warehouse.md).

| | |
|--|--|
| Клиент | `src/Warehouse/Warehouse.dpr` |
| SQL | `db/` |
| Docs | `docs/Warehouse.md` |
| Скрипты | `tools/` |

## Quick start

Нужны SQL Server >= 2005 и Delphi 7. Из корня репозитория:

```powershell
.\tools\Deploy-Database.ps1
.\tools\Build-Project.ps1 -Project .\src\Warehouse\Warehouse.dpr -Rebuild
.\src\Warehouse\bin\Warehouse.exe
```

В IDE: File → Open → `src\Warehouse\Warehouse.dpr`.

`Warehouse.ini` копируется в `bin\` при сборке. Seed: admin/admin, sklad/sklad, viewer/viewer.

Готовый `src\Warehouse\bin\Warehouse.exe` намеренно лежит в репозитории, чтобы приложение можно было запустить без установленного Delphi 7: достаточно развернуть БД и поправить `bin\Warehouse.ini`. Ограничения и вопросы безопасности описаны в [docs/Warehouse.md](docs/Warehouse.md#ограничения-и-безопасность).

## Окружение

```powershell
.\tools\Setup-Environment.ps1
.\tools\Find-Delphi7.ps1
```

Релизы — только `dcc32`. Опционально: `-InstallHelpers`; `Install-ScienceEdition.ps1`; `Install-Sql2008R2.ps1`.
