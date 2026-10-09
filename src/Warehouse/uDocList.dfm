object FormDocList: TFormDocList
  Left = 180
  Top = 100
  Width = 860
  Height = 480
  Caption = #1046#1091#1088#1085#1072#1083' '#1076#1086#1082#1091#1084#1077#1085#1090#1086#1074
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
    Width = 852
    Height = 73
    Align = alTop
    TabOrder = 0
    object lblType: TLabel
      Left = 8
      Top = 12
      Width = 18
      Height = 13
      Caption = #1058#1080#1087
    end
    object lblStatus: TLabel
      Left = 200
      Top = 12
      Width = 40
      Height = 13
      Caption = #1057#1090#1072#1090#1091#1089
    end
    object cbType: TComboBox
      Left = 40
      Top = 8
      Width = 120
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
    end
    object cbStatus: TComboBox
      Left = 248
      Top = 8
      Width = 100
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
    end
    object btnRefresh: TButton
      Left = 368
      Top = 6
      Width = 80
      Height = 25
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      TabOrder = 2
      OnClick = btnRefreshClick
    end
    object btnOpen: TButton
      Left = 456
      Top = 6
      Width = 80
      Height = 25
      Caption = #1054#1090#1082#1088#1099#1090#1100
      TabOrder = 3
      OnClick = btnOpenClick
    end
    object btnUnpost: TButton
      Left = 544
      Top = 6
      Width = 130
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100' '#1087#1088#1086#1074#1077#1076#1077#1085#1080#1077
      TabOrder = 4
      OnClick = btnUnpostClick
    end
    object btnNewIn: TButton
      Left = 8
      Top = 40
      Width = 100
      Height = 25
      Caption = #1055#1088#1080#1093#1086#1076
      TabOrder = 5
      OnClick = btnNewInClick
    end
    object btnNewOut: TButton
      Left = 116
      Top = 40
      Width = 100
      Height = 25
      Caption = #1056#1072#1089#1093#1086#1076
      TabOrder = 6
      OnClick = btnNewOutClick
    end
    object btnNewMoveCell: TButton
      Left = 224
      Top = 40
      Width = 160
      Height = 25
      Caption = #1055#1077#1088#1077#1084#1077#1097#1077#1085#1080#1077' '#1087#1086' '#1103#1095#1077#1081#1082#1072#1084
      TabOrder = 7
      OnClick = btnNewMoveCellClick
    end
    object btnNewMoveWh: TButton
      Left = 392
      Top = 40
      Width = 160
      Height = 25
      Caption = #1055#1077#1088#1077#1084#1077#1097#1077#1085#1080#1077' '#1084#1077#1078#1076#1091' '#1089#1082#1083#1072#1076#1072#1084#1080
      TabOrder = 8
      OnClick = btnNewMoveWhClick
    end
  end
  object Grid: TDBGrid
    Left = 0
    Top = 73
    Width = 852
    Height = 380
    Align = alClient
    DataSource = ds
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = RUSSIAN_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnDblClick = GridDblClick
  end
  object qry: TADOQuery
    CursorType = ctStatic
    LockType = ltReadOnly
    Parameters = <>
    Left = 720
    Top = 16
  end
  object ds: TDataSource
    DataSet = qry
    Left = 768
    Top = 16
  end
end
