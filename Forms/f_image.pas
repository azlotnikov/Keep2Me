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
  Vcl.Buttons,
  Vcl.Imaging.PNGImage,
  Vcl.Imaging.JPEG,
  Vcl.Imaging.GIFImg,
  acAlphaImageList,
  sSpeedButton,
  JvComponentBase,
  JvExMask,
  JvSpin,
  JvBackgrounds,
  JvExControls,
  JvGammaPanel,
  JvExStdCtrls,
  JvCombobox,
  JvListComb,
  sDialogs,
  sEdit,
  sSpinEdit,
  f_load,
  f_textedit,
  f_imageinfo,
  funcs,
  imgtools,
  ConstStrings,
  sListBox, System.ImageList;

type
  TFImage = class(TForm)
  published
    scrlbx             : TScrollBox;
    img                : TImage;
    mm                 : TMainMenu;
    mm_menu            : TMenuItem;
    mm_undo            : TMenuItem;
    mm_Load            : TMenuItem;
    pnl_Tools          : TPanel;
    Images             : TsAlphaImageList;
    btn_DoLoad         : TsSpeedButton;
    lbl_penwidth       : TLabel;
    mm_swapcolors      : TMenuItem;
    N1                 : TMenuItem;
    mm_close           : TMenuItem;
    mm_DefaultColor    : TMenuItem;
    mm_showrightpanel  : TMenuItem;
    mm_tools           : TMenuItem;
    mm_brush           : TMenuItem;
    mm_deleteall       : TMenuItem;
    mm_line            : TMenuItem;
    mm_view            : TMenuItem;
    mm_copyimg         : TMenuItem;
    mm_SaveToFile      : TMenuItem;
    SavePictureDlg     : TSavePictureDialog;
    mm_rect            : TMenuItem;
    mm_SelPen          : TMenuItem;
    mm_redo            : TMenuItem;
    mm_colors          : TMenuItem;
    mm_ellipse         : TMenuItem;
    mm_text            : TMenuItem;
    mm_rectclear       : TMenuItem;
    mm_ellipseclear    : TMenuItem;
    mm_blur            : TMenuItem;
    pb                 : TPaintBox;
    spin_penwidth      : TJvSpinEdit;
    pm_cut             : TMenuItem;
    mm_Resize          : TMenuItem;
    pnl_buttons        : TPanel;
    btn_Brush          : TsSpeedButton;
    btn_line           : TsSpeedButton;
    btn_Rect           : TsSpeedButton;
    btn_Ellipse        : TsSpeedButton;
    btn_rectclear      : TsSpeedButton;
    btn_ellipseclear   : TsSpeedButton;
    btn_Text           : TsSpeedButton;
    btn_SelPen         : TsSpeedButton;
    btn_Blur           : TsSpeedButton;
    btn_cut            : TsSpeedButton;
    btn_Resize         : TsSpeedButton;
    mm_showleftpanel   : TMenuItem;
    pb_Resizeborder    : TPaintBox;
    img_fon            : TImage;
    tmr_BackGroundcheck: TTimer;
    pnl_Colors         : TJvGammaPanel;
    Smiles             : TsAlphaImageList;
    cbb_smiles         : TJvImageComboBox;
    btn_smile          : TsSpeedButton;
    mm_smile           : TMenuItem;
    mm_info            : TMenuItem;
    btn_arrow          : TsSpeedButton;
    mm_arrow           : TMenuItem;
    btn_pipet          : TsSpeedButton;
    mm_pipet           : TMenuItem;
    mni_pastefrombuf   : TMenuItem;
    procedure mm_LoadClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure imgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure imgMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure mm_undoClick(Sender: TObject);
    procedure mm_swapcolorsClick(Sender: TObject);
    procedure mm_closeClick(Sender: TObject);
    procedure mm_DefaultColorClick(Sender: TObject);
    procedure mm_showrightpanelClick(Sender: TObject);
    procedure mm_brushClick(Sender: TObject);
    procedure mm_deleteallClick(Sender: TObject);
    procedure mm_lineClick(Sender: TObject);
    procedure mm_copyimgClick(Sender: TObject);
    procedure mm_SaveToFileClick(Sender: TObject);
    procedure mm_rectClick(Sender: TObject);
    procedure mm_SelPenClick(Sender: TObject);
    procedure mm_redoClick(Sender: TObject);
    procedure mm_ellipseClick(Sender: TObject);
    procedure mm_textClick(Sender: TObject);
    procedure mm_rectclearClick(Sender: TObject);
    procedure mm_ellipseclearClick(Sender: TObject);
    procedure mm_blurClick(Sender: TObject);
    procedure pbPaint(Sender: TObject);
    procedure pm_cutClick(Sender: TObject);
    procedure pb_ResizeborderPaint(Sender: TObject);
    procedure mm_ResizeClick(Sender: TObject);
    procedure mm_showleftpanelClick(Sender: TObject);
    procedure tmr_BackGroundcheckTimer(Sender: TObject);
    procedure mm_smileClick(Sender: TObject);
    procedure scrlbxMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
      var Handled: Boolean);
    procedure mm_infoClick(Sender: TObject);
    procedure mm_arrowClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure mm_pipetClick(Sender: TObject);
    procedure mni_pastefrombufClick(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  private
    ActiveDraw: Boolean;
    PastingImg: Boolean;
    tmpShape  : TFShape;
    CopyShift : TShiftState;
    OldFonSize: TPoint;
    TextDrag  : TPoint;
    SmilesList: array of TsAlphaImageList;
    function GetScreenName: string;
    procedure TextEditFormClose(Sender: TObject; var Action: TCloseAction);
    procedure TextEditMemoChange(Sender: TObject);
    procedure SetTextStyle(Sender: TObject);
    procedure SavePlacement;
    procedure LoadPlacement;
    procedure ReloadBackGround;
    procedure LoadSmiles;
    procedure UpdateCaption;
  public
    OriginImg: TBitmap;
    ShapeList: TFShapeList;
    procedure StartWork;
  end;

implementation

{$R *.dfm}

function SaveJPG(bm: TBitmap; FName: string): Integer;
var
  JPGDest: TJPEGImage;
begin
  result := 0;
  try
    JPGDest := TJPEGImage.Create;
    with JPGDest do
    begin
      Assign(bm);
      CompressionQuality := 100;
      SaveToFile(FName);
    end;
  except
    result := 1;
  end;
  JPGDest.Free;
end;

function SavePNG(bm: TBitmap; FName: string): Integer;
var
  PNGDest: TPNGImage;
begin
  result := 0;
  try
    PNGDest := TPNGImage.Create;
    with PNGDest do
    begin
      Assign(bm);
      SaveToFile(FName);
    end;
  except
    result := 1;
  end;
  PNGDest.Free;
end;

function SaveBMP(bm: TBitmap; FName: string): Integer;
begin
  result := 0;
  try
    bm.SaveToFile(FName);
  except
    result := 1;
  end;
end;

function SaveGIF(bm: TBitmap; FName: string): Integer;
var
  GIFDest: TGIFImage;
begin
  result := 0;
  try
    GIFDest := TGIFImage.Create;
    with GIFDest do
    begin
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
  Params.ExStyle   := Params.ExStyle or WS_EX_APPWINDOW;
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
  if ActiveDraw and (tmpShape is TFText) and (not tmpShape.IsDrawing) then
  begin
    TextDrag := Point(X, Y);
    tmpShape.Draw(pb.Canvas, Shift);
    exit;
  end;
  if ActiveDraw then
    exit;
  if PastingImg then
  begin
    tmpShape := TFImg.Create;
    (tmpShape as TFImg).PasteImg.LoadFromClipboardFormat(CF_BITMAP, Clipboard.GetAsHandle(CF_BITMAP), 0);
  end else begin
    if btn_pipet.Down then
    begin
      if Button = mbLeft then
        pnl_Colors.ForegroundColor := img.Canvas.Pixels[X, Y];
      if Button = mbRight then
        pnl_Colors.BackgroundColor := img.Canvas.Pixels[X, Y];
      exit;
    end;
    if Button <> mbLeft then
      exit;
    if btn_Brush.Down then
      tmpShape := TFPencil.Create;
    if btn_line.Down then
      tmpShape := TFLine.Create;
    if btn_Rect.Down then
      tmpShape := TFRect.Create;
    if btn_rectclear.Down then
      tmpShape := TFRectClear.Create;
    if btn_SelPen.Down then
      tmpShape := TFSelPencil.Create;
    if btn_Ellipse.Down then
      tmpShape := TFEllipse.Create;
    if btn_ellipseclear.Down then
      tmpShape := TFEllipseClear.Create;
    if btn_Text.Down then
      tmpShape := TFText.Create;
    if btn_Blur.Down then
      tmpShape := TFBlurRect.Create;
    if btn_cut.Down then
      tmpShape := TFCut.Create;
    if btn_Resize.Down then
      tmpShape := TFResize.Create;
    if btn_smile.Down then
      tmpShape := TFSmile.Create;
    if btn_arrow.Down then
      tmpShape := TFArrow.Create;
    if (tmpShape is TFResize) or (tmpShape is TFCut) then
      pb_Resizeborder.Visible := true;
    if (tmpShape is TFSmile) then
      (tmpShape as TFSmile).ImagesData := SmilesList[cbb_smiles.ItemIndex];
  end;
  pb.Invalidate;
  // ShapeList.DrawAll(img.Canvas);
  ActiveDraw := true;
  // tmpShape.imgCanvas := img.Picture.Bitmap.Canvas;
  tmpShape.IsDrawing    := true;
  tmpShape.pb           := pb;
  tmpShape.StartPoint   := Point(X, Y);
  pb.Canvas.Pen.Color   := pnl_Colors.ForegroundColor;
  pb.Canvas.Pen.Width   := trunc(spin_penwidth.Value);
  pb.Canvas.Brush.Color := pnl_Colors.BackgroundColor;
  tmpShape.PenF.Color   := pnl_Colors.ForegroundColor;
  tmpShape.PenF.Width   := trunc(spin_penwidth.Value);
  tmpShape.BrushF.Color := pnl_Colors.BackgroundColor;
  if not PastingImg then
    tmpShape.AddPoint(Point(X, Y), pb.Canvas, Shift);
  PastingImg := false;
end;

procedure TFImage.imgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if not ActiveDraw then
    exit;
  if btn_pipet.Down then
    exit;
  if ActiveDraw and (tmpShape is TFText) and (not tmpShape.IsDrawing) then
  begin
    with tmpShape do
    begin
      dec(EndPoint.X, TextDrag.X - X);
      dec(EndPoint.Y, TextDrag.Y - Y);
      dec(StartPoint.X, TextDrag.X - X);
      dec(StartPoint.Y, TextDrag.Y - Y);
    end;
    pb.Invalidate;
    exit;
  end;
  { if (X > scrlbx.Width + scrlbx.HorzScrollBar.ScrollPos) and (X < img.Width) then
    scrlbx.ScrollBy(scrlbx.Width + scrlbx.HorzScrollBar.ScrollPos - X, 0);
    if (Y > scrlbx.Height + scrlbx.VertScrollBar.ScrollPos) and (Y < img.Height) then
    scrlbx.ScrollBy(0, scrlbx.Height + scrlbx.VertScrollBar.ScrollPos - Y); }
  if (tmpShape is TFResize) or (tmpShape is TFCut) then
  begin
    tmpShape.EndPoint := Point(X, Y);
    CopyShift         := Shift;
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
  if not ActiveDraw then
    exit;
  img_fon.Cursor      := crCross;
  pb.Cursor           := crCross;
  pnl_buttons.Enabled := true;
  if btn_pipet.Down then
    exit;
  tmpShape.AddPoint(Point(X, Y), pb.Canvas, Shift);
  // tmpShape.EndPoint := Point(X, Y);
  pb_Resizeborder.Visible := false;
  if tmpShape is TFText then
  begin
    Enabled            := false;
    tmpShape.IsDrawing := false;
    with TFTextEdit.Create(self) do
    begin
      OnClose                  := TextEditFormClose;
      mmo_text.OnChange        := TextEditMemoChange;
      btn_fontcolor.ColorValue := tmpShape.PenF.Color;
      mmo_text.Font.Color      := tmpShape.PenF.Color;
      Show;
    end
  end else begin
    tmpShape.IsDrawing := false;
    if (tmpShape is TFResize) then
      with (tmpShape as TFResize) do
      begin
        if v < 0 then
          img.Picture.Bitmap.Height := pb.Height - v;
        if h < 0 then
          img.Picture.Bitmap.Width := pb.Width - h;
      end;
    tmpShape.Draw(img.Canvas);
    img.Picture.Bitmap.Height := pb.Height;
    img.Picture.Bitmap.Width  := pb.Width;
    ActiveDraw                := false;
  end;
  ShapeList.AddShape(tmpShape);
  pb.Invalidate;
  UpdateCaption;
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
  Application.InsertComponent(self);
  LoadPlacement;
  OriginImg     := TBitmap.Create;
  ShapeList     := TFShapeList.Create;
  ShapeList.img := img;
  LoadSmiles;
end;

procedure TFImage.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key in ['=', '+'] then
    spin_penwidth.Value := spin_penwidth.Value + 1
  else if Key in ['-'] then
    spin_penwidth.Value := spin_penwidth.Value - 1;
end;

procedure TFImage.mm_arrowClick(Sender: TObject);
begin
  btn_arrow.Down := true;
end;

procedure TFImage.mm_blurClick(Sender: TObject);
begin
  btn_Blur.Down := true;
end;

procedure TFImage.mm_brushClick(Sender: TObject);
begin
  btn_Brush.Down := true;
end;

procedure TFImage.mm_undoClick(Sender: TObject);
var
  i: Integer;
begin
  if ShapeList.Undo then
  begin
    img.Picture.Assign(OriginImg);
    pb.Width  := img.Picture.Bitmap.Width;
    pb.Height := img.Picture.Bitmap.Height;
    ShapeList.DrawAll(img.Canvas);
    img.Picture.Bitmap.Height := pb.Height;
    img.Picture.Bitmap.Width  := pb.Width;
  end;
  UpdateCaption;
end;

procedure TFImage.mni_pastefrombufClick(Sender: TObject);
begin
  if ActiveDraw then
  begin
    ShowMessage('Закончите текущее действие!');
    exit;
  end;
  if (Clipboard.HasFormat(CF_BITMAP)) or (Clipboard.HasFormat(CF_PICTURE)) then
  begin
    pnl_buttons.Enabled := false;
    img_fon.Cursor      := crSizeAll;
    pb.Cursor           := crSizeAll;
    PastingImg          := true;
    imgMouseDown(self, mbLeft, [], 0, 0);
  end
  else
    ShowMessage(RU_NOT_AN_IMAGE_CONTENT);
end;

procedure TFImage.mm_DefaultColorClick(Sender: TObject);
begin
  pnl_Colors.BackgroundColor := clWhite;
  pnl_Colors.ForegroundColor := clBlack;
end;

procedure TFImage.mm_deleteallClick(Sender: TObject);
begin
  repeat

  until (not ShapeList.Undo);
  pb.Invalidate;
  img.Picture.Assign(OriginImg);
  ShapeList.DrawAll(img.Canvas);
  UpdateCaption;
end;

procedure TFImage.mm_ellipseclearClick(Sender: TObject);
begin
  btn_ellipseclear.Down := true;
end;

procedure TFImage.mm_ellipseClick(Sender: TObject);
begin
  btn_Ellipse.Down := true;
end;

procedure TFImage.mm_infoClick(Sender: TObject);
begin
  TFImageInfo.Create(nil).Show;
end;

procedure TFImage.mm_lineClick(Sender: TObject);
begin
  btn_line.Down := true;
end;

procedure TFImage.mm_LoadClick(Sender: TObject);
var
  FSName    : string;
  SaveResult: Integer;
begin
  Hide;
  FSName := SYS_PATH + GetScreenName;
  // ShapeList.DrawAll(img.Canvas);
  SaveResult := 1;
  case TImgFormats(GSettings.ImgExtIndex) of
    ifJpg:
      SaveResult := SaveJPG(img.Picture.Bitmap, FSName);
    ifPng:
      SaveResult := SavePNG(img.Picture.Bitmap, FSName);
    ifBmp:
      SaveResult := SaveBMP(img.Picture.Bitmap, FSName);
    ifGif:
      SaveResult := SaveGIF(img.Picture.Bitmap, FSName);
  end;
  if SaveResult > 0 then
  begin
    ShowMessage('Ошибка Сохранения изображения для загрузки');
    exit;
  end;
  Hide;
  TFLoad.CreateEx(FSName, self);
end;

procedure TFImage.mm_pipetClick(Sender: TObject);
begin
  btn_pipet.Down := true;
end;

procedure TFImage.mm_rectclearClick(Sender: TObject);
begin
  btn_rectclear.Down := true;
end;

procedure TFImage.mm_rectClick(Sender: TObject);
begin
  btn_Rect.Down := true;
end;

procedure TFImage.mm_redoClick(Sender: TObject);
begin
  if ShapeList.Redo then
  begin
    img.Picture.Assign(OriginImg);
    ShapeList.DrawAll(img.Canvas);
  end;
  UpdateCaption;
end;

procedure TFImage.mm_ResizeClick(Sender: TObject);
begin
  btn_Resize.Down := true;
end;

procedure TFImage.mm_SaveToFileClick(Sender: TObject);
var
  SaveResult: Integer;
begin
  with SavePictureDlg do
  begin
    FileName    := ExtractFileName(GetScreenName);
    DefaultExt  := ExtractFileName(GetScreenName);
    FilterIndex := GSettings.ImgExtIndex;
    if Execute then
    begin
      SaveResult := 1;
      // ShapeList.DrawAll(img.Canvas);
      case TImgFormats(GSettings.ImgExtIndex) of
        ifJpg:
          SaveResult := SaveJPG(img.Picture.Bitmap, FileName);
        ifPng:
          SaveResult := SavePNG(img.Picture.Bitmap, FileName);
        ifBmp:
          SaveResult := SaveBMP(img.Picture.Bitmap, FileName);
        ifGif:
          SaveResult := SaveGIF(img.Picture.Bitmap, FileName);
      end;
      // img.Picture.Assign(OriginImg);
      if SaveResult > 0 then
        ShowMessage('Ошибка Сохранения изображения')
      else
        ShowMessage('Изображение сохранено: ' + FileName);
    end;
  end;
end;

procedure TFImage.mm_swapcolorsClick(Sender: TObject);
var
  t: Tcolor;
begin
  t                          := pnl_Colors.ForegroundColor;
  pnl_Colors.ForegroundColor := pnl_Colors.BackgroundColor;
  pnl_Colors.BackgroundColor := t;
end;

procedure TFImage.mm_textClick(Sender: TObject);
begin
  btn_Text.Down := true;
end;

procedure TFImage.mm_SelPenClick(Sender: TObject);
begin
  btn_SelPen.Down := true;
end;

procedure TFImage.pbPaint(Sender: TObject);
begin
  if ActiveDraw and (not pb_Resizeborder.Visible) then
    tmpShape.Draw(pb.Canvas)
  else if ActiveDraw and (tmpShape is TFText) and (not tmpShape.IsDrawing) then
  begin
    tmpShape.IsDrawing := true;
    tmpShape.Draw(pb.Canvas);
    tmpShape.IsDrawing := false;
  end;
end;

procedure TFImage.pb_ResizeborderPaint(Sender: TObject);
begin
  if ActiveDraw and ((tmpShape is TFResize) or (tmpShape is TFCut)) then
    tmpShape.Draw(pb_Resizeborder.Canvas, CopyShift);
end;

procedure TFImage.pm_cutClick(Sender: TObject);
begin
  btn_cut.Down := true;
end;

procedure TFImage.ReloadBackGround;
const
  SqSize = 9;
var
  i, j: Integer;
begin
  img_fon.Picture.Bitmap.Width  := img_fon.Width;
  img_fon.Picture.Bitmap.Height := img_fon.Height;
  img_fon.Picture.Bitmap.Canvas.Rectangle(0, 0, img_fon.Width, img_fon.Height);
  img_fon.Picture.Bitmap.Canvas.Pen.Style := psSolid;
  img_fon.Picture.Bitmap.Canvas.Pen.Width := 0;
  for i                                   := 0 to img_fon.Width div SqSize + 1 do
    for j                                 := 0 to img_fon.Height div SqSize + 1 do
      with img_fon.Picture.Bitmap.Canvas do
      begin
        if (i mod 2 + j mod 2 = 0) or (i mod 2 + j mod 2 = 2) then
          Brush.Color := clWhite
        else
          Brush.Color := clSilver; // $CCCCCC;
        Pen.Color     := Brush.Color;
        Rectangle(SqSize * i, SqSize * j, SqSize * (i + 1), SqSize * (j + 1));
      end;
end;

procedure TFImage.SavePlacement;
var
  F: TIniFile;
  i: Integer;
begin
  F := TIniFile.Create(SYS_PATH + SYS_IMG_LOADER_FORM_NAME);
  with F do
  begin
    WriteInteger('Form', 'Width', ClientWidth);
    WriteInteger('Form', 'Height', ClientHeight);
    WriteInteger('Form', 'Top', Top);
    WriteInteger('Form', 'Left', Left);
    WriteBool('Form', 'Maximized', (WindowState = wsMaximized));
    WriteBool('Form', 'LeftPanel', mm_showleftpanel.Checked);
    WriteBool('Form', 'RightPanel', mm_showrightpanel.Checked);
    WriteInteger('Tools', 'PenWidth', trunc(spin_penwidth.Value));
    WriteInteger('Colors', 'Pen', pnl_Colors.ForegroundColor);
    WriteInteger('Colors', 'Brush', pnl_Colors.BackgroundColor);
    WriteInteger('Smiles', 'Index', cbb_smiles.ItemIndex);
    for i := 0 to ComponentCount - 1 do
      if (Components[i] is TsSpeedButton) and ((Components[i] as TsSpeedButton).Down) then
      begin
        WriteInteger('Tools', 'Active', Components[i].Tag);
        break;
      end;
    Free;
  end;
end;

procedure TFImage.scrlbxMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
var
  d: Integer;
begin
  if WheelDelta < 0 then
    d := 7
  else
    d := -7;
  if getasynckeystate(VK_CONTROL) <> 0 then
    scrlbx.HorzScrollBar.Position := scrlbx.HorzScrollBar.Position + d
  else
    scrlbx.VertScrollBar.Position := scrlbx.VertScrollBar.Position + d;
end;

procedure TFImage.LoadPlacement;
var
  F   : TIniFile;
  i, K: Integer;
begin
  F := TIniFile.Create(SYS_PATH + SYS_IMG_LOADER_FORM_NAME);
  with F do
  begin
    if ReadBool('Form', 'Maximized', false) then
      WindowState := wsMaximized
    else
    begin
      ClientWidth  := ReadInteger('Form', 'Width', ClientWidth);
      ClientHeight := ReadInteger('Form', 'Height', ClientHeight);
      Top          := ReadInteger('Form', 'Top', Top);
      Left         := ReadInteger('Form', 'Left', Left);
    end;
    if not ReadBool('Form', 'LeftPanel', mm_showleftpanel.Checked) then
      mm_showleftpanel.Click;
    if not ReadBool('Form', 'RightPanel', mm_showrightpanel.Checked) then
      mm_showrightpanel.Click;
    spin_penwidth.Value        := ReadInteger('Tools', 'PenWidth', trunc(spin_penwidth.Value));
    pnl_Colors.ForegroundColor := ReadInteger('Colors', 'Pen', pnl_Colors.ForegroundColor);
    pnl_Colors.BackgroundColor := ReadInteger('Colors', 'Brush', pnl_Colors.BackgroundColor);
    cbb_smiles.ItemIndex       := ReadInteger('Smiles', 'Index', cbb_smiles.ItemIndex);
    if cbb_smiles.ItemIndex > cbb_smiles.Items.Count - 1 then
      cbb_smiles.ItemIndex := 0;

    K := ReadInteger('Tools', 'Active', 1);

    for i := 0 to ComponentCount - 1 do
      if (Components[i] is TsSpeedButton) and (Components[i].Tag = K) then
      begin
        (Components[i] as TsSpeedButton).Down := true;
        break;
      end;
    Free;
  end;
end;

function ReadMWord(F: TFileStream): Word;
type
  TMotorolaWord = record
    case byte of
      0:
        (Value: Word);
      1:
        (Byte1, Byte2: byte);
  end;
var
  MW: TMotorolaWord;
begin
  F.Read(MW.Byte2, SizeOf(byte));
  F.Read(MW.Byte1, SizeOf(byte));
  result := MW.Value;
end;

procedure GetJPGSize(const sFile: string; var wWidth, wHeight: Word);
const
  ValidSig: array [0 .. 1] of byte = ($FF, $D8);
  Parameterless                    = [$01, $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7];
var
  Sig    : array [0 .. 1] of byte;
  F      : TFileStream;
  X      : Integer;
  Seg    : byte;
  Dummy  : array [0 .. 15] of byte;
  Len    : Word;
  ReadLen: LongInt;
begin
  FillChar(Sig, SizeOf(Sig), #0);
  F := TFileStream.Create(sFile, fmOpenRead);
  try
    ReadLen := F.Read(Sig[0], SizeOf(Sig));
    for X   := low(Sig) to high(Sig) do
      if (Sig[X] <> ValidSig[X]) then
        ReadLen := 0;
    if (ReadLen > 0) then
    begin
      ReadLen := F.Read(Seg, 1);
      while (Seg = $FF) and (ReadLen > 0) do
      begin
        ReadLen := F.Read(Seg, 1);
        if (Seg <> $FF) then
        begin
          if (Seg = $C0) or (Seg = $C1) then
          begin
            ReadLen := F.Read(Dummy[0], 3);
            wHeight := ReadMWord(F);
            wWidth  := ReadMWord(F);
          end else begin
            if not(Seg in Parameterless) then
            begin
              Len := ReadMWord(F);
              F.Seek(Len - 2, 1);
              F.Read(Seg, 1);
            end
            else
              Seg := $FF;
          end;
        end;
      end;
    end;
  finally
    F.Free;
  end;
end;

procedure GetPNGSize(const sFile: string; var wWidth, wHeight: Word);
type
  TPNGSig = array [0 .. 7] of byte;
const
  ValidSig: TPNGSig = (137, 80, 78, 71, 13, 10, 26, 10);
var
  Sig: TPNGSig;
  F  : TFileStream;
  X  : Integer;
begin
  FillChar(Sig, SizeOf(Sig), #0);
  F := TFileStream.Create(sFile, fmOpenRead);
  try
    F.Read(Sig[0], SizeOf(Sig));
    for X := low(Sig) to high(Sig) do
      if (Sig[X] <> ValidSig[X]) then
        exit;
    F.Seek(18, 0);
    wWidth := ReadMWord(F);
    F.Seek(22, 0);
    wHeight := ReadMWord(F);
  finally
    F.Free;
  end;
end;

procedure TFImage.LoadSmiles;
var
  t   : TStringList;
  i   : Integer;
  w, h: Word;
begin
  t := TStringList.Create;
  GetAllFiles(SYS_PATH + SYS_SMILES_FOLDER, t, true);
  SetLength(SmilesList, t.Count);
  for i := 0 to t.Count - 1 do
  begin
    Smiles.LoadFromFile(t[i]);
    with cbb_smiles.Items.Add do
    begin
      Text       := ExtractFileName(t[i]);
      ImageIndex := i;
    end;
    SmilesList[i] := TsAlphaImageList.Create(self);
    if ExtractFileExt(t[i]) = '.png' then
      GetPNGSize(t[i], w, h);
    if ExtractFileExt(t[i]) = '.jpg' then
      GetJPGSize(t[i], w, h);
    SmilesList[i].Width  := w;
    SmilesList[i].Height := h;
    SmilesList[i].LoadFromFile(t[i]);
  end;
  if cbb_smiles.Items.Count > 0 then
    cbb_smiles.ItemIndex := 0
  else
  begin
    cbb_smiles.Enabled := false;
    btn_smile.Enabled  := false;
    mm_smile.Enabled   := false;
  end;
end;

procedure TFImage.mm_showleftpanelClick(Sender: TObject);
begin
  mm_showleftpanel.Checked := not mm_showleftpanel.Checked;
  pnl_buttons.Visible      := mm_showleftpanel.Checked;
end;

procedure TFImage.mm_showrightpanelClick(Sender: TObject);
begin
  mm_showrightpanel.Checked := not mm_showrightpanel.Checked;
  pnl_Tools.Visible         := mm_showrightpanel.Checked;
end;

procedure TFImage.mm_smileClick(Sender: TObject);
begin
  btn_smile.Down := true;
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

procedure TFImage.StartWork;
begin
  ShapeList.Clear;
  pb.Height := img.Height;
  pb.Width  := img.Width;
  if GSettings.FastLoad then
  begin
    mm_LoadClick(nil);
  end else begin
    BringToFront;
    Show;
  end;
  ReloadBackGround;
  UpdateCaption;
  img.Picture.Bitmap.PixelFormat := pf32bit;
end;

procedure TFImage.SetTextStyle(Sender: TObject);
begin
  (tmpShape as TFText).Text       := (Sender as TFTextEdit).mmo_text.Text;
  (tmpShape as TFText).Styles     := (Sender as TFTextEdit).mmo_text.Font.Style;
  (tmpShape as TFText).FSize      := (Sender as TFTextEdit).mmo_text.Font.Size;
  (tmpShape as TFText).FontName   := (Sender as TFTextEdit).mmo_text.Font.Name;
  (tmpShape as TFText).PenF.Color := (Sender as TFTextEdit).mmo_text.Font.Color;
  (tmpShape as TFText).IsDrawing  := false;
end;

procedure TFImage.TextEditFormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (Sender as TFTextEdit).NAdd and (Length((Sender as TFTextEdit).mmo_text.Text) <> 0) then
  begin
    SetTextStyle(Sender);
    tmpShape.Draw(img.Canvas);
  end
  else
    ShapeList.DeleteLast;
  Action := caFree;
  Enabled := true;
  ActiveDraw := false;
  pb.Invalidate;
end;

procedure TFImage.TextEditMemoChange(Sender: TObject);
begin
  SetTextStyle((Sender as TMemo).Parent);
  pb.Invalidate;
end;

procedure TFImage.tmr_BackGroundcheckTimer(Sender: TObject);
begin
  if (OldFonSize.X <> img_fon.Width) or (OldFonSize.Y <> img_fon.Height) then
  begin
    tmr_BackGroundcheck.Enabled := false;
    ReloadBackGround;
    OldFonSize                  := Point(img_fon.Width, img_fon.Height);
    tmr_BackGroundcheck.Enabled := true;
  end;
end;

procedure TFImage.UpdateCaption;
begin
  Caption := Format('Изображение [ %dx%d ]', [img.Width, img.Height]);
end;

end.
