Unit Dzwonek;

interface
uses
  Objects, Drivers, Views, Dialogs, Menus, Validate,
  DataObjects, DataDialogs, Stale;

type { typ opiusuj¥cy dzwonek }
  PDzwonek = ^TDzwonek;
  TDzwonek = object (TDataObject)
    Poczatek: LongInt;
    Dlugosc: Integer;
    constructor Load(var S: TStream);
    function Compare(Data: PDataObject): Integer; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    procedure Assign(Data: PDataObject); virtual;
    procedure Clear; virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj¥cy walidator pocz¥tku lekcji }
  PPoczatekValidator = ^TPoczatekValidator;
  TPoczatekValidator = object (TValidator)
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
    function IsValid(const S: string): Boolean; virtual;
    procedure Error; virtual;
  end;

type { typ opisuj¥cy walidator dˆugo˜† lekcji }
  PDlugoscValidator = ^TDlugoscValidator;
  TDlugoscValidator = object (TValidator)
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
    function IsValid(const S: string): Boolean; virtual;
    procedure Error; virtual;
  end;

type { typ opisuj¥cy okno edycji danych dzwonka }
  PDzwonekDialog = ^TDzwonekDialog;
  TDzwonekDialog = object (TDataDialog)
    PoczatekInputLine: PInputLine;
    PoczatekLabel: PLabel;
    DlugoscInputLine: PInputLine;
    DlugoscLabel: PLabel;
    constructor Load(var S: TStream);
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream); virtual;
  end;

const
  RDzwonek: TStreamRec = (
    ObjType: $6000;
    VmtLink: Ofs(TypeOf(TDzwonek)^);
    Load   : @TDzwonek.Load;
    Store  : @TDzwonek.Store);
  RDzwonekDialog: TStreamRec = (
    ObjType: $6001;
    VmtLink: Ofs(TypeOf(TDzwonekDialog)^);
    Load   : @TDzwonekDialog.Load;
    Store  : @TDzwonekDialog.Store);
  RPoczatekValidator: TStreamRec = (
    ObjType: $6002;
    VmtLink: Ofs(TypeOf(TPoczatekValidator)^);
    Load   : @TPoczatekValidator.Load;
    Store  : @TPoczatekValidator.Store);
  RDlugoscValidator: TStreamRec = (
    ObjType: $6003;
    VmtLink: Ofs(TypeOf(TDlugoscValidator)^);
    Load   : @TDlugoscValidator.Load;
    Store  : @TDlugoscValidator.Store);

var
  Dzwonki: PDataCollection;

procedure RegisterDzwonek;

implementation
uses
  Latin2, MsgBox;

{ TDzwonek }

constructor TDzwonek.Load;
begin
  inherited Load(S);
  S.Read(Poczatek, SizeOf(Poczatek));
  S.Read(Dlugosc, SizeOf(Dlugosc));
end;

function TDzwonek.Compare;
begin
  if inherited Compare(Data)=0 then Compare:=0
  else if Poczatek<PDzwonek(Data)^.Poczatek then Compare:=-1
  else if Poczatek>PDzwonek(Data)^.Poczatek then Compare:=1
  else Compare:=0
end;

function TDzwonek.GetText;
var
  S, S1, S2: String;
begin
  Str(Poczatek div 60, S1); while Length(S1)<2 do S1:='0'+S1;
  Str(Poczatek mod 60, S2); while Length(S2)<2 do S2:='0'+S2;
  S:=S1+':'+S2;
  Str((Poczatek+Dlugosc) div 60, S1); while Length(S1)<2 do S1:='0'+S1;
  Str((Poczatek+Dlugosc) mod 60, S2); while Length(S1)<2 do S1:='0'+S1;
  S:=S+' - '+S1+':'+S2;
  GetText:=Copy(S, 1, MaxLen);
end;

procedure TDzwonek.Assign;
begin
  inherited Assign(Data);
  Poczatek:=PDzwonek(Data)^.Poczatek;
  Dlugosc:=PDzwonek(Data)^.Dlugosc;
end;

procedure TDzwonek.Clear;
begin
  Poczatek:=8*60;
  Dlugosc:=45;
end;

procedure TDzwonek.Store;
begin
  inherited Store(S);
  S.Write(Poczatek, SizeOf(Poczatek));
  S.Write(Dlugosc, SizeOf(Dlugosc));
end;

{ TPoczatekValidator }

function TPoczatekValidator.IsValidInput;
var
  I: Integer;
begin
  IsValidInput:=True;
  if S='' then Exit;
  for I:=1 to Length(S) do
  begin
    case I of
      1,2, 4,5: if Pos(S[I], '0123456789')=0 then
      begin
        IsValidInput:=False;
        Exit;
      end;
      3: S[I]:=':';
    end;
  end;
end;

function TPoczatekValidator.IsValid;
var
  G, M, E: Integer;
begin
  IsValid:=True;
  if Length(S)<5 then IsValid:=False
  else
  begin
    Val(S[1]+S[2], G, E);
    if (E<>0) or (G>23) then IsValid:=False;
    Val(S[4]+S[5], M, E);
    if (E<>0) or (M>59) then IsValid:=False;
  end;
end;

procedure TPoczatekValidator.Error;
begin
  MessageBox(#3'Nale¾y poda† poprawn¥ godzin© pocz¥tkow¥ w formacie GG:MM', nil, mfError or mfCancelButton);
end;

{ TDlugoscValidator }

function TDlugoscValidator.IsValidInput;
var
  I: Integer;
begin
  IsValidInput:=True;
  if S='' then Exit;
  for I:=1 to Length(S) do if Pos(S[I], '0123456789')=0 then
  begin
    IsValidInput:=False;
    Exit;
  end;
end;

function TDlugoscValidator.IsValid;
var
  L, E: Integer;
begin
  IsValid:=True;
  if S='' then IsValid:=False
  else
  begin
    Val(S, L, E);
    if (E<>0) or (L<30) then IsValid:=False;
  end;
end;

procedure TDlugoscValidator.Error;
begin
  MessageBox(#3'Nale¾y poda† dˆugo˜† trwania lekcji (>=30 min)', nil, mfError or mfCancelButton);
end;

{ TDzwonekDialog }

constructor TDzwonekDialog.Load;
begin
  inherited Load(S);
  GetSubViewPtr(S, PoczatekInputLine);
  GetSubViewPtr(S, PoczatekLabel);
  GetSubViewPtr(S, DlugoscInputLine);
  GetSubViewPtr(S, DlugoscLabel);
end;

procedure TDzwonekDialog.GetData;
var
  S: String;
  L: LongInt;
  E: Integer;
begin
  with TDzwonek(Rec) do
  begin
    PoczatekInputLine^.GetData(S);
    Val(S[1]+S[2], L, E);
    Poczatek:=60*L;
    Val(S[4]+S[5], L, E);
    Poczatek:=Poczatek+L;
    DlugoscInputLine^.GetData(S);
    Val(S, L, E);
    Dlugosc:=L;
  end;
end;

procedure TDzwonekDialog.SetData;
var
  S: String;
begin
  with TDzwonek(Rec) do
  begin
    S:=GetText(5);
    PoczatekInputLine^.SetData(S);
    Str(Dlugosc, S);
    DlugoscInputLine^.SetData(S);
  end;
end;

procedure TDzwonekDialog.Store;
begin
  inherited Store(S);
  PutSubViewPtr(S, PoczatekInputLine);
  PutSubViewPtr(S, PoczatekLabel);
  PutSubViewPtr(S, DlugoscInputLine);
  PutSubViewPtr(S, DlugoscLabel);
end;

{ *** }

procedure RegisterDzwonek;
begin
  RegisterType(RDzwonek);
  RegisterType(RDzwonekDialog);
  RegisterType(RPoczatekValidator);
  RegisterType(RDlugoscValidator);
end;

begin
  Dzwonki:=nil;
end.
