Unit Przedmiot;

interface
uses
  Objects, Drivers, Views, Dialogs, Menus, Validate,
  DataObjects, DataDialogs, Stale;

type { typ opisuj¥cy przedmiot }
  PPrzedmiot = ^TPrzedmiot;
  TPrzedmiot = object (TDataObject)
    Nazwa: PString;
    Skrot: PString;
    constructor Load(var S: TStream);
    function Compare(Data: PDataObject): Integer; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    procedure Assign(Data: PDataObject); virtual;
    procedure Clear; virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj¥cy walidator nazwy przedmiotu }
  PNazwaValidator = ^TNazwaValidator;
  TNazwaValidator = object (TValidator)
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
    function IsValid(const S: string): Boolean; virtual;
    procedure Error; virtual;
  end;

type { typ opisuj¥cy walidator skr¢tu }
  PSkrotValidator = ^TSkrotValidator;
  TSkrotValidator = object (TValidator)
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
    function IsValid(const S: string): Boolean; virtual;
    procedure Error; virtual;
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
  RNazwaValidator: TStreamRec = (
    ObjType: $3002;
    VmtLink: Ofs(TypeOf(TNazwaValidator)^);
    Load   : @TNazwaValidator.Load;
    Store  : @TNazwaValidator.Store);
  RSkrotValidator: TStreamRec = (
    ObjType: $3003;
    VmtLink: Ofs(TypeOf(TSkrotValidator)^);
    Load   : @TSkrotValidator.Load;
    Store  : @TSkrotValidator.Store);

var
  Przedmioty: PDataCollection;

procedure RegisterPrzedmiot;

implementation
uses
  Latin2, MsgBox;

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

procedure TPrzedmiot.Assign;
begin
  inherited Assign(Data);
  if Assigned(PPrzedmiot(Data)^.Nazwa) then Nazwa:=NewStr(PPrzedmiot(Data)^.Nazwa^)
  else Nazwa:=nil;
  if Assigned(PPrzedmiot(Data)^.Skrot) then Skrot:=NewStr(PPrzedmiot(Data)^.Skrot^)
  else Skrot:=nil;
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

{ TNazwaValidator }

function TNazwaValidator.IsValidInput;
begin
  IsValidInput:=True;
  if S='' then Exit;
  S[1]:=UpCase(S[1]);
end;

function TNazwaValidator.IsValid;
begin
  IsValid:=not (Length(S)=0);
end;

procedure TNazwaValidator.Error;
begin
  MessageBox(#3'Nale¾y poda† nazw© identyfikuj¥c¥ przedmiot', nil, mfError or mfCancelButton);
end;

{ TSkrotValidator }

function TSkrotValidator.IsValidInput;
var
  I: Integer;
begin
  isValidInput:=True;
  if S='' then Exit;
  for I:=1 to Length(S) do S[I]:=UpCase(S[I]);
end;

function TSkrotValidator.IsValid;
begin
  IsValid:=not (Length(S)=0);
end;

procedure TSkrotValidator.Error;
begin
  MessageBox(#3'Nale¾y poda† skr¢t identyfikuj¥cy przedmiot', nil, mfError or mfCancelButton);
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
var
  S: String;
begin
  with TPrzedmiot(Rec) do
  begin
    Clear;
    NazwaInputLine^.GetData(S);
    Nazwa:=NewStr(S);
    SkrotInputLine^.GetData(S);
    Skrot:=NewStr(S);
  end;
end;

procedure TPrzedmiotDialog.SetData;
var
  S: String;
begin
  with TPrzedmiot(Rec) do
  begin
    if Assigned(Nazwa) then S:=Nazwa^ else S:='';
    NazwaInputLine^.SetData(S);
    if Assigned(Skrot) then S:=Skrot^ else S:='';
    SkrotInputLine^.SetData(S);
  end;
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
  RegisterType(RNazwaValidator);
  RegisterType(RSkrotValidator);
end;

begin
  Przedmioty:=nil;
end.
