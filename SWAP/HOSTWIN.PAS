Unit HostWin;

interface
uses
  App, Objects, Drivers, Views, Dialogs,
  DataObjects, DataDialogs, Stale,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja;

type { typ opisuj¥cy pod˜wietlany Label }
  PHighlightedLabel = ^THighlightedLabel;
  THighlightedLabel = object (TLabel)
    function GetPalette: PPalette; virtual;
  end;

type { typ opisuj¥cy widok listy dzwonk¢w }
  PDzwonekListView = ^TDzwonekListView;
  TDzwonekListView = object (TDataListBox)
    function GetPalette: PPalette; virtual;
    procedure FocusItem(Item: Integer); virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

type { typ opisuj¥cy nadrz©dne ze wzgl©du na dziedziczenie okno edycji planu zaj©† }
  PHostEditWindow = ^THostEditWindow;
  THostEditWindow = object (TDialog)
    function GetCurrentLekcja: PLekcja; virtual;
    function GetCurrentDzien: Integer; virtual;
    function GetDzwonekIndex: Integer; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;


procedure RegisterHostWin;

implementation

{ THighlightedLabel }

function THighlightedLabel.GetPalette;
const
  S: String = CLabel;
begin
  S[1]:=#2; S[2]:=#5;
  GetPalette:=@S;
end;

{ TDzwonekListView }

function TDzwonekListView.GetPalette;
const
  S: String = CListViewer;
begin
  S[1]:=#2; S[3]:=#4;
  S[2]:=#2; S[4]:=#4;
  GetPalette:=@S;
end;

procedure TDzwonekListView.FocusItem;
begin
  inherited FocusItem(Item);
  Message(Owner, evBroadcast, cmRedrawLekcjaListView, nil);
end;

procedure TDzwonekListView.HandleEvent;
var
  L: PCollection;
  Item: PObject;
  I: Integer;
begin
  if (Event.What=evBroadcast) and (Event.Command=cmUpdateLists) then
  begin
    I:=Focused;
    if I>=List^.Count then Dec(I);
    L:=List;
    List:=nil;
    NewList(L);
    if Assigned(List) and (List^.Count>0) then
    begin
      FocusItem(I);
      DrawView;
    end;
  end;
  inherited HandleEvent(Event);
end;

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
  inherited HandleEvent(Event);
end;

{ *** }

procedure RegisterHostWin;
begin
end;

begin
end.
