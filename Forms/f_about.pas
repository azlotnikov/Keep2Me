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
  sPageControl,
  funcs,
  ConstStrings,
  loaders,
  shortlinks,
  fileuploaders;

type
  TFAbout = class(TForm)
    pgc_tabs: TPageControl;
    ts_info: TTabSheet;
    ts_logs: TTabSheet;
    ts_plugins: TTabSheet;
    img_logo: TImage;
    lbl1: TLabel;
    lbl2: TLabel;
    edt_version: TEdit;
    lbl3: TLabel;
    edt_mail: TEdit;
    lbl4: TLabel;
    mmo_logs: TMemo;
    mmo_modules: TMemo;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    lbl8: TLabel;
    btn_ok: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btn_okClick(Sender: TObject);
    procedure ClickLink(Sender: TObject);
  private
  public
    { Public declarations }
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
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TFAbout.FormCreate(Sender: TObject);
const
  outtext = 'Версия: %s; Имя: %s';
var
  i: integer;
begin
  edt_version.text := SYS_KEEP_VERSION + SYS_PLATFORM;
  with mmo_modules do begin
    Clear;
    for i := 0 to High(LoadersArray) do Lines.Add(Format(outtext, [LoadersArray[i].Version, LoadersArray[i].Caption]));
    for i := 0 to High(ShortersArray) do
        Lines.Add(Format(outtext, [ShortersArray[i].Version, ShortersArray[i].Caption]));
    for i := 0 to High(FileLoadersArray) do
        Lines.Add(Format(outtext, [FileLoadersArray[i].Version, FileLoadersArray[i].Caption]));
  end;
  if FileExists(ExtractFilePath(ParamStr(0)) + SYS_CHANGELOG_FILE) then
      mmo_logs.Lines.LoadFromFile(ExtractFilePath(ParamStr(0)) + SYS_CHANGELOG_FILE)
  else mmo_logs.Lines.text := 'Не удалось загрузить changelog.txt';
end;

end.
