Unit DataDialogs;

interface
uses
  Objects, Drivers, Views, Dialogs,
  DataObjects, Stale;

type { typ opisuj¥cy bazowe okienko edycji danych }
  PDataDialog = ^TDataDialog;
  TDataDialog = object (TDialog)
    OkButton: PButton;
    CancelButton: PButton;
    HelpButton: PButton;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SetTitle(ATitle: TTitleStr); virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj¥cy ListBox danych }
  PDataListBox = ^TDataListBox;
  TDataListBox = object (TListBox)
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
  end;

const
  RDataDialog: TStreamRec = (
    ObjType: $1100;
    VmtLink: Ofs(TypeOf(TDataDialog)^);
    Load   : @TDataDialog.Load;
    Store  : @TDataDialog.Store);
  RDataListBox: TStreamRec = (
    ObjType: $1110;
    VmtLink: Ofs(TypeOf(TDataListBox)^);
    Load   : @TDataListBox.Load;
    Store  : @TDataListBox.Store);

procedure RegisterDataDialogs;

implementation

{ TDataDialog }

constructor TDataDialog.Load;
begin
  inherited Load(S);
  GetSubViewPtr(S, OkButton);
  GetSubViewPtr(S, CancelButton);
  GetSubViewPtr(S, HelpButton);
end;

procedure TDataDialog.HandleEvent;
begin
  if Event.What=evKeyboard then
  begin
    case Event.KeyCode of
      kbEnter: if (Current<>PView(OkButton)) and (Current<>PView(CancelButton)) and (Current<>PView(OkButton)) then
      begin
        SelectNext(False);
        ClearEvent(Event);
      end;
      kbUp: SelectNext(True);
      kbDown: SelectNext(False);
    end;
  end;
  inherited HandleEvent(Event);
end;

procedure TDataDialog.SetTitle;
begin
  if Assigned(Title) then DisposeStr(Title);
  Title:=Nil;
  Title:=NewStr(ATitle);
end;

procedure TDataDialog.Store;
begin
  inherited Store(S);
  PutSubViewPtr(S, OkButton);
  PutSubViewPtr(S, CancelButton);
  PutSubViewPtr(S, HelpButton);
end;

{ TDataListBox }

function TDataListBox.GetText;
begin
  GetText:=PDataObject(List^.At(Item))^.GetText(MaxLen);
end;

{ *** }

procedure RegisterDataDialogs;
begin
  RegisterType(RDataDialog);
  RegisterType(RDataListBox);
end;

begin
end.
