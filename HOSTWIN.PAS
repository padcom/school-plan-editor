Unit HostWin;

interface
uses
  App, Objects, Drivers, Views, Dialogs,
  DataObjects, DataDialogs, Stale,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja;

type { typ opisuj¥cy nadrz©dne ze wzgl©du na dziedziczenie okno edycji planu zaj©† }
  PHostEditWindow = ^THostEditWindow;
  THostEditWindow = object (TDialog)
    function GetCurrentLekcja: PLekcja; virtual;
    function GetCurrentDzien: Integer; virtual;
    function GetDzwonekIndex: Integer; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

const
  RHostEditWindow: TStreamRec = (
    ObjType: $B000;
    VmtLink: Ofs(TypeOf(THostEditWindow)^);
    Load   : @THostEditWindow.Load;
    Store  : @THostEditWindow.Store);

procedure RegisterHostWin;

implementation

{ THostEditWindow }

function THostEditWindow.GetCurrentLekcja;
begin
  Abstract;
end;

function THostEditWindow.GetCurrentDzien;
begin
  Abstract;
end;

function THostEditWindow.GetDzwonekIndex;
begin
  Abstract;
end;

procedure THostEditWindow.HandleEvent;
begin
  if Event.What=evBroadcast then
  begin
    case Event.Command of
      cmFindEditorWindow: ClearEvent(Event);
    end;
  end;
  inherited HandleEvent(Event);
end;

{ *** }

procedure RegisterHostWin;
begin
  RegisterType(RHostEditWindow);
end;

begin
end.
