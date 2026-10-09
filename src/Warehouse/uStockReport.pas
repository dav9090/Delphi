unit uStockReport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, ADODB, Grids, DBGrids, QuickRpt, QRCtrls,
  Printers, uDmMain;

type
  TFormStockReport = class(TForm)
    PanelTop: TPanel;
    btnRefresh: TButton;
    btnPrint: TButton;
    chkDetail: TCheckBox;
    Grid: TDBGrid;
    ds: TDataSource;
    qry: TADOQuery;
    qr: TQuickRep;
    QRBandTitle: TQRBand;
    QRLabelTitle: TQRLabel;
    QRBandHeader: TQRBand;
    QRLabelWh: TQRLabel;
    QRLabelMat: TQRLabel;
    QRLabelQty: TQRLabel;
    QRBandDetail: TQRBand;
    QRDBWh: TQRDBText;
    QRDBMat: TQRDBText;
    QRDBQty: TQRDBText;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
  private
    procedure OpenData;
  public
  end;

implementation

{$R *.dfm}

procedure TFormStockReport.FormCreate(Sender: TObject);
begin
  Font.Charset := RUSSIAN_CHARSET;
  Font.Name := 'Tahoma';
  qry.Connection := DmMain.Connection;
  qr.DataSet := qry;
  qr.Visible := False;
end;

procedure TFormStockReport.OpenData;
begin
  qry.Close;
  if chkDetail.Checked then
    qry.SQL.Text :=
      'SELECT WarehouseName, CellCode, MaterialName, UnitCode, Qty' +
      ' FROM dbo.vw_StockByCell ORDER BY WarehouseName, MaterialName, CellCode'
  else
    qry.SQL.Text :=
      'SELECT WarehouseName, MaterialName, UnitCode, Qty' +
      ' FROM dbo.vw_StockByWarehouse ORDER BY WarehouseName, MaterialName';
  qry.Open;
  TDmMain.SetupField(qry, 'WarehouseName', 'Склад', 16);
  TDmMain.SetupField(qry, 'CellCode', 'Ячейка', 10);
  TDmMain.SetupField(qry, 'MaterialName', 'Материал', 28);
  TDmMain.SetupField(qry, 'UnitCode', 'Ед. изм.', 8);
  TDmMain.SetupField(qry, 'Qty', 'Количество', 10);
end;

procedure TFormStockReport.FormShow(Sender: TObject);
begin
  OpenData;
end;

procedure TFormStockReport.btnRefreshClick(Sender: TObject);
begin
  OpenData;
end;

procedure TFormStockReport.btnPrintClick(Sender: TObject);
var
  QPrint: TADOQuery;
begin
  // Печать по ТЗ: склад, материал, количество (агрегат)
  QPrint := TADOQuery.Create(nil);
  try
    QPrint.Connection := DmMain.Connection;
    QPrint.SQL.Text :=
      'SELECT WarehouseName, MaterialName, Qty' +
      ' FROM dbo.vw_StockByWarehouse ORDER BY WarehouseName, MaterialName';
    QPrint.Open;
    qr.DataSet := QPrint;
    QRDBWh.DataSet := QPrint;
    QRDBMat.DataSet := QPrint;
    QRDBQty.DataSet := QPrint;
    QRDBWh.DataField := 'WarehouseName';
    QRDBMat.DataField := 'MaterialName';
    QRDBQty.DataField := 'Qty';
    QRLabelTitle.Caption := 'Остатки материалов на складах';
    qr.Preview;
    qr.DataSet := qry;
  finally
    QPrint.Free;
  end;
end;


procedure TFormStockReport.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
