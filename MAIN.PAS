Program PlanLekcji;
uses
  App, Objects, Drivers, Views, Dialogs, Menus,
  Stale, Resource,
  DataObjects, DataDialogs, DataBase, Help,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja,
  MainWin;

type { typ opisujcy gˆ¢wn aplikacj© }
  PMainApp = ^TMainApp;
  TMainApp = object (TApplication)
    constructor Init;
    destructor Done; virtual;
    procedure InitStatusLine; virtual;
    procedure InitMenuBar; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;

    procedure ShowAboutBox; virtual;
  end;

constructor TMainApp.Init;
var
  D: PMainWindow;
begin
  OpenResources('PLAN.RES');
  OpenFiles('DATA');
  inherited Init;
  D:=PMainWindow(ResourceFile.Get('MainWindow'));
  if LoadSuccessful(D) then InsertWindow(D);
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
