unit f_imageinfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFImageInfo = class(TForm)
    mmo_faq: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

implementation

{$R *.dfm}

procedure TFImageInfo.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TFImageInfo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.RemoveComponent(self);
  Action := caFree;
end;

procedure TFImageInfo.FormCreate(Sender: TObject);
begin
  Application.InsertComponent(self);
end;

end.
