Unit OknoPrzegladowe;

interface
uses Objects, Drivers, Views, Dialogs, Lekcja;

type { Typ opisuj¥cy okno przegl¥du planu lekcji }
  PPlanLekcjiDisplayWindow = ^TPlanLekcjiDisplayWindow;
  TPlanLekcjiDisplayWindow = object (TDialog)
  private
    ATitleStr: String;
  public
    constructor Init(ATitle: TTitleStr);
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SizeLimits(var Min, Max: TPoint); virtual;
    procedure Draw; virtual;
    procedure ReDraw; virtual;
    procedure Print; virtual;
    procedure EditLekcjaNow;
    procedure DeleteLekcjaNow;
    procedure Edit(Data: PLekcja); virtual;
  end;

type { Typ opisuj¥cy okno przegl¥du planu lekcji nauczyciela }
  PNauczycielPlanLekcjiViewWindow = ^TNauczycielPlanLekcjiViewWindow;
  TNauczycielPlanLekcjiViewWindow = object (TPlanLekcjiDisplayWindow)
    constructor Init(ANauczycielIndex: Integer);
    procedure Edit(Data: PLekcja); virtual;
  end;

type { Typ opisuj¥cy okno przegl¥du planu lekcji nauczyciela }
  PKlasaPlanLekcjiViewWindow = ^TKlasaPlanLekcjiViewWindow;
  TKlasaPlanLekcjiViewWindow = object (TPlanLekcjiDisplayWindow)
    constructor Init(AKlasaIndex: Integer; AGrupa:Integer);
    procedure Edit(Data: PLekcja); virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

implementation
uses App, Latin2, DataObjects, Stale, Drukarka, FiltracjaDanych, MainWindow, MsgBox,
     Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek;

const { Staˆe definiuj¥ce kolory wy˜wietlanych element¢w }
  CSelected = 5;
  CUnselected = 2;

var { Zmienna zawieraj¥ca funnkcj© pobieraj¥c¥ z lekcji tekst do wy˜wietlenia }
  GetTextFun: function (L: PLekcja): String;

var { Zmienna zawieraj¥ca funkcj© determinuj¥c¥, czy zadana lekcja pasuje, czy te¾ nie }
  CompareLekcjaFun: function (L: PLekcja): Boolean;

var { Zmienne odpowiadaj¥ce za wybrany element }
  OldSelectedLekcjaPtr: PLekcja;
  OldSelectedDzien: Integer;
  OldSelectedDzwonek: Integer;
  NauczycielIndex: Integer;
  KlasaIndex: Integer;
  GrupaMask: Integer;
  TopItem: Integer;
  SelectedLekcjaPtr: PLekcja;
  SelectedDzwonek: Integer;
  SelectedDzien: Integer;

var { Zmienne zawieraj¥ce wskazania do list lekcji poszczeg¢ˆnych dni }
  DzienList: Array [1..5] of PDataCollection;

var { Zmienne zawieraj¥ce wskazania do poszczeg¢ˆnych element¢w okienka }
  InsideGroup: PGroup;
  DetailsView: PView;
  NauczycielStaticText: PStaticText;
  PrzedmiotStaticText: PStaticText;
  SalaStaticText: PStaticText;
  KlasaStaticText: PStaticText;
  GrupyCheckBoxes: PCheckBoxes;

procedure MakeLists;
var
  I, J, K: Integer;
  L: PLekcja; LI: LongInt;
  Found: Boolean;
begin
  for I:=1 to 5 do
  begin
    if Assigned(DzienList[I]) and (DzienList[I]^.Count>0) then
    begin
      DzienList[I]^.DeleteAll;
    end
    else
    begin
      New(DzienList[I], Init(10, 5));
    end;

    J:=0;
    while Assigned(CompareLekcjaFun) and (J<Lekcje[I]^.Count) do
    begin
      L:=Lekcje[I]^.At(J);
      if CompareLekcjaFun(L) then
      begin
        L^.GetIndex(LI); L^.SetIndex(-1);
        DzienList[I]^.Insert(L);
        L^.SetIndex(LI);
      end;
      Inc(J);
    end;
  end;
end;

type { Typ opisuj¥cy wn©trze okna przegl¥du planu lekcji }
  PInsideGroup = ^TInsideGroup;
  TInsideGroup = object (TGroup)
    Total: array[0..5] of Integer;
    constructor Init(R: TRect);
    procedure Draw; virtual;
  end;

constructor TInsideGroup.Init(R: TRect);
begin
  inherited Init(R);
  GrowMode:=gfGrowHiX or gfGrowHiY;
end;

procedure TInsideGroup.Draw;
var
  Y, I, J, K: Integer;
  S: String;
  C1, C2, C3, C4: Char;
  Color: Byte;
  DI1, DI2: LongInt;
  D: LongInt; G: LongInt;
  L: PLekcja;
  Found: Boolean;
begin
  SelectedLekcjaPtr:=nil;
  { Draw the frames with some text }
  C1:='³'; C2:='Ä'; C3:='Å'; C4:='Á';
  S:=' Poniedziaˆek '+C1+'    Wtorek    '+C1+'    —roda     '+C1+'   Czwartek   '+C1+'    Pi¥tek    ';
  WriteStr(0, 0, S, CUnselected);

  S:=RepeatStr(C2, Size.X);
  S[15]:=C3; S[30]:=C3; S[45]:=C3; S[60]:=C3;
  WriteStr(0, 1, S, CUnselected);

  S:=RepeatStr(' ', Size.X);
  S[15]:=C1; S[30]:=C1; S[45]:=C1; S[60]:=C1;
  for Y:=2 to Size.Y-6 do WriteStr(0, Y, S, CUnselected);

  S:=RepeatStr(C2, Size.X);
  S[15]:=C4; S[30]:=C4; S[45]:=C4; S[60]:=C4;
  WriteStr(0, Size.Y-5, S, CUnselected);

  TopItem:=SelectedDzwonek-Size.Y+8;
  if TopItem<0 then TopItem:=0;

  for I:=0 to 5 do Total[I]:=0;

  { Draw the lessons }
  D:=1;
  while D<6 do
  begin
    G:=TopItem;
    while Assigned(Dzwonki) and (G<Dzwonki^.Count) and ((G-TopItem)<Size.Y-7) do
    begin
      I:=0; Found:=False;
      PDzwonek(Dzwonki^.At(G))^.GetIndex(DI1);
      while Assigned(DzienList[D]) and (I<DzienList[D]^.Count) and (not Found) do
      begin
        L:=DzienList[D]^.At(I);
        L^.GetDzwonekIndex(DI2);
        if DI1=DI2 then Found:=True
        else Inc(I);
      end;

      S:='';
      if Found and Assigned(L) then
      begin
        Inc(Total[0]);
        Inc(Total[D]);
        S:=GetTextFun(L);
        S:=S+SpaceStr(14-Length(S));
        if (SelectedDzien=D) and (SelectedDzwonek=G) then SelectedLekcjaPtr:=L;
      end
      else S:=SpaceStr(14);

      if (SelectedDzien=D) and (SelectedDzwonek=G) then Color:=CSelected
      else Color:=CUnselected;

      WriteStr((D-1)*15, G+2-TopItem, S, Color);
      Inc(G);
    end;
    Inc(D);
  end;
  { Draw the details group }
  if Assigned(DetailsView) then DetailsView^.Draw;
end;

constructor TPlanLekcjiDisplayWindow.Init(ATitle: TTitleStr);
var R: TRect;
begin
  Desktop^.GetExtent(R); Dec(R.B.Y, 5); Dec(R.B.X, 4);
  inherited Init(R, ATitle);
  Options:=Options or ofCentered;
  Palette:=dpBlueDialog;

  GetExtent(R); R.Grow(-1, -1);
  InsideGroup:=New(PInsideGroup, Init(R));
  Insert(InsideGroup);

  HelpCtx:=$2002;
  ATitleStr:=ATitle;
  SelectedDzien:=1;
  SelectedDzwonek:=0;
end;

destructor TPlanLekcjiDisplayWindow.Done;
var I: Integer;
begin
  for I:=1 to 5 do if Assigned(DzienList[I]) then
  begin
    DzienList[I]^.DeleteAll;
    Dispose(DzienList[I], Done);
    DzienList[I]:=nil;
  end;
  SelectedDzien:=1;
  SelectedDzwonek:=0;
  inherited Done;
end;

procedure TPlanLekcjiDisplayWindow.EditLekcjaNow;
var
  Index1, Index2, Index: LongInt;
  L: Plekcja;
  D1, D2: PDzwonek;
  I, Poz: Integer;
  TempList: PDataCollection;
begin
  if not Assigned(SelectedLekcjaPtr) then Exit;
  SelectedLekcjaPtr^.GetIndex(Index);
  Poz:=0;
  while Poz<Lekcje[SelectedDzien]^.Count do
  begin
    L:=Lekcje[SelectedDzien]^.At(Poz);
    L^.GetIndex(Index2);
    if Index=Index2 then
    begin
      Lekcje[SelectedDzien]^.AtDelete(Poz);
      Break;
    end
    else Inc(Poz);
  end;

  New(TempList, Init(10, 5));
  I:=0;
  SelectedLekcjaPtr^.GetDzwonekIndex(Index1);
  while I<Lekcje[SelectedDzien]^.Count do
  begin
    L:=Lekcje[SelectedDzien]^.At(I);
    L^.GetDzwonekIndex(Index2);
    if Index1=Index2 then
    begin
      SelectedLekcjaPtr^.SetIndex(-1);
      TempList^.Insert(L);
      SelectedLekcjaPtr^.SetIndex(Index);
    end;
    Inc(I);
  end;

  SelectedLekcjaPtr^.SetIndex(-1);
  FiltrujDane(TempList);

  Edit(SelectedLekcjaPtr);

  PrzywrocDane;
  Lekcje[SelectedDzien]^.AtInsert(Poz, SelectedLekcjaPtr);
  SelectedLekcjaPtr^.SetIndex(Index);
  SelectedLekcjaPtr^.GetIndex(Index);
  TempList^.DeleteAll;
  Dispose(TempList, Done);
  MakeLists;
end;

procedure TPlanLekcjiDisplayWindow.DeleteLekcjaNow;
var
  I: Integer;
  Index1, Index2: LongInt;
  L: PLekcja;
begin
  if not Assigned(SelectedLekcjaPtr) then Exit;
  SelectedLekcjaPtr^.GetIndex(Index1);
  L:=PLekcja(Lekcje[SelectedDzien]^.ItemByIndex(Index1));
  if (L=SelectedLekcjaPtr) and (MessageBox(#3'Czy na pewno chcesz usun¥† t¥ lekcj© ?', nil,
                                mfConfirmation or mfYesButton or mfNoButton)<>cmCancel) then
  begin
    I:=0;
    while I<Lekcje[SelectedDzien]^.Count do
    begin
      L:=Lekcje[SelectedDzien]^.At(I);
      L^.GetIndex(Index2);
      if Index1=Index2 then
      begin
        Lekcje[SelectedDzien]^.AtFree(I);

        Break;
      end
      else Inc(I);
    end;
    MakeLists;
  end;
end;

procedure TPlanLekcjiDisplayWindow.HandleEvent(var Event: TEvent);
var
  Index: LongInt;
begin
  if Event.What=evKeyboard then
  case Event.KeyCode of
    kbUp: if Assigned(Dzwonki) then
    begin
      Dec(SelectedDzwonek);
      if SelectedDzwonek<0 then SelectedDzwonek:=0
      else ReDraw;
    end;
    kbDown: if Assigned(Dzwonki) then
    begin
      Inc(SelectedDzwonek);
      if SelectedDzwonek>Dzwonki^.Count-1 then SelectedDzwonek:=Dzwonki^.Count-1
      else ReDraw;
    end;
    kbLeft:
    begin
      Dec(SelectedDzien);
      if SelectedDzien<1 then SelectedDzien:=1
      else ReDraw;
    end;
    kbRight:
    begin
      Inc(SelectedDzien);
      if SelectedDzien>5 then SelectedDzien:=5
      else ReDraw;
    end;
    kbEsc: EndModal(cmCancel);
    kbEnter: begin EditLekcjaNow; Redraw; end;
    kbDel: begin DeleteLekcjaNow; Redraw; end;
  end
  else if Event.What=evCommand then
  case Event.Command of
    cmPrint: Print;
  end;
  inherited HandleEvent(Event);
end;

procedure TPlanLekcjiDisplayWindow.SizeLimits(var Min, Max: TPoint);
var R: TRect;
begin
  Min.X:=16; Max.X:=76;
  Min.Y:=10; Max.Y:=20;
end;

procedure TPlanLekcjiDisplayWindow.ReDraw;
var
  S: String;
  I: Integer;
begin
  inherited Redraw;
  Str(PInsideGroup(InsideGroup)^.Total[0], S);
  S:=' Razem lekcji: '+S+' ';
  WriteStr((Size.X-Length(S)) div 2, Size.Y-1, S, 2);

  for I:=1 to 5 do
  begin
    Str(PInsideGroup(InsideGroup)^.Total[I], S);
    S:=' Razem: '+S+' ';
    WriteStr((I-1)*15+2, Size.Y-6, S, 2);
  end;
end;

procedure TPlanLekcjiDisplayWindow.Draw;
var
  S: String;
  I: Integer;
begin
  inherited draw;
  Str(PInsideGroup(InsideGroup)^.Total[0], S);
  S:=' Razem lekcji: '+S+' ';
  WriteStr((Size.X-Length(S)) div 2, Size.Y-1, S, 2);

  for I:=1 to 5 do
  begin
    Str(PInsideGroup(InsideGroup)^.Total[I], S);
    S:=' Razem: '+S+' ';
    WriteStr((I-1)*15+2, Size.Y-6, S, 2);
  end;
end;

procedure TPlanLekcjiDisplayWindow.Print;
var
  I, J, K: Integer;
  L: PLekcja;
  D: PDzwonek;
  DzwonekIndex, DzwonekIndex2: LongInt;
  F: Text;
  Found: Boolean;
  S, S2: String;
  C1, C2, C3, C4, C5: Char;
begin
  C1:='³'; C2:='Ä'; C3:='Å'; C4:='Á'; C5:='Â';
  if Assigned(Dzwonki) and (Dzwonki^.Count>0) then
  begin
    if IOResult<>0 then;
    Assign(F, 'wydruk.tmp');
    Rewrite(F);
    Writeln(F);
    Writeln(F, '  Plan lekcji dla: ', ATitleStr);
    Writeln(F);
    Writeln(F);

    S:=RepeatStr(C2, Size.X);
    S[15]:=C5; S[30]:=C5; S[45]:=C5; S[60]:=C5;
    S:=RepeatStr(C2, 3)+C5+S;
    Writeln(F, S);

    S:=RepeatStr(' ', 3)+C1+' Poniedziaˆek '+C1+'    Wtorek    '+C1+'    —roda     '+C1+'   Czwartek   '+C1+'    Pi¥tek    ';
    Writeln(F, S);
    S:=RepeatStr(C2, Size.X);
    S[15]:=C3; S[30]:=C3; S[45]:=C3; S[60]:=C3;
    S:=RepeatStr(C2, 3)+C3+S;
    Writeln(F, S);
    for I:=0 to Dzwonki^.Count-1 do
    begin
      S:='';
      PDzwonek(Dzwonki^.At(I))^.GetIndex(DzwonekIndex);
      for J:=1 to 5 do
      begin
        if Assigned(DzienList[J]) and (DzienList[J]^.Count>0) then
        begin
          Found:=False;
          for K:=0 to DzienList[J]^.Count-1 do
          begin
            L:=DzienList[J]^.At(K);
            L^.GetDzwonekIndex(DzwonekIndex2);
            if DzwonekIndex=DzwonekIndex2 then
            begin
              Found:=True;
              Break;
            end;
          end;
          if not Found then L:=nil;
          if Assigned(L) then S:=S+GetTextFun(L)
          else S:=S+SpaceStr(14);
          if J<5 then S:=S+C1;
        end
        else S:=S+SpaceStr(15);
      end;
      S[15]:=C1; S[30]:=C1; S[45]:=C1; S[60]:=C1;
      Str(I+1, S2);
      S:=' '+S2+' '+C1+S;

      Writeln(F, S);
    end;
    S:=RepeatStr(C2, Size.X);
    S[15]:=C4; S[30]:=C4; S[45]:=C4; S[60]:=C4;
    S:=RepeatStr(C2, 3)+C4+S;
    Writeln(F, S);

    System.Close(F);
    PrintFile('wydruk.tmp');
{
    Assign(F, 'wydruk.tmp');
    Erase(F);
}
  end;
end;

procedure TPlanLekcjiDisplayWindow.Edit;
begin
  EditLekcja('Edycja lekcji', Data, 1, True, False);
end;

  { Plan Lekcji nauczyciela }

type { Typ opisuj¥cy okno podgl¥du lekcji dla nauczyciela }
  PNauczycielDetailsView = ^TNauczycielDetailsView;
  TNauczycielDetailsView = object (TView)
    constructor Init(R: TRect);
    procedure Draw; virtual;
  end;

constructor TNauczycielDetailsView.Init(R: TRect);
begin
  inherited Init(R);
  GrowMode:=GFGrowLoY or GFGrowHiX or gfGrowHiY;
end;

procedure TNauczycielDetailsView.Draw;
var
  S: PSala; SS: String;
  K: PKlasa; KS: String;
  G: Word; GS: String;
  P: PPrzedmiot; PS: String;
  Y, I: Integer;
  TS: String;
begin
  for Y:=0 to Size.Y do WriteStr(0, Y, SpaceStr(Size.X), 1);
  if Assigned(SelectedLekcjaPtr) then with SelectedLekcjaPtr^ do
  begin
    GetPrzedmiot(P);
    GetKlasa(K);
    GetSala(S);
    GetGrupy(G);
    if Assigned(P) then PS:=P^.GetText(255) else PS:='';

    if Assigned(K) then
    begin
      KS:=K^.GetText(255);
      GS:='';

      for I:=1 to 9 do
      begin
        if G and 1<>0 then
        begin
          Str(I, TS);
          if GS='' then GS:=TS else GS:=GS+', '+TS;
        end;
        G:=G shr 1;
      end;
      if GS<>'' then GS:=GS+'.';
    end
    else
    begin
      KS:='';
      GS:='';
    end;

    if Assigned(S) then SS:=S^.GetText(255) else SS:='';
  end
  else
  begin
    PS:='';
    KS:='';
    GS:='';
    SS:='';
  end;

  WriteStr(0, 0, ' Sala:      '+SS, CUnselected);
  WriteStr(0, 1, ' Przedmiot: '+PS, CUnselected);
  WriteStr(0, 2, ' Klasa:     '+KS, CUnselected);
  WriteStr(0, 3, ' Grupy:     '+GS, CUnselected);
end;

function NauczycielGetText(L: PLekcja): String; far;
var
  St: String;
  S: PSala; SS: String;
  K: PKlasa; KS: String;
  P: PPrzedmiot; PS: String;
begin
  St:=''; SS:=''; ks:=''; PS:='';
  L^.GetSala(S); if Assigned(S) then SS:=S^.GetText(4); SS:=SS+SpaceStr(4-Length(SS));
  L^.GetKlasa(K); if Assigned(K) then KS:=K^.GetText(3); KS:=KS+SpaceStr(3-Length(KS));
  L^.GetPrzedmiot(P); if Assigned(P) then PS:=P^.GetText(5); PS:=PS+SpaceStr(5-Length(PS));
  St:=KS+'\'+SS+'\'+PS;
  NauczycielGetText:=Copy(St, 1, 14);
end;

function NauczycielCompareLekcja(L: PLekcja): Boolean; far;
var I: LongInt;
begin
  L^.GetNauczycielIndex(I);
  if I=NauczycielIndex then NauczycielCompareLekcja:=True
  else NauczycielCompareLekcja:=False;
end;

constructor TNauczycielPlanLekcjiViewWindow.Init(ANauczycielIndex: Integer);
var
  R: TRect;
  S: String;
  N: PNauczyciel;
begin
  NauczycielIndex:=ANauczycielIndex;
  N:=PNauczyciel(Nauczyciele^.ItemByIndex(NauczycielIndex));
  if Assigned(N) then
  begin
    S:=N^.GetText(255);
  end;
  inherited Init(S);

  GetTextFun:=NauczycielGetText;
  CompareLekcjaFun:=NauczycielCompareLekcja;
  MakeLists;

  R.Assign(0, InsideGroup^.Size.Y-4, InsideGroup^.Size.X, InsideGroup^.Size.Y);
  DetailsView:=New(PNauczycielDetailsView, Init(R));
  InsideGroup^.Insert(DetailsView);
end;

procedure TNauczycielPlanLekcjiViewWindow.Edit;
begin
  EditLekcja('Edycja lekcji', Data, 1, True, False);
end;

  { Plan lekcji grupy klasy }

type { Typ opisuj¥cy okno podgl¥du lekcji dla nauczyciela }
  PKlasaDetailsView = ^TKlasaDetailsView;
  TKlasaDetailsView = object (TView)
    constructor Init(R: TRect);
    procedure Draw; virtual;
  end;

constructor TKlasaDetailsView.Init(R: TRect);
begin
  inherited Init(R);
  GrowMode:=GFGrowLoY or GFGrowHiX or gfGrowHiY;
end;

procedure TKlasaDetailsView.Draw;
var
  S: PSala; SS: String;
  N: PNauczyciel; NS: String;
  P: PPrzedmiot; PS: String;
  Y, I: Integer;
  TS: String;
begin
  for Y:=0 to Size.Y do WriteStr(0, Y, SpaceStr(Size.X), 1);
  if Assigned(SelectedLekcjaPtr) then with SelectedLekcjaPtr^ do
  begin
    GetPrzedmiot(P);
    GetNauczyciel(N);
    GetSala(S);
    if Assigned(P) then PS:=P^.GetText(255) else PS:='';
    if Assigned(N) then NS:=N^.GetText(255) else NS:='';
    if Assigned(S) then SS:=S^.GetText(255) else SS:='';
  end
  else
  begin
    PS:='';
    NS:='';
    SS:='';
  end;

  WriteStr(0, 0, ' Nauczyciel: '+NS, CUnselected);
  WriteStr(0, 1, ' Sala:       '+SS, CUnselected);
  WriteStr(0, 2, ' Przedmiot:  '+PS, CUnselected);
end;

function KlasaGetText(L: PLekcja): String; far;
var
  St: String;
  S: PSala; SS: String;
  N: PNauczyciel; NS: String;
  P: PPrzedmiot; PS: String;
begin
  St:='';
  L^.GetSala(S);
  L^.GetNauczyciel(N);
  L^.GetPrzedmiot(P);
  if Assigned(S) then SS:=S^.GetText(4) else SS:='';
  if Assigned(P) then PS:=P^.GetText(4) else PS:='';
  if Assigned(N) then NS:=N^.GetText(4) else NS:='';
  NS:=NS+SpaceStr(4-Length(NS));
  PS:=PS+SpaceStr(4-Length(PS));
  SS:=SS+SpaceStr(4-Length(SS));
  St:=SS+'\'+PS+'\'+NS;

  KlasaGetText:=Copy(St, 1, 14);
end;

function KlasaCompareLekcja(L: PLekcja): Boolean; far;
var
  I: LongInt;
  G: Word;
begin
  L^.GetKlasaIndex(I);
  if I=KlasaIndex then
  begin
    L^.GetGrupy(G);
    if G and GrupaMask<>0 then KlasaCompareLekcja:=True
    else KlasaCompareLekcja:=False;
  end
  else KlasaCompareLekcja:=False;
end;

type { typ opisuj¥cy obiekt listy przedmiot¢w }
  PPrzedmiotyListBoxObject = ^TPrzedmiotyListBoxObject;
  TPrzedmiotyListBoxObject = object (TObject)
    Index: LongInt;
    Data: PPrzedmiot;
    Ilosc: Integer;
    constructor Init(AIndex: LongInt);
    destructor Done; virtual;
    function GetText(MaxLen: Integer): String; virtual;
  end;

constructor TPrzedmiotyListBoxObject.Init;
var
  S: String;
begin
  inherited Init;
  Data:=PPrzedmiot(Przedmioty^.ItemByIndex(AIndex));
  if not Assigned(Data) then Fail
  else
  begin
    Index:=AIndex;
    Ilosc:=0;
  end;
end;

destructor TPrzedmiotyListBoxObject.Done;
begin
  Data:=nil;
  Index:=-1;
  Ilosc:=0;
  inherited Done;
end;

function TPrzedmiotyListBoxObject.GetText;
var
  S1, S2: String;
begin
  Data^.GetNazwa(S1);
  while Length(S1)<MaxLen-8 do S1:=S1+' ';
  Str(Ilosc:4, S2);
  S1:=Copy(S1, 1, MaxLen-8)+S2;
  GetText:=S1;
end;

type { typ opisuj¥cy kolekcj© przedmiot¢w w li˜cie }
  PPrzedmiotyListBoxCollection = ^TPrzedmiotyListBoxCollection;
  TPrzedmiotyListBoxCollection = object (TSortedCollection)
    function Compare(Key1, Key2: Pointer): Integer; virtual;
  end;

function TPrzedmiotyListBoxCollection.Compare;
var
  S1, S2: String;
begin
  PPrzedmiotyListBoxObject(Key1)^.Data^.GetNazwa(S1);
  PPrzedmiotyListBoxObject(Key2)^.Data^.GetNazwa(S2);
  if S1<S2 then Compare:=-1
  else if S1>S2 then Compare:=1
  else Compare:=0;
end;

type { typ opisuj¥cu ListBox przedmiot¢w z ilo˜ci¥ ich wyst¥pieä }
  PPrzedmiotyListBox = ^TPrzedmiotyListBox;
  TPrzedmiotyListBox = object (TListBox)
    function GetText(Item, MaxLen: Integer): String; virtual;
  end;

function TPrzedmiotyListBox.GetText;
begin
  GetText:=PPrzedmiotyListBoxObject(List^.At(Item))^.GetText(MaxLen);
end;

type { typ opisuj¥cy okno listuj¥cej ilo˜† przedmiot¢w dla danej klasy }
  PZliczaczPrzedmiotow = ^TZliczaczPrzedmiotow;
  TZliczaczPrzedmiotow = object (TDialog)
    FScrollBar: PScrollBar;
    FPrzedmioty: PDataCollection;
    FPrzedmiotyListBox: PPrzedmiotyListBox;
    FPrzedmiotyLabel: PLabel;
    FOkButton: PButton;

    constructor Init(AKlasa: LongInt; MaskaGrup: Word);
    destructor Done; virtual;
  end;

constructor TZliczaczPrzedmiotow.Init;
var
  R: TRect;
  I, J, K, M: Integer;
  Index1, Index2: LongInt;
  Data: PPrzedmiotyListBoxObject;
  List: PPrzedmiotyListBoxCollection;
  L: PLekcja;
  Found: Boolean;
begin
  R.Assign(0, 0, 60, 15);
  inherited Init(R, 'Ilo˜ci poszczeg¢lnych przedmiot¢w');
  Options := Options or ofCentered;

  R.Assign(Size.X-17, 3, Size.X-2, 5);
  New(FOkButton, Init(R, '~Z~amknij', cmOk, bfDefault));
  Insert(FOkButton);

  R.Assign(Size.X-20, 3, Size.X-19, Size.Y-2);
  New(FScrollBar, Init(R));
  Insert(FScrollBar);
  R.Assign(2, 3, Size.X-20, Size.Y-2);
  New(FPrzedmiotyListBox, Init(R, 1, FScrollBar));
  Insert(FPrzedmiotyListBox);
  R.Assign(1, 2, Size.X-20, 3);
  New(FPrzedmiotyLabel, Init(R, '~L~ista przedmiot¢w         Ilo˜† godzin', FPrzedmiotyListBox));
  Insert(FPrzedmiotyLabel);

  New(List, Init(10, 5));
  for I:=1 to 5 do
  begin
    J:=0;
    while J<DzienList[I]^.Count do
    begin
      L:=DzienList[I]^.At(J);
      L^.GetPrzedmiotIndex(Index1);
      New(Data, Init(Index1));
      if Assigned(Data) then
      begin
        if List^.Search(Data, M) then
        begin
          Dispose(Data, Done);
          Data:=List^.At(M);
          Inc(Data^.Ilosc);
        end
        else
        begin
          List^.Insert(Data);
          Data^.Ilosc:=1;
        end;
      end;
      Inc(J);
    end;
  end;
  FPrzedmiotyListBox^.NewList(List);
end;

destructor TZliczaczPrzedmiotow.Done;
begin
  inherited Done;
end;

constructor TKlasaPlanLekcjiViewWindow.Init(AKlasaIndex: Integer; AGrupa:Integer);
var
  R: TRect;
  S1, S2: String;
  K: PKlasa;
  I: Integer;

begin
  KlasaIndex:=AKlasaIndex;
  K:=PKlasa(Klasy^.ItemByIndex(KlasaIndex));
  if Assigned(K) then
  begin
    K^.GetNumer(S1);
    K^.GetLitera(S2);
    S1:=S1+S2;
    Str(AGrupa+1, S2);
    S1:=S1+': Grupa '+S2;
  end
  else Fail;
  inherited Init(S1);

  GrupaMask:=1;
  if AGrupa>0 then
    for I:=1 to AGrupa do
      GrupaMask:=GrupaMask shl 1;

  GetTextFun:=KlasaGetText;
  CompareLekcjaFun:=KlasaCompareLekcja;
  MakeLists;

  R.Assign(0, InsideGroup^.Size.Y-4, InsideGroup^.Size.X, InsideGroup^.Size.Y);
  DetailsView:=New(PKlasaDetailsView, Init(R));
  InsideGroup^.Insert(DetailsView);
end;

procedure TKlasaPlanLekcjiViewWindow.Edit;
begin
  EditLekcja('Edycja lekcji', Data, 1, False, True);
end;

procedure TKlasaPlanLekcjiViewWindow.HandleEvent;
var
  D: PZliczaczPrzedmiotow;
begin
  if Event.What=evKeyboard then
  case Event.KeyCode of
    kbF2:
    begin
      New(D, Init(1, 1));
      Application^.ExecuteDialog(D, nil);
    end;
  end;
  inherited HandleEvent(Event);
end;

begin

end.

