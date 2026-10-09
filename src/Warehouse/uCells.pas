unit uCells;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, ADODB, Grids, DBGrids, DBCtrls, Mask,
  uDmMain;

type
  TFormCells = class(TForm)
    PanelTop: TPanel;
    btnRefresh: TButton;
    btnAdd: TButton;
    btnDelete: TButton;
    btnSave: TButton;
    lblWh: TLabel;
    cbWarehouse: TComboBox;
    Grid: TDBGrid;
    ds: TDataSource;
    qry: TADOQuery;
    PanelEdit: TPanel;
    lblCode: TLabel;
    lblName: TLabel;
    edtCode: TDBEdit;
    edtName: TDBEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure cbWarehouseChange(Sender: TObject);
  private
    FWhIds: array of Integer;
    procedure LoadWarehouses;
    procedure OpenData;
    function CurrentWarehouseId: Integer;
  public
  end;

implementation

{$R *.dfm}

procedure TFormCells.FormCreate(Sender: TObject);
begin
  Font.Charset := RUSSIAN_CHARSET;
  Font.Name := 'Tahoma';
  qry.Connection := DmMain.Connection;
end;

procedure TFormCells.LoadWarehouses;
var
  Q: TADOQuery;
begin
  cbWarehouse.Items.Clear;
  SetLength(FWhIds, 0);
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := DmMain.Connection;
    Q.SQL.Text := 'SELECT Id, Name FROM dbo.Warehouses ORDER BY Name';
    Q.Open;
    while not Q.Eof do
    begin
      SetLength(FWhIds, Length(FWhIds) + 1);
      FWhIds[High(FWhIds)] := Q.FieldByName('Id').AsInteger;
      cbWarehouse.Items.Add(Q.FieldByName('Name').AsString);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  if cbWarehouse.Items.Count > 0 then
    cbWarehouse.ItemIndex := 0;
end;

function TFormCells.CurrentWarehouseId: Integer;
begin
  Result := 0;
  if (cbWarehouse.ItemIndex >= 0) and (cbWarehouse.ItemIndex <= High(FWhIds)) then
    Result := FWhIds[cbWarehouse.ItemIndex];
end;

procedure TFormCells.OpenData;
var
  Wid: Integer;
begin
  Wid := CurrentWarehouseId;
  qry.Close;
  qry.SQL.Text :=
    'SELECT Id, WarehouseId, Code, Name FROM dbo.Cells' +
    ' WHERE WarehouseId = :Wid' +
    ' ORDER BY Code';
  qry.Parameters.ParamByName('Wid').Value := Wid;
  qry.Open;
  TDmMain.SetupField(qry, 'Id', 'Код', 6);
  TDmMain.SetupField(qry, 'WarehouseId', 'Склад', 6);
  TDmMain.SetupField(qry, 'Code', 'Код ячейки', 12);
  TDmMain.SetupField(qry, 'Name', 'Наименование', 24);
  if Assigned(qry.FindField('WarehouseId')) then
    qry.FieldByName('WarehouseId').Visible := False;
  btnAdd.Enabled := DmMain.CanEditRefs and (Wid > 0);
  btnDelete.Enabled := DmMain.CanEditRefs;
  btnSave.Enabled := DmMain.CanEditRefs;
end;

procedure TFormCells.FormShow(Sender: TObject);
begin
  LoadWarehouses;
  OpenData;
end;

procedure TFormCells.cbWarehouseChange(Sender: TObject);
begin
  OpenData;
end;

procedure TFormCells.btnRefreshClick(Sender: TObject);
begin
  OpenData;
end;

procedure TFormCells.btnAddClick(Sender: TObject);
begin
  if CurrentWarehouseId = 0 then Exit;
  qry.Append;
  qry.FieldByName('WarehouseId').AsInteger := CurrentWarehouseId;
end;

procedure TFormCells.btnDeleteClick(Sender: TObject);
begin
  if qry.IsEmpty then Exit;
  if MessageDlg('Удалить ячейку?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
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

procedure TFormCells.btnSaveClick(Sender: TObject);
begin
  try
    if qry.State in [dsEdit, dsInsert] then
    begin
      qry.FieldByName('WarehouseId').AsInteger := CurrentWarehouseId;
      qry.Post;
    end;
    qry.UpdateBatch;
    ShowMessage('Сохранено.');
  except
    on E: Exception do ShowMessage('Не удалось сохранить: ' + E.Message);
  end;
end;


procedure TFormCells.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
