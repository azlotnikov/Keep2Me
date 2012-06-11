unit f_load;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.shellapi,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.IniFiles,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Buttons,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,
  Vcl.Clipbrd,
  Vcl.IdAntiFreeze,
  Vcl.ExtCtrls,
  IdBaseComponent,
  IdAntiFreezeBase,
  JvTrayIcon,
  acAlphaImageList,
  sSpeedButton,
  loaders,
  funcs,
  shortlinks,
  ConstStrings;

type
  TFLoad = class(TForm)
    pb: TProgressBar;
    mmo_Link: TMemo;
    btn_Copy: TsSpeedButton;
    btn_Open: TsSpeedButton;
    Images: TsAlphaImageList;
    lbl_link: TLabel;
    cbb_view: TComboBox;
    tmr_selfkill: TTimer;
    tmr_killEditor: TTimer;
    procedure btn_CopyClick(Sender: TObject);
    procedure btn_OpenClick(Sender: TObject);
    procedure cbb_viewChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmr_selfkillTimer(Sender: TObject);
    procedure tmr_killEditorTimer(Sender: TObject);
  private
    OriginLink: String;
    EditorToKill: TForm;
    CloseForm: Boolean;
    CanClose: Boolean;
    procedure SavePlacement;
    procedure LoadPlacement;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    procedure LoadFile(FileName: string; Editor: TForm);
    constructor CreateEx(FileName: string; Editor: TForm);
  end;

implementation

{$R *.dfm}

procedure TFLoad.btn_CopyClick(Sender: TObject);
begin
  Clipboard.AsText := mmo_Link.Text;
end;

procedure TFLoad.btn_OpenClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(OriginLink), nil, nil, SW_SHOW);
end;

procedure TFLoad.cbb_viewChange(Sender: TObject);
begin
  case cbb_view.ItemIndex of
    0: mmo_Link.Text := OriginLink;
    1: mmo_Link.Text := Format('[IMG]%s[/IMG]', [OriginLink]);
    2: mmo_Link.Text := Format('[URL]%s[/URL]', [OriginLink]);
    3: mmo_Link.Text := Format('<img>%s</img>', [OriginLink]);
    4: mmo_Link.Text := Format('<a href="%s">%s</a>', [OriginLink, OriginLink]);
  end;
end;

constructor TFLoad.CreateEx(FileName: string; Editor: TForm);
begin
  Create(nil);
  Application.InsertComponent(self);
  LoadPlacement;
  EditorToKill := Editor;
  CanClose := false;
  LoadFile(FileName, Editor);
end;

procedure TFLoad.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TFLoad.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if not CanClose then begin
    Action := caNone;
    exit;
  end;
  SavePlacement;
  Application.RemoveComponent(self);
  Action := caFree;
end;

procedure TFLoad.LoadFile(FileName: string; Editor: TForm);
  procedure ReTry;
  begin
    case MessageDlg('Ошибка загрузки. Попробовать еще раз?', mtConfirmation, mbYesNoCancel, 0) of
      mrYes: LoadFile(FileName, Editor);
      mrNo: begin
          CloseForm := True;
          CanClose := True;
          DeleteFile(FileName);
          tmr_killEditor.Enabled := True;
        end;
      mrCancel: begin
          DeleteFile(FileName);
          CanClose := True;
          Editor.Show;
          tmr_selfkill.Enabled := True;
        end;
    end;

  end;
  procedure EnableBtns(B: Boolean);
  begin
    cbb_view.Enabled := B;
    btn_Open.Enabled := B;
    btn_Copy.Enabled := B;
  end;

var
  Cloader: TLoader;
  CShorter: TShorter;
  r: string;
begin
  try
    mmo_Link.Clear;
    OriginLink := '';
    EnableBtns(false);
    if not GSettings.HideLoadForm then Show;
    if GSettings.FTP.ImgLoad then begin
      Cloader := TFTPLoader.Create;
      Cloader.SetLoadBar(pb);
      with GSettings.FTP do
        (Cloader as TFTPLoader).LoadFile(FileName, Host, Path, User, Pass, Port, URL, Passive);
    end else begin
      Cloader := LoadersArray[GSettings.LoaderIndex].Obj.Create;
      Cloader.SetLoadBar(pb);
      Cloader.LoadFile(FileName);
    end;
  finally
    if Cloader.Error then begin
      Cloader.Free;
      ReTry;
    end else begin
      DeleteFile(FileName);
      r := Cloader.GetLink;
      AddToRecentFiles(r, ExtractFileName(FileName), rfImg);
      if (GSettings.ShortLinkIndex > 0) and (GSettings.ShortImg) then
        try
          CShorter := ShortersArray[GSettings.ShortLinkIndex - 1].Obj.Create;
          CShorter.SetLoadBar(pb);
          CShorter.LoadFile(r);
          if CShorter.Error then GSettings.TrayIcon.BalloonHint(SYS_KEEP2ME, 'Не удалось укоротить ссылку')
          else r := CShorter.GetLink;
        except
          FreeAndNil(CShorter);
        end;
      CloseForm := false;
      OriginLink := r;
      mmo_Link.Text := r;
      cbb_viewChange(nil);
      if GSettings.CopyLink then Clipboard.AsText := mmo_Link.Text;
      FreeAndNil(Cloader);
      pb.Position := pb.Max;
      EnableBtns(True);
      GSettings.TrayIcon.Hint := r;
      if GSettings.ShowInTray then GSettings.TrayIcon.BalloonHint('Файл загружен', r);
      CanClose := True;
      tmr_killEditor.Enabled := True;
    end;
  end;
end;

procedure TFLoad.SavePlacement;
var
  F: TIniFile;
begin
  F := TIniFile.Create(ExtractFilePath(paramstr(0)) + SYS_LINK_FORM_NAME);
  F.WriteInteger('Form', 'ViewIndex', cbb_view.ItemIndex);
  F.Free;
end;

procedure TFLoad.LoadPlacement;
var
  F: TIniFile;
begin
  F := TIniFile.Create(ExtractFilePath(paramstr(0)) + SYS_LINK_FORM_NAME);
  cbb_view.ItemIndex := F.ReadInteger('Form', 'ViewIndex', cbb_view.ItemIndex);
  F.Free;
end;

procedure TFLoad.tmr_killEditorTimer(Sender: TObject);
begin
  EditorToKill.Close;
  if CloseForm then begin
    CanClose := True;
    Close;
  end;
  tmr_killEditor.Enabled := false;
end;

procedure TFLoad.tmr_selfkillTimer(Sender: TObject);
begin
  tmr_selfkill.Enabled := false;
  Close;
end;

end.
