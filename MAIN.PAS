Program PlanLekcji;
uses
  App, Objects, Drivers, Views, Dialogs, Menus,
  Stale, Resource,
  DataObjects, DataDialogs, DataBase, Help, ClockViewer,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja,
  HostWin, MainWin, SpecWins, Archiwizacja;

type { typ opisujcy gˆ¢wn aplikacj© }
  PMainApp = ^TMainApp;
  TMainApp = object (TApplication)
    MainEditWindow: PMainEditWindow;
    ClockViewer: PClockViewer;
    constructor Init;
    destructor Done; virtual;
    procedure Idle; virtual;
    procedure InitStatusLine; virtual;
    procedure InitMenuBar; virtual;
    procedure GetEvent(var Event: TEvent); virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure ShowAboutBox; virtual;
  end;

constructor TMainApp.Init;
var
  L: PLekcja;
  R: TRect;
begin
  OpenResources('PLAN.RES');
  OpenFiles('DATA');
  inherited Init;
  R.Assign(Size.X-9, 0, Size.X, 1);
  New(ClockViewer, Init(R));
  Insert(ClockViewer);
  MainEditWindow:=PMainEditWindow(ResourceFile.Get('MainEditWindow'));
  if LoadSuccessful(MainEditWindow) then
  begin
    MainEditWindow^.UpdateLists;
    InsertWindow(MainEditWindow);
  end;
  Message(@Self, evCommand, cmAboutBox, nil);
end;

destructor TMainApp.Done;
begin
  CloseFiles;
  CloseResources;
  inherited Done;
end;

procedure TMainApp.Idle;
begin
  inherited Idle;
  if Assigned(ClockViewer) then ClockViewer^.Draw;
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

procedure TMainApp.GetEvent;
var
  W: PWindow;
  S: String;
begin
  inherited GetEvent(Event);
  case Event.What of
    evCommand, evBroadcast:
    begin
      if (Event.Command = cmHelp) and (not HelpInUse) then
      begin
        ShowHelp(GetHelpCtx);
        ClearEvent(Event);
      end;
    end;
    evMouseDown: if Event.Buttons<>1 then Event.What := evNothing;
  end;
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
      cmArchiwizacja: Archiwizuj;
      cmOdzysk: Odtworz;
      cmNauczycielAdd: NauczycielAdd;
      cmNauczycielDel: NauczycielDel;
      cmNauczycielEdit: NauczycielEdit;
      cmNauczycielDelAll: NauczycielDelAll;
      cmPrzedmiotAdd: PrzedmiotAdd;
      cmPrzedmiotDel: PrzedmiotDel;
      cmPrzedmiotEdit: PrzedmiotEdit;
      cmPrzedmiotDelAll: PrzedmiotDelAll;
      cmSalaAdd: SalaAdd;
      cmSalaDel: SalaDel;
      cmSalaEdit: SalaEdit;
      cmSalaDelAll: SalaDelAll;
      cmKlasaAdd: KlasaAdd;
      cmKlasaDel: KlasaDel;
      cmKlasaEdit: KlasaEdit;
      cmKlasaDelAll: KlasaDelAll;
      cmDzwonekAdd: DzwonekAdd;
      cmDzwonekDel: DzwonekDel;
      cmDzwonekEdit: DzwonekEdit;
      cmDzwonekDelAll: DzwonekDelAll;
      cmLekcjaAdd:
      begin
        HostWindow:=Message(Desktop, evBroadcast, cmFindEditorWindow, nil);
        if Assigned(HostWindow) then with HostWindow^ do LekcjaAdd(GetCurrentDzien, GetCurrentDzwonekIndex);
        ClearEvent(Event);
      end;
      cmLekcjaDel:
      begin
        HostWindow:=Message(Desktop, evBroadcast, cmFindEditorWindow, nil);
        if Assigned(HostWindow) then with HostWindow^ do LekcjaDel(GetCurrentDzien, GetCurrentLekcja);
        ClearEvent(Event);
      end;
      cmLekcjaEdit:
      begin
        HostWindow:=Message(Desktop, evBroadcast, cmFindEditorWindow, nil);
        if Assigned(HostWindow) then with HostWindow^ do LekcjaEdit(GetCurrentDzien, GetCurrentDzwonekIndex, GetCurrentLekcja);
        ClearEvent(Event);
      end;
      cmLekcjaDelAll: LekcjaDelAll;
      cmPlanNauczyciela: RunPlanLekcjiNauczyciela;
      cmPlanKlasy: RunPlanLekcjiKlasy;
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
