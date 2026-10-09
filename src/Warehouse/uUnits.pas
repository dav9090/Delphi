unit uUnits;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, ADODB, Grids, DBGrids, DBCtrls, Mask,
  uDmMain;

type
  TFormUnits = class(TForm)
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
    edtCode: TDBEdit;
    edtName: TDBEdit;
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

procedure TFormUnits.FormCreate(Sender: TObject);
begin
  Font.Charset := RUSSIAN_CHARSET;
  Font.Name := 'Tahoma';
  qry.Connection := DmMain.Connection;
end;

procedure TFormUnits.OpenData;
begin
  qry.Close;
  qry.SQL.Text := 'SELECT Id, Code, Name FROM dbo.Units ORDER BY Code';
  qry.Open;
  TDmMain.SetupField(qry, 'Id', 'Код', 6);
  TDmMain.SetupField(qry, 'Code', 'Обозначение', 10);
  TDmMain.SetupField(qry, 'Name', 'Наименование', 24);
  btnAdd.Enabled := DmMain.CanEditRefs;
  btnDelete.Enabled := DmMain.CanEditRefs;
  btnSave.Enabled := DmMain.CanEditRefs;
end;

procedure TFormUnits.FormShow(Sender: TObject);
begin
  OpenData;
end;

procedure TFormUnits.btnRefreshClick(Sender: TObject);
begin
  OpenData;
end;

procedure TFormUnits.btnAddClick(Sender: TObject);
begin
  qry.Append;
end;

procedure TFormUnits.btnDeleteClick(Sender: TObject);
begin
  if qry.IsEmpty then Exit;
  if MessageDlg('Удалить единицу измерения?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
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

procedure TFormUnits.btnSaveClick(Sender: TObject);
begin
  try
    if qry.State in [dsEdit, dsInsert] then qry.Post;
    qry.UpdateBatch;
    ShowMessage('Сохранено.');
  except
    on E: Exception do ShowMessage('Не удалось сохранить: ' + E.Message);
  end;
end;


procedure TFormUnits.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
