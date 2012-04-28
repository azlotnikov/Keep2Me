unit f_image;

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
  Vcl.Menus,
  Vcl.ImgList,
  Vcl.Clipbrd,
  Vcl.StdCtrls,
  Vcl.Imaging.GIFImg,
  Vcl.Buttons,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.JPEG,
  acAlphaImageList,
  sSpeedButton,
  sDialogs,
  sEdit,
  sSpinEdit,
  f_load,
  funcs,
  imgtools;

type
  TFImage = class(TForm)
    scrlbx: TScrollBox;
    img: TImage;
    mm: TMainMenu;
    mm_menu: TMenuItem;
    mm_Cancel: TMenuItem;
    mm_Load: TMenuItem;
    pnl_Tools: TPanel;
    btn_Brush: TsSpeedButton;
    Images: TsAlphaImageList;
    btn_DoLoad: TsSpeedButton;
    shp_brush: TShape;
    shp_pen: TShape;
    dlg_color: TsColorDialog;
    spin_penwidth: TsSpinEdit;
    lbl_penwidth: TLabel;
    mm_swapcolors: TMenuItem;
    N1: TMenuItem;
    mm_close: TMenuItem;
    mm_DefaultColor: TMenuItem;
    mm_showtools: TMenuItem;
    mm_tools: TMenuItem;
    mm_brush: TMenuItem;
    btn_line: TsSpeedButton;
    mm_deleteall: TMenuItem;
    mm_line: TMenuItem;
    pb: TPaintBox;
    mm_view: TMenuItem;
    mm_copyimg: TMenuItem;
    function GetScreenName: string;
    procedure mm_LoadClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure shp_penMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure shp_brushMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure imgMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure mm_CancelClick(Sender: TObject);
    procedure mm_swapcolorsClick(Sender: TObject);
    procedure mm_closeClick(Sender: TObject);
    procedure mm_DefaultColorClick(Sender: TObject);
    procedure mm_showtoolsClick(Sender: TObject);
    procedure mm_brushClick(Sender: TObject);
    procedure mm_deleteallClick(Sender: TObject);
    procedure mm_lineClick(Sender: TObject);
    procedure pbPaint(Sender: TObject);
    procedure mm_copyimgClick(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  private
    ActiveDraw: Boolean;
    tmpShape: TFShape;
    procedure ReDraw;
  public
    OriginImg: TBitmap;
    ShapeList: TFShapeList;
    procedure StartWork;
  end;

  // var
  // FImage: TFImage;

implementation

{$R *.dfm}

procedure TFImage.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

function TFImage.GetScreenName: string;
begin
  result := 'tmpImg\';
  result := result + timetostr(now) + '-' + datetostr(now);
  result := StringReplace(result, ':', '.', [rfReplaceAll]);
  result := StringReplace(result, '/', '.', [rfReplaceAll]);
  result := result + ImgFormatToText(TImgFormats(GSettings.ImgExtIndex));
end;

procedure TFImage.imgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  scrlbx.SetFocus;
  if Button <> mbLeft then exit;
  ActiveDraw := true;
  if btn_Brush.down then tmpShape := TFPencil.Create;
  if btn_line.down then tmpShape := TFLine.Create;

  tmpShape.PReDraw := ReDraw;
  tmpShape.StartPoint := Point(X, Y);
  pb.Canvas.Pen.Color := shp_pen.Brush.Color;
  pb.Canvas.Pen.Width := spin_penwidth.Value;
  pb.Canvas.Brush.Color := shp_brush.Brush.Color;
  tmpShape.PenF.Color := shp_pen.Brush.Color;
  tmpShape.PenF.Width := spin_penwidth.Value;
  tmpShape.BrushF.Color := shp_brush.Brush.Color;
  tmpShape.AddPoint(Point(X, Y), pb.Canvas);
end;

procedure TFImage.imgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if not ActiveDraw then exit;

  tmpShape.AddPoint(Point(X, Y), pb.Canvas);
end;

procedure TFImage.imgMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not ActiveDraw then exit;
  ActiveDraw := false;
  tmpShape.AddPoint(Point(X, Y), pb.Canvas);
  tmpShape.EndPoint := Point(X, Y);
  ShapeList.AddShape(tmpShape);

end;

procedure TFImage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.RemoveComponent(self);
  ShapeList.Free;
  Action := caFree;
end;

procedure TFImage.FormCreate(Sender: TObject);
begin
  OriginImg := TBitmap.Create;
  ShapeList := TFShapeList.Create;
  Application.InsertComponent(self);
end;

procedure TFImage.mm_brushClick(Sender: TObject);
begin
  btn_Brush.down := true;
end;

procedure TFImage.mm_CancelClick(Sender: TObject);
begin
  ShapeList.DeleteLast;
  ReDraw;
end;

procedure TFImage.mm_DefaultColorClick(Sender: TObject);
begin
  shp_brush.Brush.Color := clWhite;
  shp_pen.Brush.Color := clBlack;
end;

procedure TFImage.mm_deleteallClick(Sender: TObject);
begin
  ShapeList.Clear;
  ReDraw;
end;

procedure TFImage.mm_lineClick(Sender: TObject);
begin
  btn_line.down := true;
end;

procedure TFImage.mm_LoadClick(Sender: TObject);
var
  FSName: String;
  PNGDest: TPNGImage;
  JPGDest: TJPEGImage;
  GIFDest: TGIFImage;
begin
  Hide;
  FSName := ExtractFilePath(paramstr(0)) + GetScreenName;
  ShapeList.DrawAll(img.Canvas);
  try
    case TImgFormats(GSettings.ImgExtIndex) of
      ifJpg: begin
          JPGDest := TJPEGImage.Create;
          JPGDest.Assign(img.Picture.Bitmap);
          JPGDest.CompressionQuality := 100;
          JPGDest.SaveToFile(FSName);
          JPGDest.Free;
        end;
      ifPng: begin
          PNGDest := TPNGImage.Create;
          PNGDest.Assign(img.Picture.Bitmap);
          PNGDest.SaveToFile(FSName);
          PNGDest.Free;
        end;
      ifBmp: begin
          img.Picture.SaveToFile(FSName);
        end;
      ifGif: begin
          GIFDest := TGIFImage.Create;
          GIFDest.Assign(img.Picture.Bitmap);
          GIFDest.SaveToFile(FSName);
          GIFDest.Free;
        end;
    end;
  except
    ShowMessage('Ошибка Сохранения изображения для загрузки');
    exit;
  end;
  img.Picture.Bitmap.FreeImage;
  with TFLoad.Create(nil) do begin
    LoadFile(FSName);
  end;
end;

procedure TFImage.mm_swapcolorsClick(Sender: TObject);
var
  t: Tcolor;
begin
  t := shp_brush.Brush.Color;
  shp_brush.Brush.Color := shp_pen.Brush.Color;
  shp_pen.Brush.Color := t;
end;

procedure TFImage.pbPaint(Sender: TObject);
begin
  ShapeList.DrawAll(pb.Canvas);
  if ActiveDraw then tmpShape.Draw(pb.Canvas);
end;

procedure TFImage.ReDraw;
begin
  pb.Invalidate;

end;

procedure TFImage.mm_showtoolsClick(Sender: TObject);
begin
  mm_showtools.Checked := not mm_showtools.Checked;
  if mm_showtools.Checked then begin
    pnl_Tools.Visible := true;
    scrlbx.Top := 43;
    scrlbx.Height := scrlbx.Height - 43 + 8;
  end else begin
    pnl_Tools.Visible := false;
    scrlbx.Top := 8;
    scrlbx.Height := scrlbx.Height + 43 - 8;
  end;
end;

procedure TFImage.mm_closeClick(Sender: TObject);
begin
  Close;
end;

procedure TFImage.mm_copyimgClick(Sender: TObject);
begin
  ShapeList.DrawAll(img.Canvas);
  Clipboard.Assign(img.Picture);
  img.Picture.Assign(OriginImg);
  pb.Invalidate;
end;

procedure TFImage.shp_brushMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if dlg_color.Execute then shp_brush.Brush.Color := dlg_color.Color;
end;

procedure TFImage.shp_penMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if dlg_color.Execute then shp_pen.Brush.Color := dlg_color.Color;
end;

procedure TFImage.StartWork;
begin
  ShapeList.Clear;
  Show;
  BringToFront;
  pb.Height := img.Height;
  pb.Width := img.Width;
end;

end.
