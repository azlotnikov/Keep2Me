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
  acAlphaImageList;

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
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mm_ExitClick(Sender: TObject);
    procedure btn_boldClick(Sender: TObject);
    procedure btn_italicClick(Sender: TObject);
    procedure btn_strikedClick(Sender: TObject);
    procedure btn_underlinedClick(Sender: TObject);
    procedure se_fsizeChange(Sender: TObject);
    procedure btn_EnterTextClick(Sender: TObject);
  private
    { Private declarations }
  public
    NAdd: Boolean;
    NText: String;
  end;

implementation

{$R *.dfm}

procedure TFTextEdit.btn_boldClick(Sender: TObject);
var
  S: TFontStyles;
begin
  S := mmo_text.Font.Style;
  if btn_bold.Down then Include(S, fsBold)
  else Exclude(S, fsBold);
  mmo_text.Font.Style := S;
end;

procedure TFTextEdit.btn_EnterTextClick(Sender: TObject);
begin
  NAdd := true;
  NText := mmo_text.Text;
  Close;
end;

procedure TFTextEdit.btn_italicClick(Sender: TObject);
var
  S: TFontStyles;
begin
  S := mmo_text.Font.Style;
  if btn_italic.Down then Include(S, fsItalic)
  else Exclude(S, fsItalic);
  mmo_text.Font.Style := S;
end;

procedure TFTextEdit.btn_strikedClick(Sender: TObject);
var
  S: TFontStyles;
begin
  S := mmo_text.Font.Style;
  if btn_striked.Down then Include(S, fsStrikeOut)
  else Exclude(S, fsStrikeOut);
  mmo_text.Font.Style := S;
end;

procedure TFTextEdit.btn_underlinedClick(Sender: TObject);
var
  S: TFontStyles;
begin
  S := mmo_text.Font.Style;
  if btn_underlined.Down then Include(S, fsUnderline)
  else Exclude(S, fsUnderline);
  mmo_text.Font.Style := S;
end;

procedure TFTextEdit.FormCreate(Sender: TObject);
begin
  NAdd := false;
  NText := '';
  mmo_text.Font.Size := se_fsize.Value;
end;

procedure TFTextEdit.FormShow(Sender: TObject);
begin
  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
  Left := Mouse.CursorPos.X - 10;
  Top := Mouse.CursorPos.Y - 10;
  mmo_text.SetFocus;
end;

procedure TFTextEdit.mm_ExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFTextEdit.se_fsizeChange(Sender: TObject);
begin
  if se_fsize.Text <> '' then mmo_text.Font.Size := se_fsize.Value;
end;

end.
