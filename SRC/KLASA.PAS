Unit Klasa;

interface
uses
  Objects, Drivers, Views, Dialogs, Menus, Validate,
  DataObjects, DataDialogs, Stale;

type { typ opisuj�cy klas� }
  PKlasa = ^TKlasa;
  TKlasa = object (TDataObject)
    Numer: Byte;
    Litera: Char;
    IloscGrup: Byte;
    Grupy: Word;
    FiltrowaneGrupy: Word;
    constructor Load(var S: TStream);
    function Compare(Data: PDataObject): Integer; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    procedure Assign(Data: PDataObject); virtual;
    procedure Clear; virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj�cy walidator numeru klasy }
  PNumerValidator = ^TNumerValidator;
  TNumerValidator = object (TValidator)
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
    function IsValid(const S: string): Boolean; virtual;
    procedure Error; virtual;
  end;

type { typ opisuj�cy walidator litery klasy }
  PLiteraValidator = ^TLiteraValidator;
  TLiteraValidator = object (TValidator)
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
    function IsValid(const S: string): Boolean; virtual;
    procedure Error; virtual;
  end;

type { typ opisuj�cy okno edycji danych klasy }
  PKlasaDialog = ^TKlasaDialog;
  TKlasaDialog = object (TDataDialog)
    NumerInputLine: PInputLine;
    NumerLabel: PLabel;
    LiteraInputLine: PInputLine;
    LiteraLabel: PLabel;
    IloscGrupRadioButtons: PRadioButtons;
    IloscGrupLabel: PLabel;
    constructor Load(var S: TStream);
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj�cy dialog wyboru grupy klasy }
  PChooseGrupaKlasyDialog = ^TChooseGrupaKlasyDialog;
  TChooseGrupaKlasyDialog = object (TDataDialog)
    GrupaRadioButtons: PRadioButtons;
    GrupaLabel: PLabel;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream); virtual;
  end;

const
  RKlasa: TStreamRec = (
    ObjType: $5001;
    VmtLink: Ofs(TypeOf(TKlasa)^);
    Load   : @TKlasa.Load;
    Store  : @TKlasa.Store);
  RKlasaDialog: TStreamRec = (
    ObjType: $5002;
    VmtLink: Ofs(TypeOf(TKlasaDialog)^);
    Load   : @TKlasaDialog.Load;
    Store  : @TKlasaDialog.Store);
  RNumerValidator: TStreamRec = (
    ObjType: $5003;
    VmtLink: Ofs(TypeOf(TNumerValidator)^);
    Load   : @TNumerValidator.Load;
    Store  : @TNumerValidator.Store);
  RLiteraValidator: TStreamRec = (
    ObjType: $5004;
    VmtLink: Ofs(TypeOf(TLiteraValidator)^);
    Load   : @TLiteraValidator.Load;
    Store  : @TLiteraValidator.Store);
  RChooseGrupaKlasyDialog: TStreamRec = (
    ObjType: $5005;
    VmtLink: Ofs(TypeOf(TChooseGrupaKlasyDialog)^);
    Load   : @TChooseGrupaKlasyDialog.Load;
    Store  : @TChooseGrupaKlasyDialog.Store);

var
  Klasy: PDataCollection;

procedure RegisterKlasa;

implementation
uses
  Latin2, MsgBox;

{ TKlasa }

constructor TKlasa.Load;
begin
  inherited Load(S);
  S.Read(Numer, SizeOf(Numer));
  S.Read(Litera, SizeOf(Litera));
  S.Read(IloscGrup, SizeOf(IloscGrup));
end;

function TKlasa.Compare;
var
  S1, S2: String;
begin
  if inherited Compare(Data)=0 then compare:=0
  else
  begin
    S1:=GetText(255);
    S2:=Data^.GetText(255);
    Compare:=CompareStr(S1, S2, False);
  end;
end;

function TKlasa.GetText;
var
  S: String;
begin
  Str(Numer, S);
  S:=S+Litera;
  GetText:=Copy(S, 1, MaxLen);
end;

procedure TKlasa.Assign;
begin
  inherited Assign(Data);
  Numer:=PKlasa(Data)^.Numer;
  Litera:=PKlasa(Data)^.Litera;
  IloscGrup:=PKlasa(Data)^.IloscGrup;
  Grupy:=PKlasa(Data)^.Grupy;
end;

procedure TKlasa.Clear;
begin
  inherited Clear;
  Numer:=0;
  Litera:=' ';
  IloscGrup:=0;
  Grupy:=0;
end;

procedure TKlasa.Store;
begin
  inherited Store(S);
  S.Write(Numer, SizeOf(Numer));
  S.Write(Litera, SizeOf(Litera));
  S.Write(IloscGrup, SizeOf(IloscGrup));
end;

{ TNumerValidator }

function TNumerValidator.IsValidInput;
var
  I: Integer;
begin
  IsValidInput:=True;
  if S='' then Exit;
  for I:=1 to Length(S) do if Pos(S[1], '0123456789')=0 then
  begin
    IsValidInput:=False;
    Exit;
  end;
end;

function TNumerValidator.IsValid;
begin
  IsValid:=True;
  if S='' then IsValid:=False
  else if S[1]='0' then IsValid:=False;
end;

procedure TNumerValidator.Error;
begin
  MessageBox(#3'Nale�y poda� numer klasy', nil, mfError or mfCancelButton);
end;

{ TLiteraValidator }

function TLiteraValidator.IsValidInput;
begin
  IsValidInput:=True;
  if S='' then Exit;
  S[1]:=UpCase(S[1]);
  IsValidInput:=Pos(S[1], DuzeLitery)<>0;
end;

function TLiteraValidator.IsValid;
begin
  IsValid:=not (Length(S)=0);
end;

procedure TLiteraValidator.Error;
begin
  MessageBox(#3'Nale�y poda� liter� klasy', nil, mfError or mfCancelButton);
end;

{ TKlasaDialog }

constructor TKlasaDialog.Load;
begin
  inherited Load(S);
  GetSubViewPtr(S, NumerInputLine);
  GetSubViewPtr(S, NumerLabel);
  GetSubViewPtr(S, LiteraInputLine);
  GetSubViewPtr(S, LiteraLabel);
  GetSubViewPtr(S, IloscGrupRadioButtons);
  GetSubViewPtr(S, IloscGrupLabel);
end;

procedure TKlasaDialog.GetData;
var
  S: String;
  E: Integer;
  L: LongInt;
begin
  with TKlasa(Rec) do
  begin
    NumerInputLine^.GetData(S);
    Val(S, Numer, E);
    LiteraInputLine^.GetData(S);
    Litera:=S[1];
    IloscGrupRadioButtons^.GetData(L);
    IloscGrup:=L+1;
  end;
end;

procedure TKlasaDialog.SetData;
var
  S: String;
  L: LongInt;
begin
  with TKlasa(Rec) do
  begin
    Str(Numer, S);
    NumerInputLine^.SetData(S);
    S:=Litera;
    LiteraInputLine^.SetData(S);
    L:=IloscGrup-1;
    IloscGrupRadioButtons^.SetData(L);
  end;
end;

procedure TKlasaDialog.HandleEvent;
begin
  if Event.What=evKeyboard then
  case Event.KeyCode of
    kbDown:
    begin
      SelectNext(False);
      ClearEvent(Event);
    end;
    kbUp:
    begin
      SelectNext(True);
      ClearEvent(Event);
    end;
    kbEnter: if (Current<>PView(OkButton)) and (Current<>PView(CancelButton)) and (Current<>PView(HelpButton)) then
    begin
      SelectNext(False);
      ClearEvent(Event);
    end;
  end;
  TDialog.HandleEvent(Event);
end;

procedure TKlasaDialog.Store;
begin
  inherited Store(S);
  PutSubViewPtr(S, NumerInputLine);
  PutSubViewPtr(S, NumerLabel);
  PutSubViewPtr(S, LiteraInputLine);
  PutSubViewPtr(S, LiteraLabel);
  PutSubViewPtr(S, IloscGrupRadioButtons);
  PutSubViewPtr(S, IloscGrupLabel);
end;

{ TChooseGrupaKlasyDialog }

constructor TChooseGrupaKlasyDialog.Load;
begin
  inherited Load(S);
  GetSubViewPtr(S, GrupaRadioButtons);
  GetSubViewPtr(S, GrupaLabel);
end;

procedure TChooseGrupaKlasyDialog.Store;
begin
  inherited Store(S);
  PutSubViewPtr(S, GrupaRadioButtons);
  PutSubViewPtr(S, GrupaLabel);
end;


{ *** }

procedure RegisterKlasa;
begin
  RegisterType(RKlasa);
  RegisterType(RKlasaDialog);
  RegisterType(RNumerValidator);
  RegisterType(RLiteraValidator);
  RegisterType(RChooseGrupaKlasyDialog);
end;

begin
  Klasy:=nil;
end.
