unit fileuploaders;

interface

uses
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  Vcl.ComCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  IdHTTP,
  IdComponent,
  IdCookieManager,
  IdMultipartFormData,
  IdFTP,
  Web.HTTPApp;

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
    Function GetError: Boolean;
    procedure HTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
  public
    OnHTTPWork: THttpWorkEvent;
    property Error: Boolean read GetError;
    function GetLink: string; virtual;
    procedure StopLoad; virtual;
    procedure LoadFile(FileName: string); virtual; abstract;
    procedure Free;
    constructor Create;
  end;

type
  TFTPFileLoader = class(TFileLoader)
  private
    FTP: TIdFTP;
  public
    procedure StopLoad; override;
    procedure LoadFile(FileName: string; Host, Path, User, Pass, Port, URL: String); overload;
    procedure Free;
    constructor Create;
  end;

type
  TSendSpaceFileLoader = class(TFileLoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  TRgHostFileLoader = class(TFileLoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  TFileLoaderSettings = class
  public
    procedure InitComponents(Form: TForm); virtual; abstract;
    procedure SaveData; virtual; abstract;
    procedure LoadData; virtual; abstract;
  end;

type
  TRgHostSettings = class(TFileLoaderSettings)
  private
    ApiKey: String;
    cb_Auth: TCheckBox;
    edt_apikey: TEdit;
  public
    // procedure InitComponents(Form: TForm); override;
    // procedure SaveData; override;
    // procedure Free;
  end;

type
  TFileLoaderClass = class of TFileLoader;
  TTFileLoaderSettingsClass = class of TFileLoaderSettings;

type
  TFileLoaderElement = record
    Obj: TFileLoaderClass;
    Settings: TTFileLoaderSettingsClass;
    Caption: String;
    Version: String;
  end;

var
  FileLoadersArray: array of TFileLoaderElement;

implementation

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

procedure TFileLoader.StopLoad;
begin
  HTTP.Disconnect;
end;

procedure TFileLoader.Free;
begin
  COO.Free;
  HTTP.Free;
end;

function TFileLoader.GetError: Boolean;
begin
  Result := AError;
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

procedure TSendSpaceFileLoader.LoadFile(FileName: string);
const
  Str = '<download_url>';
  Str1 = 'status="ok"';
  Str2 = '<upload url="';
var
  Stream: TIdMultipartFormDataStream;
  s, uplink: string;
  extrainfo, identifier, maxsize: string;
begin
  try
    Link := '';
    AError := false;
    Stream := TIdMultipartFormDataStream.Create;
    try
      s := HTTP.Get('http://api.sendspace.com/rest/?method=anonymous.uploadgetinfo&api_key=XY0ZX82OCN&api_version=1.0');
    except
    end;
    if Pos(Str1, s) = 0 then begin
      AError := true;
      Exit;
    end;

    uplink := ParsSubString(s, Str2, '"');
    uplink := Copy(uplink, 1, Pos('&', uplink) - 1);
    // uplink := ReplaceStr(uplink, 'amp;', '');
    extrainfo := ParsSubString(s, 'extra_info="', '"');
    identifier := ParsSubString(s, 'upload_identifier="', '"');
    maxsize := ParsSubString(s, 'max_file_size="', '"');
    // uplink := uplink +'&extra_info='+extrainfo;
    Stream.AddFormField('MAX_FILE_SIZE', maxsize);
    Stream.AddFormField('UPLOAD_IDENTIFIER', identifier);
    Stream.AddFormField('extra_info', extrainfo);
    Stream.AddFile('file', FileName, 'multipart/form-data');
    try
      s := HTTP.Post(uplink, Stream);
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

{ TRgHostFileLoader }

procedure TRgHostFileLoader.LoadFile(FileName: string);
const
  Str = 'http://rghost';
  Str1 = '"authenticity_token":"';
var
  Stream: TIdMultipartFormDataStream;
  s, token: string;
begin
  try
    Link := '';
    AError := false;
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
    token := ParsSubString(s, Str1, '"');
    Stream.AddFormField('authenticity_token', token);
    Stream.AddFile('file', FileName, 'multipart/form-data');
    HTTP.HandleRedirects := false;
    try
      s := HTTP.Post('http://pion.rghost.ru/files', Stream);
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

procedure AddFileLoader(AObj: TFileLoaderClass; ACaption, AVersion: String; ASettings: TTFileLoaderSettingsClass);
begin
  SetLength(FileLoadersArray, Length(FileLoadersArray) + 1);
  with FileLoadersArray[High(FileLoadersArray)] do begin
    Obj := AObj;
    Caption := ACaption;
    Version := AVersion;
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

procedure TFTPFileLoader.LoadFile(FileName, Host, Path, User, Pass, Port, URL: String);
begin
  try
    Link := '';
    AError := false;
    FTP.Host := Host;
    FTP.Username := User;
    FTP.Password := Pass;
    FTP.Port := strtoint(Port);
    try
      FTP.Connect;
    except
    end;
    If FTP.Connected then Begin
      FTP.ChangeDir(Path);
      try
        FTP.Put(FileName, ExtractFileName(FileName), true);
        FTP.Quit;
      except
        AError := true;
      End;
      if not AError then Link := URL + ExtractFileName(FileName);
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

initialization

// AddFileLoader(TSendSpaceFileLoader, 'sendspace.com', '0.1');
AddFileLoader(TRgHostFileLoader, 'rghost.ru', '0.1', nil);

end.
