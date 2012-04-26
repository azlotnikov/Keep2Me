unit imgtools;

interface

uses Windows, SysUtils, Classes, Graphics, Types;

type
  TRPen = record
    Width: Integer;
    Color: TColor;
  end;

type
  TRBrush = record
    Color: TColor;
  end;

type
  TFShape = class
  public
    PenF: TRPen;
    BrushF: TRBrush;
    PReDraw: procedure of object;
    StartPoint: TPoint;
    EndPoint: TPoint;
    procedure SetColors(CanvasOut: TCanvas); virtual;
    procedure Draw(CanvasOut: TCanvas); virtual; abstract;
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas); virtual; abstract;
    constructor Create;
  end;

Type
  TFPencil = class(TFShape) // Карандаш
  private
    Points: array of TPoint;
  public
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas); override;
    procedure Draw(CanvasOut: TCanvas); override;
  end;

type
  TFLine = class(TFShape)
  public
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas); override;
    procedure Draw(CanvasOut: TCanvas); override;
  end;

Type
  TFShapeList = class
  private
    Shapes: array of TFShape;
  public
    procedure AddShape(S: TFShape);
    procedure DrawAll(CanvasOut: TCanvas);
    procedure Clear;
    procedure Free;
    function DeleteLast: Boolean;
  end;

implementation

{ TFPencil }

procedure TFPencil.AddPoint(P: TPoint; CanvasOut: TCanvas);
begin
  SetLength(Points, Length(Points) + 1);
  Points[High(Points)] := P;
  if Length(Points) < 2 then
    exit;
  CanvasOut.MoveTo(Points[High(Points) - 1].X, Points[High(Points) - 1].Y);
  CanvasOut.LineTo(P.X, P.Y);
end;

procedure TFPencil.Draw(CanvasOut: TCanvas);
var
  i: Integer;
begin
  if Length(Points) = 0 then
    exit;
  SetColors(CanvasOut);
  if Length(Points) = 1 then
  begin
    SetLength(Points, Length(Points) + 1);
    Points[High(Points)] := Point(Points[0].X + 1, Points[0].Y + 1);
  end;
  CanvasOut.MoveTo(Points[0].X, Points[0].Y);
  for i := 0 to High(Points) - 1 do
    CanvasOut.LineTo(Points[i].X, Points[i].Y);
end;

{ TFShapeList }

procedure TFShapeList.AddShape(S: TFShape);
begin

  SetLength(Shapes, Length(Shapes) + 1);
  Shapes[High(Shapes)] := S;
end;

procedure TFShapeList.Clear;
var
  i: TFShape;
begin
  for i in Shapes do
    i.Free;
  SetLength(Shapes, 0);
end;

function TFShapeList.DeleteLast: Boolean;
begin
  result := True;
  if Length(Shapes) = 0 then
    exit(false);
  Shapes[High(Shapes)].Free;
  SetLength(Shapes, Length(Shapes) - 1);
end;

procedure TFShapeList.DrawAll(CanvasOut: TCanvas);
var
  i: TFShape;
begin
  for i in Shapes do
    i.Draw(CanvasOut);
end;

procedure TFShapeList.Free;
begin
  Clear;
end;

{ TFShape }

constructor TFShape.Create;
begin

end;

procedure TFShape.SetColors(CanvasOut: TCanvas);
begin
  CanvasOut.Pen.Color := PenF.Color;
  CanvasOut.Pen.Width := PenF.Width;
  CanvasOut.Brush.Color := BrushF.Color;
end;

{ TFLine }

procedure TFLine.AddPoint(P: TPoint; CanvasOut: TCanvas);
begin
  EndPoint := P;
  PReDraw;
  Draw(CanvasOut);
end;

procedure TFLine.Draw(CanvasOut: TCanvas);
begin
  SetColors(CanvasOut);
  CanvasOut.MoveTo(StartPoint.X, StartPoint.Y);
  CanvasOut.LineTo(EndPoint.X, EndPoint.Y);
end;

end.
