Unit Sala;

interface
uses Objects, Drivers, Views, Dialogs, Validate, MsgBox,
     DataObjects, DataDialogs,
     Stale;

type { Typ opisuj¥cy sal© }
  PSala = ^TSala;
  TSala = object (TDataObject)
  private
    FNazwaSali: String[slNazwaSali];
    FNumerSali: String[slNumerSali];
  public
    constructor Init;
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function Compare(Data: PDataObject): Integer; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    procedure GetNazwa(var NazwaSali: String);
    procedure GetNumer(var NumerSali: String);
    procedure SetNazwa(const NazwaSali: String);
    procedure SetNumer(const NumerSali: String);
    procedure Store(var S: TStream); virtual;
  end;

type { Typ opisuj¥cy walidator nazwy sali }
  PNazwaSaliValidator = ^TNazwaSaliValidator;
  TNazwaSaliValidator = object (TValidator)
    function IsValid(const S: string): Boolean; virtual;
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
    procedure Error; virtual;
  end;

type { Typ opisuj¥cy walidator numeru sali }
  PNumerSaliValidator = ^TNumerSaliValidator;
  TNumerSaliValidator = object (TValidator)
    function IsValid(const S: string): Boolean; virtual;
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
    procedure Error; virtual;
  end;

type { Typ opisuj¥cy okno wprowadzania danych sali }
  PSalaDialog = ^TSalaDialog;
  TSalaDialog = object (TDataDialog)
  private
    FNazwaSaliInputLine: PInputLine;
    FNumerSaliInputLine: PInputLine;
    FNazwaSaliLabel: PLabel;
    FNumerSaliLabel: PLabel;
  public
    constructor Init(ATitle: TTitleStr);
    constructor Load(var S: TStream);
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { Typ opisuj¥cy okno wyboru sali z listy }
  PChooseSalaDialog = ^TChooseSalaDialog;
  TChooseSalaDialog = object (TChooseDataDialog)
    constructor Init;
  end;

function ChooseSala(List: PDataCollection; ShowHelpButton: Boolean): Integer;

const { Staˆe do rejestracji typ¢w w strumieniach }
  RSala: TStreamRec = (
    ObjType: $1300;
    VmtLink: Ofs(TypeOf(TSala)^);
    Load   : @TSala.Load;
    Store  : @TSala.Store);
  RNazwaSaliValidator: TStreamRec = (
    ObjType: $1301;
    VmtLink: Ofs(TypeOf(TNazwaSaliValidator)^);
    Load   : @TNazwaSaliValidator.Load;
    Store  : @TNazwaSaliValidator.Store);
  RNumerSaliValidator: TStreamRec = (
    ObjType: $1302;
    VmtLink: Ofs(TypeOf(TNumerSaliValidator)^);
    Load   : @TNumerSaliValidator.Load;
    Store  : @TNumerSaliValidator.Store);
  RSalaDialog: TStreamRec = (
    ObjType: $1303;
    VmtLink: Ofs(TypeOf(TSalaDialog)^);
    Load   : @TSalaDialog.Load;
    Store  : @TSalaDialog.Store);
  RChooseSalaDialog: TStreamRec = (
    ObjType: $1304;
    VmtLink: Ofs(TypeOf(TChooseSalaDialog)^);
    Load   : @TChooseSalaDialog.Load;
    Store  : @TChooseSalaDialog.Store);

procedure RegisterSala;

var Sale: PDataCollection;

implementation
uses App, Latin2;

  { TSala }

constructor TSala.Init;
begin
  inherited Init;
  FNazwaSali:='';
  FNumerSali:='';
end;

constructor TSala.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(FNazwaSali, SizeOf(FNazwaSali));
  S.Read(FNumerSali, SizeOf(FNumerSali));
end;

destructor TSala.Done;
begin
  FNazwaSali:='';
  FNumerSali:='';
  inherited Done;
end;

function TSala.Compare(Data: PDataObject): Integer;
var
  OldCompare: Integer;
  S1, S2: String;
  Index1, Index2: LongInt;
begin
  GetIndex(Index1); Data^.GetIndex(Index2);
  if (Index1<>-1) and (Index2<>-1) then OldCompare:=inherited Compare(Data)
  else OldCompare:=-1;

  if OldCompare=0 then Compare:=0
  else
  begin
    GetNumer(S1); PSala(Data)^.GetNumer(S2);
    Compare:=CompareStr(S1, S2, False);
  end;
end;

function TSala.GetText(MaxLen: Integer): String;
var S1, S2: String;
begin
  GetNazwa(S1); GetNumer(S2);
  if Length(S2)<slNumerSali then S2:=S2+SpaceStr(slNumerSali-Length(S2));
  if S1<>'' then S2:=S2+' - '+S1;
  GetText:=Copy(S2, 1, MaxLen);
end;

procedure TSala.GetNazwa(var NazwaSali: String);
begin
  NazwaSali:=FNazwaSali;
end;

procedure TSala.GetNumer(var NumerSali: String);
begin
  NumerSali:=FNumerSali;
end;

procedure TSala.SetNazwa(const NazwaSali: String);
begin
  FNazwaSali:=NazwaSali;
end;

procedure TSala.SetNumer(const NumerSali: String);
begin
  FNumerSali:=NumerSali;
end;

procedure TSala.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(FNazwaSali, SizeOf(FNazwaSali));
  S.Write(FNumerSali, SizeOf(FNumerSali));
end;


  { TNazwaSaliValidator }

function TNazwaSaliValidator.IsValid(const S: string): Boolean;
begin
  IsValid:=True;
end;

function TNazwaSaliValidator.IsValidInput(var S: string; SuppressFill: Boolean): Boolean;
begin
  if S<>'' then S[1]:=UpCase(S[1]);
  IsValidInput:=True;
end;

procedure TNazwaSaliValidator.Error;
begin
  MessageBox(#3'Musisz poda† nazw© sali',
              nil,
              mfError or mfCancelButton);
end;


  { TNumerSaliValidator }

function TNumerSaliValidator.IsValid(const S: string): Boolean;
var I: Integer;
begin
  if S='' then IsValid:=False
  else
  begin
    I:=Pos(S[1], '0123456789');
    if I=0 then IsValid:=False
    else IsValid:=True;
  end
end;

function TNumerSaliValidator.IsValidInput(var S: string; SuppressFill: Boolean): Boolean;
var I: Integer;
begin
  if S<>'' then
  begin
    I:=Pos(S[1], '0123456789');
    if I=0 then
    begin
      IsValidInput:=False;
      Exit;
    end;
    for I:=1 to Length(S) do
    begin
      S[I]:=LowCase(S[I]);
    end;
  end;
  IsValidInput:=True;
end;

procedure TNumerSaliValidator.Error;
begin
  MessageBox(#3'Musisz poda† numer sali (max. 5 znak¢w, pierwsza cyfra)',
              nil,
              mfError or mfCancelButton);
end;


  { TSalaDialog }

constructor TSalaDialog.Init(ATitle: TTitleStr);
var R: TRect;
begin
  R.Assign(0, 0, 60, 10);
  Inherited Init(R, ATitle);

  R.Assign(3, 3, 3+slNumerSali+2, 4);
  New(FNumerSaliInputLine, Init(R, slNumerSali));
  FNumerSaliInputLine^.SetValidator(New(PNumerSaliValidator, Init));
  Insert(FNumerSaliInputLine);

  R.Assign(2, 2, Size.X-18, 3);
  New(FNumerSaliLabel, Init(R, 'N~u~mer', FNumerSaliInputLine));
  Insert(FNumerSaliLabel);

  R.Assign(3, 5, Size.X-18, 6);
  New(FNazwaSaliInputLine, Init(R, slNazwaSali));
  FNazwaSaliInputLine^.SetValidator(New(PNazwaSaliValidator, Init));
  Insert(FNazwaSaliInputLine);

  R.Assign(2, 4, Size.X-18, 5);
  New(FNazwaSaliLabel, Init(R, '~N~azwa sali', FNazwaSaliInputLine));
  Insert(FNazwaSaliLabel);

  FNumerSaliInputLine^.Select;
  HelpCtx:=$1041;
end;

constructor TSalaDialog.Load(var S: TStream);
begin
  inherited Load(S);
  GetSubViewPtr(S, FNazwaSaliInputLine);
  GetSubViewPtr(S, FNumerSaliInputLine);
  GetSubViewPtr(S, FNazwaSaliLabel);
  GetSubViewPtr(S, FNumerSaliLabel);
end;

procedure TSalaDialog.GetData(var Rec);
var S: String;
begin
  FNazwaSaliInputLine^.GetData(S);
  PSala(Rec)^.SetNazwa(S);
  FNumerSaliInputLine^.GetData(S);
  PSala(Rec)^.SetNumer(S);
end;

procedure TSalaDialog.SetData(var Rec);
var S: String;
begin
  PSala(Rec)^.GetNazwa(S);
  FNazwaSaliInputLine^.SetData(S);
  PSala(Rec)^.GetNumer(S);
  FNumerSaliInputLine^.SetData(S);
end;

procedure TSalaDialog.Store(var S: TStream);
begin
  inherited Store(S);
  PutSubViewPtr(S, FNazwaSaliInputLine);
  PutSubViewPtr(S, FNumerSaliInputLine);
  PutSubViewPtr(S, FNazwaSaliLabel);
  PutSubViewPtr(S, FNumerSaliLabel);
end;


  { TChooseSalaDialog }

constructor TChooseSalaDialog.Init;
begin
  inherited Init('Wybierz sal©', 'Sala', '~L~ista sal', 1);
  HelpCtx:=$1043;
end;


function ChooseSala(List: PDataCollection; ShowHelpButton: Boolean): Integer;
var
  Dialog: PChooseSalaDialog;
  Index: Integer;
begin
  if (not Assigned(List)) or (List^.Count=0) then
  begin
    MessageBox(#3'Spis dost©pnych sal jest pusty !',
               nil,
               mfError or mfCancelButton);
    ChooseSala:=-1;
  end
  else
  begin
    New(Dialog, Init);
    Dialog^.SetList(List);
    if ShowHelpButton then Dialog^.ShowHelpButton
    else Dialog^.HideHelpButton;
    if Application^.ExecuteDialog(Dialog, @Index)<>cmCancel then
    begin
      ChooseSala:=Index;
    end
    else ChooseSala:=-1;
  end;
end;

procedure RegisterSala;
begin
  RegisterType(RSala);
  RegisterType(RNazwaSaliValidator);
  RegisterType(RNumerSaliValidator);
  RegisterType(RSalaDialog);
  RegisterType(RChooseSalaDialog);
end;

begin
  Sale:=nil;
  RegisterSala;
end.
