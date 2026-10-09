object FormUsers: TFormUsers
  Left = 240
  Top = 150
  Width = 700
  Height = 420
  Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080
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
    Width = 692
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
    object btnSave: TButton
      Left = 184
      Top = 8
      Width = 80
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 2
      OnClick = btnSaveClick
    end
    object btnSetPassword: TButton
      Left = 272
      Top = 8
      Width = 120
      Height = 25
      Caption = #1047#1072#1076#1072#1090#1100' '#1087#1072#1088#1086#1083#1100
      TabOrder = 3
      OnClick = btnSetPasswordClick
    end
  end
  object PanelEdit: TPanel
    Left = 0
    Top = 41
    Width = 692
    Height = 65
    Align = alTop
    TabOrder = 1
    object lblLogin: TLabel
      Left = 8
      Top = 12
      Width = 33
      Height = 13
      Caption = #1051#1086#1075#1080#1085
    end
    object lblName: TLabel
      Left = 160
      Top = 12
      Width = 30
      Height = 13
      Caption = #1060#1048#1054
    end
    object lblRole: TLabel
      Left = 8
      Top = 40
      Width = 20
      Height = 13
      Caption = #1056#1086#1083#1100
    end
    object edtLogin: TDBEdit
      Left = 56
      Top = 8
      Width = 90
      Height = 21
      DataField = 'Login'
      DataSource = ds
      TabOrder = 0
    end
    object edtName: TDBEdit
      Left = 200
      Top = 8
      Width = 280
      Height = 21
      DataField = 'FullName'
      DataSource = ds
      TabOrder = 1
    end
    object lcbRole: TDBLookupComboBox
      Left = 56
      Top = 36
      Width = 160
      Height = 21
      DataField = 'RoleId'
      DataSource = ds
      KeyField = 'Id'
      ListField = 'Name'
      ListSource = dsRoles
      TabOrder = 2
    end
    object chkActive: TDBCheckBox
      Left = 240
      Top = 36
      Width = 100
      Height = 17
      Caption = #1040#1082#1090#1080#1074#1077#1085
      DataField = 'IsActive'
      DataSource = ds
      TabOrder = 3
      ValueChecked = 'True'
      ValueUnchecked = 'False'
    end
  end
  object Grid: TDBGrid
    Left = 0
    Top = 106
    Width = 692
    Height = 287
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
    Left = 480
    Top = 8
  end
  object ds: TDataSource
    DataSet = qry
    Left = 528
    Top = 8
  end
  object qryRoles: TADOQuery
    Parameters = <>
    Left = 576
    Top = 8
  end
  object dsRoles: TDataSource
    DataSet = qryRoles
    Left = 624
    Top = 8
  end
end
