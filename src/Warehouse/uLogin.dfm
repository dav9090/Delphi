object FormLogin: TFormLogin
  Left = 300
  Top = 250
  BorderStyle = bsDialog
  Caption = #1042#1093#1086#1076' '#1074' '#1089#1080#1089#1090#1077#1084#1091
  ClientHeight = 250
  ClientWidth = 400
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
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblTitle: TLabel
      Left = 16
      Top = 10
      Width = 300
      Height = 13
      Caption = #1057#1082#1083#1072#1076#1089#1082#1086#1081' '#1091#1095#1105#1090' '#1084#1072#1090#1077#1088#1080#1072#1083#1086#1074
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblOrg: TLabel
      Left = 16
      Top = 32
      Width = 300
      Height = 13
      Caption = #1050#1091#1088#1075#1072#1085#1089#1090#1072#1083#1100#1084#1086#1089#1090
    end
  end
  object lblLogin: TLabel
    Left = 24
    Top = 76
    Width = 33
    Height = 13
    Caption = #1051#1086#1075#1080#1085
  end
  object lblPassword: TLabel
    Left = 24
    Top = 112
    Width = 37
    Height = 13
    Caption = #1055#1072#1088#1086#1083#1100
  end
  object lblAuthor: TLabel
    Left = 24
    Top = 216
    Width = 360
    Height = 13
    Caption = #1040#1074#1090#1086#1088': '#1044#1088#1103#1093#1083#1086#1074' '#1040#1083#1077#1082#1089#1072#1085#1076#1088' '#1042#1072#1089#1080#1083#1100#1077#1074#1080#1095
  end
  object edtLogin: TEdit
    Left = 120
    Top = 72
    Width = 240
    Height = 21
    TabOrder = 1
  end
  object edtPassword: TEdit
    Left = 120
    Top = 108
    Width = 240
    Height = 21
    PasswordChar = '*'
    TabOrder = 2
  end
  object btnOk: TButton
    Left = 120
    Top = 160
    Width = 90
    Height = 25
    Caption = #1042#1093#1086#1076
    Default = True
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 230
    Top = 160
    Width = 90
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 4
    OnClick = btnCancelClick
  end
end
