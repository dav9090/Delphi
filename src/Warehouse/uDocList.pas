unit uDocList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, ADODB, Grids, DBGrids, ComCtrls,
  uDmMain, uDocEdit;

type
  TFormDocList = class(TForm)
    PanelTop: TPanel;
    btnRefresh: TButton;
    btnOpen: TButton;
    btnNewIn: TButton;
    btnNewOut: TButton;
    btnNewMoveCell: TButton;
    btnNewMoveWh: TButton;
    btnUnpost: TButton;
    lblType: TLabel;
    cbType: TComboBox;
    lblStatus: TLabel;
    cbStatus: TComboBox;
    Grid: TDBGrid;
    ds: TDataSource;
    qry: TADOQuery;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnNewInClick(Sender: TObject);
    procedure btnNewOutClick(Sender: TObject);
    procedure btnNewMoveCellClick(Sender: TObject);
    procedure btnNewMoveWhClick(Sender: TObject);
    procedure btnUnpostClick(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
  private
    procedure OpenData;
    procedure CreateDoc(const DocType: string);
    procedure SetupCaptions;
    function SelectedDocTypeCode: string;
    function SelectedStatusCode: string;
  public
  end;

implementation

{$R *.dfm}

procedure TFormDocList.FormCreate(Sender: TObject);
begin
  Font.Charset := RUSSIAN_CHARSET;
  Font.Name := 'Tahoma';
  qry.Connection := DmMain.Connection;
  cbType.Items.Clear;
  cbType.Items.Add('Все');
  cbType.Items.Add('Приход');
  cbType.Items.Add('Расход');
  cbType.Items.Add('Перемещение по ячейкам');
  cbType.Items.Add('Перемещение между складами');
  cbType.ItemIndex := 0;
  cbStatus.Items.Clear;
  cbStatus.Items.Add('Все');
  cbStatus.Items.Add('Черновик');
  cbStatus.Items.Add('Проведён');
  cbStatus.ItemIndex := 0;
end;

function TFormDocList.SelectedDocTypeCode: string;
begin
  case cbType.ItemIndex of
    1: Result := 'IN';
    2: Result := 'OUT';
    3: Result := 'MOVE_CELL';
    4: Result := 'MOVE_WH';
  else
    Result := '';
  end;
end;

function TFormDocList.SelectedStatusCode: string;
begin
  case cbStatus.ItemIndex of
    1: Result := 'DRAFT';
    2: Result := 'POSTED';
  else
    Result := '';
  end;
end;

procedure TFormDocList.SetupCaptions;
begin
  TDmMain.SetupField(qry, 'Id', 'Код', 6);
  TDmMain.SetupField(qry, 'DocTypeName', 'Тип', 22);
  TDmMain.SetupField(qry, 'DocNumber', 'Номер', 12);
  TDmMain.SetupField(qry, 'DocDate', 'Дата', 10);
  TDmMain.SetupField(qry, 'StatusName', 'Статус', 10);
  TDmMain.SetupField(qry, 'Comment', 'Комментарий', 24);
  TDmMain.SetupField(qry, 'CreatedByLogin', 'Автор', 12);
  if Assigned(qry.FindField('DocType')) then
    qry.FieldByName('DocType').Visible := False;
  if Assigned(qry.FindField('Status')) then
    qry.FieldByName('Status').Visible := False;
  if Assigned(qry.FindField('SrcWarehouseId')) then
    qry.FieldByName('SrcWarehouseId').Visible := False;
  if Assigned(qry.FindField('DstWarehouseId')) then
    qry.FieldByName('DstWarehouseId').Visible := False;
end;

procedure TFormDocList.OpenData;
var
  SQL, DocTypeCode, StatusCode: string;
begin
  DocTypeCode := SelectedDocTypeCode;
  StatusCode := SelectedStatusCode;
  SQL :=
    'SELECT d.Id, d.DocType, d.Status,' +
    ' CASE d.DocType' +
    '   WHEN ''IN'' THEN N''Приход''' +
    '   WHEN ''OUT'' THEN N''Расход''' +
    '   WHEN ''MOVE_CELL'' THEN N''Перемещение по ячейкам''' +
    '   WHEN ''MOVE_WH'' THEN N''Перемещение между складами''' +
    '   ELSE d.DocType END AS DocTypeName,' +
    ' d.DocNumber, d.DocDate,' +
    ' CASE d.Status' +
    '   WHEN ''DRAFT'' THEN N''Черновик''' +
    '   WHEN ''POSTED'' THEN N''Проведён''' +
    '   ELSE d.Status END AS StatusName,' +
    ' d.SrcWarehouseId, d.DstWarehouseId, d.Comment,' +
    ' u.Login AS CreatedByLogin' +
    ' FROM dbo.Documents d' +
    ' JOIN dbo.Users u ON u.Id = d.CreatedBy' +
    ' WHERE 1=1';
  if DocTypeCode <> '' then
    SQL := SQL + ' AND d.DocType = ''' + DocTypeCode + '''';
  if StatusCode <> '' then
    SQL := SQL + ' AND d.Status = ''' + StatusCode + '''';
  SQL := SQL + ' ORDER BY d.DocDate DESC, d.Id DESC';
  qry.Close;
  qry.SQL.Text := SQL;
  qry.Open;
  SetupCaptions;
  btnNewIn.Enabled := DmMain.CanEditDocs;
  btnNewOut.Enabled := DmMain.CanEditDocs;
  btnNewMoveCell.Enabled := DmMain.CanEditDocs;
  btnNewMoveWh.Enabled := DmMain.CanEditDocs;
  btnUnpost.Enabled := DmMain.CanUnpost;
end;

procedure TFormDocList.FormShow(Sender: TObject);
begin
  OpenData;
end;

procedure TFormDocList.btnRefreshClick(Sender: TObject);
begin
  OpenData;
end;

procedure TFormDocList.CreateDoc(const DocType: string);
begin
  if TFormDocEdit.CreateDocument(DocType) then
    OpenData;
end;

procedure TFormDocList.btnNewInClick(Sender: TObject);
begin
  CreateDoc('IN');
end;

procedure TFormDocList.btnNewOutClick(Sender: TObject);
begin
  CreateDoc('OUT');
end;

procedure TFormDocList.btnNewMoveCellClick(Sender: TObject);
begin
  CreateDoc('MOVE_CELL');
end;

procedure TFormDocList.btnNewMoveWhClick(Sender: TObject);
begin
  CreateDoc('MOVE_WH');
end;

procedure TFormDocList.btnOpenClick(Sender: TObject);
begin
  if qry.IsEmpty then Exit;
  if TFormDocEdit.OpenDoc(qry.FieldByName('Id').AsInteger) then
    OpenData;
end;

procedure TFormDocList.GridDblClick(Sender: TObject);
begin
  btnOpenClick(Sender);
end;

procedure TFormDocList.btnUnpostClick(Sender: TObject);
var
  SP: TADOStoredProc;
begin
  if qry.IsEmpty then Exit;
  if qry.FieldByName('Status').AsString <> 'POSTED' then
  begin
    ShowMessage('Документ не проведён.');
    Exit;
  end;
  if MessageDlg('Отменить проведение документа?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  SP := TADOStoredProc.Create(nil);
  try
    SP.Connection := DmMain.Connection;
    SP.ProcedureName := 'dbo.usp_Document_Unpost';
    SP.Parameters.Refresh;
    SP.Parameters.ParamByName('@DocumentId').Value := qry.FieldByName('Id').AsInteger;
    SP.Parameters.ParamByName('@UserId').Value := DmMain.UserId;
    try
      SP.ExecProc;
      ShowMessage('Проведение отменено.');
      OpenData;
    except
      on E: Exception do ShowMessage(E.Message);
    end;
  finally
    SP.Free;
  end;
end;

procedure TFormDocList.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
