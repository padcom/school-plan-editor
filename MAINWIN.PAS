Unit MainWin;

interface
uses
  App, Objects, Drivers, Views, Dialogs,
  DataObjects, DataDialogs, Stale,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja,
  HostWin;

type { typ opisuj¥cy widok listy dni tygodnia }
  PDzienTygodniaListView = ^TDzienTygodniaListView;
  TDzienTygodniaListView = object (TListBox)
    function GetPalette: PPalette; virtual;
    procedure FocusItem(Item: Integer); virtual;
  end;

type { typ opisuj¥cy widok listy dzwonk¢w }
  PDzwonekListView = ^TDzwonekListView;
  TDzwonekListView = object (TDataListBox)
    function GetPalette: PPalette; virtual;
    procedure FocusItem(Item: Integer); virtual;
  end;

type { typ opisuj¥cy widok listy lekcji }
  PLekcjaListView = ^TLekcjaListView;
  TLekcjaListView = object (TListBox)
    function GetPalette: PPalette; virtual;
    procedure FocusItem(Item: Integer); virtual;
    procedure Draw; virtual;
  end;

type { typ opisuj¥cy gˆ¢wne ramki wewn©trzne okna }
  PInsideFrames = ^TInsideFrames;
  TInsideFrames = object (TView)
    procedure Draw; virtual;
  end;

type { typ opisuj¥cy gˆ¢wne okno programu }
  PMainEditWindow = ^TMainEditWindow;
  TMainEditWindow = object (THostEditWindow)
    InsideFrames: PInsideFrames;
    DzienTygodniaListView: PDzienTygodniaListView;
    DzienTygodniaLabel: PHighlightedLabel;
    DzwonekListView: PDzwonekListView;
    DzwonekListLabel: PHighlightedLabel;
    LekcjaListView: PLekcjaListView;
    LekcjaListLabel: PHighlightedLabel;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream); virtual;

    function GetCurrentDzien: Integer; virtual;
    function GetCurrentLekcja: PLekcja; virtual;
    function GetCurrentDzwonekPos: Integer; virtual;
    function GetCurrentDzwonekIndex: Integer; virtual;
    procedure UpdateDzwonekListView; virtual;
    procedure UpdateLekcjaListView; virtual;
  end;

const
  RDzienTygodniaListView: TStreamRec = (
    ObjType: $A000;
    VmtLink: Ofs(TypeOf(TDzienTygodniaListView)^);
    Load   : @TDzienTygodniaListView.Load;
    Store  : @TDzienTygodniaListView.Store);
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
  RInsideFrames: TStreamRec = (
    ObjType: $A003;
    VmtLink: Ofs(TypeOf(TInsideFrames)^);
    Load   : @TInsideFrames.Load;
    Store  : @TInsideFrames.Store);
  RMainEditWindow: TStreamRec = (
    ObjType: $A004;
    VmtLink: Ofs(TypeOf(TMainEditWindow)^);
    Load   : @TMainEditWindow.Load;
    Store  : @TMainEditWindow.Store);

procedure RegisterMainWin;

implementation

const
  DisableUpdates: Boolean = False;

{ TDzienTygodniaListView }

function TDzienTygodniaListView.GetPalette;
const
  S: String = CListViewer;
begin
  S[1]:=#2; S[3]:=#4;
  S[2]:=#2; S[4]:=#4;
  GetPalette:=@S;
end;

procedure TDzienTygodniaListView.FocusItem;
var
  Event: TEvent;
begin
  inherited FocusItem(Item);
{  if not DisableUpdates then}
  begin
    DisableUpdates:=True;
    Event.What:=evBroadcast;
    Event.Command:=cmUpdateLekcjaListView;
    Event.InfoPtr:=nil;
    Owner^.HandleEvent(Event);
    DisableUpdates:=False;
  end;
end;

{ TDzwonekListView }

function TDzwonekListView.GetPalette;
const
  S: String = CListViewer;
begin
  S[1]:=#2; S[3]:=#4;
  S[2]:=#2; S[4]:=#4;
  GetPalette:=@S;
end;

procedure TDzwonekListView.FocusItem;
var
  Event: TEvent;
begin
  inherited FocusItem(Item);
{  if not DisableUpdates then}
  begin
    DisableUpdates:=True;
    Event.What:=evBroadcast;
    Event.Command:=cmUpdateLekcjaListView;
    Event.InfoPtr:=nil;
    Owner^.HandleEvent(Event);
    DisableUpdates:=False;
  end;
end;

{ TLekcjaListView }

function TLekcjaListView.GetPalette;
const
  S: String = CListViewer;
begin
  S[1]:=#2; S[3]:=#4;
  S[2]:=#2; S[4]:=#4;
  GetPalette:=@S;
end;

procedure TLekcjaListView.Draw;
var
  Buf: TDrawBuffer;
  Color: Word;
  C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12: Char;
  Y: Integer;
  L: PLekcja;
  N: PNauczyciel;
  P: PPrzedmiot;
  K: PKlasa;
  S: PSala;
  St: String;
  I, W: Word;
begin
  C1:='Ä'; C2:='³'; C3:='Å'; C4:='Â'; C5:='Á'; C6:='Ã'; C7:='´'; C9:='Ú'; C10:='¿'; C11:='Ù'; C12:='À';
  for Y:=0 to Size.Y do
  begin
    Color:=GetColor(2);
    MoveChar(Buf, ' ', Color, Size.X);
    MoveChar(Buf[8], C2, Color, 1);
    MoveChar(Buf[20], C2, Color, 1);
    MoveChar(Buf[28], C2, Color, 1);
    MoveChar(Buf[39], C2, Color, 1);

    if Y+TopItem=Focused then Color:=GetColor(4);
    if not Assigned(List) or (List^.Count=0) or (Y+TopItem>=List^.Count) then
    begin
      Color:=GetColor(2);
      L:=nil;
    end
    else L:=List^.At(Y+TopItem);

    if not Assigned(L) then
    begin
      St:='        '; MoveStr(Buf, St, Color);
      St:='           '; MoveStr(Buf[9], St, Color);
      St:='       '; MoveStr(Buf[21], St, Color);
      St:='          '; MoveStr(Buf[29], St, Color);
      St:='        '; MoveStr(Buf[40], St, Color);
    end
    else
    begin
      { nauczyciel }
      if not Assigned(Nauczyciele) then N:=nil
      else
      begin
        N:=PNauczyciel(Nauczyciele^.ItemByIndex(L^.NauczycielIndex));
        if not Assigned(N) then St:='BRAK!'
        else if not Assigned(N^.Skrot) then St:='BRAK!'
        else St:=N^.Skrot^;
      end;
      while Length(St)<7 do St:=St+' ';
      St:=' '+St;
      MoveStr(Buf, St, Color);

      { przedmiot }
      if not Assigned(Przedmioty) then P:=nil
      else
      begin
        P:=PPrzedmiot(Przedmioty^.ItemByIndex(L^.PrzedmiotIndex));
        if not Assigned(P) then St:='BRAK!'
        else if not Assigned(P^.Skrot) then St:='BRAK!'
        else St:=P^.Skrot^;
      end;
      while Length(St)<10 do St:=St+' ';
      St:=' '+St;
      MoveStr(Buf[9], St, Color);

      { klasa }
      if not Assigned(Klasy) then K:=nil
      else
      begin
        K:=PKlasa(Klasy^.ItemByIndex(L^.KlasaIndex));
        if not Assigned(K) then St:='BRAK!'
        else St:=K^.GetText(5);
      end;
      while Length(St)<6 do St:=St+' ';
      St:=' '+St;
      MoveStr(Buf[21], St, Color);

      { grupy klasy }
      if not Assigned(K) then St:='--------'
      else
      begin
        St:='';
        W:=1;
        for I:=1 to 8 do
        begin
          if (L^.Grupy and W)<>0 then St:=St+'*'
          else St:=St+'-';
          W:=W shl 1;
        end;
      end;
      St:=' '+St+' ';
      MoveStr(Buf[29], St, Color);

      { sala }
      if not Assigned(Sale) then S:=nil
      else
      begin
        S:=PSala(Sale^.ItemByIndex(L^.SalaIndex));
        if not Assigned(S) then St:='BRAK!'
        else if not Assigned(S^.Numer) then St:='BRAK!'
        else St:=S^.Numer^;
      end;
      while Length(St)<7 do St:=St+' ';
      St:=' '+St;
      MoveStr(Buf[40], St, Color);
    end;

    WriteLine(0, Y, Size.X, 1, Buf);
  end;
end;

procedure TLekcjaListView.FocusItem;
var
  Event: TEvent;
begin
  inherited FocusItem(Item);
  DisableUpdates:=True;
  Event.What:=evBroadcast;
  Event.Command:=cmUpdateLekcjaDetailView;
  Event.InfoPtr:=nil;
  Owner^.HandleEvent(Event);
  DisableUpdates:=False;
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
  MoveChar(Buf[14], C2, Color, 1);
  MoveChar(Buf[29], C2, Color, 1);
  MoveChar(Buf[28], C2, Color, 1);
  WriteLine(0, 0, Size.X, 1, Buf);

  { linia rozdzielaj¥ca etykiety i listy }
  MoveChar(Buf, C1, Color, Size.X);
  MoveChar(Buf[14], C3, Color, 1);
  MoveChar(Buf[29], C3, Color, 1);
  MoveChar(Buf[28], C3, Color, 1);
  MoveChar(Buf[38], C4, Color, 1);
  MoveChar(Buf[50], C4, Color, 1);
  MoveChar(Buf[58], C4, Color, 1);
  MoveChar(Buf[69], C4, Color, 1);
  WriteLine(0, 1, Size.X, 1, Buf);

  { obszar list }
  MoveChar(Buf, ' ', Color, Size.X);
  MoveChar(Buf[14], C2, Color, 1);
  MoveChar(Buf[29], C2, Color, 1);
  MoveChar(Buf[28], C2, Color, 1);
  WriteLine(0, 2, Size.X, Size.Y-7, Buf);

  { linia rozdzielaj¥ca listy i widoku szczeg¢ˆowego lekcji }
  MoveChar(Buf, C1, Color, Size.X);
  MoveChar(Buf[14], C5, Color, 1);
  MoveChar(Buf[29], C5, Color, 1);
  MoveChar(Buf[28], C5, Color, 1);
  MoveChar(Buf[38], C5, Color, 1);
  MoveChar(Buf[50], C5, Color, 1);
  MoveChar(Buf[58], C5, Color, 1);
  MoveChar(Buf[69], C5, Color, 1);
  WriteLine(0, Size.Y-6, Size.X, 1, Buf);

  MoveChar(Buf, ' ', Color, Size.X);
  WriteLine(0, Size.Y-5, Size.X, 5, Buf);
end;

{ TMainEditWindow }

constructor TMainEditWindow.Load;
begin
  inherited Load(S);
  GetSubViewPtr(S, DzienTygodniaListView);
  GetSubViewPtr(S, DzienTygodniaLabel);
  GetSubViewPtr(S, DzwonekListView);
  GetSubViewPtr(S, DzwonekListLabel);
  GetSubViewPtr(S, LekcjaListView);
  GetSubViewPtr(S, LekcjaListLabel);
  GetSubViewPtr(S, InsideFrames);
end;

procedure TMainEditWindow.HandleEvent;
begin
  if Event.What=evKeyboard then
  begin
    case Event.KeyCode of
      kbLeft:
      begin
        if Current<>PView(DzienTygodniaListView) then SelectNext(True);
        ClearEvent(Event);
      end;
      kbRight:
      begin
        if Current<>PView(LekcjaListView) then SelectNext(False);
        ClearEvent(Event);
      end;
    end;
  end;
  inherited HandleEvent(Event);
end;

procedure TMainEditWindow.Store;
begin
  inherited Store(S);
  PutSubViewPtr(S, DzienTygodniaListView);
  PutSubViewPtr(S, DzienTygodniaLabel);
  PutSubViewPtr(S, DzwonekListView);
  PutSubViewPtr(S, DzwonekListLabel);
  PutSubViewPtr(S, LekcjaListView);
  PutSubViewPtr(S, LekcjaListLabel);
  PutSubViewPtr(S, InsideFrames);
end;

function TMainEditWindow.GetCurrentDzien;
begin
  if not Assigned(DzienTygodniaListView) then GetCurrentDzien:=-1
  else if not Assigned(DzienTygodniaListView^.List) then GetCurrentDzien:=-1
  else if DzienTygodniaListView^.List^.Count=0 then GetCurrentDzien:=-1
  else GetCurrentDzien:=DzienTygodniaListView^.Focused+1;
end;

function TMainEditWindow.GetCurrentDzwonekPos;
begin
  if not Assigned(DzwonekListView) then GetCurrentDzwonekPos:=-1
  else if not Assigned(DzwonekListView^.List) then GetCurrentDzwonekPos:=-1
  else if DzwonekListView^.List^.Count=0 then GetCurrentDzwonekPos:=-1
  else GetCurrentDzwonekPos:=DzwonekListView^.Focused;
end;

function TMainEditWindow.GetCurrentDzwonekIndex;
var
  Temp: PDzwonek;
begin
  if not Assigned(DzwonekListView) then GetCurrentDzwonekIndex:=-1
  else if not Assigned(DzwonekListView^.List) then GetCurrentDzwonekIndex:=-1
  else if DzwonekListView^.List^.Count=0 then GetCurrentDzwonekIndex:=-1
  else with DzwonekListView^ do
  begin
    Temp:=List^.At(Focused);
    if Temp=nil then GetCurrentDzwonekIndex:=-1
    else GetCurrentDzwonekIndex:=Temp^.Index;
  end;
end;

function TMainEditWindow.GetCurrentLekcja;
begin
  if not Assigned(LekcjaListView) then GetCurrentLekcja:=nil
  else if not Assigned(LekcjaListView^.List) then GetCurrentLekcja:=nil
  else if LekcjaListView^.List^.Count=0 then GetCurrentLekcja:=nil
  else GetCurrentLekcja:=LekcjaListView^.List^.At(LekcjaListView^.Focused);
end;

procedure TMainEditWindow.UpdateDzwonekListView;
var
  Item: Integer;
begin
  { aktualizacja listy dzwonk¢w }
  Item:=DzwonekListView^.Focused;
  DzwonekListView^.List:=nil;
  DzwonekListView^.NewList(Dzwonki);
  if Item>DzwonekListView^.List^.Count then Item:=DzwonekListView^.List^.Count;
  if Item<0 then Item:=0;
  DzwonekListView^.FocusItem(Item);
end;

procedure TMainEditWindow.UpdateLekcjaListView;
var
  I, Item: Integer;
  Temp: PLekcja;
  List: PDataCollection;
begin
  { aktualizacja listy lekcji }
  if Assigned(LekcjaListView) then
  begin
    New(List, Init(10, 5));
    Item:=DzwonekListView^.Focused;
    if Assigned(LekcjaListView^.List) then
    begin
      LekcjaListView^.List^.DeleteAll;
      Dispose(LekcjaListView^.List, Done);
      LekcjaListView^.List:=nil;
    end;

    I:=0;
    while I<Lekcje[GetCurrentDzien]^.Count do
    begin
      Temp:=Lekcje[GetCurrentDzien]^.At(I);
      if CompareData(Temp, GetCurrentDzwonekIndex) then List^.Insert(Temp);
      Inc(I);
    end;

    LekcjaListView^.NewList(List);
    if Item>LekcjaListView^.List^.Count then Item:=LekcjaListView^.List^.Count;
    if Item<0 then Item:=0;
    LekcjaListView^.FocusItem(Item);
  end;
end;

{ *** }

procedure RegisterMainWin;
begin
  RegisterType(RDzienTygodniaListView);
  RegisterType(RDzwonekListView);
  RegisterType(RLekcjaListView);
  RegisterType(RInsideFrames);
  RegisterType(RMainEditWindow);
end;

begin
end.
