unit uUsers;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, ADODB, Grids, DBGrids, DBCtrls, Mask,
  uDmMain;

type
  TFormUsers = class(TForm)
    PanelTop: TPanel;
    btnRefresh: TButton;
    btnAdd: TButton;
    btnSave: TButton;
    btnSetPassword: TButton;
    Grid: TDBGrid;
    ds: TDataSource;
    qry: TADOQuery;
    PanelEdit: TPanel;
    lblLogin: TLabel;
    lblName: TLabel;
    lblRole: TLabel;
    edtLogin: TDBEdit;
    edtName: TDBEdit;
    lcbRole: TDBLookupComboBox;
    chkActive: TDBCheckBox;
    dsRoles: TDataSource;
    qryRoles: TADOQuery;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnSetPasswordClick(Sender: TObject);
  private
    procedure OpenData;
  public
  end;

implementation

{$R *.dfm}

procedure TFormUsers.FormCreate(Sender: TObject);
begin
  Font.Charset := RUSSIAN_CHARSET;
  Font.Name := 'Tahoma';
  qry.Connection := DmMain.Connection;
  qryRoles.Connection := DmMain.Connection;
end;

procedure TFormUsers.OpenData;
begin
  qryRoles.Close;
  qryRoles.SQL.Text := 'SELECT Id, Code, Name FROM dbo.Roles ORDER BY Id';
  qryRoles.Open;
  qry.Close;
  qry.SQL.Text :=
    'SELECT Id, Login, FullName, RoleId, IsActive FROM dbo.Users ORDER BY Login';
  qry.Open;
  TDmMain.SetupField(qry, 'Id', 'Код', 6);
  TDmMain.SetupField(qry, 'Login', 'Логин', 12);
  TDmMain.SetupField(qry, 'FullName', 'ФИО', 24);
  TDmMain.SetupField(qry, 'RoleId', 'Роль', 6);
  TDmMain.SetupField(qry, 'IsActive', 'Активен', 8);
end;

procedure TFormUsers.FormShow(Sender: TObject);
begin
  OpenData;
end;

procedure TFormUsers.btnRefreshClick(Sender: TObject);
begin
  OpenData;
end;

procedure TFormUsers.btnAddClick(Sender: TObject);
begin
  qry.Append;
  qry.FieldByName('IsActive').AsBoolean := True;
  if not qryRoles.IsEmpty then
    qry.FieldByName('RoleId').AsInteger := qryRoles.FieldByName('Id').AsInteger;
end;

procedure TFormUsers.btnSaveClick(Sender: TObject);
begin
  try
    if qry.State in [dsEdit, dsInsert] then qry.Post;
    qry.UpdateBatch;
    ShowMessage('Сохранено. Для нового пользователя задайте пароль.');
  except
    on E: Exception do ShowMessage('Не удалось сохранить: ' + E.Message);
  end;
end;

procedure TFormUsers.btnSetPasswordClick(Sender: TObject);
var
  Pwd: string;
  SP: TADOStoredProc;
begin
  if qry.IsEmpty then Exit;
  try
    if qry.State in [dsEdit, dsInsert] then qry.Post;
    qry.UpdateBatch;
  except
    on E: Exception do
    begin
      ShowMessage('Не удалось сохранить: ' + E.Message);
      Exit;
    end;
  end;
  Pwd := InputBox('Пароль', 'Новый пароль для ' + qry.FieldByName('Login').AsString, '');
  if Pwd = '' then Exit;
  SP := TADOStoredProc.Create(nil);
  try
    SP.Connection := DmMain.Connection;
    SP.ProcedureName := 'dbo.usp_User_SetPassword';
    SP.Parameters.Refresh;
    SP.Parameters.ParamByName('@UserId').Value := qry.FieldByName('Id').AsInteger;
    SP.Parameters.ParamByName('@Password').Value := Pwd;
    SP.ExecProc;
    ShowMessage('Пароль установлен.');
  finally
    SP.Free;
  end;
end;


procedure TFormUsers.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
