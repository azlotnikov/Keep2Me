unit fileuploaders;

interface

uses
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  System.IniFiles,
  System.WideStrUtils,
  Vcl.ComCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Controls,
  IdHTTP,
  IdComponent,
  IdCookieManager,
  IdMultipartFormData,
  IdFTP,
  IdFTPCommon,
  IdHashMessageDigest,
  Web.HTTPApp,
  ConstStrings,
  cript;

type
  THttpWorkEvent = procedure(Sender: TObject; Text: string) of object;

type
  TFileLoader = class
  private
    MaxWorkCount: Int64;
    HTTP: TidHTTP;
    COO: TIdCookieManager;
    AError: Boolean;
    Link: String;
    procedure HTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
  public
    OnHTTPWork: THttpWorkEvent;
    property Error: Boolean read AError;
    function GetLink: string; virtual;
    procedure StopLoad; virtual;
    procedure LoadFile(FileName: string); virtual; abstract;
    procedure InitControls(Control: TWinControl); virtual;
    procedure SaveData; virtual;
    procedure LoadData; virtual;
    procedure LoadControls; virtual;
    procedure Free;
    constructor Create;
  end;

type
  TFTPFileLoader = class(TFileLoader)
  private
    FTP: TIdFTP;
  public

    procedure StopLoad; override;
    procedure LoadFile(FileName: string; Host, Path, User, Pass, Port, URL: String; Passive: Boolean); overload;
    procedure Free;
    constructor Create;
  end;

type
  TSendSpaceFileLoader = class(TFileLoader)
  private
    cb_Auth: TCheckBox;
    Auth: Boolean;
    Login, Pass: String;
    edt_login, edt_pass: TEdit;
    lbl_login, lbl_pass: TLabel;
  public
    procedure InitControls(Control: TWinControl); override;
    procedure SaveData; override;
    procedure LoadData; override;
    procedure LoadControls; override;
    procedure LoadFile(FileName: string); override;
  end;

type
  TRgHostFileLoader = class(TFileLoader)
  private
    cb_Auth: TCheckBox;
    edt_apikey: TEdit;
    ApiKey: String;
    Auth: Boolean;
  public
    procedure InitControls(Control: TWinControl); override;
    procedure SaveData; override;
    procedure LoadData; override;
    procedure LoadControls; override;
    procedure LoadFile(FileName: string); override;
  end;

type
  TZalilRuFileLoader = class(TFileLoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  TFileLoaderClass = class of TFileLoader;

type
  TFileLoaderElement = record
    Obj: TFileLoaderClass;
    Caption: String;
    Version: String;
    HaveSettings: Boolean;
  end;

var
  FileLoadersArray: array of TFileLoaderElement;

implementation

function md5(SourceString: string): string;
var
  md5: TIdHashMessageDigest5;
begin
  Result := '';
  md5 := TIdHashMessageDigest5.Create;
  try
    Result := AnsiLowerCase(md5.HashStringAsHex(SourceString));
  finally
    FreeAndNil(md5);
  end;
end;

function PosEx(SubStr, Str: string; Index: longint): integer;
begin
  delete(Str, 1, index);
  Result := index + Pos(SubStr, Str);
end;

function ParsSubString(defString, LeftString, RightString: string): string;
begin
  Result := '';
  if (Pos(LeftString, defString) = 0) or (Pos(RightString, defString) = 0) then Exit;
  Result := Copy(defString, Pos(LeftString, defString) + Length(LeftString),
    PosEx(RightString, defString, Pos(LeftString, defString) + Length(LeftString)) - Pos(LeftString, defString) -
    Length(LeftString));
end;
{ ILoader }

constructor TFileLoader.Create;
begin
  HTTP := TidHTTP.Create;
  HTTP.ReadTimeout := 12000;
  HTTP.ConnectTimeout := 20000;
  HTTP.HandleRedirects := true;
  HTTP.Request.UserAgent := 'Mozilla/5.0 (Windows NT 6.1) Gecko/20100101 Firefox/9.0.1';
  COO := TIdCookieManager.Create(HTTP);
  HTTP.AllowCookies := true;
  HTTP.CookieManager := COO;
  HTTP.OnWork := HTTPWork;
  HTTP.OnWorkBegin := HTTPWorkBegin;
end;

procedure TFileLoader.HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  MaxWorkCount := AWorkCountMax;
end;

procedure TFileLoader.InitControls(Control: TWinControl);
begin
  { Virtual }
end;

procedure TFileLoader.LoadControls;
begin
  { Virtual }
end;

procedure TFileLoader.LoadData;
begin
  { Virtual }
end;

procedure TFileLoader.SaveData;
begin
  { Virtual }
end;

procedure TFileLoader.StopLoad;
begin
  HTTP.Disconnect;
end;

procedure TFileLoader.Free;
begin
  COO.Free;
  HTTP.Free;
end;

procedure TFileLoader.HTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  OnHTTPWork(Self, Format('%d / %d', [AWorkCount div 1024, MaxWorkCount div 1024]));
end;

function TFileLoader.GetLink: string;
begin
  Result := Link;
end;

{ TSendSpaceFileLoader }

procedure TSendSpaceFileLoader.InitControls(Control: TWinControl);
begin
  cb_Auth := TCheckBox.Create(Control);
  with cb_Auth do begin
    Parent := Control;
    Caption := 'Использовать данные аккаунта';
    Width := 190;
    Top := 8;
    Left := 8;
  end;
  lbl_login := TLabel.Create(Control);
  with lbl_login do begin
    Parent := Control;
    Left := 8;
    Top := cb_Auth.Top + cb_Auth.Height + 10;
    Width := 45;
    Caption := 'Логин:';
  end;
  edt_login := TEdit.Create(Control);
  with edt_login do begin
    Parent := Control;
    Left := 56;
    Width := Control.Width - 36 - 48;
    Anchors := [akLeft, akTop, akRight];
    Top := cb_Auth.Top + cb_Auth.Height + 8;
  end;
  lbl_pass := TLabel.Create(Control);
  with lbl_pass do begin
    Parent := Control;
    Left := 8;
    Top := edt_login.Top + edt_login.Height + 10;
    Width := 45;
    Caption := 'Пароль:';
  end;
  edt_pass := TEdit.Create(Control);
  with edt_pass do begin
    Parent := Control;
    Left := 56;
    Width := Control.Width - 36 - 48;
    PasswordChar := '*';
    Anchors := [akLeft, akTop, akRight];
    Top := edt_login.Top + edt_login.Height + 8;
  end;
  Control.Height := 80 + edt_pass.Top + edt_pass.Height + 8;
  LoadControls;

end;

procedure TSendSpaceFileLoader.LoadControls;
var
  F: TIniFile;
begin
  F := TIniFile.Create(ExtractFilePath(paramstr(0)) + SYS_FILELOADERS_SETTINGS_FILE_NAME);
  with F do begin
    cb_Auth.Checked := ReadBool('SendSpaceFileLoader', 'Auth', false);
    edt_login.Text := ReadString('SendSpaceFileLoader', 'Login', '');
    edt_pass.Text := MyDecrypt(ReadString('SendSpaceFileLoader', 'Password', ''), SYS_CRYPT_KEY);
    Free;
  end;
end;

procedure TSendSpaceFileLoader.LoadData;
var
  F: TIniFile;
begin
  F := TIniFile.Create(ExtractFilePath(paramstr(0)) + SYS_FILELOADERS_SETTINGS_FILE_NAME);
  with F do begin
    Auth := ReadBool('SendSpaceFileLoader', 'Auth', false);
    Login := ReadString('SendSpaceFileLoader', 'Login', '');
    Pass := MyDecrypt(ReadString('SendSpaceFileLoader', 'Password', ''), SYS_CRYPT_KEY);
    Free;
  end;
end;

procedure TSendSpaceFileLoader.SaveData;
var
  F: TIniFile;
begin
  F := TIniFile.Create(ExtractFilePath(paramstr(0)) + SYS_FILELOADERS_SETTINGS_FILE_NAME);
  with F do begin
    WriteBool('SendSpaceFileLoader', 'Auth', cb_Auth.Checked);
    WriteString('SendSpaceFileLoader', 'Login', edt_login.Text);
    WriteString('SendSpaceFileLoader', 'Password', MyEncrypt(edt_pass.Text, SYS_CRYPT_KEY));
    Free;
  end;
end;

procedure TSendSpaceFileLoader.LoadFile(FileName: string);
const
  Str = '<download_url>';
  AStr2 = 'file_id=';
  Str1 = 'status="ok"';
  Str2 = '<upload url="';
  AStr = '<token>';
  Astr1 = '<session_key>';
var
  Stream: TIdMultipartFormDataStream;
  s, uplink: string;
  extrainfo, identifier, maxsize, sessionkey: string;
  token: ansistring;
begin
  try
    Link := '';
    AError := false;
    LoadData;
    Stream := TIdMultipartFormDataStream.Create;
    if not Auth then begin
      try
        s := HTTP.Get
          ('http://api.sendspace.com/rest/?method=anonymous.uploadgetinfo&api_key=XY0ZX82OCN&api_version=1.0');
      except
      end;
      if Pos(Str1, s) = 0 then begin
        AError := true;
        Exit;
      end;
    end else begin
      try
        s := HTTP.Get('http://api.sendspace.com/rest/?method=auth.createToken&api_key=XY0ZX82OCN&api_version=1.0');
      except
      end;
      if Pos(AStr, s) = 0 then begin
        AError := true;
        Exit;
      end;

      token := ParsSubString(s, AStr, '<');
      Pass := md5(Pass);
      Pass := md5(token + Pass);
      try
        s := HTTP.Get('http://api.sendspace.com/rest/?method=auth.login&token=' + token + '&user_name=' + Login +
          '&tokened_password=' + Pass);
      except
      end;
      if Pos(Astr1, s) = 0 then begin
        AError := true;
        Exit;
      end;
      sessionkey := ParsSubString(s, Astr1, '<');
      try
        s := HTTP.Get('http://api.sendspace.com/rest/?method=upload.getInfo&session_key=' + sessionkey +
          '&speed_limit=0');
      except
      end;
      if Pos(Str1, s) = 0 then begin
        AError := true;
        Exit;
      end;
    end;
    uplink := ParsSubString(s, Str2, '"');
    uplink := ReplaceStr(uplink, 'amp;', '');
    extrainfo := ParsSubString(s, 'extra_info="', '"');
    uplink := uplink + '&extra_info=' + extrainfo + '&description=&userfile=' + ExtractfileName(FileName);
    Stream.AddFile('file', FileName, 'multipart/form-data');
    try
      s := HTTP.Put(uplink, Stream);
    except
    end;
    if Auth then begin
      if Pos(AStr2, s) = 0 then begin
        AError := true;
        Exit;
      end;
      Link := 'http://www.sendspace.com/file/' + ParsSubString(s, AStr2, #10);
    end else begin
      if Pos(Str, s) = 0 then begin
        AError := true;
        Exit;
      end;
      Link := ParsSubString(s, Str, '<');
    end;
  finally
    Stream.Free;
  end;
end;

{ TRgHostFileLoader }

procedure TRgHostFileLoader.InitControls(Control: TWinControl);
begin
  cb_Auth := TCheckBox.Create(Control);
  with cb_Auth do begin
    Parent := Control;
    Caption := 'Использовать API ключ';
    Width := 150;
    Top := 8;
    Left := 8;
  end;
  edt_apikey := TEdit.Create(Control);
  with edt_apikey do begin
    Parent := Control;
    Left := 8;
    Width := Control.Width - 36;
    PasswordChar := '*';
    Anchors := [akLeft, akTop, akRight];
    Top := cb_Auth.Top + cb_Auth.Height + 8;
  end;
  Control.Height := 80 + edt_apikey.Top + edt_apikey.Height + 8;
  LoadControls;
end;

procedure TRgHostFileLoader.LoadControls;
var
  F: TIniFile;
begin
  F := TIniFile.Create(ExtractFilePath(paramstr(0)) + SYS_FILELOADERS_SETTINGS_FILE_NAME);
  with F do begin
    cb_Auth.Checked := ReadBool('RgHostFileLoader', 'Auth', false);
    edt_apikey.Text := MyDecrypt(ReadString('RgHostFileLoader', 'ApiKey', ''), SYS_CRYPT_KEY);
    Free;
  end;
end;

procedure TRgHostFileLoader.LoadData;
var
  F: TIniFile;
begin
  F := TIniFile.Create(ExtractFilePath(paramstr(0)) + SYS_FILELOADERS_SETTINGS_FILE_NAME);
  with F do begin
    Auth := ReadBool('RgHostFileLoader', 'Auth', false);
    ApiKey := MyDecrypt(ReadString('RgHostFileLoader', 'ApiKey', ''), SYS_CRYPT_KEY);
    Free;
  end;
end;

procedure TRgHostFileLoader.SaveData;
var
  F: TIniFile;
begin
  F := TIniFile.Create(ExtractFilePath(paramstr(0)) + SYS_FILELOADERS_SETTINGS_FILE_NAME);
  with F do begin
    WriteBool('RgHostFileLoader', 'Auth', cb_Auth.Checked);
    WriteString('RgHostFileLoader', 'ApiKey', MyEncrypt(edt_apikey.Text, SYS_CRYPT_KEY));
    Free;
  end;
end;

procedure TRgHostFileLoader.LoadFile(FileName: string);
const
  HostStr = '"upload_host":"';
  Str = 'http://rghost';
  Str1 = '"authenticity_token":"';
var
  Stream: TIdMultipartFormDataStream;
  s, token, Host: string;
begin
  try
    Link := '';
    AError := false;
    LoadData;
    Stream := TIdMultipartFormDataStream.Create;
    HTTP.HandleRedirects := true;
    try
      s := HTTP.Get('http://rghost.net/multiple/upload_host');
    except
    end;
    if Pos(Str1, s) = 0 then begin
      AError := true;
      Exit;
    end;
    Host := ParsSubString(s, HostStr, '"');
    token := ParsSubString(s, Str1, '"');
    Stream.AddFormField('authenticity_token', token);
    Stream.AddFile('file', FileName, 'multipart/form-data');
    HTTP.HandleRedirects := false;
    if Auth then HTTP.Request.CustomHeaders.Add('X-API-Key: ' + ApiKey);
    try
      s := HTTP.Post('http://' + Host + '/files', Stream);
    except
    end;
    s := HTTP.Response.Location;
    if Pos(Str, s) = 0 then begin
      AError := true;
      Exit;
    end;
    Link := s;
  finally
    Stream.Free;
  end;
end;

procedure AddFileLoader(AObj: TFileLoaderClass; ACaption, AVersion: String; AHaveSettings: Boolean);
begin
  SetLength(FileLoadersArray, Length(FileLoadersArray) + 1);
  with FileLoadersArray[High(FileLoadersArray)] do begin
    Obj := AObj;
    Caption := ACaption;
    Version := AVersion;
    HaveSettings := AHaveSettings;
  end;
end;

{ TFTPFileLoader }

constructor TFTPFileLoader.Create;
begin
  FTP := TIdFTP.Create(nil);
  FTP.OnWork := HTTPWork;
  FTP.OnWorkBegin := HTTPWorkBegin;
end;

procedure TFTPFileLoader.Free;
begin
  FTP.Free;
end;

procedure TFTPFileLoader.LoadFile(FileName, Host, Path, User, Pass, Port, URL: String; Passive: Boolean);
begin
  try
    Link := '';
    AError := false;
    FTP.Host := Host;
    FTP.Username := User;
    FTP.Password := Pass;
    FTP.Port := strtoint(Port);
    FTP.Passive := Passive;
    FTP.TransferType := ftBinary;
    try
      FTP.Connect;
    except
    end;
    If FTP.Connected then Begin
      try
        FTP.ChangeDir(Path);
        FTP.Put(FileName, ExtractfileName(FileName), false);
        FTP.Quit;
      except
        AError := true;
      End;
      if not AError then Link := URL + ExtractfileName(FileName);
    End
    else AError := true;
  finally
  end;
end;

procedure TFTPFileLoader.StopLoad;
begin
  AError := true;
  FTP.Abort;
  FTP.Disconnect;
  FTP.Quit;
end;

{ TZalilRuFileLoader }

procedure TZalilRuFileLoader.LoadFile(FileName: string);
const
  Str = '<div align="center">';
var
  Stream: TIdMultipartFormDataStream;
  s: string;
begin
  try
    Link := '';
    AError := false;
    Stream := TIdMultipartFormDataStream.Create;
    HTTP.HandleRedirects := true;
    Stream.AddFile('file', FileName, 'multipart/form-data');
    HTTP.HandleRedirects := true;
    try
      s := HTTP.Post('http://zalil.ru/upload/', Stream);
    except
    end;
    if Pos(Str, s) = 0 then begin
      AError := true;
      Exit;
    end;
    Link := ParsSubString(s, Str, '<');
  finally
    Stream.Free;
  end;
end;

initialization

AddFileLoader(TRgHostFileLoader, 'rghost.ru [API]', '0.2', true);
AddFileLoader(TSendSpaceFileLoader, 'sendspace.com [API]', '0.1', true);
AddFileLoader(TZalilRuFileLoader, 'zalil.ru', '0.1', false);

end.
