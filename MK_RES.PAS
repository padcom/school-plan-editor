Program MakeResources;
uses
  App, Objects, Drivers, Views, Dialogs, Menus,
  DataObjects, DataDialogs, Resource, Stale,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja;

{ *** procedury tworz¥ce poszczeg¢lne elementy aplikacji *** }

procedure CreateStatusLine;
var
  R: TRect;
begin
  BeginCreating('StatusLine');

  R.Assign(0, 24, 80, 25);
  StatusLine:=New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~Alt+X~ Koniec', kbAltX, cmQuit,
      NewStatusKey('~F1~ Pomoc', kbF1, cmHelp,
      NewStatusKey('~Ins~ Nowa', kbIns, cmLekcjaAdd,
      NewStatusKey('~Del~ Usuä', kbDel, cmLekcjaDel,
      NewStatusKey('~Ctrl+Enter~ Popraw', kbCtrlEnter, cmLekcjaEdit,
      NewStatusKey('~F10~ Menu', kbF10, cmMenu,
      NewStatusKey('', kbF2, cmAboutBox,
    nil))))))),
  nil)));

  StoreObject(StatusLine);
end;

procedure CreateMenuBar;
var
  R: TRect;
begin
  BeginCreating('MenuBar');
  R.Assign(0, 0, 80, 1);
  MenuBar:=New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~S~ˆowniki', hcSlownikiMenu, NewMenu(
      NewSubMenu('~N~auczyciele', hcNauczycieleMenu, NewMenu(
        NewItem('~N~owy', 'F5', kbF5, cmNauczycielAdd, hcNauczycielAdd,
        NewItem('~P~opraw', 'Shift+F5', kbShiftF5, cmNauczycielEdit, hcNauczycielEdit,
        NewItem('~U~suä', 'Ctrl+F5', KbCtrlF5, cmNauczycielDel, hcNauczycielDel,
      nil)))),
      NewSubMenu('~P~rzedmioty', hcPrzedmiotyMenu, NewMenu(
        NewItem('~N~owy', 'F6', kbF6, cmPrzedmiotAdd, hcPrzedmiotAdd,
        NewItem('~P~opraw', 'Shift+F6', kbShiftF6, cmPrzedmiotEdit, hcPrzedmiotEdit,
        NewItem('~U~suä', 'Ctrl+F6', KbCtrlF6, cmPrzedmiotDel, hcPrzedmiotDel,
      nil)))),
      NewSubMenu('~K~lasy', hcKlasyMenu, NewMenu(
        NewItem('~N~owa', 'F7', kbF7, cmKlasaAdd, hcKlasaAdd,
        NewItem('~P~opraw', 'Shift+F7', kbShiftF7, cmKlasaEdit, hcKlasaEdit,
        NewItem('~U~suä', 'Ctrl+F7', KbCtrlF7, cmKlasaDel, hcKlasaDel,
      nil)))),
      NewSubMenu('~S~ale', hcSaleMenu, NewMenu(
        NewItem('~N~owa', 'F8', kbF8, cmSalaAdd, hcSalaAdd,
        NewItem('~P~opraw', 'Shift+F8', kbShiftF8, cmSalaEdit, hcSalaEdit,
        NewItem('~U~suä', 'Ctrl+F8', KbCtrlF8, cmSalaDel, hcSalaDel,
      nil)))),
      NewLine(
      NewSubMenu('~D~zwonki', hcDzwonkiMenu, NewMenu(
        NewItem('~N~owy', 'F9', kbF9, cmDzwonekAdd, hcDzwonekAdd,
        NewItem('~P~opraw', 'Shift+F9', kbShiftF9, cmDzwonekEdit, hcDzwonekEdit,
        NewItem('~U~suä', 'Ctrl+F9', KbCtrlF9, cmDzwonekDel, hcDzwonekDel,
      nil)))),
    nil))))))),
  nil))));
  StoreObject(MenuBar);
  Dispose(MenuBar); MenuBar:=nil;
end;

procedure CreateAboutBox;
var
  R: TRect;
  D: PDialog;
begin
  BeginCreating('AboutBox');

  R.Assign(0, 0, 50, 10);
  D:=New(PDialog, Init(R, 'O programie ...'));
  with D^ do
  begin
    Options:=Options or ofCentered;

    R.Assign(1, 2, Size.X-1, 3);
    Insert(New(PStaticText, Init(R, #3'Program "Plan Lekcji" wersja 1.3')));

    R.Assign(1, 4, Size.X-1, 5);
    Insert(New(PStaticText, Init(R, #3'Autor: Maciej Hryniszak')));

    R.Assign(17, 7, 32, 9);
    Insert(New(PButton, Init(R, '~D~alej', cmOK, bfDefault)));
  end;

  StoreObject(D);
  TestDialog(D);
end;

procedure InsertStandardButtons(D: PDataDialog);
var
  R: TRect;
begin
  with D^ do
  begin
    R.Assign(2, Size.Y-3, 14, Size.Y-1);
    New(OkButton, Init(R, '~O~k', cmOK, bfDefault));
    Insert(OkButton);

    R.Assign(15, Size.Y-3, 27, Size.Y-1);
    New(CancelButton, Init(R, '~A~nuluj', cmCancel, bfNormal));
    Insert(CancelButton);

    R.Assign(Size.X-13, Size.Y-3, Size.X-2, Size.Y-1);
    New(HelpButton, Init(R, '~P~omoc', cmHelp, bfBroadcast));
    Insert(HelpButton);
  end;
end;

procedure CreateNauczycielDialog;
var
  R: TRect;
  D: PDialog;
begin
  BeginCreating('NauczycielEditDialog');

  R.Assign(0, 0, 50, 11);
  D:=New(PNauczycielDialog, Init(R, ''));
  with PNauczycielDialog(D)^ do
  begin
    Options:=Options or ofCentered;

    { standardowe przyciski }
    InsertStandardButtons(PDataDialog(D));

    { linia wprowadzania imienia i nazwiska nauczyciela }
    R.Assign(3, 3, Size.X-3, 4);
    New(ImieNazwiskoInputLine, Init(R, 255));
    Insert(ImieNazwiskoInputLine);
    R.Assign(2, 2, Size.X-3, 3);
    New(ImieNazwiskoLabel, Init(R, '~I~mi©, nazwisko', ImieNazwiskoInputLine));
    Insert(ImieNazwiskoLabel);

    { linia wprowadzania skr¢tu nauczyciela }
    R.Assign(3, 5, 10, 6);
    New(SkrotInputLine, Init(R, 5));
    Insert(SkrotInputLine);
    R.Assign(2, 4, Size.X-3, 5);
    New(SkrotLabel, Init(R, '~S~krot', SkrotInputLine));
    Insert(SkrotLabel);

    ImieNazwiskoInputLine^.Select;
  end;

  StoreObject(D);
  PDataDialog(D)^.SetTitle('Okno edycji nauczyciela');
  TestDialog(D);
end;

procedure CreatePrzedmiotDialog;
var
  R: TRect;
  D: PDialog;
begin
  BeginCreating('PrzedmiotEditDialog');

  R.Assign(0, 0, 50, 11);
  D:=New(PPrzedmiotDialog, Init(R, ''));
  with PPrzedmiotDialog(D)^ do
  begin
    Options:=Options or ofCentered;

    { standardowe przyciski }
    InsertStandardButtons(PDataDialog(D));

    { linia wprowadzania imienia i nazwiska nauczyciela }
    R.Assign(3, 3, Size.X-3, 4);
    New(NazwaInputLine, Init(R, 255));
    Insert(NazwaInputLine);
    R.Assign(2, 2, Size.X-3, 3);
    New(NazwaLabel, Init(R, '~N~azwa przedmiotu', NazwaInputLine));
    Insert(NazwaLabel);

    { linia wprowadzania skr¢tu przedmiotu }
    R.Assign(3, 5, 10, 6);
    New(SkrotInputLine, Init(R, 5));
    Insert(SkrotInputLine);
    R.Assign(2, 4, Size.X-3, 5);
    New(SkrotLabel, Init(R, '~S~krot', SkrotInputLine));
    Insert(SkrotLabel);

    NazwaInputLine^.Select;
  end;

  StoreObject(D);
  PDataDialog(D)^.SetTitle('Okno edycji przedmiotu');
  TestDialog(D);
end;

procedure CreateSalaDialog;
var
  R: TRect;
  D: PDialog;
begin
  BeginCreating('SalaEditDialog');

  R.Assign(0, 0, 50, 11);
  D:=New(PSalaDialog, Init(R, ''));
  with PSalaDialog(D)^ do
  begin
    Options:=Options or ofCentered;

    { standardowe przyciski }
    InsertStandardButtons(PDataDialog(D));

    { linia wprowadzania numeru sali }
    R.Assign(3, 3, 10, 4);
    New(NumerInputLine, Init(R, 5));
    Insert(NumerInputLine);
    R.Assign(2, 2, Size.X-3, 3);
    New(NumerLabel, Init(R, '~N~umer', NumerInputLine));
    Insert(NumerLabel);

    { linia wprowadzania nazwy pracowni, kt¢r¥ jest edytowana sala }
    R.Assign(3, 5, Size.X-3, 6);
    New(NazwaInputLine, Init(R, 255));
    Insert(NazwaInputLine);
    R.Assign(2, 4, Size.X-3, 5);
    New(NazwaLabel, Init(R, '~N~azwa pracowni', NazwaInputLine));
    Insert(NazwaLabel);

    NumerInputLine^.Select;
  end;

  StoreObject(D);
  PDataDialog(D)^.SetTitle('Okno edycji sali');
  TestDialog(D);
end;

begin
  CreateResources('PLAN.RES');
  CreateStatusLine;
  CreateMenuBar;
  CreateAboutBox;
  CreateNauczycielDialog;
  CreatePrzedmiotDialog;
  CreateSalaDialog;
  DumpNames;
  CloseResources;
end.
