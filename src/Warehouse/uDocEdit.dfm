object FormDocEdit: TFormDocEdit
  Left = 160
  Top = 80
  BorderStyle = bsDialog
  Caption = #1044#1086#1082#1091#1084#1077#1085#1090
  ClientHeight = 640
  ClientWidth = 760
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 760
    Height = 145
    Align = alTop
    TabOrder = 0
    object lblDocType: TLabel
      Left = 16
      Top = 12
      Width = 120
      Height = 13
      Caption = #1058#1080#1087
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblNumber: TLabel
      Left = 200
      Top = 12
      Width = 35
      Height = 13
      Caption = #1053#1086#1084#1077#1088
    end
    object lblDate: TLabel
      Left = 400
      Top = 12
      Width = 25
      Height = 13
      Caption = #1044#1072#1090#1072
    end
    object lblStatus: TLabel
      Left = 560
      Top = 12
      Width = 40
      Height = 13
      Caption = #1057#1090#1072#1090#1091#1089
    end
    object lblSrcWh: TLabel
      Left = 16
      Top = 48
      Width = 90
      Height = 13
      Caption = #1057#1082#1083#1072#1076'-'#1080#1089#1090#1086#1095#1085#1080#1082
    end
    object lblDstWh: TLabel
      Left = 360
      Top = 48
      Width = 100
      Height = 13
      Caption = #1057#1082#1083#1072#1076'-'#1087#1086#1083#1091#1095#1072#1090#1077#1083#1100
    end
    object lblComment: TLabel
      Left = 16
      Top = 84
      Width = 60
      Height = 13
      Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081
    end
    object edtNumber: TEdit
      Left = 248
      Top = 8
      Width = 120
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
    object edtDate: TEdit
      Left = 440
      Top = 8
      Width = 90
      Height = 21
      TabOrder = 1
    end
    object edtStatus: TEdit
      Left = 608
      Top = 8
      Width = 100
      Height = 21
      ReadOnly = True
      TabOrder = 2
    end
    object cbSrcWh: TComboBox
      Left = 120
      Top = 44
      Width = 200
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 3
      OnChange = cbSrcWhChange
    end
    object cbDstWh: TComboBox
      Left = 480
      Top = 44
      Width = 220
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 4
      OnChange = cbDstWhChange
    end
    object edtComment: TEdit
      Left = 120
      Top = 80
      Width = 580
      Height = 21
      TabOrder = 5
    end
    object btnSave: TButton
      Left = 120
      Top = 112
      Width = 120
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1095#1077#1088#1085#1086#1074#1080#1082
      TabOrder = 6
      OnClick = btnSaveClick
    end
    object btnPost: TButton
      Left = 256
      Top = 112
      Width = 100
      Height = 25
      Caption = #1055#1088#1086#1074#1077#1089#1090#1080
      TabOrder = 7
      OnClick = btnPostClick
    end
    object btnClose: TButton
      Left = 600
      Top = 112
      Width = 100
      Height = 25
      Cancel = True
      Caption = #1047#1072#1082#1088#1099#1090#1100
      TabOrder = 8
      OnClick = btnCloseClick
    end
  end
  object PanelLineEdit: TPanel
    Left = 0
    Top = 145
    Width = 760
    Height = 73
    Align = alTop
    TabOrder = 1
    object lblMaterial: TLabel
      Left = 8
      Top = 12
      Width = 50
      Height = 13
      Caption = #1052#1072#1090#1077#1088#1080#1072#1083
    end
    object lblQty: TLabel
      Left = 320
      Top = 12
      Width = 60
      Height = 13
      Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086
    end
    object lblSrcCell: TLabel
      Left = 8
      Top = 44
      Width = 90
      Height = 13
      Caption = #1071#1095#1077#1081#1082#1072'-'#1080#1089#1090#1086#1095#1085#1080#1082
    end
    object lblDstCell: TLabel
      Left = 280
      Top = 44
      Width = 100
      Height = 13
      Caption = #1071#1095#1077#1081#1082#1072'-'#1087#1086#1083#1091#1095#1072#1090#1077#1083#1100
    end
    object cbMaterial: TComboBox
      Left = 72
      Top = 8
      Width = 230
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
    end
    object edtQty: TEdit
      Left = 400
      Top = 8
      Width = 80
      Height = 21
      TabOrder = 1
      Text = '1'
    end
    object cbSrcCell: TComboBox
      Left = 120
      Top = 40
      Width = 120
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 2
    end
    object cbDstCell: TComboBox
      Left = 400
      Top = 40
      Width = 120
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 3
    end
    object btnApplyLine: TButton
      Left = 560
      Top = 36
      Width = 120
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1089#1090#1088#1086#1082#1091
      TabOrder = 4
      OnClick = btnApplyLineClick
    end
  end
  object PanelLines: TPanel
    Left = 0
    Top = 218
    Width = 760
    Height = 33
    Align = alTop
    TabOrder = 2
    object btnAddLine: TButton
      Left = 8
      Top = 4
      Width = 120
      Height = 25
      Caption = #1053#1086#1074#1072#1103' '#1089#1090#1088#1086#1082#1072
      TabOrder = 0
      OnClick = btnAddLineClick
    end
    object btnDelLine: TButton
      Left = 136
      Top = 4
      Width = 120
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1089#1090#1088#1086#1082#1091
      TabOrder = 1
      OnClick = btnDelLineClick
    end
  end
  object Grid: TDBGrid
    Left = 0
    Top = 251
    Width = 760
    Height = 189
    Align = alClient
    DataSource = dsLines
    ReadOnly = True
    TabOrder = 3
    TitleFont.Charset = RUSSIAN_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object PanelStock: TPanel
    Left = 0
    Top = 440
    Width = 760
    Height = 200
    Align = alBottom
    TabOrder = 4
    object lblStock: TLabel
      Left = 8
      Top = 8
      Width = 500
      Height = 13
      Caption = #1054#1089#1090#1072#1090#1082#1080' '#1087#1086' '#1089#1082#1083#1072#1076#1072#1084
    end
    object GridStock: TDBGrid
      Left = 1
      Top = 28
      Width = 758
      Height = 171
      Align = alBottom
      Anchors = [akLeft, akTop, akRight, akBottom]
      DataSource = dsStock
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = RUSSIAN_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      OnDblClick = GridStockDblClick
    end
  end
  object qryLines: TADOQuery
    CursorType = ctStatic
    LockType = ltReadOnly
    Parameters = <>
    Left = 600
    Top = 280
  end
  object dsLines: TDataSource
    DataSet = qryLines
    Left = 648
    Top = 280
  end
  object qryStock: TADOQuery
    CursorType = ctStatic
    LockType = ltReadOnly
    Parameters = <>
    Left = 520
    Top = 480
  end
  object dsStock: TDataSource
    DataSet = qryStock
    Left = 568
    Top = 480
  end
end
