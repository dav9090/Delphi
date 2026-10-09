unit uDocEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, ADODB, Grids, DBGrids, Mask, ComCtrls,
  uDmMain;

type
  TFormDocEdit = class(TForm)
    PanelTop: TPanel;
    lblDocType: TLabel;
    lblNumber: TLabel;
    lblDate: TLabel;
    lblStatus: TLabel;
    lblSrcWh: TLabel;
    lblDstWh: TLabel;
    lblComment: TLabel;
    edtNumber: TEdit;
    edtDate: TEdit;
    edtStatus: TEdit;
    cbSrcWh: TComboBox;
    cbDstWh: TComboBox;
    edtComment: TEdit;
    btnSave: TButton;
    btnPost: TButton;
    btnClose: TButton;
    PanelLines: TPanel;
    btnAddLine: TButton;
    btnDelLine: TButton;
    Grid: TDBGrid;
    dsLines: TDataSource;
    qryLines: TADOQuery;
    PanelLineEdit: TPanel;
    lblMaterial: TLabel;
    lblQty: TLabel;
    lblSrcCell: TLabel;
    lblDstCell: TLabel;
    cbMaterial: TComboBox;
    edtQty: TEdit;
    cbSrcCell: TComboBox;
    cbDstCell: TComboBox;
    btnApplyLine: TButton;
    PanelStock: TPanel;
    lblStock: TLabel;
    GridStock: TDBGrid;
    qryStock: TADOQuery;
    dsStock: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnPostClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnAddLineClick(Sender: TObject);
    procedure btnDelLineClick(Sender: TObject);
    procedure btnApplyLineClick(Sender: TObject);
    procedure cbSrcWhChange(Sender: TObject);
    procedure cbDstWhChange(Sender: TObject);
    procedure GridStockDblClick(Sender: TObject);
  private
    FDocId: Integer;
    FDocType: string;
    FIsPosted: Boolean;
    FWhIds: array of Integer;
    FMatIds: array of Integer;
    FSrcCellIds: array of Integer;
    FDstCellIds: array of Integer;
    procedure LoadWarehouses;
    procedure LoadMaterials;
    procedure LoadSrcCells;
    procedure LoadDstCells;
    procedure LoadStockBalances;
    function SelectedId(Combo: TComboBox; const Ids: array of Integer): Integer;
    procedure SetIdIndex(Combo: TComboBox; const Ids: array of Integer; Id: Integer);
    procedure SetIdParam(SP: TADOStoredProc; const Name: string; Id: Integer);
    procedure ConfigureByType;
    procedure LoadHeader;
    procedure LoadLines;
    procedure ApplyReadOnly;
    function ValidateHeader: Boolean;
    function ValidateLine: Boolean;
    function CreateHeader: Boolean;
    function SaveHeader: Boolean;
    function NeedsSrcWh: Boolean;
    function NeedsDstWh: Boolean;
    function NeedsSrcCell: Boolean;
    function NeedsDstCell: Boolean;
    function ShowsStockPanel: Boolean;
    procedure SetupLineCaptions;
    procedure SetupStockCaptions;
    function EnsureDocumentSaved: Boolean;
    procedure SelectDefaultWarehouses;
  public
    class function CreateDocument(const DocType: string): Boolean;
    class function OpenDoc(DocId: Integer): Boolean;
  end;

implementation

{$R *.dfm}

class function TFormDocEdit.CreateDocument(const DocType: string): Boolean;
var
  F: TFormDocEdit;
begin
  F := TFormDocEdit.Create(Application);
  try
    F.FDocId := 0;
    F.FDocType := DocType;
    F.FIsPosted := False;
    F.ConfigureByType;
    F.LoadWarehouses;
    F.LoadMaterials;
    F.edtDate.Text := FormatDateTime('dd.mm.yyyy', Date);
    F.edtStatus.Text := TDmMain.StatusCaption('DRAFT');
    F.edtNumber.Text := '(новый)';
    F.SelectDefaultWarehouses;
    F.ApplyReadOnly;
    F.LoadStockBalances;
    Result := F.ShowModal = mrOk;
  finally
    F.Free;
  end;
end;

class function TFormDocEdit.OpenDoc(DocId: Integer): Boolean;
var
  F: TFormDocEdit;
begin
  F := TFormDocEdit.Create(Application);
  try
    F.FDocId := DocId;
    F.LoadWarehouses;
    F.LoadMaterials;
    F.LoadHeader;
    F.ConfigureByType;
    F.LoadLines;
    F.ApplyReadOnly;
    F.LoadStockBalances;
    Result := F.ShowModal = mrOk;
  finally
    F.Free;
  end;
end;

procedure TFormDocEdit.FormCreate(Sender: TObject);
begin
  Font.Charset := RUSSIAN_CHARSET;
  Font.Name := 'Tahoma';
  qryLines.Connection := DmMain.Connection;
  qryStock.Connection := DmMain.Connection;
end;

function TFormDocEdit.NeedsSrcWh: Boolean;
begin
  Result := (FDocType = 'OUT') or (FDocType = 'MOVE_CELL') or (FDocType = 'MOVE_WH');
end;

function TFormDocEdit.NeedsDstWh: Boolean;
begin
  Result := (FDocType = 'IN') or (FDocType = 'MOVE_CELL') or (FDocType = 'MOVE_WH');
end;

function TFormDocEdit.NeedsSrcCell: Boolean;
begin
  Result := (FDocType = 'OUT') or (FDocType = 'MOVE_CELL') or (FDocType = 'MOVE_WH');
end;

function TFormDocEdit.NeedsDstCell: Boolean;
begin
  Result := (FDocType = 'IN') or (FDocType = 'MOVE_CELL') or (FDocType = 'MOVE_WH');
end;

function TFormDocEdit.ShowsStockPanel: Boolean;
begin
  Result := NeedsSrcWh;
end;

procedure TFormDocEdit.LoadWarehouses;
var
  Q: TADOQuery;
begin
  cbSrcWh.Items.Clear;
  cbDstWh.Items.Clear;
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
      cbSrcWh.Items.Add(Q.FieldByName('Name').AsString);
      cbDstWh.Items.Add(Q.FieldByName('Name').AsString);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TFormDocEdit.LoadMaterials;
var
  Q: TADOQuery;
begin
  cbMaterial.Items.Clear;
  SetLength(FMatIds, 0);
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := DmMain.Connection;
    Q.SQL.Text := 'SELECT Id, Name FROM dbo.Materials ORDER BY Name';
    Q.Open;
    while not Q.Eof do
    begin
      SetLength(FMatIds, Length(FMatIds) + 1);
      FMatIds[High(FMatIds)] := Q.FieldByName('Id').AsInteger;
      cbMaterial.Items.Add(Q.FieldByName('Name').AsString);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TFormDocEdit.SelectedId(Combo: TComboBox; const Ids: array of Integer): Integer;
begin
  Result := 0;
  if (Combo.ItemIndex >= 0) and (Combo.ItemIndex <= High(Ids)) then
    Result := Ids[Combo.ItemIndex];
end;

procedure TFormDocEdit.SetIdIndex(Combo: TComboBox; const Ids: array of Integer; Id: Integer);
var
  I: Integer;
begin
  Combo.ItemIndex := -1;
  for I := 0 to High(Ids) do
    if Ids[I] = Id then
    begin
      Combo.ItemIndex := I;
      Break;
    end;
end;

procedure TFormDocEdit.SetIdParam(SP: TADOStoredProc; const Name: string; Id: Integer);
begin
  if Id = 0 then
    SP.Parameters.ParamByName(Name).Value := Null
  else
    SP.Parameters.ParamByName(Name).Value := Id;
end;

procedure TFormDocEdit.LoadSrcCells;
var
  Q: TADOQuery;
  Wid, KeepId: Integer;
begin
  KeepId := SelectedId(cbSrcCell, FSrcCellIds);
  cbSrcCell.Items.Clear;
  SetLength(FSrcCellIds, 0);
  Wid := SelectedId(cbSrcWh, FWhIds);
  if Wid = 0 then Exit;
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := DmMain.Connection;
    Q.SQL.Text :=
      'SELECT Id, Code FROM dbo.Cells WHERE WarehouseId = :Wid ORDER BY Code';
    Q.Parameters.ParamByName('Wid').Value := Wid;
    Q.Open;
    while not Q.Eof do
    begin
      SetLength(FSrcCellIds, Length(FSrcCellIds) + 1);
      FSrcCellIds[High(FSrcCellIds)] := Q.FieldByName('Id').AsInteger;
      cbSrcCell.Items.Add(Q.FieldByName('Code').AsString);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  if KeepId > 0 then
    SetIdIndex(cbSrcCell, FSrcCellIds, KeepId);
end;

procedure TFormDocEdit.LoadDstCells;
var
  Q: TADOQuery;
  Wid, KeepId: Integer;
begin
  KeepId := SelectedId(cbDstCell, FDstCellIds);
  cbDstCell.Items.Clear;
  SetLength(FDstCellIds, 0);
  Wid := SelectedId(cbDstWh, FWhIds);
  if (FDocType = 'MOVE_CELL') then
    Wid := SelectedId(cbSrcWh, FWhIds);
  if Wid = 0 then Exit;
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := DmMain.Connection;
    Q.SQL.Text :=
      'SELECT Id, Code FROM dbo.Cells WHERE WarehouseId = :Wid ORDER BY Code';
    Q.Parameters.ParamByName('Wid').Value := Wid;
    Q.Open;
    while not Q.Eof do
    begin
      SetLength(FDstCellIds, Length(FDstCellIds) + 1);
      FDstCellIds[High(FDstCellIds)] := Q.FieldByName('Id').AsInteger;
      cbDstCell.Items.Add(Q.FieldByName('Code').AsString);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  if KeepId > 0 then
    SetIdIndex(cbDstCell, FDstCellIds, KeepId);
end;

procedure TFormDocEdit.SetupStockCaptions;
begin
  if qryStock.Active then
  begin
    TDmMain.SetupField(qryStock, 'WarehouseName', 'Склад', 16);
    TDmMain.SetupField(qryStock, 'CellCode', 'Ячейка', 10);
    TDmMain.SetupField(qryStock, 'MaterialName', 'Материал', 28);
    TDmMain.SetupField(qryStock, 'UnitCode', 'Ед.', 6);
    TDmMain.SetupField(qryStock, 'Qty', 'Кол-во', 10);
    if Assigned(qryStock.FindField('WarehouseId')) then
      qryStock.FieldByName('WarehouseId').Visible := False;
    if Assigned(qryStock.FindField('MaterialId')) then
      qryStock.FieldByName('MaterialId').Visible := False;
    if Assigned(qryStock.FindField('CellId')) then
      qryStock.FieldByName('CellId').Visible := False;
  end;
end;

procedure TFormDocEdit.LoadStockBalances;
var
  Wid: Integer;
  SQL: string;
begin
  PanelStock.Visible := ShowsStockPanel;
  if not ShowsStockPanel then
  begin
    qryStock.Close;
    Exit;
  end;
  Wid := SelectedId(cbSrcWh, FWhIds);
  if Wid > 0 then
    lblStock.Caption := 'Остатки на складе-источнике (двойной щелчок — подставить в строку)'
  else
    lblStock.Caption := 'Остатки по складам (выберите склад-источник или щёлкните строку дважды)';
  SQL :=
    'SELECT WarehouseId, WarehouseName, CellId, CellCode, MaterialId, MaterialName, UnitCode, Qty' +
    ' FROM dbo.vw_StockByCell WHERE 1=1';
  if Wid > 0 then
    SQL := SQL + ' AND WarehouseId = :Wid';
  SQL := SQL + ' ORDER BY WarehouseName, MaterialName, CellCode';
  qryStock.Close;
  qryStock.SQL.Text := SQL;
  if Wid > 0 then
    qryStock.Parameters.ParamByName('Wid').Value := Wid;
  qryStock.Open;
  SetupStockCaptions;
end;

procedure TFormDocEdit.cbSrcWhChange(Sender: TObject);
begin
  LoadSrcCells;
  if FDocType = 'MOVE_CELL' then
  begin
    SetIdIndex(cbDstWh, FWhIds, SelectedId(cbSrcWh, FWhIds));
    LoadDstCells;
  end;
  LoadStockBalances;
end;

procedure TFormDocEdit.cbDstWhChange(Sender: TObject);
begin
  if FDocType <> 'MOVE_CELL' then
    LoadDstCells;
end;

procedure TFormDocEdit.GridStockDblClick(Sender: TObject);
var
  MatId, CellId, WhId: Integer;
begin
  if (not ShowsStockPanel) or qryStock.IsEmpty or FIsPosted then Exit;
  if not DmMain.CanEditDocs then Exit;
  MatId := qryStock.FieldByName('MaterialId').AsInteger;
  CellId := qryStock.FieldByName('CellId').AsInteger;
  WhId := qryStock.FieldByName('WarehouseId').AsInteger;
  if NeedsSrcWh and (WhId > 0) then
  begin
    SetIdIndex(cbSrcWh, FWhIds, WhId);
    LoadSrcCells;
    if FDocType = 'MOVE_CELL' then
    begin
      SetIdIndex(cbDstWh, FWhIds, WhId);
      LoadDstCells;
    end;
  end;
  SetIdIndex(cbMaterial, FMatIds, MatId);
  SetIdIndex(cbSrcCell, FSrcCellIds, CellId);
  edtQty.Text := qryStock.FieldByName('Qty').AsString;
  edtQty.SetFocus;
end;

procedure TFormDocEdit.ConfigureByType;
begin
  lblDocType.Caption := 'Тип: ' + TDmMain.DocTypeCaption(FDocType);
  cbSrcWh.Enabled := NeedsSrcWh;
  lblSrcWh.Enabled := NeedsSrcWh;
  cbDstWh.Enabled := NeedsDstWh and (FDocType <> 'MOVE_CELL');
  lblDstWh.Enabled := NeedsDstWh;
  cbSrcCell.Enabled := NeedsSrcCell;
  lblSrcCell.Enabled := NeedsSrcCell;
  cbDstCell.Enabled := NeedsDstCell;
  lblDstCell.Enabled := NeedsDstCell;
  PanelStock.Visible := ShowsStockPanel;
end;

procedure TFormDocEdit.LoadHeader;
var
  Q: TADOQuery;
begin
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := DmMain.Connection;
    Q.SQL.Text :=
      'SELECT DocType, DocNumber, DocDate, Status, SrcWarehouseId, DstWarehouseId, Comment' +
      ' FROM dbo.Documents WHERE Id = :Id';
    Q.Parameters.ParamByName('Id').Value := FDocId;
    Q.Open;
    if Q.IsEmpty then
      raise Exception.Create('Документ не найден.');
    FDocType := Q.FieldByName('DocType').AsString;
    FIsPosted := SameText(Q.FieldByName('Status').AsString, 'POSTED');
    edtNumber.Text := Q.FieldByName('DocNumber').AsString;
    edtDate.Text := FormatDateTime('dd.mm.yyyy', Q.FieldByName('DocDate').AsDateTime);
    edtStatus.Text := TDmMain.StatusCaption(Q.FieldByName('Status').AsString);
    edtComment.Text := Q.FieldByName('Comment').AsString;
    SetIdIndex(cbSrcWh, FWhIds, Q.FieldByName('SrcWarehouseId').AsInteger);
    SetIdIndex(cbDstWh, FWhIds, Q.FieldByName('DstWarehouseId').AsInteger);
    LoadSrcCells;
    LoadDstCells;
  finally
    Q.Free;
  end;
end;

procedure TFormDocEdit.LoadLines;
begin
  qryLines.Close;
  qryLines.SQL.Text :=
    'SELECT l.Id, l.DocumentId, l.MaterialId, l.Qty, l.SrcCellId, l.DstCellId,' +
    ' m.Name AS MaterialName, sc.Code AS SrcCellCode, dc.Code AS DstCellCode' +
    ' FROM dbo.DocumentLines l' +
    ' JOIN dbo.Materials m ON m.Id = l.MaterialId' +
    ' LEFT JOIN dbo.Cells sc ON sc.Id = l.SrcCellId' +
    ' LEFT JOIN dbo.Cells dc ON dc.Id = l.DstCellId' +
    ' WHERE l.DocumentId = :DocId' +
    ' ORDER BY l.Id';
  qryLines.Parameters.ParamByName('DocId').Value := FDocId;
  qryLines.Open;
  SetupLineCaptions;
end;

procedure TFormDocEdit.SetupLineCaptions;
begin
  if qryLines.IsEmpty and (qryLines.Fields.Count = 0) then Exit;
  TDmMain.SetupField(qryLines, 'Id', 'Код', 6);
  TDmMain.SetupField(qryLines, 'MaterialName', 'Материал', 28);
  TDmMain.SetupField(qryLines, 'Qty', 'Количество', 10);
  TDmMain.SetupField(qryLines, 'SrcCellCode', 'Ячейка-источник', 12);
  TDmMain.SetupField(qryLines, 'DstCellCode', 'Ячейка-получатель', 12);
  if Assigned(qryLines.FindField('DocumentId')) then qryLines.FieldByName('DocumentId').Visible := False;
  if Assigned(qryLines.FindField('MaterialId')) then qryLines.FieldByName('MaterialId').Visible := False;
  if Assigned(qryLines.FindField('SrcCellId')) then qryLines.FieldByName('SrcCellId').Visible := False;
  if Assigned(qryLines.FindField('DstCellId')) then qryLines.FieldByName('DstCellId').Visible := False;
end;

procedure TFormDocEdit.SelectDefaultWarehouses;
begin
  if NeedsSrcWh and (cbSrcWh.Items.Count > 0) and (cbSrcWh.ItemIndex < 0) then
  begin
    cbSrcWh.ItemIndex := 0;
    LoadSrcCells;
  end;
  if NeedsDstWh and (FDocType <> 'MOVE_CELL') and
     (cbDstWh.Items.Count > 0) and (cbDstWh.ItemIndex < 0) then
  begin
    cbDstWh.ItemIndex := 0;
    LoadDstCells;
  end;
  if (FDocType = 'MOVE_CELL') and (cbSrcWh.ItemIndex >= 0) then
  begin
    SetIdIndex(cbDstWh, FWhIds, SelectedId(cbSrcWh, FWhIds));
    LoadDstCells;
  end;
end;

function TFormDocEdit.EnsureDocumentSaved: Boolean;
begin
  Result := True;
  if FDocId <> 0 then Exit;
  try
    Result := SaveHeader;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Result := False;
    end;
  end;
end;

procedure TFormDocEdit.ApplyReadOnly;
var
  CanEdit: Boolean;
begin
  CanEdit := DmMain.CanEditDocs and not FIsPosted;
  btnSave.Enabled := CanEdit;
  btnPost.Enabled := CanEdit;
  btnAddLine.Enabled := CanEdit;
  btnDelLine.Enabled := CanEdit;
  btnApplyLine.Enabled := CanEdit;
  edtDate.ReadOnly := not CanEdit;
  edtComment.ReadOnly := not CanEdit;
  if CanEdit then
    ConfigureByType
  else
  begin
    cbSrcWh.Enabled := False;
    cbDstWh.Enabled := False;
    cbSrcCell.Enabled := False;
    cbDstCell.Enabled := False;
    cbMaterial.Enabled := False;
    edtQty.ReadOnly := True;
  end;
end;

function TFormDocEdit.ValidateHeader: Boolean;
var
  D: TDateTime;
begin
  Result := False;
  if not TryStrToDate(edtDate.Text, D) then
  begin
    ShowMessage('Неверная дата.');
    Exit;
  end;
  if NeedsSrcWh and (SelectedId(cbSrcWh, FWhIds) = 0) then
  begin
    ShowMessage('Укажите склад-отправитель.');
    Exit;
  end;
  if NeedsDstWh and (FDocType <> 'MOVE_CELL') and (SelectedId(cbDstWh, FWhIds) = 0) then
  begin
    ShowMessage('Укажите склад-получатель.');
    Exit;
  end;
  if (FDocType = 'MOVE_WH') and
     (SelectedId(cbSrcWh, FWhIds) = SelectedId(cbDstWh, FWhIds)) then
  begin
    ShowMessage('Склады должны быть разными.');
    Exit;
  end;
  Result := True;
end;

function TFormDocEdit.CreateHeader: Boolean;
var
  SP: TADOStoredProc;
  SrcId, DstId: Integer;
  D: TDateTime;
begin
  Result := False;
  if not ValidateHeader then Exit;
  D := StrToDate(edtDate.Text);
  SrcId := SelectedId(cbSrcWh, FWhIds);
  DstId := SelectedId(cbDstWh, FWhIds);
  if FDocType = 'MOVE_CELL' then
    DstId := SrcId;
  if FDocType = 'IN' then SrcId := 0;
  if FDocType = 'OUT' then DstId := 0;

  SP := TADOStoredProc.Create(nil);
  try
    SP.Connection := DmMain.Connection;
    SP.ProcedureName := 'dbo.usp_Document_Create';
    SP.Parameters.Refresh;
    SP.Parameters.ParamByName('@DocType').Value := FDocType;
    SP.Parameters.ParamByName('@DocDate').Value := D;
    SetIdParam(SP, '@SrcWarehouseId', SrcId);
    SetIdParam(SP, '@DstWarehouseId', DstId);
    SP.Parameters.ParamByName('@Comment').Value := edtComment.Text;
    SP.Parameters.ParamByName('@UserId').Value := DmMain.UserId;
    SP.Open;
    FDocId := SP.FieldByName('Id').AsInteger;
    edtNumber.Text := SP.FieldByName('DocNumber').AsString;
    edtStatus.Text := TDmMain.StatusCaption('DRAFT');
    if FDocType = 'MOVE_CELL' then
      SetIdIndex(cbDstWh, FWhIds, SrcId);
    LoadSrcCells;
    LoadDstCells;
    LoadLines;
    ApplyReadOnly;
    Result := True;
  finally
    SP.Free;
  end;
end;

function TFormDocEdit.SaveHeader: Boolean;
var
  SrcId, DstId: Integer;
  D: TDateTime;
  SP: TADOStoredProc;
begin
  Result := False;
  if not ValidateHeader then Exit;
  if FDocId = 0 then
  begin
    Result := CreateHeader;
    Exit;
  end;
  D := StrToDate(edtDate.Text);
  SrcId := SelectedId(cbSrcWh, FWhIds);
  DstId := SelectedId(cbDstWh, FWhIds);
  if FDocType = 'MOVE_CELL' then
    DstId := SrcId;
  if not NeedsSrcWh then SrcId := 0;
  if not NeedsDstWh then DstId := 0;
  SP := TADOStoredProc.Create(nil);
  try
    SP.Connection := DmMain.Connection;
    SP.ProcedureName := 'dbo.usp_Document_Update';
    SP.Parameters.Refresh;
    SP.Parameters.ParamByName('@DocumentId').Value := FDocId;
    SP.Parameters.ParamByName('@DocDate').Value := D;
    SetIdParam(SP, '@SrcWarehouseId', SrcId);
    SetIdParam(SP, '@DstWarehouseId', DstId);
    SP.Parameters.ParamByName('@Comment').Value := edtComment.Text;
    SP.Parameters.ParamByName('@UserId').Value := DmMain.UserId;
    SP.ExecProc;
  finally
    SP.Free;
  end;
  Result := True;
end;

function TFormDocEdit.ValidateLine: Boolean;
var
  Qty: Double;
  SrcC, DstC: Integer;
  S: string;
begin
  Result := False;
  if SelectedId(cbMaterial, FMatIds) = 0 then
  begin
    ShowMessage('Выберите материал.');
    Exit;
  end;
  S := StringReplace(edtQty.Text, ',', DecimalSeparator, [rfReplaceAll]);
  S := StringReplace(S, '.', DecimalSeparator, [rfReplaceAll]);
  if not TryStrToFloat(S, Qty) or (Qty <= 0) then
  begin
    ShowMessage('Количество должно быть больше нуля.');
    Exit;
  end;
  SrcC := SelectedId(cbSrcCell, FSrcCellIds);
  DstC := SelectedId(cbDstCell, FDstCellIds);
  if NeedsSrcCell and (SrcC = 0) then
  begin
    ShowMessage('Укажите ячейку-источник.');
    Exit;
  end;
  if NeedsDstCell and (DstC = 0) then
  begin
    ShowMessage('Укажите ячейку-получатель.');
    Exit;
  end;
  if NeedsSrcCell and NeedsDstCell and (SrcC = DstC) then
  begin
    ShowMessage('Ячейки источника и приёмника должны различаться.');
    Exit;
  end;
  Result := True;
end;

procedure TFormDocEdit.btnSaveClick(Sender: TObject);
begin
  try
    if SaveHeader then
    begin
      LoadStockBalances;
      ShowMessage('Документ сохранён.');
    end;
  except
    on E: Exception do ShowMessage(E.Message);
  end;
end;

procedure TFormDocEdit.btnPostClick(Sender: TObject);
var
  SP: TADOStoredProc;
begin
  if FDocId = 0 then
  begin
    ShowMessage('Сначала сохраните документ.');
    Exit;
  end;
  try
    if not SaveHeader then Exit;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Exit;
    end;
  end;
  LoadLines;
  if qryLines.IsEmpty then
  begin
    ShowMessage('Добавьте строки документа.');
    Exit;
  end;
  if MessageDlg('Провести документ?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  SP := TADOStoredProc.Create(nil);
  try
    SP.Connection := DmMain.Connection;
    SP.ProcedureName := 'dbo.usp_Document_Post';
    SP.Parameters.Refresh;
    SP.Parameters.ParamByName('@DocumentId').Value := FDocId;
    SP.Parameters.ParamByName('@UserId').Value := DmMain.UserId;
    try
      SP.ExecProc;
      FIsPosted := True;
      edtStatus.Text := TDmMain.StatusCaption('POSTED');
      ApplyReadOnly;
      LoadStockBalances;
      ShowMessage('Документ проведён.');
      ModalResult := mrOk;
    except
      on E: Exception do ShowMessage(E.Message);
    end;
  finally
    SP.Free;
  end;
end;

procedure TFormDocEdit.btnCloseClick(Sender: TObject);
begin
  if FDocId > 0 then
    ModalResult := mrOk
  else
    ModalResult := mrCancel;
end;

procedure TFormDocEdit.btnAddLineClick(Sender: TObject);
begin
  if not EnsureDocumentSaved then Exit;
  if cbMaterial.Items.Count > 0 then cbMaterial.ItemIndex := 0;
  edtQty.Text := '1';
  if cbSrcCell.Items.Count > 0 then cbSrcCell.ItemIndex := 0;
  if cbDstCell.Items.Count > 0 then cbDstCell.ItemIndex := 0;
  cbMaterial.SetFocus;
end;

procedure TFormDocEdit.btnApplyLineClick(Sender: TObject);
var
  Qty: Double;
  SrcC, DstC, MatId: Integer;
  S: string;
  SP: TADOStoredProc;
begin
  MatId := SelectedId(cbMaterial, FMatIds);
  SrcC := SelectedId(cbSrcCell, FSrcCellIds);
  DstC := SelectedId(cbDstCell, FDstCellIds);
  if not EnsureDocumentSaved then Exit;
  if MatId > 0 then
    SetIdIndex(cbMaterial, FMatIds, MatId);
  if SrcC > 0 then
    SetIdIndex(cbSrcCell, FSrcCellIds, SrcC);
  if DstC > 0 then
    SetIdIndex(cbDstCell, FDstCellIds, DstC);
  if not ValidateLine then Exit;
  MatId := SelectedId(cbMaterial, FMatIds);
  S := StringReplace(edtQty.Text, ',', DecimalSeparator, [rfReplaceAll]);
  S := StringReplace(S, '.', DecimalSeparator, [rfReplaceAll]);
  Qty := StrToFloat(S);
  SrcC := SelectedId(cbSrcCell, FSrcCellIds);
  DstC := SelectedId(cbDstCell, FDstCellIds);
  if FDocType = 'IN' then SrcC := 0;
  if FDocType = 'OUT' then DstC := 0;
  SP := TADOStoredProc.Create(nil);
  try
    SP.Connection := DmMain.Connection;
    SP.ProcedureName := 'dbo.usp_DocumentLine_Add';
    SP.Parameters.Refresh;
    SP.Parameters.ParamByName('@DocumentId').Value := FDocId;
    SP.Parameters.ParamByName('@MaterialId').Value := MatId;
    SP.Parameters.ParamByName('@Qty').Value := Qty;
    SetIdParam(SP, '@SrcCellId', SrcC);
    SetIdParam(SP, '@DstCellId', DstC);
    SP.Parameters.ParamByName('@UserId').Value := DmMain.UserId;
    try
      SP.ExecProc;
      LoadLines;
    except
      on E: Exception do ShowMessage(E.Message);
    end;
  finally
    SP.Free;
  end;
end;

procedure TFormDocEdit.btnDelLineClick(Sender: TObject);
var
  SP: TADOStoredProc;
begin
  if qryLines.IsEmpty then Exit;
  if MessageDlg('Удалить строку?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  SP := TADOStoredProc.Create(nil);
  try
    SP.Connection := DmMain.Connection;
    SP.ProcedureName := 'dbo.usp_DocumentLine_Delete';
    SP.Parameters.Refresh;
    SP.Parameters.ParamByName('@LineId').Value := qryLines.FieldByName('Id').AsInteger;
    SP.Parameters.ParamByName('@UserId').Value := DmMain.UserId;
    try
      SP.ExecProc;
    except
      on E: Exception do ShowMessage(E.Message);
    end;
  finally
    SP.Free;
  end;
  LoadLines;
end;

end.
