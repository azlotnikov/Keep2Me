unit f_about;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, funcs,
  Vcl.Imaging.jpeg, Vcl.ComCtrls, sPageControl;

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
begin
  lbl_version.Caption := KEEP_VERSION;
end;

end.
