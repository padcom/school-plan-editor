Unit Przedmiot;

interface
uses Objects, Drivers, Views, Dialogs, Validate, MsgBox,
     DataObjects, DataDialogs,
     Stale;

type { Typ opisuj¥cy przedmiot }
  PPrzedmiot = ^TPrzedmiot;
  TPrzedmiot = object (TDataObject)
  private
    FNazwa: String[slNazwaPrzedmiotu];
    FSkrot: String[slSkrot];
  public
    constructor Init;
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function Compare(Data: PDataObject): Integer; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    procedure GetNazwa(var NazwaPrzedmiotu: String);
    procedure GetSkrot(var Skrot: String);
    procedure SetNazwa(const NazwaPrzedmiotu: String);
    procedure SetSkrot(const Skrot: String);
    procedure Store(var S: TStream); virtual;
  end;

type { Typ opisuj¥cy walidator nazwy przedmiotu }
  PNazwaPrzedmiotuValidator = ^TNazwaPrzedmiotuValidator;
  TNazwaPrzedmiotuValidator = object (TValidator)
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

type { Typ opisuj¥cy okno wprowadzania danych przedmiotu }
  PPrzedmiotDialog = ^TPrzedmiotDialog;
  TPrzedmiotDialog = object (TDataDialog)
  private
    FNazwaPrzedmiotuInputLine: PInputLine;
    FSkrotInputLine: PInputLine;
    FNazwaPrzedmiotuLabel: PLabel;
    FSkrotLabel: PLabel;
  public
    constructor Init(ATitle: TTitleStr);
    constructor Load(var S: TStream);
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { Typ opisuj¥cy okno wyboru przedmiotu z listy }
  PChoosePrzedmiotDialog = ^TChoosePrzedmiotDialog;
  TChoosePrzedmiotDialog = object (TChooseDataDialog)
    constructor Init;
  end;

function ChoosePrzedmiot(List: PDataCollection; ShowHelpButton: Boolean): Integer;

const { Staˆe do rejestracji typ¢w w strumieniach }
  RPrzedmiot: TStreamRec = (
    ObjType: $1100;
    VmtLink: Ofs(TypeOf(TPrzedmiot)^);
    Load   : @TPrzedmiot.Load;
    Store  : @TPrzedmiot.Store);
  RNazwaPrzedmiotuValidator: TStreamRec = (
    ObjType: $1101;
    VmtLink: Ofs(TypeOf(TNazwaPrzedmiotuValidator)^);
    Load   : @TNazwaPrzedmiotuValidator.Load;
    Store  : @TNazwaPrzedmiotuValidator.Store);
  RSkrotValidator: TStreamRec = (
    ObjType: $1102;
    VmtLink: Ofs(TypeOf(TSkrotValidator)^);
    Load   : @TSkrotValidator.Load;
    Store  : @TSkrotValidator.Store);
  RPrzedmiotDialog: TStreamRec = (
    ObjType: $1103;
    VmtLink: Ofs(TypeOf(TPrzedmiotDialog)^);
    Load   : @TPrzedmiotDialog.Load;
    Store  : @TPrzedmiotDialog.Store);
  RChoosePrzedmiotDialog: TStreamRec = (
    ObjType: $1104;
    VmtLink: Ofs(TypeOf(TChoosePrzedmiotDialog)^);
    Load   : @TChoosePrzedmiotDialog.Load;
    Store  : @TChoosePrzedmiotDialog.Store);

procedure RegisterPrzedmiot;

var Przedmioty: PDataCollection;

implementation
uses App, Latin2;

  { TPrzedmiot }

constructor TPrzedmiot.Init;
begin
  inherited Init;
  FNazwa:='';
  FSkrot:='';
end;

constructor TPrzedmiot.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(FNazwa, SizeOf(FNazwa));
  S.Read(FSkrot, SizeOf(FSkrot));
end;

destructor TPrzedmiot.Done;
begin
  FNazwa:='';
  FSkrot:='';
  inherited Done;
end;

function TPrzedmiot.Compare(Data: PDataObject): Integer;
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

function TPrzedmiot.GetText(MaxLen: Integer): String;
var S: String;
begin
  if MaxLen<=5 then GetSkrot(S)
  else GetNazwa(S);
  GetText:=Copy(S, 1, MaxLen);
end;

procedure TPrzedmiot.GetNazwa(var NazwaPrzedmiotu: String);
begin
  NazwaPrzedmiotu:=FNazwa;
end;

procedure TPrzedmiot.GetSkrot(var Skrot: String);
begin
  Skrot:=FSkrot;
end;

procedure TPrzedmiot.SetNazwa(const NazwaPrzedmiotu: String);
begin
  FNazwa:=NazwaPrzedmiotu;
end;

procedure TPrzedmiot.SetSkrot(const Skrot: String);
begin
  FSkrot:=Skrot;
end;

procedure TPrzedmiot.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(FNazwa, SizeOf(FNazwa));
  S.Write(FSkrot, SizeOf(FSkrot));
end;


  { TNazwaPrzedmiotuValidator }

function TNazwaPrzedmiotuValidator.IsValid(const S: string): Boolean;
begin
  if S<>'' then IsValid:=True
  else IsValid:=False;
end;

function TNazwaPrzedmiotuValidator.IsValidInput(var S: string; SuppressFill: Boolean): Boolean;
begin
  if S<>'' then S[1]:=UpCase(S[1]);
  IsValidInput:=True;
end;

procedure TNazwaPrzedmiotuValidator.Error;
begin
  MessageBox(#3'Musisz poda† nazw© przedmiotu',
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
  MessageBox(#3'Musisz poda† skr¢t przedmiotu (max. 5 liter)',
              nil,
              mfError or mfCancelButton);
end;


  { TPrzedmiotDialog }

constructor TPrzedmiotDialog.Init(ATitle: TTitleStr);
var R: TRect;
begin
  R.Assign(0, 0, 60, 10);
  inherited Init(R, ATitle);

  R.Assign(3, 3, Size.X-18, 4);
  New(FNazwaPrzedmiotuInputLine, Init(R, slNazwaPrzedmiotu));
  FNazwaPrzedmiotuInputLine^.SetValidator(New(PNazwaPrzedmiotuValidator, Init));
  Insert(FNazwaPrzedmiotuInputLine);

  R.Assign(2, 2, Size.X-18, 3);
  New(FNazwaPrzedmiotuLabel, Init(R, '~N~azwa przedmiotu', FNazwaPrzedmiotuInputLine));
  Insert(FNazwaPrzedmiotuLabel);

  R.Assign(3, 5, 3+slSkrot+2, 6);
  New(FSkrotInputLine, Init(R, slSkrot));
  FSkrotInputLine^.SetValidator(New(PSkrotValidator, Init));
  Insert(FSkrotInputLine);

  R.Assign(2, 4, Size.X-18, 5);
  New(FSkrotLabel, Init(R, '~S~kr¢t', FSkrotInputLine));
  Insert(FSkrotLabel);

  FNazwaPrzedmiotuInputLine^.Select;
  HelpCtx:=$1021;
end;

constructor TPrzedmiotDialog.Load(var S: TStream);
begin
  inherited Load(S);
  GetPeerViewPtr(S, FNazwaPrzedmiotuInputLine);
  GetPeerViewPtr(S, FSkrotInputLine);
  GetPeerViewPtr(S, FNazwaPrzedmiotuLabel);
  GetPeerViewPtr(S, FSkrotLabel);
end;

procedure TPrzedmiotDialog.GetData(var Rec);
var S: String;
begin
  FNazwaPrzedmiotuInputLine^.GetData(S);
  PPrzedmiot(Rec)^.SetNazwa(S);
  FSkrotInputLine^.GetData(S);
  PPrzedmiot(Rec)^.SetSkrot(S);
end;

procedure TPrzedmiotDialog.SetData(var Rec);
var S: String;
begin
  PPrzedmiot(Rec)^.GetNazwa(S);
  FNazwaPrzedmiotuInputLine^.SetData(S);
  PPrzedmiot(Rec)^.GetSkrot(S);
  FSkrotInputLine^.SetData(S);
end;

procedure TPrzedmiotDialog.Store(var S: TStream);
begin
  inherited Store(S);
  PutPeerViewPtr(S, FNazwaPrzedmiotuInputLine);
  PutPeerViewPtr(S, FSkrotInputLine);
  PutPeerViewPtr(S, FNazwaPrzedmiotuLabel);
  PutPeerViewPtr(S, FSkrotLabel);
end;


  { TChoosePrzedmiotDialog }

constructor TChoosePrzedmiotDialog.Init;
begin
  inherited Init('Wybierz przedmiot', 'Przedmiot', '~L~ista przedmiot¢w', 1);
  HelpCtx:=$1023;
end;


function ChoosePrzedmiot(List: PDataCollection; ShowHelpButton: Boolean): Integer;
var
  Dialog: PChoosePrzedmiotDialog;
  Index: Integer;
begin
  if (not Assigned(List)) or (List^.Count=0) then
  begin
    MessageBox(#3'Spis dost©pnych przedmiot¢w jest pusty !',
               nil,
               mfError or mfCancelButton);
    ChoosePrzedmiot:=-1;
  end
  else
  begin
    New(Dialog, Init);
    Dialog^.SetList(List);
    if ShowHelpButton then Dialog^.ShowHelpButton
    else Dialog^.HideHelpButton;
    if Application^.ExecuteDialog(Dialog, @Index)<>cmCancel then
    begin
      ChoosePrzedmiot:=Index;
    end
    else ChoosePrzedmiot:=-1;
  end;
end;

procedure RegisterPrzedmiot;
begin
  RegisterType(RPrzedmiot);
  RegisterType(RNazwaPrzedmiotuValidator);
  RegisterType(RSkrotValidator);
  RegisterType(RPrzedmiotDialog);
  RegisterType(RChoosePrzedmiotDialog);
end;

begin
  Przedmioty:=nil;
  RegisterPrzedmiot;
end.
