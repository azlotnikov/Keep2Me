unit loaders;

interface

uses
  System.Classes,
  Vcl.ComCtrls,
  IdHTTP,
  IdComponent,
  IdMultipartFormData,
  IdCookieManager;

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
  public
    property Error: Boolean read GetError;
    function GetLink: string; virtual;
    procedure SetLoadBar(sPB: TProgressBar);
    procedure LoadFile(FileName: string); virtual; abstract;
    procedure Free;
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
  PB.Position := AWorkCount div 1024;
end;

procedure TLoader.SetLoadBar(sPB: TProgressBar);
begin
  PB := sPB;
  HTTP.OnWork := HTTPWork;
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
  Str = '</label><input class="image-link" type="text" size="92" onclick="this.select();" value="';
var
  Stream: TIdMultipartFormDataStream;
  s: string;
begin
  try
    Link := '';
    AError := false;
    Stream := TIdMultipartFormDataStream.Create;
    Stream.AddFile('image_1', FileName, 'application/octet-stream');
    Stream.AddFormField('jpeg_quality', '70%');
    Stream.AddFormField('resize_to', '500px');
    Stream.AddFormField('upload_type', 'standard');
    PB.Max := Stream.Size div 1024;
    try
      s := HTTP.Post('http://hostingkartinok.com/process.php', Stream);
    except
    end;
    if (Length(s) = 0) or (Pos(Str, s) = 0) then begin
      AError := true;
      Exit;
    end;
    Link := ParsSubString(s, Str, '"');
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
    PB.Max := Stream.Size div 1024;
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
    PB.Max := Stream.Size div 1024;
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
    PB.Max := Stream.Size div 1024;
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

initialization

AddLoader(THostingKartinokLoader, 'hostingkartinok.com', '0.2');
AddLoader(TQikrLoader, 'qikr.co', '0.1');
AddLoader(TImgurLoader, 'imgur.com', '0.1');
AddLoader(TZhykLoader, 'i.zhyk.ru', '0.3');
AddLoader(TImgLinkLoader, 'imglink.ru', '0.1');

end.
