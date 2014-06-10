unit uSynEditPopupEdit;

interface

uses
  System.Classes,
  Vcl.ActnList,
  Vcl.Menus,
  SynEdit;

type
  TSynEdit = class(SynEdit.TSynEdit)
  private
    FActnList : TActionList;
    FPopupMenu: TPopupMenu;
    procedure CreateActns;
    procedure FillPopupMenu(APopupMenu: TPopupMenu);
    procedure CutExecute(Sender: TObject);
    procedure CutUpdate(Sender: TObject);
    procedure CopyExecute(Sender: TObject);
    procedure CopyUpdate(Sender: TObject);
    procedure PasteExecute(Sender: TObject);
    procedure PasteUpdate(Sender: TObject);
    procedure DeleteExecute(Sender: TObject);
    procedure DeleteUpdate(Sender: TObject);
    procedure SelectAllExecute(Sender: TObject);
    procedure SelectAllUpdate(Sender: TObject);
    procedure RedoExecute(Sender: TObject);
    procedure RedoUpdate(Sender: TObject);
    procedure UndoExecute(Sender: TObject);
    procedure UndoUpdate(Sender: TObject);
    procedure SetPopupMenu_(const Value: TPopupMenu);
    function GetPopupMenu_: TPopupMenu;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property PopupMenu: TPopupMenu
      read   GetPopupMenu_
      write  SetPopupMenu_;
  end;

implementation

uses
  SysUtils;

const
  MenuName = 'uSynEditPopupMenu';

procedure TSynEdit.CopyExecute(Sender: TObject);
begin
  Self.CopyToClipboard;
end;

procedure TSynEdit.CopyUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Self.SelAvail;
end;

procedure TSynEdit.CutExecute(Sender: TObject);
begin
  Self.CutToClipboard;
end;

procedure TSynEdit.CutUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Self.SelAvail and not Self.ReadOnly;
end;

procedure TSynEdit.DeleteExecute(Sender: TObject);
begin
  Self.SelText := '';
end;

procedure TSynEdit.DeleteUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Self.SelAvail and not Self.ReadOnly;
end;

procedure TSynEdit.PasteExecute(Sender: TObject);
begin
  Self.PasteFromClipboard;
end;

procedure TSynEdit.PasteUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Self.CanPaste;
end;

procedure TSynEdit.RedoExecute(Sender: TObject);
begin
  Self.Redo;
end;

procedure TSynEdit.RedoUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Self.CanRedo;
end;

procedure TSynEdit.SelectAllExecute(Sender: TObject);
begin
  Self.SelectAll;
end;

procedure TSynEdit.SelectAllUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Self.Lines.Text <> '';
end;

procedure TSynEdit.UndoExecute(Sender: TObject);
begin
  Self.Undo;
end;

procedure TSynEdit.UndoUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Self.CanUndo;
end;

constructor TSynEdit.Create(AOwner: TComponent);
begin
  inherited;
  FActnList       := TActionList.Create(Self);
  FPopupMenu      := TPopupMenu.Create(Self);
  FPopupMenu.Name := MenuName;
  CreateActns;
  FillPopupMenu(FPopupMenu);
  PopupMenu := FPopupMenu;
end;

procedure TSynEdit.CreateActns;

  procedure AddActItem(const AText: string; AShortCut: TShortCut; AEnabled: Boolean; OnExecute, OnUpdate: TNotifyEvent);
  var
    ActionItem: TAction;
  begin
    ActionItem            := TAction.Create(FActnList);
    ActionItem.ActionList := FActnList;
    ActionItem.Caption    := AText;
    ActionItem.ShortCut   := AShortCut;
    ActionItem.Enabled    := AEnabled;
    ActionItem.OnExecute  := OnExecute;
    ActionItem.OnUpdate   := OnUpdate;
  end;

begin
  AddActItem('&Undo', Vcl.Menus.ShortCut(Word('Z'), [ssCtrl]), False, UndoExecute, UndoUpdate);
  AddActItem('&Redo', Vcl.Menus.ShortCut(Word('Z'), [ssCtrl, ssShift]), False, RedoExecute, RedoUpdate);
  AddActItem('-', 0, False, nil, nil);
  AddActItem('Cu&t', Vcl.Menus.ShortCut(Word('X'), [ssCtrl]), False, CutExecute, CutUpdate);
  AddActItem('&Copy', Vcl.Menus.ShortCut(Word('C'), [ssCtrl]), False, CopyExecute, CopyUpdate);
  AddActItem('&Paste', Vcl.Menus.ShortCut(Word('V'), [ssCtrl]), False, PasteExecute, PasteUpdate);
  AddActItem('De&lete', 0, False, DeleteExecute, DeleteUpdate);
  AddActItem('-', 0, False, nil, nil);
  AddActItem('Select &All', Vcl.Menus.ShortCut(Word('A'), [ssCtrl]), False, SelectAllExecute, SelectAllUpdate);
end;

procedure TSynEdit.SetPopupMenu_(const Value: TPopupMenu);
var
  MenuItem: TMenuItem;
begin
  SynEdit.TSynEdit(Self).PopupMenu := Value;
  if CompareText(MenuName, Value.Name) <> 0 then
  begin
    MenuItem         := TMenuItem.Create(Value);
    MenuItem.Caption := '-';
    Value.Items.Add(MenuItem);
    FillPopupMenu(Value);
  end;
end;

function TSynEdit.GetPopupMenu_: TPopupMenu;
begin
  Result := SynEdit.TSynEdit(Self).PopupMenu;
end;

destructor TSynEdit.Destroy;
begin
  FPopupMenu.Free;
  FActnList.Free;
  inherited;
end;

procedure TSynEdit.FillPopupMenu(APopupMenu: TPopupMenu);
var
  i       : integer;
  MenuItem: TMenuItem;
begin
  if Assigned(FActnList) then
    for i := 0 to FActnList.ActionCount - 1 do
    begin
      MenuItem        := TMenuItem.Create(APopupMenu);
      MenuItem.Action := FActnList.Actions[i];
      APopupMenu.Items.Add(MenuItem);
    end;
end;

end.
