Unit Statystyka;

interface
uses
  Objects, Drivers, Views, Dialogs;

type { typ opisuj¥cy element listy statystycznej }
  PStatisticListItem = ^TStatisticListItem;
  TStatisticListItem = object (TObject)
    Data: PString;
    Count: Integer;
    constructor Init(AData: String);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    function Compare(AData: PStatisticListItem): Integer; virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj¥cy kolekcj© element¢w statystycznych }
  PStatisticList = ^TStatisticList;
  TStatisticList = object (TSortedCollection)
    function Compare(Key1, Key2: Pointer): Integer; virtual;
  end;

type { typ opisuj¥cy ListBox element¢w statystycznych }
  PStatisticListBox = ^TStatisticListBox;
  TStatisticListBox = object (TListBox)
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
  end;

const
  RStatisticListItem: TStreamRec = (
    ObjType: $C000;
    VmtLink: Ofs(TypeOf(TStatisticListItem)^);
    Load   : @TStatisticListItem.Load;
    Store  : @TStatisticListItem.Store);
  RStatisticList: TStreamRec = (
    ObjType: $C001;
    VmtLink: Ofs(TypeOf(TStatisticList)^);
    Load   : @TStatisticList.Load;
    Store  : @TStatisticList.Store);
  RStatisticListBox: TStreamRec = (
    ObjType: $C002;
    VmtLink: Ofs(TypeOf(TStatisticListBox)^);
    Load   : @TStatisticListBox.Load;
    Store  : @TStatisticListBox.Store);

procedure RegisterStatystyka;

implementation
uses
  Latin2;

{ TStatisticListIte }

constructor TStatisticListItem.Init;
begin
  inherited Init;
  if AData<>'' then Data:=NewStr(AData);
  Count:=1;
end;

constructor TStatisticListItem.Load;
begin
  inherited Init;
  Data:=S.ReadStr;
  S.Read(Count, SizeOf(Count));
end;

destructor TStatisticListItem.Done;
begin
  if Assigned(Data) then
  begin
    DisposeStr(Data);
    Data:=nil;
  end;
  Count:=0;
  inherited Done;
end;

function TStatisticListItem.GetText;
var
  S, C: String;
begin
  if Assigned(Data) then S:=Copy(Data^, 1, MaxLen-10) else S:='';
  while Length(S)<(MaxLen-10) do S:=S+' ';
  Str(Count: 5, C);
  C:='  '+C;
  S:=S+C;
  GetText:=S;
end;

function TStatisticListItem.Compare;
begin
  Compare:=CompareStr(Data^, AData^.Data^, False);
end;

procedure TStatisticListItem.Store;
begin
  inherited Init;
  S.WriteStr(Data);
  S.Write(Count, SizeOf(Count));
end;

{ TStatisticList }

function TStatisticList.Compare;
begin
  Compare:=PStatisticListItem(Key1)^.Compare(Key2);
end;

{ TStatisticListBox }

function TStatisticListBox.GetText;
begin
  GetText:=PStatisticListItem(List^.At(Item))^.GetText(MaxLen);
end;

{ *** }

procedure RegisterStatystyka;
begin
  RegisterType(RStatisticListItem);
  RegisterType(RStatisticList);
  RegisterType(RStatisticListBox);
end;

begin
end.
