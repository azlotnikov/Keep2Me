unit f_load;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.shellapi,
  Winapi.Wininet,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.IniFiles,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Buttons,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,
  Vcl.Clipbrd,
  Vcl.IdAntiFreeze,
  Vcl.ExtCtrls,
  Vcl.Imaging.PNGImage,
  HTTPApp,
  IdBaseComponent,
  IdAntiFreezeBase,
  JvTrayIcon,
  acAlphaImageList,
  sSpeedButton,
  loaders,
  funcs,
  shortlinks,
  ConstStrings;

type
  TFLoad = class(TForm)
  published
    pb            : TProgressBar;
    mmo_Link      : TMemo;
    btn_Copy      : TsSpeedButton;
    btn_Open      : TsSpeedButton;
    Images        : TsAlphaImageList;
    lbl_link      : TLabel;
    cbb_view      : TComboBox;
    tmr_selfkill  : TTimer;
    tmr_killEditor: TTimer;
    btn_QRCode    : TsSpeedButton;
    img_qr        : TImage;
    procedure btn_CopyClick(Sender: TObject);
    procedure btn_OpenClick(Sender: TObject);
    procedure cbb_viewChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmr_selfkillTimer(Sender: TObject);
    procedure tmr_killEditorTimer(Sender: TObject);
    procedure btn_QRCodeClick(Sender: TObject);
  private
    OriginLink   : string;
    EditorToKill : TForm;
    CloseForm    : Boolean;
    CanClose     : Boolean;
    DontDeleteImg: Boolean;
    QrDone       : Boolean;
    procedure SavePlacement;
    procedure LoadPlacement;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public

    procedure LoadFile(FileName: string; Editor: TForm);
    constructor CreateEx(FileName: string; Editor: TForm; ADontDeleteImg: Boolean = false);
  end;

implementation

{$R *.dfm}

procedure TFLoad.btn_CopyClick(Sender: TObject);
begin
  Clipboard.AsText := mmo_Link.Text;
end;

procedure TFLoad.btn_OpenClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(OriginLink), nil, nil, SW_SHOW);
end;

procedure TFLoad.btn_QRCodeClick(Sender: TObject);
const
  UrlGoogleQrCode = 'http://chart.apis.google.com/chart?chs=%dx%d&cht=qr&chld=%s&chl=%s';
var
  URL        : string;
  ImageStream: TMemoryStream;
  PNGImage   : TPngImage;
  procedure WinInet_HttpGet(const URL: string; Stream: TStream);
  const
    BuffSize = 1024 * 1024;
  var
    hInter   : HINTERNET;
    UrlHandle: HINTERNET;
    BytesRead: DWORD;
    Buffer   : Pointer;
  begin
    hInter := InternetOpen('', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
    if Assigned(hInter) then
    begin
      Stream.Seek(0, 0);
      GetMem(Buffer, BuffSize);
      try
        UrlHandle := InternetOpenUrl(hInter, PChar(URL), nil, 0, INTERNET_FLAG_RELOAD, 0);
        if Assigned(UrlHandle) then
        begin
          repeat
            InternetReadFile(UrlHandle, Buffer, BuffSize, BytesRead);
            if BytesRead > 0 then
              Stream.WriteBuffer(Buffer^, BytesRead);
          until BytesRead = 0;
          InternetCloseHandle(UrlHandle);
        end;
      finally
        FreeMem(Buffer);
      end;
      InternetCloseHandle(hInter);
    end
  end;

begin
  if QrDone then
    exit;
  QrDone         := true;
  ClientWidth    := 568;
  img_qr.Picture := nil;
  ImageStream    := TMemoryStream.Create;
  PNGImage       := TPngImage.Create;
  try
    try
      URL := Format(UrlGoogleQrCode, [146, 146, 'L', HTTPEncode(OriginLink)]);
      WinInet_HttpGet(URL, ImageStream);
      if ImageStream.Size > 0 then
      begin
        ImageStream.Position := 0;
        PNGImage.LoadFromStream(ImageStream);
        img_qr.Picture.Assign(PNGImage);
      end;
    except
      on E: exception do
        ShowMessage(E.Message);
    end;
  finally
    ImageStream.Free;
    PNGImage.Free;
  end;
end;

procedure TFLoad.cbb_viewChange(Sender: TObject);
begin
  case cbb_view.ItemIndex of
    0:
      mmo_Link.Text := OriginLink;
    1:
      mmo_Link.Text := Format('[IMG]%s[/IMG]', [OriginLink]);
    2:
      mmo_Link.Text := Format('[URL]%s[/URL]', [OriginLink]);
    3:
      mmo_Link.Text := Format('<img src="%s">', [OriginLink]);
    4:
      mmo_Link.Text := Format('<a href="%s">%s</a>', [OriginLink, OriginLink]);
  end;
  if GSettings.CopyLink then
    Clipboard.AsText := mmo_Link.Text;
end;

constructor TFLoad.CreateEx(FileName: string; Editor: TForm; ADontDeleteImg: Boolean = false);
begin
  Create(nil);
  Application.InsertComponent(self);
  DontDeleteImg := ADontDeleteImg;
  LoadPlacement;
  EditorToKill := Editor;
  CanClose     := false;
  LoadFile(FileName, Editor);
end;

procedure TFLoad.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle   := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TFLoad.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if not CanClose then
  begin
    Action := caNone;
    exit;
  end;
  SavePlacement;
  Application.RemoveComponent(self);
  Action := caFree;
end;

procedure TFLoad.LoadFile(FileName: string; Editor: TForm);
  procedure ReTry;
  begin
    case MessageDlg('Ошибка загрузки. Попробовать еще раз?', mtConfirmation, mbYesNoCancel, 0) of
      mrYes:
        LoadFile(FileName, Editor);
      mrNo:
        begin
          CloseForm := true;
          CanClose  := true;
          if not DontDeleteImg then
            DeleteFile(FileName);
          tmr_killEditor.Enabled := true;
        end;
      mrCancel:
        begin
          if not DontDeleteImg then
            DeleteFile(FileName);
          CanClose := true;
          if Editor <> nil then
            Editor.Show;
          tmr_selfkill.Enabled := true;
        end;
    end;

  end;
  procedure EnableBtns(B: Boolean);
  begin
    cbb_view.Enabled   := B;
    btn_Open.Enabled   := B;
    btn_Copy.Enabled   := B;
    btn_QRCode.Enabled := B;
  end;

var
  Cloader : TLoader;
  CShorter: TShorter;
  r       : string;
begin
  try
    mmo_Link.Clear;
    OriginLink := '';
    EnableBtns(false);
    if not GSettings.HideLoadForm then
      Show;
    if GSettings.FTP.ImgLoad then
    begin
      Cloader := TFTPLoader.Create;
      Cloader.SetLoadBar(pb);
      with GSettings.FTP do
        (Cloader as TFTPLoader).LoadFile(FileName, Host, Path, User, Pass, Port, URL, Passive);
    end else begin
      Cloader := LoadersArray[GSettings.LoaderIndex].Obj.Create;
      Cloader.SetLoadBar(pb);
      Cloader.LoadFile(FileName);
    end;
  finally
    if Cloader.Error then
    begin
      Cloader.Free;
      ReTry;
    end else begin
      if not DontDeleteImg then
        DeleteFile(FileName);
      r := Cloader.GetLink;
      AddToRecentFiles(r, ExtractFileName(FileName), rfImg);
      if (GSettings.ShortImg) then
        try
          CShorter := ShortersArray[GSettings.ShortLinkIndex].Obj.Create;
          CShorter.SetLoadBar(pb);
          CShorter.LoadFile(r);
          if CShorter.Error then
            GSettings.TrayIcon.BalloonHint(SYS_KEEP2ME, 'Не удалось укоротить ссылку')
          else
            r := CShorter.GetLink;
        except
          FreeAndNil(CShorter);
        end;
      CloseForm     := false;
      OriginLink    := r;
      mmo_Link.Text := r;
      cbb_viewChange(nil);
      if GSettings.CopyLink then
        Clipboard.AsText := mmo_Link.Text;
      FreeAndNil(Cloader);
      pb.Position := pb.Max;
      EnableBtns(true);
      GSettings.TrayIcon.Hint := r;
      if GSettings.ShowInTray then
        GSettings.TrayIcon.BalloonHint('Изображение загружено', r, btInfo, 4000, false);
      CanClose               := true;
      tmr_killEditor.Enabled := true;
    end;
  end;
end;

procedure TFLoad.SavePlacement;
var
  F: TIniFile;
begin
  F := TIniFile.Create(SYS_PATH + SYS_LINK_FORM_NAME);
  F.WriteInteger('Form', 'ViewIndex', cbb_view.ItemIndex);
  F.Free;
end;

procedure TFLoad.LoadPlacement;
var
  F: TIniFile;
begin
  F                  := TIniFile.Create(SYS_PATH + SYS_LINK_FORM_NAME);
  cbb_view.ItemIndex := F.ReadInteger('Form', 'ViewIndex', cbb_view.ItemIndex);
  F.Free;
end;

procedure TFLoad.tmr_killEditorTimer(Sender: TObject);
begin
  if EditorToKill <> nil then
    EditorToKill.Close;
  if CloseForm then
  begin
    CanClose := true;
    Close;
  end;
  tmr_killEditor.Enabled := false;
end;

procedure TFLoad.tmr_selfkillTimer(Sender: TObject);
begin
  tmr_selfkill.Enabled := false;
  Close;
end;

end.
