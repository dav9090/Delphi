program Warehouse;

uses
  Forms,
  uDmMain in 'uDmMain.pas' {DmMain},
  uLogin in 'uLogin.pas' {FormLogin},
  uMain in 'uMain.pas' {FormMain},
  uWarehouses in 'uWarehouses.pas' {FormWarehouses},
  uCells in 'uCells.pas' {FormCells},
  uUnits in 'uUnits.pas' {FormUnits},
  uMaterials in 'uMaterials.pas' {FormMaterials},
  uUsers in 'uUsers.pas' {FormUsers},
  uDocList in 'uDocList.pas' {FormDocList},
  uDocEdit in 'uDocEdit.pas' {FormDocEdit},
  uStockReport in 'uStockReport.pas' {FormStockReport};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Складской учёт - Курганстальмост';
  Application.CreateForm(TDmMain, DmMain);
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
