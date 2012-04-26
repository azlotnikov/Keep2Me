program updater;

uses
  Vcl.Forms,
  upd_main in 'upd_main.pas' {FMain},
  unitIsAdmin in 'unitIsAdmin.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Keep2Me Updater';
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.
