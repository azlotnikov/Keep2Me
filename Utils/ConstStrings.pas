unit ConstStrings;

interface

uses System.SysUtils;

const

{$IFDEF WIN32}
  SYS_KEEP_VERSION = '0.9.9.10';
{$ENDIF}
{$IFDEF WIN64}
  SYS_KEEP_VERSION = '0.9.9.10';
{$ENDIF}
{$IFDEF WIN32}
  SYS_PLATFORM = '32 bit';
{$ENDIF}
{$IFDEF WIN64}
  SYS_PLATFORM = '64 bit';
{$ENDIF}
  SYS_BUILD_TYPE = 'alone';
  // SYS_BUILD_TYPE = 'installation';
  SYS_CRYPT_KEY = 26123;

  // NOT FINISHED!
  SYS_CHANGELOG_FILE                 = 'changelog.txt';
  SYS_SETTINGS_FILE_NAME             = 'settings.ini';
  SYS_FILE_LOADER_FORM_NAME          = 'form_fileloader.ini';
  SYS_IMG_LOADER_FORM_NAME           = 'form_imgloader.ini';
  SYS_LINK_FORM_NAME                 = 'form_link.ini';
  SYS_FILELOADERS_SETTINGS_FILE_NAME = 'fileloaders_settings.ini';
  SYS_IMGLOADERS_SETTINGS_FILE_NAME  = 'imgloaders_settings.ini';
  SYS_LOADERS_SETTINGS_FILE_NAME     = 'loaders.ini';
  SYS_RECENT_FILE_NAME               = 'recent_files.ini';
  SYS_SHOW_SETTINGS_PARAM            = 'SHOWSETTINGS';
  SYS_TMP_IMG_FOLDER                 = 'tmpImg\';
  SYS_SMILES_FOLDER                  = 'smiles\';
  SYS_SETTINGS_FOLDER                = 'settings\';
  SYS_KEEP2ME                        = 'Keep2Me';
  SYS_USERAGENT                      = 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)';
{$IFDEF WIN32}
  SYS_UPDATE_CHECK_PAGE = 'http://keep2.me/program/lastversion.php?clientversion=' + SYS_KEEP_VERSION;
{$ENDIF}
{$IFDEF WIN64}
  SYS_UPDATE_CHECK_PAGE = 'http://keep2.me/program64/lastversion.php?clientversion=' + SYS_KEEP_VERSION;
{$ENDIF}
  SYS_UPDATE_TOKEN     = 'K2M_VERSION';
  SYS_UPDATER_EXE_NAME = 'updater.exe';

  INI_COMMON_SETTINGS = 'CommonSettings';
  INI_HOT_KEYS        = 'HotKeys';
  INI_PASTEBIN        = 'Pastebin';
  INI_FTP             = 'FTP';
  INI_RECENTFILES     = 'RecentFiles';

  RU_SEL_TYPES_ABOUT = '��� Real-Time ��������� ����� ���, ��� ���������� �� ������ �������� � ������� ������. ' +
    '��� ����������� ��������� �� ���� ��������� ������ ������� �� ��� ��������� ���������, ' +
    '��� ����� ���� ������, ���� ����� ����� �����-�� ������������ ��������, ��������� ������� ������� � �. �.';

  RU_NOT_ADMIN               = '��� ���������� ������ ��������� ���������� ����� ��������������.';
  RU_SELECT_SCREEN_PART      = '�������� ������� ������';
  RU_SEND_FROM_BUFFER        = '��������� �� ������ ������';
  RU_SEND_WINDOW_SCREEN      = '��������� �������� ����';
  RU_SEND_TO_PASTEBIN        = '��������� �� Pastebin.com';
  RU_OPEN_IMAGE_AND_LOAD     = '������� � ��������� �����������';
  RU_OPEN_FILE_AND_LOAD      = '������� � ��������� ����';
  RU_LOAD_FILES_FROM_BUF     = '��������� ����� �� ������';
  RU_SHORT_LINK_FROM_BUF     = '��������� ������ �� ������';
  RU_SHOW_SETTNGS            = '�������� ���������';
  RU_NO                      = '���';
  RU_HINT                    = '���������';
  RU_SELECTWINDOW_HINT       = '��� - ���������� ����, ��� - ������� �������� ����';
  RU_NOT_AN_IMAGE_CONTENT    = '���������� �� �������� ������������';
  RU_SERVER_CONNECTION_ERROR = '������ ��������� � ��������';
  RU_UPDATE_AVAILABLE        = 'Keep2Me: �������� ����������  %s (���� ������: %s). �������� ���������?';
  RU_ERROR_FIND_UPDATER      = '������: �� ������� ����� ';
  RU_UPTODATE_VERSION        = '� ��� ���������� ������ (' + SYS_KEEP_VERSION + ')';
  RU_IMG_LOAD_ERROR          = '������ �������� �����������: ';
  RU_HOTKEYS_ARE_EQUAL       = '��� ���������� ��� ���������������� ��� �������� ��������!';
  RU_HOTKEY_IS_FREE          = '���������� ��������!';
  RU_HOTKEY_IS_BUSY          = '���������� ������!';

var
  SYS_PATH: string = '';

implementation

initialization

SYS_PATH := ExtractFilePath(ParamStr(0));

end.
