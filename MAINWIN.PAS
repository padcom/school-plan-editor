Unit MainWin;

interface
uses
  App, Objects, Drivers, Views, Dialogs,
  DataObjects, DataDialogs, Stale,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja;

type { typ opisuj¥cy pod˜wietlany Label }
  PHighlightedLabel = ^THighlightedLabel;
  THighlightedLabel = object (TLabel)
    function GetPalette: PPalette; virtual;
  end;

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
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

type { typ opisuj¥cy widok listy lekcji }
  PLekcjaListView = ^TLekcjaListView;
  TLekcjaListView = object (TListBox)
    function GetPalette: PPalette; virtual;
    procedure Draw; virtual;
    procedure FocusItem(Item: Integer); virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

type { typ opisuj¥cy widok detali lekcji }
  PLekcjaDetailView = ^TLekcjaDetailView;
  TLekcjaDetailView = object (TView)
    ListView: PLekcjaListView;
    constructor Init(var Bounds: TRect; AListView: PLekcjaListView);
    constructor Load(var S: TStream);
    function GetPalette: PPalette; virtual;
    procedure Draw; virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj¥cy gˆ¢wne ramki wewn©trzne okna }
  PInsideFrames = ^TInsideFrames;
  TInsideFrames = object (TView)
    procedure Draw; virtual;
  end;

type { typ opisuj¥cy gˆ¢wne okno programu }
  PMainWindow = ^TMainWindow;
  TMainWindow = object (TDialog)
    DzienTygodniaListView: PDzienTygodniaListView;
    DzienTygodniaLabel: PHighlightedLabel;
    DzwonekListView: PDzwonekListView;
    DzwonekListLabel: PHighlightedLabel;
    LekcjaListView: PLekcjaListView;
    LekcjaListLabel: PHighlightedLabel;
    LekcjaDetailView: PLekcjaDetailView;
    InsideFrames: PInsideFrames;
    constructor Load(var S: TStream);
    function GetCurrentLekcja: PLekcja; virtual;
    function GetCurrentDzien: Integer; virtual;
    function GetDzwonekIndex: Integer; virtual;
    procedure PrepareLekcjaList; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SetDzwonekList(List: PDataCollection); virtual;
    procedure SetLekcjaList(List: PDataCollection); virtual;
    procedure SizeLimits(var Min,Max: TPoint); virtual;
    procedure Store(var S: TStream); virtual;
  end;

const
  RHighlightedLabel: TStreamRec = (
    ObjType: $9000;
    VmtLink: Ofs(TypeOf(THighlightedLabel)^);
    Load   : @THighlightedLabel.Load;
    Store  : @THighlightedLabel.Store);
  RDzienTygodniaListView: TStreamRec = (
    ObjType: $9001;
    VmtLink: Ofs(TypeOf(TDzienTygodniaListView)^);
    Load   : @TDzienTygodniaListView.Load;
    Store  : @TDzienTygodniaListView.Store);
  RDzwonekListView: TStreamRec = (
    ObjType: $9002;
    VmtLink: Ofs(TypeOf(TDzwonekListView)^);
    Load   : @TDzwonekListView.Load;
    Store  : @TDzwonekListView.Store);
  RLekcjaListView: TStreamRec = (
    ObjType: $9003;
    VmtLink: Ofs(TypeOf(TLekcjaListView)^);
    Load   : @TLekcjaListView.Load;
    Store  : @TLekcjaListView.Store);
  RLekcjaDetailView: TStreamRec = (
    ObjType: $9004;
    VmtLink: Ofs(TypeOf(TLekcjaDetailView)^);
    Load   : @TLekcjaDetailView.Load;
    Store  : @TLekcjaDetailView.Store);
  RInsideFrames: TStreamRec = (
    ObjType: $9005;
    VmtLink: Ofs(TypeOf(TInsideFrames)^);
    Load   : @TInsideFrames.Load;
    Store  : @TInsideFrames.Store);
  RMainWindow: TStreamRec = (
    ObjType: $9006;
    VmtLink: Ofs(TypeOf(TMainWindow)^);
    Load   : @TMainWindow.Load;
    Store  : @TMainWindow.Store);

procedure RegisterMainWin;

implementation
uses
  Resource;

{ THighlightedLabel }

function THighlightedLabel.GetPalette;
const
  S: String = CLabel;
begin
  S[1]:=#2; S[2]:=#5;
  GetPalette:=@S;
end;

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
begin
  inherited FocusItem(Item);
  if Assigned(Owner) then Message(Owner, evBroadcast, cmRedrawLekcjaListView, nil);
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
begin
  inherited FocusItem(Item);
  Message(Owner, evBroadcast, cmRedrawLekcjaListView, nil);
end;

procedure TDzwonekListView.HandleEvent;
var
  L: PCollection;
  Item: PObject;
  I: Integer;
begin
  if (Event.What=evBroadcast) and (Event.Command=cmUpdateLists) then
  begin
    I:=Focused;
    if I>=List^.Count then Dec(I);
    L:=List;
    List:=nil;
    NewList(L);
    if Assigned(List) and (List^.Count>0) then
    begin
      FocusItem(I);
      DrawView;
    end;
  end;
  inherited HandleEvent(Event);
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
  C: Char;
  L: PLekcja;
  Y: Integer;
  Color, Color1, Color2: Word;
  N: PNauczyciel;
  P: PPrzedmiot;
  K: PKlasa;
  S: PSala;
  St: String;
  I, W: Word;
begin
  Color1:=GetColor(3);
  Color2:=GetColor(1);
  C:='³';
  for Y:=0 to Size.Y-1 do
  begin
    MoveChar(Buf, ' ', Color2, Size.X);
    { narysowanie ramek rozdzielaj¥cych poszczeg¢lne elementy listy }
    MoveChar(Buf[8], C, Color2, 1);
    MoveChar(Buf[20], C, Color2, 1);
    MoveChar(Buf[28], C, Color2, 1);
    MoveChar(Buf[39], C, Color2, 1);

    if TopItem+Y=Focused then Color:=Color1 else Color:=Color2;
    if not Assigned(List) or (Y+TopItem>=List^.Count) then
    begin
      Color:=Color2;
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
begin
  inherited FocusItem(Item);
  if CreatingResources then Exit;
  Message(Owner, evBroadcast, cmRedrawLekcjaDetailView, nil);
end;

procedure TLekcjaListView.HandleEvent;
var
  I: Integer;
  L: PCollection;
begin
  if (Event.What=evBroadcast) and
     (Event.Command=cmDataBaseChanged) then DrawView;
  if (Event.What=evBroadcast) and
     (Event.Command=cmUpdateLists) then
  begin
    I:=Focused;
    if I>=List^.Count then Dec(I);
    L:=List;
    List:=nil;
    NewList(L);
    if Assigned(List) and (List^.Count>0) then
    begin
      FocusItem(I);
      DrawView;
    end;
  end;
  inherited HandleEvent(Event);
end;

{ TLekcjaDetailView }

constructor TLekcjaDetailView.Init;
begin
  inherited Init(Bounds);
  ListView:=AListView;
end;

constructor TLekcjaDetailView.Load;
begin
  inherited Load(S);
  GetPeerViewPtr(S, ListView);
end;

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
    if (not Assigned(ListView)) or (not Assigned(ListView^.List)) or (ListView^.List^.Count=0) then St:=''
    else
    begin
      L:=ListView^.List^.At(ListView^.Focused);
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

procedure TLekcjaDetailView.Store;
begin
  inherited Store(S);
  PutPeerViewPtr(S, ListView);
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

{ TMainWindow }

constructor TMainWindow.Load;
begin
  inherited Load(S);
  GetSubViewPtr(S, DzienTygodniaListView);
  GetSubViewPtr(S, DzienTygodniaLabel);
  GetSubViewPtr(S, DzwonekListView);
  GetSubViewPtr(S, DzwonekListLabel);
  GetSubViewPtr(S, LekcjaListView);
  GetSubViewPtr(S, LekcjaListLabel);
  GetSubViewPtr(S, LekcjaDetailView);
  GetSubViewPtr(S, InsideFrames);
end;

function TMainWindow.GetCurrentLekcja;
begin
  if not Assigned(LekcjaListView^.List) then GetCurrentLekcja:=nil
  else if LekcjaListView^.List^.Count=0 then GetCurrentLekcja:=nil
  else GetCurrentLekcja:=LekcjaListView^.List^.At(LekcjaListView^.Focused);
end;

function TMainWindow.GetCurrentDzien;
begin
  GetCurrentDzien:=DzienTygodniaListView^.Focused;
end;

function TMainWindow.GetDzwonekIndex;
begin
  if not Assigned(DzwonekListView) then GetDzwonekIndex:=-1
  else if not Assigned(DzwonekListView^.List) then GetDzwonekIndex:=-1
  else if DzwonekListView^.List^.Count=0 then GetDzwonekIndex:=-1
  else GetDzwonekIndex:=PDzwonek(Dzwonki^.At(DzwonekListView^.Focused))^.Index;
end;

procedure TMainWindow.PrepareLekcjaList;
var
  List: PDataCollection;
  I: Integer;
  DzwonekIndex: LongInt;
  Data: PLekcja;
begin
  if CreatingResources then Exit;
  if Assigned(LekcjaListView^.List) then LekcjaListView^.List^.DeleteAll;
  New(List, Init(10, 5));
  DzwonekIndex:=GetDzwonekIndex;
  I:=0;
  while I<Lekcje[GetCurrentDzien+1]^.Count do
  begin
    Data:=Lekcje[GetCurrentDzien+1]^.At(I);
    if Data^.DzwonekIndex=DzwonekIndex then List^.Insert(Data);
    Inc(I);
  end;
  SetLekcjaList(List);
  LekcjaDetailView^.DrawView;
end;

procedure TMainWindow.HandleEvent;
begin
  if Event.What=evKeyboard then
  begin
    case Event.KeyCode of
      kbLeft:
      begin
        SelectNext(True);
        ClearEvent(Event);
      end;
      kbRight:
      begin
        SelectNext(False);
        ClearEvent(Event);
      end;
    end;
  end
  else if (Event.What=evBroadcast) then
  begin
    case Event.Command of
      cmRedrawLekcjaListView:
      begin
        PrepareLekcjaList;
        ClearEvent(Event);
      end;
      cmRedrawLekcjaDetailView:
      begin
        LekcjaDetailView^.DrawView;
        ClearEvent(Event);
      end;
    end;
  end;
  inherited HandleEvent(Event);
end;

procedure TMainWindow.SetLekcjaList;
begin
  LekcjaListView^.NewList(List);
end;

procedure TMainWindow.SetDzwonekList;
begin
  DzwonekListView^.NewList(List);
end;

procedure TMainWindow.SizeLimits;
begin
  inherited SizeLimits(Min, Max);
  Min.X:=80; Min.Y:=11;
end;

procedure TMainWindow.Store;
begin
  inherited Store(S);
  PutSubViewPtr(S, DzienTygodniaListView);
  PutSubViewPtr(S, DzienTygodniaLabel);
  PutSubViewPtr(S, DzwonekListView);
  PutSubViewPtr(S, DzwonekListLabel);
  PutSubViewPtr(S, LekcjaListView);
  PutSubViewPtr(S, LekcjaListLabel);
  PutSubViewPtr(S, LekcjaDetailView);
  PutSubViewPtr(S, InsideFrames);
end;

{ *** }

procedure RegisterMainWin;
begin
  RegisterType(RHighlightedLabel);
  RegisterType(RDzienTygodniaListView);
  RegisterType(RDzwonekListView);
  RegisterType(RLekcjaListView);
  RegisterType(RLekcjaDetailView);
  RegisterType(RInsideFrames);
  RegisterType(RMainWindow);
end;

begin
end.
