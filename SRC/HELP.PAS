Unit Help;

interface
uses Objects, Drivers, Views, Dialogs, TextView, Menus;

type { typ opisuj¥cy okno pomocy }
  PHelpWindow = ^THelpWindow;
  THelpWindow = object (TWindow)
  private
    FTerminal: PTerminal;
  public
    constructor Init(FileName: String; Help: Word);
    procedure HandleEvent(var Event: TEvent); virtual;
    function GetPalette: PPalette; virtual;
  end;

procedure ShowHelp(Index: Word);

type { typ opisuj¥cy StatusBar z podpowiedziami }
  PHintStatusLine = ^THintStatusLine;
  THintStatusLine = object (TStatusLine)
    function Hint(AHelpCtx: Word): String; virtual;
  end;

const
  HelpInUse: Boolean = False;

implementation
uses App;

{ THelpWindow }

constructor THelpWindow.Init;
var
  R: TRect;
  HelpFile, TermFile: Text;
  S, SIndex: String;
  ShowIndex: Boolean;
begin
  if IOResult<>0 then;

  Assign(HelpFile, 'help\index.txt');
  {$I-} Reset(HelpFile); {$I+}
  if IOResult=0 then
  begin
    ShowIndex:=True;
    System.Close(HelpFile);
  end
  else ShowIndex:=False;

  Str(Help, S);
  FileName:='help\'+S+'.txt';
  Desktop^.GetExtent(R);
  R.Grow(-2, -2);
  S:='Elektroniczny sufler';
  if ShowIndex then
  begin
    Str(Help, SIndex);
    S:=S+' - plik: '+SIndex+'.txt';
  end;
  inherited Init(R, S, 0);

  Palette:=wpCyanWindow;
  GetExtent(R);
  R.Grow(-1, -1);
  New(FTerminal, Init(R,
    StandardScrollBar(sbHorizontal or sbHandleKeyboard),
    StandardScrollBar(sbVertical or sbHandleKeyboard),
    16384));
  Insert(FTerminal);
  AssignDevice(TermFile, FTerminal);
  Rewrite(TermFile);

  Assign(HelpFile, FileName);
  {$I-} Reset(HelpFile); {$I+}
  if IOResult=0 then
  begin
    while not Eof(Helpfile) do
    begin
      Readln(HelpFile, S);
      Writeln(TermFile, S);
    end;
    System.Close(HelpFile);
  end
  else
  begin
    Writeln(TermFile);
    Writeln(TermFile, '  Brak pomocy na wybrany temat ...');
    Writeln(TermFile);
  end;

  System.Close(TermFile);

  FTerminal^.ScrollTo(0, 0);
  FTerminal^.SetState(sfCursorVis, False);
  HelpCtx:=$FFF;
end;

procedure THelpWindow.HandleEvent;
begin
  if Event.What=evCommand then
  case Event.Command of
    cmClose:
    begin
      EndModal(cmClose);
      ClearEvent(Event);
    end;
  end;
  inherited HandleEvent(Event);
end;

function THelpWindow.GetPalette;
var
  S: PPalette;
begin
  S:=inherited GetPalette;
  S^[6]:=#12;
  GetPalette:=S;
end;

procedure ShowHelp(Index: Word);
var
  W: PWindow;
begin
  HelpInUse := True;

  W:=New(PHelpWindow,Init('PLAN.BAK', Index));
  if Application^.ValidView(W) <> nil then
  begin
    Desktop^.ExecView(W);
    Dispose(W, Done);
  end;

  HelpInUse := False;
end;

{ THintStatusLine }

function THintStatusLine.Hint;
begin
  case HelpCtx of
    $FF10: Hint:='Koniec programu';

    $FF20: Hint:='Archiwizacja i zapis danych na dyskietk©';
    $FF21: Hint:='Archiwizacja danych na dyskietk©';
    $FF22: Hint:='Odzysk danych z dyskietki';
    $FF23: Hint:='Wyskok do DOS''u (systemowy wiersz poleceä)';

    $FF30: Hint:='Podgl¥d uˆo¾onego planu zaj©†';
    $FF31: Hint:='Podgl¥d uˆo¾onego planu zaj©† dla nauczyciela';
    $FF32: Hint:='Podgl¥d uˆo¾onego planu zaj©† dla grupy klasy';

    $FF3F: Hint:='Sˆowniki';
    $FF40: Hint:='Spis nauczycieli';
    $FF41: Hint:='Dodawanie nowego nauczyciela';
    $FF42: Hint:='Poprawianie wpisu nauczyciela';
    $FF43: Hint:='Usuwanie nauczyciela';

    $FF44: Hint:='Spis przedmiot¢w';
    $FF45: Hint:='Dodawanie nowego przedmiotu';
    $FF46: Hint:='Poprawianie wpisu przedmiotu';
    $FF47: Hint:='Usuwanie przedmiotu';

    $FF48: Hint:='Spis klas';
    $FF49: Hint:='Dodawanie nowej klasy';
    $FF4A: Hint:='Poprawianie wpisu klasy';
    $FF4B: Hint:='Usuwanie klasy';

    $FF4C: Hint:='Spis sal lekcyjnych';
    $FF4D: Hint:='Dodawanie nowej sali';
    $FF4E: Hint:='Poprawianie wpisu sali';
    $FF4F: Hint:='Usuwanie sali';

    $FF50: Hint:='Spis dzwonk¢w (rozkˆad czasowy)';
    $FF51: Hint:='Dodawanie nowego dzwonka';
    $FF52: Hint:='Poprawianie wpisu dzwonka';
    $FF53: Hint:='Usuwanie dzwonka';

    $FF00: Hint:='Pomoc';
    $FF01: Hint:='Uruchomienie elektronicznego suflera';
    $FF02: Hint:='Informacje o programie';

    else Hint:='';
  end;
end;

begin
end.
