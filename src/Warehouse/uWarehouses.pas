unit uWarehouses;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, ADODB, Grids, DBGrids, DBCtrls, Mask,
  uDmMain;

type
  TFormWarehouses = class(TForm)
    PanelTop: TPanel;
    btnRefresh: TButton;
    btnAdd: TButton;
    btnDelete: TButton;
    btnSave: TButton;
    Grid: TDBGrid;
    ds: TDataSource;
    qry: TADOQuery;
    PanelEdit: TPanel;
    lblName: TLabel;
    lblAddress: TLabel;
    edtName: TDBEdit;
    edtAddress: TDBEdit;
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

procedure TFormWarehouses.FormCreate(Sender: TObject);
begin
  Font.Charset := RUSSIAN_CHARSET;
  Font.Name := 'Tahoma';
  qry.Connection := DmMain.Connection;
end;

procedure TFormWarehouses.OpenData;
begin
  qry.Close;
  qry.SQL.Text :=
    'SELECT Id, Name, Address FROM dbo.Warehouses ORDER BY Name';
  qry.Open;
  TDmMain.SetupField(qry, 'Id', 'Код', 6);
  TDmMain.SetupField(qry, 'Name', 'Наименование', 28);
  TDmMain.SetupField(qry, 'Address', 'Адрес', 24);
  btnAdd.Enabled := DmMain.CanEditRefs;
  btnDelete.Enabled := DmMain.CanEditRefs;
  btnSave.Enabled := DmMain.CanEditRefs;
end;

procedure TFormWarehouses.FormShow(Sender: TObject);
begin
  OpenData;
end;

procedure TFormWarehouses.btnRefreshClick(Sender: TObject);
begin
  OpenData;
end;

procedure TFormWarehouses.btnAddClick(Sender: TObject);
begin
  qry.Append;
  edtName.SetFocus;
end;

procedure TFormWarehouses.btnDeleteClick(Sender: TObject);
begin
  if qry.IsEmpty then Exit;
  if MessageDlg('Удалить выбранный склад?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  try
    qry.Delete;
    qry.UpdateBatch;
  except
    on E: Exception do
    begin
      qry.CancelBatch;
      ShowMessage('Нельзя удалить: ' + E.Message);
    end;
  end;
end;

procedure TFormWarehouses.btnSaveClick(Sender: TObject);
begin
  try
    if qry.State in [dsEdit, dsInsert] then
      qry.Post;
    qry.UpdateBatch;
    ShowMessage('Сохранено.');
  except
    on E: Exception do ShowMessage('Не удалось сохранить: ' + E.Message);
  end;
end;


procedure TFormWarehouses.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
