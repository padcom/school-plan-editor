Unit Help;

interface
uses
  Objects, Drivers, Views, Dialogs, Menus,
  Stale;

type { typ opisuj¥cy lini© statusu z podpowiedziami }
  PHintStatusLine = ^THintStatusLine;
  THintStatusLine = object (TStatusLine)
    Hints: PStringList;
    function Hint(AHelpCtx: Word): String; virtual;
  end;

const
  RHintStatusLine: TStreamRec = (
    ObjType: $8000;
    VmtLink: Ofs(TypeOf(THintStatusLine)^);
    Load   : @THintStatusLine.Load;
    Store  : @THintStatusLine.Store);

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

{ *** }

procedure RegisterHelp;
begin
  RegisterType(RHintStatusLine);
end;

begin
end.
