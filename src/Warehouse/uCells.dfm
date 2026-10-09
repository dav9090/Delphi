object FormCells: TFormCells
  Left = 210
  Top = 130
  Width = 620
  Height = 400
  Caption = #1071#1095#1077#1081#1082#1080' '#1089#1082#1083#1072#1076#1072
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  OnCreate = FormCreate
  OnShow = FormShow
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 612
    Height = 41
    Align = alTop
    TabOrder = 0
    object lblWh: TLabel
      Left = 8
      Top = 12
      Width = 30
      Height = 13
      Caption = #1057#1082#1083#1072#1076
    end
    object cbWarehouse: TComboBox
      Left = 48
      Top = 8
      Width = 200
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbWarehouseChange
    end
    object btnRefresh: TButton
      Left = 264
      Top = 8
      Width = 75
      Height = 25
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      TabOrder = 1
      OnClick = btnRefreshClick
    end
    object btnAdd: TButton
      Left = 344
      Top = 8
      Width = 75
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 2
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 424
      Top = 8
      Width = 75
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 3
      OnClick = btnDeleteClick
    end
    object btnSave: TButton
      Left = 504
      Top = 8
      Width = 75
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 4
      OnClick = btnSaveClick
    end
  end
  object PanelEdit: TPanel
    Left = 0
    Top = 41
    Width = 612
    Height = 49
    Align = alTop
    TabOrder = 1
    object lblCode: TLabel
      Left = 16
      Top = 16
      Width = 20
      Height = 13
      Caption = #1050#1086#1076
    end
    object lblName: TLabel
      Left = 160
      Top = 16
      Width = 60
      Height = 13
      Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
    end
    object edtCode: TDBEdit
      Left = 48
      Top = 12
      Width = 90
      Height = 21
      DataField = 'Code'
      DataSource = ds
      TabOrder = 0
    end
    object edtName: TDBEdit
      Left = 240
      Top = 12
      Width = 280
      Height = 21
      DataField = 'Name'
      DataSource = ds
      TabOrder = 1
    end
  end
  object Grid: TDBGrid
    Left = 0
    Top = 90
    Width = 612
    Height = 283
    Align = alClient
    DataSource = ds
    TabOrder = 2
    TitleFont.Charset = RUSSIAN_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object qry: TADOQuery
    CursorType = ctStatic
    LockType = ltBatchOptimistic
    Parameters = <>
    Left = 40
    Top = 120
  end
  object ds: TDataSource
    DataSet = qry
    Left = 88
    Top = 120
  end
end
