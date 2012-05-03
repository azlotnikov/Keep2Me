program keep2me;

uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  Vcl.Dialogs,
  myhotkeys in 'Utils\myhotkeys.pas',
  funcs in 'Utils\funcs.pas',
  mons in 'Utils\mons.pas',
  loaders in 'Utils\loaders.pas',
  shortlinks in 'Utils\shortlinks.pas',
  imgtools in 'Utils\imgtools.pas',
  pastebin_tools in 'Utils\pastebin_tools.pas',
  uSynEditPopupEdit in 'Utils\uSynEditPopupEdit.pas',
  cript in 'Utils\cript.pas',
  unitIsAdmin in 'Utils\unitIsAdmin.pas',
  ConstStrings in 'Utils\ConstStrings.pas',
  main in 'Forms\main.pas' {FMain} ,
  f_load in 'Forms\f_load.pas' {FLoad} ,
  f_points in 'Forms\f_points.pas' {FPoints} ,
  f_selfield in 'Forms\f_selfield.pas' {FSelField} ,
  f_image in 'Forms\f_image.pas' {FImage} ,
  f_about in 'Forms\f_about.pas' {FAbout} ,
  f_framsize in 'Forms\f_framsize.pas' {FFrameSize} ,
  f_windows in 'Forms\f_windows.pas' {FWindows} ,
  f_pastebin in 'Forms\f_pastebin.pas' {FPasteBin};

{$R *.res}

begin
  if FindWindow('TFMain', 'Keep2Me Настройки') <> 0 then begin
    ShowMessage('Keep2Me уже запущен!');
    Halt(0);
  end;

  Application.Initialize;
  Application.Title := 'Keep2Me';
  Application.ShowMainForm := false;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFWindows, FWindows);
  Application.CreateForm(TFPoints, FPoints);
  Application.CreateForm(TFSelField, FSelField);
  Application.CreateForm(TFAbout, FAbout);
  Application.CreateForm(TFFrameSize, FFrameSize);
  Application.Run;

end.
