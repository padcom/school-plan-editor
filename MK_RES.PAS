Program MakeResources;
uses
  App, Objects, Drivers, Views, Dialogs, Menus,
  DataObjects, DataDialogs, Resource, Stale,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja,
  Help, DataBase, MainWin{, SpecWins};

{ *** procedury tworz¥ce poszczeg¢lne elementy aplikacji *** }

procedure CreateStatusLine;
var
  R: TRect;
begin
  BeginCreating('StatusLine');

  R.Assign(0, 24, 80, 25);
  StatusLine:=New(PHintStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~Alt+X~ Koniec', kbAltX, cmQuit,
      NewStatusKey('~F1~ Pomoc', kbF1, cmHelp,
      NewStatusKey('~Ins~ Nowa', kbIns, cmLekcjaAdd,
      NewStatusKey('~Del~ Usuä', kbDel, cmLekcjaDel,
      NewStatusKey('~Ctrl+Enter~ Popraw', kbCtrlEnter, cmLekcjaEdit,
      NewStatusKey('~F10~ Menu', kbF10, cmMenu,
      NewStatusKey('', kbAltF3, cmClose,
      NewStatusKey('', kbCtrlF6, cmNext,
      NewStatusKey('', kbCtrlF1, cmAboutBox,
    nil))))))))),
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
    NewSubMenu('~S~ystem', hcSystemMenu, NewMenu(
      NewItem('~A~rchiwizacja danych', '', kbNoKey, cmArchiwizacja, hcArchiwizacja,
      NewItem('~O~dzysk danych', '', kbNoKey, cmOdzysk, hcOdzysk,
      NewLine(
      NewItem('~D~OS shell', '', kbNoKey, cmDosShell, hcDosShell,
      NewItem('~K~oniec', 'Alt+X', kbAltX, cmQuit, hcQuit,
    nil)))))),
    NewSubMenu('Sˆ~o~wniki', hcSlownikiMenu, NewMenu(
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
    NewSubMenu('P~l~an lekcji', hcPlanLekcjiMenu, NewMenu(
      NewItem('~N~owa lekcja', 'Ins', kbIns, cmLekcjaAdd, hcLekcjaAdd,
      NewItem('~U~suä lekcje', 'Del', kbDel, cmLekcjaDel, hcLekcjaDel,
      NewItem('~P~opraw lekcje', 'Ctrl+Enter', kbCtrlEnter, cmLekcjaEdit, hcLekcjaEdit,
      NewLine(
      NewItem('Plan lekcji n~a~uczyciela', 'F3', kbF3, cmPlanNauczyciela, hcPlanNauczyciela,
      NewItem('Plan lekcji grupy k~l~asy', 'F4', kbF4, cmPlanKlasy, hcPlanKlasy,
    nil))))))),
    NewSubMenu('~P~omoc', hcPomocMenu, NewMenu(
      NewItem('~E~lektroniczny sufler', 'F1', kbF1, cmHelp, hcHelp,
      NewItem('~O~ programie ...', '', kbNoKey, cmAboutBox, hcAboutBox,
    nil))),
  nil)))))));
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
{  TestDialog(D);}
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
    ImieNazwiskoInputLine^.SetValidator(New(Nauczyciel.PImieNazwiskoValidator, Init));

    { linia wprowadzania skr¢tu nauczyciela }
    R.Assign(3, 5, 10, 6);
    New(SkrotInputLine, Init(R, 5));
    Insert(SkrotInputLine);
    R.Assign(2, 4, Size.X-3, 5);
    New(SkrotLabel, Init(R, '~S~krot', SkrotInputLine));
    Insert(SkrotLabel);
    SkrotInputLine^.SetValidator(New(Nauczyciel.PSkrotValidator, Init));

    ImieNazwiskoInputLine^.Select;
  end;

  StoreObject(D);
  PDataDialog(D)^.SetTitle('Okno edycji nauczyciela');
{  TestDialog(D);}
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
    NazwaInputLine^.SetValidator(New(Przedmiot.PNazwaValidator, Init));

    { linia wprowadzania skr¢tu przedmiotu }
    R.Assign(3, 5, 10, 6);
    New(SkrotInputLine, Init(R, 5));
    Insert(SkrotInputLine);
    R.Assign(2, 4, Size.X-3, 5);
    New(SkrotLabel, Init(R, '~S~krot', SkrotInputLine));
    Insert(SkrotLabel);
    SkrotInputLine^.SetValidator(New(Przedmiot.PSkrotValidator, Init));

    NazwaInputLine^.Select;
  end;

  StoreObject(D);
  PDataDialog(D)^.SetTitle('Okno edycji przedmiotu');
{  TestDialog(D);}
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
    NumerInputLine^.SetValidator(New(Sala.PNumerValidator, Init));

    { linia wprowadzania nazwy pracowni, kt¢r¥ jest edytowana sala }
    R.Assign(3, 5, Size.X-3, 6);
    New(NazwaInputLine, Init(R, 255));
    Insert(NazwaInputLine);
    R.Assign(2, 4, Size.X-3, 5);
    New(NazwaLabel, Init(R, '~N~azwa pracowni', NazwaInputLine));
    Insert(NazwaLabel);
    NazwaInputLine^.SetValidator(New(Sala.PNazwaValidator, Init));

    NumerInputLine^.Select;
  end;

  StoreObject(D);
  PDataDialog(D)^.SetTitle('Okno edycji sali');
{  TestDialog(D);}
end;

procedure CreateKlasaDialog;
var
  R: TRect;
  D: PDialog;
begin
  BeginCreating('KlasaEditDialog');

  R.Assign(0, 0, 48, 11);
  D:=New(PKlasaDialog, Init(R, ''));
  with PKlasaDialog(D)^ do
  begin
    Options:=Options or ofCentered;

    { standardowe przyciski }
    InsertStandardButtons(PDataDialog(D));

    { linia wprowadzania numeru klasy }
    R.Assign(9, 2, 12, 3);
    New(NumerInputLine, Init(R, 1));
    Insert(NumerInputLine);
    R.Assign(2, 2, 8, 3);
    New(NumerLabel, Init(R, '~N~umer', NumerInputLine));
    Insert(NumerLabel);
    NumerInputLine^.SetValidator(New(Klasa.PNumerValidator, Init));

    { linia wprowadzania litery klasy }
    R.Assign(23, 2, 26, 3);
    New(LiteraInputLine, Init(R, 5));
    Insert(LiteraInputLine);
    R.Assign(15, 2, 22, 3);
    New(LiteraLabel, Init(R, '~L~itera', LiteraInputLine));
    Insert(LiteraLabel);
    LiteraInputLine^.SetValidator(New(Klasa.PLiteraValidator, Init));

    R.Assign(3, 5, Size.X-3, 6);
    New(IloscGrupRadioButtons, Init(R,
      NewSItem('~1~',
      NewSItem('~2~',
      NewSItem('~3~',
      NewSItem('~4~',
      NewSItem('~5~',
      NewSItem('~6~',
      nil))))))));
    Insert(IloscGrupRadioButtons);
    R.Assign(2, 4, Size.X-3, 5);
    New(IloscGrupLabel, Init(R, '~I~lo˜† grup', IloscGrupRadioButtons));
    Insert(IloscGrupLabel);

    NumerInputLine^.Select;
  end;

  StoreObject(D);
  PDataDialog(D)^.SetTitle('Okno edycji klasy');
{  TestDialog(D);}
end;

procedure CreateDzwonekDialog;
var
  R: TRect;
  D: PDialog;
begin
  BeginCreating('DzwonekEditDialog');

  R.Assign(0, 0, 50, 10);
  D:=New(PDzwonekDialog, Init(R, ''));
  with PDzwonekDialog(D)^ do
  begin
    Options:=Options or ofCentered;

    { standardowe przyciski }
    InsertStandardButtons(PDataDialog(D));

    { linia wprowadzania numeru pocz¥tku lekcji }
    R.Assign(25, 2, 32, 3);
    New(PoczatekInputLine, Init(R, 5));
    Insert(PoczatekInputLine);
    R.Assign(12, 2, 25, 3);
    New(PoczatekLabel, Init(R, 'P~o~cz¥tek', PoczatekInputLine));
    Insert(PoczatekLabel);
    PoczatekInputLine^.SetValidator(New(Dzwonek.PPoczatekValidator, Init));

    { linia wprowadzania dˆugo˜ci lekcji }
    R.Assign(25, 4, 30, 5);
    New(DlugoscInputLine, Init(R, 3));
    Insert(DlugoscInputLine);
    R.Assign(12, 4, 25, 5);
    New(DlugoscLabel, Init(R, '~D~ˆugo˜†', DlugoscInputLine));
    Insert(DlugoscLabel);
    DlugoscInputLine^.SetValidator(New(Dzwonek.PDlugoscValidator, Init));

    PoczatekInputLine^.Select;
  end;

  StoreObject(D);
{  TestDialog(D);}
End;

procedure CreateLekcjaDialog;
var
  R: TRect;
  D: PDialog;
begin
  BeginCreating('LekcjaEditDialog');

  R.Assign(0, 0, 64, 12);
  D:=New(PLekcjaDialog, Init(R, ''));
  with PLekcjaDialog(D)^ do
  begin
    Options:=Options or ofCentered;

    { standardowe przyciski }
    InsertStandardButtons(PDataDialog(D));

    { elementy lekcji }
    { Nauczyciel }
    R.Assign(18, 2, Size.X-2, 3);
    New(NauczycielActiveText, Init(R, '(BRAK)'));
    Insert(NauczycielActiveText);
    R.Assign(3, 2, 16, 3);
    New(NauczycielLabel, Init(R, '~N~auczyciel :', NauczycielActiveText));
    Insert(NauczycielLabel);

    { przedmiot }
    R.Assign(18, 3, Size.X-2, 4);
    New(PrzedmiotActiveText, Init(R, '(BRAK)'));
    Insert(PrzedmiotActiveText);
    R.Assign(3, 3, 16, 4);
    New(PrzedmiotLabel, Init(R, '~P~rzedmiot  :', PrzedmiotActiveText));
    Insert(PrzedmiotLabel);

    { sala }
    R.Assign(18, 4, Size.X-2, 5);
    New(SalaActiveText, Init(R, '(BRAK)'));
    Insert(SalaActiveText);
    R.Assign(3, 4, 16, 5);
    New(SalaLabel, Init(R, '~S~ala       :', SalaActiveText));
    Insert(SalaLabel);

    { klasa }
    R.Assign(18, 5, Size.X-2, 6);
    New(KlasaActiveText, Init(R, '(BRAK)'));
    Insert(KlasaActiveText);
    R.Assign(3, 5, 16, 6);
    New(KlasaLabel, Init(R, '~K~lasa      :', KlasaActiveText));
    Insert(KlasaLabel);

    { grupy klasy }
    R.Assign(18, 6, Size.X-3, 7);
    New(GrupyCheckBoxes, Init(R,
      NewSItem('~1~',
      NewSItem('~2~',
      NewSItem('~3~',
      NewSItem('~4~',
      NewSItem('~5~',
      NewSItem('~6~',
    nil))))))));
    Insert(GrupyCheckBoxes);
    R.Assign(3, 6, 16, 7);
    New(GrupyLabel, Init(R, '~G~rupy   :', GrupyCheckBoxes));
    Insert(GrupyLabel);

    NauczycielActiveText^.Select;
  end;

  StoreObject(D);
{  TestDialog(D);}
end;

var
  N: PNauczyciel;

procedure CreateChooseDataDialog;
var
  R: TRect;
  D: PDialog;
begin
  BeginCreating('ChooseDataDialog');

  R.Assign(0, 0, 50, 20);
  D:=New(PChooseDataDialog, Init(R, ''));
  with PChooseDataDialog(D)^ do
  begin
    Options:=Options or ofCentered;

    { standardowe przyciski }
    InsertStandardButtons(PDataDialog(D));

    { nieaktywna linia szybkiego wyszukiwania }
    R.Assign(3, 3, Size.X-3, 4);
    New(QuickSearchLine, Init(R, 255));
    Insert(QuickSearchLine);
    with QuickSearchLine^ do Options:=Options and (not ofSelectable);
    R.Assign(2, 2, Size.X-2, 3);
    New(QuickSearchLabel, Init(R, '~S~zybkie wyszukiwanie', QuickSearchLine));
    Insert(QuickSearchLabel);

    { lista danych }
    R.Assign(Size.X-4, 5, Size.X-3, Size.Y-5);
    New(ScrollBar, Init(R));
    Insert(ScrollBar);
    R.Assign(3, 5, Size.X-4, Size.Y-5);
    New(DataListBox, Init(R, 1, ScrollBar, QuickSearchLine));
    Insert(DataListBox);
    R.Assign(2, 4, Size.X-4, 5);
    New(DataLabel, Init(R, '~L~ista', DataListBox));
    Insert(DataLabel);
  end;
  StoreObject(D);
{ TestDialog(D);}
end;

procedure CreateHints;
var
  List: PStrListMaker;
begin
  BeginCreating('HintList');
  New(List, Init(16384, 256));

{  List^.Put(hc, '');}
  List^.Put(hcSlownikiMenu, 'Zbi¢r danych');
  List^.Put(hcNauczycieleMenu, 'Lista nauczycieli');
  List^.Put(hcPrzedmiotyMenu, 'Lista przedmiot¢w');
  List^.Put(hcKlasyMenu, 'Lista klas');
  List^.Put(hcSaleMenu, 'Lista sal');
  List^.Put(hcDzwonkiMenu, 'Lista dzwonk¢w');

  List^.Put(hcPlanLekcjiMenu, 'Operacje zwi¥zane z edycj¥ plau lekcji');
  List^.Put(hcSystemMenu, 'Operacje systemowe');
  List^.Put(hcPlanKlasy, 'Podgl¥d/edycja planu lekcji grupy klasy');
  List^.Put(hcPlanNauczyciela, 'Podgl¥d/edycja planu lekcji nauczyciela');
  List^.Put(hcArchiwizacja, 'Archiwizacja danych na dyskietk©');
  List^.Put(hcOdzysk, 'Odzysk danych z dyskietki');
  List^.Put(hcQuit, 'Koniec programu');
  List^.Put(hcHelp, 'Elektroniczny sufler');

  List^.Put(hcNauczycielAdd, 'Dodawanie nowego nauczyciela');
  List^.Put(hcNauczycielDel, 'Usuwanie istniej¥cego nauczyciela');
  List^.Put(hcNauczycielEdit, 'Poprawanie wpisu nauczyciela');
  List^.Put(hcPrzedmiotAdd, 'Dodawanie nowego przedmiotu');
  List^.Put(hcPrzedmiotDel, 'Usuwanie istniej¥cego przedmiotu');
  List^.Put(hcPrzedmiotEdit, 'Poprawanie wpisu przedmotu');
  List^.Put(hcSalaAdd, 'Dodawanie nowej sali');
  List^.Put(hcSalaDel, 'Usuwanie istniej¥cej sali');
  List^.Put(hcSalaEdit, 'Poprawanie wpisu sali');
  List^.Put(hcKlasaAdd, 'Dodawanie nowej klasy');
  List^.Put(hcKlasaDel, 'Usuwanie istniej¥cej klasy');
  List^.Put(hcKlasaEdit, 'Poprawanie wpisu klasy');
  List^.Put(hcDzwonekAdd, 'Dodawanie nowego dzwonka');
  List^.Put(hcDzwonekDel, 'Usuwanie istniej¥cego dzwonka');
  List^.Put(hcDzwonekEdit, 'Poprawanie wpisu dzwonka');
  List^.Put(hcLekcjaAdd, 'Dodawanie nowej lekcji');
  List^.Put(hcLekcjaDel, 'Usuwanie istniej¥cej lekcji');
  List^.Put(hcLekcjaEdit, 'Poprawanie lekcji');
  List^.Put(hcAboutBox, 'Informacje o programie');

  StoreObject(List);
end;

procedure CreateMainWindow;
var
  R: TRect;
  D: PMainEditWindow;
  S: PStringCollection;
  I: Integer;
begin
  BeginCreating('MainEditWindow');

  R.Assign(0, 0, 80, 23);
  D:=New(PMainEditWindow, Init(R, 'Plan lekcji'));
  with D^ do
  begin
    Palette:=dpBlueDialog;
    Options:=Options or ofCentered;
    Flags:=Flags and (not wfClose);

    { wewn©trzne ramki }
    GetExtent(R);
    R.Grow(-1, -1);
    New(InsideFrames, Init(R));
    Insert(InsideFrames);
    InsideFrames^.GrowMode:=gfGrowHiX or gfGrowHiY;

    { lista dni tygodnia }
    R.Assign(1, 3, 15, Size.Y-7);
    New(DzienTygodniaListView, Init(R, 1, nil));
    Insert(DzienTygodniaListView);
    DzienTygodniaListView^.GrowMode:=gfGrowHiY;
    New(S, Init(10, 5));
    for I:=0 to 4 do S^.AtInsert(I, NewStr(NazwyDniTygodnia[I+1]));
    DzienTygodniaListView^.NewList(S);
    R.Assign(1, 1, 15, 2);
    New(DzienTygodniaLabel, Init(R, 'Dni tygodnia', DzienTygodniaListView));
    Insert(DzienTygodniaLabel);

    { lista dzwonk¢w }
    R.Assign(16, 3, 29, Size.Y-7);
    New(DzwonekListView, Init(R, 1, nil, nil));
    Insert(DzwonekListView);
    DzwonekListView^.GrowMode:=gfGrowHiY;
    R.Assign(16, 1, 29, 2);
    New(DzwonekListLabel, Init(R, '  Dzwonki', DzwonekListView));
    Insert(DzwonekListLabel);

    { lista lekcji }
    R.Assign(31, 3, Size.X-1, Size.Y-7);
    New(LekcjaListView, Init(R, 1, nil));
    Insert(LekcjaListView);
    LekcjaListView^.GrowMode:=gfGrowHiY;
    R.Assign(31, 1, Size.X-1, 2);
    New(LekcjaListLabel, Init(R, 'Naucz.   Przedmiot   Klasa   Grupy      Sala ', LekcjaListView));
    Insert(LekcjaListLabel);

    { widok szczeg¢ˆowy lekcji }
    R.Assign(1, Size.Y-6, Size.X-1, Size.Y-1);
    New(LekcjaDetailView, Init(R));{, LekcjaListView));}
    Insert(LekcjaDetailView);
    LekcjaDetailView^.GrowMode:=gfGrowLoY or gfGrowHiY;

    DzwonekListView^.Select;
  end;

  StoreObject(D);
  TestDialog(D);
end;

(*
procedure CreatePlanLekcjiNauczycielWindow;
var
  R: TRect;
  D: PPlanLekcjiNauczycielWindow;
  I: Integer;
begin
  BeginCreating('PlanLekcjiNauczycielWindow');

  R.Assign(0, 0, 72, 18);
  New(D, Init(R, 'Plan lekcji nauczyciela'));
  with D^ do
  begin
    Options:=Options or ofCentered;
    Palette:=dpBlueDialog;
    Flags:=Flags{ and (not wfClose) }or wfGrow or wfZoom;

    GetExtent(R);
    R.Grow(-1, -1);
    New(InsideFrames, Init(R));
    Insert(InsideFrames);
    InsideFrames^.GrowMode:=gfGrowHiX or gfGrowHiY;

    R.Assign(1, 3, 10, Size.Y-7);
    New(DzwonekListView, Init(R, 1, nil));
    Insert(DzwonekListView);
    R.Assign(1, 1, 10, 2);
    New(DzwonekLabel, Init(R, 'Dzwonki', DzwonekListView));
    Insert(DzwonekLabel);
    with DzwonekListView^ do
    begin
      Options:=Options and (not ofSelectable);
      GrowMode:=gfGrowHiY;
    end;

    for I:=0 to 3 do
    begin
      R.Assign(I*15+12, 3, I*15+12+14, Size.Y-7);
      New(LekcjaListView[I+1], Init(R, 1, nil));
      Insert(LekcjaListView[I+1]);
      LekcjaListView[I+1]^.GrowMode:=gfGrowHiY;

      R.Assign(I*15+12, 1, I*15+12+14, 2);
      New(LekcjaLabel[I+1], Init(R, NazwyDniTygodnia[I+1], LekcjaListView[I+1]));
      Insert(LekcjaLabel[I+1]);
    end;

    R.Assign(1, Size.Y-6, Size.X-1, Size.Y-1);
    New(LekcjaDetailView, Init(R));
    for I:=1 to 4 do LekcjaDetailView^.ListView[I]:=LekcjaListView[I];
    Insert(LekcjaDetailView);
    LekcjaDetailView^.GrowMode:=gfGrowLoY or gfGrowHiY;

    FirstDzien:=1; SelectedDzien:=1;
    LekcjaListView[1]^.Select;
  end;

  StoreObject(D);
{  TestDialog(D);}
end;
*)
var
  D: PDzwonek;
  L: PLekcja;

begin
  CreateResources('PLAN.RES');
  CreateStatusLine;
  CreateMenuBar;
  CreateAboutBox;
  CreateNauczycielDialog;
  CreatePrzedmiotDialog;
  CreateSalaDialog;
  CreateKlasaDialog;
  CreateDzwonekDialog;
  CreateLekcjaDialog;
  CreateChooseDataDialog;
  CreateHints;
  CreateMainWindow;
{  CreatePlanLekcjiNauczycielWindow;}
  DumpNames;
  CloseResources;
end.
