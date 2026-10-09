object FormStockReport: TFormStockReport
  Left = 200
  Top = 120
  Width = 780
  Height = 480
  Caption = #1054#1089#1090#1072#1090#1082#1080' '#1085#1072' '#1089#1082#1083#1072#1076#1072#1093
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
    Width = 772
    Height = 41
    Align = alTop
    TabOrder = 0
    object btnRefresh: TButton
      Left = 8
      Top = 8
      Width = 90
      Height = 25
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      TabOrder = 0
      OnClick = btnRefreshClick
    end
    object btnPrint: TButton
      Left = 104
      Top = 8
      Width = 120
      Height = 25
      Caption = #1055#1077#1095#1072#1090#1100' '#1086#1090#1095#1105#1090
      TabOrder = 1
      OnClick = btnPrintClick
    end
    object chkDetail: TCheckBox
      Left = 248
      Top = 12
      Width = 200
      Height = 17
      Caption = #1044#1077#1090#1072#1083#1080#1079#1072#1094#1080#1103' '#1087#1086' '#1103#1095#1077#1081#1082#1072#1084
      TabOrder = 2
      OnClick = btnRefreshClick
    end
  end
  object Grid: TDBGrid
    Left = 0
    Top = 41
    Width = 772
    Height = 412
    Align = alClient
    DataSource = ds
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = RUSSIAN_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object qry: TADOQuery
    CursorType = ctStatic
    LockType = ltReadOnly
    Parameters = <>
    Left = 400
    Top = 8
  end
  object ds: TDataSource
    DataSet = qry
    Left = 448
    Top = 8
  end
  object qr: TQuickRep
    Left = 520
    Top = 80
    Width = 794
    Height = 1123
    Frame.Color = clBlack
    Frame.DrawTop = False
    Frame.DrawBottom = False
    Frame.DrawLeft = False
    Frame.DrawRight = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    Functions.Strings = (
      'PAGENUMBER'
      'COLUMNNUMBER'
      'REPORTTITLE')
    Functions.DATA = (
      '0'
      '0'
      #39#39)
    Options = [FirstPageHeader, LastPageFooter]
    Page.Columns = 1
    Page.Orientation = poPortrait
    Page.PaperSize = A4
    Page.Values = (
      100
      2970
      100
      2100
      100
      100
      0)
    PrinterSettings.Copies = 1
    PrinterSettings.Duplex = False
    PrinterSettings.FirstPage = 0
    PrinterSettings.LastPage = 0
    PrinterSettings.OutputBin = Auto
    PrintIfEmpty = True
    SnapToGrid = True
    Units = MM
    Zoom = 100
    object QRBandTitle: TQRBand
      Left = 38
      Top = 38
      Width = 718
      Height = 40
      Frame.Color = clBlack
      Frame.DrawTop = False
      Frame.DrawBottom = False
      Frame.DrawLeft = False
      Frame.DrawRight = False
      AlignToBottom = False
      Color = clWhite
      ForceNewColumn = False
      ForceNewPage = False
      Size.Values = (
        105.833333333333
        1899.70833333333)
      BandType = rbTitle
      object QRLabelTitle: TQRLabel
        Left = 16
        Top = 8
        Width = 300
        Height = 20
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          52.9166666666667
          42.3333333333333
          21.1666666666667
          793.75)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = True
        AutoStretch = False
        Caption = #1054#1089#1090#1072#1090#1082#1080' '#1084#1072#1090#1077#1088#1080#1072#1083#1086#1074' '#1085#1072' '#1089#1082#1083#1072#1076#1072#1093
        Color = clWhite
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = False
        WordWrap = True
        FontSize = 12
      end
    end
    object QRBandHeader: TQRBand
      Left = 38
      Top = 78
      Width = 718
      Height = 24
      Frame.Color = clBlack
      Frame.DrawTop = False
      Frame.DrawBottom = True
      Frame.DrawLeft = False
      Frame.DrawRight = False
      AlignToBottom = False
      Color = clWhite
      ForceNewColumn = False
      ForceNewPage = False
      Size.Values = (
        63.5
        1899.70833333333)
      BandType = rbColumnHeader
      object QRLabelWh: TQRLabel
        Left = 16
        Top = 4
        Width = 40
        Height = 17
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          44.9791666666667
          42.3333333333333
          10.5833333333333
          105.833333333333)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = True
        AutoStretch = False
        Caption = #1057#1082#1083#1072#1076
        Color = clWhite
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = False
        WordWrap = True
        FontSize = 10
      end
      object QRLabelMat: TQRLabel
        Left = 220
        Top = 4
        Width = 60
        Height = 17
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          44.9791666666667
          582.083333333333
          10.5833333333333
          158.75)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = True
        AutoStretch = False
        Caption = #1052#1072#1090#1077#1088#1080#1072#1083
        Color = clWhite
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = False
        WordWrap = True
        FontSize = 10
      end
      object QRLabelQty: TQRLabel
        Left = 520
        Top = 4
        Width = 70
        Height = 17
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          44.9791666666667
          1375.83333333333
          10.5833333333333
          185.208333333333)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = True
        AutoStretch = False
        Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086
        Color = clWhite
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = False
        WordWrap = True
        FontSize = 10
      end
    end
    object QRBandDetail: TQRBand
      Left = 38
      Top = 102
      Width = 718
      Height = 20
      Frame.Color = clBlack
      Frame.DrawTop = False
      Frame.DrawBottom = False
      Frame.DrawLeft = False
      Frame.DrawRight = False
      AlignToBottom = False
      Color = clWhite
      ForceNewColumn = False
      ForceNewPage = False
      Size.Values = (
        52.9166666666667
        1899.70833333333)
      BandType = rbDetail
      object QRDBWh: TQRDBText
        Left = 16
        Top = 2
        Width = 180
        Height = 17
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          44.9791666666667
          42.3333333333333
          5.29166666666667
          476.25)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Color = clWhite
        DataField = 'WarehouseName'
        Transparent = False
        WordWrap = True
        FontSize = 10
      end
      object QRDBMat: TQRDBText
        Left = 220
        Top = 2
        Width = 280
        Height = 17
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          44.9791666666667
          582.083333333333
          5.29166666666667
          740.833333333333)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Color = clWhite
        DataField = 'MaterialName'
        Transparent = False
        WordWrap = True
        FontSize = 10
      end
      object QRDBQty: TQRDBText
        Left = 520
        Top = 2
        Width = 80
        Height = 17
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          44.9791666666667
          1375.83333333333
          5.29166666666667
          211.666666666667)
        Alignment = taRightJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Color = clWhite
        DataField = 'Qty'
        Transparent = False
        WordWrap = True
        FontSize = 10
      end
    end
  end
end
