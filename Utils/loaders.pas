unit loaders;

interface

uses IdHTTP, System.Classes, Vcl.ComCtrls, IdComponent, IdMultipartFormData,
  IdCookieManager;

type
  ILoader = class
  private
    HTTP: TidHTTP;
    COO: TIdCookieManager;
    PB: TProgressBar;
    AError: Boolean;
    Link: String;
    Function GetError: Boolean;
    procedure HTTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
  public
    property Error: Boolean read GetError;
    function GetLink: string; virtual;
    procedure SetLoadBar(sPB: TProgressBar);
    procedure LoadFile(FileName: string); virtual; abstract;
    procedure Free;
    constructor Create;
  end;

type
  IZhykLoader = class(ILoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  IHostingKartinokLoader = class(ILoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  IImgLinkLoader = class(ILoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  IImgurLoader = class(ILoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  IqikrLoader = class(ILoader)
  public
    procedure LoadFile(FileName: string); override;
  end;

type
  TILoaderClass = class of ILoader;

type
  LoadersElement = record
    L: TILoaderClass;
    C: String;
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
  if (Pos(LeftString, defString) = 0) or (Pos(RightString, defString) = 0) then
    Exit;
  Result := Copy(defString, Pos(LeftString, defString) + Length(LeftString),
    PosEx(RightString, defString, Pos(LeftString, defString) +
    Length(LeftString)) - Pos(LeftString, defString) - Length(LeftString));
end;
{ ILoader }

constructor ILoader.Create;
begin
  HTTP := TidHTTP.Create;
  HTTP.ReadTimeout := 30000;
  HTTP.ConnectTimeout := 20000;
  HTTP.HandleRedirects := true;
  HTTP.Request.UserAgent :=
    'Mozilla/5.0 (Windows NT 6.1) Gecko/20100101 Firefox/9.0.1';
  COO := TIdCookieManager.Create(HTTP);
  HTTP.AllowCookies := true;
  HTTP.CookieManager := COO;
end;

procedure ILoader.Free;
begin
  COO.Free;
  HTTP.Free;
end;

function ILoader.GetError: Boolean;
begin
  Result := AError;
end;

procedure ILoader.HTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  PB.Position := AWorkCount div 1024;
end;

procedure ILoader.SetLoadBar(sPB: TProgressBar);
begin
  PB := sPB;
  HTTP.OnWork := HTTPWork;
end;

function ILoader.GetLink: string;
begin
  Result := Link;
end;
{ IZhykLoader }

procedure IZhykLoader.LoadFile(FileName: string);
const
  str_ = '<div class="inputshare"><input tabindex="4" value="[img]';
var
  Stream: TIdMultipartFormDataStream;
  s, key, r: string;
begin
  try
    Link := '';
    AError := false;
    try
      s := HTTP.Get('http://i.zhyk.ru/');
    except
    end;
    if Pos('id="postkey" value="', s) = 0 then
    begin
      AError := true;
      Exit;
    end;
    key := ParsSubString(s, 'id="postkey" value="', '"');
    Stream := TIdMultipartFormDataStream.Create;
    Stream.AddFormField('postkey', key);
    Stream.AddFile('fileup', FileName, 'image/png');
    PB.Max := Stream.Size div 1024;
    try
      s := HTTP.Post('http://i.zhyk.ru/', Stream);
    except
      Stream.Free;
      AError := true;
      Exit;
    end;
    if Pos(str_, s) = 0 then
    begin
      Stream.Free;
      AError := true;
      Exit;
    end;
    r := ParsSubString(s, str_, '[');
    Link := r;
  finally
    Stream.Free;
  end;
end;

procedure AddLoader(A: TILoaderClass; Caption: String);
begin
  SetLength(LoadersArray, Length(LoadersArray) + 1);
  LoadersArray[High(LoadersArray)].L := A;
  LoadersArray[High(LoadersArray)].C := Caption;
end;

{ IHostingKartinokLoader }

procedure IHostingKartinokLoader.LoadFile(FileName: string);
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
    if (Length(s) = 0) or (Pos(Str, s) = 0) then
    begin
      AError := true;
      Exit;
    end;
    Link := ParsSubString(s, Str, '"');
  finally
    Stream.Free;
  end;
end;

{ IImgLinkLoader }

procedure IImgLinkLoader.LoadFile(FileName: string);
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
    if (Pos(Str, s) = 0) then
    begin
      AError := true;
      Exit;
    end;
    Link := ParsSubString(s, Str, '[');
  finally
    Stream.Free;
  end;

end;

{ IImgur }

procedure IImgurLoader.LoadFile(FileName: string);
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
    if (Pos(Str, s) = 0) then
    begin
      AError := true;
      Exit;
    end;
    Link := ParsSubString(s, Str, '<');
  finally
    Stream.Free;
  end;
end;

{ IqikrLoader }

procedure IqikrLoader.LoadFile(FileName: string);
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
    if (Pos(Str, s) = 0) then
    begin
      AError := true;
      Exit;
    end;
    Link := 'http://qikr.co/' + ParsSubString(s, Str, '[/');
  finally
    Stream.Free;
  end;
end;

initialization

AddLoader(IHostingKartinokLoader, 'hostingkartinok.com');
AddLoader(IqikrLoader, 'qikr.co');
AddLoader(IImgurLoader, 'imgur.com');
AddLoader(IZhykLoader, 'i.zhyk.ru');
AddLoader(IImgLinkLoader, 'imglink.ru');

end.
