unit mons;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Forms;

type
  TMonitorManager = class
  public
    function GetMonitorByPoint(P: TPoint): Integer;
    function GetCaptions: TStringList;
    function GetRect(Index: Integer): TRect;
  end;

implementation

{ TMonitorManager }

function TMonitorManager.GetCaptions: TStringList;
var
  i: Integer;
begin
  result := TStringList.Create;
  result.Add('0: Все мониторы');
  for i := 0 to Screen.MonitorCount - 1 do
    result.Add(Format('%d: %d x %d', [i + 1, Screen.Monitors[i].WorkareaRect.Width, Screen.Monitors[i].WorkareaRect.Height]));
end;

function TMonitorManager.GetMonitorByPoint(P: TPoint): Integer;
var
  i: Integer;
begin
  result := 0;
  for i  := 0 to Screen.MonitorCount - 1 do
    if PtInRect(Screen.Monitors[i].WorkareaRect, P) then
      exit(i + 1);
end;

function TMonitorManager.GetRect(Index: Integer): TRect;
begin
  if index > 0 then
    result := Screen.Monitors[index - 1].WorkareaRect
  else
    result := Screen.DesktopRect;
end;

initialization

end.
