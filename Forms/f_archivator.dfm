object FArchivator: TFArchivator
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = #1040#1088#1093#1080#1074#1072#1090#1086#1088
  ClientHeight = 137
  ClientWidth = 577
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btn_Save: TsSpeedButton
    Left = 455
    Top = 50
    Width = 114
    Height = 22
    Caption = #1040#1088#1093#1080#1074#1080#1088#1086#1074#1072#1090#1100
    OnClick = btn_SaveClick
    SkinData.SkinSection = 'SPEEDBUTTON'
  end
  object btn_cancel: TsSpeedButton
    Left = 455
    Top = 109
    Width = 114
    Height = 22
    Caption = #1054#1090#1084#1077#1085#1072
    SkinData.SkinSection = 'SPEEDBUTTON'
  end
  object btn_SaveAndLoad: TsSpeedButton
    Left = 455
    Top = 73
    Width = 114
    Height = 35
    Caption = #1040#1088#1093#1080#1074#1080#1088#1086#1074#1072#1090#1100#13#10#1080' '#1079#1072#1075#1088#1091#1079#1080#1090#1100
    OnClick = btn_SaveClick
    SkinData.SkinSection = 'SPEEDBUTTON'
  end
  object edt_savefile: TJvFilenameEdit
    Left = 8
    Top = 7
    Width = 561
    Height = 21
    Filter = 'Zip File (*.zip)|*.zip'
    TabOrder = 0
  end
  object mmo_files: TMemo
    Left = 8
    Top = 50
    Width = 441
    Height = 81
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object prb_compress: TProgressBar
    Left = 8
    Top = 31
    Width = 561
    Height = 15
    TabOrder = 1
  end
  object ZLib: TJvZlibMultiple
    OnProgress = ZLibProgress
    Left = 32
    Top = 80
  end
end
