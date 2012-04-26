unit upd_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ImgList,
  acAlphaImageList, Vcl.Buttons, sSpeedButton, Vcl.StdCtrls, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, IdBaseComponent, IdAntiFreezeBase,
  Vcl.IdAntiFreeze, shellapi, unitIsAdmin;

type
  TFMain = class(TForm)
    pb: TProgressBar;
    Images: TsAlphaImageList;
    stat: TStatusBar;
    AntiFreeze: TIdAntiFreeze;
    HTTP: TIdHTTP;
    cb_close: TCheckBox;
    lbl_info: TLabel;
    btn_update: TsSpeedButton;
    procedure HTTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure btn_updateClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.dfm}

function RunMeAsAdmin(hWnd: hWnd; filename: string; Parameters: string)
  : Boolean;
var
  sei: TShellExecuteInfo;
begin
  ZeroMemory(@sei, SizeOf(sei));
  sei.cbSize := SizeOf(TShellExecuteInfo);
  sei.Wnd := hWnd;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := PChar('runas');
  sei.lpFile := PChar(filename); // PAnsiChar;
  if Parameters <> '' then
    sei.lpParameters := PChar(Parameters)
  else
    sei.lpParameters := nil; // PAnsiChar;
  sei.nShow := SW_SHOWNORMAL; // Integer;
  Result := ShellExecuteEx(@sei);
end;

function GetCommand(s: string): string;
begin
  Result := Copy(s, 1, Pos('&&', s) - 1);
end;

function GetValue(s: string): string;
begin
  Delete(s, 1, Pos('&&', s) + 1);
  Result := s;
end;

function GetName(s: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := length(s) downto 1 do
    if s[i] = '/' then
      break
    else
      Result := s[i] + Result;
end;

function ClearDir(Dir: string): Boolean;
var
  isFound: Boolean;
  sRec: TSearchRec;
begin
  Result := false;
  ChDir(Dir);
  if IOResult <> 0 then
  begin
    ShowMessage('Не могу войти в каталог: ' + Dir);
    Exit;
  end;
  if Dir[length(Dir)] <> '\' then
    Dir := Dir + '\';
  isFound := FindFirst(Dir + '*.*', faAnyFile, sRec) = 0;
  while isFound do
  begin
    if (sRec.Name <> '.') and (sRec.Name <> '..') then
      if (sRec.Attr and faDirectory) = faDirectory then
      begin
        if not ClearDir(Dir + sRec.Name) then
          Exit;
        if (sRec.Name <> '.') and (sRec.Name <> '..') then
          if (Dir + sRec.Name) <> Dir then
          begin
            ChDir('..');
            RmDir(Dir + sRec.Name);
          end;
      end
      else if not DeleteFile(Dir + sRec.Name) then
      begin
        ShowMessage('Не могу удалить файл: ' + sRec.Name);
        Exit;
      end;
    isFound := FindNext(sRec) = 0;
  end;
  FindClose(sRec);
  Result := IOResult = 0;
end;

function FullRemoveDir(Dir: string; DeleteAllFilesAndFolders,
  StopIfNotAllDeleted, RemoveRoot: Boolean): Boolean;
var
  i: Integer;
  sRec: TSearchRec;
  FN: string;
begin
  Result := false;
  if not DirectoryExists(Dir) then
    Exit;
  Result := True;
  // Добавляем слэш в конце и задаем маску - "все файлы и директории"
  Dir := IncludeTrailingBackslash(Dir);
  i := FindFirst(Dir + '*', faAnyFile, sRec);
  try
    while i = 0 do
    begin
      // Получаем полный путь к файлу или директорию
      FN := Dir + sRec.Name;
      // Если это директория
      if sRec.Attr = faDirectory then
      begin
        // Рекурсивный вызов этой же функции с ключом удаления корня
        if (sRec.Name <> '') and (sRec.Name <> '.') and (sRec.Name <> '..') then
        begin
          if DeleteAllFilesAndFolders then
            FileSetAttr(FN, faArchive);
          Result := FullRemoveDir(FN, DeleteAllFilesAndFolders,
            StopIfNotAllDeleted, True);
          if not Result and StopIfNotAllDeleted then
            Exit;
        end;
      end
      else // Иначе удаляем файл
      begin
        if DeleteAllFilesAndFolders then
          FileSetAttr(FN, faArchive);
        Result := DeleteFile(FN);
        if not Result and StopIfNotAllDeleted then
          Exit;
      end;
      // Берем следующий файл или директорию
      i := FindNext(sRec);
    end;
  finally
    FindClose(sRec);
  end;
  if not Result then
    Exit;
  if RemoveRoot then // Если необходимо удалить корень - удаляем
    if not RemoveDir(Dir) then
      Result := false;
end;

procedure TFMain.btn_updateClick(Sender: TObject);
var
  t: tstringlist;
  i: Integer;
  s: string;
  LoadStream: TMemoryStream;
begin
  if (not IsUserAnAdmin) then
    ShowMessage
      ('Для корректной работы программы необходимы права Администратора');
  if FindWindow('TFMain', 'Keep2Me Настройки') <> 0 then
  begin
    ShowMessage('Закройте Keep2Me перед началом обновления');
    Exit;
  end;
  HTTP.ReadTimeout := 5000;
  HTTP.ConnectTimeout := 5000;
  btn_update.Enabled := false;
  stat.Panels[0].Text := 'Получаем список файлов';
  t := tstringlist.Create;
  try
    t.Text := HTTP.Get('http://keep2.me/loaderfiles/fileslist.php');
  except
  end;
  if t.Text = '' then
  begin
    ShowMessage('Не удалось подключиться к серверу!');
    stat.Panels[0].Text := 'Ошибка обновления!';
    btn_update.Enabled := True;
    Exit;
  end;
  HTTP.ReadTimeout := 60000;
  HTTP.ConnectTimeout := 60000;
  LoadStream := TMemoryStream.Create; // выделение памяти под переменную
  for i := 0 to t.Count - 1 do
  begin
    s := GetCommand(t[i]);

    if s = 'download_file' then
    begin
      stat.Panels[0].Text := 'Загружаем: ' + GetName(GetValue(t[i]));
      try
        HTTP.Get(t[i], LoadStream);
      except
      end;
      LoadStream.SaveToFile(ExtractFilePath(ParamStr(0)) +
        GetName(GetValue(t[i])));
      LoadStream.Clear;
    end
    else if s = 'delete_file' then
    begin
      stat.Panels[0].Text := 'Удаляем: ' + GetValue(t[i]);
      try
        DeleteFile(ExtractFilePath(ParamStr(0)) + GetValue(t[i]));
      except
      end;
    end
    else if s = 'delete_dir' then
    begin
      stat.Panels[0].Text := 'Удаляем: ' + GetValue(t[i]);
      try
        FullRemoveDir(ExtractFilePath(ParamStr(0)) + GetValue(t[i]) + '\', True,
          false, True);
      except
      end;
    end
    else if s = 'create_dir' then
    begin
      stat.Panels[0].Text := 'Создаем: ' + GetValue(t[i]);
      try
        ForceDirectories(ExtractFilePath(ParamStr(0)) + GetValue(t[i]) + '\');
      except
      end;
    end
    ELSE if s = 'clear_dir' then
    begin
      stat.Panels[0].Text := 'Очищаем: ' + GetValue(t[i]);
      try
        ClearDir(ExtractFilePath(ParamStr(0)) + GetValue(t[i]) + '\');
      except
      end;
    end;
  end;
  stat.Panels[0].Text := 'Обновление завершено!';
  RunMeAsAdmin(GetDesktopWindow,
    PChar(ExtractFilePath(ParamStr(0)) + 'keep2me.exe'), PChar('SHOWSETTINGS'));
  LoadStream.Free;
  if cb_close.Checked then
    Application.Terminate;
end;

procedure TFMain.HTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  pb.Position := AWorkCount;
end;

procedure TFMain.HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  pb.Max := AWorkCountMax;
  pb.Position := 0;
end;

end.
