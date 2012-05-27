object FArchivator: TFArchivator
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = #1040#1088#1093#1080#1074#1072#1090#1086#1088
  ClientHeight = 154
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
    Left = 367
    Top = 33
    Width = 114
    Height = 22
    Caption = #1040#1088#1093#1080#1074#1080#1088#1086#1074#1072#1090#1100
    OnClick = btn_SaveClick
    SkinData.SkinSection = 'SPEEDBUTTON'
  end
  object btn_cancel: TsSpeedButton
    Left = 487
    Top = 33
    Width = 82
    Height = 22
    Caption = #1054#1090#1084#1077#1085#1072
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
    Top = 59
    Width = 561
    Height = 86
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object prb_compress: TProgressBar
    Left = 8
    Top = 34
    Width = 353
    Height = 20
    TabOrder = 1
  end
  object ZLib: TJvZlibMultiple
    OnProgress = ZLibProgress
    Left = 464
    Top = 16
  end
end
