Unit Sala;

interface
uses
  Objects, Drivers, Views, Dialogs, Menus, Validate,
  DataObjects, DataDialogs, Stale;

type { typ opisuj¥cy sal© }
  PSala = ^TSala;
  TSala = object (TDataObject)
    Numer: PString;
    Nazwa: PString;
    constructor Load(var S: TStream);
    function Compare(Data: PDataObject): Integer; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    procedure Assign(Data: PDataObject); virtual;
    procedure Clear; virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj¥cy walidator numeru sali }
  PNumerValidator = ^TNumerValidator;
  TNumerValidator = object (TValidator)
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
    function IsValid(const S: string): Boolean; virtual;
    procedure Error; virtual;
  end;

type { typ opisuj¥cy walidator nazwy sali }
  PNazwaValidator = ^TNazwaValidator;
  TNazwaValidator = object (TValidator)
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
  end;

type { typ opisuj¥cy okno edycji sali }
  PSalaDialog = ^TSalaDialog;
  TSalaDialog = object (TDataDialog)
    NumerInputLine: PInputLine;
    NumerLabel: PLabel;
    NazwaInputLine: PInputLine;
    NazwaLabel: PLabel;
    constructor Load(var S: TStream);
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream); virtual;
  end;

const
  RSala: TStreamRec = (
    ObjType: $4000;
    VmtLink: Ofs(TypeOf(TSala)^);
    Load   : @TSala.Load;
    Store  : @TSala.Store);
  RSalaDialog: TStreamRec = (
    ObjType: $4001;
    VmtLink: Ofs(TypeOf(TSalaDialog)^);
    Load   : @TSalaDialog.Load;
    Store  : @TSalaDialog.Store);
  RNumerValidator: TStreamRec = (
    ObjType: $4002;
    VmtLink: Ofs(TypeOf(TNumerValidator)^);
    Load   : @TNumerValidator.Load;
    Store  : @TNumerValidator.Store);
  RNazwaValidator: TStreamRec = (
    ObjType: $4003;
    VmtLink: Ofs(TypeOf(TNazwaValidator)^);
    Load   : @TNazwaValidator.Load;
    Store  : @TNazwaValidator.Store);


var
  Sale: PDataCollection;

procedure RegisterSala;

implementation
uses
  Latin2, MsgBox;

{ TSala }

constructor TSala.Load;
begin
  inherited Load(S);
  Numer:=S.ReadStr;
  Nazwa:=S.ReadStr;
end;

function TSala.Compare;
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

function TSala.GetText;
var
  S1, S2: String;
begin
  if Assigned(Numer) then S1:=Numer^
  else S1:='';
  if Assigned(Nazwa) then S2:=Nazwa^
  else S2:='';
  if Length(S1)<5 then S1:=S1+SpaceStr(5-Length(S1));
  GetText:=Copy(S1+' - '+S2, 1, MaxLen);
end;

procedure TSala.Assign;
begin
  inherited Assign(Data);
  Numer:=NewStr(PSala(Data)^.Numer^);
  Nazwa:=NewStr(PSala(Data)^.Nazwa^);
end;

procedure TSala.Clear;
begin
  if Assigned(Numer) then DisposeStr(Numer);
  Numer:=nil;
  if Assigned(Nazwa) then DisposeStr(Nazwa);
  Nazwa:=nil;
end;

procedure TSala.Store;
begin
  inherited Store(S);
  S.WriteStr(Numer);
  S.WriteStr(Nazwa);
end;

{ TNumerValidator }

function TNumerValidator.IsValidInput;
begin
  IsValidInput:=True;
  if S='' then Exit;
  if Pos(S[1], '0123456789')=0 then IsValidInput:=False;
end;

function TNumerValidator.IsValid;
begin
  IsValid:=not (Length(S)=0);
end;

procedure TNumerValidator.Error;
begin
  MessageBox(#3'Nale¾y poda† numer sali (pierwsza cyfra, reszta dowolna)', nil, mfError or mfCancelButton);
end;

{ TNazwaValidator }

function TNazwaValidator.IsValidInput;
begin
  IsValidInput:=True;
  if S='' then Exit;
  S[1]:=UpCase(S[1]);
end;

{ TSalaDialog }

constructor TSalaDialog.Load;
begin
  inherited Load(S);
  GetSubViewPtr(S, NumerInputLine);
  GetSubViewPtr(S, NumerLabel);
  GetSubViewPtr(S, NazwaInputLine);
  GetSubViewPtr(S, NazwaLabel);
end;

procedure TSalaDialog.GetData;
var
  S: String;
begin
  with TSala(Rec) do
  begin
    Clear;
    NumerInputLine^.GetData(S);
    Numer:=NewStr(S);
    NazwaInputLine^.GetData(S);
    Nazwa:=NewStr(S);
  end;
end;

procedure TSalaDialog.SetData;
var
  S: String;
begin
  with TSala(Rec) do
  begin
    if Assigned(Numer) then S:=Numer^ else S:='';
    NumerInputLine^.SetData(S);
    if Assigned(Nazwa) then S:=Nazwa^ else S:='';
    NazwaInputLine^.SetData(S);
  end;
end;

procedure TSalaDialog.Store;
begin
  inherited Store(S);
  PutSubViewPtr(S, NumerInputLine);
  PutSubViewPtr(S, NumerLabel);
  PutSubViewPtr(S, NazwaInputLine);
  PutSubViewPtr(S, NazwaLabel);
end;

{ *** }

procedure RegisterSala;
begin
  RegisterType(RSala);
  RegisterType(RSalaDialog);
  RegisterType(RNumerValidator);
  RegisterType(RNazwaValidator);
end;

begin
  Sale:=nil;
end.
