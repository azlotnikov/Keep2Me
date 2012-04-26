unit f_load;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, sSpeedButton, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ImgList, acAlphaImageList, Vcl.Clipbrd, loaders, funcs,
  JvTrayIcon, IdBaseComponent, IdAntiFreezeBase, Vcl.IdAntiFreeze, shellapi,
  shortlinks;

type
  TFLoad = class(TForm)
    pb: TProgressBar;
    mmo_Link: TMemo;
    btn_Copy: TsSpeedButton;
    btn_Open: TsSpeedButton;
    Images: TsAlphaImageList;
    lbl_link: TLabel;
    cbb_view: TComboBox;
    procedure btn_CopyClick(Sender: TObject);
    procedure btn_OpenClick(Sender: TObject);
    procedure cbb_viewChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    OriginLink: String;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    procedure LoadFile(FileName: string);
  end;

  // var
  // FLoad: TFLoad;

implementation

{$R *.dfm}

procedure TFLoad.btn_CopyClick(Sender: TObject);
begin
  Clipboard.AsText := mmo_Link.Text;
end;

procedure TFLoad.btn_OpenClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(OriginLink), nil, nil, SW_SHOW)
end;

procedure TFLoad.cbb_viewChange(Sender: TObject);
begin
  case cbb_view.ItemIndex of
    0:
      mmo_Link.Text := OriginLink;
    1:
      mmo_Link.Text := '[IMG]' + OriginLink + '[/IMG]';
    2:
      mmo_Link.Text := '[URL]' + OriginLink + '[/URL]';
    3:
      mmo_Link.Text := '<img>' + OriginLink + '</img>';
    4:
      mmo_Link.Text := '<a href="' + OriginLink + '">' + OriginLink + '</a>';
  end;
end;

procedure TFLoad.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TFLoad.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.RemoveComponent(self);
  Action := caFree;
end;

procedure TFLoad.FormCreate(Sender: TObject);
begin
  Application.InsertComponent(self);
end;

procedure TFLoad.LoadFile(FileName: string);
  procedure ReTry;
  begin
    if MessageDlg('Ошибка загрузки. Попробовать еще раз?', mtConfirmation,
      mbYesNo, 0) = mrYes then
      LoadFile(FileName)
    else
    begin
      DeleteFile(FileName);
      Hide;
    end;
  end;

var
  Cloader: ILoader;
  CShorter: IShorter;
  r: string;
begin
  try
    mmo_Link.Clear;
    OriginLink := '';
    cbb_view.ItemIndex := 0;
    cbb_view.Enabled := false;
    btn_Open.Enabled := false;
    btn_Copy.Enabled := false;
    if not GSettings.HideLoadForm then
      Show
    else
      Hide;
    Cloader := LoadersArray[GSettings.LoaderIndex].L.Create;
    Cloader.SetLoadBar(pb);
    Cloader.LoadFile(FileName);
  finally
    if Cloader.Error then
    begin
      Cloader.Free;
      ReTry;
    end
    else
    begin
      DeleteFile(FileName);
      r := Cloader.GetLink;
      try
        if GSettings.ShortLinkIndex > 0 then
        begin
          CShorter := ShortersArray[GSettings.ShortLinkIndex - 1].L.Create;
          CShorter.SetLoadBar(pb);
          CShorter.LoadFile(r);
          if CShorter.Error then
            GSettings.TrayIcon.BalloonHint('Keep2Me',
              'Не удалось укоротить ссылку')
          else
            r := CShorter.GetLink;
        end;
      except
        CShorter.Free;
      end;
      AddToRecentFiles(r, ExtractFileName(FileName), rfImg);
      OriginLink := r;
      mmo_Link.Text := r;
      if GSettings.CopyLink then
        Clipboard.AsText := r;
      Cloader.Free;
      pb.Position := pb.Max;
      cbb_view.Enabled := true;
      btn_Open.Enabled := true;
      btn_Copy.Enabled := true;
      if GSettings.ShowInTray then
        GSettings.TrayIcon.BalloonHint('Файл загружен', r);
    end;
  end;
end;

end.
