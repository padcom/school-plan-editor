Unit Klasa;

interface
uses Objects, Drivers, Views, Dialogs, Validate, MsgBox,
     DataObjects, DataDialogs,
     Stale;

type { Typ opisuj¥cy klas© }
  PKlasa = ^TKlasa;
  TKlasa = object (TDataObject)
  private
    FNumer: Byte;
    FLitera: Char;
  public
    FIloscGrup: Word;
    EnableGroupMask: Word;
    constructor Init;
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function Compare(Data: PDataObject): Integer; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    procedure GetIloscGrup(var IloscGrup: Word);
    procedure GetLitera(var Litera: String);
    procedure GetNumer(var Numer: String);
    procedure SetIloscGrup(const IloscGrup: Word);
    procedure SetLitera(const Litera: String);
    procedure SetNumer(const Numer: String);
    procedure Store(var S: TStream); virtual;
  end;

type { Typ opisuj¥cy walidator numeru klasy }
  PNumerKlasyValidator = ^TNumerKlasyValidator;
  TNumerKlasyValidator = object (TValidator)
    function IsValid(const S: string): Boolean; virtual;
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
    procedure Error; virtual;
  end;

type { Typ opisuj¥cy walidator litery klasy }
  PLiteraKlasyValidator = ^TLiteraKlasyValidator;
  TLiteraKlasyValidator = object (TValidator)
    function IsValid(const S: string): Boolean; virtual;
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
    procedure Error; virtual;
  end;

type { Typ opisuj¥cy okno edycji klasy }
  PKlasaDialog = ^TKlasaDialog;
  TKlasaDialog = object (TDataDialog)
  private
    FNumerKlasyInputLine: PInputLine;
    FLiteraKlasyInputLine: PInputLine;
    FIloscGrupRadioButtons: PRadioButtons;
    FNumerKlasyLabel: PLabel;
    FLiteraKlasyLabel: PLabel;
    FIloscGrupLabel: PLabel;
  public
    constructor Init(ATitle: TTitleStr);
    constructor Load(var S: TStream);
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { Typ opisuj¥cy okno wyboru klasy z listy }
  PChooseKlasaDialog = ^TChooseKlasaDialog;
  TChooseKlasaDialog = object (TChooseDataDialog)
    constructor Init;
  end;

function ChooseKlasa(List: PDataCollection; ShowHelpButton: Boolean): Integer;

const { Staˆe do rejestracji typ¢w w strumieniach }
  RKlasa: TStreamRec = (
    ObjType: $1200;
    VmtLink: Ofs(TypeOf(TKlasa)^);
    Load   : @TKlasa.Load;
    Store  : @TKlasa.Store);
  RNumerKlasyValidator: TStreamRec = (
    ObjType: $1201;
    VmtLink: Ofs(TypeOf(TNumerKlasyValidator)^);
    Load   : @TNumerKlasyValidator.Load;
    Store  : @TNumerKlasyValidator.Store);
  RLiteraKlasyValidator: TStreamRec = (
    ObjType: $1202;
    VmtLink: Ofs(TypeOf(TLiteraKlasyValidator)^);
    Load   : @TLiteraKlasyValidator.Load;
    Store  : @TLiteraKlasyValidator.Store);
  RKlasaDialog: TStreamRec = (
    ObjType: $1203;
    VmtLink: Ofs(TypeOf(TKlasaDialog)^);
    Load   : @TKlasaDialog.Load;
    Store  : @TKlasaDialog.Store);
  RChooseKlasaDialog: TStreamRec = (
    ObjType: $1204;
    VmtLink: Ofs(TypeOf(TChooseKlasaDialog)^);
    Load   : @TChooseKlasaDialog.Load;
    Store  : @TChooseKlasaDialog.Store);

procedure RegisterKlasa;
function IncPower2(N: Byte): Word;

var Klasy: PDataCollection;

implementation
uses App, Latin2;

function IncPower2(N: Byte): Word;
var
  T: Word;
begin
  T:=0;
  while N>0 do
  begin
    T:=T shl 1+1;
    Dec(N);
  end;
  IncPower2:=T;
end;


constructor TKlasa.Init;
begin
  inherited Init;
  FNumer:=1;
  FLitera:='A';
  FIloscGrup:=1;
  EnableGroupMask:=511;
end;

constructor TKlasa.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(FNumer, SizeOf(FNumer));
  S.Read(FLitera, SizeOf(FLitera));
  S.Read(FIloscGrup, SizeOf(FIloscGrup));
  EnableGroupMask:=511;
end;

destructor TKlasa.Done;
begin
  FNumer:=0;
  FLitera:='a';
  FIloscGrup:=1;
  EnableGroupMask:=$FFFF;
  inherited Done;
end;

function TKlasa.Compare(Data: PDataObject): Integer;
var
  OldCompare: Integer;
  Numer1, Numer2: String;
  Litera1, Litera2: String;
  Index1, Index2: LongInt;
begin
  GetIndex(Index1); Data^.GetIndex(Index2);
  if (Index1<>-1) and (Index2<>-1) then OldCompare:=inherited Compare(Data)
  else OldCompare:=-1;

  if OldCompare=0 then Compare:=0
  else
  begin
    GetNumer(Numer1); PKlasa(Data)^.GetNumer(Numer2);
    GetLitera(Litera1); PKlasa(Data)^.GetLitera(Litera2);
    if Numer1<Numer2 then Compare:=-1
    else if Numer1>Numer2 then Compare:=1
    else if Litera1<Litera2 then Compare:=-1
    else if Litera1>Litera2 then Compare:=1
    else Compare:=0;
  end;
end;

function TKlasa.GetText(MaxLen: Integer): String;
var Numer, Litera: String;
begin
  GetNumer(Numer); GetLitera(Litera);
  GetText:=Copy(Numer+Litera, 1, MaxLen);
end;

procedure TKlasa.GetIloscGrup(var IloscGrup: Word);
begin
  IloscGrup:=FIloscGrup;
end;

procedure TKlasa.GetLitera(var Litera: String);
begin
  Litera:=FLitera;
end;

procedure TKlasa.GetNumer(var Numer: String);
begin
  Str(FNumer, Numer);
end;

procedure TKlasa.SetIloscGrup(const IloscGrup: Word);
begin
  FIloscGrup:=IloscGrup;
end;

procedure TKlasa.SetLitera(const Litera: String);
begin
  if Length(Litera)=1 then FLitera:=Litera[1];
end;

procedure TKlasa.SetNumer(const Numer: String);
var Error, Temp: Word;
begin
  Val(Numer, Temp, Error);
  if Error=0 then FNumer:=Temp;
end;

procedure TKlasa.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(FNumer, SizeOf(FNumer));
  S.Write(FLitera, SizeOf(FLitera));
  S.Write(FIloscGrup, SizeOf(FIloscGrup));
end;


  { TNumerKlasyValidator }

function TNumerKlasyValidator.IsValid(const S: string): Boolean;
var Temp, ErrorCode: Word;
begin
  Val(S, Temp, ErrorCode);
  If (S='') or (ErrorCode<>0) then IsValid:=False
  else IsValid:=True;
end;

function TNumerKlasyValidator.IsValidInput(var S: string; SuppressFill: Boolean): Boolean;
var Temp, ErrorCode: Word;
begin
  Val(S, Temp, ErrorCode);
  If (ErrorCode<>0) and (S<>'') then IsValidInput:=False
  else IsValidInput:=True;
end;

procedure TNumerKlasyValidator.Error;
begin
  MessageBox(#3'Musisz poda† numer klasy',
              nil,
              mfError or mfCancelButton);
end;


  { TLiteraKlasyValidator }

function TLiteraKlasyValidator.IsValid(const S: string): Boolean;
begin
  if S<>'' then IsValid:=True else IsValid:=False;
end;

function TLiteraKlasyValidator.IsValidInput(var S: string; SuppressFill: Boolean): Boolean;
begin
  if (S<>'') then
  begin
    S[1]:=UpCase(S[1]);
    if not (S[1] in ['A'..'Z']) then S:=''
  end;
  IsValidInput:=True;
end;

procedure TLiteraKlasyValidator.Error;
begin
  MessageBox(#3'Musisz poda† liter© klasy',
              nil,
              mfError or mfCancelButton);
end;

  { TKlasaDialog }

constructor TKlasaDialog.Init(ATitle: TTitleStr);
var R: TRect;
begin
  R.Assign(0, 0, 57, 10);
  inherited Init(R, ATitle);

  R.Assign(3, 3, 10, 4);
  New(FNumerKlasyInputLine, Init(R, 5));
  FNumerKlasyInputLine^.SetValidator(New(PNumerKlasyValidator, Init));
  Insert(FNumerKlasyInputLine);

  R.Assign(2, 2, 15, 3);
  New(FNumerKlasyLabel, Init(R, '~N~umer klasy', FNumerKlasyInputLine));
  Insert(FNumerKlasyLabel);

  R.Assign(17, 3, 20, 4);
  New(FLiteraKlasyInputLine, Init(R, 1));
  FLiteraKlasyInputLine^.SetValidator(New(PLiteraKlasyValidator, Init));
  Insert(FLiteraKlasyInputLine);

  R.Assign(16, 2, 30, 3);
  New(FLiteraKlasyLabel, Init(R, '~L~itera klasy', FLiteraKlasyInputLine));
  Insert(FLiteraKlasyLabel);

  R.Assign(3, 5, Size.X-18, 7);
  New(FIloscGrupRadioButtons, Init(R,
    NewSItem('~1~', NewSItem('~2~',
    NewSItem('~3~', NewSItem('~4~',
    NewSItem('~5~', NewSItem('~6~',
    NewSItem('~7~', NewSItem('~8~',
    NewSItem('~9~',
  nil)))))))))));
  Insert(FIloscGrupRadioButtons);

  R.Assign(2, 4, Size.X-18, 5);
  New(FIloscGrupLabel, Init(R, '~I~lo˜† grup', FIloscGrupRadioButtons));
  Insert(FIloscGrupLabel);

  FNumerKlasyInputLine^.Select;
  HelpCtx:=$1031;
end;

constructor TKlasaDialog.Load(var S: TStream);
begin
  inherited Load(S);
  GetSubViewPtr(S, FNumerKlasyInputLine);
  GetSubViewPtr(S, FLiteraKlasyInputLine);
  GetSubViewPtr(S, FIloscGrupRadioButtons);
  GetSubViewPtr(S, FNumerKlasyLabel);
  GetSubViewPtr(S, FLiteraKlasyLabel);
  GetSubViewPtr(S, FIloscGrupLabel);
end;

procedure TKlasaDialog.GetData(var Rec);
var
  W: Word;
  S: String;
begin
  FNumerKlasyInputLine^.GetData(S);
  PKlasa(Rec)^.SetNumer(S);
  FLiteraKlasyInputLine^.GetData(S);
  PKlasa(Rec)^.SetLitera(S);
  FIloscGrupRadioButtons^.GetData(W);
  Inc(W);
  PKlasa(Rec)^.SetIloscGrup(W);
  PKlasa(Rec)^.EnableGroupMask:=IncPower2(PKlasa(Rec)^.FIloscGrup);
end;

procedure TKlasaDialog.SetData(var Rec);
var
  W: Word;
  S: String;
begin
  PKlasa(Rec)^.GetNumer(S);
  FNumerKlasyInputLine^.SetData(S);
  PKlasa(Rec)^.GetLitera(S);
  FLiteraKlasyInputLine^.SetData(S);
  PKlasa(Rec)^.GetIloscGrup(W);
  Dec(W);
  FIloscGrupRadioButtons^.SetData(W);
end;

procedure TKlasaDialog.Store(var S: TStream);
begin
  inherited Store(S);
  PutSubViewPtr(S, FNumerKlasyInputLine);
  PutSubViewPtr(S, FLiteraKlasyInputLine);
  PutSubViewPtr(S, FIloscGrupRadioButtons);
  PutSubViewPtr(S, FNumerKlasyLabel);
  PutSubViewPtr(S, FLiteraKlasyLabel);
  PutSubViewPtr(S, FIloscGrupLabel);
end;


  { TChooseKlasaDialog }

constructor TChooseKlasaDialog.Init;
begin
  inherited Init('Wybierz klas©', 'Klasa', '~L~ista klas', 3);
  HelpCtx:=$1033;
end;


function ChooseKlasa(List: PDataCollection; ShowHelpButton: Boolean): Integer;
var
  Dialog: PChooseKlasaDialog;
  Index: Integer;
begin
  if (not Assigned(List)) or (List^.Count=0) then
  begin
    MessageBox(#3'Spis dost©pnych klas jest pusty !',
               nil,
               mfError or mfCancelButton);
    ChooseKlasa:=-1;
  end
  else
  begin
    New(Dialog, Init);
    Dialog^.SetList(List);
    if ShowHelpButton then Dialog^.ShowHelpButton
    else Dialog^.HideHelpButton;
    if Application^.ExecuteDialog(Dialog, @Index)<>cmCancel then
    begin
      ChooseKlasa:=Index;
    end
    else ChooseKlasa:=-1;
  end;
end;

procedure RegisterKlasa;
begin
  RegisterType(RKlasa);
  RegisterType(RNumerKlasyValidator);
  RegisterType(RLiteraKlasyValidator);
  RegisterType(RKlasaDialog);
  RegisterType(RChooseKlasaDialog);
end;


begin
  Klasy:=nil;
  RegisterKlasa;
end.

