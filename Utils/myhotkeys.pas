unit myhotkeys;

interface

uses Winapi.Windows, System.Classes;

type
  TMyHotKey = record
    Caption: String;
    Value: Word;
  end;

var
  HotKeysArray: array of TMyHotKey;

procedure AddToHotKeys(Caption: string; Value: Integer);

implementation

procedure AddToHotKeys(Caption: string; Value: Integer);
begin
  SetLength(HotKeysArray, Length(HotKeysArray) + 1);
  HotKeysArray[High(HotKeysArray)].Caption := Caption;
  HotKeysArray[High(HotKeysArray)].Value := Value;
end;

initialization

AddToHotKeys('F1', vk_f1);
AddToHotKeys('F2', vk_f2);
AddToHotKeys('F3', vk_f3);
AddToHotKeys('F4', vk_f4);
AddToHotKeys('F5', vk_f5);
AddToHotKeys('F6', vk_f6);
AddToHotKeys('F7', vk_f7);
AddToHotKeys('F8', vk_f8);
AddToHotKeys('F9', vk_f9);
AddToHotKeys('F10', vk_f10);
AddToHotKeys('F11', vk_f11);
AddToHotKeys('F12', vk_f11);

AddToHotKeys('Pause', vk_Pause);
AddToHotKeys('End', vk_End);
AddToHotKeys('Home', vk_Home);
AddToHotKeys('Print Screen', vk_SnapShot);
AddToHotKeys('Insert', vk_Insert);
AddToHotKeys('Delete', vk_Delete);

AddToHotKeys('Q', ord('Q'));
AddToHotKeys('W', ord('W'));
AddToHotKeys('E', ord('E'));
AddToHotKeys('R', ord('R'));
AddToHotKeys('T', ord('T'));
AddToHotKeys('Y', ord('Y'));
AddToHotKeys('U', ord('U'));
AddToHotKeys('I', ord('I'));
AddToHotKeys('O', ord('O'));
AddToHotKeys('P', ord('P'));
AddToHotKeys('A', ord('A'));
AddToHotKeys('S', ord('S'));
AddToHotKeys('D', ord('D'));
AddToHotKeys('F', ord('F'));
AddToHotKeys('G', ord('G'));
AddToHotKeys('H', ord('H'));
AddToHotKeys('J', ord('J'));
AddToHotKeys('K', ord('K'));
AddToHotKeys('L', ord('L'));
AddToHotKeys('Z', ord('Z'));
AddToHotKeys('X', ord('X'));
AddToHotKeys('C', ord('C'));
AddToHotKeys('V', ord('V'));
AddToHotKeys('B', ord('B'));
AddToHotKeys('N', ord('N'));
AddToHotKeys('M', ord('M'));

AddToHotKeys('NumPad 0', vk_NumPad0);
AddToHotKeys('NumPad 1', vk_NumPad1);
AddToHotKeys('NumPad 2', vk_NumPad2);
AddToHotKeys('NumPad 3', vk_NumPad3);
AddToHotKeys('NumPad 4', vk_NumPad4);
AddToHotKeys('NumPad 5', vk_NumPad5);
AddToHotKeys('NumPad 6', vk_NumPad6);
AddToHotKeys('NumPad 7', vk_NumPad7);
AddToHotKeys('NumPad 8', vk_NumPad8);
AddToHotKeys('NumPad 9', vk_NumPad9);

AddToHotKeys('0', ord('0'));
AddToHotKeys('1', ord('1'));
AddToHotKeys('2', ord('2'));
AddToHotKeys('3', ord('3'));
AddToHotKeys('4', ord('4'));
AddToHotKeys('5', ord('5'));
AddToHotKeys('6', ord('6'));
AddToHotKeys('7', ord('7'));
AddToHotKeys('8', ord('8'));
AddToHotKeys('9', ord('9'));

end.
