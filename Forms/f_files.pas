unit f_files;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellAPI,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.IniFiles,
  Vcl.Clipbrd,
  Vcl.ExtCtrls,
  Vcl.Buttons,
  Vcl.Menus,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ImgList,
  Vcl.ComCtrls,
  JvExComCtrls,
  JvListView,
  acAlphaImageList,
  sSpeedButton,
  funcs,
  ConstStrings,
  fileuploaders,
  shortlinks;

type
  TLinkStatus = (lsWait, lsError, lsOK, lsCanceled, lsNoFile, lsInProgress);

type
  TLinkData = record
    FilePath: String;
    Size: String;
    Status: TLinkStatus;
    StatusText: String;
    Link: String;
  end;

type
  TFFiles = class(TForm)
    lv_files: TJvListView;
    Images: TsAlphaImageList;
    pnl_buttons: TPanel;
    btn_StartLoad: TsSpeedButton;
    btn_Stop: TsSpeedButton;
    btn_settings: TsSpeedButton;
    mm: TMainMenu;
    mm_menu: TMenuItem;
    mm_load: TMenuItem;
    mm_close: TMenuItem;
    mm_links: TMenuItem;
    mm_copyall: TMenuItem;
    mm_openall: TMenuItem;
    btn_copyall: TsSpeedButton;
    btn_openall: TsSpeedButton;
    pm: TPopupMenu;
    pm_dontload: TMenuItem;
    pm_load: TMenuItem;
    pm_delete: TMenuItem;
    pm_copy: TMenuItem;
    pm_open: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btn_StartLoadClick(Sender: TObject);
    procedure btn_copyallClick(Sender: TObject);
    procedure btn_openallClick(Sender: TObject);
    procedure mm_closeClick(Sender: TObject);
    procedure btn_StopClick(Sender: TObject);
    procedure pm_loadClick(Sender: TObject);
    procedure pm_deleteClick(Sender: TObject);
    procedure pm_copyClick(Sender: TObject);
    procedure pm_openClick(Sender: TObject);
    procedure pm_dontloadClick(Sender: TObject);
    procedure lv_filesResize(Sender: TObject);
  private
    Links: array of TLinkData;
    CurrentLink: Integer;
    StopLoad: Boolean;
    FileLoader: TFileLoader;
    procedure LoadFileByIndex(Index: Integer);
    procedure RePaintList;
    procedure FileProgress(Sender: TObject; Text: string);
    procedure EnableButtons(B: Boolean);
    procedure SavePlacement;
    procedure LoadPlacement;
  public
    procedure StartLoad(Files: Tstringlist);
  protected
    procedure CreateParams(var Params: TCreateParams); override;

  end;

implementation

{$R *.dfm}

procedure TFFiles.EnableButtons(B: Boolean);
begin
  btn_StartLoad.Enabled := B;
  btn_Stop.Enabled := not B;
end;

procedure TFFiles.btn_copyallClick(Sender: TObject);
var
  i: Integer;
  r: string;
begin
  r := '';
  for i := 0 to High(Links) do
    if Links[i].Status = lsOK then r := r + Links[i].Link + #13#10;
  if r <> '' then Clipboard.AsText := r;
end;

procedure TFFiles.btn_openallClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to High(Links) do
    if Links[i].Status = lsOK then ShellExecute(Handle, 'open', PChar(Links[i].Link), nil, nil, SW_SHOW);
end;

procedure TFFiles.btn_StartLoadClick(Sender: TObject);
var
  i: Integer;

begin
  StopLoad := false;
  EnableButtons(false);
  for i := 0 to High(Links) do begin
    if StopLoad then break;
    CurrentLink := i;
    if Links[i].Status = lsWait then LoadFileByIndex(i);
  end;
  EnableButtons(true);
end;

procedure TFFiles.btn_StopClick(Sender: TObject);
begin
  StopLoad := true;
  if FileLoader <> nil then FileLoader.StopLoad;
end;

procedure TFFiles.LoadFileByIndex(Index: Integer);
var
  ALink: string;
  CShorter: TShorter;
begin
  try
    if GSettings.FTP.FilesLoad then FileLoader := TFTPFileLoader.Create
    else FileLoader := FileLoadersArray[GSettings.FileLoaderIndex].Obj.Create;
    FileLoader.OnHTTPWork := FileProgress;
    if FileExists(Links[Index].FilePath) then begin
      CurrentLink := Index;
      Links[Index].Status := lsInProgress;
      RePaintList;
      if GSettings.FTP.FilesLoad then begin
        with GSettings.FTP do
          (FileLoader as TFTPFileLoader).LoadFile(Links[Index].FilePath, Host, Path, User, Pass, Port, URL, Passive);
      end
      else FileLoader.LoadFile(Links[Index].FilePath);
    end else begin
      Links[Index].Status := lsNoFile;
      RePaintList;
    end;
  finally
    if Links[Index].Status <> lsNoFile then begin
      if FileLoader.Error then begin
        Links[Index].Status := lsError;
        Links[Index].StatusText := 'Ошибка загрузки';
      end else begin
        Links[Index].Status := lsOK;
        ALink := FileLoader.GetLink;
        AddToRecentFiles(ALink, ExtractFileName(Links[Index].FilePath), rfOther);
        try
          if GSettings.ShortLinkIndex > 0 then begin
            CShorter := ShortersArray[GSettings.ShortLinkIndex - 1].Obj.Create;
            CShorter.SetLoadBar(nil);
            CShorter.LoadFile(ALink);
            if CShorter.Error then GSettings.TrayIcon.BalloonHint(SYS_KEEP2ME, 'Не удалось укоротить ссылку')
            else ALink := CShorter.GetLink;
          end;
        except
          FreeAndNil(CShorter);
        end;
        Links[Index].Link := ALink;
        Links[Index].StatusText := ALink;

        if GSettings.ShowInTray then begin
          GSettings.TrayIcon.Hint := Links[Index].Link;
          GSettings.TrayIcon.BalloonHint('Файл загружен', Links[Index].Link);
        end;
        if GSettings.CopyLink then Clipboard.AsText := Links[Index].Link;
      end;
    end;
    RePaintList;
    FreeAndNil(FileLoader);
  end;
end;

procedure TFFiles.mm_closeClick(Sender: TObject);
begin
  Close;
end;

procedure TFFiles.pm_copyClick(Sender: TObject);
begin
  if lv_files.ItemIndex < 0 then exit;
  if Links[lv_files.ItemIndex].Status = lsOK then Clipboard.AsText := Links[lv_files.ItemIndex].Link;
end;

procedure TFFiles.pm_deleteClick(Sender: TObject);
var
  i: Integer;
begin
  if lv_files.ItemIndex < 0 then exit;
  for i := lv_files.ItemIndex to High(Links) - 1 do Links[i] := Links[i + 1];
  SetLength(Links, Length(Links) - 1);
  RePaintList;
end;

procedure TFFiles.pm_dontloadClick(Sender: TObject);
begin
  if lv_files.ItemIndex < 0 then exit;
  if Links[lv_files.ItemIndex].Status = lsWait then begin
    Links[lv_files.ItemIndex].Status := lsCanceled;
    Links[lv_files.ItemIndex].StatusText := 'Пропустить';
  end else begin
    Links[lv_files.ItemIndex].Status := lsWait;
    Links[lv_files.ItemIndex].StatusText := 'Ожидание';
  end;
  RePaintList;
end;

procedure TFFiles.pm_loadClick(Sender: TObject);
begin
  if lv_files.ItemIndex < 0 then exit;
  EnableButtons(false);
  StopLoad := false;
  CurrentLink := lv_files.ItemIndex;
  LoadFileByIndex(lv_files.ItemIndex);
  EnableButtons(true);
end;

procedure TFFiles.pm_openClick(Sender: TObject);
begin
  if lv_files.ItemIndex < 0 then exit;
  if Links[lv_files.ItemIndex].Status = lsOK then
      ShellExecute(Handle, 'open', PChar(Links[lv_files.ItemIndex].Link), nil, nil, SW_SHOW);
end;

procedure TFFiles.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TFFiles.FileProgress(Sender: TObject; Text: string);
begin
  Links[CurrentLink].StatusText := Text;
  lv_files.Items[CurrentLink].SubItems[1] := Text;
end;

procedure TFFiles.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StopLoad := true;
  if FileLoader <> nil then begin
    FileLoader.StopLoad;
    FileLoader.Free;
  end;
  Application.RemoveComponent(self);
  SavePlacement;
  Action := caFree;
end;

procedure TFFiles.FormCreate(Sender: TObject);
begin
  Application.InsertComponent(self);
  LoadPlacement;
end;

procedure TFFiles.RePaintList;
var
  d, i, indx: Integer;
begin
  with lv_files do begin
    d := ItemIndex;
    Clear;
    for i := 0 to High(Links) do
      with Items.Add do begin
        Caption := Links[i].FilePath;
        SubItems.Add(Links[i].Size + ' КБ');
        SubItems.Add(Links[i].StatusText);
        case Links[i].Status of
          lsWait: indx := 2;
          lsError: indx := 1;
          lsInProgress: indx := 0;
          lsOK: indx := 3;
          lsCanceled: indx := 4;
          lsNoFile: indx := 1;
        end;
        ImageIndex := indx;
        StateIndex := indx;
      end;
    if (Length(Links) > 0) and (d <= High(Links)) then ItemIndex := d;
  end;

end;

procedure TFFiles.SavePlacement;
var
  F: TIniFile;
  i: Integer;
begin
  F := TIniFile.Create(ExtractFilePath(paramstr(0)) + SYS_FILE_LOADER_FORM_NAME);
  with F do begin
    WriteInteger('Form', 'Width', Width);
    WriteInteger('Form', 'Height', Height);
    WriteInteger('Form', 'Top', Top);
    WriteInteger('Form', 'Left', Left);
    WriteInteger('List', 'Width', lv_files.Width);
    WriteInteger('List', 'Height', lv_files.Height);
    for i := 0 to lv_files.Columns.Count - 1 do
        WriteInteger('List_Column' + inttostr(i), 'Width', lv_files.Columns[i].Width);
    Free;
  end;
end;

procedure TFFiles.LoadPlacement;
var
  F: TIniFile;
  i: Integer;
begin
  F := TIniFile.Create(ExtractFilePath(paramstr(0)) + SYS_FILE_LOADER_FORM_NAME);
  with F do begin
    Width := ReadInteger('Form', 'Width', Width);
    Height := ReadInteger('Form', 'Height', Height);
    Top := ReadInteger('Form', 'Top', Top);
    Left := ReadInteger('Form', 'Left', Left);
    lv_files.Width := ReadInteger('List', 'Width', lv_files.Width);
    lv_files.Height := ReadInteger('List', 'Height', lv_files.Height);
    for i := 0 to lv_files.Columns.Count - 1 do
        lv_files.Columns[i].Width := ReadInteger('List_Column' + inttostr(i), 'Width', lv_files.Columns[i].Width);
    Free;
  end;
end;

procedure TFFiles.lv_filesResize(Sender: TObject);
begin
  SavePlacement;
end;

procedure TFFiles.StartLoad(Files: Tstringlist);
var
  i: Integer;
begin
  SetLength(Links, Files.Count);
  for i := 0 to Files.Count - 1 do begin
    Links[i].FilePath := Files[i];
    if FileExists(Files[i]) then begin
      Links[i].Size := inttostr(GetFileSize(Files[i]) div 1024);
      if Links[i].Size = '0' then Links[i].Size := '1';
      Links[i].StatusText := 'Ожидание';
      Links[i].Status := lsWait;
    end else begin
      Links[i].Size := '0';
      Links[i].Status := lsNoFile;
      Links[i].StatusText := 'Файл отсутствует!';
    end;
  end;
  Files.Free;
  RePaintList;
  Show;
end;

end.
