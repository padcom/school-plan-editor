Unit Dzwonek;

interface
uses Objects, Drivers, Views, Dialogs, Validate, MsgBox,
     DataObjects, DataDialogs,
     Stale;

type { Typ opisuj¥cy czas pocz¥tku lekcji }
  TDzwonekStart = record
    Godzina, Minuta: Word;
  end;

type { Typ opisuj¥cy dzwonek }
  PDzwonek = ^TDzwonek;
  TDzwonek = object (TDataObject)
  private
    FStart: TDzwonekStart;
    FDlugosc: Byte;
  public
    constructor Init;
    constructor Load(var S: TStream);
    function Compare(Data: PDataObject): Integer; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    procedure GetDlugosc(var Dlugosc: Byte);
    procedure GetStart(var Start: TDzwonekStart);
    procedure SetDlugosc(const Dlugosc: Byte);
    procedure SetStart(const Start: TDzwonekStart);
    procedure Store(var S: TStream); virtual;
  end;

type { Typ opisuj¥cy walidator czasu pocz¥tku lekcji }
  PStartDzwonekValidator = ^TStartDzwonekValidator;
  TStartDzwonekValidator = object (TValidator)
    function IsValid(const S: string): Boolean; virtual;
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
    procedure Error; virtual;
  end;

type { Typ opisuj¥cy okno edycji dzwonka }
  PDzwonekDialog = ^TDzwonekDialog;
  TDzwonekDialog = object (TDataDialog)
  private
    FStartInputLine: PInputLine;
    FDlugoscInputLine: PInputLine;
    FStartLabel: PLabel;
    FDlugoscLabel: PLabel;
  public
    constructor Init(ATitle: TTitleStr);
    constructor Load(var S: TStream);
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { Typ opisuj¥cy okno wyboru dzwonka z listy }
  PChooseDzwonekDialog = ^TChooseDzwonekDialog;
  TChooseDzwonekDialog = object (TChooseDataDialog)
    constructor Init;
  end;

function ChooseDzwonek(List: PDataCollection; ShowHelpButton: Boolean): Integer;

const { Staˆe do rejestracji typ¢w w strumieniach }
  RDzwonek: TStreamRec = (
    ObjType: $1400;
    VmtLink: Ofs(TypeOf(TDzwonek)^);
    Load   : @TDzwonek.Load;
    Store  : @TDzwonek.Store);
  RStartDzwonekValidator: TStreamRec = (
    ObjType: $1401;
    VmtLink: Ofs(TypeOf(TStartDzwonekValidator)^);
    Load   : @TStartDzwonekValidator.Load;
    Store  : @TStartDzwonekValidator.Store);
  RDzwonekDialog: TStreamRec = (
    ObjType: $1402;
    VmtLink: Ofs(TypeOf(TDzwonekDialog)^);
    Load   : @TDzwonekDialog.Load;
    Store  : @TDzwonekDialog.Store);

procedure RegisterDzwonek;

var
  Dzwonki: PDataCollection;

implementation
uses App, Latin2;

  { TDzwonek }

constructor TDzwonek.Init;
begin
  inherited Init;
  with FStart do
  begin
    Godzina:=8;
    Minuta:=0;
  end;
  FDlugosc:=45;
end;

constructor TDzwonek.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(FStart, SizeOf(FStart));
  S.Read(FDlugosc, SizeOf(FDlugosc));
end;

function TDzwonek.Compare(Data: PDataObject): Integer;
var
  Start1, Start2: TDzwonekStart;
  Index1, Index2: LongInt;
  OldCompare: Integer;
begin
  GetIndex(Index1); Data^.GetIndex(Index2);
  if (Index1<>-1) and (Index2<>-1) then OldCompare:=inherited Compare(Data)
  else OldCompare:=-1;

  if OldCompare=0 then Compare:=0
  else
  begin
    GetStart(Start1); PDzwonek(Data)^.GetStart(Start2);
    if Start1.Godzina<Start2.Godzina then Compare:=-1
    else if Start1.Godzina>Start2.Godzina then Compare:=1
    else if Start1.Minuta<Start2.Minuta then Compare:=-1
    else if Start1.Minuta>Start2.Minuta then Compare:=1
    else Compare:=0;
  end;
end;

function TDzwonek.GetText(MaxLen: Integer): String;
var
  S1, S2: String;
  TempTime: TDzwonekStart;
  Dlugosc: Byte;
begin
  S1:=''; S2:='';
  GetStart(TempTime);
  GetDlugosc(Dlugosc);
  with TempTime do
  begin
    Str(Godzina, S1); if Godzina<10 then S1:='0'+S1; S1:=S1+':';
    Str(Minuta, S2); if Minuta<10 then S2:='0'+S2; S1:=S1+S2;
    Minuta:=Minuta+Dlugosc;
    while Minuta>60 do
    begin
      Minuta:=Minuta-60;
      Inc(Godzina);
    end;
    S1:=S1+'-';
    Str(Godzina, S2); if Godzina<10 then S2:='0'+S2; S1:=S1+S2+':';
    Str(Minuta, S2); if Minuta<10 then S2:='0'+S2; S1:=S1+S2;
  end;
  GetText:=Copy(S1, 1, MaxLen);
end;

procedure TDzwonek.GetDlugosc(var Dlugosc: Byte);
begin
  Dlugosc:=FDlugosc;
end;

procedure TDzwonek.GetStart(var Start: TDzwonekStart);
begin
  Start:=FStart;
end;

procedure TDzwonek.SetDlugosc(const Dlugosc: Byte);
begin
  FDlugosc:=Dlugosc;
end;

procedure TDzwonek.SetStart(const Start: TDzwonekStart);
begin
  FStart:=Start;
end;

procedure TDzwonek.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(FStart, SizeOf(FStart));
  S.Write(FDlugosc, SizeOf(FDlugosc));
end;


  { TStartDzwonekValidator }

function TStartDzwonekValidator.IsValid(const S: string): Boolean;
var Godzina, Minuta, ErrorCode: Integer;
begin
  if IOResult<>0 then;
  if Length(S)=5 then
  begin
    Val(S[1]+S[2], Godzina, ErrorCode);
    if (ErrorCode=0) and (Godzina in [0..23]) then
    begin
      Val(S[4]+S[5], Minuta, ErrorCode);
      Writeln(Minuta);
      if (ErrorCode=0) and (Minuta in [0..59]) then IsValid:=True
      else IsValid:=False;
    end
    else IsValid:=False;
  end
  else IsValid:=False;
end;

function TStartDzwonekValidator.IsValidInput(var S: string; SuppressFill: Boolean): Boolean;
var T, I: Integer;
begin
  if S<>'' then
  begin
    for I:=1 to Length(S) do
    begin
      if I<>3 then
      begin
        if Pos(S[I], '0123456789')=0 then
        begin
          IsValidInput:=False;
          Exit;
        end;
      end
      else
      begin
        if S[I]<>':' then S[I]:=':';
      end;
    end;
    IsValidInput:=True;
  end;
end;

procedure TStartDzwonekValidator.Error;
begin
  MessageBox(#3'Bˆ¥d przy wprowadzaniu godziny pocz¥tkowej', nil, mfError or mfCancelButton);
end;



  { TDzwonekDialog }

constructor TDzwonekDialog.Init(ATitle: TTitleStr);
var R: TRect;
begin
  R.Assign(0, 0, 50, 10);
  inherited Init(R, ATitle);

  R.Assign(15, 3, 22, 4);
  New(FStartInputLine, Init(R, 5));
  FStartInputLine^.SetValidator(New(PStartDzwonekValidator, Init));
  Insert(FStartInputLine);

  R.Assign(2, 3, 15, 4);
  New(FStartLabel, Init(R, '~P~ocz¥tek', FStartInputLine));
  Insert(FStartLabel);
{
  R.Assign(15, 5, 19, 6);
  New(FDlugoscInputLine, Init(R, 2));
  Insert(FDlugoscInputLine);

  R.Assign(2, 5, 15, 6);
  New(FDlugoscLabel, Init(R, 'Dˆ~u~go˜†', FDlugoscInputLine));
  Insert(FDlugoscLabel);
}
  FStartInputLine^.Select;
  HelpCtx:=$1051;
end;

constructor TDzwonekDialog.Load(var S: TStream);
begin
  inherited Load(S);
  GetSubViewPtr(S, FStartInputLine);
  GetSubViewPtr(S, FDlugoscInputLine);
  GetSubViewPtr(S, FStartLabel);
  GetSubViewPtr(S, FDlugoscLabel);
end;

procedure TDzwonekDialog.GetData(var Rec);
var
  S: String;
  ErrorCode: Integer;
  Data: TDzwonekStart;
begin
  FStartInputLine^.GetData(S);
  with Data do
  begin
    Val(S[1]+S[2], Godzina, ErrorCode);
    Val(S[4]+S[5], Minuta, ErrorCode);
  end;
  PDzwonek(Rec)^.SetStart(Data);
end;

procedure TDzwonekDialog.SetData(var Rec);
var
  S1, S2: String;
  Data: TDzwonekStart;
begin
  PDzwonek(Rec)^.GetStart(Data);
  with Data do
  begin
    Str(Godzina, S1); if Godzina<10 then S1:='0'+S1;
    Str(Minuta, S2); if Minuta<10 then S2:='0'+S2;
    S1:=S1+':'+S2;
  end;
  FStartInputLine^.SetData(S1);
end;

procedure TDzwonekDialog.Store(var S: TStream);
begin
  inherited Store(S);
  PutSubViewPtr(S, FStartInputLine);
  PutSubViewPtr(S, FDlugoscInputLine);
  PutSubViewPtr(S, FStartLabel);
  PutSubViewPtr(S, FDlugoscLabel);
end;


  { TChooseDzwonekDialog }

constructor TChooseDzwonekDialog.Init;
begin
  inherited Init('Wybierz dzwonek', 'Dzwonek', '~L~ista dzwonk¢w', 1);
  HelpCtx:=$1053;
end;



function ChooseDzwonek(List: PDataCollection; ShowHelpButton: Boolean): Integer;
var
  Dialog: PChooseDzwonekDialog;
  Index: Integer;
begin
  if (not Assigned(List)) or (List^.Count=0) then
  begin
    MessageBox(#3'Spis dost©pnych dzwonk¢w jest pusty !',
               nil,
               mfError or mfCancelButton);
    ChooseDzwonek:=-1;
  end
  else
  begin
    New(Dialog, Init);
    Dialog^.SetList(List);
    if ShowHelpButton then Dialog^.ShowHelpButton
    else Dialog^.HideHelpButton;
    if Application^.ExecuteDialog(Dialog, @Index)<>cmCancel then
    begin
      ChooseDzwonek:=Index;
    end
    else ChooseDzwonek:=-1;
  end;
end;

procedure RegisterDzwonek;
begin
  RegisterType(RDzwonek);
  RegisterType(RStartDzwonekValidator);
  RegisterType(RDzwonekDialog);
end;


begin
  RegisterDzwonek;
end.
