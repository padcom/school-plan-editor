Program PlanLekcji;
uses
  App, Objects, Drivers, Views, Dialogs, Menus,
  Stale, Resource,
  DataObjects, DataDialogs, DataBase, Help,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja,
  HostWin, MainWin, SpecWins;


type { typ opisujcy gˆ¢wn aplikacj© }
  PMainApp = ^TMainApp;
  TMainApp = object (TApplication)
    MainWindow: PMainWindow;
    constructor Init;
    destructor Done; virtual;
    procedure InitStatusLine; virtual;
    procedure InitMenuBar; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure ShowAboutBox; virtual;
  end;

constructor TMainApp.Init;
var
  L: PLekcja;
begin
  OpenResources('PLAN.RES');
  OpenFiles('DATA');
  inherited Init;
  MainWindow:=PMainWindow(ResourceFile.Get('MainWindow'));
  if LoadSuccessful(MainWindow) then
  begin
    MainWindow^.SetDzwonekList(Dzwonki);
    InsertWindow(MainWindow);
  end;
  Message(@Self, evCommand, cmAboutBox, nil);
end;

destructor TMainApp.Done;
begin
  CloseFiles;
  CloseResources;
  inherited Done;
end;

procedure TMainApp.InitStatusLine;
begin
  StatusLine:=PHintStatusLine(ResourceFile.Get('StatusLine'));
end;

procedure TMainApp.InitMenuBar;
var
  R: TRect;
begin
  MenuBar:=PMenuBar(ResourceFile.Get('MenuBar'));
end;

procedure TMainApp.ShowAboutBox;
var
  D: PDialog;
begin
  D:=PDialog(ResourceFile.Get('AboutBox'));
  if Assigned(D) then ExecuteDialog(D, nil);
end;

procedure TMainApp.HandleEvent;
var
  HostWindow: PHostEditWindow;
begin
  inherited HandleEvent(Event);
  if Event.What=evCommand then
  begin
    case Event.Command of
      cmAboutBox: ShowAboutBox;
      cmNauczycielAdd: NauczycielAdd;
      cmNauczycielDel: NauczycielDel;
      cmNauczycielEdit: NauczycielEdit;
      cmPrzedmiotAdd: PrzedmiotAdd;
      cmPrzedmiotDel: PrzedmiotDel;
      cmPrzedmiotEdit: PrzedmiotEdit;
      cmSalaAdd: SalaAdd;
      cmSalaDel: SalaDel;
      cmSalaEdit: SalaEdit;
      cmKlasaAdd: KlasaAdd;
      cmKlasaDel: KlasaDel;
      cmKlasaEdit: KlasaEdit;
      cmDzwonekAdd: DzwonekAdd;
      cmDzwonekDel: DzwonekDel;
      cmDzwonekEdit: DzwonekEdit;
      cmLekcjaAdd:
      begin
        HostWindow:=Message(Desktop, evBroadcast, cmFindEditorWindow, nil);
        if Assigned(HostWindow) then with HostWindow^ do
          LekcjaAdd(GetCurrentDzien, GetDzwonekIndex);
        ClearEvent(Event);
      end;
      cmLekcjaDel:
      begin
        HostWindow:=Message(Desktop, evBroadcast, cmFindEditorWindow, nil);
        if Assigned(HostWindow) then with HostWindow^ do
          LekcjaDel(GetCurrentDzien, GetCurrentLekcja);
        ClearEvent(Event);
      end;
      cmLekcjaEdit:
      begin
        HostWindow:=Message(Desktop, evBroadcast, cmFindEditorWindow, nil);
        if Assigned(HostWindow) then with HostWindow^ do
          LekcjaEdit(GetCurrentDzien, GetDzwonekIndex, GetCurrentLekcja);
        ClearEvent(Event);
      end;
      cmPlanNauczyciela: RunPlanLekcjiNauczyciela;
    end;
  end;
end;

var
  Main: TMainApp;
  N: PNauczyciel;

begin
  Main.Init;
  Main.Run;
  Main.Done;
end.
