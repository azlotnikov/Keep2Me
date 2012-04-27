unit funcs;

interface

uses Winapi.Windows, System.Classes, System.Win.Registry, myhotkeys,
  System.SysUtils, loaders, JvTrayIcon, mons, Winapi.ShellAPI, Vcl.Forms,
  System.IniFiles;

type
  TImgFormats = (ifJpg, ifPng, ifBmp, ifGif);

type
  THotKeyAction = record
    Enabled: Boolean;
    Caption: String;
    Ctrl: Boolean;
    Alt: Boolean;
    Shift: Boolean;
    Win: Boolean;
    Key: Integer;
    RegKey: Integer;
    Proc: TNotifyEvent;
  end;

  PHotKeyAction = ^THotKeyAction;

type
  TRecentFileType = (rfImg, rfText);

type
  TRecentFile = record
    Link: String;
    Caption: String;
    LType: TRecentFileType;
  end;

type
  TPasteBinSettings = record
    Anon: Boolean;
    Login: String;
    Password: String;
    SyntaxIndex: Integer;
    ExpireIndex: Integer;
    PrivateIndex: Integer;
    CopyLink: Boolean;
  end;

type
  TSettings = record
    MonIndex: Integer;
    LoaderIndex: Integer;
    ShortLinkIndex: Integer;
    AutoStart: Boolean;
    ShowInTray: Boolean;
    HideLoadForm: Boolean;
    CopyLink: Boolean;
    ImgExtIndex: Integer;
    Actions: array of THotKeyAction;
    TrayIcon: TJvTrayIcon;
    RecentFiles: array of TRecentFile;
    UpdateRecentFiles: TNotifyEvent;
    Pastebin: TPasteBinSettings;
  end;

function ImgFormatToText(I: TImgFormats): String;
procedure MinimizeAllForms;
procedure RestoreAllForms;
procedure RegisterMyHotKey(Key: PHotKeyAction; FHandle: THandle; Num: Integer);
procedure UnRegisterMyHotKey(Key: PHotKeyAction; FHandle: THandle);
procedure Autorun(Flag: Boolean; NameParam, Path: String);
procedure AddToRecentFiles(Link, Caption: string; FType: TRecentFileType);
procedure AddHotKeyAction(_Enabled: Boolean; _Caption: string;
  _Ctrl, _Alt, _Shift, _Win: Boolean; _Key: Integer; _Proc: TNotifyEvent);
procedure LoadRecentFiles;
function RunMeAsAdmin(hWnd: hWnd; filename: string; Parameters: string)
  : Boolean;

const
  SETTINGS_FILE_NAME = 'settings.ini';
  RECENT_FILE_NAME = 'recent_files.ini';
  KEEP_VERSION = '0.3.1';
  CRYPT_KEY = 26123;

var
  GSettings: TSettings;
  MonitorManager: TMonitorManager;

implementation

procedure MinimizeAllForms;
var
  I: Integer;
begin
  with Application do
  begin
    for I := 0 to ComponentCount - 1 do
      if (Components[I] is TForm) then
        if (Components[I] as TForm).Visible then
        begin
          (Components[I] as TForm).Tag := -1;
          (Components[I] as TForm).Visible := false;
        end
        else
          (Components[I] as TForm).Tag := 0;
  end;
end;

procedure RestoreAllForms;
var
  I: Integer;
begin
  with Application do
  begin
    for I := 0 to ComponentCount - 1 do
      if (Components[I] is TForm) then
        if (Components[I] as TForm).Tag = -1 then
        begin
          (Components[I] as TForm).Show;
          (Components[I] as TForm).Tag := 0;
        end;

  end;
end;

function RunMeAsAdmin(hWnd: hWnd; filename: string; Parameters: string)
  : Boolean;
var
  sei: TShellExecuteInfo;
begin
  ZeroMemory(@sei, SizeOf(sei));
  sei.cbSize := SizeOf(TShellExecuteInfo);
  sei.Wnd := hWnd;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := PChar('runas');
  sei.lpFile := PChar(filename); // PAnsiChar;
  if Parameters <> '' then
    sei.lpParameters := PChar(Parameters)
  else
    sei.lpParameters := nil; // PAnsiChar;
  sei.nShow := SW_SHOWNORMAL; // Integer;
  Result := ShellExecuteEx(@sei);
end;

function ImgFormatToText(I: TImgFormats): String;
begin
  Result := '';
  case I of
    ifJpg:
      Result := '.jpg';
    ifPng:
      Result := '.png';
    ifBmp:
      Result := '.bmp';
    ifGif:
      Result := '.gif';
  end;
end;

function RecentFileTypeToString(R: TRecentFileType): string;
begin
  case R of
    rfImg:
      Result := 'img';
    rfText:
      Result := 'text';
  end;
end;

function StringToRecentFileType(R: string): TRecentFileType;
begin
  if R = 'img' then
    Result := rfImg
  else if R = 'text' then
    Result := rfText;
end;

procedure LoadRecentFiles;
var
  F: TIniFile;
  s: TRecentFileType;
  I: Integer;
begin
  if Not FileExists(ExtractFilePath(ParamStr(0)) + RECENT_FILE_NAME) then
    Exit;
  F := TIniFile.Create(ExtractFilePath(ParamStr(0)) + RECENT_FILE_NAME);
  for I := 0 to F.ReadInteger('RecentFiles', 'High', -1) do
  begin
    SetLength(GSettings.RecentFiles, Length(GSettings.RecentFiles) + 1);
    GSettings.RecentFiles[High(GSettings.RecentFiles)].Link :=
      F.ReadString('RecentFiles', 'Link' + inttostr(I), '');
    GSettings.RecentFiles[High(GSettings.RecentFiles)].Caption :=
      F.ReadString('RecentFiles', 'Caption' + inttostr(I), '');
    GSettings.RecentFiles[High(GSettings.RecentFiles)].LType :=
      StringToRecentFileType(F.ReadString('RecentFiles',
      'Type' + inttostr(I), 'img'));
  end;
  F.Free;
end;

procedure AddToRecentFiles(Link, Caption: string; FType: TRecentFileType);
var
  I: Integer;
  F: TIniFile;
begin
  if Length(GSettings.RecentFiles) < 10 then
    SetLength(GSettings.RecentFiles, Length(GSettings.RecentFiles) + 1)
  else
    for I := 0 to High(GSettings.RecentFiles) - 1 do
      GSettings.RecentFiles[I] := GSettings.RecentFiles[I + 1];
  GSettings.RecentFiles[High(GSettings.RecentFiles)].Link := Link;
  GSettings.RecentFiles[High(GSettings.RecentFiles)].Caption := Caption;
  GSettings.RecentFiles[High(GSettings.RecentFiles)].LType := FType;
  F := TIniFile.Create(ExtractFilePath(ParamStr(0)) + RECENT_FILE_NAME);
  F.WriteInteger('RecentFiles', 'High', High(GSettings.RecentFiles));
  for I := 0 to High(GSettings.RecentFiles) do
  begin
    F.WriteString('RecentFiles', 'Link' + inttostr(I),
      GSettings.RecentFiles[I].Link);
    F.WriteString('RecentFiles', 'Caption' + inttostr(I),
      GSettings.RecentFiles[I].Caption);
    F.WriteString('RecentFiles', 'Type' + inttostr(I),
      RecentFileTypeToString(GSettings.RecentFiles[I].LType));
  end;
  F.Free;
  GSettings.UpdateRecentFiles(nil);
end;

procedure AddHotKeyAction(_Enabled: Boolean; _Caption: string;
  _Ctrl, _Alt, _Shift, _Win: Boolean; _Key: Integer; _Proc: TNotifyEvent);
begin
  SetLength(GSettings.Actions, Length(GSettings.Actions) + 1);
  with GSettings.Actions[High(GSettings.Actions)] do
  begin
    Enabled := _Enabled;
    Caption := _Caption;
    Ctrl := _Ctrl;
    Alt := _Alt;
    Shift := _Shift;
    Win := _Win;
    Key := _Key;
    Proc := _Proc;
  end;
end;

procedure UnRegisterMyHotKey(Key: PHotKeyAction; FHandle: THandle);
begin
  if not Key.Enabled then
    Exit;
  UnRegisterHotKey(FHandle, Key^.RegKey);
  GlobalDeleteAtom(Key^.RegKey);
end;

procedure RegisterMyHotKey(Key: PHotKeyAction; FHandle: THandle; Num: Integer);
var
  Modifiers: UINT;
begin
  if not Key.Enabled then
    Exit;
  Modifiers := 0;
  if Key.Alt then
    Modifiers := Modifiers or MOD_ALT;
  if Key.Ctrl then
    Modifiers := Modifiers or MOD_CONTROL;
  if Key.Shift then
    Modifiers := Modifiers or MOD_SHIFT;
  if Key.Win then
    Modifiers := Modifiers or MOD_WIN;
  Key.RegKey := GlobalAddAtom(PChar('Keep2MeKey' + inttostr(Num)));
  RegisterHotKey(FHandle, Key^.RegKey, Modifiers, HotKeysArray[Key^.Key].Value);
end;

procedure Autorun(Flag: Boolean; NameParam, Path: String);
var
  Reg: TRegistry;
begin
  if Flag then
  begin
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', false);
    Reg.WriteString(NameParam, Path);
    Reg.Free;
  end
  else
  begin
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', false);
    Reg.DeleteValue(NameParam);
    Reg.Free;
  end;
end;

end.
