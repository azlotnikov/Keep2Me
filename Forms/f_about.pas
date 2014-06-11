unit f_about;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellAPI,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Imaging.jpeg,
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ImgList,
  sPageControl,
  sSpeedButton,
  acAlphaImageList,
  funcs,
  ConstStrings,
  loaders,
  shortlinks,
  fileuploaders;

type
  TFAbout = class(TForm)
    lblLicense: TLabel;
    lblAlphaSkins: TLabel;
    lblThanks: TLabel;
  published
    pgc_tabs     : TPageControl;
    ts_info      : TTabSheet;
    ts_logs      : TTabSheet;
    ts_plugins   : TTabSheet;
    img_logo     : TImage;
    lbl1         : TLabel;
    lbl2         : TLabel;
    edt_version  : TEdit;
    lbl3         : TLabel;
    edt_mail     : TEdit;
    lbl4         : TLabel;
    mmo_logs     : TMemo;
    mmo_modules  : TMemo;
    lbl5         : TLabel;
    lbl7         : TLabel;
    lbl8         : TLabel;
    images       : TsAlphaImageList;
    BtnOk        : TsSpeedButton;
    ts_help      : TTabSheet;
    Lbl_help_main: TLabel;
    Edt_wmr      : TEdit;
    Edt_wmz      : TEdit;
    Edt_yad      : TEdit;
    Lbl_wmr      : TLabel;
    Lbl_wmz      : TLabel;
    Lbl_yad      : TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btn_okClick(Sender: TObject);
    procedure ClickLink(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

var
  FAbout: TFAbout;

implementation

{$R *.dfm}

procedure TFAbout.btn_okClick(Sender: TObject);
begin
  Close;
end;

procedure TFAbout.ClickLink(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar((Sender as TLabel).Caption), nil, nil, SW_SHOW);
end;

procedure TFAbout.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle   := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TFAbout.FormCreate(Sender: TObject);
const
  outtext = '[%s] %-24s %-15s';
var
  i: integer;
begin
  edt_version.text := SYS_KEEP_VERSION + ' ' + SYS_PLATFORM;
  with mmo_modules do
  begin
    Clear;
    for i := 0 to high(LoadersArray) do
      Lines.Add(Format(outtext, [LoadersArray[i].Version, LoadersArray[i].Caption, '(ImageLoader)']));
    for i := 0 to high(ShortersArray) do
      Lines.Add(Format(outtext, [ShortersArray[i].Version, ShortersArray[i].Caption, '(LinkShorter)']));
    for i := 0 to high(FileLoadersArray) do
      Lines.Add(Format(outtext, [FileLoadersArray[i].Version, FileLoadersArray[i].Caption, '(FileLoader)']));
  end;
  if FileExists(SYS_PATH + SYS_CHANGELOG_FILE) then
    mmo_logs.Lines.LoadFromFile(SYS_PATH + SYS_CHANGELOG_FILE)
  else
    mmo_logs.Lines.text := 'Не удалось загрузить changelog.txt';
end;

end.
