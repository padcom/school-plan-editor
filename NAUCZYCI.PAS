Unit Nauczyciel;

interface
uses
  Objects, Drivers, Views, Dialogs, Menus,
  DataObjects, DataDialogs, Stale;

type { typ opisuj¥cy nauczyciela }
  PNauczyciel = ^TNauczyciel;
  TNauczyciel = object (TDataObject)
    ImieNazwisko: PString;
    Skrot: PString;
    constructor Load(var S: TStream);
    function Compare(Data: PDataObject): Integer; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    procedure Assign(Data: PDataObject); virtual;
    procedure Clear; virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj¥cy okno edycji danych nauczyciela }
  PNauczycielDialog = ^TNauczycielDialog;
  TNauczycielDialog = object (TDataDialog)
    ImieNazwiskoInputLine: PInputLine;
    ImieNazwiskoLabel: PLabel;
    SkrotInputLine: PInputLine;
    SkrotLabel: PLabel;
    constructor Load(var S: TStream);
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream); virtual;
  end;

const
  RNauczyciel: TStreamRec = (
    ObjType: $2000;
    VmtLink: Ofs(TypeOf(TNauczyciel)^);
    Load   : @TNauczyciel.Load;
    Store  : @TNauczyciel.Store);
  RNauczycielDialog: TStreamRec = (
    ObjType: $2001;
    VmtLink: Ofs(TypeOf(TNauczycielDialog)^);
    Load   : @TNauczycielDialog.Load;
    Store  : @TNauczycielDialog.Store);

var
  Nauczyciele: PDataCollection;

procedure RegisterNauczyciel;

implementation
uses
  Latin2;

{ TNauczyciel }

constructor TNauczyciel.Load;
begin
  inherited Load(S);
  ImieNazwisko:=S.ReadStr;
end;

function TNauczyciel.Compare;
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

function TNauczyciel.GetText;
var
  S: String;
begin
  if Assigned(ImieNazwisko) then S:=ImieNazwisko^
  else S:='';
  GetText:=Copy(S, 1, MaxLen);
end;

procedure TNauczyciel.Assign;
begin
  inherited Assign(Data);
  ImieNazwisko:=NewStr(PNauczyciel(Data)^.ImieNazwisko^);
  Skrot:=NewStr(PNauczyciel(Data)^.Skrot^);
end;

procedure TNauczyciel.Clear;
begin
  inherited Clear;
  if Assigned(ImieNazwisko) then DisposeStr(ImieNazwisko);
  ImieNazwisko:=nil;
  if Assigned(Skrot) then DisposeStr(Skrot);
  Skrot:=nil;
end;

procedure TNauczyciel.Store;
begin
  inherited Store(S);
  S.WriteStr(ImieNazwisko);
  S.WriteStr(Skrot);
end;

{ TNauczycielDialog }

constructor TNauczycielDialog.Load;
begin
  inherited Load(S);
  GetSubViewPtr(S, ImieNazwiskoInputLine);
  GetSubViewPtr(S, ImieNazwiskoLabel);
  GetSubViewPtr(S, SkrotInputLine);
  GetSubViewPtr(S, SkrotLabel);
end;

procedure TNauczycielDialog.GetData;
var
  S: String;
begin
  with TNauczyciel(Rec) do
  begin
    Clear;
    ImieNazwiskoInputLine^.GetData(S);
    ImieNazwisko:=NewStr(S);
    SkrotInputLine^.GetData(S);
    Skrot:=NewStr(S);
  end;
end;

procedure TNauczycielDialog.SetData;
var
  S: String;
begin
  with TNauczyciel(Rec) do
  begin
    if Assigned(ImieNazwisko) then S:=ImieNazwisko^ else S:='';
    ImieNazwiskoInputLine^.SetData(S);
    if Assigned(Skrot) then S:=Skrot^ else S:='';
    SkrotInputLine^.SetData(S);
  end;
end;

procedure TNauczycielDialog.Store;
begin
  inherited Store(S);
  PutSubViewPtr(S, ImieNazwiskoInputLine);
  PutSubViewPtr(S, ImieNazwiskoLabel);
  PutSubViewPtr(S, SkrotInputLine);
  PutSubViewPtr(S, SkrotLabel);
end;

{ *** }

procedure RegisterNauczyciel;
begin
  RegisterType(RNauczyciel);
  RegisterType(RNauczycielDialog);
end;

begin
  Nauczyciele:=nil;
end.
