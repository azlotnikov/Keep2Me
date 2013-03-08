unit loaders;

interface

uses
  Winapi.WinInet,
  System.Classes,
  System.SysUtils,
  Vcl.ComCtrls,
  IdHTTP,
  IdComponent,
  IdMultipartFormData,
  IdCookieManager,
  IdFTP,
  IdFTPCommon;

type
  TLoader = class
  private
    HTTP: TidHTTP;
    COO: TIdCookieManager;
    PB: TProgressBar;
    AError: Boolean;
    Link: String;
    Function GetError: Boolean;
    procedure HTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
  public
    property Error: Boolean read GetError;
    function GetLink: string; virtual;
    procedure SetLoadBar(sPB: TProgressBar); virtual;
    procedure LoadFile(FileName: string); virtual; abstract;
    procedure Free; virtual;
    constructor Create;
  end;

type
  TFTPLoader = class(TLoader)
  private
    FTP: TidFTP;
  public
    procedure SetLoadBar(sPB: TProgressBar); override;
    procedure LoadFile(FileName: string; Host, Path, User, Pass, Port, URL: String; Passive: Boolean); overload;
    procedure Free; override;
    constructor Create;
  end;

type
  TZhykLoader = class(TLoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  THostingKartinokLoader = class(TLoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  TImgLinkLoader = class(TLoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  TImgurLoader = class(TLoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  TQikrLoader = class(TLoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  TTrollWsLoader = class(TLoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  TImgsSuLoader = class(TLoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  TFilezPro = class(TLoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  TLoaderClass = class of TLoader;

type
  LoadersElement = record
    Obj: TLoaderClass;
    Caption: String;
    Version: String;
  end;

var
  LoadersArray: array of LoadersElement;

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

constructor TLoader.Create;
begin
  HTTP := TidHTTP.Create;
  HTTP.ReadTimeout := 30000;
  HTTP.ConnectTimeout := 20000;
  HTTP.HandleRedirects := true;
  HTTP.Request.UserAgent := 'Mozilla/5.0 (Windows NT 6.1) Gecko/20100101 Firefox/9.0.1';
  COO := TIdCookieManager.Create(HTTP);
  HTTP.AllowCookies := true;
  HTTP.CookieManager := COO;
end;

procedure TLoader.Free;
begin
  COO.Free;
  HTTP.Free;
end;

function TLoader.GetError: Boolean;
begin
  Result := AError;
end;

procedure TLoader.HTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  if PB <> nil then PB.Position := AWorkCount div 1024;
end;

procedure TLoader.HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  if PB <> nil then PB.Max := AWorkCountMax div 1024;
end;

procedure TLoader.SetLoadBar(sPB: TProgressBar);
begin
  PB := sPB;
  HTTP.OnWork := HTTPWork;
  HTTP.OnWorkBegin := HTTPWorkBegin;
end;

function TLoader.GetLink: string;
begin
  Result := Link;
end;
{ IZhykLoader }

procedure TZhykLoader.LoadFile(FileName: string);
const
  Str = '<img_url>';
var
  Stream: TIdMultipartFormDataStream;
  s: string;
begin
  try
    Link := '';
    AError := false;
    Stream := TIdMultipartFormDataStream.Create;
    Stream.AddFormField('key', 'Jk8hh9L');
    Stream.AddFile('upload', FileName, 'application/octet-stream');
    Stream.AddFormField('format', 'xml');
    PB.Max := Stream.Size div 1024;
    try
      s := HTTP.Post('http://i.zhyk.ru/api', Stream);
    except
      AError := true;
      Exit;
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

{ IHostingKartinokLoader }

procedure THostingKartinokLoader.LoadFile(FileName: string);
const
  Str = '<img src="http://s5.hostingkartinok.com/uploads/thumbs/';
var
  Stream: TIdMultipartFormDataStream;
  s: string;
begin
  try
    Link := '';
    AError := false;
    Stream := TIdMultipartFormDataStream.Create;
    Stream.AddFile('image_1', FileName, 'application/octet-stream');
    Stream.AddFormField('jpeg_quality', '100%');
    Stream.AddFormField('resize_to', '500px');
    Stream.AddFormField('upload_type', 'standard');
    try
      s := HTTP.Post('http://hostingkartinok.com/process.php', Stream);
    except
    end;
    if (Length(s) = 0) or (Pos(Str, s) = 0) then begin
      AError := true;
      Exit;
    end;
    Link := 'http://s5.hostingkartinok.com/uploads/images/' + ParsSubString(s, Str, '.') + ExtractFileExt(FileName);
  finally
    Stream.Free;
  end;
end;

{ IImgLinkLoader }

procedure TImgLinkLoader.LoadFile(FileName: string);
const
  Str = '[URL=http://imglink.ru] [IMG]';
var
  Stream: TIdMultipartFormDataStream;
  s: string;
begin
  try
    Link := '';
    AError := false;
    Stream := TIdMultipartFormDataStream.Create;
    Stream.AddFile('image1', FileName, 'application/octet-stream');
    Stream.AddFormField('tags1', 'Без тегов');
    Stream.AddFormField('user_uniq_key', 'yes');
    try
      s := HTTP.Post('http://imglink.ru/process.php', Stream);
    except
    end;
    if (Pos(Str, s) = 0) then begin
      AError := true;
      Exit;
    end;
    Link := ParsSubString(s, Str, '[');
  finally
    Stream.Free;
  end;

end;

{ IImgur }

procedure TImgurLoader.LoadFile(FileName: string);
const
  myAPI = '569c6f649f330f39b23b4612b83f9e3a';
  Str = '<original_image>';
var
  Stream: TIdMultipartFormDataStream;
  s: string;
begin
  try
    Link := '';
    AError := false;
    Stream := TIdMultipartFormDataStream.Create;
    Stream.AddFormField('key', myAPI);
    Stream.AddFile('image', FileName, 'application/octet-stream');
    try
      s := HTTP.Post('http://imgur.com/api/upload.xml', Stream);
    except
    end;
    if (Pos(Str, s) = 0) then begin
      AError := true;
      Exit;
    end;
    Link := ParsSubString(s, Str, '<');
  finally
    Stream.Free;
  end;
end;

{ IqikrLoader }

procedure TQikrLoader.LoadFile(FileName: string);
const
  Str = '][IMG]http://qikr.co/';
var
  Stream: TIdMultipartFormDataStream;
  s: string;
begin
  try
    Link := '';
    AError := false;
    HTTP.HandleRedirects := true;
    Stream := TIdMultipartFormDataStream.Create;
    Stream.AddFile('file1', FileName, 'application/octet-stream');
    Stream.AddFormField('caption', '');
    Stream.AddFormField('resize', '0');
    Stream.AddFormField('B1', 'Upload Image');
    try
      s := HTTP.Post('http://qikr.co/upload.php', Stream);
    except
    end;
    if (Pos(Str, s) = 0) then begin
      AError := true;
      Exit;
    end;
    Link := 'http://qikr.co/' + ParsSubString(s, Str, '[/');
  finally
    Stream.Free;
  end;
end;

procedure AddLoader(AObj: TLoaderClass; ACaption, AVersion: String);
begin
  SetLength(LoadersArray, Length(LoadersArray) + 1);
  with LoadersArray[High(LoadersArray)] do begin
    Obj := AObj;
    Caption := ACaption;
    Version := AVersion;
  end;
end;

{ TFTPLoader }

constructor TFTPLoader.Create;
begin
  FTP := TidFTP.Create(nil);
end;

procedure TFTPLoader.Free;
begin
  inherited;
  FTP.Free;
end;

procedure TFTPLoader.LoadFile(FileName: string; Host, Path, User, Pass, Port, URL: String; Passive: Boolean);
begin
  try
    Link := '';
    AError := false;
    if FTP.Connected then begin
      FTP.Abort;
      FTP.Quit;
    end;
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
        FTP.Put(FileName, ExtractFileName(FileName), false);
        FTP.Quit;
        FTP.Disconnect;
      except
        AError := true;
      End;
      if not AError then Link := URL + ExtractFileName(FileName);
    End
    else AError := true;
  finally
  end;
end;

procedure TFTPLoader.SetLoadBar(sPB: TProgressBar);
begin
  PB := sPB;
  FTP.OnWork := HTTPWork;
  FTP.OnWorkBegin := HTTPWorkBegin;
end;

{ TTrollWsLoader }

procedure TTrollWsLoader.LoadFile(FileName: string);
const
  str0 = '<meta content="';
  Str = '"name":"';
var
  Stream: TIdMultipartFormDataStream;
  s, k: string;
begin
  try
    Link := '';
    AError := false;
    HTTP.HandleRedirects := true;
    k := '';
    { try
      s := HTTP.Get('http://troll.ws/');
      except
      end;
      delete(s, Pos(str0, s), 1);
      if Pos(str0, s) = 0 then begin
      AError := true;
      Exit;
      end;
      k := ParsSubString(s, str0, '"'); }
    Stream := TIdMultipartFormDataStream.Create;
    Stream.AddFile('image[image]', FileName, 'application/octet-stream');
    Stream.AddFormField('ut8', '');
    Stream.AddFormField('authenticity_token', k);
    try
      s := HTTP.Post('http://troll.ws/upload_image', Stream);
    except
    end;
    if (Pos(Str, s) = 0) then begin
      AError := true;
      Exit;
    end;
    Link := 'http://i.troll.ws/' + ParsSubString(s, Str, '"');
  finally
    Stream.Free;
  end;
end;

{ TImgsSuLoader }

procedure TImgsSuLoader.LoadFile(FileName: string);
const
  Str = '><img src="';
var
  Stream: TIdMultipartFormDataStream;
  s: string;
begin
  try
    Link := '';
    AError := false;
    HTTP.HandleRedirects := true;
    Stream := TIdMultipartFormDataStream.Create;
    Stream.AddFile('file', FileName, 'application/octet-stream');
    Stream.AddFormField('url', 'http://');
    Stream.AddFormField('resize', '0');
    Stream.AddFormField('retype', '0');
    Stream.AddFormField('quality', '100');
    Stream.AddFormField('rotate', '0');
    try
      s := HTTP.Post('http://imgs.su/', Stream);
    except
    end;
    if (Pos(Str, s) = 0) then begin
      AError := true;
      Exit;
    end;
    Link := ParsSubString(s, Str, '"');
  finally
    Stream.Free;
  end;

end;

{ TFilezPro }

procedure TFilezPro.LoadFile(FileName: string);
const
  Str = 'redirectAfterUpload(''';
  str0 = 'Uploader.startUpload("';
  str1 = '<input type="text" value="';
var
  Stream: TIdMultipartFormDataStream;
  Post: tstringlist;
  s, token: string;
begin
  try
    Link := '';
    AError := false;
    HTTP.HandleRedirects := true;
    Post := tstringlist.Create;
    Stream := TIdMultipartFormDataStream.Create;
    Post.Add('upload_file[]=' + ExtractFileName(FileName));
    Post.Add('private=0');
    Post.Add('member=0');
    try
      s := HTTP.Post('http://filez.pro/link_upload.php', Post);
    except
    end;
    if (Pos(str0, s) = 0) then begin
      AError := true;
      Exit;
    end;
    token := ParsSubString(s, str0, '"');
    Stream.AddFile('upfile_1362636679472', FileName, 'application/octet-stream');
    Stream.AddFormField('private', '0');
    Stream.AddFormField('member', '0');
    try
      s := HTTP.Post('http://filez.pro/cgi-bin/upload.cgi?upload_id=' + token, Stream);
    except
    end;
    if (Pos(Str, s) = 0) then begin
      AError := true;
      Exit;
    end;
    token := ParsSubString(s, Str, '''');
    try
      s := HTTP.Get(token);
    except
    end;
    if (Pos(str1, s) = 0) then begin
      AError := true;
      Exit;
    end;
    Link := ParsSubString(s, str1, '"');
  finally
    Stream.Free;
    Post.Free
  end;
end;

initialization

AddLoader(THostingKartinokLoader, 'hostingkartinok.com', '0.3');
AddLoader(TQikrLoader, 'qikr.co', '0.1');
AddLoader(TImgurLoader, 'imgur.com [API]', '0.1');
AddLoader(TZhykLoader, 'i.zhyk.ru [API]', '0.3');
AddLoader(TImgLinkLoader, 'imglink.ru', '0.1');
AddLoader(TTrollWsLoader, 'troll.ws', '0.3');
AddLoader(TImgsSuLoader, 'imgs.su', '0.1');
AddLoader(TFilezPro, 'filez.pro', '0.1');

end.
