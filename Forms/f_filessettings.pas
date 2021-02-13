unit f_filessettings;

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
  Vcl.Buttons,
  sSpeedButton,
  Vcl.ExtCtrls,
  Vcl.ImgList,
  acAlphaImageList,
  fileuploaders,
  ConstStrings,
  funcs, System.ImageList;

type
  TFFilesSettings = class(TForm)
  published
    pnl_buttons: TPanel;
    btn_Cancel : TsSpeedButton;
    btn_save   : TsSpeedButton;
    Images     : TsAlphaImageList;
    procedure btn_CancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btn_saveClick(Sender: TObject);
  private
    FileLoader: TFileLoader;
  public
    constructor CreateEx(Loader: TFileLoader; ACaption: string);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

implementation

{$R *.dfm}

procedure TFFilesSettings.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle   := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TFFilesSettings.btn_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFFilesSettings.btn_saveClick(Sender: TObject);
begin
  FileLoader.SaveData;
  Close;
end;

constructor TFFilesSettings.CreateEx(Loader: TFileLoader; ACaption: string);
begin
  Create(nil);
  FileLoader := Loader;
  FileLoader.InitControls(self);
  Caption := ACaption;
  Show;
end;

procedure TFFilesSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FileLoader.Free;
  Action := caFree;
end;

end.
