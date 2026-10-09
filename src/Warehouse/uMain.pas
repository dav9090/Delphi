unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, StdCtrls, ComCtrls, uDmMain, uLogin,
  uWarehouses, uCells, uUnits, uMaterials, uUsers, uDocList, uStockReport;

type
  TFormMain = class(TForm)
    MainMenu: TMainMenu;
    miRefs: TMenuItem;
    miWarehouses: TMenuItem;
    miCells: TMenuItem;
    miUnits: TMenuItem;
    miMaterials: TMenuItem;
    miUsers: TMenuItem;
    miDocs: TMenuItem;
    miDocJournal: TMenuItem;
    miReports: TMenuItem;
    miStockReport: TMenuItem;
    miHelp: TMenuItem;
    miAbout: TMenuItem;
    miExit: TMenuItem;
    StatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miWarehousesClick(Sender: TObject);
    procedure miCellsClick(Sender: TObject);
    procedure miUnitsClick(Sender: TObject);
    procedure miMaterialsClick(Sender: TObject);
    procedure miUsersClick(Sender: TObject);
    procedure miDocJournalClick(Sender: TObject);
    procedure miStockReportClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
  private
    procedure ApplyRoleMenu;
    procedure ShowChild(FormClass: TFormClass);
  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  Font.Charset := RUSSIAN_CHARSET;
  Font.Name := 'Tahoma';
  Caption := 'Складской учёт - Курганстальмост';
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  if not TFormLogin.Execute then
  begin
    Application.ShowMainForm := False;
    Close;
    Exit;
  end;
  ApplyRoleMenu;
  StatusBar.SimpleText :=
    'Пользователь: ' + DmMain.UserName +
    ' (' + DmMain.UserLogin + ') | Роль: ' + DmMain.RoleCode +
    ' | Автор: Дряхлов Александр Васильевич | Курганстальмост';
end;

procedure TFormMain.ApplyRoleMenu;
begin
  miUsers.Visible := DmMain.IsAdmin;
  miRefs.Enabled := True;
  miDocs.Enabled := True;
  miReports.Enabled := True;
end;

procedure TFormMain.ShowChild(FormClass: TFormClass);
var
  F: TForm;
  I: Integer;
begin
  for I := 0 to MDIChildCount - 1 do
    if MDIChildren[I].ClassType = FormClass then
    begin
      MDIChildren[I].BringToFront;
      Exit;
    end;
  F := FormClass.Create(Self);
  F.Show;
end;

procedure TFormMain.miWarehousesClick(Sender: TObject);
begin
  ShowChild(TFormWarehouses);
end;

procedure TFormMain.miCellsClick(Sender: TObject);
begin
  ShowChild(TFormCells);
end;

procedure TFormMain.miUnitsClick(Sender: TObject);
begin
  ShowChild(TFormUnits);
end;

procedure TFormMain.miMaterialsClick(Sender: TObject);
begin
  ShowChild(TFormMaterials);
end;

procedure TFormMain.miUsersClick(Sender: TObject);
begin
  if DmMain.IsAdmin then
    ShowChild(TFormUsers);
end;

procedure TFormMain.miDocJournalClick(Sender: TObject);
begin
  ShowChild(TFormDocList);
end;

procedure TFormMain.miStockReportClick(Sender: TObject);
begin
  ShowChild(TFormStockReport);
end;

procedure TFormMain.miAboutClick(Sender: TObject);
begin
  ShowMessage(
    'Складской учёт материалов'#13#10 +
    'Организация: Курганстальмост'#13#10 +
    'Автор: Дряхлов Александр Васильевич');
end;

procedure TFormMain.miExitClick(Sender: TObject);
begin
  Close;
end;

end.
