unit f_selfield;

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
  Vcl.ExtCtrls,
  funcs;

type
  TFSelField = class(TForm)
  published
    shp_sel: TShape;
    shp_wnd: TShape;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    procedure StartSelect(Full: Boolean = False);
  end;

implementation

{$R *.dfm}

procedure TFSelField.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFSelField.FormCreate(Sender: TObject);
begin
  Color                 := $00FF00;
  TransparentColorValue := $00FF00;
  TransparentColor      := true;
  shp_sel.Brush.Color   := GSettings.SelColor;
end;

procedure TFSelField.FormShow(Sender: TObject);

begin
  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

procedure TFSelField.StartSelect(Full: Boolean = False);
begin
  BoundsRect := MonitorManager.GetRect(GSettings.MonIndex);
end;

end.
