Program Szkola;
uses App, Objects, Drivers, Views, Dialogs, Menus, MsgBox,
     DataObjects, DataDialogs, BazaDanych, Stale,
     Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek,
     Lekcja, MainWindow, OknoPrzegladowe, Archiwizacja,
     HeapViewer, ClockViewer, Help, AboutBox;

type { Typ opisuj¥cy gˆ¢wn¥ aplikacj© }
  PMainApp = ^TMainApp;
  TMainApp = object (TApplication)
    HeapViewer: PHeapMemViewer;
    ClockViewer: PClockViewer;
    constructor Init;
    destructor Done; virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure Idle; virtual;
    procedure GetEvent(var Event: TEvent); virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure ShowPlanNauczyciela;
    procedure ShowPlanKlasy;
  end;

constructor TMainApp.Init;
var
  W: PPlanLekcjiMainWindow;
  R: TRect;
begin
  inherited Init;
  OpenFiles('DATA');
  CloseFiles;

  New(MainWin, Init('Plan lekcji'));
  InsertWindow(MainWin);
{
  R.Assign(Size.X-10, Size.Y-1, Size.X, Size.Y);
  New(HeapViewer, Init(R));
  Insert(HeapViewer);
}
  R.Assign(Size.X-9, 0, Size.X, 1);
  New(ClockViewer, Init(R));
  Insert(ClockViewer);
  ShowOProgramie;
end;

destructor TMainApp.Done;
begin
  UpdateAllStreams;
  inherited Done;
end;

const
  cmNothing=$ffea;

procedure TMainApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R); R.A.Y:=R.B.Y-1;
  StatusLine:=New(PHintStatusLine, Init(R,
    NewStatusDef($1000, $1000,
      NewStatusKey('~F1~ Pomoc', kbF1, cmHelp,
      NewStatusKey('~Alt-X~ Koniec', kbAltX, cmQuit,
      NewStatusKey('~Ins~ Dodanie', kbNoKey, cmDodajLekcje,
      NewStatusKey('~Del~ Usuni©cie', kbNoKey, cmUsunLekcje,
      NewStatusKey('~Enter~ Edycja', kbNoKey, cmPoprawLekcje,
      NewStatusKey('~F10~ Menu', kbF10, cmMenu,
    nil)))))),
    NewStatusDef($FFF, $FFF,
      NewStatusKey('~Esc~ Zamknij pomoc', kbEsc, cmClose,
      NewStatusKey('', kbF5, cmZoom,
      NewStatusKey('', kbCtrlF5, cmResize,
    nil))),
    NewStatusDef($1001, $2001,
      NewStatusKey('~Esc~ Wyj˜cie', kbNoKey, cmNothing,
      NewStatusKey('~Enter~ Dalej', kbNoKey, cmNothing,
      NewStatusKey('~F1~ Pomoc', kbNoKey, cmHelp,
    nil))),
    NewStatusDef($2001, $3001,
      NewStatusKey('~Esc~ Wyj˜cie', kbNoKey, cmNothing,
      NewStatusKey('~Enter~ Popraw', kbNoKey, cmNothing,
      NewStatusKey('~F1~ Pomoc', kbF1, cmHelp,
      NewStatusKey('~F2~ Zlicz przedmioty', kbNoKey, cmNothing,
      NewStatusKey('~F4~ Drukuj', kbF4, cmPrint,
    nil))))),
    NewStatusDef($FF00, $FFFF,
      NewStatusKey('~Esc~ Wyj˜cie', kbNoKey, cmNothing,
      NewStatusKey('~Enter~ Wybierz', kbNoKey, cmNothing,
    nil)),
  nil)))))));
end;

procedure TMainApp.InitMenuBar;
var R: TRect;
begin
  GetExtent(R); R.B.Y:=R.A.Y+1;
  MenuBar:=New(PMenuBar, Init(R,
    BazaDanychMenu(
    NewSubMenu('~P~odgl¥d', $FF30, NewMenu(
      NewItem('Plan lekcji ~n~auczyciela', 'F3', kbF3, cmShowPlanNauczyciela, $FF31,
      NewItem('Plan lekcji ~k~lasy (grupy)', 'F4', kbF4, cmShowPlanKlasy, $FF32,
      nil))),
    NewSubMenu('~A~rchiwizacja', $FF20, NewMenu(
      NewItem('~A~rchiwizuj', '', kbNoKey, cmArchiwizacja, $FF21,
      NewItem('~O~dzyskaj', '', kbNoKey, cmOdzysk, $FF22,
      NewLine(
      NewItem('~D~OS Shell', '', kbNoKey, cmDosShell, $FF23,
      nil))))),
    NewSubMenu('~P~omoc', $FF00, NewMenu(
      NewItem('~S~ufler', 'F1', kbF1, cmHelp, $FF01,
      NewItem('~O~ programie ...', '', kbF2, cmOProgramie, $FF02,
      nil))),
      NewItem('~K~oniec', '', kbAltX, cmQuit, $FF10,
  nil)))))));
end;

procedure TMainApp.Idle;
begin
  inherited Idle;
{  HeapViewer^.Draw;}
  ClockViewer^.Draw;
end;

procedure TMainApp.GetEvent(var Event: TEvent);
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
    evKeyboard: if Event.KeyCode=kbCtrlF10 then
    begin
      Str(MemAvail, S);
      MessageBox(#3'Ilo˜† wolnej pami©ci: '+S, nil, mfInformation or mfOkButton);
    end;
  end;
end;

procedure TMainApp.ShowPlanNauczyciela;
var
  W: PNauczycielPlanLekcjiViewWindow;
  I: Integer;
begin
  I:=ChooseNauczyciel(Nauczyciele, True);
  if I<>-1 then
  begin
    New(W, Init(I));
    ExecuteDialog(W, nil);
    DostosujListeLekcji;
    MainWin^.Draw;
  end;
end;

procedure TMainApp.ShowPlanKlasy;
var
  W: PKlasaPlanLekcjiViewWindow;
  RB: PRadioButtons;
  I: LongInt;
  G: Word;
  D: PDialog;
  R: TRect;
  IloscGrup: Word;
  K: PKlasa;
begin
  I:=ChooseKlasa(Klasy, False);
  if I<>-1 then
  begin
    R.Assign(0, 0, 9*7+4, 7);
    New(D, Init(R,'Wybierz grup©'));
    D^.Options:=D^.Options or ofCentered;
    D^.HelpCtx:=$1001;

    R.Assign(2, 2, D^.Size.X-2, 3);
    RB:=(New(PRadioButtons, Init(R,
      NewSItem('~1~',
      NewSItem('~2~',
      NewSItem('~3~',
      NewSItem('~4~',
      NewSItem('~5~',
      NewSItem('~6~',
      NewSItem('~7~',
      NewSItem('~8~',
      NewSItem('~9~', nil))))))))))));

    K:=PKlasa(Klasy^.ItemByIndex(I));
    RB^.EnableMask:=IncPower2(K^.FIloscGrup);
    D^.Insert(RB);

    R.Assign((D^.Size.X div 2) - 7, 4, (D^.Size.X div 2)+6, 6);
    D^.Insert(New(PButton, Init(R, '~W~ybierz', cmOK, bfDefault)));

    D^.SelectNext(False);

    G:=0;
    if ExecuteDialog(D, @G)<>cmCancel then
    begin
      New(W, Init(I, G));
      ExecuteDialog(W, nil);
      DostosujListeLekcji;
      MainWin^.Draw;
    end;
  end;
end;

function ConfirmExit: Boolean;
begin
  ConfirmExit:=MessageBox(#3'Czy na pewno chcesz zakoäczy† program ?',nil,mfConfirmation or mfOkButton or mfCancelButton)=cmOK;
end;

procedure TMainApp.HandleEvent(var Event: TEvent);
begin
  if Event.What=evCommand then
    case Event.Command of
      cmDodajNauczyciela    : DodajNauczyciela;
      cmPoprawNauczyciela   : PoprawNauczyciela;
      cmUsunNauczyciela     : UsunNauczyciela;
      cmDodajPrzedmiot      : DodajPrzedmiot;
      cmPoprawPrzedmiot     : PoprawPrzedmiot;
      cmUsunPrzedmiot       : UsunPrzedmiot;
      cmDodajKlase          : DodajKlase;
      cmPoprawKlase         : PoprawKlase;
      cmUsunKlase           : UsunKlase;
      cmDodajSale           : DodajSale;
      cmPoprawSale          : PoprawSale;
      cmUsunSale            : UsunSale;
      cmDodajDzwonek        : DodajDzwonek;
      cmPoprawDzwonek       : PoprawDzwonek;
      cmUsunDzwonek         : UsunDzwonek;
      cmShowPlanNauczyciela : ShowPlanNauczyciela;
      cmShowPlanKlasy       : ShowPlanKlasy;
      cmArchiwizacja        : Archiwizuj;
      cmOdzysk              : Odtworz;
      cmOProgramie          : ShowOProgramie;
      cmQuit                : if not ConfirmExit then ClearEvent(Event);
    end;
  inherited HandleEvent(Event);
end;

procedure AfterExitInfo;
begin
  if IOResult<>0 then;
  Writeln('Program "Plan lekcji" zakoäczyˆ dziaˆanie.');
  Writeln;
  Writeln('Teraz mo¾na bezpiecznie wyˆ¥czy† komputer');
  Writeln;
  Writeln;
end;

var
  Main: TMainApp;

begin
  Main.Init;
  Main.Run;
  Main.Done;
  AfterExitInfo;
end.
