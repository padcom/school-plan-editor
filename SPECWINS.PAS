Unit SpecWins;

interface
uses
  App, Objects, Drivers, Views, Dialogs, Menus,
  DataObjects, DataDialogs, Stale, Help,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja;

type { typ opisuj¥cy pod˜wietlany label }
  PHighlightedLabel = ^THighlightedLabel;
  THighlightedLabel = object (TLabel)

  end;

type { typ opisuj¥cy widok listy lekcji dla poszczeg¢lnego dnia }
  PLekcjaListView = ^TLekcjaListView;
  TLekcjaListView = object (TListBox)

  end;

type { typ opisuj¥cy widok informacji szczeg¢ˆowych lekcji }
  PLekcjaDetailView = ^TLekcjaDetailView;
  TLekcjaDetailView = object (TView)

  end;

type { typ opisuj¥cy widok ramek w ˜rodku okna edycji planu lekcji }
  PInsideFrames = ^TInsideFrames;
  TInsideFrames = object (TView)

  end;

type { typ opisuj¥cy okno edycji planu zaj©† dla danego elementu }
  PPlanLekcjiWindow = ^TPlanLekcjiWindow;
  TPlanLekcjiWindow = object (TDialog)

  end;

type { typ opisuj¥cy okno edycji planu lekcji nauczyciela }
  PPlanLekcjiNauczycielWindow = ^TPlanLekcjiNauczycielWindow;
  TPlanLekcjiNauczycielWindow = object (TPlanLekcjiWindow)

  end;

type { typ opisuj¥cy okno edycji planu lekcji grupy klasy }
  PPlanLekcjiKlasaWindow = ^TPlanLekcjiKlasaWindow;
  TPlanLekcjiKlasaWindow = object (TPlanLekcjiWindow)

  end;

type { typ opisuj¥cy okno edycji planu lekcji sali }
  PPlanLekcjiSalaWindow = ^TPlanLekcjiSalaWindow;
  TPlanLekcjiSalaWindow = object (TPlanLekcjiWindow)

  end;

const
  RHighlightedLabel: TStreamRec = (
    ObjType: $A000;
    VmtLink: Ofs(TypeOf(THighlightedLabel)^);
    Load   : @THighlightedLabel.Load;
    Store  : @THighlightedLabel.Store);
  RLekcjaListView: TStreamRec = (
    ObjType: $A001;
    VmtLink: Ofs(TypeOf(TLekcjaListView)^);
    Load   : @TLekcjaListView.Load;
    Store  : @TLekcjaListView.Store);
  RLekcjaDetailView: TStreamRec = (
    ObjType: $A002;
    VmtLink: Ofs(TypeOf(TLekcjaDetailView)^);
    Load   : @TLekcjaDetailView.Load;
    Store  : @TLekcjaDetailView.Store);
  RInsideFrames: TStreamRec = (
    ObjType: $A003;
    VmtLink: Ofs(TypeOf(TInsideFrames)^);
    Load   : @TInsideFrames.Load;
    Store  : @TInsideFrames.Store);
  RPlanLekcjiWindow: TStreamRec = (
    ObjType: $A004;
    VmtLink: Ofs(TypeOf(TPlanLekcjiWindow)^);
    Load   : @TPlanLekcjiWindow.Load;
    Store  : @TPlanLekcjiWindow.Store);
  RPlanLekcjiNauczycielWindow: TStreamRec = (
    ObjType: $A005;
    VmtLink: Ofs(TypeOf(TPlanLekcjiNauczycielWindow)^);
    Load   : @TPlanLekcjiNauczycielWindow.Load;
    Store  : @TPlanLekcjiNauczycielWindow.Store);
  RPlanLekcjiKlasaWindow: TStreamRec = (
    ObjType: $A006;
    VmtLink: Ofs(TypeOf(TPlanLekcjiKlasaWindow)^);
    Load   : @TPlanLekcjiKlasaWindow.Load;
    Store  : @TPlanLekcjiKlasaWindow.Store);
  RPlanLekcjiSalaWindow: TStreamRec = (
    ObjType: $A007;
    VmtLink: Ofs(TypeOf(TPlanLekcjiSalaWindow)^);
    Load   : @TPlanLekcjiSalaWindow.Load;
    Store  : @TPlanLekcjiSalaWindow.Store);

procedure RegisterSpecWins;

implementation

procedure RegisterSpecWins;
begin
  RegisterType(RHighlightedLabel);
  RegisterType(RLekcjaListView);
  RegisterType(RLekcjaDetailView);
  RegisterType(RInsideFrames);
  RegisterType(RPlanLekcjiWindow);
  RegisterType(RPlanLekcjiNauczycielWindow);
  RegisterType(RPlanLekcjiKlasaWindow);
  RegisterType(RPlanLekcjiSalaWindow);
end;

begin
end.

