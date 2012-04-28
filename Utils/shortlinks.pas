unit shortlinks;

interface

uses
  System.Classes,
  Vcl.ComCtrls,
  IdHTTP,
  IdComponent,
  IdCookieManager,
  Web.HTTPApp;

type
  TShorter = class
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
    procedure LoadFile(Url: string); virtual; abstract;
    procedure Free;
    constructor Create;
  end;

type
  TZtAmLoader = class(TShorter)
  public
    procedure LoadFile(Url: string); override;
  end;

type
  TTinyUrlLoader = class(TShorter)
  public
    procedure LoadFile(Url: string); override;
  end;

type
  TIsGdLoader = class(TShorter)
  public
    procedure LoadFile(Url: string); override;
  end;

type
  TQikrLoader = class(TShorter)
  public
    procedure LoadFile(Url: string); override;
  end;

type
  TShorterClass = class of TShorter;

type
  ShortersElement = record
    L: TShorterClass;
    C: String;
  end;

var
  ShortersArray: array of ShortersElement;

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

constructor TShorter.Create;
begin
  HTTP := TidHTTP.Create;
  HTTP.ReadTimeout := 12000;
  HTTP.ConnectTimeout := 20000;
  HTTP.HandleRedirects := true;
  HTTP.Request.UserAgent := 'Mozilla/5.0 (Windows NT 6.1) Gecko/20100101 Firefox/9.0.1';
  COO := TIdCookieManager.Create(HTTP);
  HTTP.AllowCookies := true;
  HTTP.CookieManager := COO;
end;

procedure TShorter.Free;
begin
  COO.Free;
  HTTP.Free;
end;

function TShorter.GetError: Boolean;
begin
  Result := AError;
end;

procedure TShorter.HTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  PB.Position := AWorkCount div 1024;
end;

procedure TShorter.SetLoadBar(sPB: TProgressBar);
begin
  PB := sPB;
  HTTP.OnWork := HTTPWork;
end;

function TShorter.GetLink: string;
begin
  Result := Link;
end;
{ IZhykLoader }

procedure TZtAmLoader.LoadFile(Url: string);
var
  s: string;
begin
  try
    AError := false;
    Link := '';
    try
      s := HTTP.get('http://zt.am/go.php?u=' + Url);
    except
    end;
    if Pos('http', s) > 0 then Link := s
    else AError := true;
  finally
  end;
end;

procedure AddShorter(A: TShorterClass; Caption: String);
begin
  SetLength(ShortersArray, Length(ShortersArray) + 1);
  ShortersArray[High(ShortersArray)].L := A;
  ShortersArray[High(ShortersArray)].C := Caption;
end;

{ ITinyCCLoader }

procedure TTinyUrlLoader.LoadFile(Url: string);
const
  Str = '</b><br><small>[<a href="';
var
  s: string;
begin
  try
    AError := false;
    Link := '';
    Url := HTTPEncode(Url);
    try
      s := HTTP.get('http://tinyurl.com/create.php?source=indexpage&url=' + Url + '&submit=Make+TinyURL%21&alias=');
    except
    end;
    if Pos(Str, s) = 0 then begin
      AError := true;
      Exit;
    end;
    Link := ParsSubString(s, Str, '"');
  finally
  end;
end;

{ IIsGdlLoader }

procedure TIsGdLoader.LoadFile(Url: string);
const
  Str = 'class="tb" id="short_url" value="';
var
  s: string;
  post: tstringlist;
begin
  try
    AError := false;
    Link := '';
    post := tstringlist.Create;
    post.add('url=' + Url);
    post.add('shorturl=');
    post.add('opt=0');
    try
      s := HTTP.post('http://is.gd/create.php', post);
    except
    end;
    if Pos(Str, s) = 0 then begin
      AError := true;
      Exit;
    end;
    Link := ParsSubString(s, Str, '"');
  finally
    post.Free;
  end;
end;

{ IAddflyLoader }

procedure TQikrLoader.LoadFile(Url: string);
const
  Str = '&nbsp;&nbsp;&nbsp;&nbsp;http://qikr.co/';
var
  s: string;
begin
  try
    AError := false;
    Link := '';
    // Url := HTTPEncode(Url);
    try
      s := HTTP.get('http://qikr.co/submit.php?url=' + Url);
    except
    end;
    if Pos(Str, s) = 0 then begin
      AError := true;
      Exit;
    end;
    Link := 'http://qikr.co/' + ParsSubString(s, Str, '&nbsp');
  finally
  end;
end;

initialization

AddShorter(TIsGdLoader, 'is.gd');
AddShorter(TZtAmLoader, 'zt.am');
AddShorter(TQikrLoader, 'qikr.co');
AddShorter(TTinyUrlLoader, 'tinyurl.com');

end.
