Unit HostWin;

interface
uses
  App, Objects, Drivers, Views, Dialogs,
  DataObjects, DataDialogs, Stale,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja;

type { typ opisuj¥cy pod˜wietlany Label }
  PHighlightedLabel = ^THighlightedLabel;
  THighlightedLabel = object (TLabel)
    constructor Load(var S: TStream);
    function GetPalette: PPalette; virtual;
  end;

type { typ opisuj¥cy widok detali lekcji }
  PLekcjaDetailView = ^TLekcjaDetailView;
  TLekcjaDetailView = object (TView)
    function GetPalette: PPalette; virtual;
    procedure Draw; virtual;
  end;

type { typ opisuj¥cy nadrz©dne ze wzgl©du na dziedziczenie okno edycji planu zaj©† }
  PHostEditWindow = ^THostEditWindow;
  THostEditWindow = object (TDialog)
    Data: PDataObject;
    LekcjaDetailView: PLekcjaDetailView;
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream); virtual;

    function GetCurrentDzien: Integer; virtual;
    function GetCurrentLekcja: PLekcja; virtual;
    function GetCurrentDzwonekPos: Integer; virtual;
    function GetCurrentDzwonekIndex: Integer; virtual;
    function CompareData(LekcjaData: PLekcja; DzwonekPos: Integer): Boolean; virtual;
    function GetLekcja(List: PCollection; DzwonekPos: Integer): PLekcja; virtual;
    procedure UpdateDzwonekListView; virtual;
    procedure UpdateLekcjaListView; virtual;
    procedure UpdateLekcjaDetailView; virtual;
    procedure UpdateLists; virtual;
    procedure SetEditorData(EditorData: PDataObject); virtual;
    procedure SetTitle(ATitle: TTitleStr); virtual;
  end;

const
  RHighlightedLabel: TStreamRec = (
    ObjType: $9000;
    VmtLink: Ofs(TypeOf(THighlightedLabel)^);
    Load   : @THighlightedLabel.Load;
    Store  : @THighlightedLabel.Store);
  RLekcjaDetailView: TStreamRec = (
    ObjType: $9001;
    VmtLink: Ofs(TypeOf(TLekcjaDetailView)^);
    Load   : @TLekcjaDetailView.Load;
    Store  : @TLekcjaDetailView.Store);
  RHostEditWindow: TStreamRec = (
    ObjType: $9002;
    VmtLink: Ofs(TypeOf(THostEditWindow)^);
    Load   : @THostEditWindow.Load;
    Store  : @THostEditWindow.Store);

procedure RegisterHostWin;

implementation

{ THighlightedLabel }

constructor THighlightedLabel.Load;
begin
  inherited Load(S);
  EventMask:=EventMask and (not evMouse);
end;

function THighlightedLabel.GetPalette;
const
  S: String = CLabel;
begin
  S[1]:=#2; S[2]:=#5;
  GetPalette:=@S;
end;

{ TLekcjaDetailView }

function TLekcjaDetailView.GetPalette;
const
  S: String = #2;
begin
  GetPalette:=@S;
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
begin
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

    K:=nil;
    { wypisanie danych zgodnie z danymi wy˜wietlanymi w li˜cie lekcji }
    L:=PHostEditWindow(Owner)^.GetCurrentLekcja;
    if not Assigned(L) then St:=''
    else
    begin
      case Y of
        0:
        begin
          if not Assigned(Nauczyciele) then St:=''
          else
          begin
            N:=PNauczyciel(Nauczyciele^.ItemByIndex(L^.NauczycielIndex));
            if not Assigned(N) then St:=''
            else if not Assigned(N^.ImieNazwisko) then St:=''
            else St:=N^.ImieNazwisko^;
          end;
        end;
        1:
        begin
          if not Assigned(Przedmioty) then St:=''
          else
          begin
            P:=PPrzedmiot(Przedmioty^.ItemByIndex(L^.PrzedmiotIndex));
            if not Assigned(P) then St:=''
            else if not Assigned(P^.Nazwa) then St:=''
            else St:=P^.Nazwa^;
          end;
        end;
        2:
        begin
          if not Assigned(Klasy) then St:=''
          else
          begin
            K:=PKlasa(Klasy^.ItemByIndex(L^.KlasaIndex));
            if not Assigned(K) then St:=''
            else St:=K^.GetText(5);
          end;
        end;
        3:
        begin
          if not Assigned(L) then St:=''
          else
          begin
            St:='';
            W:=1;
            for I:=1 to 8 do
            begin
              if (L^.Grupy and W)<>0 then
              begin
                Str(I, Grupa);
                St:=St+Grupa+', ';
              end;
              W:=W shl 1;
            end;
            if St<>'' then
            begin
              St:=Copy(St, 1, Length(St)-2);
              St:=St+'.'
            end;
          end;
        end;
        4:
        begin
          if not Assigned(Sale) then St:=''
          else
          begin
            S:=PSala(Sale^.ItemByIndex(L^.SalaIndex));
            if not Assigned(S) then St:=''
            else if not Assigned(S^.Numer) then St:=''
            else
            begin
              St:=S^.Numer^;
              if Assigned(S^.Nazwa) then St:=St+' ('+S^.Nazwa^+')';
            end;
          end;
        end
        else St:='';
      end;
    end;
    MoveStr(Buf[15], St, Color);
    WriteLine(0, Y, Size.X, 1, Buf);
  end;
end;

{ THostEditWindow }

constructor THostEditWindow.Load;
begin
  inherited Load(S);
  GetSubViewPtr(S, LekcjaDetailView);
end;

destructor THostEditWindow.Done;
begin
  if Assigned(Data) then Dispose(Data, Done);
  inherited Done;
end;
procedure THostEditWindow.HandleEvent;
begin
  inherited HandleEvent(Event);
  if Event.What=evBroadcast then
  begin
    case Event.Command of
      cmFindEditorWindow: ClearEvent(Event);
      cmUpdateLists: UpdateLists;
      cmUpdateDzwonekListView: UpdateDzwonekListView;
      cmUpdateLekcjaListView: UpdateLekcjaListView;
      cmUpdateLekcjaDetailView: UpdateLekcjaDetailView;
      cmDataBaseChanged:
      begin
        Lock;
        UpdateLists;
        UpdateDzwonekListView;
        UpdateLekcjaListView;
        UpdateLekcjaDetailView;
        UnLock;
      end
    end;
  end;
end;

procedure THostEditWindow.Store;
begin
  inherited Store(S);
  PutSubViewPtr(S, LekcjaDetailView);
end;

function THostEditWindow.GetCurrentDzien;
begin
  Abstract;
end;

function THostEditWindow.GetCurrentDzwonekPos;
begin
  Abstract;
end;

function THostEditWindow.GetCurrentDzwonekIndex;
begin
  Abstract;
end;

function THostEditWindow.GetCurrentLekcja;
var
  Dzien, DzwonekPos: Integer;
begin
  Dzien:=GetCurrentDzien;
  DzwonekPos:=GetCurrentDzwonekPos;
  if (Dzien=-1) or (DzwonekPos=-1) then GetCurrentLekcja:=nil
  else GetCurrentLekcja:=GetLekcja(Lekcje[Dzien], GetCurrentDzwonekPos);
end;

function THostEditWindow.CompareData;
var
  Temp: PDzwonek;
begin
  Temp:=Dzwonki^.At(DzwonekPos);
  if LekcjaData^.DzwonekIndex<>Temp^.Index then CompareData:=False
  else CompareData:=True;
end;

function THostEditWindow.GetLekcja;
var
  I: Integer;
  L: PLekcja;
begin
  I:=0;
  L:=nil;
  while Assigned(List) and (I<List^.Count) do
  begin
    L:=PLekcja(List^.At(I));
    if CompareData(L, DzwonekPos) then Break
    else L:=nil;
    Inc(I);
  end;
  GetLekcja:=L;
end;

procedure THostEditWindow.SetEditorData;
begin
  if Assigned(Data) then Dispose(Data, Done);
  if TypeOf(EditorData^)=TypeOf(TNauczyciel) then
  begin
    Data:=New(PNauczyciel, Init);
    PNauczyciel(Data)^.Assign(EditorData);
  end
  else if TypeOf(EditorData^)=TypeOf(TKlasa) then
  begin
    Data:=New(PKlasa, Init);
    PKlasa(Data)^.Assign(EditorData);
  end
  else if TypeOf(EditorData^)=TypeOf(TSala) then
  begin
    Data:=New(PSala, Init);
    PSala(Data)^.Assign(EditorData);
  end
end;

procedure THostEditWindow.SetTitle;
begin
  if ATitle='' then Exit;
  if Assigned(Title) then DisposeStr(Title);
  Title:=nil;
  Title:=NewStr(ATitle);
end;

procedure THostEditWindow.UpdateDzwonekListView;
begin
  Abstract;
end;

procedure THostEditWindow.UpdateLekcjaListView;
begin
  Abstract;
end;

procedure THostEditWindow.UpdateLekcjaDetailView;
begin
  if Assigned(LekcjaDetailView) then LekcjaDetailView^.DrawView;
end;

procedure THostEditWindow.UpdateLists;
begin
  UpdateDzwonekListView;
  UpdateLekcjaListView;
  UpdateLekcjaDetailView;
end;

{ *** }

procedure RegisterHostWin;
begin
  RegisterType(RHighlightedLabel);
  RegisterType(RLekcjaDetailView);
  RegisterType(RHostEditWindow);
end;

begin
end.
