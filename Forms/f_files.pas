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
  JvTrayIcon,
  acAlphaImageList,
  sSpeedButton,
  funcs,
  ConstStrings,
  fileuploaders,
  shortlinks;

type
  TFFiles = class(TForm)
  published
    lv_files     : TJvListView;
    Images       : TsAlphaImageList;
    pnl_buttons  : TPanel;
    btn_StartLoad: TsSpeedButton;
    btn_Stop     : TsSpeedButton;
    btn_settings : TsSpeedButton;
    mm           : TMainMenu;
    mm_menu      : TMenuItem;
    mm_load      : TMenuItem;
    mm_close     : TMenuItem;
    mm_links     : TMenuItem;
    mm_copyall   : TMenuItem;
    mm_openall   : TMenuItem;
    btn_copyall  : TsSpeedButton;
    btn_openall  : TsSpeedButton;
    pm           : TPopupMenu;
    pm_dontload  : TMenuItem;
    pm_load      : TMenuItem;
    pm_delete    : TMenuItem;
    pm_copy      : TMenuItem;
    pm_open      : TMenuItem;
    stat_hint    : TStatusBar;
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
    Links              : TArrayOfLinkData;
    CurrentLink        : Integer;
    StopLoad           : Boolean;
    FileLoader         : TFileLoader;
    FOrgListViewWndProc: TWndMethod;
    procedure LV_FilesWndProc(var Msg: TMessage);
    procedure LoadFileByIndex(Index: Integer);
    procedure RePaintList;
    procedure FileProgress(Sender: TObject; Text: string);
    procedure EnableButtons(B: Boolean);
    procedure SavePlacement;
    procedure LoadPlacement;
  public
    procedure StartLoad(Files: Tstringlist);
    procedure DropFiles(var Msg: TMessage); message WM_DROPFILES;

  protected
    procedure CreateParams(var Params: TCreateParams); override;

  end;

implementation

{$R *.dfm}

procedure TFFiles.EnableButtons(B: Boolean);
begin
  btn_StartLoad.Enabled := B;
  btn_Stop.Enabled      := not B;
end;

procedure TFFiles.btn_copyallClick(Sender: TObject);
var
  i: Integer;
  r: string;
begin
  r     := '';
  for i := 0 to high(Links) do
    if Links[i].Status = lsOK then
      r := r + Links[i].Link + #13#10;
  if r <> '' then
    Clipboard.AsText := r;
end;

procedure TFFiles.btn_openallClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to high(Links) do
    if Links[i].Status = lsOK then
      ShellExecute(Handle, 'open', PChar(Links[i].Link), nil, nil, SW_SHOW);
end;

procedure TFFiles.btn_StartLoadClick(Sender: TObject);
var
  i: Integer;

begin
  StopLoad := false;
  EnableButtons(false);
  for i := 0 to high(Links) do
  begin
    if StopLoad then
      break;
    CurrentLink := i;
    if Links[i].Status = lsWait then
      LoadFileByIndex(i);
  end;
  EnableButtons(true);
end;

procedure TFFiles.btn_StopClick(Sender: TObject);
begin
  StopLoad := true;
  if FileLoader <> nil then
    FileLoader.StopLoad;
end;

procedure TFFiles.DropFiles(var Msg: TMessage);
var
  i, count    : Integer;
  dropFileName: array [0 .. 511] of Char;
  MAXFILENAME : Integer;
begin
  MAXFILENAME := 511;
  count       := DragQueryFile(Msg.WParam, $FFFFFFFF, dropFileName, MAXFILENAME);
  for i       := 0 to count - 1 do
  begin
    DragQueryFile(Msg.WParam, i, dropFileName, MAXFILENAME);
    AddFileLink(dropFileName, Links);
  end;
  RePaintList;
  DragFinish(Msg.WParam);
end;

procedure TFFiles.LoadFileByIndex(Index: Integer);
var
  ALink   : string;
  CShorter: TShorter;
begin
  try
    if GSettings.FTP.FilesLoad then
      FileLoader := TFTPFileLoader.Create
    else
      FileLoader          := FileLoadersArray[GSettings.FileLoaderIndex].Obj.Create;
    FileLoader.OnHTTPWork := FileProgress;
    if FileExists(Links[index].FilePath) then
    begin
      CurrentLink         := index;
      Links[index].Status := lsInProgress;
      RePaintList;
      if GSettings.FTP.FilesLoad then
      begin
        with GSettings.FTP do
          (FileLoader as TFTPFileLoader).LoadFile(Links[index].FilePath, Host, Path, User, Pass, Port, URL, Passive);
      end
      else
        FileLoader.LoadFile(Links[index].FilePath);
    end else begin
      Links[index].Status := lsNoFile;
      RePaintList;
    end;
  finally
    if Links[index].Status <> lsNoFile then
    begin
      if FileLoader.Error then
      begin
        Links[index].Status     := lsError;
        Links[index].StatusText := 'Ошибка загрузки';
      end else begin
        Links[index].Status := lsOK;
        ALink               := FileLoader.GetLink;
        AddToRecentFiles(ALink, ExtractFileName(Links[index].FilePath), rfOther);
        if (GSettings.ShortFiles) then
          try
            CShorter := ShortersArray[GSettings.ShortLinkIndex].Obj.Create;
            CShorter.SetLoadBar(nil);
            CShorter.LoadFile(ALink);
            if CShorter.Error then
              GSettings.TrayIcon.BalloonHint(SYS_KEEP2ME, 'Не удалось укоротить ссылку', btInfo, 4000, false)
            else
              ALink := CShorter.GetLink;
          except
            FreeAndNil(CShorter);
          end;
        Links[index].Link       := ALink;
        Links[index].StatusText := ALink;

        if GSettings.ShowInTray then
        begin
          GSettings.TrayIcon.Hint := Links[index].Link;
          GSettings.TrayIcon.BalloonHint('Файл загружен', Links[index].Link, btInfo, 4000, false);
        end;
        if GSettings.CopyLink then
          Clipboard.AsText := Links[index].Link;
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
  if lv_files.ItemIndex < 0 then
    exit;
  if Links[lv_files.ItemIndex].Status = lsOK then
    Clipboard.AsText := Links[lv_files.ItemIndex].Link;
end;

procedure TFFiles.pm_deleteClick(Sender: TObject);
var
  i: Integer;
begin
  if lv_files.ItemIndex < 0 then
    exit;
  for i      := lv_files.ItemIndex to high(Links) - 1 do
    Links[i] := Links[i + 1];
  SetLength(Links, Length(Links) - 1);
  RePaintList;
end;

procedure TFFiles.pm_dontloadClick(Sender: TObject);
begin
  if lv_files.ItemIndex < 0 then
    exit;
  if Links[lv_files.ItemIndex].Status = lsWait then
  begin
    Links[lv_files.ItemIndex].Status     := lsCanceled;
    Links[lv_files.ItemIndex].StatusText := 'Пропустить';
  end else begin
    Links[lv_files.ItemIndex].Status     := lsWait;
    Links[lv_files.ItemIndex].StatusText := 'Ожидание';
  end;
  RePaintList;
end;

procedure TFFiles.pm_loadClick(Sender: TObject);
begin
  if lv_files.ItemIndex < 0 then
    exit;
  EnableButtons(false);
  StopLoad    := false;
  CurrentLink := lv_files.ItemIndex;
  LoadFileByIndex(lv_files.ItemIndex);
  EnableButtons(true);
end;

procedure TFFiles.pm_openClick(Sender: TObject);
begin
  if lv_files.ItemIndex < 0 then
    exit;
  if Links[lv_files.ItemIndex].Status = lsOK then
    ShellExecute(Handle, 'open', PChar(Links[lv_files.ItemIndex].Link), nil, nil, SW_SHOW);
end;

procedure TFFiles.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle   := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;

procedure TFFiles.FileProgress(Sender: TObject; Text: string);
begin
  Links[CurrentLink].StatusText           := Text;
  lv_files.Items[CurrentLink].SubItems[1] := Text;
end;

procedure TFFiles.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StopLoad := true;
  if FileLoader <> nil then
  begin
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
  FOrgListViewWndProc := lv_files.WindowProc;
  lv_files.WindowProc := LV_FilesWndProc;
  DragAcceptFiles(lv_files.Handle, true);
end;

procedure TFFiles.RePaintList;
var
  d, i, indx: Integer;
begin
  with lv_files do
  begin
    d := ItemIndex;
    Clear;
    for i := 0 to high(Links) do
      with Items.Add do
      begin
        Caption := Links[i].FilePath;
        SubItems.Add(Links[i].Size + ' КБ');
        SubItems.Add(Links[i].StatusText);
        case Links[i].Status of
          lsWait:
            indx := 2;
          lsError:
            indx := 1;
          lsInProgress:
            indx := 0;
          lsOK:
            indx := 3;
          lsCanceled:
            indx := 4;
          lsNoFile:
            indx := 1;
        end;
        ImageIndex := indx;
        StateIndex := indx;
      end;
    if (Length(Links) > 0) and (d <= high(Links)) then
      ItemIndex := d;
  end;

end;

procedure TFFiles.SavePlacement;
var
  F: TIniFile;
  i: Integer;
begin
  F := TIniFile.Create(SYS_PATH + SYS_FILE_LOADER_FORM_NAME);
  with F do
  begin
    WriteInteger('Form', 'Width', ClientWidth);
    WriteInteger('Form', 'Height', ClientHeight);
    WriteInteger('Form', 'Top', Top);
    WriteInteger('Form', 'Left', Left);
    WriteBool('Form', 'Maximized', (WindowState = wsMaximized));
    // WriteInteger('List', 'Width', lv_files.Width);
    // WriteInteger('List', 'Height', lv_files.Height);
    for i := 0 to lv_files.Columns.count - 1 do
      WriteInteger('List_Column' + inttostr(i), 'Width', lv_files.Columns[i].Width);
    Free;
  end;
end;

procedure TFFiles.LoadPlacement;
var
  F: TIniFile;
  i: Integer;
begin
  F := TIniFile.Create(SYS_PATH + SYS_FILE_LOADER_FORM_NAME);
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
    // lv_files.Width := ReadInteger('List', 'Width', lv_files.Width);
    // lv_files.Height := ReadInteger('List', 'Height', lv_files.Height);
    for i                       := 0 to lv_files.Columns.count - 1 do
      lv_files.Columns[i].Width := ReadInteger('List_Column' + inttostr(i), 'Width', lv_files.Columns[i].Width);
    Free;
  end;
end;

procedure TFFiles.lv_filesResize(Sender: TObject);
begin
  SavePlacement;
end;

procedure TFFiles.LV_FilesWndProc(var Msg: TMessage);
begin
  case Msg.Msg of
    WM_DROPFILES:
      DropFiles(Msg);
  else
    if Assigned(FOrgListViewWndProc) then
      FOrgListViewWndProc(Msg);
  end;
end;

procedure TFFiles.StartLoad(Files: Tstringlist);
var
  i: Integer;
begin
  SetLength(Links, 0);
  for i := 0 to Files.count - 1 do
    AddFileLink(Files[i], Links);
  Files.Free;
  RePaintList;
  Show;
end;

end.
