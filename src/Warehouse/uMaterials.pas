unit uMaterials;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, ADODB, Grids, DBGrids, DBCtrls, Mask,
  uDmMain;

type
  TFormMaterials = class(TForm)
    PanelTop: TPanel;
    btnRefresh: TButton;
    btnAdd: TButton;
    btnDelete: TButton;
    btnSave: TButton;
    Grid: TDBGrid;
    ds: TDataSource;
    qry: TADOQuery;
    PanelEdit: TPanel;
    lblCode: TLabel;
    lblName: TLabel;
    lblUnit: TLabel;
    edtCode: TDBEdit;
    edtName: TDBEdit;
    lcbUnit: TDBLookupComboBox;
    dsUnits: TDataSource;
    qryUnits: TADOQuery;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    procedure OpenData;
  public
  end;

implementation

{$R *.dfm}

procedure TFormMaterials.FormCreate(Sender: TObject);
begin
  Font.Charset := RUSSIAN_CHARSET;
  Font.Name := 'Tahoma';
  qry.Connection := DmMain.Connection;
  qryUnits.Connection := DmMain.Connection;
end;

procedure TFormMaterials.OpenData;
begin
  qryUnits.Close;
  qryUnits.SQL.Text := 'SELECT Id, Code, Name FROM dbo.Units ORDER BY Code';
  qryUnits.Open;
  qry.Close;
  qry.SQL.Text :=
    'SELECT Id, Code, Name, UnitId FROM dbo.Materials ORDER BY Name';
  qry.Open;
  TDmMain.SetupField(qry, 'Id', 'Код', 6);
  TDmMain.SetupField(qry, 'Code', 'Артикул', 12);
  TDmMain.SetupField(qry, 'Name', 'Наименование', 28);
  TDmMain.SetupField(qry, 'UnitId', 'Ед. изм.', 8);
  btnAdd.Enabled := DmMain.CanEditRefs;
  btnDelete.Enabled := DmMain.CanEditRefs;
  btnSave.Enabled := DmMain.CanEditRefs;
end;

procedure TFormMaterials.FormShow(Sender: TObject);
begin
  OpenData;
end;

procedure TFormMaterials.btnRefreshClick(Sender: TObject);
begin
  OpenData;
end;

procedure TFormMaterials.btnAddClick(Sender: TObject);
begin
  qry.Append;
  if not qryUnits.IsEmpty then
    qry.FieldByName('UnitId').AsInteger := qryUnits.FieldByName('Id').AsInteger;
end;

procedure TFormMaterials.btnDeleteClick(Sender: TObject);
begin
  if qry.IsEmpty then Exit;
  if MessageDlg('Удалить материал?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  try
    qry.Delete;
    qry.UpdateBatch;
  except
    on E: Exception do
    begin
      qry.CancelBatch;
      ShowMessage('Не удалось удалить: ' + E.Message);
    end;
  end;
end;

procedure TFormMaterials.btnSaveClick(Sender: TObject);
begin
  try
    if qry.State in [dsEdit, dsInsert] then qry.Post;
    qry.UpdateBatch;
    ShowMessage('Сохранено.');
  except
    on E: Exception do ShowMessage('Не удалось сохранить: ' + E.Message);
  end;
end;


procedure TFormMaterials.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
