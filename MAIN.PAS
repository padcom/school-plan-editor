Program PlanLekcji;
uses
  App, Objects, Drivers, Views, Dialogs, Menus,
  Stale, Resource,
  DataObjects, DataDialogs, DataBase,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja;

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
begin
  OpenResources('PLAN.RES');
  inherited Init;
end;

destructor TMainApp.Done;
begin
  CloseResources;
  inherited Done;
end;

procedure TMainApp.InitStatusLine;
begin
  StatusLine:=PStatusLine(ResourceFile.Get('StatusLine'));
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
  New(Dzwonki, Init(10, 5));
  New(Klasy, Init(10, 5));
  New(Sale, Init(10, 5));
  New(Przedmioty, Init(10, 5));
  New(Nauczyciele, Init(10, 5));
  New(N, Init); N^.ImieNazwisko:=NewStr('Maciej Hryniszak'); N^.Skrot:=NewStr('MACIE');
  N^.Index:=Nauczyciele^.GetFirstFreeIndex;
  Nauczyciele^.Insert(N);
  New(N, Init); N^.ImieNazwisko:=NewStr('Marzena Hanarz'); N^.Skrot:=NewStr('MARZE');
  N^.Index:=Nauczyciele^.GetFirstFreeIndex;
  Nauczyciele^.Insert(N);

  Main.Init;
  Main.Run;
  Main.Done;
end.
