object FormMain: TFormMain
  Left = 120
  Top = 80
  Width = 900
  Height = 600
  Caption = #1057#1082#1083#1072#1076#1089#1082#1086#1081' '#1091#1095#1105#1090' ''-'' '#1050#1091#1088#1075#1072#1085#1089#1090#1072#1083#1100#1084#1086#1089#1090
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 543
    Width = 892
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object MainMenu: TMainMenu
    Left = 40
    Top = 40
    object miRefs: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1086#1095#1085#1080#1082#1080
      object miWarehouses: TMenuItem
        Caption = #1057#1082#1083#1072#1076#1099
        OnClick = miWarehousesClick
      end
      object miCells: TMenuItem
        Caption = #1071#1095#1077#1081#1082#1080
        OnClick = miCellsClick
      end
      object miUnits: TMenuItem
        Caption = #1045#1076'. '#1080#1079#1084#1077#1088#1077#1085#1080#1103
        OnClick = miUnitsClick
      end
      object miMaterials: TMenuItem
        Caption = #1052#1072#1090#1077#1088#1080#1072#1083#1099
        OnClick = miMaterialsClick
      end
      object miUsers: TMenuItem
        Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080
        OnClick = miUsersClick
      end
    end
    object miDocs: TMenuItem
      Caption = #1044#1086#1082#1091#1084#1077#1085#1090#1099
      object miDocJournal: TMenuItem
        Caption = #1046#1091#1088#1085#1072#1083' '#1076#1086#1082#1091#1084#1077#1085#1090#1086#1074
        OnClick = miDocJournalClick
      end
    end
    object miReports: TMenuItem
      Caption = #1054#1090#1095#1105#1090#1099
      object miStockReport: TMenuItem
        Caption = #1054#1089#1090#1072#1090#1082#1080' '#1085#1072' '#1089#1082#1083#1072#1076#1072#1093
        OnClick = miStockReportClick
      end
    end
    object miHelp: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
      object miAbout: TMenuItem
        Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
        OnClick = miAboutClick
      end
    end
    object miExit: TMenuItem
      Caption = #1042#1099#1093#1086#1076
      OnClick = miExitClick
    end
  end
end
