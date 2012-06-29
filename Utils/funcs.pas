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
  Vcl.Menus,
  JvTrayIcon,
  acAlphaImageList,
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
    MenuItem: TMenuItem;
    ShowMenuItem: Boolean;
  end;

  PHotKeyAction = ^THotKeyAction;

type
  TRecentFileType = (rfImg, rfText, rfOther);

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
  TFTPSettings = record
    ImgLoad: Boolean;
    FilesLoad: Boolean;
    Host: string;
    Path: string;
    User: String;
    Pass: string;
    Port: string;
    URL: String;
    Passive: Boolean;
  end;

type
  TSettings = record
    LastLink: String;
    MonIndex: Integer;
    LoaderIndex: Integer;
    ShortLinkIndex: Integer;
    FileLoaderIndex: Integer;
    OpenLinksByClick: Boolean;
    AutoStart: Boolean;
    ShowInTray: Boolean;
    HideLoadForm: Boolean;
    CopyLink: Boolean;
    EditImageFromFile: Boolean;
    ImgExtIndex: Integer;
    Actions: array of THotKeyAction;
    TrayIcon: TJvTrayIcon;
    RecentFiles: array of TRecentFile;
    UpdateRecentFiles: TNotifyEvent;
    DontShowAdmin: Boolean;
    FastLoad: Boolean;
    Pastebin: TPasteBinSettings;
    ShortImg: Boolean;
    ShortFiles: Boolean;
    FTP: TFTPSettings;
  end;

type
  TLinkStatus = (lsWait, lsError, lsOK, lsCanceled, lsNoFile, lsInProgress);

type
  TLinkData = record
    FilePath: String;
    Size: String;
    Status: TLinkStatus;
    StatusText: String;
    Link: String;
  end;

  TArrayOfLinkData = array of TLinkData;

function ImgFormatToText(I: TImgFormats): String;
function RunMeAsAdmin(hWnd: hWnd; FileName: string; Parameters: string): Boolean;
procedure MinimizeAllForms;
procedure RestoreAllForms;
function RegisterMyHotKey(Key: PHotKeyAction; FHandle: THandle; Num: Integer; Check: Boolean = false): Boolean;
procedure UnRegisterMyHotKey(Key: PHotKeyAction; FHandle: THandle);
procedure Autorun(Flag: Boolean; NameParam, Path: String);
procedure AddToRecentFiles(ALink, ACaption: string; ALType: TRecentFileType);
procedure AddHotKeyAction(_Enabled: Boolean; _Caption: string; _Ctrl, _Alt, _Shift, _Win: Boolean; _Key: Integer;
  _Proc: TNotifyEvent; _MenuItem: TMenuItem);
procedure LoadRecentFiles;
function CompareHotKeys(Key1, Key2: PHotKeyAction): Boolean;
function GetFileSize(FileName: wideString): Int64;
procedure GetAllFiles(Path: string; T: TStringList; ImgOnly: Boolean);
procedure AddFileLink(Path: String; var A: TArrayOfLinkData);
function HotKeyToText(K: THotKeyAction): String;

var
  GSettings: TSettings;
  MonitorManager: TMonitorManager;

implementation

function HotKeyToText(K: THotKeyAction): String;
begin
  Result := '';
  if K.Ctrl then Result := Result + 'Ctrl+';
  if K.Alt then Result := Result + 'Alt+';
  if K.Shift then Result := Result + 'Shift+';
  if K.Win then Result := Result + 'Win+';
  Result := Result + HotKeysArray[K.RegKey].Caption;
end;

procedure AddFileLink(Path: String; var A: TArrayOfLinkData);
begin
  SetLength(A, Length(A) + 1);
  with A[High(A)] do begin
    FilePath := Path;
    if FileExists(Path) then begin
      Size := inttostr(GetFileSize(Path) div 1024);
      if Size = '0' then Size := '1';
      StatusText := 'Ожидание';
      Status := lsWait;
    end else begin
      Size := '0';
      Status := lsNoFile;
      StatusText := 'Файл отсутствует!';
    end;
  end;
end;

procedure GetAllFiles(Path: string; T: TStringList; ImgOnly: Boolean);
var
  sRec: TSearchRec;
  isFound: Boolean;
begin
  isFound := FindFirst(Path + '\*.*', faAnyFile, sRec) = 0;
  while isFound do begin
    if (sRec.Name <> '.') and (sRec.Name <> '..') then begin
      if (sRec.Attr and faDirectory) = faDirectory then GetAllFiles(Path + '\' + sRec.Name, T, ImgOnly);
      if ImgOnly then begin
        if (ExtractFileExt(sRec.Name) = '.png') or (ExtractFileExt(sRec.Name) = '.jpg') then
            T.Add(Path + '\' + sRec.Name);
      end
      else T.Add(Path + '\' + sRec.Name);
    end;
    Application.ProcessMessages;
    isFound := FindNext(sRec) = 0;
  end;
  FindClose(sRec);
end;

function GetFileSize(FileName: wideString): Int64;
var
  sr: TSearchRec;
begin
  if FindFirst(FileName, faAnyFile, sr) = 0 then
      Result := Int64(sr.FindData.nFileSizeHigh) shl Int64(32) + Int64(sr.FindData.nFileSizeLow)
  else Result := -1;
  FindClose(sr);
end;

function CompareHotKeys(Key1, Key2: PHotKeyAction): Boolean;
begin
  Result := false;
  if Key1^.Ctrl <> Key2^.Ctrl then Exit;
  if Key1^.Alt <> Key2^.Alt then Exit;
  if Key1^.Win <> Key2^.Win then Exit;
  if Key1^.Shift <> Key2^.Shift then Exit;
  if Key1^.Key <> Key2^.Key then Exit;
  Result := true;
end;

procedure MinimizeAllForms;
var
  I: Integer;
begin
  with Application do begin
    for I := 0 to ComponentCount - 1 do
      if (Components[I] is TForm) and ((Components[I] as TForm).Tag <> -2) then
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

function RunMeAsAdmin(hWnd: hWnd; FileName: string; Parameters: string): Boolean;
var
  sei: TShellExecuteInfo;
begin
  ZeroMemory(@sei, SizeOf(sei));
  sei.cbSize := SizeOf(TShellExecuteInfo);
  sei.Wnd := hWnd;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := PChar('runas');
  sei.lpFile := PChar(FileName); // PAnsiChar;
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
    rfOther: Result := 'other';
  end;
end;

function StringToRecentFileType(R: string): TRecentFileType;
begin
  if R = 'img' then Result := rfImg
  else if R = 'text' then Result := rfText
  else Result := rfOther;
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
      with RecentFiles[High(RecentFiles)] do begin
        Link := ReadString(INI_RECENTFILES + inttostr(I), 'Link', '');
        Caption := ReadString(INI_RECENTFILES + inttostr(I), 'Caption', '');
        LType := StringToRecentFileType(ReadString(INI_RECENTFILES + inttostr(I), 'Type', 'img'));
      end;
    end;
  F.Free;
end;

procedure AddToRecentFiles(ALink, ACaption: string; ALType: TRecentFileType);
var
  I: Integer;
  F: TIniFile;
begin
  with GSettings do begin
    if Length(RecentFiles) < 10 then SetLength(RecentFiles, Length(RecentFiles) + 1)
    else
      for I := 0 to High(RecentFiles) - 1 do RecentFiles[I] := RecentFiles[I + 1];
    with RecentFiles[High(RecentFiles)] do begin
      Link := ALink;
      Caption := ACaption;
      LType := ALType;
    end;
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
  _Proc: TNotifyEvent; _MenuItem: TMenuItem);
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
    MenuItem := _MenuItem;
    ShowMenuItem := true;
  end;
end;

procedure UnRegisterMyHotKey(Key: PHotKeyAction; FHandle: THandle);
begin
  if not Key.Enabled then Exit;
  UnRegisterHotKey(FHandle, Key^.RegKey);
  GlobalDeleteAtom(Key^.RegKey);
end;

function RegisterMyHotKey(Key: PHotKeyAction; FHandle: THandle; Num: Integer; Check: Boolean = false): Boolean;
var
  Modifiers: UINT;
begin
  Result := false;
  if (not Key.Enabled) and (not Check) then Exit;
  Modifiers := 0;
  if Key.Alt then Modifiers := Modifiers or MOD_ALT;
  if Key.Ctrl then Modifiers := Modifiers or MOD_CONTROL;
  if Key.Shift then Modifiers := Modifiers or MOD_SHIFT;
  if Key.Win then Modifiers := Modifiers or MOD_WIN;
  Key.RegKey := GlobalAddAtom(PChar('Keep2MeKey' + inttostr(Num)));
  Result := RegisterHotKey(FHandle, Key^.RegKey, Modifiers, HotKeysArray[Key^.Key].Value);
end;

procedure Autorun(Flag: Boolean; NameParam, Path: String);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', false);
  if Flag then Reg.WriteString(NameParam, Path)
  else Reg.DeleteValue(NameParam);
  Reg.Free;
end;

{ TSmileList }

end.
