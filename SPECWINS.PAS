Unit SpecWins;

interface
uses
  App, Objects, Drivers, Views, Dialogs, Menus,
  DataObjects, DataDialogs, Stale, Help,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja,
  HostWin;

type { typ opisuj¥cy pod˜wietlany label }
  PHighlightedLabel = ^THighlightedLabel;
  THighlightedLabel = object (TLabel)
    function GetPalette: PPalette; virtual;
  end;

type { typ opisuj¥cy list box dzwonk¢w }
  PDzwonekListView = ^TDzwonekListView;
  TDzwonekListView = object (TListBox)
    function GetPalette: PPalette; virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
  end;

type { typ opisuj¥cy widok listy lekcji dla poszczeg¢lnego dnia }
  PLekcjaListView = ^TLekcjaListView;
  TLekcjaListView = object (TListBox)
    DisableUpdates: Boolean;
    function GetPalette: PPalette; virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure FocusItem(Item: Integer); virtual;
    procedure NewList(AList: PCollection); virtual;
  end;

type { typ opisuj¥cy widok informacji szczeg¢ˆowych lekcji }
  PLekcjaDetailView = ^TLekcjaDetailView;
  TLekcjaDetailView = object (TView)
    ListView: array[1..4] of PLekcjaListView;
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj¥cy widok ramek w ˜rodku okna edycji planu lekcji }
  PInsideFrames = ^TInsideFrames;
  TInsideFrames = object (TView)
    procedure Draw; virtual;
  end;

type { typ opisuj¥cy okno edycji planu zaj©† dla danego elementu }
  PPlanLekcjiWindow = ^TPlanLekcjiWindow;
  TPlanLekcjiWindow = object (THostEditWindow)
    Data: PDataObject;
    InsideFrames: PInsideFrames;
    DzwonekListView: PDzwonekListView;
    DzwonekLabel: PHighlightedLabel;
    FirstDzien: Integer;
    SelectedDzien: Integer;
    LekcjaListView: array[1..4] of PLekcjaListView;
    LekcjaLabel: array[1..4] of PHighlightedLabel;
    LekcjaDetailView: PLekcjaDetailView;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SizeLimits(var Min, Max: TPoint); virtual;
    procedure Store(var S: TStream);
    procedure Zoom; virtual;

    procedure SetDzwonkiList(List: PDataCollection); virtual;
    procedure SetEditorData(AData: PDataObject); virtual;
    procedure SetTitle(ATitle: TTitleStr); virtual;
    procedure UpdateLabels; virtual;
    procedure UpdateLists; virtual;
    function CompareData(AData: PLekcja; Position: Integer): Boolean; virtual;
    function GetLekcja(List: PDataCollection; Position: Integer): PLekcja; virtual;
    function GetText(Position: Integer; MaxLen: Integer; ListView: PLekcjaListView): String; virtual;
    function GetCurrentLekcja: PLekcja; virtual;
    function GetCurrentDzien: Integer; virtual;
    function GetDzwonekIndex: Integer; virtual;
  end;

type { typ opisuj¥cy okno edycji planu lekcji nauczyciela }
  PPlanLekcjiNauczycielWindow = ^TPlanLekcjiNauczycielWindow;
  TPlanLekcjiNauczycielWindow = object (TPlanLekcjiWindow)
    function CompareData(AData: PLekcja; Item: Integer): Boolean; virtual;
    function GetText(Item: Integer; MaxLen: Integer; ListView: PLekcjaListView): String; virtual;
  end;

type { typ opisuj¥cy okno edycji planu lekcji grupy klasy }
  PPlanLekcjiKlasaWindow = ^TPlanLekcjiKlasaWindow;
  TPlanLekcjiKlasaWindow = object (TPlanLekcjiWindow)

  end;

type { typ opisuj¥cy okno edycji planu lekcji sali }
  PPlanLekcjiSalaWindow = ^TPlanLekcjiSalaWindow;
  TPlanLekcjiSalaWindow = object (TPlanLekcjiWindow)

  end;

procedure RunPlanLekcjiNauczyciela;

const
  RHighlightedLabel: TStreamRec = (
    ObjType: $A000;
    VmtLink: Ofs(TypeOf(THighlightedLabel)^);
    Load   : @THighlightedLabel.Load;
    Store  : @THighlightedLabel.Store);
  RDzwonekListView: TStreamRec = (
    ObjType: $A001;
    VmtLink: Ofs(TypeOf(TDzwonekListView)^);
    Load   : @TDzwonekListView.Load;
    Store  : @TDzwonekListView.Store);
  RLekcjaListView: TStreamRec = (
    ObjType: $A002;
    VmtLink: Ofs(TypeOf(TLekcjaListView)^);
    Load   : @TLekcjaListView.Load;
    Store  : @TLekcjaListView.Store);
  RLekcjaDetailView: TStreamRec = (
    ObjType: $A003;
    VmtLink: Ofs(TypeOf(TLekcjaDetailView)^);
    Load   : @TLekcjaDetailView.Load;
    Store  : @TLekcjaDetailView.Store);
  RInsideFrames: TStreamRec = (
    ObjType: $A004;
    VmtLink: Ofs(TypeOf(TInsideFrames)^);
    Load   : @TInsideFrames.Load;
    Store  : @TInsideFrames.Store);
  RPlanLekcjiWindow: TStreamRec = (
    ObjType: $A005;
    VmtLink: Ofs(TypeOf(TPlanLekcjiWindow)^);
    Load   : @TPlanLekcjiWindow.Load;
    Store  : @TPlanLekcjiWindow.Store);
  RPlanLekcjiNauczycielWindow: TStreamRec = (
    ObjType: $A006;
    VmtLink: Ofs(TypeOf(TPlanLekcjiNauczycielWindow)^);
    Load   : @TPlanLekcjiNauczycielWindow.Load;
    Store  : @TPlanLekcjiNauczycielWindow.Store);
  RPlanLekcjiKlasaWindow: TStreamRec = (
    ObjType: $A007;
    VmtLink: Ofs(TypeOf(TPlanLekcjiKlasaWindow)^);
    Load   : @TPlanLekcjiKlasaWindow.Load;
    Store  : @TPlanLekcjiKlasaWindow.Store);
  RPlanLekcjiSalaWindow: TStreamRec = (
    ObjType: $A008;
    VmtLink: Ofs(TypeOf(TPlanLekcjiSalaWindow)^);
    Load   : @TPlanLekcjiSalaWindow.Load;
    Store  : @TPlanLekcjiSalaWindow.Store);

procedure RegisterSpecWins;

implementation
uses
  Resource, DataBase, Latin2;

{ THighlightedLabel }

function THighlightedLabel.GetPalette;
const
  S: String = CLabel;
begin
  S[1]:=#2; S[2]:=#5;
  GetPalette:=@S;
end;

{ TDzwonekListView }

function TDzwonekListView.GetText;
begin
  GetText:=PDataObject(List^.At(Item))^.GetText(5);
end;

function TDzwonekListView.GetPalette;
const
  S: String = CListViewer;
begin
  S[1]:=#10; S[3]:=#5;
  S[2]:=#2; S[4]:=#5;
  GetPalette:=@S;
end;

{ TLekcjaListView }

function TLekcjaListView.GetPalette;
const
  S: String = CListViewer;
begin
  S[1]:=#2; S[3]:=#5;
  S[2]:=#2; S[4]:=#2;
  GetPalette:=@S;
end;

function TLekcjaListView.GetText;
begin
  GetText:=PPlanLekcjiWindow(Owner)^.GetText(Item, MaxLen, @Self);
end;

var
  EventFromLekcjaListView: Boolean;

procedure TLekcjaListView.FocusItem;
begin
  inherited FocusItem(Item);
  if not DisableUpdates then
  begin
    EventFromLekcjaListView:=True;
    Message(Owner, evBroadcast, cmRedrawLekcjaDetailView, nil);
    Message(Owner, evBroadcast, cmListItemChanged, @Self);
    EventFromLekcjaListView:=False;
  end;
end;

procedure TLekcjaListView.NewList;
var
  Position: Integer;
begin
  DisableUpdates:=True;
  Position:=Focused;
  List:=AList;
  if Assigned(Dzwonki) then SetRange(Dzwonki^.Count)
  else SetRange(0);
  if (Position>0) and (Position<Range) then FocusItem(Position)
  else FocusItem(0);
  DrawView;
  DisableUpdates:=False;
end;

{ TLekcjaDetailView }

constructor TLekcjaDetailView.Load;
var
  I: Integer;
begin
  inherited Load(S);
  for I:=1 to 4 do GetPeerViewPtr(S, ListView[I]);
end;

procedure TLekcjaDetailView.Draw;
var
  Buf: TDrawBuffer;
  Color: Word;
  Y: Integer;
  L: PLekcja;
  N: PNauczyciel;
  P: PPrzedmiot;
  K: PKlasa;
  S: PSala;
  St, Grupa: String;
  I, W: Word;
  Dzien: Integer;
begin
  with PPlanLekcjiWindow(Owner)^ do Dzien:=SelectedDzien-FirstDzien+1;
  Color:=GetColor(1);
  for Y:=0 to Size.Y-1 do
  begin
    MoveChar(Buf, ' ', Color, Size.X);

    { wypisanie nagˆ¢wk¢w }
    case Y of
      0: St:=' Nauczyciel :';
      1: St:=' Przedmiot  :';
      2: St:=' Klasa      :';
      3: St:=' Grupy      :';
      4: St:=' Sala       :'
      else St:='';
    end;
    MoveStr(Buf, St, Color);

    WriteLine(0, Y, Size.X, 1, Buf);
  end;
end;

procedure TLekcjaDetailView.Store;
var
  I: Integer;
begin
  inherited Store(S);
  for I:=1 to 4 do PutPeerViewPtr(S, ListView[I]);
end;

{ TInsideFrames }

procedure TInsideFrames.Draw;
var
  Color: Word;
  Buf: TDrawBuffer;
  C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12: Char;
begin
  C1:='Ä'; C2:='³'; C3:='Å'; C4:='Â'; C5:='Á'; C6:='Ã'; C7:='´'; C9:='Ú'; C10:='¿'; C11:='Ù'; C12:='À';
  Color:=GetColor(2);

  { linia, w kt¢rej b©d¥ rysowane etykiety }
  MoveChar(Buf, ' ', Color, Size.X);
  MoveChar(Buf[9], C2, Color, 1);
  MoveChar(Buf[10], C2, Color, 1);
  MoveChar(Buf[25], C2, Color, 1);
  MoveChar(Buf[40], C2, Color, 1);
  MoveChar(Buf[55], C2, Color, 1);
  WriteLine(0, 0, Size.X, 1, Buf);

  { linia oddzielaj¥ca etykiety od list }
  MoveChar(Buf, C1, Color, Size.X);
  MoveChar(Buf[9], C3, Color, 1);
  MoveChar(Buf[10], C3, Color, 1);
  MoveChar(Buf[25], C3, Color, 1);
  MoveChar(Buf[40], C3, Color, 1);
  MoveChar(Buf[55], C3, Color, 1);
  WriteLine(0, 1, Size.X, 1, Buf);

  { linie, w kt¢rych b©d¥ rysowane listy }
  MoveChar(Buf, ' ', Color, Size.X);
  MoveChar(Buf[9], C2, Color, 1);
  MoveChar(Buf[10], C2, Color, 1);
  MoveChar(Buf[25], C2, Color, 1);
  MoveChar(Buf[40], C2, Color, 1);
  MoveChar(Buf[55], C2, Color, 1);
  WriteLine(0, 2, Size.X, Size.Y-7, Buf);

  { linia oddzielaj¥ca listy od widoku detali lekcji }
  MoveChar(Buf, C1, Color, Size.X);
  MoveChar(Buf[9], C5, Color, 1);
  MoveChar(Buf[10], C5, Color, 1);
  MoveChar(Buf[25], C5, Color, 1);
  MoveChar(Buf[40], C5, Color, 1);
  MoveChar(Buf[55], C5, Color, 1);
  WriteLine(0, Size.Y-6, Size.X, 1, Buf);

  MoveChar(Buf, ' ', Color, Size.X);
  WriteLine(0, Size.Y-5, Size.X, 4, Buf);
end;

{ TPlanLekcjiWindow }

constructor TPlanLekcjiWindow.Load;
var
  I: Integer;
begin
  inherited Load(S);
  GetSubViewPtr(S, InsideFrames);
  GetSubViewPtr(S, DzwonekListView);
  GetSubViewPtr(S, DzwonekLabel);
  for I:=1 to 4 do GetSubViewPtr(S, LekcjaListView[I]);
  for I:=1 to 4 do GetSubViewPtr(S, LekcjaLabel[I]);
  GetSubViewPtr(S, LekcjaDetailView);
  S.Read(FirstDzien, SizeOf(FirstDzien));
  S.Read(SelectedDzien, SizeOf(SelectedDzien));
end;

procedure TPlanLekcjiWindow.HandleEvent;
var
  I: Integer;
begin
  if Event.What=evKeyboard then
    case Event.KeyCode of
      kbTab: ClearEvent(Event);
      kbLeft:
      begin
        if SelectedDzien=1 then ClearEvent(Event)
        else
        begin
          Dec(SelectedDzien);
          if SelectedDzien<FirstDzien then
          begin
            FirstDzien:=SelectedDzien;
            UpdateLabels;
            UpdateLists;
            ClearEvent(Event);
          end
          else
          begin
            SelectNext(True);
            ClearEvent(Event);
          end;
        end;
      end;
      kbRight:
      begin
        if SelectedDzien=IloscDni then ClearEvent(Event)
        else
        begin
          Inc(SelectedDzien);
          if SelectedDzien>FirstDzien+3 then
          begin
            FirstDzien:=SelectedDzien-3;
            UpdateLabels;
            UpdateLists;
            ClearEvent(Event);
          end
          else
          begin
            SelectNext(False);
            ClearEvent(Event);
          end;
        end;
      end;
    end
  else if Event.What=evBroadcast then
  begin
    case Event.Command of
      cmUpdateLists: UpdateLists;
      cmListItemChanged: if EventFromLekcjaListView then
      begin
        for I:=1 to 4 do
        begin
          LekcjaListView[I]^.DisableUpdates:=True;
          LekcjaListView[I]^.FocusItem(PLekcjaListView(Event.InfoPtr)^.Focused);
          LekcjaListView[I]^.DisableUpdates:=False;
        end;
        DzwonekListView^.FocusItem(PLekcjaListView(Event.InfoPtr)^.Focused);
        DzwonekListView^.DrawView;
      end;
      cmRedrawLekcjaDetailView:
      begin
        LekcjaDetailView^.DrawView;
{        ClearEvent(Event);}
      end;
    end;
  end;
  inherited HandleEvent(Event);
end;

procedure TPlanLekcjiWindow.SizeLimits;
begin
  inherited SizeLimits(Min, Max);
  Min.X:=72; Min.Y:=10;
  Max.X:=72;
end;

procedure TPlanLekcjiWindow.Store;
var
  I: Integer;
begin
  inherited Store(S);
  PutSubViewPtr(S, InsideFrames);
  PutSubViewPtr(S, DzwonekListView);
  PutSubViewPtr(S, DzwonekLabel);
  for I:=1 to 4 do PutSubViewPtr(S, LekcjaListView[I]);
  for I:=1 to 4 do PutSubViewPtr(S, LekcjaLabel[I]);
  PutSubViewPtr(S, LekcjaDetailView);
  S.Write(FirstDzien, SizeOf(FirstDzien));
  S.Write(SelectedDzien, SizeOf(SelectedDzien));
end;

procedure TPlanLekcjiWindow.Zoom;
var
  R: TRect;
  Max, Min: TPoint;
begin
  SizeLimits(Min, Max);
  if Longint(Size)<>Longint(Max) then
  begin
    GetBounds(ZoomRect);
    Longint(R.A):=4;
    R.B:=Max;
    Locate(R);
  end else Locate(ZoomRect);
end;

procedure TPlanLekcjiWindow.SetDzwonkiList;
begin
  if Assigned(DzwonekListView^.List) then DzwonekListView^.List:=nil;
  DzwonekListView^.NewList(List);
end;

procedure TPlanLekcjiWindow.SetEditorData;
begin
  Data:=AData;
end;

procedure TPlanLekcjiWindow.SetTitle;
begin
  if ATitle='' then Exit;
  if Assigned(Title) then DisposeStr(Title);
  Title:=nil;
  Title:=NewStr(ATitle);
end;

procedure TPlanLekcjiWindow.UpdateLabels;
var
  I, J: Integer;
begin
  for I:=1 to 4 do with LekcjaLabel[I]^ do
  begin
    if Assigned(Text) then DisposeStr(Text);
    J:=FirstDzien+I-1;
    Text:=NewStr(NazwyDniTygodnia[J]);
    DrawView;
  end;
end;

procedure TPlanLekcjiWindow.UpdateLists;
var
  I: Integer;
  TempList: PDataCollection;
begin
  for I:=1 to 4 do with LekcjaListView[I]^ do
  begin
    List:=nil;
    NewList(Lekcje[FirstDzien+I-1]);
  end;
end;

function TPlanLekcjiWindow.CompareData;
var
  Temp: PDzwonek;
begin
  Temp:=Dzwonki^.At(Position);
  if AData^.DzwonekIndex<>Temp^.Index then CompareData:=False
  else CompareData:=True;
end;

function TPlanLekcjiWindow.GetLekcja;
var
  I: Integer;
  L: PLekcja;
begin
  I:=0;
  L:=nil;
  while Assigned(List) and (I<List^.Count) do
  begin
    L:=PLekcja(List^.At(I));
    if CompareData(L, Position) then Break
    else L:=nil;
    Inc(I);
  end;
  GetLekcja:=L;
end;

function TPlanLekcjiWindow.GetText;
begin
  GetText:='';
end;

function TPlanLekcjiWindow.GetCurrentLekcja;
begin
  GetCurrentLekcja:=GetLekcja(PDataCollection(LekcjaListView[SelectedDzien-FirstDzien+1]^.List),
                              DzwonekListView^.Focused);
end;

function TPlanLekcjiWindow.GetCurrentDzien;
begin
  GetCurrentDzien:=SelectedDzien-1;
end;

function TPlanLekcjiWindow.GetDzwonekIndex;
var
  D: PDzwonek;
begin
  if not Assigned(Dzwonki) or (Dzwonki^.Count=0) then GetDzwonekIndex:=-1
  else GetDzwonekIndex:=PDzwonek(Dzwonki^.At(DzwonekListView^.Focused))^.Index;
end;

{ TPlanLekcjiNauczycielWindow }

function TPlanLekcjiNauczycielWindow.CompareData;
begin
  if not (inherited CompareData(AData, Item)) then CompareData:=False
  else if Data^.Index<>AData^.NauczycielIndex then CompareData:=False
  else CompareData:=True;
end;

function TPlanLekcjiNauczycielWindow.GetText;
var
  L: PLekcja;
  N: PNauczyciel;
begin
  N:=nil; L:=nil;
  L:=GetLekcja(PDataCollection(ListView^.List), Item);
  if Assigned(L) and Assigned(Nauczyciele) then N:=PNauczyciel(Nauczyciele^.ItemByIndex(L^.NauczycielIndex));
  if Assigned(N) then GetText:=N^.GetText(MaxLen)
  else GetText:='';
end;

{ TPlanLekcjiKlasaWindow }

{ TPlanLekcjiSalaWindow }

{ procedury uruchamiaj¥ce edycj© planu zaj©† wybranego elementu skˆadowego }

procedure RunPlanLekcjiNauczyciela;
var
  Win: PPlanLekcjiNauczycielWindow;
  Data: PNauczyciel;
  S: String;
begin
  Data:=ChooseNauczyciel(Nauczyciele);
  if not Assigned(Data) then Exit;
  Win:=PPlanLekcjiNauczycielWindow(ResourceFile.Get('PlanLekcjiNauczycielWindow'));
  if LoadSuccessful(Win) then
  begin
    if not Assigned(Data^.ImieNazwisko) then S:=''
    else S:=Data^.ImieNazwisko^;
    Win^.SetTitle('Edycja planu lekcji dla: '+S);
    Win^.SetDzwonkiList(Dzwonki);
    Win^.SetEditorData(Data);
    Win^.UpdateLists;
    Application^.InsertWindow(Win);
  end;
end;

{ *** }

procedure RegisterSpecWins;
begin
  RegisterType(RHighlightedLabel);
  RegisterType(RDzwonekListView);
  RegisterType(RLekcjaListView);
  RegisterType(RLekcjaDetailView);
  RegisterType(RInsideFrames);
  RegisterType(RPlanLekcjiWindow);
  RegisterType(RPlanLekcjiNauczycielWindow);
  RegisterType(RPlanLekcjiKlasaWindow);
  RegisterType(RPlanLekcjiSalaWindow);
end;

begin
end.

