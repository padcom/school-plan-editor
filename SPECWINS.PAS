Unit SpecWins;

interface
uses
  App, Objects, Drivers, Views, Dialogs,
  DataObjects, DataDialogs, Stale,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja,
  HostWin;

type { typ opisuj¥cy list box dzwonk¢w }
  PDzwonekListView = ^TDzwonekListView;
  TDzwonekListView = object (TDataListBox)
    function GetPalette: PPalette; virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
  end;

type { typ opisuj¥cy widok listy lekcji dla poszczeg¢lnego dnia }
  PLekcjaListView = ^TLekcjaListView;
  TLekcjaListView = object (TListBox)
    function GetPalette: PPalette; virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure FocusItem(Item: Integer); virtual;
    procedure NewList(AList: PCollection); virtual;
  end;

type { typ opisuj¥cy widok ramek w ˜rodku okna edycji planu lekcji }
  PInsideFrames = ^TInsideFrames;
  TInsideFrames = object (TView)
    procedure Draw; virtual;
  end;

type { typ opisuj¥cy okno edycji planu lekcji dla wybranego elementu planu }
  PIndividualEditWindow = ^TIndividualEditWindow;
  TIndividualEditWindow = object (THostEditWindow)
    FirstDzien: Integer;
    SelectedDzien: Integer;
    DzwonekListView: PDzwonekListView;
    DzwonekLabel: PHighlightedLabel;
    LekcjaListView: array[1..4] of PLekcjaListView;
    LekcjaLabel: array[1..4] of PHighlightedLabel;
    InsideFrames: PInsideFrames;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SizeLimits(var Min, Max: TPoint); virtual;
    procedure Store(var S: TStream); virtual;
    procedure Zoom; virtual;

    function CompareData(LekcjaData: PLekcja; DzwonekPos: Integer): Boolean; virtual;
    function GetCurrentDzien: Integer; virtual;
    function GetCurrentDzwonekPos: Integer; virtual;
    function GetCurrentDzwonekIndex: Integer; virtual;
    procedure UpdateDzwonekListView; virtual;
    procedure UpdateLekcjaListView; virtual;

    function GetText(Item: Integer; MaxLen: Integer; List: PDataCollection): String; virtual;
    procedure UpdateLabels; virtual;

    procedure ViewStatistics; virtual;
    procedure Print; virtual;
  end;

type { typ opisuj¥cy okno edycji planu lekcji nauczyciela }
  PNauczycielEditWindow = ^TNauczycielEditWindow;
  TNauczycielEditWindow = object (TIndividualEditWindow)
    function CompareData(LekcjaData: PLekcja; DzwonekPos: Integer): Boolean; virtual;
    function GetText(Item: Integer; MaxLen: Integer; List: PDataCollection): String; virtual;
  end;

type { typ opisuj¥cy okno edycji planu lekcji nauczyciela }
  PKlasaEditWindow = ^TKlasaEditWindow;
  TKlasaEditWindow = object (TIndividualEditWindow)
    function CompareData(LekcjaData: PLekcja; DzwonekPos: Integer): Boolean; virtual;
    function GetText(Item: Integer; MaxLen: Integer; List: PDataCollection): String; virtual;
    procedure ViewStatistics; virtual;
  end;

procedure RunPlanLekcjiNauczyciela;
procedure RunPlanLekcjiKlasy;

const
  RDzwonekListView: TStreamRec = (
    ObjType: $B000;
    VmtLink: Ofs(TypeOf(TDzwonekListView)^);
    Load   : @TDzwonekListView.Load;
    Store  : @TDzwonekListView.Store);
  RLekcjaListView: TStreamRec = (
    ObjType: $B001;
    VmtLink: Ofs(TypeOf(TLekcjaListView)^);
    Load   : @TLekcjaListView.Load;
    Store  : @TLekcjaListView.Store);
  RInsideFrames: TStreamRec = (
    ObjType: $B002;
    VmtLink: Ofs(TypeOf(TInsideFrames)^);
    Load   : @TInsideFrames.Load;
    Store  : @TInsideFrames.Store);
  RIndividualEditWindow: TStreamRec = (
    ObjType: $B003;
    VmtLink: Ofs(TypeOf(TIndividualEditWindow)^);
    Load   : @TIndividualEditWindow.Load;
    Store  : @TIndividualEditWindow.Store);
  RNauczycielEditWindow: TStreamRec = (
    ObjType: $B004;
    VmtLink: Ofs(TypeOf(TNauczycielEditWindow)^);
    Load   : @TNauczycielEditWindow.Load;
    Store  : @TNauczycielEditWindow.Store);
  RKlasaEditWindow: TStreamRec = (
    ObjType: $B005;
    VmtLink: Ofs(TypeOf(TKlasaEditWindow)^);
    Load   : @TKlasaEditWindow.Load;
    Store  : @TKlasaEditWindow.Store);

procedure RegisterSpecWins;

implementation
uses
  Resource, DataBase, Statystyka, Latin2, Crt, Drukowanie;

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
  GetText:=PIndividualEditWindow(Owner)^.GetText(Item, MaxLen, PDataCollection(List));
end;

const
  DisableUpdates: Boolean = False;

procedure TLekcjaListView.FocusItem;
var
  Event: TEvent;
  I: Integer;
begin
  inherited FocusItem(Item);
  with PIndividualEditWindow(Owner)^ do
  begin
    DzwonekListView^.FocusItem(Item);
    DzwonekListView^.DrawView;
    if not DisableUpdates then
    begin
      for I:=1 to 4 do with LekcjaListView[I]^ do
      begin
        DisableUpdates:=True;
        FocusItem(Item);
        DrawView;
        DisableUpdates:=False;
      end;
    end;
  end;
  Event.What:=evBroadcast;
  Event.Command:=cmUpdateLekcjaDetailView;
  Event.InfoPtr:=nil;
  Owner^.HandleEvent(Event);
end;

procedure TLekcjaListView.NewList;
begin
  if List <> nil then Dispose(List, Done);
  List := AList;
  SetRange(Dzwonki^.Count);
  if Range > 0 then FocusItem(0);
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

{ TIndividualEditWindow }

constructor TIndividualEditWindow.Load;
var
  I: Integer;
begin
  inherited Load(S);
  GetSubViewPtr(S, DzwonekListView);
  GetSubViewPtr(S, DzwonekLabel);
  for I:=1 to 4 do GetSubViewPtr(S, LekcjaListView[I]);
  for I:=1 to 4 do GetSubViewPtr(S, LekcjaLabel[I]);
  GetSubViewPtr(S, InsideFrames);
  S.Read(FirstDzien, SizeOf(FirstDzien));
  S.Read(SelectedDzien, SizeOf(SelectedDzien));
end;

procedure TIndividualEditWindow.HandleEvent;
begin
  if Event.What=evKeyboard then
  begin
    case Event.KeyCode of
      kbLeft:
      begin
        Lock;
        if SelectedDzien=1 then ClearEvent(Event)
        else
        begin
          Dec(SelectedDzien);
          if SelectedDzien<FirstDzien then
          begin
            FirstDzien:=SelectedDzien;
            UpdateLabels;
          end
          else SelectNext(True);
          UpdateLists;
        end;
        Unlock;
      end;
      kbRight:
      begin
        Lock;
        if SelectedDzien=IloscDni then ClearEvent(Event)
        else
        begin
          Inc(SelectedDzien);
          if SelectedDzien-3>FirstDzien then
          begin
            FirstDzien:=SelectedDzien-3;
            UpdateLabels;
          end
          else SelectNext(False);
          UpdateLists;
        end;
        Unlock;
      end;
      kbEsc:
      begin
        Close;
        ClearEvent(Event);
      end;
      kbF2:
      begin
        ViewStatistics;
        ClearEvent(Event);
      end;
      kbCtrlF2:
      begin
        Print;
        ClearEvent(Event);
      end;
    end;
  end;
  inherited HandleEvent(Event);
end;

procedure TIndividualEditWindow.SizeLimits;
begin
  inherited SizeLimits(Min, Max);
  Min.X:=72; Min.Y:=11;
  Max.X:=72;
end;

procedure TIndividualEditWindow.Store;
var
  I: Integer;
begin
  inherited Store(S);
  PutSubViewPtr(S, DzwonekListView);
  PutSubViewPtr(S, DzwonekLabel);
  for I:=1 to 4 do PutSubViewPtr(S, LekcjaListView[I]);
  for I:=1 to 4 do PutSubViewPtr(S, LekcjaLabel[I]);
  PutSubViewPtr(S, InsideFrames);
  S.Write(FirstDzien, SizeOf(FirstDzien));
  S.Write(SelectedDzien, SizeOf(SelectedDzien));
end;

procedure TIndividualEditWindow.Zoom;
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

function TIndividualEditWindow.CompareData;
begin
  if not inherited CompareData(LekcjaData, DzwonekPos) then CompareData:=False
  else CompareData:=True;
end;

function TIndividualEditWindow.GetCurrentDzien;
begin
  GetCurrentDzien:=SelectedDzien;
end;

function TIndividualEditWindow.GetCurrentDzwonekPos;
begin
  if not Assigned(DzwonekListView^.List) then GetCurrentDzwonekPos:=-1
  else GetCurrentDzwonekPos:=DzwonekListView^.Focused;
end;

function TIndividualEditWindow.GetCurrentDzwonekIndex;
var
  Temp: PDzwonek;
begin
  if not Assigned(DzwonekListView^.List) then GetCurrentDzwonekIndex:=-1
  else if DzwonekListView^.List^.Count=0 then GetCurrentDzwonekIndex:=-1
  else
  begin
    Temp:=Dzwonki^.At(DzwonekListView^.Focused);
    if not Assigned(Temp) then GetCurrentDzwonekIndex:=-1
    else GetCurrentDzwonekIndex:=Temp^.Index;
  end;
end;

procedure TIndividualEditWindow.UpdateDzwonekListView;
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

procedure TIndividualEditWindow.UpdateLekcjaListView;
var
  I: Integer;
  Position: Integer;
begin
  for I:=1 to 4 do
  begin
    Position:=LekcjaListView[I]^.Focused;
    LekcjaListView[I]^.List:=nil;
    LekcjaListView[I]^.NewList(Lekcje[FirstDzien+I-1]);
    LekcjaListView[I]^.FocusItem(Position);
    LekcjaListView[I]^.DrawView;
  end;
end;

function TIndividualEditWindow.GetText;
begin
  GetText:='';
end;

procedure TIndividualEditWindow.UpdateLabels;
var
  I: Integer;
begin
  for I:=1 to 4 do
  begin
    if Assigned(LekcjaLabel[I+1]^.Text) then DisposeStr(LekcjaLabel[I]^.Text);
    LekcjaLabel[I]^.Text:=NewStr(NazwyDniTygodnia[FirstDzien+I-1]);
    LekcjaLabel[I]^.DrawView;
  end;
end;

procedure TIndividualEditWindow.ViewStatistics;
begin
end;

procedure TIndividualEditWindow.Print;
var
  F: Text;
  S, T: String;
  I, J, D: Integer;
  C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12: Char;
  ColWidth: Word;
  R: TRect;
  Dialog: PDialog;
  TempFile: String;
begin
  TempFile:='C:\WYDRUK.TMP';

  R.Assign(0, 0, 50, 7);
  New(Dialog, Init(R, 'Informacja'));
  with Dialog^ do Options:=Options or ofCentered;
  R.Assign(1, 3, Dialog^.Size.X-1, 5);
  Dialog^.Insert(New(PStaticText, Init(R, #3'Przygotowanie wydruku - Prosz© czeka†')));
  Application^.InsertWindow(Dialog);

  ColWidth:=18;
  C1:='Ä'; C2:='³'; C3:='Å'; C4:='Â'; C5:='Á'; C6:='Ã'; C7:='´'; C9:='Ú'; C10:='¿'; C11:='Ù'; C12:='À';

  if (not Assigned(Dzwonki)) or Dzwonki^.Empty then Exit;

  I:=Pos(':', Title^);
  if I=0 then Exit;

  S:=Copy(Title^, I+2, Length(Title^)-I);
  Assign(F, TempFile);
  Rewrite(F);

  Writeln(F, '\FONT:FINE');
  Writeln(F, '\DPI:75');
  Writeln(F);
  Writeln(F, 'Plan lekcji dla: ', S);
  Writeln(F);
  Writeln(F);
  Writeln(F, '\DPI:150');

  S:=RepeatStr(C1, IloscDni*ColWidth+11);
  S[10]:=C4; S[11]:=C4; for I:=1 to IloscDni-1 do S[(I*ColWidth)+11]:=C4;
  Writeln(F, S);

  S:=RepeatStr(' ', IloscDni*ColWidth+11);
  S[10]:=C2; S[11]:=C2; for I:=1 to IloscDni-1 do S[(I*ColWidth)+11]:=C2;
  T:='Dzwonek';
  for I:=1 to Length(T) do S[I+1]:=T[I];
  for I:=1 to IloscDni do for J:=1 to Length(NazwyDniTygodnia[I]) do S[(I-1)*ColWidth+12+J]:=NazwyDniTygodnia[I, J];
  Writeln(F, S);

  S:=RepeatStr(C1, IloscDni*ColWidth+11);
  S[10]:=C3; S[11]:=C3; for I:=1 to IloscDni-1 do S[(I*ColWidth)+11]:=C3;
  Writeln(F, S);

  for I:=0 to Dzwonki^.Count-1 do
  begin
    S:=RepeatStr(' ', IloscDni*ColWidth+11);
    S[10]:=C2; S[11]:=C2; for J:=1 to IloscDni-1 do S[(J*ColWidth)+11]:=C2;

    T:=DzwonekListView^.GetText(I, 9);
    for J:=1 to Length(T) do S[J+2]:=T[J];

    for D:=1 to IloscDni do
    begin
      T:=GetText(I, ColWidth-2, Lekcje[D]);
      if T<>'' then for J:=1 to Length(T) do S[(D-1)*ColWidth+12+J]:=T[J];
    end;

    Writeln(F, S);
  end;

  S:=RepeatStr(C1, IloscDni*ColWidth+11);
  S[10]:=C5; S[11]:=C5; for I:=1 to IloscDni-1 do S[(I*ColWidth)+11]:=C5;
  Writeln(F, S);

  Writeln(F);
  Writeln(F, '\DPI:300');
  Writeln(F, 'Plan lekcji wesja 1.3.54');
  Writeln(F, '(C) by Grand s.c.');

  Writeln(F);
  Writeln(F);

  System.Close(F);
  Delay(1000);
  Dialog^.Close;

  R.Assign(0, 0, 50, 7);
  New(Dialog, Init(R, 'Informacja'));
  with Dialog^ do Options:=Options or ofCentered;
  R.Assign(1, 3, Dialog^.Size.X-1, 5);
  Dialog^.Insert(New(PStaticText, Init(R, #3'Trwa wydruk - Prosz© czeka†')));
  Application^.InsertWindow(Dialog);

  Drukowanie.PrintFile(TempFile);
  Delay(1000);

  Dialog^.Close;
end;

{ TNauczycielEditWindow }

function TNauczycielEditWindow.CompareData;
begin
  if not inherited CompareData(LekcjaData, DzwonekPos) then CompareData:=False
  else if not Assigned(Data) then CompareData:=False
  else if Data^.Index<>LekcjaData^.NauczycielIndex then CompareData:=False
  else CompareData:=True;
end;

function TNauczycielEditWindow.GetText;
var
  L: PLekcja;
  P: PPrzedmiot;
  K: PKlasa;
  S: PSala;
  St, S2: String;
begin
  L:=GetLekcja(List, Item);
  if not Assigned(L) then GetText:=''
  else
  begin
    P:=PPrzedmiot(Przedmioty^.ItemByIndex(L^.PrzedmiotIndex));
    K:=PKlasa(Klasy^.ItemByIndex(L^.KlasaIndex));
    S:=PSala(Sale^.ItemByIndex(L^.SalaIndex));
    St:='';
    if Assigned(P) and Assigned(P^.Skrot) then St:=St+P^.Skrot^
    else St:=St+'BRAK';
    St:=Copy(St, 1, 4); while Length(St)<4 do St:=St+' ';

    if Assigned(K) then
    begin
      Str(K^.Numer, S2);
      St:=St+'\'+S2+K^.Litera;
    end
    else St:=St+'\BRAK';
    St:=Copy(St, 1, 9); while Length(St)<9 do St:=St+' ';

    if Assigned(S) and Assigned(S^.Numer) then St:=St+'\'+S^.Numer^
    else St:=St+'\BRAK';

{    St:=Copy(St, 1, 14); while Length(St)<14 do St:=St+' ';}
    GetText:=St;
  end;
end;

{ TKlasaEditWindow }

function TKlasaEditWindow.CompareData;
begin
  if not inherited CompareData(LekcjaData, DzwonekPos) then CompareData:=False
  else if not Assigned(Data) then CompareData:=False
  else if Data^.Index<>LekcjaData^.KlasaIndex then CompareData:=False
  else if PKlasa(Data)^.Grupy and LekcjaData^.Grupy=0 then CompareData:=False
  else CompareData:=True;
end;

function TKlasaEditWindow.GetText;
var
  L: PLekcja;
  N: PNauczyciel;
  P: PPrzedmiot;
  S: PSala;
  St, S2: String;
begin
  L:=GetLekcja(List, Item);
  if not Assigned(L) then GetText:=''
  else
  begin
    N:=PNauczyciel(Nauczyciele^.ItemByIndex(L^.NauczycielIndex));
    P:=PPrzedmiot(Przedmioty^.ItemByIndex(L^.PrzedmiotIndex));
    S:=PSala(Sale^.ItemByIndex(L^.SalaIndex));
    St:='';
    if Assigned(P) and Assigned(P^.Skrot) then St:=St+P^.Skrot^
    else St:=St+'BRAK';
    St:=Copy(St, 1, 4); while Length(St)<4 do St:=St+' ';

    if Assigned(N) then St:=St+'\'+N^.Skrot^
    else St:=St+'\BRAK';
    St:=Copy(St, 1, 9); while Length(St)<9 do St:=St+' ';

    if Assigned(S) and Assigned(S^.Numer) then St:=St+'\'+S^.Numer^
    else St:=St+'\BRAK';
    St:=Copy(St, 1, 14); while Length(St)<14 do St:=St+' ';

    GetText:=St;
  end;
end;

procedure TKlasaEditWindow.ViewStatistics;
var
  R: TRect;
  D: PDialog;
  Rec: record
    List: PStatisticList;
    Item: Integer;
  end;
  Item: PStatisticListItem;
  I, J, Position: Integer;
  L: PLekcja;
  P: PPrzedmiot;
begin
  New(Rec.List, Init(10, 5));
  Rec.Item:=0;

  if Assigned(Dzwonki) and (not Dzwonki^.Empty) then for I:=1 to IloscDni do
  begin
    for J:=0 to Dzwonki^.Count-1 do
    begin
      L:=nil;
      if Assigned(Lekcje[I]) then L:=GetLekcja(Lekcje[I], J);
      if Assigned(L) then
      begin
        P:=PPrzedmiot(Przedmioty^.ItemByIndex(L^.PrzedmiotIndex));
        if Assigned(P) then
        begin
          New(Item, Init(P^.Nazwa^));
          if not Rec.List^.Search(Item, Position) then Rec.List^.Insert(Item)
          else
          begin
            Dispose(Item, Done);
            Item:=Rec.List^.At(Position);
            Inc(Item^.Count);
          end;
        end;
      end;
    end;
  end;

  D:=PDialog(ResourceFile.Get('StatisticDialog'));
  if LoadSuccessful(D) then Application^.ExecuteDialog(D, @Rec);

  Dispose(Rec.List, Done);
end;

{ procedury uruchamiaj¥ce edycj© planu zaj©† wybranego elementu skˆadowego }

procedure RunPlanLekcjiNauczyciela;
var
  Win: PNauczycielEditWindow;
  Data: PNauczyciel;
  S: String;
begin
  Data:=ChooseNauczyciel(Nauczyciele);
  if not Assigned(Data) then Exit;
  Win:=PNauczycielEditWindow(ResourceFile.Get('NauczycielEditWindow'));
  if LoadSuccessful(Win) then
  begin
    if not Assigned(Data^.ImieNazwisko) then S:=''
    else S:=Data^.ImieNazwisko^;
    Win^.SetTitle('Edycja planu lekcji dla: '+S);
    Win^.SetEditorData(Data);
    Win^.UpdateLists;
    Win^.HelpCtx:=Win^.HelpCtx+1;
    Application^.InsertWindow(Win);
  end;
end;

procedure RunPlanLekcjiKlasy;
var
  Win: PKlasaEditWindow;
  Data: PKlasa;
  S, S2: String;
  I, W: Word;
begin
  Data:=ChooseKlasa(Klasy, True);
  if not Assigned(Data) then Exit;
  Win:=PKlasaEditWindow(ResourceFile.Get('KlasaEditWindow'));
  if LoadSuccessful(Win) then
  begin
    W:=Data^.Grupy;
    Str(W, S2);
    Str(Data^.Numer, S);
    S:='Klasa '+S+Data^.Litera;
    if Data^.Grupy>0 then S:=S+', grupa: '+S2;
    Win^.SetTitle('Edycja planu lekcji dla: '+S);
    Win^.SetEditorData(Data);
    Win^.UpdateLists;
    Win^.HelpCtx:=Win^.HelpCtx+2;
    Application^.InsertWindow(Win);
  end;
end;

{ *** }

procedure RegisterSpecWins;
begin
  RegisterType(RDzwonekListView);
  RegisterType(RLekcjaListView);
  RegisterType(RInsideFrames);
  RegisterType(RIndividualEditWindow);
  RegisterType(RNauczycielEditWindow);
  RegisterType(RKlasaEditWindow);
end;

begin
end.
