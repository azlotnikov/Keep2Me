unit f_windows;

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
  // JclGraphics,
  f_selfield,
  f_image,
  funcs;

type
  TFWindows = class(TForm)
  published
    procedure FormShow(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FSelField: TFSelField;
  public
    procedure StartSelect;
  end;

implementation

{$R *.dfm}

function WindowSnap(windowHandle: HWND; Bmp: TBitmap): boolean;
var
  R              : TRect;
  user32DLLHandle: THandle;
  printWindowAPI : function(sourceHandle: HWND; destinationHandle: HDC; nFlags: UINT): BOOL; stdcall;
begin
  result          := False;
  user32DLLHandle := GetModuleHandle(user32);
  if user32DLLHandle <> 0 then
  begin
    @printWindowAPI := GetProcAddress(user32DLLHandle, 'PrintWindow');
    if @printWindowAPI <> nil then
    begin
      GetWindowRect(windowHandle, R);
      Bmp.Width  := R.Right - R.Left;
      Bmp.Height := R.Bottom - R.Top;
      Bmp.Canvas.Lock;
      try
        result := printWindowAPI(windowHandle, Bmp.Canvas.Handle, 0);
      finally
        Bmp.Canvas.Unlock;
      end;
    end;
  end;
end;

procedure TFWindows.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FSelField.Close;
  Action := caFree;
end;

procedure TFWindows.FormCreate(Sender: TObject);
begin
  FSelField := TFSelField.Create(nil);
end;

procedure TFWindows.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  R   : TRect;
  H   : HWND;
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
      Top     := R.Top + 7;
      Left    := R.Left + 7;
      Width   := R.Width - 14;
      Height  := R.Height - 14;
      Visible := true;
    end;
  end else if Button = mbLeft then
  begin
    Hide;
    FSelField.Hide;
    H := WindowFromPoint(Mouse.CursorPos);
    H := GetAncestor(H, GA_ROOTOWNER);
    GetWindowRect(H, R);
    FSelField.shp_wnd.Visible := False;
    // FSelField.AlphaBlendValue := 100;
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
    Close;
  end;
end;

procedure TFWindows.FormShow(Sender: TObject);
begin
  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

procedure TFWindows.StartSelect;
var
  i, w, H: Integer;
begin
  BoundsRect := MonitorManager.GetRect(GSettings.MonIndex);
  FSelField.StartSelect(true);
end;

end.
