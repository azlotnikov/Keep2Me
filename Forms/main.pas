unit main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  mons,
  JvExControls,
  JvSpeedButton,
  JvExStdCtrls,
  JvButton,
  JvCtrls,
  Vcl.ImgList,
  JvImageList,
  acAlphaImageList,
  Vcl.Buttons,
  sSpeedButton,
  funcs,
  loaders,
  JvComponentBase,
  JvTrayIcon,
  myhotkeys,
  inifiles,
  Vcl.Menus,
  Vcl.ExtCtrls,
  f_points,
  f_image,
  Vcl.Clipbrd,
  f_about,
  Winapi.ShellAPI,
  shortlinks,
  IdHTTP,
  unitIsAdmin,
  IdBaseComponent,
  IdAntiFreezeBase,
  Vcl.IdAntiFreeze,
  f_windows,
  f_selfield,
  Vcl.ComCtrls,
  sPageControl,
  pastebin_tools,
  f_pastebin,
  cript;

type
  TFMain = class(TForm)
    Pages: TsPageControl;
    pg_main: TsTabSheet;
    grp_Monitors: TGroupBox;
    btn_RefreshMonitors: TsSpeedButton;
    btn_GetCurrentMonitor: TsSpeedButton;
    cbb_Monitors: TComboBox;
    grp_HotKey: TGroupBox;
    lbl_HotKeysActions: TLabel;
    cbb_HotKeysActions: TComboBox;
    cb_CtrlKey: TCheckBox;
    cb_AltKey: TCheckBox;
    cbb_HotKeys: TComboBox;
    cb_ShiftKey: TCheckBox;
    cb_WinKey: TCheckBox;
    grp_Hostings: TGroupBox;
    cbb_Hostings: TComboBox;
    grp_ShortLink: TGroupBox;
    cbb_ShortLink: TComboBox;
    grp_OtherSettings: TGroupBox;
    lbl_ImgExt: TLabel;
    cb_ShowInTray: TCheckBox;
    cb_HideLoadForm: TCheckBox;
    cb_CopyLink: TCheckBox;
    cbb_ImgExt: TComboBox;
    cb_AutoStart: TCheckBox;
    Images: TsAlphaImageList;
    TrayIcon: TJvTrayIcon;
    pm: TPopupMenu;
    pm_SelectScreen: TMenuItem;
    pm_BufferSend: TMenuItem;
    pm_SelectWindow: TMenuItem;
    pm_Sep1: TMenuItem;
    pm_RecentLoads: TMenuItem;
    pm_Settings: TMenuItem;
    pm_Sep2: TMenuItem;
    pm_CheckUpdates: TMenuItem;
    pm_About: TMenuItem;
    pm_exit: TMenuItem;
    tmr_ExitFromThread: TTimer;
    AntiFreeze: TIdAntiFreeze;
    pg_pastebin: TsTabSheet;
    grp_pb_account: TGroupBox;
    rb_pb_anon: TRadioButton;
    rb_pb_account: TRadioButton;
    edt_pb_login: TEdit;
    lbl_pb_login: TLabel;
    edt_pb_pass: TEdit;
    lbl_pb_pass: TLabel;
    grp_pb_defsets: TGroupBox;
    cbb_pb_deflang: TComboBox;
    lbl_pb_deflang: TLabel;
    cbb_pb_expire: TComboBox;
    lbl_pb_expire: TLabel;
    cbb_pb_private: TComboBox;
    lbl_pb_private: TLabel;
    btn_ApplySettings: TsSpeedButton;
    grp_pb_other: TGroupBox;
    cb_pb_copylink: TCheckBox;
    pm_pastebin: TMenuItem;
    cb_EnableKey: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btn_GetCurrentMonitorClick(Sender: TObject);
    procedure btn_RefreshMonitorsClick(Sender: TObject);
    procedure cbb_HotKeysActionsChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure pm_exitClick(Sender: TObject);
    procedure btn_ApplySettingsClick(Sender: TObject);
    procedure DoScreenSelect(Sender: TObject);
    procedure DoBufferSend(Sender: TObject);
    procedure cb_CtrlKeyClick(Sender: TObject);
    procedure cb_AltKeyClick(Sender: TObject);
    procedure cb_ShiftKeyClick(Sender: TObject);
    procedure cbb_HotKeysChange(Sender: TObject);
    procedure pm_SettingsClick(Sender: TObject);
    procedure pm_AboutClick(Sender: TObject);
    procedure cb_WinKeyClick(Sender: TObject);
    procedure pm_CheckUpdatesClick(Sender: TObject);
    procedure ExitKeep;
    procedure tmr_ExitFromThreadTimer(Sender: TObject);
    procedure DoWindowSelect(Sender: TObject);
    procedure rb_pb_accountClick(Sender: TObject);
    procedure rb_pb_anonClick(Sender: TObject);
    procedure DoPastebin(Sender: TObject);
    procedure cb_EnableKeyClick(Sender: TObject);
    procedure DoShowSettings(Sender: TObject);
  private
    tmpHotKeys: array of THotKeyAction;
    procedure InitMonitors;
    procedure WMHotKey(var Msg: TWMHotKey); message WM_HOTKEY;
    procedure SaveSettings;
    procedure LoadSettings;
    procedure GetSettings;
    procedure ApplySettings;
    procedure UpdateRecentFiles(Sender: TObject);
    procedure OnRecentFileClick(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.dfm}

procedure TFMain.ApplySettings;
var
  i: Integer;
begin
  with GSettings do
  begin
    cbb_Monitors.ItemIndex := MonIndex;
    cbb_Hostings.ItemIndex := LoaderIndex;
    cbb_ShortLink.ItemIndex := ShortLinkIndex;
    cb_AutoStart.Checked := AutoStart;
    cb_HideLoadForm.Checked := HideLoadForm;
    cb_ShowInTray.Checked := ShowInTray;
    cb_CopyLink.Checked := CopyLink;
    cbb_ImgExt.ItemIndex := ImgExtIndex;
    SetLength(tmpHotKeys, Length(Actions));
    for i := 0 to High(Actions) do
      tmpHotKeys[i] := Actions[i];
    with Pastebin do
    begin
      rb_pb_anon.Checked := Anon;
      rb_pb_account.Checked := not Anon;
      edt_pb_login.Text := Login;
      edt_pb_pass.Text := Password;
      cbb_pb_deflang.ItemIndex := SyntaxIndex;
      cbb_pb_expire.ItemIndex := ExpireIndex;
      cbb_pb_private.ItemIndex := PrivateIndex;
      cb_pb_copylink.Checked := CopyLink;
    end;
    Autorun(AutoStart, 'Keep2Me', ParamStr(0));
  end;
end;

procedure TFMain.btn_ApplySettingsClick(Sender: TObject);
begin
  GetSettings;
  SaveSettings;
  Hide;
end;

procedure TFMain.btn_GetCurrentMonitorClick(Sender: TObject);
begin
  cbb_Monitors.ItemIndex := MonitorManager.GetMonitorByPoint
    (Point(self.Left, self.Top));
end;

procedure TFMain.btn_RefreshMonitorsClick(Sender: TObject);
begin
  InitMonitors;
end;

procedure TFMain.cbb_HotKeysActionsChange(Sender: TObject);
begin
  cb_CtrlKey.Checked := tmpHotKeys[cbb_HotKeysActions.ItemIndex].Ctrl;
  cb_AltKey.Checked := tmpHotKeys[cbb_HotKeysActions.ItemIndex].Alt;
  cb_ShiftKey.Checked := tmpHotKeys[cbb_HotKeysActions.ItemIndex].Shift;
  cbb_HotKeys.ItemIndex := tmpHotKeys[cbb_HotKeysActions.ItemIndex].Key;
  cb_WinKey.Checked := tmpHotKeys[cbb_HotKeysActions.ItemIndex].Win;
  cb_EnableKey.Checked := tmpHotKeys[cbb_HotKeysActions.ItemIndex].Enabled;
end;

procedure TFMain.cbb_HotKeysChange(Sender: TObject);
begin
  tmpHotKeys[cbb_HotKeysActions.ItemIndex].Key := cbb_HotKeys.ItemIndex;
end;

procedure TFMain.cb_AltKeyClick(Sender: TObject);
begin
  tmpHotKeys[cbb_HotKeysActions.ItemIndex].Alt := cb_AltKey.Checked;
end;

procedure TFMain.cb_CtrlKeyClick(Sender: TObject);
begin
  tmpHotKeys[cbb_HotKeysActions.ItemIndex].Ctrl := cb_CtrlKey.Checked;
end;

procedure TFMain.cb_EnableKeyClick(Sender: TObject);
begin
  tmpHotKeys[cbb_HotKeysActions.ItemIndex].Enabled := cb_EnableKey.Checked;
  cb_ShiftKey.Enabled := cb_EnableKey.Checked;
  cb_WinKey.Enabled := cb_EnableKey.Checked;
  cb_CtrlKey.Enabled := cb_EnableKey.Checked;
  cb_AltKey.Enabled := cb_EnableKey.Checked;
  cbb_HotKeys.Enabled := cb_EnableKey.Checked;
end;

procedure TFMain.cb_ShiftKeyClick(Sender: TObject);
begin
  tmpHotKeys[cbb_HotKeysActions.ItemIndex].Shift := cb_ShiftKey.Checked;
end;

procedure TFMain.cb_WinKeyClick(Sender: TObject);
begin
  tmpHotKeys[cbb_HotKeysActions.ItemIndex].Win := cb_WinKey.Checked;
end;

procedure CheckUpdates(OnRun: Integer);
var
  HTTP: tidhttp;
  s: string;
begin
  s := '';
  HTTP := tidhttp.Create(nil);
  HTTP.Request.UserAgent :=
    'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)';
  try
    s := HTTP.Get('http://keep2.me/lastversion.php');
  except
  end;
  if (Length(s) = 0) and (OnRun = 0) then
    ShowMessage('Ошибка соедниния с сервером');
  if (Length(s) > 0) and (s <> KEEP_VERSION) then
  begin
    if MessageDlg('Доступно обновление ' + s + ' (ваша версия: ' + KEEP_VERSION
      + '). Обновить программу?', mtConfirmation, mbYesNo, 0) <> mrYes then
    begin
      HTTP.Free;
      exit;
    end;
    if not FileExists(ExtractFilePath(ParamStr(0)) + 'updater.exe') then
    begin
      ShowMessage('Ошибка: Не удалось найти updater.exe');
      exit;
    end;
    RunMeAsAdmin(GetDesktopWindow,
      PChar(ExtractFilePath(ParamStr(0)) + 'updater.exe'), '');
    HTTP.Free;
    FMain.tmr_ExitFromThread.Enabled := true;
  end
  else if OnRun = 0 then
  begin
    ShowMessage('У вас актуальная версия');
    HTTP.Free;
  end;
end;

procedure TFMain.DoBufferSend(Sender: TObject);
begin
  if (Clipboard.HasFormat(CF_BITMAP)) or (Clipboard.HasFormat(CF_PICTURE)) then
  begin
    with TFImage.Create(nil) do
    begin
      img.Picture.Assign(Clipboard);
      OriginImg.Assign(Clipboard);
      Show;
    end;
  end
  else
    TrayIcon.BalloonHint('Keep2Me', 'Содержимое не является изображением');
end;

procedure TFMain.DoPastebin(Sender: TObject);
begin
  with TFPasteBin.Create(nil) do
    Show;
end;

procedure TFMain.DoScreenSelect(Sender: TObject);
begin
  MinimizeAllForms;
  FSelField.AlphaBlend := true;
  FPoints.Show;
end;

procedure TFMain.DoShowSettings(Sender: TObject);
begin
  Show;
end;

procedure TFMain.DoWindowSelect(Sender: TObject);
begin
  TrayIcon.BalloonHint('Подсказка',
    'ПКМ - подсветить окно, ЛКМ - сделать скриншот окна');
  FSelField.AlphaBlend := false;
  FWindows.StartSelect;
  FWindows.Show;
end;

procedure TFMain.ExitKeep;
var
  i: Integer;
begin
  for i := 0 to High(GSettings.Actions) do
    UnRegisterMyHotKey(@GSettings.Actions[i], self.Handle);
  Hide;
  Application.Terminate;
  halt(0);
end;

procedure TFMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := false;
  LoadSettings;
  Hide;
end;

procedure TFMain.FormCreate(Sender: TObject);
var
  i: Integer;
  id: longword;
begin
  if (not IsUserAnAdmin) then
    ShowMessage
      ('Для корректной работы программы необходимы права Администратора');
  ForceDirectories(ExtractFilePath(ParamStr(0)) + 'tmpImg\');
  GSettings.TrayIcon := TrayIcon;
  GSettings.UpdateRecentFiles := UpdateRecentFiles;
  LoadRecentFiles;
  if FileExists(ExtractFilePath(ParamStr(0)) + SETTINGS_FILE_NAME) and
    not((ParamCount > 0) and (ParamStr(1) = 'SHOWSETTINGS')) then
    Visible := false
  else
    Visible := true;
  for i := Ord(Low(TImgFormats)) to Ord(High(TImgFormats)) do
    cbb_ImgExt.Items.Add(ImgFormatToText(TImgFormats(i)));
  cbb_ImgExt.ItemIndex := 0;
  AddHotKeyAction(true, 'Выделить область экрана', true, true, false, false, 5,
    DoScreenSelect);
  AddHotKeyAction(false, 'Отправить из буфера обмена', true, true, false, false,
    6, DoBufferSend);
  AddHotKeyAction(false, 'Отправить скриншот окна', true, true, false, false, 7,
    DoWindowSelect);
  AddHotKeyAction(true, 'Отправить на Pastebin.com', true, true, true, false, 8,
    DoPastebin);
  AddHotKeyAction(false, 'Показать настройки', true, true, false, false, 9,
    DoShowSettings);
  MonitorManager := TMonitorManager.Create;
  InitMonitors;
  for i := 0 to High(LoadersArray) do
    cbb_Hostings.Items.Add(LoadersArray[i].C);
  cbb_Hostings.ItemIndex := 0;
  cbb_ShortLink.Items.Add('Нет');
  for i := 0 to High(ShortersArray) do
    cbb_ShortLink.Items.Add(ShortersArray[i].C);
  cbb_ShortLink.ItemIndex := 0;
  for i := 0 to High(HotKeysArray) do
    cbb_HotKeys.Items.Add(HotKeysArray[i].Caption);
  cbb_HotKeys.ItemIndex := 0;
  for i := 0 to High(GSettings.Actions) do
    cbb_HotKeysActions.Items.Add(GSettings.Actions[i].Caption);
  for i := 0 to High(PastebinLangs) do
    cbb_pb_deflang.Items.Add(PastebinLangs[i].Caption);
  for i := 0 to High(PastebinExpires) do
    cbb_pb_expire.Items.Add(PastebinExpires[i].Caption);
  for i := 0 to High(PastebinPrivates) do
    cbb_pb_private.Items.Add(PastebinPrivates[i].Caption);
  cbb_HotKeysActions.ItemIndex := 0;
  LoadSettings;
  ApplySettings;
  for i := 0 to High(GSettings.Actions) do
    RegisterMyHotKey(@GSettings.Actions[i], self.Handle, i);
  cbb_HotKeysActionsChange(self);
  UpdateRecentFiles(self);
  beginthread(nil, 0, Addr(CheckUpdates), ptr(1), 0, id);
end;

procedure TFMain.GetSettings;
var
  i: Integer;
begin
  with GSettings do
  begin
    MonIndex := cbb_Monitors.ItemIndex;
    LoaderIndex := cbb_Hostings.ItemIndex;
    ShortLinkIndex := cbb_ShortLink.ItemIndex;
    AutoStart := cb_AutoStart.Checked;
    HideLoadForm := cb_HideLoadForm.Checked;
    ShowInTray := cb_ShowInTray.Checked;
    CopyLink := cb_CopyLink.Checked;
    ImgExtIndex := cbb_ImgExt.ItemIndex;
    SetLength(Actions, Length(tmpHotKeys));
    for i := 0 to High(tmpHotKeys) do
      Actions[i] := tmpHotKeys[i];
    with Pastebin do
    begin
      Anon := rb_pb_anon.Checked;
      Login := edt_pb_login.Text;
      Password := edt_pb_pass.Text;
      SyntaxIndex := cbb_pb_deflang.ItemIndex;
      ExpireIndex := cbb_pb_expire.ItemIndex;
      PrivateIndex := cbb_pb_private.ItemIndex;
      CopyLink := cb_pb_copylink.Checked;
    end;

  end;
end;

procedure TFMain.InitMonitors;
var
  t: TStringList;
  i: Integer;
begin
  cbb_Monitors.Clear;
  t := MonitorManager.GetCaptions;
  for i := 0 to t.Count - 1 do
    cbb_Monitors.Items.Add(t[i]);
  cbb_Monitors.ItemIndex := 0;
  t.Free;
end;

procedure TFMain.LoadSettings;
var
  F: TIniFile;
  i: Integer;
begin
  F := TIniFile.Create(ExtractFilePath(ParamStr(0)) + SETTINGS_FILE_NAME);
  with F, GSettings do
  begin
    MonIndex := ReadInteger('CommonSettings', 'MonitorIndex', 0);
    LoaderIndex := ReadInteger('CommonSettings', 'LoaderIndex', 0);
    ShortLinkIndex := ReadInteger('CommonSettings', 'ShortLinkIndex', 0);
    AutoStart := ReadBool('CommonSettings', 'AutoStart', false);
    ShowInTray := ReadBool('CommonSettings', 'ShowInTray', true);
    HideLoadForm := ReadBool('CommonSettings', 'HideLoadForm', false);
    CopyLink := ReadBool('CommonSettings', 'CopyLink', true);
    ImgExtIndex := ReadInteger('CommonSettings', 'ImgExtIndex', 1);
    for i := 0 to High(Actions) do
      with Actions[i] do
      begin
        Enabled := ReadBool('HotKeys' + inttostr(i), 'Enabled', Enabled);
        Key := ReadInteger('HotKeys' + inttostr(i), 'Key', Key);
        Ctrl := ReadBool('HotKeys' + inttostr(i), 'Ctrl', Ctrl);
        Alt := ReadBool('HotKeys' + inttostr(i), 'Alt', Alt);
        Shift := ReadBool('HotKeys' + inttostr(i), 'Shift', Shift);
        Win := ReadBool('HotKeys' + inttostr(i), 'Win', Win);
      end;
    with Pastebin do
    begin
      Anon := ReadBool('Pastebin', 'Anonimous', true);
      Login := MyDecrypt(ReadString('Pastebin', 'Login', ''), CRYPT_KEY);
      Password := MyDecrypt(ReadString('Pastebin', 'Password', ''), CRYPT_KEY);
      SyntaxIndex := ReadInteger('Pastebin', 'SyntaxIndex', 0);
      ExpireIndex := ReadInteger('Pastebin', 'ExpireIndex', 0);
      PrivateIndex := ReadInteger('Pastebin', 'PrivateIndex', 0);
      CopyLink := ReadBool('Pastebin', 'CopyLink', true);
    end;
    Free;
  end;
end;

procedure TFMain.OnRecentFileClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open',
    PChar(GSettings.RecentFiles[(Sender as TMenuItem).Tag].Link), nil,
    nil, SW_SHOW);
end;

procedure TFMain.pm_AboutClick(Sender: TObject);
begin
  FAbout.Show;
end;

procedure TFMain.pm_CheckUpdatesClick(Sender: TObject);
var
  id: longword;
begin
  beginthread(nil, 0, Addr(CheckUpdates), ptr(0), 0, id);
end;

procedure TFMain.pm_exitClick(Sender: TObject);
begin
  ExitKeep;
end;

procedure TFMain.pm_SettingsClick(Sender: TObject);
begin
  Show;
  BringToFront;
end;

procedure TFMain.rb_pb_accountClick(Sender: TObject);
begin
  edt_pb_login.Enabled := rb_pb_account.Checked;
  edt_pb_pass.Enabled := rb_pb_account.Checked;
end;

procedure TFMain.rb_pb_anonClick(Sender: TObject);
begin
  edt_pb_login.Enabled := not rb_pb_anon.Checked;
  edt_pb_pass.Enabled := not rb_pb_anon.Checked;
end;

procedure TFMain.SaveSettings;
var
  F: TIniFile;
  i: Integer;
begin
  F := TIniFile.Create(ExtractFilePath(ParamStr(0)) + SETTINGS_FILE_NAME);
  with F, GSettings do
  begin
    WriteInteger('CommonSettings', 'MonitorIndex', MonIndex);
    WriteInteger('CommonSettings', 'LoaderIndex', LoaderIndex);
    WriteInteger('CommonSettings', 'ShortLinkIndex', ShortLinkIndex);
    WriteBool('CommonSettings', 'AutoStart', AutoStart);
    WriteBool('CommonSettings', 'ShowInTray', ShowInTray);
    WriteBool('CommonSettings', 'HideLoadForm', HideLoadForm);
    WriteBool('CommonSettings', 'CopyLink', CopyLink);
    WriteInteger('CommonSettings', 'ImgExtIndex', ImgExtIndex);
    WriteInteger('HotKeys', 'KeyHigh', High(Actions));
    for i := 0 to High(Actions) do
      with Actions[i] do
      begin
        WriteInteger('HotKeys' + inttostr(i), 'Key', Key);
        WriteBool('HotKeys' + inttostr(i), 'Ctrl', Ctrl);
        WriteBool('HotKeys' + inttostr(i), 'Alt', Alt);
        WriteBool('HotKeys' + inttostr(i), 'Shift', Shift);
        WriteBool('HotKeys' + inttostr(i), 'Win', Win);
        WriteBool('HotKeys' + inttostr(i), 'Enabled', Enabled);
      end;
    with Pastebin do
    begin
      WriteBool('Pastebin', 'Anonimous', Anon);
      WriteString('Pastebin', 'Login', MyEncrypt(Login, CRYPT_KEY));
      WriteString('Pastebin', 'Password', MyEncrypt(Password, CRYPT_KEY));
      WriteInteger('Pastebin', 'SyntaxIndex', SyntaxIndex);
      WriteInteger('Pastebin', 'ExpireIndex', ExpireIndex);
      WriteInteger('Pastebin', 'PrivateIndex', PrivateIndex);
      WriteBool('Pastebin', 'CopyLink', CopyLink);
    end;
    Free;
  end;
  for i := 0 to High(GSettings.Actions) do
    UnRegisterMyHotKey(@GSettings.Actions[i], self.Handle);
  for i := 0 to High(GSettings.Actions) do
    RegisterMyHotKey(@GSettings.Actions[i], self.Handle, i);
end;

procedure TFMain.tmr_ExitFromThreadTimer(Sender: TObject);
begin
  ExitKeep;
end;

procedure TFMain.UpdateRecentFiles(Sender: TObject);
var
  i: Integer;
  M: TMenuItem;
begin
  for i := 0 to pm_RecentLoads.Count - 1 do
    pm_RecentLoads.Delete(0);
  for i := 0 to High(GSettings.RecentFiles) do
  begin
    M := TMenuItem.Create(pm_RecentLoads);
    M.Caption := GSettings.RecentFiles[i].Caption;
    M.OnClick := OnRecentFileClick;
    M.Tag := i;
    case GSettings.RecentFiles[i].LType of
      rfImg:
        M.ImageIndex := 10;
      rfText:
        M.ImageIndex := 12;
    end;
    pm_RecentLoads.Insert(0, M);
  end;
end;

procedure TFMain.WMHotKey(var Msg: TWMHotKey);
var
  i: Integer;
begin
  for i := 0 to High(GSettings.Actions) do
    if GSettings.Actions[i].RegKey = Msg.hotkey then
      GSettings.Actions[i].Proc(self);
end;

end.
