unit funcs;

interface

uses
  Winapi.Windows,
  Winapi.ShellAPI,
  System.Classes,
  System.Win.Registry,
  System.IniFiles,
  System.SysUtils,
  Vcl.Forms,
  JvTrayIcon,
  loaders,
  mons,
  myhotkeys,
  ConstStrings;

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
    CloseForm: Boolean;
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
    DontShowAdmin: Boolean;
    Pastebin: TPasteBinSettings;
  end;

function ImgFormatToText(I: TImgFormats): String;
function RunMeAsAdmin(hWnd: hWnd; filename: string; Parameters: string): Boolean;
procedure MinimizeAllForms;
procedure RestoreAllForms;
procedure RegisterMyHotKey(Key: PHotKeyAction; FHandle: THandle; Num: Integer);
procedure UnRegisterMyHotKey(Key: PHotKeyAction; FHandle: THandle);
procedure Autorun(Flag: Boolean; NameParam, Path: String);
procedure AddToRecentFiles(Link, Caption: string; FType: TRecentFileType);
procedure AddHotKeyAction(_Enabled: Boolean; _Caption: string; _Ctrl, _Alt, _Shift, _Win: Boolean; _Key: Integer;
  _Proc: TNotifyEvent);
procedure LoadRecentFiles;

const
  CRYPT_KEY = 26123;

var
  GSettings: TSettings;
  MonitorManager: TMonitorManager;

implementation

procedure MinimizeAllForms;
var
  I: Integer;
begin
  with Application do begin
    for I := 0 to ComponentCount - 1 do
      if (Components[I] is TForm) then
        if (Components[I] as TForm).Visible then begin
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
  with Application do begin
    for I := 0 to ComponentCount - 1 do
      if (Components[I] is TForm) then
        if (Components[I] as TForm).Tag = -1 then begin
          (Components[I] as TForm).Show;
          (Components[I] as TForm).Tag := 0;
        end;

  end;
end;

function RunMeAsAdmin(hWnd: hWnd; filename: string; Parameters: string): Boolean;
var
  sei: TShellExecuteInfo;
begin
  ZeroMemory(@sei, SizeOf(sei));
  sei.cbSize := SizeOf(TShellExecuteInfo);
  sei.Wnd := hWnd;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := PChar('runas');
  sei.lpFile := PChar(filename); // PAnsiChar;
  if Parameters <> '' then sei.lpParameters := PChar(Parameters)
  else sei.lpParameters := nil; // PAnsiChar;
  sei.nShow := SW_SHOWNORMAL; // Integer;
  Result := ShellExecuteEx(@sei);
end;

function ImgFormatToText(I: TImgFormats): String;
begin
  Result := '';
  case I of
    ifJpg: Result := '.jpg';
    ifPng: Result := '.png';
    ifBmp: Result := '.bmp';
    ifGif: Result := '.gif';
  end;
end;

function RecentFileTypeToString(R: TRecentFileType): string;
begin
  case R of
    rfImg: Result := 'img';
    rfText: Result := 'text';
  end;
end;

function StringToRecentFileType(R: string): TRecentFileType;
begin
  if R = 'img' then Result := rfImg
  else if R = 'text' then Result := rfText;
end;

procedure LoadRecentFiles;
var
  F: TIniFile;
  s: TRecentFileType;
  I: Integer;
begin
  if Not FileExists(ExtractFilePath(ParamStr(0)) + SYS_RECENT_FILE_NAME) then Exit;
  F := TIniFile.Create(ExtractFilePath(ParamStr(0)) + SYS_RECENT_FILE_NAME);
  for I := 0 to F.ReadInteger(INI_RECENTFILES, 'Length', -1) - 1 do
    with GSettings, F do begin
      SetLength(RecentFiles, Length(RecentFiles) + 1);
      RecentFiles[High(RecentFiles)].Link := ReadString(INI_RECENTFILES + inttostr(I), 'Link', '');
      RecentFiles[High(RecentFiles)].Caption := ReadString(INI_RECENTFILES + inttostr(I), 'Caption', '');
      RecentFiles[High(RecentFiles)].LType := StringToRecentFileType(ReadString(INI_RECENTFILES + inttostr(I),
        'Type', 'img'));
    end;
  F.Free;
end;

procedure AddToRecentFiles(Link, Caption: string; FType: TRecentFileType);
var
  I: Integer;
  F: TIniFile;
begin
  with GSettings do begin
    if Length(RecentFiles) < 10 then SetLength(RecentFiles, Length(RecentFiles) + 1)
    else
      for I := 0 to High(RecentFiles) - 1 do RecentFiles[I] := RecentFiles[I + 1];
    RecentFiles[High(RecentFiles)].Link := Link;
    RecentFiles[High(RecentFiles)].Caption := Caption;
    RecentFiles[High(RecentFiles)].LType := FType;
    F := TIniFile.Create(ExtractFilePath(ParamStr(0)) + SYS_RECENT_FILE_NAME);
    F.WriteInteger(INI_RECENTFILES, 'Length', Length(RecentFiles));
    for I := 0 to High(RecentFiles) do begin
      F.WriteString(INI_RECENTFILES + inttostr(I), 'Link', RecentFiles[I].Link);
      F.WriteString(INI_RECENTFILES + inttostr(I), 'Caption', RecentFiles[I].Caption);
      F.WriteString(INI_RECENTFILES + inttostr(I), 'Type', RecentFileTypeToString(RecentFiles[I].LType));
    end;
    F.Free;
    UpdateRecentFiles(nil);
  end;
end;

procedure AddHotKeyAction(_Enabled: Boolean; _Caption: string; _Ctrl, _Alt, _Shift, _Win: Boolean; _Key: Integer;
  _Proc: TNotifyEvent);
begin
  SetLength(GSettings.Actions, Length(GSettings.Actions) + 1);
  with GSettings.Actions[High(GSettings.Actions)] do begin
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
  if not Key.Enabled then Exit;
  UnRegisterHotKey(FHandle, Key^.RegKey);
  GlobalDeleteAtom(Key^.RegKey);
end;

procedure RegisterMyHotKey(Key: PHotKeyAction; FHandle: THandle; Num: Integer);
var
  Modifiers: UINT;
begin
  if not Key.Enabled then Exit;
  Modifiers := 0;
  if Key.Alt then Modifiers := Modifiers or MOD_ALT;
  if Key.Ctrl then Modifiers := Modifiers or MOD_CONTROL;
  if Key.Shift then Modifiers := Modifiers or MOD_SHIFT;
  if Key.Win then Modifiers := Modifiers or MOD_WIN;
  Key.RegKey := GlobalAddAtom(PChar('Keep2MeKey' + inttostr(Num)));
  RegisterHotKey(FHandle, Key^.RegKey, Modifiers, HotKeysArray[Key^.Key].Value);
end;

procedure Autorun(Flag: Boolean; NameParam, Path: String);
var
  Reg: TRegistry;
begin
  if Flag then begin
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', false);
    Reg.WriteString(NameParam, Path);
    Reg.Free;
  end else begin
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', false);
    Reg.DeleteValue(NameParam);
    Reg.Free;
  end;
end;

end.
