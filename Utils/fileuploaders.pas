unit fileuploaders;

interface

uses
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  Vcl.ComCtrls,
  IdHTTP,
  IdComponent,
  IdCookieManager,
  IdMultipartFormData,
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
    procedure StopLoad;
    procedure LoadFile(FileName: string); virtual; abstract;
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
  TFileLoaderClass = class of TFileLoader;

type
  TFileLoaderElement = record
    Obj: TFileLoaderClass;
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

procedure AddFileLoader(AObj: TFileLoaderClass; ACaption, AVersion: String);
begin
  SetLength(FileLoadersArray, Length(FileLoadersArray) + 1);
  with FileLoadersArray[High(FileLoadersArray)] do begin
    Obj := AObj;
    Caption := ACaption;
    Version := AVersion;
  end;
end;

{ TRgHostFileLoader }

procedure TRgHostFileLoader.LoadFile(FileName: string);
const
  Str = 'http://rghost.ru/';
  Str1 = 'name="authenticity_token" type="hidden" value="';
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
      s := HTTP.Get('http://rghost.ru/');
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

initialization

// AddFileLoader(TSendSpaceFileLoader, 'sendspace.com', '0.1');
AddFileLoader(TRgHostFileLoader, 'rghost.ru', '0.1');

end.
