unit f_textedit;

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
  Vcl.Menus,
  Vcl.ComCtrls,
  Vcl.ImgList,
  Vcl.Buttons,
  Vcl.Samples.Spin,
  sSpeedButton,
  acAlphaImageList,
  JvExStdCtrls,
  JvCombobox,
  JvColorCombo, sColorSelect;

type
  TFTextEdit = class(TForm)
    mmo_text: TMemo;
    mm: TMainMenu;
    mm_Menu: TMenuItem;
    mm_EnterText: TMenuItem;
    mm_Exit: TMenuItem;
    Images: TsAlphaImageList;
    btn_bold: TsSpeedButton;
    btn_italic: TsSpeedButton;
    btn_striked: TsSpeedButton;
    btn_underlined: TsSpeedButton;
    se_fsize: TSpinEdit;
    lbl_fontsize: TLabel;
    btn_EnterText: TsSpeedButton;
    btn_font: TsSpeedButton;
    cbb_font: TJvFontComboBox;
    btn_fontcolor: TsColorSelect;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mm_ExitClick(Sender: TObject);
    procedure btn_boldClick(Sender: TObject);
    procedure btn_italicClick(Sender: TObject);
    procedure btn_strikedClick(Sender: TObject);
    procedure btn_underlinedClick(Sender: TObject);
    procedure se_fsizeChange(Sender: TObject);
    procedure btn_EnterTextClick(Sender: TObject);
    procedure btn_fontClick(Sender: TObject);
    procedure cbb_fontChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btn_fontcolorChange(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  private
    { Private declarations }
  public
    NAdd: Boolean;
  end;

implementation

{$R *.dfm}

procedure TFTextEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TFTextEdit.btn_boldClick(Sender: TObject);
var
  S: TFontStyles;
begin
  S := mmo_text.Font.Style;
  if btn_bold.Down then Include(S, fsBold)
  else Exclude(S, fsBold);
  mmo_text.Font.Style := S;
  mmo_text.OnChange(mmo_text);
end;

procedure TFTextEdit.btn_EnterTextClick(Sender: TObject);
begin
  NAdd := true;
  Close;
end;

procedure TFTextEdit.btn_fontClick(Sender: TObject);
begin
  if btn_font.Down then begin
    mmo_text.Top := 56;
    mmo_text.Height := mmo_text.Height - 24;
  end else begin
    mmo_text.Top := 32;
    mmo_text.Height := mmo_text.Height + 24;
  end;
  cbb_font.Visible := btn_font.Down;
end;

procedure TFTextEdit.btn_fontcolorChange(Sender: TObject);
begin
  mmo_text.Font.Color := btn_fontcolor.ColorValue;
  mmo_text.OnChange(mmo_text);
end;

procedure TFTextEdit.btn_italicClick(Sender: TObject);
var
  S: TFontStyles;
begin
  S := mmo_text.Font.Style;
  if btn_italic.Down then Include(S, fsItalic)
  else Exclude(S, fsItalic);
  mmo_text.Font.Style := S;
  mmo_text.OnChange(mmo_text);
end;

procedure TFTextEdit.btn_strikedClick(Sender: TObject);
var
  S: TFontStyles;
begin
  S := mmo_text.Font.Style;
  if btn_striked.Down then Include(S, fsStrikeOut)
  else Exclude(S, fsStrikeOut);
  mmo_text.Font.Style := S;
  mmo_text.OnChange(mmo_text);
end;

procedure TFTextEdit.btn_underlinedClick(Sender: TObject);
var
  S: TFontStyles;
begin
  S := mmo_text.Font.Style;
  if btn_underlined.Down then Include(S, fsUnderline)
  else Exclude(S, fsUnderline);
  mmo_text.Font.Style := S;
  mmo_text.OnChange(mmo_text);
end;

procedure TFTextEdit.cbb_fontChange(Sender: TObject);
begin
  mmo_text.Font.Name := cbb_font.FontName;
  mmo_text.OnChange(mmo_text);
end;

procedure TFTextEdit.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFTextEdit.FormCreate(Sender: TObject);
begin
  NAdd := false;
  mmo_text.Font.Size := se_fsize.Value;
  cbb_font.FontName := mmo_text.Font.Name;
end;

procedure TFTextEdit.FormShow(Sender: TObject);
begin
  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
  BringToFront;
  Left := Mouse.CursorPos.X - 10;
  Top := Mouse.CursorPos.Y - 10;
  mmo_text.SetFocus;
end;

procedure TFTextEdit.mm_ExitClick(Sender: TObject);
begin
  NAdd := false;
  Close;
end;

procedure TFTextEdit.se_fsizeChange(Sender: TObject);
begin
  if se_fsize.Text <> '' then mmo_text.Font.Size := se_fsize.Value;
end;

end.
