object FormWarehouses: TFormWarehouses
  Left = 200
  Top = 120
  Width = 640
  Height = 420
  Caption = #1057#1082#1083#1072#1076#1099
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
    Width = 632
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
    Width = 632
    Height = 65
    Align = alTop
    TabOrder = 1
    object lblName: TLabel
      Left = 16
      Top = 12
      Width = 60
      Height = 13
      Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
    end
    object lblAddress: TLabel
      Left = 16
      Top = 40
      Width = 35
      Height = 13
      Caption = #1040#1076#1088#1077#1089
    end
    object edtName: TDBEdit
      Left = 96
      Top = 8
      Width = 300
      Height = 21
      DataField = 'Name'
      DataSource = ds
      TabOrder = 0
    end
    object edtAddress: TDBEdit
      Left = 96
      Top = 36
      Width = 400
      Height = 21
      DataField = 'Address'
      DataSource = ds
      TabOrder = 1
    end
  end
  object Grid: TDBGrid
    Left = 0
    Top = 106
    Width = 632
    Height = 287
    Align = alClient
    DataSource = ds
    TabOrder = 2
    TitleFont.Charset = RUSSIAN_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'Id'
        Title.Caption = 'Id'
        Visible = True
        Width = 40
      end
      item
        Expanded = False
        FieldName = 'Name'
        Title.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
        Width = 200
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Address'
        Title.Caption = #1040#1076#1088#1077#1089
        Width = 280
        Visible = True
      end>
  end
  object qry: TADOQuery
    CursorType = ctStatic
    LockType = ltBatchOptimistic
    Parameters = <>
    Left = 400
    Top = 8
  end
  object ds: TDataSource
    DataSet = qry
    Left = 448
    Top = 8
  end
end
