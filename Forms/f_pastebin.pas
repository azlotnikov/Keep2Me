unit f_pastebin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, Vcl.Buttons, sSpeedButton,
  Vcl.ImgList, acAlphaImageList, SynEdit, Vcl.ComCtrls, Vcl.Menus, Vcl.StdCtrls,
  pastebin_tools, Vcl.Clipbrd, uSynEditPopupEdit, funcs, shellapi, sStatusBar;

type
  TFPasteBin = class(TForm)
    syn_code: TSynEdit;
    HTTP: TIdHTTP;
    pnl_actions: TPanel;
    lbl_syntax: TLabel;
    cbb_syntax: TComboBox;
    lbl_expire: TLabel;
    cbb_expire: TComboBox;
    pb: TProgressBar;
    lbl_private: TLabel;
    cbb_private: TComboBox;
    lbl_caption: TLabel;
    edt_caption: TEdit;
    Images: TsAlphaImageList;
    btn_load: TsSpeedButton;
    lbl_link: TLabel;
    edt_link: TEdit;
    btn_copy: TsSpeedButton;
    btn_open: TsSpeedButton;
    mm: TMainMenu;
    mm_menu: TMenuItem;
    mm_close: TMenuItem;
    mm_load: TMenuItem;
    mm_clear: TMenuItem;
    mm_link: TMenuItem;
    mm_copy: TMenuItem;
    mm_open: TMenuItem;
    sb_info: TsStatusBar;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mm_closeClick(Sender: TObject);
    procedure mm_clearClick(Sender: TObject);
    procedure btn_loadClick(Sender: TObject);
    procedure cbb_syntaxChange(Sender: TObject);
    procedure btn_copyClick(Sender: TObject);
    procedure HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure HTTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure btn_openClick(Sender: TObject);
    procedure syn_codeClick(Sender: TObject);
    procedure syn_codeChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  // var
  // FPasteBin: TFPasteBin;

implementation

{$R *.dfm}

const
  API_DEV_KEY = '0f7d82ed3b15d568915abd9919273246';

procedure TFPasteBin.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TFPasteBin.btn_copyClick(Sender: TObject);
begin
  Clipboard.AsText := edt_link.Text;
end;

procedure TFPasteBin.btn_loadClick(Sender: TObject);
var
  post: TStringList;
  userkey, s, k: string;
begin
  if (not GSettings.Pastebin.Anon) and (cbb_private.ItemIndex = 2) then
  begin
    ShowMessage
      ('Приватная загрузка доступна только авторизованным пользователям!');
    exit;
  end;
  btn_load.Enabled := False;
  post := TStringList.Create;
  userkey := '';
  if not GSettings.Pastebin.Anon then
  begin
    post.Add('api_dev_key=' + API_DEV_KEY);
    post.Add('api_user_name=' + GSettings.Pastebin.Login);
    post.Add('api_user_password=' + GSettings.Pastebin.Password);
    try
      s := HTTP.post('http://pastebin.com/api/api_login.php', post);
    except
    end;
    if pos('Bad API request', s) > 0 then
    begin
      ShowMessage('Login Error:' + s);
      post.Free;
      btn_load.Enabled := true;
      exit;
    end;
    userkey := s;
    post.Clear;
  end;
  post.Add('api_option=paste');
  post.Add('api_dev_key=' + API_DEV_KEY);
  post.Add('api_paste_code=' + syn_code.Text);
  post.Add('api_paste_private=' + PastebinPrivates[cbb_private.ItemIndex].Name);
  post.Add('api_paste_name=' + edt_caption.Text);
  post.Add('api_paste_expire_date=' + PastebinExpires
    [cbb_expire.ItemIndex].Name);
  post.Add('api_paste_format=' + PastebinLangs[cbb_syntax.ItemIndex].Name);
  post.Add('api_user_key=' + userkey);
  try
    s := HTTP.post('http://pastebin.com/api/api_post.php', post);
  except
  end;
  post.Free;
  btn_load.Enabled := true;
  if pos('Bad API request', s) > 0 then
  begin
    ShowMessage('Load Error:' + s);
    exit;
  end;
  edt_link.Text := s;
  if GSettings.Pastebin.CopyLink then
    Clipboard.AsText := s;
  if edt_caption.Text = '' then
    k := '...'
  else
    k := edt_caption.Text;
  AddToRecentFiles(s, k, rfText);
end;

procedure TFPasteBin.btn_openClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(edt_link.Text), nil, nil, SW_SHOW)
end;

procedure TFPasteBin.cbb_syntaxChange(Sender: TObject);
begin
  syn_code.Highlighter := PastebinLangs[cbb_syntax.ItemIndex].Highlighter;
end;

procedure TFPasteBin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  Application.RemoveComponent(self);
end;

procedure TFPasteBin.FormCreate(Sender: TObject);
var
  i: integer;
begin
  Application.InsertComponent(self);
  HTTP.ReadTimeout := 30000;
  HTTP.ConnectTimeout := 20000;
  for i := 0 to High(PastebinLangs) do
    cbb_syntax.Items.Add(PastebinLangs[i].Caption);
  cbb_syntax.ItemIndex := GSettings.Pastebin.SyntaxIndex;
  cbb_syntaxChange(nil);
  for i := 0 to High(PastebinExpires) do
    cbb_expire.Items.Add(PastebinExpires[i].Caption);
  cbb_expire.ItemIndex := GSettings.Pastebin.ExpireIndex;
  for i := 0 to High(PastebinPrivates) do
    cbb_private.Items.Add(PastebinPrivates[i].Caption);
  cbb_private.ItemIndex := GSettings.Pastebin.PrivateIndex;
end;

procedure TFPasteBin.HTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  pb.Position := AWorkCount;
end;

procedure TFPasteBin.HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  pb.Max := AWorkCountMax;
  pb.Position := 0;
end;

procedure TFPasteBin.mm_clearClick(Sender: TObject);
begin
  syn_code.Clear;
end;

procedure TFPasteBin.mm_closeClick(Sender: TObject);
begin
  Close;
end;

procedure TFPasteBin.syn_codeChange(Sender: TObject);
begin
  sb_info.SimpleText := IntToStr(Length(syn_code.Text));
end;

procedure TFPasteBin.syn_codeClick(Sender: TObject);
begin
  syn_code.SetFocus;
end;

end.
