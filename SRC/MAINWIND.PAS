unit MainWindow;

interface
uses Objects, Drivers, Views, Dialogs, DataObjects, Lekcja;

type { Typ opisuj¥cy gˆ¢wne okno aplikacji }
  PPlanLekcjiMainWindow = ^TPlanLekcjiMainWindow;
  TPlanLekcjiMainWindow = object (TDialog)
    constructor Init(ATitle: TTitleStr);
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SizeLimits(var Min, Max: TPoint); virtual;
  end;

var MainWin: PPlanLekcjiMainWindow;

procedure DostosujListeLekcji;

implementation
uses App, Latin2, Crt, MsgBox, FiltracjaDanych,
     Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Stale;

const { Tablica zawieraj¥ca nazwy dni tygodnia }
  DzienTygodniaStr: Array[1..IloscDniTygodnia] of String =
    (' Poniedziaˆek ',
     ' Wtorek       ',
     ' —roda        ',
     ' Czwartek     ',
     ' Pi¥tek       ');

const { Staˆe definiuj¥ce kolory element¢w wybranych i niewybranych }
  CSelected = 5;
  CUnselected = 2;

var { Zmienne zawieraj¥ce wskazania do poszczeg¢lnych podwidok¢w gˆ¢wnego okna aplikacji }
  InsideGroup: PGroup;
  DzienView: PView;
  DzwonekView: PView;
  LekcjeView: PView;

  EditGroup: PGroup;
   NauczycielStaticText: PStaticText;
   PrzedmiotStaticText: PStaticText;
   KlasaStaticText: PStaticText;
   GrupyCheckBoxes: PCheckBoxes;
   SalaStaticText: PStaticText;

var { Zmienne zawieraj¥ce dane o stanie wybranych element¢w w gˆ¢wnym oknie aplikacji }
  TopDzien : Integer;
  TopDzwonek: Integer;
  TopLekcja, SelectedLekcja: Integer;
  SelectedLekcjaPtr: PLekcja;
  SelectedDzien: Integer;
  SelectedDzwonek: Integer;
  LekcjeList: PDataCollection;


{ Procedura wpisuj¥ca do zmiennej SelectedLekcjaPtr wskazanie na aktualnie pod˜wietlon¥ lekcja lub nil }
procedure PobierzAktualnaLekcje;
begin
  if Assigned(LekcjeList) and (LekcjeList^.Count>0) then
  begin
    if SelectedLekcja>LekcjeList^.Count-1 then SelectedLekcja:=LekcjeList^.Count-1;
    SelectedLekcjaPtr:=LekcjeList^.At(SelectedLekcja);
  end
  else
  begin
    SelectedLekcjaPtr:=nil;
  end;
  if Assigned(LekcjeView) then LekcjeView^.Draw;
  if Assigned(EditGroup) then EditGroup^.Draw;
end;

{ Procedura dostosowuj¥ca list© lekcji do aktualnie wybranych parametr¢w }
procedure DostosujListeLekcji;
var
  I: Integer;
  D: PDzwonek;
  DzwonekIndex: LongInt;
  Index: LongInt;
  L: PLekcja;
  K: PKlasa;
begin
{
  sound(1000); delay(10); nosound;
}

  { Delete all viewed lessons }
  LekcjeList^.DeleteAll;

  { Get index of the actual "Dzwonek" }
  if Assigned(Dzwonki) and (Dzwonki^.Count>0) then
  begin
    D:=Dzwonki^.At(SelectedDzwonek);
    if Assigned(D) then D^.GetIndex(DzwonekIndex);
  end
  else Exit;

  { Prepare the list }
  I:=0;
  while Assigned(Lekcje[SelectedDzien]) and (I<Lekcje[SelectedDzien]^.Count) do
  begin
    L:=Lekcje[SelectedDzien]^.At(I);
    L^.GetKlasa(K);
    K^.EnableGroupMask:=IncPower2(K^.FIloscGrup);
    L^.GetIndex(Index);
    if L^.Dzwonek=DzwonekIndex then
    begin
      LekcjeList^.Insert(L);
      L^.SetIndex(Index);
    end;
    Inc(I);
  end;

  { Redraw the lesson list view }
  PobierzAktualnaLekcje;
end;


type { Typ definiuj¥cy kontrolk© wyboru dnia }
  PDzienView = ^TDzienView;
  TDzienView = object (TView)
    constructor Init(R: TRect);
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

constructor TDzienView.Init(R: TRect);
begin
  inherited Init(R);
  Options:=Options or ofSelectable;
  GrowMode:=gfGrowHiY;
  TopDzien:=1; SelectedDzien:=1;
end;

procedure TDzienView.Draw;
var
  Y: Integer;
  S: String;
  Color: Byte;
begin
  { Draw column header }
  if GetState(sfSelected) then Color:=CSelected else Color:=CUnselected;
  S:=' Dz. tygodnia ';
  WriteStr(0, 0, S, Color);

  { Check the visibility of items }
  TopDzien:=SelectedDzien-Size.Y+3;
  if TopDzien<1 then TopDzien:=1;

  { Draw the names of days }
  Y:=2;
  while (Y<Size.Y) and (Y-2<5) do
  begin
    S:=DzienTygodniaStr[TopDzien+Y-2];
    if SelectedDzien=TopDzien+Y-2 then Color:=CSelected else Color:=CUnselected;
    WriteStr(0, Y, S, Color);
    Inc(Y);
  end;
end;

procedure TDzienView.HandleEvent(var Event: TEvent);
begin
  if Event.What=evKeyboard then
  case Event.KeyCode of
    kbUp:
    begin
      Dec(SelectedDzien);
      if SelectedDzien<1 then SelectedDzien:=1
      else
      begin
        Draw;
        DostosujListeLekcji;
      end;
    end;
    kbDown:
    begin
      Inc(SelectedDzien);
      if SelectedDzien>5 then SelectedDzien:=5
      else
      begin
        Draw;
        DostosujListeLekcji;
      end;
    end;
  end;
  inherited HandleEvent(Event);
end;


type { Typ definiuj¥cy kontrolk© wyboru dzwonka }
  PDzwonekView = ^TDzwonekView;
  TDzwonekView = object (TView)
    constructor Init(R: TRect);
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

constructor TDzwonekView.Init(R: TRect);
begin
  inherited Init(R);
  Options:=Options or ofSelectable;
  GrowMode:=gfGrowHiY;
  TopDzwonek:=0; SelectedDzwonek:=0;
end;

procedure TDzwonekView.Draw;
var
  Y: Integer;
  S: String;
  D: PDzwonek;
  Color: Byte;
begin
  { Draw column header }
  if GetState(sfSelected) then Color:=CSelected else Color:=CUnselected;
  S:=' Dzwonek ';
  WriteStr(0, 0, S, Color);

  { Check the visibility of items }
  TopDzwonek:=SelectedDzwonek-Size.Y+3;
  if TopDzwonek<0 then TopDzwonek:=0;

  { Draw items }
  Y:=2;
  while Y<Size.Y do
  begin
    { Check if there is anything to get data from }
    if Assigned(Dzwonki) and (Y-2<Dzwonki^.Count) then
    begin
      D:=Dzwonki^.At(TopDzwonek+Y-2);
      S:=D^.GetText(5);
      if SelectedDzwonek=TopDzwonek+Y-2 then Color:=CSelected else Color:=CUnselected;
    end
    else { if not draw an empty string }
    begin
      S:=RepeatStr(' ', Size.X-5);
      Color:=CUnselected;
    end;
    WriteStr(0, Y, '  '+S+'  ',Color);
    Inc(Y);
  end;
end;

procedure TDzwonekView.HandleEvent(var Event: TEvent);
begin
  if Event.What=evKeyboard then
  case Event.KeyCode of
    kbUp: if Assigned(Dzwonki) and (Dzwonki^.Count>0) then
    begin
      Dec(SelectedDzwonek);
      if SelectedDzwonek<0 then SelectedDzwonek:=0
      else
      begin
        Draw;
        DostosujListeLekcji;
      end;
    end;
    kbDown: if Assigned(Dzwonki) and (Dzwonki^.Count>0) then
    begin
      Inc(SelectedDzwonek);
      if SelectedDzwonek>Dzwonki^.Count-1 then SelectedDzwonek:=Dzwonki^.Count-1
      else
      begin
        Draw;
        DostosujListeLekcji;
      end;
    end;
  end;
  inherited HandleEvent(Event);
end;


type { Typ definiuj¥cy kontrolk© wyboru lekcji }
  PLekcjeView = ^TLekcjeView;
  TLekcjeView = object (TView)
    constructor Init(R: TRect);
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

constructor TLekcjeView.Init(R: TRect);
begin
  inherited Init(R);
  Options:=Options or ofSelectable;
  GrowMode:=gfGrowHiY or gfGrowHiX;
  TopLekcja:=0; SelectedLekcja:=0;
end;

procedure TLekcjeView.Draw;
var
  Y, I: Integer;
  St, NS, PS, KS, SS, GS: String;
  N: PNauczyciel;
  P: PPrzedmiot;
  K: PKlasa;
  S: PSala;
  Grupy: Word;
  IloscGrup: Word;
  L: PLekcja;
  Color: Byte;
begin
  { Draw column header }
  if GetState(sfSelected) then Color:=CSelected else Color:=CUnselected;
  St:=' Nauczyciel   Sala   Klasa   123456789   Przedmiot  ';
  WriteStr(0, 0, St, Color);

  { Check the visibility of items }
  TopLekcja:=SelectedLekcja-Size.Y+3;
  if TopLekcja<0 then TopLekcja:=0;

  { Draw items }
  Y:=2;
  while Y<Size.Y do
  begin
    { Check if there is anything to get data from }
    if Assigned(LekcjeList) and (Y-2<LekcjeList^.Count) then
    begin
      L:=LekcjeList^.At(TopLekcja+Y-2);
      L^.GetNauczyciel(N);
      L^.GetPrzedmiot(P);
      L^.GetKlasa(K);
      L^.GetGrupy(Grupy);
      L^.GetSala(S);
      if Assigned(N) then NS:=N^.GetText(5) else NS:='BRAK!'; NS:=NS+SpaceStr(5-Length(NS));
      if Assigned(P) then PS:=P^.GetText(5) else PS:='BRAK!'; PS:=PS+SpaceStr(5-Length(PS));
      if Assigned(K) then
      begin
        KS:=K^.GetText(5); KS:=KS+SpaceStr(5-Length(KS));
        GS:='';
        for I:=0 to 8 do
        begin
          if Grupy and 1<>0 then GS:=GS+'*' else GS:=GS+'-';
          Grupy:=Grupy shr 1;
        end;
      end
      else
      begin
        KS:='BRAK!';
        GS:='         ';
      end;
      if Assigned(S) then SS:=S^.GetText(5) else SS:='BRAK!';
      if SelectedLekcja=TopLekcja+Y-2 then Color:=CSelected else Color:=CUnselected;
    end
    else { if not draw an empty string }
    begin
      NS:='     ';
      PS:='     ';
      KS:='     ';
      GS:='         ';
      SS:='     ';
      Color:=CUnselected;
    end;
    WriteStr(0, Y,  ' '+NS+'      ', Color);
    WriteStr(13, Y, ' '+SS, Color);
    WriteStr(20, Y, ' '+KS+' ', Color);
    WriteStr(28, Y, ' '+GS+' ', Color);
    WriteStr(40, Y, ' '+PS+'      ', Color);
    Inc(Y);
  end;
end;

procedure TLekcjeView.HandleEvent(var Event: TEvent);
begin
  if Event.What=evKeyboard then
  case Event.KeyCode of
    kbUp: if Assigned(LekcjeList) and (LekcjeList^.Count>0) then
    begin
      Dec(SelectedLekcja);
      if SelectedLekcja<0 then SelectedLekcja:=0
      else
      begin
        PobierzAktualnaLekcje;
        Draw;
      end;
    end;
    kbDown: if Assigned(LekcjeList) and (LekcjeList^.Count>0) then
    begin
      Inc(SelectedLekcja);
      if SelectedLekcja>LekcjeList^.Count-1 then SelectedLekcja:=LekcjeList^.Count-1
      else
      begin
        PobierzAktualnaLekcje;
        Draw;
      end;
    end;
  end;
  inherited HandleEvent(Event);
end;


type { Typ definiuj¥cy kontrolk© edycji/podgl¥du lekcji }
  PEditGroup = ^TEditGroup;
  TEditGroup = object (TGroup)
    constructor Init(R: TRect);
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

constructor TEditGroup.Init(R: TRect);
begin
  inherited Init(R);
  GrowMode:=gfGrowHiX or gfGrowHiY or gfGrowLoY;
  Options:=Options and (not ofSelectable);

  R.Assign(0, 0, slImieNazwisko, 1);
  New(NauczycielStaticText, Init(R, SpaceStr(slImieNazwisko)));
  Insert(NauczycielStaticText);

  R.Assign(0, 1, slNazwaSali+slNumerSali+3, 2);
  New(SalaStaticText, Init(R, SpaceStr(slNazwaSali+slNumerSali+3)));
  Insert(SalaStaticText);

  R.Assign(0, 2, 10, 3);
  New(KlasaStaticText, Init(R, SpaceStr(10)));
  Insert(KlasaStaticText);

  R.Assign(0, 3, 9*7, 4);
  New(GrupyCheckBoxes, Init(R,
    NewSItem('~1~',
    NewSItem('~2~',
    NewSItem('~3~',
    NewSItem('~4~',
    NewSItem('~5~',
    NewSItem('~6~',
    NewSItem('~7~',
    NewSItem('~8~',
    NewSItem('~9~', nil)))))))))));
  Insert(GrupyCheckBoxes);
  with GrupyCheckBoxes^ do Options:=Options and (not ofSelectable);

  R.Assign(0, 4, slNazwaPrzedmiotu, 5);
  New(PrzedmiotStaticText, Init(R, SpaceStr(slNazwaPrzedmiotu)));
  Insert(PrzedmiotStaticText);
end;

procedure TEditGroup.Draw;
var
  Y: Integer;
  St, NS, PS, KS, GS, SS: String;
  EnableMask: Word;
  Grupy: Word;
  N: PNauczyciel;
  P: PPrzedmiot;
  K: PKlasa;
  S: PSala;
begin
  St:=RepeatStr(' ', Size.X);
  for Y:=0 to Size.Y do WriteStr(0, Y, St, 2);
  if Assigned(SelectedLekcjaPtr) then
  begin
    SelectedLekcjaPtr^.GetNauczyciel(N);
    SelectedLekcjaPtr^.GetPrzedmiot(P);
    SelectedLekcjaPtr^.GetKlasa(K);
    SelectedLekcjaPtr^.GetGrupy(Grupy);
    SelectedLekcjaPtr^.GetSala(S);
    if Assigned(N) then NS:=N^.GetText(255) else NS:='';
    if Assigned(P) then PS:=P^.GetText(255) else PS:='';
    if Assigned(K) then KS:=K^.GetText(255) else KS:='';
    if Assigned(S) then SS:=S^.GetText(255) else SS:='';
  end
  else
  begin
    NS:='';
    PS:='';
    KS:='';
    SS:='';
    Grupy:=0;
    EnableMask:=0;
  end;

  if Assigned(NauczycielStaticText) then
  begin
    NauczycielStaticText^.Text^:=NS;
    NauczycielStaticText^.Draw;
  end;
  if Assigned(PrzedmiotStaticText) then
  begin
    PrzedmiotStaticText^.Text^:=PS;
    PrzedmiotStaticText^.Draw;
  end;
  if Assigned(KlasaStaticText) then
  begin
    KlasaStaticText^.Text^:=KS;
    KlasaStaticText^.Draw;
  end;
  if Assigned(SalaStaticText) then
  begin
    SalaStaticText^.Text^:=SS;
    SalaStaticText^.Draw;
  end;
  if Assigned(GrupyCheckBoxes) then
  begin
    GrupyCheckBoxes^.SetData(Grupy);
    GrupyCheckBoxes^.Draw;
  end;
end;

procedure TEditGroup.HandleEvent(var Event: TEvent);
var
  Index: Integer;
  Grupy: Word;
begin
  inherited HandleEvent(Event);
end;


type { Typ definiuj¥cy wn©trze gˆ¢wnego okna aplikacji }
  PInsideGroup = ^TInsideGroup;
  TInsideGroup = object (TGroup)
    constructor Init(R: TRect);
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

constructor TInsideGroup.Init(R: TRect);
begin
  inherited Init(R);
  GrowMode:=gfGrowHiX or gfGrowHiY;

  R.Assign(0, 0, 14, Size.Y-6);
  DzienView:=New(PDzienView, Init(R));
  Insert(DzienView);

  R.Assign(15, 0, 25, Size.Y-6);
  DzwonekView:=New(PDzwonekView, Init(R));
  Insert(DzwonekView);

  R.Assign(26, 0, Size.X, Size.Y-6);
  LekcjeView:=New(PLekcjeView, Init(R));
  Insert(LekcjeView);

  R.Assign(14, Size.Y-5, Size.X, Size.Y);
  EditGroup:=New(PEditGroup, Init(R));
  Insert(EditGroup);

  DzienView^.Select;
end;

procedure TInsideGroup.Draw;
var
  Y: Integer;
  S: String;
  C1, C2, C3, C4, C5: Char;
  Color: Byte;
begin
  { Init special characters }
  C1:='Ä'; C2:='³'; C3:='Å'; C4:='Â'; C5:='Á';
  Color:=CUnselected;

  { Draw the frames wiht some texts }
  S:=' Dz. tygodnia '+C2+' Dzwonek '+C2+C2+' Nauczyciel   Sala   Klasa   123456789   Przedmiot  ';
  WriteStr(0, 0, S, Color);

  S:=RepeatStr(C1, Size.X);
  S[15]:=C3; S[25]:=C3; S[26]:=C3; S[39]:=C4; S[46]:=C4; S[54]:=C4; S[66]:=C4;
  WriteStr(0, 1, S, Color);

  S:=RepeatStr(' ', Size.X);
  S[15]:=C2; S[25]:=C2; S[26]:=C2; S[39]:=C2; S[46]:=C2; S[54]:=C2; S[66]:=C2;
  for Y:=2 to Size.Y-7 do WriteStr(0, Y, S, Color);

  S:=RepeatStr(C1, Size.X);
  S[15]:=C5; S[25]:=C5; S[26]:=C5; S[39]:=C5; S[46]:=C5; S[54]:=C5; S[66]:=C5;
  WriteStr(0, Size.Y-6, S, Color);

  { Draw editor labels }
  S:=' Nauczyciel:  '; WriteStr(0, Size.Y-5, S, Color);
  S:=' Sala:        '; WriteStr(0, Size.Y-4, S, Color);
  S:=' Klasa:       '; WriteStr(0, Size.Y-3, S, Color);
  S:=' Grupy:       '; WriteStr(0, Size.Y-2, S, Color);
  S:=' Przedmiot:   '; WriteStr(0, Size.Y-1, S, Color);

  { Draw all the others views }
  if Assigned(DzienView) then DzienView^.Draw;
  if Assigned(DzwonekView) then DzwonekView^.Draw;
  if Assigned(LekcjeView) then LekcjeView^.Draw;
  if Assigned(EditGroup) then EditGroup^.Draw;
end;

procedure EditLekcjaNow;
var
  V: PView;
  L: PLekcja;
  LI: LongInt;
  I: Integer;
  Found: Boolean;
  I1, I2: LongInt;
begin
  DostosujListeLekcji;
  if SelectedLekcjaPtr=nil then Exit;
  SelectedLekcjaPtr^.GetIndex(I1);

  I:=0; Found:=False;
  while (I<LekcjeList^.Count) and (not Found) do
  begin
    L:=LekcjeList^.At(I);
    L^.GetIndex(I2);
    if I1=I2 then Found:=True
    else Inc(I);
  end;

  if not Found then Exit;
  LekcjeList^.AtDelete(I);
  L^.GetIndex(LI); L^.SetIndex(-1);

  FiltrujDane(LekcjeList);

  EditLekcja('Edycja lekcji', SelectedLekcjaPtr, 1, False, False);

  PrzywrocDane;

  LekcjeList^.Insert(SelectedLekcjaPtr);
  L^.SetIndex(LI);

  DostosujListeLekcji;
end;

procedure DeleteLekcjaNow;
var
  Index1, Index2: LongInt;
  L: PLekcja;
  I: Integer;
begin
  if Assigned(SelectedLekcjaPtr) then
  begin
    if MessageBox(#3'Czy na pewno chcesz usun¥† t¥ lekcj© ?', nil, mfConfirmation or mfYesButton or mfNoButton)<>cmCancel then
    begin
      SelectedLekcjaPtr^.GetIndex(Index1);
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
      DostosujListeLekcji;
    end;
  end;
end;

procedure InsertLekcjaNow;
var V: PView;
    L: PLekcja;
begin
  if not Assigned(Dzwonki) or (Dzwonki^.Count=0) then
  begin
    MessageBox(#3'Lista dzwonk¢w jest pusta !'#13#10#3'Uzupeˆnij list© dzwonk¢w', nil,
               mfError or mfCancelButton);
    Exit;
  end;
  FiltrujDane(LekcjeList);

  New(L, Init);

  if EditLekcja('Dodawanie nowej lekcji', L, 0, False, False) then
  begin
    Lekcje[SelectedDzien]^.Insert(L);
    L^.SetDzwonek(Dzwonki^.At(SelectedDzwonek));
  end
  else
  begin
    L^.Free;
    L:=nil;
  end;

  PrzywrocDane;
  DostosujListeLekcji;
  EditGroup^.Draw;
end;

procedure TInsideGroup.HandleEvent(var Event: TEvent);
begin
  if Event.What=evKeyboard then
  case Event.KeyCode of
    kbTab, kbRight:
    begin
      if Current=PView(DzienView) then
      begin
        DzwonekView^.Select;
        DzwonekView^.Draw;
        DzienView^.Draw;
      end
      else if Current=PView(DzwonekView) then
      begin
        LekcjeView^.Select;
        LekcjeView^.Draw;
        DzwonekView^.Draw;
      end;
    end;
    kbShiftTab, kbLeft:
    begin
      if Current=PView(DzwonekView) then
      begin
        DzienView^.Select;
        DzienView^.Draw;
        DzwonekView^.Draw;
      end
      else if Current=PView(LekcjeView) then
      begin
        DzwonekView^.Select;
        DzwonekView^.Draw;
        LekcjeView^.Draw;
      end;
    end;
    kbEnter: Message(Owner, evCommand, cmPoprawLekcje, nil);
    kbDel: Message(Owner, evCommand, cmUsunLekcje, nil);
    kbIns: Message(Owner, evCommand, cmDodajLekcje, nil);
  end;
  inherited HandleEvent(Event);
end;


  { TPlanLekcjiMainWindow }

constructor TPlanLekcjiMainWindow.Init(ATitle: TTitleStr);
var R: TRect;
begin
  Desktop^.GetExtent(R); Dec(R.B.Y, 0);
  inherited Init(R, ATitle);
  Options:=Options or ofCentered;
  Flags:=wfMove or wfGrow or wfZoom;
  Palette:=dpBlueDialog;

  R.Grow(-1, -1);
  InsideGroup:=New(PInsideGroup, Init(R));
  Insert(InsideGroup);

  New(LekcjeList, Init(10, 5));
  DostosujListeLekcji;
  HelpCtx:=$1000;
end;

destructor TPlanLekcjiMainWindow.Done;
begin
  LekcjeList^.DeleteAll;
  Dispose(LekcjeList, Done);
  inherited Done;
end;

procedure TPlanLekcjiMainWindow.HandleEvent(var Event: TEvent);
begin
  if Event.What=evBroadcast then
  case Event.Command of
    cmDataChanged:
    begin
      DostosujListeLekcji;
      ReDraw;
    end;
  end
  else if Event.What=evCommand then
  case Event.Command of
    cmDodajLekcje: InsertLekcjaNow;
    cmUsunLekcje: DeleteLekcjaNow;
    cmPoprawLekcje: EditLekcjaNow;
  end;
  inherited HandleEvent(Event);
end;

procedure TPlanLekcjiMainWindow.SizeLimits(var Min, Max: TPoint);
begin
  inherited SizeLimits(Min, Max);
  if Min.Y<11 then Min.Y:=11;
  Min.X:=80;
end;

begin
end.
