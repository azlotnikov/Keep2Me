unit imgtools;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.Types,
  Vcl.Graphics,
  Vcl.ExtCtrls;

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
    PB: TPaintBox;
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

Type
  TFSelPencil = class(TFPencil) // Карандаш
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

type
  TFRect = class(TFShape)
  public
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas); override;
    procedure Draw(CanvasOut: TCanvas); override;
  end;

type
  TFEllipse = class(TFShape)
  public
    procedure AddPoint(P: TPoint; CanvasOut: TCanvas); override;
    procedure Draw(CanvasOut: TCanvas); override;
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
    function Undo: Boolean;
    function Redo: Boolean;
  end;

implementation

{ TFPencil }

procedure TFPencil.AddPoint(P: TPoint; CanvasOut: TCanvas);
begin
  SetLength(Points, Length(Points) + 1);
  Points[High(Points)] := P;
  if Length(Points) < 2 then exit;
  CanvasOut.MoveTo(Points[High(Points) - 1].x, Points[High(Points) - 1].y);
  CanvasOut.LineTo(P.x, P.y);
end;

procedure TFPencil.Draw(CanvasOut: TCanvas);
var
  i: Integer;
begin
  if Length(Points) = 0 then exit;
  SetColors(CanvasOut);
  if Length(Points) = 1 then begin
    SetLength(Points, Length(Points) + 1);
    Points[High(Points)] := Point(Points[0].x + 1, Points[0].y + 1);
  end;
  CanvasOut.MoveTo(Points[0].x, Points[0].y);
  for i := 0 to High(Points) - 1 do CanvasOut.LineTo(Points[i].x, Points[i].y);
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
  Result := true;
  if Length(Shapes) = 0 then exit(false);
  if UndoIndex < Length(Shapes) then Inc(UndoIndex)
  else exit(false);
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
  Result := true;
  if UndoIndex > 0 then Dec(UndoIndex)
  else exit(false);
end;

{ TFShape }

constructor TFShape.Create;
begin

end;

procedure TFShape.SetColors(CanvasOut: TCanvas);
begin
  with CanvasOut do begin
    Pen.Color := PenF.Color;
    Pen.Style := psSolid;
    Pen.Width := PenF.Width;
    Brush.Color := BrushF.Color;
    Brush.Style := bsSolid;
  end;
end;

{ TFLine }

procedure TFLine.AddPoint(P: TPoint; CanvasOut: TCanvas);
begin
  EndPoint := P;
  PB.Invalidate;
  Draw(CanvasOut);
end;

procedure TFLine.Draw(CanvasOut: TCanvas);
begin
  SetColors(CanvasOut);
  CanvasOut.MoveTo(StartPoint.x, StartPoint.y);
  CanvasOut.LineTo(EndPoint.x, EndPoint.y);
end;

{ TFRect }

procedure TFRect.AddPoint(P: TPoint; CanvasOut: TCanvas);
begin
  EndPoint := P;
  PB.Invalidate;
  Draw(CanvasOut);
end;

procedure TFRect.Draw(CanvasOut: TCanvas);
begin
  SetColors(CanvasOut);
  CanvasOut.Rectangle(StartPoint.x, StartPoint.y, EndPoint.x, EndPoint.y);
end;

{ TFSelPencil }

procedure TFSelPencil.AddPoint(P: TPoint; CanvasOut: TCanvas);
begin
  CanvasOut.Pen.Mode := pmMerge;
  inherited;
  CanvasOut.Pen.Mode := pmCopy;
end;

procedure TFSelPencil.Draw(CanvasOut: TCanvas);
begin
  CanvasOut.Pen.Mode := pmMerge;
  inherited;
  CanvasOut.Pen.Mode := pmCopy;
end;

{ TFEllipse }

procedure TFEllipse.AddPoint(P: TPoint; CanvasOut: TCanvas);
begin
  EndPoint := P;
  PB.Invalidate;
  Draw(CanvasOut);
end;

procedure TFEllipse.Draw(CanvasOut: TCanvas);
begin
  SetColors(CanvasOut);
  CanvasOut.Ellipse(StartPoint.x, StartPoint.y, EndPoint.x, EndPoint.y);
end;

end.
