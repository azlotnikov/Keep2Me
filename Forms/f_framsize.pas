unit f_framsize;

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
  Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFFrameSize = class(TForm)
    shp_frame: TShape;
    lbl_size: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    procedure ReCalcFormSize;
  end;

implementation

{$R *.dfm}

procedure TFFrameSize.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFFrameSize.FormShow(Sender: TObject);
begin
  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

procedure TFFrameSize.ReCalcFormSize;
begin
  ClientHeight := lbl_size.Height + 2;
  ClientWidth := lbl_size.Width + 2;
end;

end.
