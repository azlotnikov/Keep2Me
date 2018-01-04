unit upd_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ImgList,
  acAlphaImageList, Vcl.Buttons, sSpeedButton, Vcl.StdCtrls, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, IdBaseComponent, IdAntiFreezeBase,
  Vcl.IdAntiFreeze, shellapi, unitIsAdmin, Vcl.ExtCtrls;

type
  TFMain = class(TForm)
    pb: TProgressBar;
    AntiFreeze: TIdAntiFreeze;
    HTTP: TIdHTTP;
    cb_close: TCheckBox;
    lbl_info: TLabel;
    btn_update: TButton;
    tmr_exit: TTimer;
    mmo_log: TMemo;
    procedure HTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure btn_updateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmr_exitTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.dfm}

function RunMeAsAdmin(hWnd: hWnd; filename: string; Parameters: string): Boolean;
var
  sei: TShellExecuteInfo;
begin
  ZeroMemory(@sei, SizeOf(sei));
  sei.cbSize := SizeOf(TShellExecuteInfo);
  sei.Wnd := hWnd;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := PChar('runas');
  sei.lpFile := PChar(filename); // PAnsiChar;
  if Parameters <> '' then sei.lpParameters := PChar(Parameters)
  else sei.lpParameters := nil; // PAnsiChar;
  sei.nShow := SW_SHOWNORMAL; // Integer;
  Result := ShellExecuteEx(@sei);
end;

function GetCommand(s: string): string;
begin
  Result := Copy(s, 1, Pos('&&', s) - 1);
end;

function GetValue(s: string; Param: integer = 1): string;
var
  i: integer;
begin
  for i := 1 to Param do Delete(s, 1, Pos('&&', s) + 1);
  if Pos('&&', s) > 0 then Delete(s, Pos('&&', s), Length(s) + 1 - Pos('&&', s));

  Result := s;
end;

function GetName(s: string): string;
var
  i: integer;
begin
  Result := '';
  for i := Length(s) downto 1 do
    if s[i] = '/' then break
    else Result := s[i] + Result;
end;

function ClearDir(Dir: string): Boolean;
var
  isFound: Boolean;
  sRec: TSearchRec;
begin
  Result := false;
  ChDir(Dir);
  if IOResult <> 0 then begin
    ShowMessage('Не могу войти в каталог: ' + Dir);
    Exit;
  end;
  if Dir[Length(Dir)] <> '\' then Dir := Dir + '\';
  isFound := FindFirst(Dir + '*.*', faAnyFile, sRec) = 0;
  while isFound do begin
    if (sRec.Name <> '.') and (sRec.Name <> '..') then
      if (sRec.Attr and faDirectory) = faDirectory then begin
        if not ClearDir(Dir + sRec.Name) then Exit;
        if (sRec.Name <> '.') and (sRec.Name <> '..') then
          if (Dir + sRec.Name) <> Dir then begin
            ChDir('..');
            RmDir(Dir + sRec.Name);
          end;
      end
      else if not DeleteFile(Dir + sRec.Name) then begin
        ShowMessage('Не могу удалить файл: ' + sRec.Name);
        Exit;
      end;
    isFound := FindNext(sRec) = 0;
  end;
  FindClose(sRec);
  Result := IOResult = 0;
end;

function FullRemoveDir(Dir: string; DeleteAllFilesAndFolders, StopIfNotAllDeleted, RemoveRoot: Boolean): Boolean;
var
  i: integer;
  sRec: TSearchRec;
  FN: string;
begin
  Result := false;
  if not DirectoryExists(Dir) then Exit;
  Result := True;
  // Добавляем слэш в конце и задаем маску - "все файлы и директории"
  Dir := IncludeTrailingBackslash(Dir);
  i := FindFirst(Dir + '*', faAnyFile, sRec);
  try
    while i = 0 do begin
      // Получаем полный путь к файлу или директорию
      FN := Dir + sRec.Name;
      // Если это директория
      if sRec.Attr = faDirectory then begin
        // Рекурсивный вызов этой же функции с ключом удаления корня
        if (sRec.Name <> '') and (sRec.Name <> '.') and (sRec.Name <> '..') then begin
          if DeleteAllFilesAndFolders then FileSetAttr(FN, faArchive);
          Result := FullRemoveDir(FN, DeleteAllFilesAndFolders, StopIfNotAllDeleted, True);
          if not Result and StopIfNotAllDeleted then Exit;
        end;
      end
      else // Иначе удаляем файл
      begin
        if DeleteAllFilesAndFolders then FileSetAttr(FN, faArchive);
        Result := DeleteFile(FN);
        if not Result and StopIfNotAllDeleted then Exit;
      end;
      // Берем следующий файл или директорию
      i := FindNext(sRec);
    end;
  finally
    FindClose(sRec);
  end;
  if not Result then Exit;
  if RemoveRoot then // Если необходимо удалить корень - удаляем
    if not RemoveDir(Dir) then Result := false;
end;

procedure TFMain.btn_updateClick(Sender: TObject);
const
{$IFDEF WIN32}
  SYS_UPDATE_FILE_LIST = 'http://keep2.me/program/fileslist.php';
{$ENDIF}
{$IFDEF WIN64}
  SYS_UPDATE_FILE_LIST = 'http://keep2.me/program64/fileslist.php';
{$ENDIF}
var
  t: tstringlist;
  i: integer;
  s, Path: string;
  LoadStream: TMemoryStream;
begin
  // if (not IsUserAnAdmin) then ShowMessage('Для корректной работы программы необходимы права Администратора');
  if FindWindow('TFMain', 'Keep2Me Настройки') <> 0 then begin
    ShowMessage('Закройте Keep2Me перед началом обновления');
    Exit;
  end;
  Show;
  Path := ExtractFilePath(ParamStr(0));
  HTTP.ReadTimeout := 5000;
  HTTP.ConnectTimeout := 5000;
  btn_update.Enabled := false;
  mmo_log.Lines.Add('Получаем список файлов');
  t := tstringlist.Create;
  try
    t.Text := HTTP.Get(SYS_UPDATE_FILE_LIST);
  except
  end;
  if t.Text = '' then begin
    mmo_log.Lines.Add('Не удалось подключиться к серверу!');
    mmo_log.Lines.Add('Ошибка обновления!');
    btn_update.Enabled := True;
    Exit;
  end;
  HTTP.ReadTimeout := 60000;
  HTTP.ConnectTimeout := 60000;
  for i := 0 to t.Count - 1 do begin
    s := GetCommand(t[i]);

    if s = 'download_file' then begin
      mmo_log.Lines.Add('Загружаем: ' + GetName(GetValue(t[i])));
      LoadStream := TMemoryStream.Create;
      try
        HTTP.Get(t[i], LoadStream);
      except
      end;
      LoadStream.SaveToFile(Path + GetName(GetValue(t[i])));
      LoadStream.Free;
    end
    else if s = 'delete_file' then begin
      mmo_log.Lines.Add('Удаляем: ' + GetValue(t[i]));
      try
        DeleteFile(Path + GetValue(t[i]));
      except
      end;
    end
    else if s = 'delete_dir' then begin
      mmo_log.Lines.Add('Удаляем: ' + GetValue(t[i]));
      try
        FullRemoveDir(Path + GetValue(t[i]), True, false, True);
      except
      end;
    end
    else if s = 'create_dir' then begin
      mmo_log.Lines.Add('Создаем: ' + GetValue(t[i]));
      try
        ForceDirectories(Path + GetValue(t[i]));
      except
      end;
    end
    else if s = 'clear_dir' then begin
      mmo_log.Lines.Add('Очищаем: ' + GetValue(t[i]));
      try
        ClearDir(Path + GetValue(t[i]));
      except
      end;
    end
    else if s = 'move_file' then begin
      mmo_log.Lines.Add('Перемещаем: ' + GetValue(t[i]));
      if FileExists(Path + GetValue(t[i])) then
        try
          MoveFile(PChar(Path + GetValue(t[i])), PChar(Path + GetValue(t[i], 2)));
        except
        end;
    end
    else if s = 'rename_file' then begin
      mmo_log.Lines.Add('Переименовываем: ' + GetValue(t[i]));
      if FileExists(Path + GetValue(t[i])) then
        try
          RenameFile(Path + GetValue(t[i]), Path + GetValue(t[i], 2));
        except
        end;
    end
    else if s = 'copy_file' then begin
      mmo_log.Lines.Add('Копируем: ' + GetValue(t[i]));
      if FileExists(Path + GetValue(t[i])) then
        try
          CopyFile(PChar(Path + GetValue(t[i])), PChar(Path + GetValue(t[i], 2)), false);
        except
        end;
    end;
  end;
  mmo_log.Lines.Add('Обновление завершено!');
  // RunMeAsAdmin(GetDesktopWindow, PChar(ExtractFilePath(ParamStr(0)) + 'keep2me.exe'), PChar('SHOWSETTINGS'));
  ShellExecute(GetDesktopWindow, 'open', PChar(ExtractFilePath(ParamStr(0)) + 'keep2me.exe'), 'SHOWSETTINGS',
    nil, SW_SHOW);
  if cb_close.Checked then tmr_exit.Enabled := True;
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
{$IFDEF WIN32}
  Caption := Caption + ' 32-bit';
{$ENDIF}
{$IFDEF WIN64}
  Caption := Caption + ' 64-bit';
{$ENDIF}
  Show;
  if ParamCount > 0 then
    if ParamStr(1) = 'STARTUPDATE' then begin
      Sleep(1000);
      btn_update.Click;
    end;
  // MoveFile(PChar(ExtractFilePath(ParamStr(0)) + 'dgs.png'), PChar(ExtractFilePath(ParamStr(0)) + 'smiles\dgs.png'));
end;

procedure TFMain.HTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  pb.Position := AWorkCount;
end;

procedure TFMain.HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  pb.Max := AWorkCountMax;
  pb.Position := 0;
end;

procedure TFMain.tmr_exitTimer(Sender: TObject);
begin
  halt;
end;

end.
