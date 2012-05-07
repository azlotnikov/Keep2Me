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
  Vcl.ExtDlgs,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Menus,
  Vcl.ImgList,
  Vcl.Clipbrd,
  Vcl.StdCtrls,
  Vcl.Imaging.GIFImg,
  Vcl.Buttons,
  Vcl.Imaging.PNGImage,
  Vcl.Imaging.JPEG,
  acAlphaImageList,
  sSpeedButton,
  sDialogs,
  sEdit,
  sSpinEdit,
  f_load,
  f_textedit,
  funcs,
  imgtools,
  ConstStrings;

type
  TFImage = class(TForm)
    scrlbx: TScrollBox;
    img: TImage;
    mm: TMainMenu;
    mm_menu: TMenuItem;
    mm_undo: TMenuItem;
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
    mm_view: TMenuItem;
    mm_copyimg: TMenuItem;
    mm_SaveToFile: TMenuItem;
    SavePictureDlg: TSavePictureDialog;
    btn_Rect: TsSpeedButton;
    mm_rect: TMenuItem;
    btn_SelPen: TsSpeedButton;
    mm_SelPen: TMenuItem;
    mm_redo: TMenuItem;
    mm_colors: TMenuItem;
    mm_pencolor: TMenuItem;
    mm_brushcolor: TMenuItem;
    btn_Ellipse: TsSpeedButton;
    mm_ellipse: TMenuItem;
    btn_Text: TsSpeedButton;
    mm_text: TMenuItem;
    btn_rectclear: TsSpeedButton;
    btn_ellipseclear: TsSpeedButton;
    mm_rectclear: TMenuItem;
    mm_ellipseclear: TMenuItem;
    btn_Blur: TsSpeedButton;
    mm_blur: TMenuItem;
    pb: TPaintBox;
    procedure mm_LoadClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure shp_penMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure shp_brushMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure imgMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure mm_undoClick(Sender: TObject);
    procedure mm_swapcolorsClick(Sender: TObject);
    procedure mm_closeClick(Sender: TObject);
    procedure mm_DefaultColorClick(Sender: TObject);
    procedure mm_showtoolsClick(Sender: TObject);
    procedure mm_brushClick(Sender: TObject);
    procedure mm_deleteallClick(Sender: TObject);
    procedure mm_lineClick(Sender: TObject);
    procedure mm_copyimgClick(Sender: TObject);
    procedure mm_SaveToFileClick(Sender: TObject);
    procedure mm_rectClick(Sender: TObject);
    procedure mm_SelPenClick(Sender: TObject);
    procedure mm_pencolorClick(Sender: TObject);
    procedure mm_brushcolorClick(Sender: TObject);
    procedure mm_redoClick(Sender: TObject);
    procedure mm_ellipseClick(Sender: TObject);
    procedure mm_textClick(Sender: TObject);
    procedure mm_rectclearClick(Sender: TObject);
    procedure mm_ellipseclearClick(Sender: TObject);
    procedure mm_blurClick(Sender: TObject);
    procedure pbPaint(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  private
    ActiveDraw: Boolean;
    tmpShape: TFShape;
    function GetScreenName: string;
    procedure TextEditFormClose(Sender: TObject; var Action: TCloseAction);
  public
    OriginImg: TBitmap;
    ShapeList: TFShapeList;
    procedure StartWork;
  end;

implementation

{$R *.dfm}

function SaveJPG(bm: TBitmap; FName: String): Integer;
var
  JPGDest: TJPEGImage;
begin
  result := 0;
  try
    JPGDest := TJPEGImage.Create;
    with JPGDest do begin
      Assign(bm);
      CompressionQuality := 100;
      SaveToFile(FName);
    end;
  except
    result := 1;
  end;
  JPGDest.Free;
end;

function SavePNG(bm: TBitmap; FName: String): Integer;
var
  PNGDest: TPNGImage;
begin
  result := 0;
  try
    PNGDest := TPNGImage.Create;
    with PNGDest do begin
      Assign(bm);
      SaveToFile(FName);
    end;
  except
    result := 1;
  end;
  PNGDest.Free;
end;

function SaveBMP(bm: TBitmap; FName: String): Integer;
begin
  result := 0;
  try
    bm.SaveToFile(FName);
  except
    result := 1;
  end;
end;

function SaveGIF(bm: TBitmap; FName: String): Integer;
var
  GIFDest: TGIFImage;
begin
  result := 0;
  try
    GIFDest := TGIFImage.Create;
    with GIFDest do begin
      Assign(bm);
      SaveToFile(FName);
    end;
  except
    result := 1;
  end;
  GIFDest.Free;
end;

procedure TFImage.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

function TFImage.GetScreenName: string;
begin
  result := SYS_TMP_IMG_FOLDER;
  result := result + timetostr(now) + '-' + datetostr(now);
  result := StringReplace(result, ':', '.', [rfReplaceAll]);
  result := StringReplace(result, '/', '.', [rfReplaceAll]);
  result := result + ImgFormatToText(TImgFormats(GSettings.ImgExtIndex));
end;

procedure TFImage.imgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  scrlbx.SetFocus;
  if Button <> mbLeft then exit;
  if btn_Brush.down then tmpShape := TFPencil.Create;
  if btn_line.down then tmpShape := TFLine.Create;
  if btn_Rect.down then tmpShape := TFRect.Create;
  if btn_rectclear.down then tmpShape := TFRectClear.Create;
  if btn_SelPen.down then tmpShape := TFSelPencil.Create;
  if btn_Ellipse.down then tmpShape := TFEllipse.Create;
  if btn_ellipseclear.down then tmpShape := TFEllipseClear.Create;
  if btn_Text.down then tmpShape := TFText.Create;
  if btn_Blur.down then tmpShape := TFBlurRect.Create;

  pb.Invalidate;
  ShapeList.DrawAll(img.Canvas);
  ActiveDraw := true;
  // tmpShape.imgCanvas := img.Picture.Bitmap.Canvas;
  tmpShape.IsDrawing := true;
  tmpShape.pb := pb;
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
  pb.Invalidate;
end;

procedure TFImage.imgMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not ActiveDraw then exit;

  ActiveDraw := false;
  tmpShape.AddPoint(Point(X, Y), pb.Canvas);
  tmpShape.EndPoint := Point(X, Y);
  if tmpShape is TFText then begin
    Enabled := false;
    with TFTextEdit.Create(nil) do begin
      // Left := Mouse.CursorPos.X - 20;
      // Top := Mouse.CursorPos.Y - 20;
      OnClose := TextEditFormClose;
      mmo_text.Font.Color := tmpShape.PenF.Color;
      Show;
    end
  end
  else tmpShape.IsDrawing := false;
  ShapeList.AddShape(tmpShape);
  img.Picture.Assign(OriginImg);
  pb.Invalidate;
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

procedure TFImage.mm_blurClick(Sender: TObject);
begin
  btn_Blur.down := true;
end;

procedure TFImage.mm_brushClick(Sender: TObject);
begin
  btn_Brush.down := true;
end;

procedure TFImage.mm_brushcolorClick(Sender: TObject);
begin
  shp_brushMouseDown(self, mbLeft, [], 1, 1);
end;

procedure TFImage.mm_undoClick(Sender: TObject);
begin
  if ShapeList.Undo then pb.Invalidate;
end;

procedure TFImage.mm_DefaultColorClick(Sender: TObject);
begin
  shp_brush.Brush.Color := clWhite;
  shp_pen.Brush.Color := clBlack;
end;

procedure TFImage.mm_deleteallClick(Sender: TObject);
begin
  ShapeList.Clear;
  pb.Invalidate;
end;

procedure TFImage.mm_ellipseclearClick(Sender: TObject);
begin
  btn_ellipseclear.down := true;
end;

procedure TFImage.mm_ellipseClick(Sender: TObject);
begin
  btn_Ellipse.down := true;
end;

procedure TFImage.mm_lineClick(Sender: TObject);
begin
  btn_line.down := true;
end;

procedure TFImage.mm_LoadClick(Sender: TObject);
var
  FSName: String;
  SaveResult: Integer;
begin
  Hide;
  FSName := ExtractFilePath(paramstr(0)) + GetScreenName;
  ShapeList.DrawAll(img.Canvas);
  SaveResult := 1;
  case TImgFormats(GSettings.ImgExtIndex) of
    ifJpg: SaveResult := SaveJPG(img.Picture.Bitmap, FSName);
    ifPng: SaveResult := SavePNG(img.Picture.Bitmap, FSName);
    ifBmp: SaveResult := SaveBMP(img.Picture.Bitmap, FSName);
    ifGif: SaveResult := SaveGIF(img.Picture.Bitmap, FSName);
  end;
  if SaveResult > 0 then begin
    ShowMessage('Ошибка Сохранения изображения для загрузки');
    exit;
  end;
  img.Picture.Bitmap.FreeImage;
  with TFLoad.Create(nil) do LoadFile(FSName);
  Close;
end;

procedure TFImage.mm_pencolorClick(Sender: TObject);
begin
  shp_penMouseDown(self, mbLeft, [], 1, 1);
end;

procedure TFImage.mm_rectclearClick(Sender: TObject);
begin
  btn_rectclear.down := true;
end;

procedure TFImage.mm_rectClick(Sender: TObject);
begin
  btn_Rect.down := true;
end;

procedure TFImage.mm_redoClick(Sender: TObject);
begin
  if ShapeList.Redo then pb.Invalidate;
end;

procedure TFImage.mm_SaveToFileClick(Sender: TObject);
var
  SaveResult: Integer;
begin
  with SavePictureDlg do begin
    FileName := ExtractFileName(GetScreenName);
    DefaultExt := ExtractFileName(GetScreenName);
    FilterIndex := 1 + GSettings.ImgExtIndex;
    if Execute then begin
      SaveResult := 1;
      ShapeList.DrawAll(img.Canvas);
      case TImgFormats(GSettings.ImgExtIndex) of
        ifJpg: SaveResult := SaveJPG(img.Picture.Bitmap, FileName);
        ifPng: SaveResult := SavePNG(img.Picture.Bitmap, FileName);
        ifBmp: SaveResult := SaveBMP(img.Picture.Bitmap, FileName);
        ifGif: SaveResult := SaveGIF(img.Picture.Bitmap, FileName);
      end;
      img.Picture.Assign(OriginImg);
      if SaveResult > 0 then ShowMessage('Ошибка Сохранения изображения')
      else ShowMessage('Изображение сохранено: ' + FileName);
    end;
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

procedure TFImage.mm_textClick(Sender: TObject);
begin
  btn_Text.down := true;
end;

procedure TFImage.mm_SelPenClick(Sender: TObject);
begin
  btn_SelPen.down := true;
end;

procedure TFImage.pbPaint(Sender: TObject);
begin
  if ActiveDraw then tmpShape.Draw(pb.Canvas)
  else ShapeList.DrawAll(pb.Canvas);
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
  pb.Height := img.Height;
  pb.Width := img.Width;
  if GSettings.FastLoad then begin
    mm_LoadClick(nil);
  end else begin
    BringToFront;
    Show;
  end;
end;

procedure TFImage.TextEditFormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (Sender as TFTextEdit).NAdd then begin
    (tmpShape as TFText).Text := (Sender as TFTextEdit).NText;
    (tmpShape as TFText).Styles := (Sender as TFTextEdit).mmo_text.Font.Style;
    (tmpShape as TFText).FSize := (Sender as TFTextEdit).mmo_text.Font.Size;
    (tmpShape as TFText).IsDrawing := false;
  end
  else ShapeList.DeleteLast;
  Action := caFree;
  Enabled := true;
end;

end.
