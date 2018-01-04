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
  Vcl.Imaging.PNGImage,
  Vcl.Imaging.JPEG,
  Vcl.Imaging.GIFImg,
  JvImageList,
  JvExControls,
  JvSpeedButton,
  JvExStdCtrls,
  JvButton,
  JvCtrls,
  JvComponentBase,
  JvTrayIcon,
  JvDialogs,
  IdHTTP,
  IdBaseComponent,
  IdAntiFreezeBase,
  acAlphaImageList,
  sSpeedButton,
  sPageControl,
  sComboBoxes,
  f_points,
  f_image,
  f_about,
  f_windows,
  f_selfield,
  f_pastebin,
  f_files,
  f_filessettings,
  f_load,
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
  published
    Pages                   : TsPageControl;
    pg_main                 : TsTabSheet;
    pg_pastebin             : TsTabSheet;
    grp_pb_account          : TGroupBox;
    grp_Monitors            : TGroupBox;
    grp_HotKey              : TGroupBox;
    grp_Hostings            : TGroupBox;
    grp_ShortLink           : TGroupBox;
    grp_pb_other            : TGroupBox;
    grp_pb_defsets          : TGroupBox;
    btn_ApplySettings       : TsSpeedButton;
    btn_RefreshMonitors     : TsSpeedButton;
    btn_GetCurrentMonitor   : TsSpeedButton;
    cbb_Monitors            : TComboBox;
    cbb_HotKeysActions      : TComboBox;
    cbb_Hostings            : TComboBox;
    cbb_ShortLink           : TComboBox;
    cbb_HotKeys             : TComboBox;
    cbb_pb_deflang          : TComboBox;
    cbb_pb_private          : TComboBox;
    cbb_pb_expire           : TComboBox;
    lbl_pb_login            : TLabel;
    lbl_pb_pass             : TLabel;
    lbl_pb_deflang          : TLabel;
    lbl_pb_expire           : TLabel;
    lbl_pb_private          : TLabel;
    cb_CtrlKey              : TCheckBox;
    cb_AltKey               : TCheckBox;
    cb_ShiftKey             : TCheckBox;
    cb_WinKey               : TCheckBox;
    cb_pb_copylink          : TCheckBox;
    cb_EnableKey            : TCheckBox;
    tmr_ExitFromThread      : TTimer;
    AntiFreeze              : TIdAntiFreeze;
    Images                  : TsAlphaImageList;
    TrayIcon                : TJvTrayIcon;
    pm                      : TPopupMenu;
    pm_SelectScreen         : TMenuItem;
    pm_BufferSend           : TMenuItem;
    pm_SelectWindow         : TMenuItem;
    pm_Sep1                 : TMenuItem;
    pm_RecentLoads          : TMenuItem;
    pm_Settings             : TMenuItem;
    pm_Sep2                 : TMenuItem;
    pm_CheckUpdates         : TMenuItem;
    pm_About                : TMenuItem;
    pm_exit                 : TMenuItem;
    pm_pastebin             : TMenuItem;
    rb_pb_anon              : TRadioButton;
    rb_pb_account           : TRadioButton;
    edt_pb_login            : TEdit;
    edt_pb_pass             : TEdit;
    cb_pb_CloseAfterLoad    : TCheckBox;
    pm_LoadImageFromFile    : TMenuItem;
    OpenImageDlg            : TOpenPictureDialog;
    btn_Cancel              : TsSpeedButton;
    btn_ImgHostSettings     : TsSpeedButton;
    btn_ShortLinkSettings   : TsSpeedButton;
    btn_CheckHotKey         : TsSpeedButton;
    pg_OtherSettings        : TsTabSheet;
    grp_OtherSettings       : TGroupBox;
    cb_ShowInTray           : TCheckBox;
    cb_HideLoadForm         : TCheckBox;
    cb_CopyLink             : TCheckBox;
    cb_AutoStart            : TCheckBox;
    cb_FastLoad             : TCheckBox;
    cbb_ImgExt              : TComboBox;
    lbl_ImgExt              : TLabel;
    grp_files               : TGroupBox;
    cbb_Files               : TComboBox;
    btn_FilesSettings       : TsSpeedButton;
    pm_filesfrombuf         : TMenuItem;
    cb_OpenByTrayClick      : TCheckBox;
    pg_FTP                  : TsTabSheet;
    cb_FTP_Img              : TCheckBox;
    cb_FTP_Files            : TCheckBox;
    grp_FTP_Settings        : TGroupBox;
    edt_FTP_host            : TEdit;
    lbl_FTP_host            : TLabel;
    edt_FTP_user            : TEdit;
    lbl_FTP_user            : TLabel;
    edt_FTP_pass            : TEdit;
    lbl_FTP_pass            : TLabel;
    edt_FTP_port            : TEdit;
    lbl_FTP_port            : TLabel;
    pm_ShortLinkFromBuf     : TMenuItem;
    edt_FTP_path            : TEdit;
    lbl_FTP_path            : TLabel;
    edt_FTP_URL             : TEdit;
    lbl_FTP_URL             : TLabel;
    cb_FTP_Passive          : TCheckBox;
    cb_ShowActionInTray     : TCheckBox;
    cb_shortlinkFiles       : TCheckBox;
    cb_shortlinkImg         : TCheckBox;
    cb_EditImageFromFile    : TCheckBox;
    Grp_SelType             : TGroupBox;
    rb_staticsel            : TRadioButton;
    Btn_AboutSel            : TsSpeedButton;
    rb_realtimesel          : TRadioButton;
    cbb_SelColor            : TsColorBox;
    Lbl_SelColor            : TLabel;
    OpenFileDlg             : TJvOpenDialog;
    pm_OpenAndLoadFile      : TMenuItem;
    grp_DelButtons          : TGroupBox;
    btn_ClearFormsSettings  : TsSpeedButton;
    btn_ClearMainSettings   : TsSpeedButton;
    btn_ClearPluginsSettings: TsSpeedButton;
    btn_ClearRecentFiles    : TsSpeedButton;
    cb_AutoCheckUpdate      : TCheckBox;

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
    procedure DoShortLinkFromBuf(Sender: TObject);
    procedure DoOpenAndLoadFile(Sender: TObject);
    procedure ExitKeep;
    procedure FormShow(Sender: TObject);
    procedure btn_CancelClick(Sender: TObject);
    procedure btn_CheckHotKeyClick(Sender: TObject);
    procedure TrayIconClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TrayIconBalloonClick(Sender: TObject);
    procedure TrayIconBalloonShow(Sender: TObject);
    procedure cb_FTP_ImgClick(Sender: TObject);
    procedure cb_FTP_FilesClick(Sender: TObject);
    procedure cbb_FilesChange(Sender: TObject);
    procedure btn_FilesSettingsClick(Sender: TObject);
    procedure btn_ClearFormsSettingsClick(Sender: TObject);
    procedure btn_ClearMainSettingsClick(Sender: TObject);
    procedure btn_ClearPluginsSettingsClick(Sender: TObject);
    procedure btn_ClearRecentFilesClick(Sender: TObject);
    procedure cb_ShowActionInTrayClick(Sender: TObject);
    procedure Btn_AboutSelClick(Sender: TObject);
    procedure cbb_SelColorChange(Sender: TObject);
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
    procedure WMQueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION;
    procedure UpdateActions;
  end;

var
  FMain: TFMain;

implementation

{$R *.dfm}

function BoolToCheckedAction(B: Boolean): string;
begin
  Result := '[  ]';
  if B then
    Result := '[*]';
end;

procedure TFMain.ApplySettings;
var
  i: Integer;
begin
  with GSettings do
  begin
    cbb_Monitors.ItemIndex       := MonIndex;
    cbb_Hostings.ItemIndex       := LoaderIndex;
    cbb_ShortLink.ItemIndex      := ShortLinkIndex;
    cbb_Files.ItemIndex          := FileLoaderIndex;
    cb_AutoStart.Checked         := AutoStart;
    cb_HideLoadForm.Checked      := HideLoadForm;
    cb_ShowInTray.Checked        := ShowInTray;
    cb_CopyLink.Checked          := CopyLink;
    cbb_ImgExt.ItemIndex         := ImgExtIndex;
    cb_OpenByTrayClick.Checked   := OpenLinksByClick;
    cb_FastLoad.Checked          := FastLoad;
    cb_shortlinkFiles.Checked    := ShortFiles;
    cb_shortlinkImg.Checked      := ShortImg;
    cb_EditImageFromFile.Checked := EditImageFromFile;
    rb_realtimesel.Checked       := RealTimeSel;
    rb_staticsel.Checked         := not RealTimeSel;
    cbb_SelColor.Selected        := SelColor;
    cb_AutoCheckUpdate.Checked   := AutoCheckUpdate;
    SetLength(tmpHotKeys, Length(Actions));
    for i           := 0 to high(Actions) do
      tmpHotKeys[i] := Actions[i];
    with Pastebin do
    begin
      rb_pb_anon.Checked           := Anon;
      rb_pb_account.Checked        := not Anon;
      edt_pb_login.Text            := Login;
      edt_pb_pass.Text             := Password;
      cbb_pb_deflang.ItemIndex     := SyntaxIndex;
      cbb_pb_expire.ItemIndex      := ExpireIndex;
      cbb_pb_private.ItemIndex     := PrivateIndex;
      cb_pb_copylink.Checked       := CopyLink;
      cb_pb_CloseAfterLoad.Checked := CloseForm;
    end;
    with FTP do
    begin
      cb_FTP_Img.Checked     := ImgLoad;
      cb_FTP_Files.Checked   := FilesLoad;
      edt_FTP_host.Text      := Host;
      edt_FTP_user.Text      := User;
      edt_FTP_pass.Text      := Pass;
      edt_FTP_port.Text      := Port;
      edt_FTP_path.Text      := path;
      edt_FTP_URL.Text       := URL;
      cb_FTP_Passive.Checked := Passive;
    end;
    Autorun(AutoStart, SYS_KEEP2ME, ParamStr(0));
  end;
  UpdateActions;
  cb_ShowActionInTray.Checked := GSettings.Actions[0].ShowMenuItem;
  cb_EnableKey.Checked        := GSettings.Actions[0].Enabled;
end;

procedure TFMain.Btn_AboutSelClick(Sender: TObject);
begin
  ShowMessage(RU_SEL_TYPES_ABOUT);
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
  else
    ShowMessage(RU_HOTKEY_IS_BUSY);
end;

procedure TFMain.btn_ClearFormsSettingsClick(Sender: TObject);
begin
  if FileExists(SYS_PATH + SYS_FILE_LOADER_FORM_NAME) then
    DeleteFile(SYS_PATH + SYS_FILE_LOADER_FORM_NAME);
  if FileExists(SYS_PATH + SYS_IMG_LOADER_FORM_NAME) then
    DeleteFile(SYS_PATH + SYS_IMG_LOADER_FORM_NAME);
end;

procedure TFMain.btn_ClearMainSettingsClick(Sender: TObject);
begin
  if FileExists(SYS_PATH + SYS_SETTINGS_FILE_NAME) then
    DeleteFile(SYS_PATH + SYS_SETTINGS_FILE_NAME);
  LoadSettings;
  ApplySettings;
end;

procedure TFMain.btn_ClearPluginsSettingsClick(Sender: TObject);
begin
  if FileExists(SYS_PATH + SYS_FILELOADERS_SETTINGS_FILE_NAME) then
    DeleteFile(SYS_PATH + SYS_FILELOADERS_SETTINGS_FILE_NAME);
  if FileExists(SYS_PATH + SYS_IMGLOADERS_SETTINGS_FILE_NAME) then
    DeleteFile(SYS_PATH + SYS_IMGLOADERS_SETTINGS_FILE_NAME);
end;

procedure TFMain.btn_ClearRecentFilesClick(Sender: TObject);
begin
  if FileExists(SYS_PATH + SYS_RECENT_FILE_NAME) then
    DeleteFile(SYS_PATH + SYS_RECENT_FILE_NAME);
  LoadRecentFiles;
  UpdateRecentFiles(self);
end;

procedure TFMain.btn_FilesSettingsClick(Sender: TObject);
begin
  if FileLoadersArray[cbb_Files.ItemIndex].HaveSettings then
    TFFilesSettings.CreateEx(FileLoadersArray[cbb_Files.ItemIndex].Obj.Create,
      'Настройки ' + FileLoadersArray[cbb_Files.ItemIndex].Caption);
end;

procedure TFMain.btn_GetCurrentMonitorClick(Sender: TObject);
begin
  cbb_Monitors.ItemIndex := MonitorManager.GetMonitorByPoint(Point(self.Left, self.Top));
end;

procedure TFMain.btn_RefreshMonitorsClick(Sender: TObject);
begin
  InitMonitors;
end;

procedure TFMain.cbb_FilesChange(Sender: TObject);
begin
  btn_FilesSettings.Enabled := FileLoadersArray[cbb_Files.ItemIndex].HaveSettings;
end;

procedure TFMain.cbb_HotKeysActionsChange(Sender: TObject);
begin
  with tmpHotKeys[cbb_HotKeysActions.ItemIndex] do
  begin
    cb_CtrlKey.Checked          := Ctrl;
    cb_AltKey.Checked           := Alt;
    cb_ShiftKey.Checked         := Shift;
    cbb_HotKeys.ItemIndex       := Key;
    cb_WinKey.Checked           := Win;
    cb_EnableKey.Checked        := Enabled;
    cb_ShowActionInTray.Enabled := (MenuItem <> nil);
    cb_ShowActionInTray.Checked := ShowMenuItem;
  end;
end;

procedure TFMain.cbb_HotKeysChange(Sender: TObject);
begin
  tmpHotKeys[cbb_HotKeysActions.ItemIndex].Key := cbb_HotKeys.ItemIndex;
end;

procedure TFMain.cbb_SelColorChange(Sender: TObject);
begin
  GSettings.SelColor := cbb_SelColor.Selected;
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
  cb_ShiftKey.Enabled                              := cb_EnableKey.Checked;
  cb_WinKey.Enabled                                := cb_EnableKey.Checked;
  cb_CtrlKey.Enabled                               := cb_EnableKey.Checked;
  cb_AltKey.Enabled                                := cb_EnableKey.Checked;
  cbb_HotKeys.Enabled                              := cb_EnableKey.Checked;
  btn_CheckHotKey.Enabled                          := cb_EnableKey.Checked;
end;

procedure TFMain.cb_FTP_FilesClick(Sender: TObject);
begin
  cbb_Files.Enabled         := not cb_FTP_Files.Checked;
  btn_FilesSettings.Enabled := not cb_FTP_Files.Checked;
end;

procedure TFMain.cb_FTP_ImgClick(Sender: TObject);
begin
  cbb_Hostings.Enabled := not cb_FTP_Img.Checked;
end;

procedure TFMain.cb_ShiftKeyClick(Sender: TObject);
begin
  tmpHotKeys[cbb_HotKeysActions.ItemIndex].Shift := cb_ShiftKey.Checked;
end;

procedure TFMain.cb_ShowActionInTrayClick(Sender: TObject);
begin
  tmpHotKeys[cbb_HotKeysActions.ItemIndex].ShowMenuItem := cb_ShowActionInTray.Checked;
end;

procedure TFMain.cb_WinKeyClick(Sender: TObject);
begin
  tmpHotKeys[cbb_HotKeysActions.ItemIndex].Win := cb_WinKey.Checked;
end;

procedure CheckUpdates(OnRun: Integer);
var
  HTTP: tidhttp;
  s, v: string;
begin
  s                      := '';
  HTTP                   := tidhttp.Create(nil);
  HTTP.Request.UserAgent := SYS_USERAGENT;
  try
    s := HTTP.Get(SYS_UPDATE_CHECK_PAGE);
  except
  end;
  v := s;
  Delete(v, 1, pos(SYS_UPDATE_TOKEN, s) + Length(SYS_UPDATE_TOKEN));
  if (Length(s) = 0) and (OnRun = 0) then
    ShowMessage(RU_SERVER_CONNECTION_ERROR)
  else if (pos(SYS_UPDATE_TOKEN, s) = 0) and (OnRun = 0) then
    ShowMessage(RU_SERVER_CONNECTION_ERROR)
  else if (Length(s) > 0) and (v <> SYS_KEEP_VERSION) then
  begin
    if MessageDlg(Format(RU_UPDATE_AVAILABLE, [v, SYS_KEEP_VERSION]), mtConfirmation, mbYesNo, 0) <> mrYes then
    begin
      HTTP.Free;
      Exit;
    end;
    if not FileExists(SYS_PATH + SYS_UPDATER_EXE_NAME) then
    begin
      ShowMessage(RU_ERROR_FIND_UPDATER + SYS_UPDATER_EXE_NAME);
      Exit;
    end;
    // RunMeAsAdmin(GetDesktopWindow, PChar(SYS_PATH + SYS_UPDATER_EXE_NAME), '');
    ShellExecute(GetDesktopWindow, 'open', PChar(SYS_PATH + SYS_UPDATER_EXE_NAME), 'STARTUPDATE', nil, SW_SHOW);
    HTTP.Free;
    FMain.tmr_ExitFromThread.Enabled := true;
  end else if OnRun = 0 then
  begin
    ShowMessage(RU_UPTODATE_VERSION);
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
      StartWork;
    end;
  end
  else
    TrayIcon.BalloonHint(SYS_KEEP2ME, RU_NOT_AN_IMAGE_CONTENT);
end;

procedure TFMain.DoLoadFilesFromBuf(Sender: TObject);
var
  f          : THandle;
  buffer     : array [0 .. MAX_PATH] of Char;
  i, numFiles: Integer;
  T          : Tstringlist;
begin
  Clipboard.Open;
  T := Tstringlist.Create;
  try
    f := Clipboard.GetAsHandle(CF_HDROP);
    if f <> 0 then
    begin
      numFiles := DragQueryFile(f, $FFFFFFFF, nil, 0);
      for i    := 0 to numFiles - 1 do
      begin
        buffer[0] := #0;
        DragQueryFile(f, i, buffer, sizeof(buffer));
        T.Add(buffer);
      end;
    end;
  finally
    Clipboard.Close;
    if T.Count > 0 then
      TFFiles.Create(nil).StartLoad(T)
    else
    begin
      T.Free;
      TrayIcon.BalloonHint(SYS_KEEP2ME, 'Содержимое буфера обмена не содержит файлов');
    end;
  end;
end;

procedure DetectImage(const InputFileName: string; BM: TBitmap);
var
  FS        : TFileStream;
  FirstBytes: AnsiString;
  Graphic   : TGraphic;
begin
  Graphic := nil;
  FS      := TFileStream.Create(InputFileName, fmOpenRead);
  try
    SetLength(FirstBytes, 8);
    FS.Read(FirstBytes[1], 8);
    if copy(FirstBytes, 1, 2) = 'BM' then
    begin
      Graphic := TBitmap.Create;
    end else if FirstBytes = #137'PNG'#13#10#26#10 then
    begin
      Graphic := TPngImage.Create;
    end else if copy(FirstBytes, 1, 3) = 'GIF' then
    begin
      Graphic := TGIFImage.Create;
    end else if copy(FirstBytes, 1, 2) = #$FF#$D8 then
    begin
      Graphic := TJPEGImage.Create;
    end;
    if Assigned(Graphic) then
    begin
      try
        FS.Seek(0, soFromBeginning);
        Graphic.LoadFromStream(FS);
        BM.Assign(Graphic);
      except
      end;
      Graphic.Free;
    end;
  finally
    FS.Free;
  end;
end;

procedure TFMain.DoOpenAndLoadFile(Sender: TObject);
var
  T: Tstringlist;
begin
  if OpenFileDlg.Execute then
  begin
    T := Tstringlist.Create;
    T.Add(OpenFileDlg.FileName);
    TFFiles.Create(nil).StartLoad(T);
  end;
end;

procedure TFMain.DoOpenAndSendImage(Sender: TObject);
begin
  if OpenImageDlg.Execute then
    if GSettings.EditImageFromFile then
    begin
      with TFImage.Create(nil) do
        try
          DetectImage(OpenImageDlg.FileName, OriginImg);
          img.Picture.Assign(OriginImg);
          StartWork;
        except
          on E: Exception do
          begin
            ShowMessage(RU_IMG_LOAD_ERROR + E.Message);
            Free;
          end;
        end;
    end
    else
      TFLoad.CreateEx(OpenImageDlg.FileName, nil, true);
end;

procedure TFMain.DoPastebin(Sender: TObject);
begin
  TFPasteBin.Create(nil).Show;
end;

procedure TFMain.DoScreenSelect(Sender: TObject);
begin
  if GSettings.RealTimeSel then
    Hide;
  TFPoints.Create(nil).Show;
end;

procedure TFMain.DoShortLinkFromBuf(Sender: TObject);
var
  CShorter: TShorter;
begin
  if pos('http://', LowerCase(Clipboard.AsText)) <> 1 then
  begin
    GSettings.TrayIcon.BalloonHint(SYS_KEEP2ME, 'Содержимое не является ссылкой');
    Exit;
  end;
  CShorter := ShortersArray[GSettings.ShortLinkIndex].Obj.Create;
  CShorter.SetLoadBar(nil);
  CShorter.LoadFile(Clipboard.AsText);
  if CShorter.Error then
    GSettings.TrayIcon.BalloonHint(SYS_KEEP2ME, 'Не удалось укоротить ссылку')
  else
  begin
    Clipboard.AsText        := CShorter.GetLink;
    GSettings.TrayIcon.Hint := Clipboard.AsText;
    GSettings.TrayIcon.BalloonHint(SYS_KEEP2ME, Clipboard.AsText);
  end;
  CShorter.Free;

end;

procedure TFMain.DoShowSettings(Sender: TObject);
begin
  Show;
  BringToFront;
end;

procedure TFMain.DoWindowSelect(Sender: TObject);
begin
  if GSettings.RealTimeSel then
    Hide;
  TrayIcon.BalloonHint(RU_HINT, RU_SELECTWINDOW_HINT);
  // FSelField.AlphaBlend := false;
  with TFWindows.Create(nil) do
  begin
    StartSelect;
    Show;
  end;
end;

procedure TFMain.ExitKeep;
var
  i: Integer;
begin
  for i := 0 to high(GSettings.Actions) do
    UnRegisterMyHotKey(@GSettings.Actions[i], self.Handle);
  halt(0);
end;

procedure TFMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := false;
  cbb_HotKeysActionsChange(self);
  Hide;
end;

{
  procedure TmpUpdate;
  var
  LoadStream: TMemoryStream;
  HTTP: tidhttp;
  begin
  HTTP := tidhttp.Create;
  HTTP.ReadTimeout := 60000;
  HTTP.ConnectTimeout := 60000;
  HTTP.Request.UserAgent := SYS_USERAGENT;
  LoadStream := TMemoryStream.Create;
  try
  DeleteFile(SYS_PATH + SYS_UPDATER_EXE_NAME);
  HTTP.Get('http://keep2.me/program/files/updater.exe', LoadStream);
  LoadStream.SaveToFile(SYS_PATH + SYS_UPDATER_EXE_NAME);
  except
  end;
  LoadStream.Free;
  HTTP.Free;
  if FileExists(SYS_PATH + SYS_UPDATER_EXE_NAME) then begin
  ShellExecute(GetDesktopWindow, 'open', PChar(SYS_PATH + SYS_UPDATER_EXE_NAME), 'STARTUPDATE',
  nil, SW_SHOW);
  end else begin
  ShowMessage('Не удалось обновить updater.exe' + #13#10 +
  'Сейчас вас перенаправит на страницу скачивания keep2me. Скачайте архив и замените ваши keep2me.exe и updater.exe на новые.');
  ShellExecute(GetDesktopWindow, 'open', 'http://keep2.me/keep2me(test)_x86.rar', nil, nil, SW_SHOW);
  end;
  FMain.tmr_ExitFromThread.Enabled := true;
  end;
}
procedure TFMain.FormCreate(Sender: TObject);
var
  i : Integer;
  id: longword;
begin
  { TrayIcon.IconVisible := false;
    ShowMessage('Необходимо обновить updater.exe' + #13#10 +
    'Программа в фоновом режиме перекачает файл и автоматически обновит keep2me до последней версии.' + #13#10 +
    'Процесс займет несколько минут.');
    TmpUpdate;
    Exit; }
  GSettings.TrayIcon          := TrayIcon;
  GSettings.UpdateRecentFiles := UpdateRecentFiles;
  LoadRecentFiles;
  for i := Ord(low(TImgFormats)) to Ord(high(TImgFormats)) do
    cbb_ImgExt.Items.Add(ImgFormatToText(TImgFormats(i)));
  AddHotKeyAction(true, RU_SELECT_SCREEN_PART, true, true, false, false, 3, DoScreenSelect, pm_SelectScreen);
  AddHotKeyAction(false, RU_SEND_FROM_BUFFER, true, true, false, false, 4, DoBufferSend, pm_BufferSend);
  AddHotKeyAction(false, RU_SEND_WINDOW_SCREEN, true, true, false, false, 5, DoWindowSelect, pm_SelectWindow);
  AddHotKeyAction(true, RU_SEND_TO_PASTEBIN, true, true, true, false, 6, DoPastebin, pm_pastebin);
  AddHotKeyAction(false, RU_SHOW_SETTNGS, true, true, false, false, 7, DoShowSettings, nil);
  AddHotKeyAction(false, RU_OPEN_IMAGE_AND_LOAD, true, true, false, false, 8, DoOpenAndSendImage, pm_LoadImageFromFile);
  AddHotKeyAction(false, RU_LOAD_FILES_FROM_BUF, true, true, false, false, 9, DoLoadFilesFromBuf, pm_filesfrombuf);
  AddHotKeyAction(false, RU_SHORT_LINK_FROM_BUF, true, true, false, false, 10, DoShortLinkFromBuf, pm_ShortLinkFromBuf);
  AddHotKeyAction(false, RU_OPEN_FILE_AND_LOAD, true, true, false, false, 11, DoOpenAndLoadFile, pm_OpenAndLoadFile);
  MonitorManager := TMonitorManager.Create;
  InitMonitors;
  UpdateActions;
  for i := 0 to high(ShortersArray) do
    cbb_ShortLink.Items.Add(ShortersArray[i].Caption);
  for i := 0 to high(HotKeysArray) do
    cbb_HotKeys.Items.Add(HotKeysArray[i].Caption);
  for i := 0 to high(PastebinLangs) do
    cbb_pb_deflang.Items.Add(PastebinLangs[i].Caption);
  for i := 0 to high(PastebinExpires) do
    cbb_pb_expire.Items.Add(PastebinExpires[i].Caption);
  for i := 0 to high(PastebinPrivates) do
    cbb_pb_private.Items.Add(PastebinPrivates[i].Caption);
  for i := 0 to high(LoadersArray) do
    cbb_Hostings.Items.Add(LoadersArray[i].Caption);
  for i := 0 to high(FileLoadersArray) do
    cbb_Files.Items.Add(FileLoadersArray[i].Caption);
  LoadSettings;
  ApplySettings;
  for i := 0 to high(GSettings.Actions) do
    RegisterMyHotKey(@GSettings.Actions[i], self.Handle, i);
  cbb_HotKeysActionsChange(self);
  cbb_FilesChange(self);
  UpdateRecentFiles(self);
  if GSettings.AutoCheckUpdate then
    beginthread(nil, 0, Addr(CheckUpdates), ptr(1), 0, id);
  // if (not GSettings.DontShowAdmin) and (not IsUserAnAdmin) then ShowMessage(RU_NOT_ADMIN);
  ForceDirectories(SYS_PATH + SYS_TMP_IMG_FOLDER);
  Visible := not(FileExists(SYS_PATH + SYS_SETTINGS_FILE_NAME) and
    not((ParamCount > 0) and (ParamStr(1) = SYS_SHOW_SETTINGS_PARAM)));
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  ApplySettings;
end;

procedure TFMain.GetSettings;
var
  i: Integer;
begin
  with GSettings do
  begin
    MonIndex          := cbb_Monitors.ItemIndex;
    LoaderIndex       := cbb_Hostings.ItemIndex;
    ShortLinkIndex    := cbb_ShortLink.ItemIndex;
    FileLoaderIndex   := cbb_Files.ItemIndex;
    AutoStart         := cb_AutoStart.Checked;
    HideLoadForm      := cb_HideLoadForm.Checked;
    ShowInTray        := cb_ShowInTray.Checked;
    CopyLink          := cb_CopyLink.Checked;
    ImgExtIndex       := cbb_ImgExt.ItemIndex;
    OpenLinksByClick  := cb_OpenByTrayClick.Checked;
    FastLoad          := cb_FastLoad.Checked;
    ShortFiles        := cb_shortlinkFiles.Checked;
    ShortImg          := cb_shortlinkImg.Checked;
    EditImageFromFile := cb_EditImageFromFile.Checked;
    RealTimeSel       := rb_realtimesel.Checked;
    SelColor          := cbb_SelColor.Selected;
    AutoCheckUpdate   := cb_AutoCheckUpdate.Checked;
    SetLength(Actions, Length(tmpHotKeys));
    for i := 0 to high(tmpHotKeys) do
    begin
      Actions[i] := tmpHotKeys[i];
      if Actions[i].MenuItem <> nil then
        Actions[i].MenuItem.Visible := Actions[i].ShowMenuItem;
    end;
    with Pastebin do
    begin
      Anon         := rb_pb_anon.Checked;
      Login        := edt_pb_login.Text;
      Password     := edt_pb_pass.Text;
      SyntaxIndex  := cbb_pb_deflang.ItemIndex;
      ExpireIndex  := cbb_pb_expire.ItemIndex;
      PrivateIndex := cbb_pb_private.ItemIndex;
      CopyLink     := cb_pb_copylink.Checked;
      CloseForm    := cb_pb_CloseAfterLoad.Checked;
    end;
    with FTP do
    begin
      ImgLoad   := cb_FTP_Img.Checked;
      FilesLoad := cb_FTP_Files.Checked;
      Host      := edt_FTP_host.Text;
      User      := edt_FTP_user.Text;
      Pass      := edt_FTP_pass.Text;
      Port      := edt_FTP_port.Text;
      path      := edt_FTP_path.Text;
      URL       := edt_FTP_URL.Text;
      Passive   := cb_FTP_Passive.Checked;
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
  f := TIniFile.Create(SYS_PATH + SYS_SETTINGS_FILE_NAME);
  with f, GSettings do
  begin
    { if ReadString(INI_COMMON_SETTINGS, 'Version', SYS_KEEP_VERSION) <= '0.9.5' then
      ShowMessage
      ('В этой версии по умолчанию включен измененный внешний вид. Отключить его можно в Настройки - Остальные'); }
    MonIndex := ReadInteger(INI_COMMON_SETTINGS, 'MonitorIndex', 0);
    if MonIndex > Screen.MonitorCount - 1 then
      MonIndex  := 0;
    LoaderIndex := ReadInteger(INI_COMMON_SETTINGS, 'LoaderIndex', 0);
    if LoaderIndex > high(LoadersArray) then
      LoaderIndex  := high(LoadersArray);
    ShortLinkIndex := ReadInteger(INI_COMMON_SETTINGS, 'ShortLinkIndex', 0);
    if ShortLinkIndex > high(ShortersArray) then
      ShortLinkIndex := high(ShortersArray);
    FileLoaderIndex  := ReadInteger(INI_COMMON_SETTINGS, 'FileLoaderIndex', 0);
    if FileLoaderIndex > high(FileLoadersArray) then
      FileLoaderIndex := high(FileLoadersArray);
    AutoStart         := ReadBool(INI_COMMON_SETTINGS, 'AutoStart', false);
    ShowInTray        := ReadBool(INI_COMMON_SETTINGS, 'ShowInTray', true);
    HideLoadForm      := ReadBool(INI_COMMON_SETTINGS, 'HideLoadForm', false);
    OpenLinksByClick  := ReadBool(INI_COMMON_SETTINGS, 'OpenLinksByClick', true);
    CopyLink          := ReadBool(INI_COMMON_SETTINGS, 'CopyLink', true);
    FastLoad          := ReadBool(INI_COMMON_SETTINGS, 'FastLoad', false);
    ImgExtIndex       := ReadInteger(INI_COMMON_SETTINGS, 'ImgExtIndex', 1);
    ShortFiles        := ReadBool(INI_COMMON_SETTINGS, 'ShortFiles', false);
    ShortImg          := ReadBool(INI_COMMON_SETTINGS, 'ShortImg', false);
    EditImageFromFile := ReadBool(INI_COMMON_SETTINGS, 'EditImageFromFile', false);
    RealTimeSel       := ReadBool(INI_COMMON_SETTINGS, 'RealTimeSel', true);
    SelColor          := StringToColor(ReadString(INI_COMMON_SETTINGS, 'SelColor', 'clHighlight'));
    AutoCheckUpdate   := ReadBool(INI_COMMON_SETTINGS, 'AutoCheckUpdate', true);
    for i             := 0 to high(Actions) do
      with Actions[i] do
      begin
        Enabled      := ReadBool(INI_HOT_KEYS + inttostr(i), 'Enabled', Enabled);
        Key          := ReadInteger(INI_HOT_KEYS + inttostr(i), 'Key', Key);
        Ctrl         := ReadBool(INI_HOT_KEYS + inttostr(i), 'Ctrl', Ctrl);
        Alt          := ReadBool(INI_HOT_KEYS + inttostr(i), 'Alt', Alt);
        Shift        := ReadBool(INI_HOT_KEYS + inttostr(i), 'Shift', Shift);
        Win          := ReadBool(INI_HOT_KEYS + inttostr(i), 'Win', Win);
        ShowMenuItem := ReadBool(INI_HOT_KEYS + inttostr(i), 'ShowMenuItem', true);
      end;
    with Pastebin do
    begin
      Anon         := ReadBool(INI_PASTEBIN, 'Anonimous', true);
      Login        := MyDecrypt(ReadString(INI_PASTEBIN, 'Login', ''), SYS_CRYPT_KEY);
      Password     := MyDecrypt(ReadString(INI_PASTEBIN, 'Password', ''), SYS_CRYPT_KEY);
      SyntaxIndex  := ReadInteger(INI_PASTEBIN, 'SyntaxIndex', 0);
      ExpireIndex  := ReadInteger(INI_PASTEBIN, 'ExpireIndex', 0);
      PrivateIndex := ReadInteger(INI_PASTEBIN, 'PrivateIndex', 0);
      CopyLink     := ReadBool(INI_PASTEBIN, 'CopyLink', true);
      CloseForm    := ReadBool(INI_PASTEBIN, 'CloseForm', false);
    end;
    with FTP do
    begin
      ImgLoad   := ReadBool(INI_FTP, 'ImgLoad', false);
      FilesLoad := ReadBool(INI_FTP, 'FilesLoad', false);
      Host      := ReadString(INI_FTP, 'Host', '127.0.0.1');
      User      := ReadString(INI_FTP, 'User', 'User');
      Pass      := MyDecrypt(ReadString(INI_FTP, 'Password', ''), SYS_CRYPT_KEY);
      Port      := ReadString(INI_FTP, 'Port', '21');
      path      := ReadString(INI_FTP, 'Path', '/www/site.com/');
      URL       := ReadString(INI_FTP, 'URL', 'http://site.com/');
      Passive   := ReadBool(INI_FTP, 'Passive', true)
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
  DoShowSettings(self);
end;

procedure TFMain.rb_pb_accountClick(Sender: TObject);
begin
  edt_pb_login.Enabled := rb_pb_account.Checked;
  edt_pb_pass.Enabled  := rb_pb_account.Checked;
end;

procedure TFMain.rb_pb_anonClick(Sender: TObject);
begin
  edt_pb_login.Enabled := not rb_pb_anon.Checked;
  edt_pb_pass.Enabled  := not rb_pb_anon.Checked;
end;

procedure TFMain.SaveSettings;
var
  f: TIniFile;
  i: Integer;
begin
  f := TIniFile.Create(SYS_PATH + SYS_SETTINGS_FILE_NAME);
  f.WriteString(INI_COMMON_SETTINGS, 'Version', SYS_KEEP_VERSION);
  f.WriteString(INI_COMMON_SETTINGS, 'Platform', SYS_PLATFORM);
  with f, GSettings do
  begin
    WriteInteger(INI_COMMON_SETTINGS, 'MonitorIndex', MonIndex);
    WriteInteger(INI_COMMON_SETTINGS, 'LoaderIndex', LoaderIndex);
    WriteInteger(INI_COMMON_SETTINGS, 'ShortLinkIndex', ShortLinkIndex);
    WriteInteger(INI_COMMON_SETTINGS, 'FileLoaderIndex', FileLoaderIndex);
    WriteBool(INI_COMMON_SETTINGS, 'AutoStart', AutoStart);
    WriteBool(INI_COMMON_SETTINGS, 'ShowInTray', ShowInTray);
    WriteBool(INI_COMMON_SETTINGS, 'HideLoadForm', HideLoadForm);
    WriteBool(INI_COMMON_SETTINGS, 'CopyLink', CopyLink);
    WriteBool(INI_COMMON_SETTINGS, 'OpenLinksByClick', OpenLinksByClick);
    WriteBool(INI_COMMON_SETTINGS, 'FastLoad', FastLoad);
    WriteBool(INI_COMMON_SETTINGS, 'ShortFiles', ShortFiles);
    WriteBool(INI_COMMON_SETTINGS, 'ShortImg', ShortImg);
    WriteInteger(INI_COMMON_SETTINGS, 'ImgExtIndex', ImgExtIndex);
    WriteBool(INI_COMMON_SETTINGS, 'EditImageFromFile', EditImageFromFile);
    WriteBool(INI_COMMON_SETTINGS, 'RealTimeSel', RealTimeSel);
    WriteString(INI_COMMON_SETTINGS, 'SelColor', ColorToString(SelColor));
    WriteBool(INI_COMMON_SETTINGS, 'AutoCheckUpdate', AutoCheckUpdate);
    for i := 0 to high(Actions) do
      with Actions[i] do
      begin
        WriteInteger(INI_HOT_KEYS + inttostr(i), 'Key', Key);
        WriteBool(INI_HOT_KEYS + inttostr(i), 'Ctrl', Ctrl);
        WriteBool(INI_HOT_KEYS + inttostr(i), 'Alt', Alt);
        WriteBool(INI_HOT_KEYS + inttostr(i), 'Shift', Shift);
        WriteBool(INI_HOT_KEYS + inttostr(i), 'Win', Win);
        WriteBool(INI_HOT_KEYS + inttostr(i), 'Enabled', Enabled);
        WriteBool(INI_HOT_KEYS + inttostr(i), 'ShowMenuItem', ShowMenuItem);
      end;
    with Pastebin do
    begin
      WriteBool(INI_PASTEBIN, 'Anonimous', Anon);
      WriteString(INI_PASTEBIN, 'Login', MyEncrypt(Login, SYS_CRYPT_KEY));
      WriteString(INI_PASTEBIN, 'Password', MyEncrypt(Password, SYS_CRYPT_KEY));
      WriteInteger(INI_PASTEBIN, 'SyntaxIndex', SyntaxIndex);
      WriteInteger(INI_PASTEBIN, 'ExpireIndex', ExpireIndex);
      WriteInteger(INI_PASTEBIN, 'PrivateIndex', PrivateIndex);
      WriteBool(INI_PASTEBIN, 'CopyLink', CopyLink);
      WriteBool(INI_PASTEBIN, 'CloseForm', CloseForm);
    end;
    with FTP do
    begin
      WriteBool(INI_FTP, 'ImgLoad', ImgLoad);
      WriteBool(INI_FTP, 'FilesLoad', FilesLoad);
      WriteString(INI_FTP, 'Host', Host);
      WriteString(INI_FTP, 'User', User);
      WriteString(INI_FTP, 'Password', MyEncrypt(Pass, SYS_CRYPT_KEY));
      WriteString(INI_FTP, 'Port', Port);
      WriteString(INI_FTP, 'Path', path);
      WriteString(INI_FTP, 'URL', URL);
      WriteBool(INI_FTP, 'Passive', Passive);
    end;
    Free;
  end;
  for i := 0 to high(GSettings.Actions) do
    UnRegisterMyHotKey(@GSettings.Actions[i], self.Handle);
  for i := 0 to high(GSettings.Actions) do
    RegisterMyHotKey(@GSettings.Actions[i], self.Handle, i);
end;

procedure TFMain.tmr_ExitFromThreadTimer(Sender: TObject);
begin
  ExitKeep;
end;

procedure TFMain.TrayIconBalloonClick(Sender: TObject);
begin
  if pos('http', GSettings.LastLink) > 0 then
    if GSettings.OpenLinksByClick then
      ShellExecute(Handle, 'open', PChar(GSettings.LastLink), nil, nil, SW_SHOW);
end;

procedure TFMain.TrayIconBalloonShow(Sender: TObject);
begin
  if pos('http', TrayIcon.Hint) > 0 then
    GSettings.LastLink := TrayIcon.Hint
  else
    GSettings.LastLink := '-1';
  TrayIcon.Hint        := SYS_KEEP2ME;
end;

procedure TFMain.TrayIconClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    // GSettings.RealTimeSel := true;
    DoScreenSelect(self);
  end;
end;

procedure TFMain.UpdateActions;
var
  i: Integer;
begin
  cbb_HotKeysActions.Clear;
  with GSettings do
    for i := 0 to high(Actions) do
      cbb_HotKeysActions.Items.Add(BoolToCheckedAction(Actions[i].ShowMenuItem) +
        BoolToCheckedAction(Actions[i].Enabled) + ' ' + Actions[i].Caption);
  cbb_HotKeysActions.ItemIndex := 0;
end;

procedure TFMain.UpdateRecentFiles(Sender: TObject);
var
  i: Integer;
  M: TMenuItem;
begin
  for i := 0 to pm_RecentLoads.Count - 1 do
    pm_RecentLoads.Delete(0);
  for i := 0 to high(GSettings.RecentFiles) do
  begin
    M         := TMenuItem.Create(pm_RecentLoads);
    M.Caption := GSettings.RecentFiles[i].Caption;
    M.OnClick := OnRecentFileClick;
    M.Tag     := i;
    case GSettings.RecentFiles[i].LType of
      rfImg:
        M.ImageIndex := 10;
      rfText:
        M.ImageIndex := 12;
      rfOther:
        M.ImageIndex := 18;
    end;
    pm_RecentLoads.Insert(0, M);
  end;
end;

procedure TFMain.WMHotKey(var Msg: TWMHotKey);
var
  i: Integer;
begin
  for i := 0 to high(GSettings.Actions) do
    if GSettings.Actions[i].RegKey = Msg.hotkey then
      GSettings.Actions[i].Proc(self);
end;

procedure TFMain.WMQueryEndSession(var Message: TMessage);
begin
  inherited;
  halt(0);
end;

end.
