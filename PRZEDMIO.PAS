Unit Przedmiot;

interface
uses
  Objects, Drivers, Views, Dialogs, Menus,
  DataObjects, DataDialogs, Stale;

type { typ opisuj¥cy przedmiot }
  PPrzedmiot = ^TPrzedmiot;
  TPrzedmiot = object (TDataObject)
    Nazwa: PString;
    Skrot: PString;
    constructor Load(var S: TStream);
    function Compare(Data: PDataObject): Integer; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    procedure Clear; virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj¥cy okno edycji przedmiotu }
  PPrzedmiotDialog = ^TPrzedmiotDialog;
  TPrzedmiotDialog = object (TDataDialog)
    NazwaInputLine: PInputLine;
    NazwaLabel: PLabel;
    SkrotInputLine: PInputLine;
    SkrotLabel: PLabel;
    constructor Load(var S: TStream);
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream); virtual;
  end;

const
  RPrzedmiot: TStreamRec = (
    ObjType: $3000;
    VmtLink: Ofs(TypeOf(TPrzedmiot)^);
    Load   : @TPrzedmiot.Load;
    Store  : @TPrzedmiot.Store);
  RPrzedmiotDialog: TStreamRec = (
    ObjType: $3001;
    VmtLink: Ofs(TypeOf(TPrzedmiotDialog)^);
    Load   : @TPrzedmiotDialog.Load;
    Store  : @TPrzedmiotDialog.Store);

var
  Przedmioty: PDataCollection;

procedure RegisterPrzedmiot;

implementation
uses
  Latin2;

{ TPrzedmiot }

constructor TPrzedmiot.Load;
begin
  inherited Load(S);
  Nazwa:=S.ReadStr;
  Skrot:=S.ReadStr;
end;

function TPrzedmiot.Compare;
var
  S1, S2: String;
begin
  if inherited Compare(Data)=0 then Compare:=0
  else
  begin
    S1:=GetText(255);
    S2:=Data^.GetText(255);
    Compare:=CompareStr(S1, S2, False);
  end;
end;

function TPrzedmiot.GetText;
var
  S: String;
begin
  if Assigned(Nazwa) then S:=Nazwa^
  else S:='';
  GetText:=Copy(S, 1, MaxLen);
end;

procedure TPrzedmiot.Clear;
begin
  inherited Clear;
  if Assigned(Nazwa) then DisposeStr(Nazwa);
  Nazwa:=nil;
  if Assigned(Skrot) then DisposeStr(Skrot);
  Skrot:=nil;
end;

procedure TPrzedmiot.Store;
begin
  inherited Store(S);
  S.WriteStr(Nazwa);
  S.WriteStr(Skrot);
end;

{ TPrzedmiotDialog }

constructor TPrzedmiotDialog.Load;
begin
  inherited Load(S);
  GetSubViewPtr(S, NazwaInputLine);
  GetSubViewPtr(S, NazwaLabel);
  GetSubViewPtr(S, SkrotInputLine);
  GetSubViewPtr(S, SkrotLabel);
end;

procedure TPrzedmiotDialog.GetData;
begin
end;

procedure TPrzedmiotDialog.SetData;
begin
end;

procedure TPrzedmiotDialog.Store;
begin
  inherited Store(S);
  PutSubViewPtr(S, NazwaInputLine);
  PutSubViewPtr(S, NazwaLabel);
  PutSubViewPtr(S, SkrotInputLine);
  PutSubViewPtr(S, SkrotLabel);
end;

{ *** }

procedure RegisterPrzedmiot;
begin
  RegisterType(RPrzedmiot);
  RegisterType(RPrzedmiotDialog);
end;

begin
  Przedmioty:=nil;
end.
