unit uLogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ADODB, DB, uDmMain;

type
  TFormLogin = class(TForm)
    lblLogin: TLabel;
    lblPassword: TLabel;
    edtLogin: TEdit;
    edtPassword: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    pnlTop: TPanel;
    lblTitle: TLabel;
    lblOrg: TLabel;
    lblAuthor: TLabel;
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
  public
    class function Execute: Boolean;
  end;

implementation

{$R *.dfm}

class function TFormLogin.Execute: Boolean;
var
  F: TFormLogin;
begin
  F := TFormLogin.Create(Application);
  try
    Result := F.ShowModal = mrOk;
  finally
    F.Free;
  end;
end;

procedure TFormLogin.FormCreate(Sender: TObject);
begin
  Font.Charset := RUSSIAN_CHARSET;
  Font.Name := 'Tahoma';
  edtPassword.PasswordChar := '*';
  lblOrg.Caption := 'Курганстальмост';
  lblAuthor.Caption := 'Автор: Дряхлов Александр Васильевич';
end;

procedure TFormLogin.btnOkClick(Sender: TObject);
var
  SP: TADOStoredProc;
begin
  if Trim(edtLogin.Text) = '' then
  begin
    ShowMessage('Введите логин.');
    edtLogin.SetFocus;
    Exit;
  end;
  SP := TADOStoredProc.Create(nil);
  try
    SP.Connection := DmMain.Connection;
    SP.ProcedureName := 'dbo.usp_User_Login';
    SP.Parameters.Refresh;
    SP.Parameters.ParamByName('@Login').Value := Trim(edtLogin.Text);
    SP.Parameters.ParamByName('@Password').Value := edtPassword.Text;
    SP.Open;
    if SP.IsEmpty then
    begin
      ShowMessage('Неверный логин или пароль.');
      edtPassword.SetFocus;
      Exit;
    end;
    DmMain.SetSession(
      SP.FieldByName('Id').AsInteger,
      SP.FieldByName('Login').AsString,
      SP.FieldByName('FullName').AsString,
      SP.FieldByName('RoleCode').AsString);
    ModalResult := mrOk;
  finally
    SP.Free;
  end;
end;

procedure TFormLogin.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
