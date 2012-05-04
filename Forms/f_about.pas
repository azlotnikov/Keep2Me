unit f_about;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
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
  shortlinks;

type
  TFAbout = class(TForm)
    lbl_about: TLabel;
    lbl_version: TLabel;
    img_team: TImage;
    lbl_verscaption: TLabel;
    Pages: TsPageControl;
    pg_Log: TsTabSheet;
    mmo_logs: TMemo;
    pg_thanks: TsTabSheet;
    mmo_info: TMemo;
    pg_Plugins: TsTabSheet;
    mmo_modules: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

var
  FAbout: TFAbout;

implementation

{$R *.dfm}

procedure TFAbout.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TFAbout.FormCreate(Sender: TObject);
var
  i: integer;
begin
  lbl_version.Caption := SYS_KEEP_VERSION;
  with mmo_modules do begin
    Clear;
    for i := 0 to High(LoadersArray) do
        Lines.Add(Format('Имя: %s Версия: %s', [LoadersArray[i].Caption, LoadersArray[i].Version]));
    for i := 0 to High(ShortersArray) do
        Lines.Add(Format('Имя: %s Версия: %s', [ShortersArray[i].Caption, ShortersArray[i].Version]));
  end;
end;

end.
