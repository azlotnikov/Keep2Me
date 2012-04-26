unit f_windows;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, funcs, f_selfield, f_image,
  Vcl.StdCtrls, JclGraphics;

type
  TFWindows = class(TForm)
    procedure FormShow(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    procedure StartSelect;
  end;

var
  FWindows: TFWindows;

implementation

{$R *.dfm}

function WindowSnap(windowHandle: HWND; Bmp: TBitmap): boolean;
var
  R: TRect;
  user32DLLHandle: THandle;
  printWindowAPI: function(sourceHandle: HWND; destinationHandle: HDC;
    nFlags: UINT): BOOL; stdcall;
begin
  result := False;
  user32DLLHandle := GetModuleHandle(user32);
  if user32DLLHandle <> 0 then
  begin
    @printWindowAPI := GetProcAddress(user32DLLHandle, 'PrintWindow');
    if @printWindowAPI <> nil then
    begin
      GetWindowRect(windowHandle, R);
      Bmp.Width := R.Right - R.Left;
      Bmp.Height := R.Bottom - R.Top;
      Bmp.Canvas.Lock;
      try
        result := printWindowAPI(windowHandle, Bmp.Canvas.Handle, 0);
      finally
        Bmp.Canvas.Unlock;
      end;
    end;
  end;
end; (* WindowSnap *)

procedure TFWindows.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  R: TRect;
  H: HWND;
  tBmp: TBitmap;
begin
  if Button = mbRight then
  begin
    Hide;
    H := WindowFromPoint(Mouse.CursorPos);
    H := GetAncestor(H, GA_ROOTOWNER);
    GetWindowRect(H, R);
    Show;
    FSelField.Show;
    with FSelField.shp_wnd do
    begin
      Top := R.Top + 7;
      Left := R.Left + 7;
      Width := R.Width - 14;
      Height := R.Height - 14;
      Visible := true;
    end;
  end
  else if Button = mbLeft then
  begin
    Hide;
    FSelField.Hide;
    H := WindowFromPoint(Mouse.CursorPos);
    H := GetAncestor(H, GA_ROOTOWNER);
    GetWindowRect(H, R);
    FSelField.shp_wnd.Visible := False;
    FSelField.AlphaBlendValue := 100;
    tBmp := TBitmap.Create;
    with TFImage.Create(nil) do
    begin
      WindowSnap(H, tBmp);
      // JclGraphics.ScreenShot(tBmp, 0, 0, R.Right - R.Left, R.Bottom - R.Top, H);
      tBmp.PixelFormat := pf24bit;
      img.Picture.Assign(tBmp);
      OriginImg.Assign(tBmp);
      tBmp.Free;
      StartWork;

    end;
  end;
end;

procedure TFWindows.FormShow(Sender: TObject);
begin
  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or
    SWP_NOMOVE or SWP_NOSIZE);
end;

procedure TFWindows.StartSelect;
var
  i, w, H: Integer;
begin
  begin
    Top := 0;
    Left := 0;
    H := 0;
    w := 0;
    for i := 0 to Screen.MonitorCount - 1 do
    begin
      Inc(H, Screen.Monitors[i].Height);
      Inc(w, Screen.Monitors[i].Width);
    end;
    Width := w;
    Height := H;
  end;
  with FSelField.shp_wnd do
  begin
    Top := 0; // устанавливаем нашу форму с шэйпом
    Left := 0; // в место нажатия мыши и с нулевым размером
    Height := 0;
    Width := 0;
    Visible := true;
  end;
  FSelField.StartSelect(true);
  FSelField.AlphaBlendValue := 200;
  // FSelField.Show;
end;

end.
