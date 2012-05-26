unit f_image;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Math,
  System.IniFiles,
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
  Vcl.Mask,
  Vcl.Imaging.GIFImg,
  Vcl.Buttons,
  Vcl.Imaging.PNGImage,
  Vcl.Imaging.JPEG,
  acAlphaImageList,
  sSpeedButton,
  JvComponentBase,
  JvExMask,
  JvSpin,
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
    spin_penwidth: TJvSpinEdit;
    btn_cut: TsSpeedButton;
    pm_cut: TMenuItem;
    btn_Resize: TsSpeedButton;
    pb_Resizeborder: TPaintBox;
    pb_fon: TPaintBox;
    mm_Resize: TMenuItem;
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
    procedure pm_cutClick(Sender: TObject);
    procedure pb_ResizeborderPaint(Sender: TObject);
    procedure pb_fonPaint(Sender: TObject);
    procedure mm_ResizeClick(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  private
    ActiveDraw: Boolean;
    tmpShape: TFShape;
    CopyShift: TShiftState;
    function GetScreenName: string;
    procedure TextEditFormClose(Sender: TObject; var Action: TCloseAction);
    procedure SavePlacement;
    procedure LoadPlacement;
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
  result := result + timetostr(now) + '_' + datetostr(now);
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
  if btn_cut.down then tmpShape := TFCut.Create;
  if btn_Resize.down then tmpShape := TFResize.Create;
  if (tmpShape is TFResize) or (tmpShape is TFCut) then pb_Resizeborder.Visible := true;
  pb.Invalidate;
  // ShapeList.DrawAll(img.Canvas);
  ActiveDraw := true;
  // tmpShape.imgCanvas := img.Picture.Bitmap.Canvas;
  tmpShape.IsDrawing := true;
  tmpShape.pb := pb;
  tmpShape.StartPoint := Point(X, Y);
  pb.Canvas.Pen.Color := shp_pen.Brush.Color;
  pb.Canvas.Pen.Width := trunc(spin_penwidth.Value);
  pb.Canvas.Brush.Color := shp_brush.Brush.Color;
  tmpShape.PenF.Color := shp_pen.Brush.Color;
  tmpShape.PenF.Width := trunc(spin_penwidth.Value);
  tmpShape.BrushF.Color := shp_brush.Brush.Color;
  tmpShape.AddPoint(Point(X, Y), pb.Canvas, Shift);
end;

procedure TFImage.imgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if not ActiveDraw then exit;
  if (tmpShape is TFResize) or (tmpShape is TFCut) then begin
    tmpShape.EndPoint := Point(X, Y);
    CopyShift := Shift;
    pb_Resizeborder.Invalidate;
  end else begin
    tmpShape.AddPoint(Point(X, Y), pb.Canvas, Shift);
    pb.Invalidate;
  end;
end;

procedure TFImage.imgMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  K: Integer;
begin
  if not ActiveDraw then exit;
  tmpShape.AddPoint(Point(X, Y), pb.Canvas, Shift);
  tmpShape.EndPoint := Point(X, Y);
  pb_Resizeborder.Visible := false;
  if tmpShape is TFText then begin
    Enabled := false;
    with TFTextEdit.Create(nil) do begin
      OnClose := TextEditFormClose;
      mmo_text.Font.Color := tmpShape.PenF.Color;
      Show;
    end
  end else begin
    tmpShape.IsDrawing := false;
    if (tmpShape is TFResize) then
      with (tmpShape as TFResize) do begin
        if v < 0 then img.Picture.Bitmap.Height := pb.Height - v;
        if h < 0 then img.Picture.Bitmap.Width := pb.Width - h;
      end;
    tmpShape.Draw(img.Canvas);

    img.Picture.Bitmap.Height := pb.Height;
    img.Picture.Bitmap.Width := pb.Width;

    ActiveDraw := false;
  end;
  ShapeList.AddShape(tmpShape);
  pb.Invalidate;
end;

procedure TFImage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SavePlacement;
  Application.RemoveComponent(self);
  ShapeList.Free;
  Action := caFree;
end;

procedure TFImage.FormCreate(Sender: TObject);
begin
  LoadPlacement;
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
  if ShapeList.Undo then begin
    img.Picture.Assign(OriginImg);
    pb.Width := img.Width;
    pb.Height := img.Height;
    ShapeList.DrawAll(img.Canvas);
    img.Picture.Bitmap.Height := pb.Height;
    img.Picture.Bitmap.Width := pb.Width;
  end;
end;

procedure TFImage.mm_DefaultColorClick(Sender: TObject);
begin
  shp_brush.Brush.Color := clWhite;
  shp_pen.Brush.Color := clBlack;
end;

procedure TFImage.mm_deleteallClick(Sender: TObject);
begin
  repeat

  until (not ShapeList.Undo);
  pb.Invalidate;
  img.Picture.Assign(OriginImg);
  pb.Width := img.Width;
  pb.Height := img.Height;
  ShapeList.DrawAll(img.Canvas);
  img.Picture.Bitmap.Height := pb.Height;
  img.Picture.Bitmap.Width := pb.Width;
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
  // ShapeList.DrawAll(img.Canvas);
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
  Hide;
  TFLoad.CreateEx(FSName, self);
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
  if ShapeList.Redo then begin
    img.Picture.Assign(OriginImg);
    pb.Width := img.Width;
    pb.Height := img.Height;
    ShapeList.DrawAll(img.Canvas);
    img.Picture.Bitmap.Height := pb.Height;
    img.Picture.Bitmap.Width := pb.Width;
  end;
end;

procedure TFImage.mm_ResizeClick(Sender: TObject);
begin
  btn_Resize.down := true;
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
      // ShapeList.DrawAll(img.Canvas);
      case TImgFormats(GSettings.ImgExtIndex) of
        ifJpg: SaveResult := SaveJPG(img.Picture.Bitmap, FileName);
        ifPng: SaveResult := SavePNG(img.Picture.Bitmap, FileName);
        ifBmp: SaveResult := SaveBMP(img.Picture.Bitmap, FileName);
        ifGif: SaveResult := SaveGIF(img.Picture.Bitmap, FileName);
      end;
      // img.Picture.Assign(OriginImg);
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
  if (ActiveDraw) and (not pb_Resizeborder.Visible) then tmpShape.Draw(pb.Canvas);
end;

procedure TFImage.pb_fonPaint(Sender: TObject);
const
  SqSize = 12;
var
  i, j: Integer;
begin
  pb_fon.Canvas.Pen.Style := psClear;
  pb_fon.Canvas.Pen.Width := 0;
  for i := 0 to pb_fon.Width div SqSize + 1 do
    for j := 0 to pb_fon.Height div SqSize + 1 do
      with pb_fon.Canvas do begin
        if (i mod 2 + j mod 2 = 0) or (i mod 2 + j mod 2 = 2) then Brush.Color := clWhite
        else Brush.Color := $CCCCCC;
        Rectangle(SqSize * i, SqSize * j, SqSize * (i + 1), SqSize * (j + 1));
      end;
end;

procedure TFImage.pb_ResizeborderPaint(Sender: TObject);
begin
  if ActiveDraw then tmpShape.Draw(pb_Resizeborder.Canvas, CopyShift);
end;

procedure TFImage.pm_cutClick(Sender: TObject);
begin
  btn_cut.down := true;
end;

procedure TFImage.SavePlacement;
var
  F: TIniFile;
  i: Integer;
begin
  F := TIniFile.Create(ExtractFilePath(paramstr(0)) + SYS_IMG_LOADER_FORM_NAME);
  with F do begin
    WriteInteger('Form', 'Width', Width);
    WriteInteger('Form', 'Height', Height);
    WriteInteger('Form', 'Top', Top);
    WriteInteger('Form', 'Left', Left);
    WriteInteger('Tools', 'PenWidth', trunc(spin_penwidth.Value));
    WriteInteger('Colors', 'Pen', shp_pen.Brush.Color);
    WriteInteger('Colors', 'Brush', shp_brush.Brush.Color);
    for i := 0 to ComponentCount - 1 do
      if (Components[i] is TsSpeedButton) and ((Components[i] as TsSpeedButton).down) then begin
        WriteInteger('Tools', 'Active', Components[i].Tag);
        break;
      end;
    Free;
  end;
end;

procedure TFImage.LoadPlacement;
var
  F: TIniFile;
  i, K: Integer;
begin
  F := TIniFile.Create(ExtractFilePath(paramstr(0)) + SYS_IMG_LOADER_FORM_NAME);
  with F do begin
    Width := ReadInteger('Form', 'Width', Width);
    Height := ReadInteger('Form', 'Height', Height);
    Top := ReadInteger('Form', 'Top', Top);
    Left := ReadInteger('Form', 'Left', Left);
    spin_penwidth.Value := ReadInteger('Tools', 'PenWidth', trunc(spin_penwidth.Value));
    shp_pen.Brush.Color := ReadInteger('Colors', 'Pen', shp_pen.Brush.Color);
    shp_brush.Brush.Color := ReadInteger('Colors', 'Brush', shp_brush.Brush.Color);
    K := ReadInteger('Tools', 'Active', 1);
    for i := 0 to ComponentCount - 1 do
      if (Components[i] is TsSpeedButton) and (Components[i].Tag = K) then begin
        (Components[i] as TsSpeedButton).down := true;
        break;
      end;
    Free;
  end;
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
  Clipboard.Assign(img.Picture);
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
    (tmpShape as TFText).FontName := (Sender as TFTextEdit).mmo_text.Font.Name;
    (tmpShape as TFText).IsDrawing := false;
    tmpShape.Draw(img.Canvas);
  end
  else ShapeList.DeleteLast;
  Action := caFree;
  Enabled := true;
  ActiveDraw := false;
  pb.Invalidate;
end;

end.
