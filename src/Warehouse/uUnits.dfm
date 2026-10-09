object FormUnits: TFormUnits
  Left = 220
  Top = 140
  Width = 520
  Height = 380
  Caption = #1045#1076#1080#1085#1080#1094#1099' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
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
    Width = 512
    Height = 41
    Align = alTop
    TabOrder = 0
    object btnRefresh: TButton
      Left = 8
      Top = 8
      Width = 80
      Height = 25
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      TabOrder = 0
      OnClick = btnRefreshClick
    end
    object btnAdd: TButton
      Left = 96
      Top = 8
      Width = 80
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 1
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 184
      Top = 8
      Width = 80
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnSave: TButton
      Left = 272
      Top = 8
      Width = 80
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 3
      OnClick = btnSaveClick
    end
  end
  object PanelEdit: TPanel
    Left = 0
    Top = 41
    Width = 512
    Height = 57
    Align = alTop
    TabOrder = 1
    object lblCode: TLabel
      Left = 16
      Top = 20
      Width = 20
      Height = 13
      Caption = #1050#1086#1076
    end
    object lblName: TLabel
      Left = 160
      Top = 20
      Width = 60
      Height = 13
      Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
    end
    object edtCode: TDBEdit
      Left = 48
      Top = 16
      Width = 80
      Height = 21
      DataField = 'Code'
      DataSource = ds
      TabOrder = 0
    end
    object edtName: TDBEdit
      Left = 240
      Top = 16
      Width = 220
      Height = 21
      DataField = 'Name'
      DataSource = ds
      TabOrder = 1
    end
  end
  object Grid: TDBGrid
    Left = 0
    Top = 98
    Width = 512
    Height = 255
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
    Left = 360
    Top = 8
  end
  object ds: TDataSource
    DataSet = qry
    Left = 408
    Top = 8
  end
end
