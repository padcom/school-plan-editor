Unit Klasa;

interface
uses
  Objects, Drivers, Views, Dialogs, Menus,
  DataObjects, DataDialogs, Stale;

type { typ opisuj¥cy klas© }
  PKlasa = ^TKlasa;
  TKlasa = object (TDataObject)
    Numer: Byte;
    Litera: Char;
    IloscGrup: Byte;
    Grupy: Word;
    constructor Load(var S: TStream);
    function Compare(Data: PDataObject): Integer; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    procedure Clear; virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj¥cy okno edycji danych klasy }
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
    procedure Store(var S: TStream); virtual;
  end;

const
  RKlasa: TStreamRec = (
    ObjType: $5000;
    VmtLink: Ofs(TypeOf(TKlasa)^);
    Load   : @TKlasa.Load;
    Store  : @TKlasa.Store);
  RKlasaDialog: TStreamRec = (
    ObjType: $5001;
    VmtLink: Ofs(TypeOf(TKlasaDialog)^);
    Load   : @TKlasaDialog.Load;
    Store  : @TKlasaDialog.Store);

procedure RegisterKlasa;

implementation
uses
  Latin2;

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

procedure TKlasa.Clear;
begin
  inherited Clear;
  Numer:=1;
  Litera:='A';
  IloscGrup:=1;
  Grupy:=$FFFF;
end;

procedure TKlasa.Store;
begin
  inherited Store(S);
  S.Write(Numer, SizeOf(Numer));
  S.Write(Litera, SizeOf(Litera));
  S.Write(IloscGrup, SizeOf(IloscGrup));
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
begin
end;

procedure TKlasaDialog.SetData;
begin
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

{ *** }

procedure RegisterKlasa;
begin
  RegisterType(RKlasa);
  RegisterType(RKlasaDialog);
end;

begin
end.
