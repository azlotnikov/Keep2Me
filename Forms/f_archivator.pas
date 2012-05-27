unit f_archivator;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, sSpeedButton, Vcl.StdCtrls, Vcl.Mask, JvExMask, JvToolEdit,
  JvComponentBase, JvZlibMultiple, funcs, Vcl.ComCtrls;

type
  TFArchivator = class(TForm)
    ZLib: TJvZlibMultiple;
    edt_savefile: TJvFilenameEdit;
    mmo_files: TMemo;
    btn_Save: TsSpeedButton;
    btn_cancel: TsSpeedButton;
    prb_compress: TProgressBar;
    procedure btn_SaveClick(Sender: TObject);
    procedure ZLibProgress(Sender: TObject; Position, Total: Integer);
  private
    Files: TStringList;
    procedure FilesToMemo;
  public
    constructor CreateEx(AOwner: TWinControl; AFiles: TStringList);
  end;

implementation

{$R *.dfm}
{ TFArchivator }

procedure TFArchivator.btn_SaveClick(Sender: TObject);
begin
  //
  ZLib.CompressFiles(Files);
end;

constructor TFArchivator.CreateEx(AOwner: TWinControl; AFiles: TStringList);
begin
  Create(nil);
  Files := AFiles;
  FilesToMemo;
  edt_savefile.Text := ChangeFileExt(Files[0], '.zip');
  Show;
end;

procedure TFArchivator.FilesToMemo;
var
  i: Integer;
begin
  for i := 0 to Files.Count - 1 do
      mmo_files.lines.add(Format('[%d สม] %s', [GetFileSize(Files[i]) div 1024, Files[i]]));
end;

procedure TFArchivator.ZLibProgress(Sender: TObject; Position, Total: Integer);
begin
  prb_compress.Max := Total;
  prb_compress.Position := Position;
end;

end.
