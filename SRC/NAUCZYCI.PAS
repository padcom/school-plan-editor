unit Nauczyciel;

interface
uses Objects, Drivers, Views, Dialogs, Validate, MsgBox,
     DataObjects, DataDialogs,
     Stale;

type { Typ opisuj¥cy nauczyciela }
  PNauczyciel = ^TNauczyciel;
  TNauczyciel = object (TDataObject)
  private
    FImieNazwisko: String[slImieNazwisko];
    FSkrot: String[slSkrot];
  public
    constructor Init;
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function Compare(Data: PDataObject): Integer; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    procedure GetImieNazwisko(var ImieNazwisko: String);
    procedure GetSkrot(var Skrot: String);
    procedure SetImieNazwisko(const ImieNazwisko: String);
    procedure SetSkrot(const Skrot: String);
    procedure Store(var S: TStream); virtual;
  end;

type { Typ opisuj¥cy walidator imienia i nazwiska }
  PImieNazwiskoValidator = ^TImieNazwiskoValidator;
  TImieNazwiskoValidator = object (TValidator)
    function IsValid(const S: string): Boolean; virtual;
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
    procedure Error; virtual;
  end;

type { Typ opisuj¥cy walidator skr¢tu }
  PSkrotValidator = ^TSkrotValidator;
  TSkrotValidator = object (TValidator)
    function IsValid(const S: string): Boolean; virtual;
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
    procedure Error; virtual;
  end;

type { Typ opisuj¥cy okno wprowadzania danych nauczyciela }
  PNauczycielDialog = ^TNauczycielDialog;
  TNauczycielDialog = object (TDataDialog)
  private
    FImieNazwiskoInputLine: PInputLine;
    FSkrotInputLine: PInputLine;
    FImieNazwiskoLabel: PLabel;
    FSkrotLabel: PLabel;
  public
    constructor Init(ATitle: TTitleStr);
    constructor Load(var S: TStream);
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { Typ opisuj¥cy okno wyboru nauczyciela z listy }
  PChooseNauczycielDialog = ^TChooseNauczycielDialog;
  TChooseNauczycielDialog = object (TChooseDataDialog)
    constructor Init;
  end;

function ChooseNauczyciel(List: PDataCollection; ShowHelpButton: Boolean): Integer;

const { Staˆe do rejestracji typ¢w w strumieniach }
  RNauczyciel: TStreamRec = (
    ObjType: $1000;
    VmtLink: Ofs(TypeOf(TNauczyciel)^);
    Load   : @TNauczyciel.Load;
    Store  : @TNauczyciel.Store);
  RImieNazwiskoValidator: TStreamRec = (
    ObjType: $1001;
    VmtLink: Ofs(TypeOf(TImieNazwiskoValidator)^);
    Load   : @TImieNazwiskoValidator.Load;
    Store  : @TImieNazwiskoValidator.Store);
  RSkrotValidator: TStreamRec = (
    ObjType: $1002;
    VmtLink: Ofs(TypeOf(TSkrotValidator)^);
    Load   : @TSkrotValidator.Load;
    Store  : @TSkrotValidator.Store);
  RNauczycielDialog: TStreamRec = (
    ObjType: $1003;
    VmtLink: Ofs(TypeOf(TNauczycielDialog)^);
    Load   : @TNauczycielDialog.Load;
    Store  : @TNauczycielDialog.Store);
  RChooseNauczycielDialog: TStreamRec = (
    ObjType: $1004;
    VmtLink: Ofs(TypeOf(TChooseNauczycielDialog)^);
    Load   : @TChooseNauczycielDialog.Load;
    Store  : @TChooseNauczycielDialog.Store);

procedure RegisterNauczyciel;

var Nauczyciele: PDataCollection;

implementation
uses App, Latin2;

  { TNauczyciel }

constructor TNauczyciel.Init;
begin
  inherited Init;
  FImieNazwisko:='';
  FSkrot:='';
end;

constructor TNauczyciel.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(FImieNazwisko, SizeOf(FImieNazwisko));
  S.Read(FSkrot, SizeOf(FSkrot));
end;

destructor TNauczyciel.Done;
begin
  FImieNazwisko:='';
  FSkrot:='';
  inherited Done;
end;

function TNauczyciel.Compare(Data: PDataObject): Integer;
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
    S1:=GetText(255); S2:=Data^.GetText(255);
    Compare:=CompareStr(S1, S2, False);
  end;
end;

function TNauczyciel.GetText(MaxLen: Integer): String;
var S: String;
begin
  if MaxLen<=5 then GetSkrot(S)
  else GetImieNazwisko(S);
  GetText:=Copy(S, 1, MaxLen);
end;

procedure TNauczyciel.GetImieNazwisko(var ImieNazwisko: String);
begin
  ImieNazwisko:=FImieNazwisko;
end;

procedure TNauczyciel.GetSkrot(var Skrot: String);
begin
  Skrot:=FSkrot;
end;

procedure TNauczyciel.SetImieNazwisko(const ImieNazwisko: String);
begin
  FImieNazwisko:=ImieNazwisko;
end;

procedure TNauczyciel.SetSkrot(const Skrot: String);
begin
  FSkrot:=Skrot;
end;

procedure TNauczyciel.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(FImieNazwisko, SizeOf(FImieNazwisko));
  S.Write(FSkrot, SizeOf(FSkrot));
end;


  { TImieNazwiskoValidator }

function TImieNazwiskoValidator.IsValid(const S: string): Boolean;
begin
  if S='' then IsValid:=False
  else IsValid:=True;
end;

function TImieNazwiskoValidator.IsValidInput(var S: string; SuppressFill: Boolean): Boolean;
var
  I: Byte;
  C1, C2: Char;
begin
  if S<>'' then
  begin
    for I:=1 to Length(S)-1 do
    begin
      if I=1 then S[I]:=UpCase(S[I]);
      if S[I]=' ' then S[I+1]:=UpCase(S[I+1])
      else if S[I]<>' ' then S[I+1]:=LowCase(S[I+1]);
    end;
  end;
  IsValidInput:=True;
end;

procedure TImieNazwiskoValidator.Error;
begin
  MessageBox(#3'Musisz poda† imi© i nazwisko nauczyciela',
              nil,
              mfError or mfCancelButton);
end;


  { TSkrotValidator }

function TSkrotValidator.IsValid(const S: string): Boolean;
begin
  if S='' then IsValid:=False
  else IsValid:=True;
end;

function TSkrotValidator.IsValidInput(var S: string; SuppressFill: Boolean): Boolean;
var I: Integer;
begin
  if S<>'' then
  begin
    for I:=1 to Length(S) do
    begin
      S[I]:=UpCase(S[I]);
    end;
  end;
  IsValidInput:=True;
end;

procedure TSkrotValidator.Error;
begin
  MessageBox(#3'Musisz poda† skr¢t nauczyciela (max. 5 liter)',
              nil,
              mfError or mfCancelButton);
end;


  { TNauczycielDialog }

constructor TNauczycielDialog.Init(ATitle: TTitleStr);
var R: TRect;
begin
  R.Assign(0,0,60,10);
  inherited Init(R, ATitle);

  R.Assign(3, 3, Size.X-18, 4);
  New(FImieNazwiskoInputLine, Init(R, slImieNazwisko));
  Insert(FImieNazwiskoInputLine);

  R.Assign(2, 2, Size.X-18, 3);
  New(FImieNazwiskoLabel, Init(R, '~I~mi©, nazwisko', FImieNazwiskoLabel));
  FImieNazwiskoInputLine^.SetValidator(New(PImieNazwiskoValidator, Init));
  Insert(FImieNazwiskoLabel);

  R.Assign(3, 5, 3+slSkrot+2, 6);
  New(FSkrotInputLine, Init(R, slSkrot));
  FSkrotInputLine^.SetValidator(New(PSkrotValidator, Init));
  Insert(FSkrotInputLine);

  R.Assign(2, 4, Size.X-18, 5);
  New(FSkrotLabel, Init(R, '~S~kr¢t', FSkrotInputLine));
  Insert(FSkrotLabel);

  FImieNazwiskoInputLine^.Select;
  HelpCtx:=$1011;
end;

constructor TNauczycielDialog.Load(var S: TStream);
begin
  inherited Load(S);
  GetPeerViewPtr(S, FImieNazwiskoInputLine);
  GetPeerViewPtr(S, FSkrotInputLine);
  GetPeerViewPtr(S, FImieNazwiskoLabel);
  GetPeerViewPtr(S, FSkrotLabel);
end;

procedure TNauczycielDialog.GetData(var Rec);
var S: String;
begin
  FImieNazwiskoInputLine^.GetData(S);
  PNauczyciel(Rec)^.SetImieNazwisko(S);
  FSkrotInputLine^.GetData(S);
  PNauczyciel(Rec)^.SetSkrot(S);
end;

procedure TNauczycielDialog.SetData(var Rec);
var S: String;
begin
  PNauczyciel(Rec)^.GetImieNazwisko(S);
  FImieNazwiskoInputLine^.SetData(S);
  PNauczyciel(Rec)^.GetSkrot(S);
  FSkrotInputLine^.SetData(S);
end;

procedure TNauczycielDialog.Store(var S: TStream);
begin
  inherited Store(S);
  PutPeerViewPtr(S, FImieNazwiskoInputLine);
  PutPeerViewPtr(S, FSkrotInputLine);
  PutPeerViewPtr(S, FImieNazwiskoLabel);
  PutPeerViewPtr(S, FSkrotLabel);
end;

  { TChooseNauczycielDialog }

constructor TChooseNauczycielDialog.Init;
begin
  inherited Init('Wybierz nauczyciela', 'Nauczyciel', '~L~ista nauczycieli', 1);
  HelpCtx:=$1013;
end;


function ChooseNauczyciel(List: PDataCollection; ShowHelpButton: Boolean): Integer;
var
  Dialog: PChooseNauczycielDialog;
  Index: Integer;
begin
  if (not Assigned(List)) or (List^.Count=0) then
  begin
    MessageBox(#3'Spis dost©pnych nauczycieli jest pusty !',
               nil,
               mfError or mfCancelButton);
    ChooseNauczyciel:=-1;
  end
  else
  begin
    New(Dialog, Init);
    Dialog^.SetList(List);
    if ShowHelpButton then Dialog^.ShowHelpButton
    else Dialog^.HideHelpButton;
    if Application^.ExecuteDialog(Dialog, @Index)<>cmCancel then
    begin
      ChooseNauczyciel:=Index;
    end
    else ChooseNauczyciel:=-1;
  end;
end;

procedure RegisterNauczyciel;
begin
  RegisterType(RNauczyciel);
  RegisterType(RImieNazwiskoValidator);
  RegisterType(RSkrotValidator);
  RegisterType(RNauczycielDialog);
  RegisterType(RChooseNauczycielDialog);
end;

begin
  Nauczyciele:=nil;
  RegisterNauczyciel;
end.
