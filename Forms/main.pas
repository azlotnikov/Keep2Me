unit main;

{ ***************************** }
{ Keep2Me }
{ Z.Razor }
{ 2012 }
{ ***************************** }

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellAPI,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.IniFiles,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ImgList,
  Vcl.Clipbrd,
  Vcl.Menus,
  Vcl.ExtCtrls,
  Vcl.IdAntiFreeze,
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ExtDlgs,
  Vcl.Imaging.GIFImg,
  Vcl.Imaging.PNGImage,
  Vcl.Imaging.JPEG,
  JvImageList,
  JvExControls,
  JvSpeedButton,
  JvExStdCtrls,
  JvButton,
  JvCtrls,
  JvComponentBase,
  JvTrayIcon,
  IdHTTP,
  IdBaseComponent,
  IdAntiFreezeBase,
  acAlphaImageList,
  sSpeedButton,
  sPageControl,
  f_points,
  f_image,
  f_about,
  f_windows,
  f_selfield,
  f_pastebin,
  f_files,
  funcs,
  loaders,
  myhotkeys,
  shortlinks,
  unitIsAdmin,
  mons,
  pastebin_tools,
  cript,
  ConstStrings,
  fileuploaders;

type
  TFMain = class(TForm)
    Pages: TsPageControl;
    pg_main: TsTabSheet;
    pg_pastebin: TsTabSheet;

    grp_pb_account: TGroupBox;
    grp_Monitors: TGroupBox;
    grp_HotKey: TGroupBox;
    grp_Hostings: TGroupBox;
    grp_ShortLink: TGroupBox;
    grp_pb_other: TGroupBox;
    grp_pb_defsets: TGroupBox;

    btn_ApplySettings: TsSpeedButton;
    btn_RefreshMonitors: TsSpeedButton;
    btn_GetCurrentMonitor: TsSpeedButton;

    cbb_Monitors: TComboBox;
    cbb_HotKeysActions: TComboBox;
    cbb_Hostings: TComboBox;
    cbb_ShortLink: TComboBox;
    cbb_HotKeys: TComboBox;
    cbb_pb_deflang: TComboBox;
    cbb_pb_private: TComboBox;
    cbb_pb_expire: TComboBox;

    lbl_HotKeysActions: TLabel;
    lbl_pb_login: TLabel;
    lbl_pb_pass: TLabel;
    lbl_pb_deflang: TLabel;
    lbl_pb_expire: TLabel;
    lbl_pb_private: TLabel;

    cb_CtrlKey: TCheckBox;
    cb_AltKey: TCheckBox;
    cb_ShiftKey: TCheckBox;
    cb_WinKey: TCheckBox;
    cb_pb_copylink: TCheckBox;
    cb_EnableKey: TCheckBox;

    tmr_ExitFromThread: TTimer;
    AntiFreeze: TIdAntiFreeze;
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
    pm_pastebin: TMenuItem;

    rb_pb_anon: TRadioButton;
    rb_pb_account: TRadioButton;

    edt_pb_login: TEdit;
    edt_pb_pass: TEdit;
    cb_pb_CloseAfterLoad: TCheckBox;
    mm_LoadImageFromFile: TMenuItem;
    OpenImageDlg: TOpenPictureDialog;
    btn_Cancel: TsSpeedButton;
    btn_ImgHostSettings: TsSpeedButton;
    btn_ShortLinkSettings: TsSpeedButton;
    btn_CheckHotKey: TsSpeedButton;
    pg_OtherSettings: TsTabSheet;
    grp_OtherSettings: TGroupBox;
    cb_ShowInTray: TCheckBox;
    cb_HideLoadForm: TCheckBox;
    cb_CopyLink: TCheckBox;
    cb_AutoStart: TCheckBox;
    cb_ShowAdmin: TCheckBox;
    cb_FastLoad: TCheckBox;
    cbb_ImgExt: TComboBox;
    lbl_ImgExt: TLabel;
    grp_files: TGroupBox;
    cbb_Files: TComboBox;
    btn_FilesSettings: TsSpeedButton;
    mm_filesfrombuf: TMenuItem;
    cb_OpenByTrayClick: TCheckBox;

    procedure FormCreate(Sender: TObject);

    procedure btn_GetCurrentMonitorClick(Sender: TObject);
    procedure btn_RefreshMonitorsClick(Sender: TObject);
    procedure btn_ApplySettingsClick(Sender: TObject);

    procedure cbb_HotKeysActionsChange(Sender: TObject);
    procedure cbb_HotKeysChange(Sender: TObject);

    procedure cb_CtrlKeyClick(Sender: TObject);
    procedure cb_AltKeyClick(Sender: TObject);
    procedure cb_ShiftKeyClick(Sender: TObject);
    procedure cb_EnableKeyClick(Sender: TObject);
    procedure cb_WinKeyClick(Sender: TObject);

    procedure pm_SettingsClick(Sender: TObject);
    procedure pm_AboutClick(Sender: TObject);
    procedure pm_CheckUpdatesClick(Sender: TObject);
    procedure pm_exitClick(Sender: TObject);

    procedure tmr_ExitFromThreadTimer(Sender: TObject);

    procedure rb_pb_accountClick(Sender: TObject);
    procedure rb_pb_anonClick(Sender: TObject);

    procedure DoShowSettings(Sender: TObject);
    procedure DoScreenSelect(Sender: TObject);
    procedure DoBufferSend(Sender: TObject);
    procedure DoPastebin(Sender: TObject);
    procedure DoWindowSelect(Sender: TObject);
    procedure DoOpenAndSendImage(Sender: TObject);
    procedure DoLoadFilesFromBuf(Sender: TObject);

    procedure ExitKeep;
    procedure FormShow(Sender: TObject);
    procedure btn_CancelClick(Sender: TObject);
    procedure btn_CheckHotKeyClick(Sender: TObject);
    procedure TrayIconClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TrayIconBalloonClick(Sender: TObject);
    procedure TrayIconBalloonShow(Sender: TObject);
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
    procedure UpdateActions;
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.dfm}

function BoolToCheckedAction(B: Boolean): String;
begin
  Result := '[  ]';
  if B then Result := '[*]';
end;

procedure TFMain.ApplySettings;
var
  i: Integer;
begin
  with GSettings do begin
    cbb_Monitors.ItemIndex := MonIndex;
    cbb_Hostings.ItemIndex := LoaderIndex;
    cbb_ShortLink.ItemIndex := ShortLinkIndex;
    cbb_Files.ItemIndex := FileLoaderIndex;
    cb_AutoStart.Checked := AutoStart;
    cb_HideLoadForm.Checked := HideLoadForm;
    cb_ShowInTray.Checked := ShowInTray;
    cb_CopyLink.Checked := CopyLink;
    cb_ShowAdmin.Checked := DontShowAdmin;
    cbb_ImgExt.ItemIndex := ImgExtIndex;
    cb_OpenByTrayClick.Checked := OpenLinksByClick;
    cb_FastLoad.Checked := FastLoad;
    SetLength(tmpHotKeys, Length(Actions));
    for i := 0 to High(Actions) do tmpHotKeys[i] := Actions[i];
    with Pastebin do begin
      rb_pb_anon.Checked := Anon;
      rb_pb_account.Checked := not Anon;
      edt_pb_login.Text := Login;
      edt_pb_pass.Text := Password;
      cbb_pb_deflang.ItemIndex := SyntaxIndex;
      cbb_pb_expire.ItemIndex := ExpireIndex;
      cbb_pb_private.ItemIndex := PrivateIndex;
      cb_pb_copylink.Checked := CopyLink;
      cb_pb_CloseAfterLoad.Checked := CloseForm;
    end;
    Autorun(AutoStart, SYS_KEEP2ME, ParamStr(0));
  end;
  UpdateActions;
end;

procedure TFMain.btn_ApplySettingsClick(Sender: TObject);
begin
  GetSettings;
  SaveSettings;
  Hide;
end;

procedure TFMain.btn_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFMain.btn_CheckHotKeyClick(Sender: TObject);
begin
  if CompareHotKeys(@tmpHotKeys[cbb_HotKeysActions.ItemIndex], @GSettings.Actions[cbb_HotKeysActions.ItemIndex]) then
  begin
    ShowMessage(RU_HOTKEYS_ARE_EQUAL);
    Exit;
  end;
  if RegisterMyHotKey(@tmpHotKeys[cbb_HotKeysActions.ItemIndex], self.Handle, cbb_HotKeysActions.ItemIndex, true) then
  begin
    UnRegisterMyHotKey(@tmpHotKeys[cbb_HotKeysActions.ItemIndex], self.Handle);
    ShowMessage(RU_HOTKEY_IS_FREE);
  end
  else ShowMessage(RU_HOTKEY_IS_BUSY);
end;

procedure TFMain.btn_GetCurrentMonitorClick(Sender: TObject);
begin
  cbb_Monitors.ItemIndex := MonitorManager.GetMonitorByPoint(Point(self.Left, self.Top));
end;

procedure TFMain.btn_RefreshMonitorsClick(Sender: TObject);
begin
  InitMonitors;
end;

procedure TFMain.cbb_HotKeysActionsChange(Sender: TObject);
begin
  with tmpHotKeys[cbb_HotKeysActions.ItemIndex] do begin
    cb_CtrlKey.Checked := Ctrl;
    cb_AltKey.Checked := Alt;
    cb_ShiftKey.Checked := Shift;
    cbb_HotKeys.ItemIndex := Key;
    cb_WinKey.Checked := Win;
    cb_EnableKey.Checked := Enabled;
  end;
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
  HTTP.Request.UserAgent := SYS_USERAGENT;
  try
    s := HTTP.Get(SYS_UPDATE_CHECK_PAGE);
  except
  end;
  if (Length(s) = 0) and (OnRun = 0) then ShowMessage(RU_SERVER_CONNECTION_ERROR);
  if (Length(s) > 0) and (s <> SYS_KEEP_VERSION) then begin

    if MessageDlg(Format(RU_UPDATE_AVAILABLE, [s, SYS_KEEP_VERSION]), mtConfirmation, mbYesNo, 0) <> mrYes then begin
      HTTP.Free;
      Exit;
    end;
    if not FileExists(ExtractFilePath(ParamStr(0)) + SYS_UPDATER_EXE_NAME) then begin
      ShowMessage(RU_ERROR_FIND_UPDATER + SYS_UPDATER_EXE_NAME);
      Exit;
    end;
    RunMeAsAdmin(GetDesktopWindow, PChar(ExtractFilePath(ParamStr(0)) + SYS_UPDATER_EXE_NAME), '');
    HTTP.Free;
    FMain.tmr_ExitFromThread.Enabled := true;
  end
  else if OnRun = 0 then begin
    ShowMessage(RU_UPTODATE_VERSION);
    HTTP.Free;
  end;
end;

procedure TFMain.DoBufferSend(Sender: TObject);
begin
  if (Clipboard.HasFormat(CF_BITMAP)) or (Clipboard.HasFormat(CF_PICTURE)) then begin
    with TFImage.Create(nil) do begin
      img.Picture.Assign(Clipboard);
      OriginImg.Assign(Clipboard);
      StartWork;
    end;
  end
  else TrayIcon.BalloonHint(SYS_KEEP2ME, RU_NOT_AN_IMAGE_CONTENT);
end;

procedure TFMain.DoLoadFilesFromBuf(Sender: TObject);
var
  f: THandle;
  buffer: Array [0 .. MAX_PATH] of Char;
  i, numFiles: Integer;
  T: Tstringlist;
begin
  Clipboard.Open;
  T := Tstringlist.Create;
  try
    f := Clipboard.GetAsHandle(CF_HDROP);
    If f <> 0 Then Begin
      numFiles := DragQueryFile(f, $FFFFFFFF, nil, 0);
      for i := 0 to numFiles - 1 do begin
        buffer[0] := #0;
        DragQueryFile(f, i, buffer, sizeof(buffer));
        T.Add(buffer);
      end;
    end;
  finally
    Clipboard.Close;
    if T.Count > 0 then TFFiles.Create(nil).StartLoad(T)
    else begin
      T.Free;
      TrayIcon.BalloonHint(SYS_KEEP2ME, 'Содержимое буфера обмена не содержит файлов');
    end;
  end;
end;

procedure TFMain.DoOpenAndSendImage(Sender: TObject);
begin
  if OpenImageDlg.Execute then
    with TFImage.Create(nil) do
      try
        img.Picture.LoadFromFile(OpenImageDlg.FileName);
        StartWork;
      except
        On E: Exception do begin
          ShowMessage(RU_IMG_LOAD_ERROR + E.Message);
          Free;
        end;
      end;
end;

procedure TFMain.DoPastebin(Sender: TObject);
begin
  with TFPasteBin.Create(nil) do Show;
end;

procedure TFMain.DoScreenSelect(Sender: TObject);
begin
  MinimizeAllForms;
  // FSelField.AlphaBlend := true;
  TFPoints.Create(nil).Show;
end;

procedure TFMain.DoShowSettings(Sender: TObject);
begin
  Show;
end;

procedure TFMain.DoWindowSelect(Sender: TObject);
begin
  TrayIcon.BalloonHint(RU_HINT, RU_SELECTWINDOW_HINT);
  // FSelField.AlphaBlend := false;
  with TFWindows.Create(nil) do begin
    StartSelect;
    Show;
  end;
end;

procedure TFMain.ExitKeep;
var
  i: Integer;
begin
  for i := 0 to High(GSettings.Actions) do UnRegisterMyHotKey(@GSettings.Actions[i], self.Handle);
  halt(0);
end;

procedure TFMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := false;
  cbb_HotKeysActionsChange(self);
  Hide;
end;

procedure TFMain.FormCreate(Sender: TObject);
var
  i: Integer;
  id: longword;
begin
  ForceDirectories(ExtractFilePath(ParamStr(0)) + SYS_TMP_IMG_FOLDER);
  GSettings.TrayIcon := TrayIcon;
  GSettings.UpdateRecentFiles := UpdateRecentFiles;
  LoadRecentFiles;
  if FileExists(ExtractFilePath(ParamStr(0)) + SYS_SETTINGS_FILE_NAME) and
    not((ParamCount > 0) and (ParamStr(1) = SYS_SHOW_SETTINGS_PARAM)) then Visible := false
  else Visible := true;
  for i := Ord(Low(TImgFormats)) to Ord(High(TImgFormats)) do cbb_ImgExt.Items.Add(ImgFormatToText(TImgFormats(i)));
  AddHotKeyAction(true, RU_SELECT_SCREEN_PART, true, true, false, false, 4, DoScreenSelect);
  AddHotKeyAction(false, RU_SEND_FROM_BUFFER, true, true, false, false, 5, DoBufferSend);
  AddHotKeyAction(false, RU_SEND_WINDOW_SCREEN, true, true, false, false, 6, DoWindowSelect);
  AddHotKeyAction(true, RU_SEND_TO_PASTEBIN, true, true, true, false, 7, DoPastebin);
  AddHotKeyAction(false, RU_SHOW_SETTNGS, true, true, false, false, 8, DoShowSettings);
  AddHotKeyAction(false, RU_OPEN_IMAGE_AND_LOAD, true, true, false, false, 9, DoOpenAndSendImage);
  AddHotKeyAction(false, RU_LOAD_FILES_FROM_BUF, true, true, false, false, 10, DoLoadFilesFromBuf);
  MonitorManager := TMonitorManager.Create;
  InitMonitors;
  UpdateActions;
  cbb_ShortLink.Items.Add(RU_NO);
  for i := 0 to High(ShortersArray) do cbb_ShortLink.Items.Add(ShortersArray[i].Caption);
  for i := 0 to High(HotKeysArray) do cbb_HotKeys.Items.Add(HotKeysArray[i].Caption);
  for i := 0 to High(PastebinLangs) do cbb_pb_deflang.Items.Add(PastebinLangs[i].Caption);
  for i := 0 to High(PastebinExpires) do cbb_pb_expire.Items.Add(PastebinExpires[i].Caption);
  for i := 0 to High(PastebinPrivates) do cbb_pb_private.Items.Add(PastebinPrivates[i].Caption);
  for i := 0 to High(LoadersArray) do cbb_Hostings.Items.Add(LoadersArray[i].Caption);
  for i := 0 to High(FileLoadersArray) do cbb_Files.Items.Add(FileLoadersArray[i].Caption);
  LoadSettings;
  ApplySettings;
  for i := 0 to High(GSettings.Actions) do RegisterMyHotKey(@GSettings.Actions[i], self.Handle, i);
  cbb_HotKeysActionsChange(self);
  UpdateRecentFiles(self);
  beginthread(nil, 0, Addr(CheckUpdates), ptr(1), 0, id);
  if (not GSettings.DontShowAdmin) and (not IsUserAnAdmin) then ShowMessage(RU_NOT_ADMIN);
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  ApplySettings;
end;

procedure TFMain.GetSettings;
var
  i: Integer;
begin
  with GSettings do begin
    MonIndex := cbb_Monitors.ItemIndex;
    LoaderIndex := cbb_Hostings.ItemIndex;
    ShortLinkIndex := cbb_ShortLink.ItemIndex;
    FileLoaderIndex := cbb_Files.ItemIndex;
    AutoStart := cb_AutoStart.Checked;
    HideLoadForm := cb_HideLoadForm.Checked;
    ShowInTray := cb_ShowInTray.Checked;
    CopyLink := cb_CopyLink.Checked;
    DontShowAdmin := cb_ShowAdmin.Checked;
    ImgExtIndex := cbb_ImgExt.ItemIndex;
    OpenLinksByClick := cb_OpenByTrayClick.Checked;
    FastLoad := cb_FastLoad.Checked;
    SetLength(Actions, Length(tmpHotKeys));
    for i := 0 to High(tmpHotKeys) do Actions[i] := tmpHotKeys[i];
    with Pastebin do begin
      Anon := rb_pb_anon.Checked;
      Login := edt_pb_login.Text;
      Password := edt_pb_pass.Text;
      SyntaxIndex := cbb_pb_deflang.ItemIndex;
      ExpireIndex := cbb_pb_expire.ItemIndex;
      PrivateIndex := cbb_pb_private.ItemIndex;
      CopyLink := cb_pb_copylink.Checked;
      CloseForm := cb_pb_CloseAfterLoad.Checked;
    end;
  end;
end;

procedure TFMain.InitMonitors;
var
  T: Tstringlist;
begin
  cbb_Monitors.Clear;
  T := MonitorManager.GetCaptions;
  cbb_Monitors.Items.Assign(T);
  cbb_Monitors.ItemIndex := 0;
  T.Free;
end;

procedure TFMain.LoadSettings;
var
  f: TIniFile;
  i: Integer;
begin
  f := TIniFile.Create(ExtractFilePath(ParamStr(0)) + SYS_SETTINGS_FILE_NAME);
  with f, GSettings do begin
    MonIndex := ReadInteger(INI_COMMON_SETTINGS, 'MonitorIndex', 0);
    LoaderIndex := ReadInteger(INI_COMMON_SETTINGS, 'LoaderIndex', 0);
    ShortLinkIndex := ReadInteger(INI_COMMON_SETTINGS, 'ShortLinkIndex', 0);
    FileLoaderIndex := ReadInteger(INI_COMMON_SETTINGS, 'FileLoaderIndex', 0);
    AutoStart := ReadBool(INI_COMMON_SETTINGS, 'AutoStart', false);
    ShowInTray := ReadBool(INI_COMMON_SETTINGS, 'ShowInTray', true);
    HideLoadForm := ReadBool(INI_COMMON_SETTINGS, 'HideLoadForm', false);
    OpenLinksByClick := ReadBool(INI_COMMON_SETTINGS, 'OpenLinksByClick', true);
    CopyLink := ReadBool(INI_COMMON_SETTINGS, 'CopyLink', true);
    DontShowAdmin := ReadBool(INI_COMMON_SETTINGS, 'DontShowAdmin', false);
    FastLoad := ReadBool(INI_COMMON_SETTINGS, 'FastLoad', false);
    ImgExtIndex := ReadInteger(INI_COMMON_SETTINGS, 'ImgExtIndex', 1);
    for i := 0 to High(Actions) do
      with Actions[i] do begin
        Enabled := ReadBool(INI_HOT_KEYS + inttostr(i), 'Enabled', Enabled);
        Key := ReadInteger(INI_HOT_KEYS + inttostr(i), 'Key', Key);
        Ctrl := ReadBool(INI_HOT_KEYS + inttostr(i), 'Ctrl', Ctrl);
        Alt := ReadBool(INI_HOT_KEYS + inttostr(i), 'Alt', Alt);
        Shift := ReadBool(INI_HOT_KEYS + inttostr(i), 'Shift', Shift);
        Win := ReadBool(INI_HOT_KEYS + inttostr(i), 'Win', Win);
      end;
    with Pastebin do begin
      Anon := ReadBool(INI_PASTEBIN, 'Anonimous', true);
      Login := MyDecrypt(ReadString(INI_PASTEBIN, 'Login', ''), SYS_CRYPT_KEY);
      Password := MyDecrypt(ReadString(INI_PASTEBIN, 'Password', ''), SYS_CRYPT_KEY);
      SyntaxIndex := ReadInteger(INI_PASTEBIN, 'SyntaxIndex', 0);
      ExpireIndex := ReadInteger(INI_PASTEBIN, 'ExpireIndex', 0);
      PrivateIndex := ReadInteger(INI_PASTEBIN, 'PrivateIndex', 0);
      CopyLink := ReadBool(INI_PASTEBIN, 'CopyLink', true);
      CloseForm := ReadBool(INI_PASTEBIN, 'CloseForm', false);
    end;
    Free;
  end;
end;

procedure TFMain.OnRecentFileClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(GSettings.RecentFiles[(Sender as TMenuItem).Tag].Link), nil, nil, SW_SHOW);
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
  self.Show;
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
  f: TIniFile;
  i: Integer;
begin
  f := TIniFile.Create(ExtractFilePath(ParamStr(0)) + SYS_SETTINGS_FILE_NAME);
  with f, GSettings do begin
    WriteInteger(INI_COMMON_SETTINGS, 'MonitorIndex', MonIndex);
    WriteInteger(INI_COMMON_SETTINGS, 'LoaderIndex', LoaderIndex);
    WriteInteger(INI_COMMON_SETTINGS, 'ShortLinkIndex', ShortLinkIndex);
    WriteInteger(INI_COMMON_SETTINGS, 'FileLoaderIndex', FileLoaderIndex);
    WriteBool(INI_COMMON_SETTINGS, 'AutoStart', AutoStart);
    WriteBool(INI_COMMON_SETTINGS, 'ShowInTray', ShowInTray);
    WriteBool(INI_COMMON_SETTINGS, 'HideLoadForm', HideLoadForm);
    WriteBool(INI_COMMON_SETTINGS, 'CopyLink', CopyLink);
    WriteBool(INI_COMMON_SETTINGS, 'DontShowAdmin', DontShowAdmin);
    WriteBool(INI_COMMON_SETTINGS, 'OpenLinksByClick', OpenLinksByClick);
    WriteBool(INI_COMMON_SETTINGS, 'FastLoad', FastLoad);
    WriteInteger(INI_COMMON_SETTINGS, 'ImgExtIndex', ImgExtIndex);
    for i := 0 to High(Actions) do
      with Actions[i] do begin
        WriteInteger(INI_HOT_KEYS + inttostr(i), 'Key', Key);
        WriteBool(INI_HOT_KEYS + inttostr(i), 'Ctrl', Ctrl);
        WriteBool(INI_HOT_KEYS + inttostr(i), 'Alt', Alt);
        WriteBool(INI_HOT_KEYS + inttostr(i), 'Shift', Shift);
        WriteBool(INI_HOT_KEYS + inttostr(i), 'Win', Win);
        WriteBool(INI_HOT_KEYS + inttostr(i), 'Enabled', Enabled);
      end;
    with Pastebin do begin
      WriteBool(INI_PASTEBIN, 'Anonimous', Anon);
      WriteString(INI_PASTEBIN, 'Login', MyEncrypt(Login, SYS_CRYPT_KEY));
      WriteString(INI_PASTEBIN, 'Password', MyEncrypt(Password, SYS_CRYPT_KEY));
      WriteInteger(INI_PASTEBIN, 'SyntaxIndex', SyntaxIndex);
      WriteInteger(INI_PASTEBIN, 'ExpireIndex', ExpireIndex);
      WriteInteger(INI_PASTEBIN, 'PrivateIndex', PrivateIndex);
      WriteBool(INI_PASTEBIN, 'CopyLink', CopyLink);
      WriteBool(INI_PASTEBIN, 'CloseForm', CloseForm);
    end;
    Free;
  end;
  for i := 0 to High(GSettings.Actions) do UnRegisterMyHotKey(@GSettings.Actions[i], self.Handle);
  for i := 0 to High(GSettings.Actions) do RegisterMyHotKey(@GSettings.Actions[i], self.Handle, i);
end;

procedure TFMain.tmr_ExitFromThreadTimer(Sender: TObject);
begin
  ExitKeep;
end;

procedure TFMain.TrayIconBalloonClick(Sender: TObject);
begin
  if Pos('http', GSettings.LastLink) > 0 then
    if GSettings.OpenLinksByClick then ShellExecute(Handle, 'open', PChar(GSettings.LastLink), nil, nil, SW_SHOW);
end;

procedure TFMain.TrayIconBalloonShow(Sender: TObject);
begin
  if Pos('http', TrayIcon.Hint) > 0 then GSettings.LastLink := TrayIcon.Hint
  else GSettings.LastLink := '-1';
  TrayIcon.Hint := SYS_KEEP2ME;
end;

procedure TFMain.TrayIconClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then DoScreenSelect(self);
end;

procedure TFMain.UpdateActions;
var
  i: Integer;
begin
  cbb_HotKeysActions.Clear;
  with GSettings do
    for i := 0 to High(Actions) do
        cbb_HotKeysActions.Items.Add(BoolToCheckedAction(Actions[i].Enabled) + ' ' + Actions[i].Caption);
  cbb_HotKeysActions.ItemIndex := 0;
end;

procedure TFMain.UpdateRecentFiles(Sender: TObject);
var
  i: Integer;
  M: TMenuItem;
begin
  for i := 0 to pm_RecentLoads.Count - 1 do pm_RecentLoads.Delete(0);
  for i := 0 to High(GSettings.RecentFiles) do begin
    M := TMenuItem.Create(pm_RecentLoads);
    M.Caption := GSettings.RecentFiles[i].Caption;
    M.OnClick := OnRecentFileClick;
    M.Tag := i;
    case GSettings.RecentFiles[i].LType of
      rfImg: M.ImageIndex := 10;
      rfText: M.ImageIndex := 12;
      rfOther: M.ImageIndex := 18;
    end;
    pm_RecentLoads.Insert(0, M);
  end;
end;

procedure TFMain.WMHotKey(var Msg: TWMHotKey);
var
  i: Integer;
begin
  for i := 0 to High(GSettings.Actions) do
    if GSettings.Actions[i].RegKey = Msg.hotkey then GSettings.Actions[i].Proc(self);
end;

end.
