Unit DataObjects;

interface
uses Objects;

type { Typ opisuj¥cy obiekt danych }
  PDataObject = ^TDataObject;
  TDataObject = object (TObject)
  private
    FIndex: LongInt;
  public
    constructor Init;
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function Compare(Data: PDataObject): Integer; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    procedure GetIndex(var Index: LongInt);
    procedure SetIndex(const Index: LongInt);
    procedure Store(var S: TStream); virtual;
  end;

type { Typ opisuj¥cy kolekcj© obiekt¢w danych }
  PDataCollection = ^TDataCollection;
  TDataCollection = object (TSortedCollection)
  private
    FHighestIndex: LongInt;
    function GetFirstFreeIndex: Integer;
  public
    constructor Init(ALimit, ADelta: Integer);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream); virtual;
    function Compare(Key1, Key2: Pointer): Integer; virtual;
    function ItemByIndex(Index: LongInt): PDataObject;
    procedure Insert(Item: Pointer); virtual;
  end;

const { Staˆe do rejestracji typ¢w w strumieniach }
  RDataObject: TStreamRec = (
    ObjType: $FFF0;
    VmtLink: Ofs(TypeOf(TDataObject)^);
    Load   : @TDataObject.Load;
    Store  : @TDataObject.Store);

  RDataCollection: TStreamRec = (
    ObjType: $FFF1;
    VmtLink: Ofs(TypeOf(TDataCollection)^);
    Load   : @TDataCollection.Load;
    Store  : @TDataCollection.Store);

procedure RegisterDataObjects;

implementation

  { TDataObject }

constructor TDataObject.Init;
begin
  inherited Init;
  FIndex:=-1;
end;

constructor TDataObject.Load(var S: TStream);
begin
  inherited Init;
  S.Read(FIndex, SizeOf(FIndex));
end;

destructor TDataObject.Done;
begin
  FIndex:=-1;
  inherited Done;
end;

function TDataObject.Compare(Data: PDataObject): Integer;
var Index1, Index2: LongInt;
begin
  GetIndex(Index1); Data^.GetIndex(Index2);
  if Index1<Index2 then Compare:=-1
  else if Index1>Index2 then Compare:=1
  else Compare:=0;
end;

function TDataObject.GetText(MaxLen: Integer): String;
begin
  GetText:='';
end;

procedure TDataObject.GetIndex(var Index: LongInt);
begin
  Index:=FIndex;
end;

procedure TDataObject.SetIndex(const Index: LongInt);
begin
  FIndex:=Index;
end;

procedure TDataObject.Store(var S: TStream);
begin
  S.Write(FIndex, SizeOf(FIndex));
end;


  { TDataCollection }

function TDataCollection.GetFirstFreeIndex: Integer;
var
  I, Index1, Index2: LongInt;
  Data: PDataObject;
  Found: Boolean;
begin
  if Count=0 then GetFirstFreeIndex:=1
  else
  begin
    Index1:=1;
    for I:=0 to Count-1 do
    begin
      Data:=At(I);
      Data^.GetIndex(Index2);
      if Index1<Index2 then Index1:=Index2;
    end;
    GetFirstFreeIndex:=Index1+1;
  end;
end;

constructor TDataCollection.Init;
begin
  inherited Init(ALimit, ADelta);
  FHighestIndex:=0;
end;

constructor TDataCollection.Load;
begin
  inherited Load(S);
  S.Read(FHighestIndex, SizeOf(FHighestIndex));
end;

procedure TDataCollection.Store;
begin
  inherited Store(S);
  S.Write(FHighestIndex, SizeOf(FHighestIndex));
end;

function TDataCollection.Compare(Key1, Key2: Pointer): Integer;
begin
  Compare:=PDataObject(Key1)^.Compare(Key2);
end;

function TDataCollection.ItemByIndex(Index: LongInt): PDataObject;
var
  I: Integer;
  Index1: LongInt;
  Data: PDataObject;
  Found: Boolean;
begin
  if Count=0 then ItemByIndex:=nil
  else
  begin
    I:=0;
    Found:=False;
    while (I<Count) and (not Found) do
    begin
      Data:=At(I);
      Data^.GetIndex(Index1);
      if Index1=Index then
      begin
        Found:=True;
      end
      else Inc(I);
    end;
    if Found then ItemByIndex:=At(I)
    else ItemByIndex:=nil;
  end;
end;

procedure TDataCollection.Insert(Item: Pointer);
var Index: Integer;
begin
  PDataObject(Item)^.SetIndex(GetFirstFreeIndex);
  inherited Insert(Item);
end;


procedure RegisterDataObjects;
begin
  RegisterType(RDataObject);
  RegisterType(RDataCollection);
end;

begin
  RegisterDataObjects;
end.
