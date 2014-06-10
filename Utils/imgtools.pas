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
  JclGraphics,
  acAlphaImageList;

type
  TRPen = record
  public
    Width: Integer;
    Color: TColor;
  end;

type
  TRBrush = record
  public
    Color: TColor;
    Style: TBrushStyle;
  end;

type
  TFShape = class
  public
    PenF      : TRPen;
    BrushF    : TRBrush;
    PB        : TPaintBox;
    StartPoint: TPoint;
    EndPoint  : TPoint;
    IsDrawing : Boolean;
    IMGSize   : TPoint;
    procedure SetColors(CanvasOut: TCanvas); virtual;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); virtual; abstract;
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); virtual; abstract;
    constructor Create;
  end;

type
  TFSmile = class(TFShape)
  public
    ImagesData: TsAlphaImageList;
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); override;
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
    Text    : string;
    Styles  : TFontStyles;
    FSize   : Integer;
    FontName: TFontName;
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); override;
  end;

type
  TFPencil = class(TFShape)
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

type
  TFSelPencil = class(TFShape)
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

type
  TFArrow = class(TFShape)
  public
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); override;
  end;

type
  TFImg = class(TFShape)
  public
    PasteImg: TBitmap;
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Draw(CanvasOut: TCanvas; Shift: TShiftState = []); override;
    procedure Free;
    constructor Create;
  end;

type
  TFShapeList = class
  private
    UndoIndex: Integer;

  public
    IMG   : TImage;
    Shapes: array of TFShape;
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
    if Result then
      BitmapOut.Assign(Bitmap);
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

  PRow   = ^TRow;
  TRow   = array [0 .. 1000000] of TRGBTriple;
  PPRows = ^TPRows;
  TPRows = array [0 .. 1000000] of PRow;

type
  TRGBTripleArray = array [0 .. 1000] of TRGBTriple;
  PRGBTripleArray = ^TRGBTripleArray;

const
  MaxKernelSize = 100;

type
  TKernelSize = 1 .. MaxKernelSize;

  TKernel = record
    Size: TKernelSize;
    Weights: array [-MaxKernelSize .. MaxKernelSize] of Single;
  end;

procedure MakeGaussianKernel(var K: TKernel; Radius: Double; MaxData, DataGranularity: Double);
var
  J          : Integer;
  Temp, Delta: Double;
  KernelSize : TKernelSize;
begin
  for J := low(K.Weights) to high(K.Weights) do
  begin
    Temp         := J / Radius;
    K.Weights[J] := Exp(-Temp * Temp / 2);
  end;
  Temp           := 0;
  for J          := low(K.Weights) to high(K.Weights) do
    Temp         := Temp + K.Weights[J];
  for J          := low(K.Weights) to high(K.Weights) do
    K.Weights[J] := K.Weights[J] / Temp;
  KernelSize     := MaxKernelSize;
  Delta          := DataGranularity / (2 * MaxData);
  Temp           := 0;
  while (Temp < Delta) and (KernelSize > 1) do
  begin
    Temp := Temp + 2 * K.Weights[KernelSize];
    Dec(KernelSize);
  end;
  K.Size         := KernelSize;
  Temp           := 0;
  for J          := -K.Size to K.Size do
    Temp         := Temp + K.Weights[J];
  for J          := -K.Size to K.Size do
    K.Weights[J] := K.Weights[J] / Temp;
end;

function TrimInt(Lower, Upper, theInteger: Integer): Integer;
begin
  if (theInteger <= Upper) and (theInteger >= Lower) then
    Result := theInteger
  else if theInteger > Upper then
    Result := Upper
  else
    Result := Lower;
end;

function TrimReal(Lower, Upper: Integer; X: Double): Integer;
begin
  if (X < Upper) and (X >= Lower) then
    Result := Trunc(X)
  else if X > Upper then
    Result := Upper
  else
    Result := Lower;
end;

procedure BlurRow(var theRow: array of TRGBTriple; K: TKernel; P: PRow);
var
  J, N      : Integer;
  TR, TG, TB: Double;
  W         : Double;
begin
  for J := 0 to high(theRow) do
  begin
    TB    := 0;
    TG    := 0;
    TR    := 0;
    for N := -K.Size to K.Size do
    begin
      W := K.Weights[N];
      with theRow[TrimInt(0, high(theRow), J - N)] do
      begin
        TB := TB + W * B;
        TG := TG + W * G;
        TR := TR + W * R;
      end;
    end;
    with P[J] do
    begin
      B := TrimReal(0, 255, TB);
      G := TrimReal(0, 255, TG);
      R := TrimReal(0, 255, TR);
    end;
  end;
  Move(P[0], theRow[0], (high(theRow) + 1) * Sizeof(TRGBTriple));
end;

function BitmapBlurGaussian(Bitmap: TBitmap; Radius: Double): Boolean; overload;
var
  Row    : Integer;
  Col    : Integer;
  theRows: PPRows;
  K      : TKernel;
  ACol   : PRow;
  P      : PRow;
begin
  try
    if (Bitmap.HandleType <> bmDIB) or (Bitmap.PixelFormat <> pf24Bit) then
      raise exception.Create('GaussianBlur only works for 24-bit bitmaps');
    MakeGaussianKernel(K, Radius, 255, 1);
    GetMem(theRows, Bitmap.Height * Sizeof(PRow));
    GetMem(ACol, Bitmap.Height * Sizeof(TRGBTriple));

    for Row        := 0 to Bitmap.Height - 1 do
      theRows[Row] := Bitmap.Scanline[Row];

    P       := AllocMem(Bitmap.Width * Sizeof(TRGBTriple));
    for Row := 0 to Bitmap.Height - 1 do
      BlurRow(Slice(theRows[Row]^, Bitmap.Width), K, P);

    ReAllocMem(P, Bitmap.Height * Sizeof(TRGBTriple));
    for Col := 0 to Bitmap.Width - 1 do
    begin
      for Row     := 0 to Bitmap.Height - 1 do
        ACol[Row] := theRows[Row][Col];
      BlurRow(Slice(ACol^, Bitmap.Height), K, P);

      for Row             := 0 to Bitmap.Height - 1 do
        theRows[Row][Col] := ACol[Row];
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
  if ssShift in Shift then
  begin
    if length(Points) = 0 then
      P.Y := StartPoint.Y
    else
      P.Y := Points[high(Points)].Y;
  end;
  SetLength(Points, length(Points) + 1);
  Points[high(Points)] := P;
end;

procedure TFPencil.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
var
  i: Integer;
begin
  if length(Points) = 0 then
    exit;
  SetColors(CanvasOut);
  CanvasOut.MoveTo(Points[0].X, Points[0].Y);
  for i := 0 to high(Points) - 1 do
    CanvasOut.LineTo(Points[i].X, Points[i].Y);
  IMGSize := Point(PB.Width, PB.Height);
end;

{ TFShapeList }

procedure TFShapeList.AddShape(S: TFShape);
var
  i: Integer;
begin
  for i := high(Shapes) - UndoIndex + 1 to high(Shapes) do
    Shapes[i].Free;
  SetLength(Shapes, length(Shapes) - UndoIndex);
  UndoIndex := 0;
  SetLength(Shapes, length(Shapes) + 1);
  Shapes[high(Shapes)] := S;
end;

procedure TFShapeList.Clear;
var
  i: TFShape;
begin
  for i in Shapes do
    i.Free;
  SetLength(Shapes, 0);
end;

function TFShapeList.Undo: Boolean;
begin
  Result := True;
  if length(Shapes) = 0 then
    exit(False);
  if UndoIndex < length(Shapes) then
    Inc(UndoIndex)
  else
    exit(False);
end;

procedure TFShapeList.DeleteLast;
begin
  if length(Shapes) = 0 then
    exit;
  Shapes[high(Shapes)].Free;
  SetLength(Shapes, length(Shapes) - 1);
end;

procedure TFShapeList.DrawAll(CanvasOut: TCanvas);
var
  i: Integer;
begin
  for i := 0 to high(Shapes) - UndoIndex do
  begin
    if (Shapes[i] is TFResize) and ((IMG.Picture.Bitmap.Height > Shapes[i].IMGSize.Y) or
      (IMG.Picture.Bitmap.Width > Shapes[i].IMGSize.X)) then
    else if not(Shapes[i] is TFCut) then
    begin
      IMG.Picture.Bitmap.Height := Shapes[i].IMGSize.Y;
      IMG.Picture.Bitmap.Width  := Shapes[i].IMGSize.X;
    end;
    Shapes[i].Draw(CanvasOut);
    IMG.Picture.Bitmap.Height := Shapes[i].IMGSize.Y;
    IMG.Picture.Bitmap.Width  := Shapes[i].IMGSize.X;
  end;
end;

procedure TFShapeList.Free;
begin
  Clear;
end;

function TFShapeList.Redo: Boolean;
begin
  Result := True;
  if UndoIndex > 0 then
    Dec(UndoIndex)
  else
    exit(False);
end;

{ TFShape }

constructor TFShape.Create;
begin
  BrushF.Style := bsSolid;
end;

procedure TFShape.SetColors(CanvasOut: TCanvas);
begin
  with CanvasOut do
  begin
    Pen.Color   := PenF.Color;
    Pen.Style   := psSolid;
    Pen.Width   := PenF.Width;
    Brush.Color := BrushF.Color;
    Brush.Style := BrushF.Style;
  end;
end;

{ TFLine }

procedure TFLine.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  if ssShift in Shift then
  begin
    if Abs(P.Y - StartPoint.Y) < Abs(P.X - StartPoint.X) then
      P.Y := StartPoint.Y
    else
      P.X := StartPoint.X;
  end;
  EndPoint := P;
  // Draw(CanvasOut);
end;

procedure TFLine.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  SetColors(CanvasOut);
  CanvasOut.MoveTo(StartPoint.X, StartPoint.Y);
  CanvasOut.LineTo(EndPoint.X, EndPoint.Y);
  IMGSize := Point(PB.Width, PB.Height);
end;

{ TFRect }

procedure TFRect.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  if ssShift in Shift then
  begin
    if Abs(P.Y - StartPoint.Y) < Abs(P.X - StartPoint.X) then
      P.Y := StartPoint.Y + (P.X - StartPoint.X)
    else
      P.X := StartPoint.X + (P.Y - StartPoint.Y);
  end;
  EndPoint := P;
  // Draw(CanvasOut);
end;

procedure TFRect.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  SetColors(CanvasOut);
  CanvasOut.Rectangle(StartPoint.X, StartPoint.Y, EndPoint.X, EndPoint.Y);
  IMGSize := Point(PB.Width, PB.Height);
end;

{ TFSelPencil }

procedure TFSelPencil.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  if ssShift in Shift then
  begin
    if length(Points) = 0 then
      P.Y := StartPoint.Y
    else
      P.Y := Points[high(Points)].Y;
  end;
  SetLength(Points, length(Points) + 1);
  Points[high(Points)] := P;
end;

procedure TFSelPencil.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
var
  i       : Integer;
  bm1, bm2: TBitmap;
begin
  bm1 := TBitmap.Create;
  bm1.SetSize(PB.Width, PB.Height);
  bm1.Canvas.CopyRect(Rect(0, 0, bm1.Width, bm1.Height), CanvasOut, Rect(0, 0, bm1.Width, bm1.Height));
  bm2 := TBitmap.Create;
  bm2.Assign(bm1);
  SetColors(bm2.Canvas);
  bm2.Canvas.MoveTo(Points[0].X, Points[0].Y);
  for i := 0 to high(Points) - 1 do
    bm2.Canvas.LineTo(Points[i].X, Points[i].Y);
  CanvasOut.Draw(0, 0, bm1);
  CanvasOut.Draw(0, 0, bm2, 100);
  bm1.Free;
  bm2.Free;
  IMGSize := Point(PB.Width, PB.Height);
end;

{ TFEllipse }

procedure TFEllipse.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  if ssShift in Shift then
  begin
    if Abs(P.Y - StartPoint.Y) < Abs(P.X - StartPoint.X) then
      P.Y := StartPoint.Y + (P.X - StartPoint.X)
    else
      P.X := StartPoint.X + (P.Y - StartPoint.Y);
  end;
  EndPoint := P;
  // Draw(CanvasOut);
end;

procedure TFEllipse.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  SetColors(CanvasOut);
  CanvasOut.Ellipse(StartPoint.X, StartPoint.Y, EndPoint.X, EndPoint.Y);
  IMGSize := Point(PB.Width, PB.Height);
end;

{ TFText }

procedure TFText.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
begin
  EndPoint := P;
  with CanvasOut do
  begin
    Brush.Style := bsClear;
    Pen.Color   := clRed;
    Pen.Width   := 1;
    Pen.Style   := psDashDot;
    Rectangle(StartPoint.X, StartPoint.Y, EndPoint.X, EndPoint.Y);
  end;

end;

procedure TFText.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
var
  MRect: TRect;
begin
  if IsDrawing then
    AddPoint(EndPoint, CanvasOut)
  else
  begin
    MRect := Rect(Min(StartPoint.X, EndPoint.X), Min(StartPoint.Y, EndPoint.Y), Max(StartPoint.X, EndPoint.X),
      Max(StartPoint.Y, EndPoint.Y));
    SetColors(CanvasOut);
    CanvasOut.Brush.Style := bsClear;
    CanvasOut.Font.Color  := PenF.Color;
    CanvasOut.Font.Style  := Styles;
    CanvasOut.Font.Size   := FSize;
    CanvasOut.Font.Name   := FontName;
    if (StartPoint.X = EndPoint.X) or (StartPoint.Y = EndPoint.Y) then
      CanvasOut.TextOut(StartPoint.X - FSize, StartPoint.Y - FSize, Text)
    else
      CanvasOut.TextRect(MRect, Text, [tfWordBreak, tfWordEllipsis]);
    IMGSize := Point(PB.Width, PB.Height);
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
  tmp                   : TBitmap;
begin
  if not IsDrawing then
  begin
    XMin       := Min(EndPoint.X, StartPoint.X);
    YMin       := Min(EndPoint.Y, StartPoint.Y);
    XMax       := Max(EndPoint.X, StartPoint.X);
    YMax       := Max(EndPoint.Y, StartPoint.Y);
    tmp        := TBitmap.Create;
    tmp.Width  := Abs(EndPoint.X - StartPoint.X);
    tmp.Height := Abs(EndPoint.Y - StartPoint.Y);
    tmp.Canvas.CopyRect(Rect(0, 0, tmp.Width, tmp.Height), CanvasOut, Rect(XMin, YMin, XMax, YMax));
    tmp.PixelFormat := pf24Bit;
    BitmapBlurGaussian(tmp, 2.8);
    CanvasOut.Draw(XMin, YMin, tmp);
    IMGSize := Point(PB.Width, PB.Height);
    tmp.Free;
  end
  else
    with CanvasOut do
    begin
      Brush.Style := bsDiagCross;
      Pen.Color   := clRed;
      Pen.Width   := 1;
      Pen.Style   := psSolid;
      Brush.Color := clRed;
      Rectangle(StartPoint.X, StartPoint.Y, EndPoint.X, EndPoint.Y);
    end;
end;

{ TFCut }

procedure TFCut.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState = []);
var
  size_text: string;
begin
  EndPoint := P;
  with CanvasOut do
  begin
    Brush.Style := bsClear;
    Pen.Color   := clRed;
    Pen.Width   := 1;
    Pen.Style   := psDashDot;
    Rectangle(StartPoint.X, StartPoint.Y, EndPoint.X, EndPoint.Y);
    Font.Color  := clRed;
    Font.Style  := [fsBold];
    size_text   := Format('%dx%d', [Abs(StartPoint.X - EndPoint.X), Abs(EndPoint.Y - StartPoint.Y)]);
    Brush.Color := clWhite;
    Brush.Style := bsSolid;
    Pen.Style   := psClear;
    Rectangle(EndPoint.X, EndPoint.Y, EndPoint.X + TextWidth(size_text), EndPoint.Y + TextHeight(size_text));
    TextOut(EndPoint.X, EndPoint.Y, size_text);
  end;
end;

procedure TFCut.Draw(CanvasOut: TCanvas; Shift: TShiftState = []);
var
  bm: TBitmap;
begin
  if IsDrawing then
  begin
    AddPoint(EndPoint, CanvasOut);
  end else begin
    bm        := TBitmap.Create;
    bm.Width  := Abs(StartPoint.X - EndPoint.X);
    bm.Height := Abs(StartPoint.Y - EndPoint.Y);
    bm.Canvas.CopyRect(Rect(0, 0, bm.Width, bm.Height), CanvasOut, Rect(Min(StartPoint.X, EndPoint.X),
      Min(StartPoint.Y, EndPoint.Y), Max(StartPoint.X, EndPoint.X), Max(StartPoint.Y, EndPoint.Y)));
    PB.Width              := bm.Width;
    PB.Height             := bm.Height;
    IMGSize               := Point(PB.Width, PB.Height);
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
  tmp      : TBitmap;
  pW, pH   : Integer;
  size_text: string;
begin
  if IsDrawing then
    with CanvasOut do
    begin
      Brush.Style := bsClear;
      Pen.Style   := psSolid;
      Pen.Color   := clRed;
      Pen.Width   := 2;
      h           := StartPoint.X - EndPoint.X;
      v           := StartPoint.Y - EndPoint.Y;
      if ssShift in Shift then
      begin
        Pen.Color := clGreen;
        h         := Trunc(v * PB.Width / PB.Height);
      end;
      Rectangle(1, 1, PB.Width - h, PB.Height - v);
      Font.Color  := clRed;
      Font.Style  := [fsBold];
      size_text   := Format('%dx%d', [PB.Width - h, PB.Height - v]);
      Brush.Color := clWhite;
      Brush.Style := bsSolid;
      Pen.Style   := psClear;
      Rectangle(PB.Width - h, PB.Height - v, PB.Width - h + TextWidth(size_text),
        PB.Height - v + TextHeight(size_text));
      TextOut(PB.Width - h, PB.Height - v, size_text);
    end
  else begin
    tmp        := TBitmap.Create;
    tmp.Width  := PB.Width;
    tmp.Height := PB.Height;
    if (PB.Width - h) < 1 then
      h := PB.Width - 2;
    if (PB.Height - v) < 1 then
      v := PB.Height - 2;
    tmp.Canvas.CopyRect(Rect(0, 0, tmp.Width, tmp.Height), CanvasOut, Rect(0, 0, tmp.Width, tmp.Height));
    try
      Stretch(PB.Width - h, PB.Height - v, rfLanczos3, 0, tmp);
    except
    end;
    CanvasOut.CopyRect(Rect(0, 0, tmp.Width, tmp.Height), tmp.Canvas, Rect(0, 0, tmp.Width, tmp.Height));
    PB.Width  := tmp.Width;
    PB.Height := tmp.Height;
    IMGSize   := Point(tmp.Width, tmp.Height);
    tmp.Free;
  end;
end;

{ TFSmile }

procedure TFSmile.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState);
begin
  EndPoint := P;
  Draw(CanvasOut, Shift);
end;

procedure TFSmile.Draw(CanvasOut: TCanvas; Shift: TShiftState);
var
  W, h: Integer;
begin
  h := ImagesData.Height div 2;
  W := ImagesData.Width div 2;
  ImagesData.Draw(CanvasOut, EndPoint.X - W, EndPoint.Y - h, 0);
  IMGSize := Point(PB.Width, PB.Height);
end;

{ TFArrow }

procedure TFArrow.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState);
begin
  // if ssShift in Shift then begin
  // if Abs(P.Y - StartPoint.Y) < Abs(P.X - StartPoint.X) then P.Y := StartPoint.Y + (P.X - StartPoint.X)
  // else P.X := StartPoint.X + (P.Y - StartPoint.Y);
  // end;
  EndPoint := P;
end;

procedure DrawArrowHead(Canvas: TCanvas; X, Y: Integer; Angle, LW: Extended);
var
  A1, A2  : Extended;
  Arrow   : array [0 .. 3] of TPoint;
  OldWidth: Integer;
const
  Beta    = 0.275;
  LineLen = 4.74;
  CentLen = 3.5;
begin
  Angle            := Pi + Angle;
  Arrow[0]         := Point(X, Y);
  A1               := Angle - Beta;
  A2               := Angle + Beta;
  Arrow[1]         := Point(X + Round(LineLen * LW * Cos(A1)), Y - Round(LineLen * LW * Sin(A1)));
  Arrow[2]         := Point(X + Round(CentLen * LW * Cos(Angle)), Y - Round(CentLen * LW * Sin(Angle)));
  Arrow[3]         := Point(X + Round(LineLen * LW * Cos(A2)), Y - Round(LineLen * LW * Sin(A2)));
  OldWidth         := Canvas.Pen.Width;
  Canvas.Pen.Width := 1;
  Canvas.Polygon(Arrow);
  Canvas.Pen.Width := OldWidth
end;

procedure DrawArrow(P1, P2: TPoint; Canvas: TCanvas; LW: Extended);
var
  Angle: Extended;
begin
  Angle := ArcTan2(P1.Y - P2.Y, P2.X - P1.X);
  Canvas.MoveTo(P1.X, P1.Y);
  Canvas.LineTo(P2.X - Round(2 * LW * Cos(Angle)), P2.Y + Round(2 * LW * Sin(Angle)));
  DrawArrowHead(Canvas, P2.X, P2.Y, Angle, LW);
end;

procedure TFArrow.Draw(CanvasOut: TCanvas; Shift: TShiftState);
var
  tmpColor: TColor;
begin
  SetColors(CanvasOut);
  tmpColor              := CanvasOut.Brush.Color;
  CanvasOut.Brush.Color := CanvasOut.Pen.Color;
  DrawArrow(StartPoint, EndPoint, CanvasOut, 3 + CanvasOut.Pen.Width);
  CanvasOut.Brush.Color := tmpColor;
  IMGSize               := Point(PB.Width, PB.Height);
end;

{ TFImg }

procedure TFImg.AddPoint(P: TPoint; CanvasOut: TCanvas; Shift: TShiftState);
begin
  EndPoint.X := P.X - (PasteImg.Width div 2);
  EndPoint.Y := P.Y - (PasteImg.Height div 2);
  Draw(CanvasOut, Shift);
end;

constructor TFImg.Create;
begin
  inherited;
  PasteImg             := TBitmap.Create;
  PasteImg.Transparent := True;
end;

procedure TFImg.Draw(CanvasOut: TCanvas; Shift: TShiftState);
begin
  CanvasOut.Draw(EndPoint.X, EndPoint.Y, PasteImg);
  if IsDrawing then
  begin
    CanvasOut.Pen.Width   := 1;
    CanvasOut.Pen.Style   := psDashDot;
    CanvasOut.Pen.Color   := clRed;
    CanvasOut.Brush.Style := bsClear;
    CanvasOut.Rectangle(EndPoint.X, EndPoint.Y, EndPoint.X + PasteImg.Width, EndPoint.Y + PasteImg.Height);
  end;
  IMGSize := Point(PB.Width, PB.Height);
end;

procedure TFImg.Free;
begin
  PasteImg.FreeImage;
  PasteImg.Free;
  inherited;
end;

end.
