Unit Help;

interface
uses
  App, Objects, Drivers, Views, Dialogs, Menus, TextView,
  Stale;

type { typ opisuj¥cy lini© statusu z podpowiedziami }
  PHintStatusLine = ^THintStatusLine;
  THintStatusLine = object (TStatusLine)
    Hints: PStringList;
    function Hint(AHelpCtx: Word): String; virtual;
  end;

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

const
  HelpInUse: Boolean = False;

procedure ShowHelp(Index: Word);

const
  RHintStatusLine: TStreamRec = (
    ObjType: $8000;
    VmtLink: Ofs(TypeOf(THintStatusLine)^);
    Load   : @THintStatusLine.Load;
    Store  : @THintStatusLine.Store);
  RHelpWindow: TStreamRec = (
    ObjType: $8001;
    VmtLink: Ofs(TypeOf(THelpWindow)^);
    Load   : @THelpWindow.Load;
    Store  : @THelpWindow.Store);

procedure RegisterHelp;

implementation
uses
  Resource;

{ THintStatusLine }

function THintStatusLine.Hint;
begin
  if not Assigned(Hints) then Hints:=PStringList(ResourceFile.Get('HintList'));
  Hint:=Hints^.Get(AHelpCtx);
end;

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

{ *** }

procedure RegisterHelp;
begin
  RegisterType(RHintStatusLine);
  RegisterType(RHelpWindow);
end;

begin
end.
