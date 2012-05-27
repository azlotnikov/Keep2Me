unit imgtools;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.Types,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  System.Math,
  JclGraphics;

type
  TRPen = record
    Width: Integer;
    Color: TColor;
  end;

type
  TRBrush = record
    Color: TColor;
    Style: TBrushStyle;
  end;

type
  TFShape = class
  public
    PenF: TRPen;
    BrushF: TRBrush;
    PB: TPaintBox;
    StartPoint: TPoint;
    EndPoint: TPoint;
    IsDrawing: Boolean;
    procedure SetColors(CanvasOut: TCanvas); virtual;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); virtual; abstract;
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); virtual; abstract;
    constructor Create;
  end;

type
  TFResize = class(TFShape)
  public
    h, v: Integer;
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); override;
  end;

type
  TFCut = class(TFShape)
  public
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); override;
  end;

type
  TFText = class(TFShape)
  public
    Text: String;
    Styles: TFontStyles;
    FSize: Integer;
    FontName: TFontName;
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); override;
  end;

Type
  TFPencil = class(TFShape) // Карандаш
  private
    Points: array of TPoint;
  public
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); override;
  end;

type
  TFBlurRect = class(TFShape)
  public
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); override;
  end;

Type
  TFSelPencil = class(TFPencil) // Карандаш
  private
    Points: array of TPoint;
  public
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); override;
  end;

type
  TFLine = class(TFShape)
  public
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); override;
  end;

type
  TFRect = class(TFShape)
  public
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); override;
  end;

type
  TFRectClear = class(TFRect)
  public
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); override;
  end;

type
  TFEllipse = class(TFShape)
  public
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); override;
  end;

type
  TFEllipseClear = class(TFEllipse)
  public
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); override;
  end;

Type
  TFShapeList = class
  private
    UndoIndex: Integer;
    Shapes: array of TFShape;
  public
    procedure AddShape(S: TFShape);
    procedure DrawAll(CanvasOut: TCanvas);
    procedure Clear;
    procedure Free;
    procedure DeleteLast;
    function Undo: Boolean;
    function Redo: Boolean;
  end;

function BitmapBlurGaussian(BitmapSource, BitmapOut: TBitmap; Radius: Double): Boolean; overload;
function BitmapBlurGaussian(Bitmap: TBitmap; Radius: Double): Boolean; overload;

implementation

function BitmapBlurGaussian(BitmapSource, BitmapOut: TBitmap; Radius: Double): Boolean; overload;
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create();
  try
    Result := BitmapBlurGaussian(Bitmap, Radius);
    if Result then BitmapOut.Assign(Bitmap);
  finally
    Bitmap.Free;
  end;
end;

type
  PRGBTriple = ^TRGBTriple;

  TRGBTriple = packed record
    B: Byte;
    G: Byte;
    R: Byte;
  end;

  PRow = ^TRow;
  TRow = Array [0 .. 1000000] of TRGBTriple;
  PPRows = ^TPRows;
  TPRows = Array [0 .. 1000000] of PRow;

const
  MaxKernelSize = 100;

type
  TKernelSize = 1 .. MaxKernelSize;

  TKernel = record
    Size: TKernelSize;
    Weights: Array [-MaxKernelSize .. MaxKernelSize] of Single;
  end;

procedure MakeGaussianKernel(var K: TKernel; Radius: Double; MaxData, DataGranularity: Double);
var
  J: Integer;
  Temp, Delta: Double;
  KernelSize: TKernelSize;
begin
  for J := Low(K.Weights) to High(K.Weights) do begin
    Temp := J / Radius;
    K.Weights[J] := Exp(-Temp * Temp / 2);
  end;
  Temp := 0;
  for J := Low(K.Weights) to High(K.Weights) do Temp := Temp + K.Weights[J];
  for J := Low(K.Weights) to High(K.Weights) do K.Weights[J] := K.Weights[J] / Temp;
  KernelSize := MaxKernelSize;
  Delta := DataGranularity / (2 * MaxData);
  Temp := 0;
  while (Temp < Delta) and (KernelSize > 1) do begin
    Temp := Temp + 2 * K.Weights[KernelSize];
    Dec(KernelSize);
  end;
  K.Size := KernelSize;
  Temp := 0;
  for J := -K.Size to K.Size do Temp := Temp + K.Weights[J];
  for J := -K.Size to K.Size do K.Weights[J] := K.Weights[J] / Temp;
end;

function TrimInt(Lower, Upper, theInteger: Integer): Integer;
begin
  if (theInteger <= Upper) and (theInteger >= Lower) then Result := theInteger
  else if theInteger > Upper then Result := Upper
  else Result := Lower;
end;

function TrimReal(Lower, Upper: Integer; X: Double): Integer;
begin
  if (X < Upper) and (X >= Lower) then Result := Trunc(X)
  else if X > Upper then Result := Upper
  else Result := Lower;
end;

procedure BlurRow(var theRow: array of TRGBTriple; K: TKernel; P: PRow);
var
  J, N: Integer;
  TR, TG, TB: Double;
  W: Double;
begin
  for J := 0 to High(theRow) do begin
    TB := 0;
    TG := 0;
    TR := 0;
    for N := -K.Size to K.Size do begin
      W := K.Weights[N];
      with theRow[TrimInt(0, High(theRow), J - N)] do begin
        TB := TB + W * B;
        TG := TG + W * G;
        TR := TR + W * R;
      end;
    end;
    with P[J] do begin
      B := TrimReal(0, 255, TB);
      G := TrimReal(0, 255, TG);
      R := TrimReal(0, 255, TR);
    end;
  end;
  Move(P[0], theRow[0], (High(theRow) + 1) * Sizeof(TRGBTriple));
end;

function BitmapBlurGaussian(Bitmap: TBitmap; Radius: Double): Boolean; overload;
var
  Row: Integer;
  Col: Integer;
  theRows: PPRows;
  K: TKernel;
  ACol: PRow;
  P: PRow;
begin
  try
    if (Bitmap.HandleType <> bmDIB) or (Bitmap.PixelFormat <> pf24Bit) Then
        raise exception.Create('GaussianBlur only works for 24-bit bitmaps');
    MakeGaussianKernel(K, Radius, 255, 1);
    GetMem(theRows, Bitmap.Height * Sizeof(PRow));
    GetMem(ACol, Bitmap.Height * Sizeof(TRGBTriple));

    for Row := 0 to Bitmap.Height - 1 do theRows[Row] := Bitmap.Scanline[Row];

    P := AllocMem(Bitmap.Width * Sizeof(TRGBTriple));
    for Row := 0 to Bitmap.Height - 1 do BlurRow(Slice(theRows[Row]^, Bitmap.Width), K, P);

    ReAllocMem(P, Bitmap.Height * Sizeof(TRGBTriple));
    for Col := 0 to Bitmap.Width - 1 do begin
      for Row := 0 to Bitmap.Height - 1 do ACol[Row] := theRows[Row][Col];
      BlurRow(Slice(ACol^, Bitmap.Height), K, P);

      for Row := 0 to Bitmap.Height - 1 do theRows[Row][Col] := ACol[Row];
    end;
    FreeMem(theRows);
    FreeMem(ACol);
    ReAllocMem(P, 0);
    Result := True;
  except
    Result := False;
  end;
end;
{ TFPencil }

procedure TFPencil.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  SetLength(Points, Length(Points) + 1);
  Points[High(Points)] := P;
  if Length(Points) < 2 then exit;
  CanvasOut.MoveTo(Points[High(Points) - 1].X, Points[High(Points) - 1].y);
  CanvasOut.LineTo(P.X, P.y);
end;

procedure TFPencil.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
var
  i: Integer;
begin
  if Length(Points) = 0 then exit;
  SetColors(CanvasOut);
  if Length(Points) = 1 then begin
    SetLength(Points, Length(Points) + 1);
    Points[High(Points)] := Point(Points[0].X + 1, Points[0].y + 1);
  end;
  CanvasOut.MoveTo(Points[0].X, Points[0].y);
  for i := 0 to High(Points) - 1 do CanvasOut.LineTo(Points[i].X, Points[i].y);
end;

{ TFShapeList }

procedure TFShapeList.AddShape(S: TFShape);
var
  i: Integer;
begin
  for i := High(Shapes) - UndoIndex + 1 to High(Shapes) do Shapes[i].Free;
  SetLength(Shapes, Length(Shapes) - UndoIndex);
  UndoIndex := 0;
  SetLength(Shapes, Length(Shapes) + 1);
  Shapes[High(Shapes)] := S;
end;

procedure TFShapeList.Clear;
var
  i: TFShape;
begin
  for i in Shapes do i.Free;
  SetLength(Shapes, 0);
end;

function TFShapeList.Undo: Boolean;
begin
  Result := True;
  if Length(Shapes) = 0 then exit(False);
  if UndoIndex < Length(Shapes) then Inc(UndoIndex)
  else exit(False);
end;

procedure TFShapeList.DeleteLast;
begin
  if Length(Shapes) = 0 then exit;
  Shapes[High(Shapes)].Free;
  SetLength(Shapes, Length(Shapes) - 1);
end;

procedure TFShapeList.DrawAll(CanvasOut: TCanvas);
var
  i: Integer;
begin
  for i := 0 to High(Shapes) - UndoIndex do Shapes[i].Draw(CanvasOut);
end;

procedure TFShapeList.Free;
begin
  Clear;
end;

function TFShapeList.Redo: Boolean;
begin
  Result := True;
  if UndoIndex > 0 then Dec(UndoIndex)
  else exit(False);
end;

{ TFShape }

constructor TFShape.Create;
begin
  BrushF.Style := bsSolid;
end;

procedure TFShape.SetColors(CanvasOut: TCanvas);
begin
  with CanvasOut do begin
    Pen.Color := PenF.Color;
    Pen.Style := psSolid;
    Pen.Width := PenF.Width;
    Brush.Color := BrushF.Color;
    Brush.Style := BrushF.Style;
  end;
end;

{ TFLine }

procedure TFLine.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  EndPoint := P;
  Draw(CanvasOut);
end;

procedure TFLine.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  SetColors(CanvasOut);
  CanvasOut.MoveTo(StartPoint.X, StartPoint.y);
  CanvasOut.LineTo(EndPoint.X, EndPoint.y);
end;

{ TFRect }

procedure TFRect.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  EndPoint := P;
  Draw(CanvasOut);
end;

procedure TFRect.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  SetColors(CanvasOut);
  CanvasOut.Rectangle(StartPoint.X, StartPoint.y, EndPoint.X, EndPoint.y);
end;

{ TFSelPencil }

procedure TFSelPencil.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  CanvasOut.Pen.Mode := pmMerge;
  inherited;
  CanvasOut.Pen.Mode := pmCopy;
end;

procedure TFSelPencil.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  CanvasOut.Pen.Mode := pmMerge;
  inherited;
  CanvasOut.Pen.Mode := pmCopy;
end;

{ TFEllipse }

procedure TFEllipse.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  EndPoint := P;
  Draw(CanvasOut);
end;

procedure TFEllipse.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  SetColors(CanvasOut);
  CanvasOut.Ellipse(StartPoint.X, StartPoint.y, EndPoint.X, EndPoint.y);
end;

{ TFText }

procedure TFText.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  EndPoint := P;
  with CanvasOut do begin
    Brush.Style := bsClear;
    Pen.Color := clRed;
    Pen.Width := 1;
    Pen.Style := psDashDot;
    Rectangle(StartPoint.X, StartPoint.y, EndPoint.X, EndPoint.y);
  end;

end;

procedure TFText.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
var
  MRect: TRect;
begin
  if IsDrawing then AddPoint(EndPoint, CanvasOut)
  else begin
    MRect := Rect(Min(StartPoint.X, EndPoint.X), Min(StartPoint.y, EndPoint.y), Max(StartPoint.X, EndPoint.X),
      Max(StartPoint.y, EndPoint.y));
    SetColors(CanvasOut);
    CanvasOut.Brush.Style := bsClear;
    CanvasOut.Font.Color := PenF.Color;
    CanvasOut.Font.Style := Styles;
    CanvasOut.Font.Size := FSize;
    CanvasOut.Font.Name := FontName;
    if (StartPoint.X = EndPoint.X) or (StartPoint.y = EndPoint.y) then
        CanvasOut.TextOut(StartPoint.X - FSize, StartPoint.y - FSize, Text)
    else CanvasOut.TextRect(MRect, Text, [tfWordBreak, tfWordEllipsis]);
  end;
end;

{ TFRectClear }

procedure TFRectClear.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  BrushF.Style := bsClear;
  inherited;
end;

procedure TFRectClear.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  BrushF.Style := bsClear;
  inherited;
end;

{ TFEllipseClear }

procedure TFEllipseClear.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  BrushF.Style := bsClear;
  inherited;
end;

procedure TFEllipseClear.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  BrushF.Style := bsClear;
  inherited;
end;

{ TFBlurRect }

procedure TFBlurRect.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  EndPoint := P;
  Draw(CanvasOut);
end;

procedure TFBlurRect.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
var
  XMin, YMin, XMax, YMax: Integer;
  tmp: TBitmap;
begin
  if not IsDrawing then begin
    XMin := Min(EndPoint.X, StartPoint.X);
    YMin := Min(EndPoint.y, StartPoint.y);
    XMax := Max(EndPoint.X, StartPoint.X);
    YMax := Max(EndPoint.y, StartPoint.y);
    tmp := TBitmap.Create;
    tmp.Width := Abs(EndPoint.X - StartPoint.X);
    tmp.Height := Abs(EndPoint.y - StartPoint.y);
    tmp.Canvas.CopyRect(Rect(0, 0, tmp.Width, tmp.Height), CanvasOut, Rect(XMin, YMin, XMax, YMax));
    tmp.PixelFormat := pf24Bit;
    BitmapBlurGaussian(tmp, 2.8);
    CanvasOut.Draw(XMin, YMin, tmp);
    tmp.Free;
  end
  else
    with CanvasOut do begin
      Brush.Style := bsDiagCross;
      Pen.Color := clRed;
      Pen.Width := 1;
      Pen.Style := psSolid;
      Brush.Color := clRed;
      Rectangle(StartPoint.X, StartPoint.y, EndPoint.X, EndPoint.y);
    end;
end;

{ TFCut }

procedure TFCut.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  EndPoint := P;
  with CanvasOut do begin
    Brush.Style := bsClear;
    Pen.Color := clRed;
    Pen.Width := 1;
    Pen.Style := psDashDot;
    Rectangle(StartPoint.X, StartPoint.y, EndPoint.X, EndPoint.y);
  end;
end;

procedure TFCut.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
var
  bm: TBitmap;
begin
  if IsDrawing then begin
    AddPoint(EndPoint, CanvasOut);
  end else begin
    bm := TBitmap.Create;
    bm.Width := Abs(StartPoint.X - EndPoint.X);
    bm.Height := Abs(StartPoint.y - EndPoint.y);
    bm.Canvas.CopyRect(Rect(0, 0, bm.Width, bm.Height), CanvasOut, Rect(Min(StartPoint.X, EndPoint.X),
      Min(StartPoint.y, EndPoint.y), Max(StartPoint.X, EndPoint.X), Max(StartPoint.y, EndPoint.y)));
    PB.Width := bm.Width;
    PB.Height := bm.Height;
    CanvasOut.Brush.Color := clBtnFace;
    CanvasOut.FillRect(CanvasOut.ClipRect);
    CanvasOut.Draw(0, 0, bm);
    bm.Free;
  end;
end;

{ TFResize }

procedure TFResize.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  EndPoint := P;
  Draw(CanvasOut, Shift);
end;

procedure TFResize.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
var
  rtmp: TJclBitmap32;
  tmp: TBitmap;
  pW, pH: Integer;
begin
  if IsDrawing then
    with CanvasOut do begin
      Brush.Style := bsClear;
      Pen.Color := clRed;
      Pen.Width := 2;
      h := StartPoint.X - EndPoint.X;
      v := StartPoint.y - EndPoint.y;
      if ssShift in Shift then begin
        Pen.Color := clGreen;
        if h > v then v := h
        else if v > h then h := v;
      end;
      Rectangle(1, 1, PB.Width - h, PB.Height - v);
    end
  else begin
    tmp := TBitmap.Create;
    tmp.Width := PB.Width;
    tmp.Height := PB.Height;
    tmp.Canvas.CopyRect(Rect(0, 0, tmp.Width, tmp.Height), CanvasOut, Rect(0, 0, tmp.Width, tmp.Height));
    Stretch(PB.Width - h, PB.Height - v, rfLanczos3, 0, tmp);
    CanvasOut.CopyRect(Rect(0, 0, tmp.Width, tmp.Height), tmp.Canvas, Rect(0, 0, tmp.Width, tmp.Height));
    PB.Width := tmp.Width;
    PB.Height := tmp.Height;
    tmp.Free;
  end;
end;

end.
