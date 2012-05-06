unit f_points;

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
  f_selfield,
  f_image,
  f_framsize,
  funcs;

type
  TFPoints = class(TForm)
    procedure FormShow(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    ActiveSelect: Boolean;
    GLx, GLy: Integer;
    Rx, Ry: Integer;
    bx, by: Integer;
    FSelField: TFSelField;
    FFrameSize: TFFrameSize;
  public
    procedure StartSelect;
  end;

implementation

{$R *.dfm}

procedure TFPoints.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FSelField.Close;
  FFrameSize.Close;
  Action := caFree;
end;

procedure TFPoints.FormCreate(Sender: TObject);
begin
  FSelField := TFSelField.Create(nil);
  FFrameSize := TFFrameSize.Create(nil);
end;

procedure TFPoints.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    Rx := Mouse.CursorPos.X;
    Ry := Mouse.CursorPos.Y;
    bx := X;
    by := Y;
    GLx := X; // координаты начала (Х)
    GLy := Y; // координаты начала (У)
    FSelField.StartSelect;
    with FSelField.shp_sel do begin
      Top := Y; // устанавливаем нашу форму с шэйпом
      Left := X; // в место нажатия мыши и с нулевым размером
      Height := 0;
      Width := 0;
      Visible := true;
    end;
    FFrameSize.Top := Mouse.CursorPos.Y - FFrameSize.Height;
    FFrameSize.Left := Mouse.CursorPos.X;
    FSelField.Show;
    FFrameSize.Show;
    ActiveSelect := true;
  end else begin
    RestoreAllForms;
    Close;
  end;
end;

procedure TFPoints.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if not ActiveSelect then exit;
  // X := Mouse.CursorPos.X;
  // Y := Mouse.CursorPos.Y;
  if (X >= GLx) and (Y >= GLy) then begin
    with FSelField.shp_sel do begin
      Top := GLy;
      Left := GLx;
      Height := Y - GLy;
      Width := X - GLx;
      FFrameSize.Top := Ry - FFrameSize.Height;
      FFrameSize.Left := Rx;
    end;
  end
  else if (X > GLx) and (Y <= GLy) then begin
    with FSelField.shp_sel do begin
      Top := GLy - (GLy - Y);
      Left := GLx;
      Height := GLy - Y;
      Width := X - GLx;
      FFrameSize.Top := Ry;
      FFrameSize.Left := Rx;
    end;
  end
  else if (X <= GLx) and (Y <= GLy) then begin
    with FSelField.shp_sel do begin
      Top := Y;
      Left := X;
      Height := GLy - Y;
      Width := GLx - X;
      FFrameSize.Top := Ry;
      FFrameSize.Left := Rx - FFrameSize.Width;
    end;
  end
  else if (X <= GLx) and (Y > GLy) then begin
    with FSelField.shp_sel do begin
      Left := GLx - (GLx - X);
      Top := GLy;
      Width := GLx - X;
      Height := Y - GLy;
      FFrameSize.Top := Ry - FFrameSize.Height;
      FFrameSize.Left := Rx - FFrameSize.Width;
    end;
  end;
  FFrameSize.lbl_size.Caption := inttostr(abs(X - bx)) + 'x' + inttostr(abs(Y - by));
end;

procedure TFPoints.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  dc: HDC;
  bm: TBitMap;
  dx, dy: Integer;
begin
  X := Mouse.CursorPos.X;
  Y := Mouse.CursorPos.Y;
  ActiveSelect := false;
  FSelField.shp_sel.Visible := false;
  FSelField.Hide;
  FFrameSize.Hide;
  Hide;
  if not(Button = mbLeft) then exit;
  dc := GetDC(0);
  bm := TBitMap.Create;
  bm.Width := FSelField.shp_sel.Width;
  bm.Height := FSelField.shp_sel.Height;
  dx := 0;
  dy := 0;
  if GSettings.MonIndex > 0 then begin
    dx := Screen.Monitors[GSettings.MonIndex - 1].Left;
    dy := Screen.Monitors[GSettings.MonIndex - 1].Top;
  end;
  if (X >= GLx) and (Y >= GLy) then BitBlt(bm.Canvas.Handle, 0, 0, bm.Width, bm.Height, dc, dx + GLx, dy + GLy, SRCCOPY)
  else if (X <= GLx) and (Y <= GLy) then
      BitBlt(bm.Canvas.Handle, 0, 0, bm.Width, bm.Height, dc, dx + X, dy + Y, SRCCOPY)
  else if (X < GLx) and (Y > GLy) then
      BitBlt(bm.Canvas.Handle, 0, 0, bm.Width, bm.Height, dc, dx + X, dy + GLy, SRCCOPY)
  else BitBlt(bm.Canvas.Handle, 0, 0, bm.Width, bm.Height, dc, dx + GLx, dy + Y, SRCCOPY);
  RestoreAllForms;
  with TFImage.Create(nil) do begin
    img.Picture.Assign(bm);
    OriginImg.Assign(bm);
    StartWork;
  end;
  bm.FreeImage;
  bm.Free;
  Close;
end;

procedure TFPoints.FormShow(Sender: TObject);
var
  i, w, h: Integer;
begin
  StartSelect;
  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

procedure TFPoints.StartSelect;
begin
  BoundsRect := MonitorManager.GetRect(GSettings.MonIndex);
end;

end.
