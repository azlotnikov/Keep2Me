object FMain: TFMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Keep2Me Updater'
  ClientHeight = 159
  ClientWidth = 416
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbl_info: TLabel
    Left = 217
    Top = 12
    Width = 153
    Height = 39
    Alignment = taCenter
    Caption = 'Keep2Me '#1072#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080#13#10#1079#1072#1087#1091#1089#1090#1080#1090#1089#1103' '#1087#1086#1089#1083#1077' '#1079#1072#1074#1077#1088#1096#1077#1085#1080#1103#13#10#1086#1073#1085#1086#1074#1083#1077#1085#1080#1103'.'
  end
  object pb: TProgressBar
    Left = 15
    Top = 64
    Width = 386
    Height = 17
    TabOrder = 1
  end
  object cb_close: TCheckBox
    Left = 15
    Top = 39
    Width = 184
    Height = 19
    Caption = #1047#1072#1082#1088#1099#1090#1100' '#1087#1086#1089#1083#1077' '#1079#1072#1074#1077#1088#1096#1077#1085#1080#1103
    Checked = True
    State = cbChecked
    TabOrder = 0
  end
  object btn_update: TButton
    Left = 15
    Top = 8
    Width = 155
    Height = 25
    Caption = #1053#1072#1095#1072#1090#1100' '#1086#1073#1085#1086#1074#1083#1077#1085#1080#1077
    TabOrder = 2
    OnClick = btn_updateClick
  end
  object mmo_log: TMemo
    Left = 15
    Top = 87
    Width = 386
    Height = 64
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object AntiFreeze: TIdAntiFreeze
    Left = 303
    Top = 88
  end
  object HTTP: TIdHTTP
    OnWork = HTTPWork
    OnWorkBegin = HTTPWorkBegin
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 223
    Top = 88
  end
  object tmr_exit: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmr_exitTimer
    Left = 263
    Top = 88
  end
end
