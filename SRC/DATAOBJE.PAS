Unit DataObjects;

interface
uses
  Objects;

type { typ opisuj¥cy bazowy typ danych }
  PDataObject = ^TDataObject;
  TDataObject = object (TObject)
    Index: LongInt;
    constructor Init;
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function Compare(Data: PDataObject): Integer; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    procedure Assign(Data: PDataObject); virtual;
    procedure Clear; virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj¥cy kolekcj© danych }
  PDatacollection = ^TDataCollection;
  TDataCollection = object (TSortedCollection)
    function GetFirstFreeIndex: LongInt;
    function Compare(Key1, Key2: Pointer): Integer; virtual;
    function Empty: Boolean; virtual;
    function ItemByIndex(Index: LongInt): PDataObject; virtual;
  end;

const
  RDataObject: TStreamRec = (
    ObjType: $1000;
    VmtLink: Ofs(TypeOf(TDataObject)^);
    Load   : @TDataObject.Load;
    Store  : @TDataObject.Store);
  RDataCollection: TStreamRec = (
    ObjType: $1001;
    VmtLink: Ofs(TypeOf(TDataCollection)^);
    Load   : @TDataCollection.Load;
    Store  : @TDataCollection.Store);

procedure RegisterDataObjects;

implementation

{ TDataObject }

constructor TDataObject.Init;
begin
  inherited Init;
  Index:=-1;
  Clear;
end;

constructor TDataObject.Load;
begin
  inherited Init;
  S.Read(Index, SizeOf(Index));
end;

destructor TDataObject.Done;
begin
  Clear;
  Index:=-1;
  inherited Done;
end;

function TDataObject.Compare;
begin
  if Index<Data^.Index then Compare:=1
  else if Index>Data^.Index then Compare:=-1
  else Compare:=0;
end;

function TDataObject.GetText;
begin
  GetText:='';
end;

procedure TDataObject.Assign;
begin
  Clear;
  Index:=Data^.Index;
end;

procedure TDataObject.Clear;
begin
end;

procedure TDataObject.Store;
begin
  S.Write(Index, SizeOf(Index));
end;

{ TDataCollection }

function TDataCollection.GetFirstFreeIndex;
var
  I: Integer;
  Index: LongInt;
begin
  Index:=0;
  I:=0;
  while I<Count do
  begin
    If Index=PDataObject(Items^[I])^.Index then
    begin
      Inc(Index);
      I:=0;
    end
    else Inc(I);
  end;
  GetFirstFreeIndex:=Index;
end;

function TDataCollection.Compare;
begin
  Compare:=PDataObject(Key1)^.Compare(Key2);
end;

function TDataCollection.Empty;
begin
  Empty:=(Count=0);
end;

function TDataCollection.ItemByIndex;
var
  I: Integer;
begin
  if Index=-1 then ItemByIndex:=nil
  else
  begin
    I:=0;
    while I<Count do
    begin
      if PDataObject(Items^[I])^.Index=Index then
      begin
        ItemByIndex:=Items^[I];
        Exit;
      end
      else Inc(I);
    end;
    ItemByIndex:=nil;
  end;
end;

{ *** }

procedure RegisterDataObjects;
begin
  RegisterType(RDataObject);
  RegisterType(RDataCollection);
end;

begin
end.

