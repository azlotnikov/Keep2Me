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
      result.Add(Format('%d: %d x %d', [i + 1, Screen.Monitors[i].Width, Screen.Monitors[i].Height]));
end;

function TMonitorManager.GetMonitorByPoint(P: TPoint): Integer;
var
  i: Integer;
begin
  result := 0;
  for i := 0 to Screen.MonitorCount - 1 do
    if PtInRect(Screen.Monitors[i].WorkareaRect, P) then exit(i + 1);
end;

function TMonitorManager.GetRect(Index: Integer): TRect;
var
  i: Integer;
  MaxWidth, MaxHeight: Integer;
begin
  MaxWidth := -maxint;
  MaxHeight := -maxint;
  if Index > 0 then exit(Screen.Monitors[Index - 1].BoundsRect);
  with Screen do
    for i := 0 to MonitorCount - 1 do begin
      if Monitors[i].Left + Monitors[i].Width > MaxWidth then MaxWidth := Monitors[i].Left + Monitors[i].Width;
      if Monitors[i].Top + Monitors[i].Height > MaxHeight then MaxHeight := Monitors[i].Top + Monitors[i].Height;
    end;
  result := Rect(0, 0, MaxWidth, MaxHeight);
end;

end.
