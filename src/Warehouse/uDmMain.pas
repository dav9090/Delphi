unit uDmMain;

interface

uses
  SysUtils, Classes, DB, ADODB, IniFiles, Forms, Dialogs, Windows;

type
  TDmMain = class(TDataModule)
    Connection: TADOConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
    FUserId: Integer;
    FUserLogin: string;
    FUserName: string;
    FRoleCode: string;
    function BuildConnectionString: string;
    function IniPath: string;
  public
    property UserId: Integer read FUserId;
    property UserLogin: string read FUserLogin;
    property UserName: string read FUserName;
    property RoleCode: string read FRoleCode;
    function IsAdmin: Boolean;
    function IsStorekeeper: Boolean;
    function CanEditRefs: Boolean;
    function CanEditDocs: Boolean;
    function CanUnpost: Boolean;
    procedure SetSession(AUserId: Integer; const ALogin, AName, ARole: string);
    procedure ClearSession;
    class function DocTypeCaption(const Code: string): string;
    class function StatusCaption(const Code: string): string;
    class function SetFieldCaption(DS: TDataSet; const FieldName, Caption: string): Boolean;
    class function SetFieldWidth(DS: TDataSet; const FieldName: string; Width: Integer): Boolean;
    class procedure SetupField(DS: TDataSet; const FieldName, Caption: string; Width: Integer);
  end;

var
  DmMain: TDmMain;

implementation

{$R *.dfm}

function TDmMain.IniPath: string;
var
  Candidates: array[0..3] of string;
  I: Integer;
begin
  Candidates[0] := ExtractFilePath(Application.ExeName) + 'Warehouse.ini';
  Candidates[1] := ExtractFilePath(Application.ExeName) + '..\Warehouse.ini';
  Candidates[2] := ExtractFilePath(ParamStr(0)) + 'Warehouse.ini';
  Candidates[3] := ExtractFilePath(ParamStr(0)) + '..\src\Warehouse\Warehouse.ini';
  Result := Candidates[0];
  for I := 0 to High(Candidates) do
    if FileExists(Candidates[I]) then
    begin
      Result := ExpandFileName(Candidates[I]);
      Exit;
    end;
end;

function TDmMain.BuildConnectionString: string;
var
  Ini: TIniFile;
  Server, Database, Auth, User, Pass: string;
begin
  Ini := TIniFile.Create(IniPath);
  try
    Server := Ini.ReadString('Database', 'Server', '.');
    Database := Ini.ReadString('Database', 'Database', 'WarehouseDB');
    Auth := UpperCase(Ini.ReadString('Database', 'Auth', 'Windows'));
    User := Ini.ReadString('Database', 'User', '');
    Pass := Ini.ReadString('Database', 'Password', '');
  finally
    Ini.Free;
  end;
  Result :=
    'Provider=SQLOLEDB.1;Persist Security Info=False;' +
    'Data Source=' + Server + ';' +
    'Initial Catalog=' + Database + ';';
  if Auth = 'SQL' then
    Result := Result + 'User ID=' + User + ';Password=' + Pass + ';'
  else
    Result := Result + 'Integrated Security=SSPI;';
end;

procedure TDmMain.DataModuleCreate(Sender: TObject);
begin
  ClearSession;
  Connection.LoginPrompt := False;
  Connection.ConnectionString := BuildConnectionString;
  try
    Connection.Connected := True;
  except
    on E: Exception do
    begin
      MessageBox(0,
        PChar('Не удалось подключиться к SQL Server.'#13#10 +
              E.Message + #13#10 +
              'Проверьте SQL Server и файл Warehouse.ini рядом с программой.'),
        'Складской учёт', MB_OK or MB_ICONERROR);
      Halt(1);
    end;
  end;
end;

procedure TDmMain.SetSession(AUserId: Integer; const ALogin, AName, ARole: string);
begin
  FUserId := AUserId;
  FUserLogin := ALogin;
  FUserName := AName;
  FRoleCode := ARole;
end;

procedure TDmMain.ClearSession;
begin
  FUserId := 0;
  FUserLogin := '';
  FUserName := '';
  FRoleCode := '';
end;

function TDmMain.IsAdmin: Boolean;
begin
  Result := FRoleCode = 'ADMIN';
end;

function TDmMain.IsStorekeeper: Boolean;
begin
  Result := FRoleCode = 'STOREKEEPER';
end;

function TDmMain.CanEditRefs: Boolean;
begin
  Result := IsAdmin or IsStorekeeper;
end;

function TDmMain.CanEditDocs: Boolean;
begin
  Result := IsAdmin or IsStorekeeper;
end;

function TDmMain.CanUnpost: Boolean;
begin
  Result := IsAdmin;
end;

class function TDmMain.DocTypeCaption(const Code: string): string;
begin
  if Code = 'IN' then Result := 'Приход'
  else if Code = 'OUT' then Result := 'Расход'
  else if Code = 'MOVE_CELL' then Result := 'Перемещение по ячейкам'
  else if Code = 'MOVE_WH' then Result := 'Перемещение между складами'
  else Result := Code;
end;

class function TDmMain.StatusCaption(const Code: string): string;
begin
  if Code = 'DRAFT' then Result := 'Черновик'
  else if Code = 'POSTED' then Result := 'Проведён'
  else Result := Code;
end;

class function TDmMain.SetFieldCaption(DS: TDataSet; const FieldName, Caption: string): Boolean;
var
  F: TField;
begin
  F := DS.FindField(FieldName);
  Result := Assigned(F);
  if Result then
    F.DisplayLabel := Caption;
end;

class function TDmMain.SetFieldWidth(DS: TDataSet; const FieldName: string; Width: Integer): Boolean;
var
  F: TField;
begin
  F := DS.FindField(FieldName);
  Result := Assigned(F);
  if Result then
    F.DisplayWidth := Width;
end;

class procedure TDmMain.SetupField(DS: TDataSet; const FieldName, Caption: string; Width: Integer);
begin
  SetFieldCaption(DS, FieldName, Caption);
  SetFieldWidth(DS, FieldName, Width);
end;

end.
