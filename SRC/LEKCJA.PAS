Unit Lekcja;

interface
uses Objects, Drivers, Views, Dialogs, Validate, MsgBox,
     DataObjects, DataDialogs,
     Nauczyciel, Przedmiot, Klasa, Sala, Stale, Dzwonek;

const { Staˆa determinuj¥ca ilo˜† dni tygodnia }
  IloscDniTygodnia = 5;

type { Typ opisuj¥cy lekcj© }
  PLekcja = ^TLekcja;
  TLekcja = object (TDataObject)
    FNauczyciel: LongInt;
    FPrzedmiot: LongInt;
    FKlasa: LongInt;
    FSala: LongInt;
  public
    FGrupy: Word;
    Dzwonek: LongInt;
    constructor Init;
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function Compare(Data: PDataObject): Integer; virtual;
    function GetText(MaxLen: Integer): String; virtual;
    procedure GetNauczyciel(var ANauczyciel: PNauczyciel);
    procedure GetPrzedmiot(var APrzedmiot: PPrzedmiot);
    procedure GetKlasa(var AKlasa: PKlasa);
    procedure GetSala(var ASala: PSala);
    procedure GetDzwonek(var ADzwonek: PDzwonek);
    procedure GetNauczycielIndex(var Index: LongInt);
    procedure GetPrzedmiotIndex(var Index: LongInt);
    procedure GetKlasaIndex(var Index: LongInt);
    procedure GetSalaIndex(var Index: LongInt);
    procedure GetDzwonekIndex(var Index: LongInt);
    procedure GetGrupy(var Grupy: Word);
    procedure SetNauczyciel(const ANauczyciel: PNauczyciel);
    procedure SetPrzedmiot(const APrzedmiot: PPrzedmiot);
    procedure SetKlasa(const AKlasa: PKlasa);
    procedure SetSala(const ASala: PSala);
    procedure SetDzwonek(const ADzwonek: PDzwonek);
    procedure SetNauczycielIndex(const Index: LongInt);
    procedure SetPrzedmiotIndex(const Index: LongInt);
    procedure SetKlasaIndex(const Index: LongInt);
    procedure SetSalaIndex(const Index: LongInt);
    procedure SetDzwonekIndex(const Index: LongInt);
    procedure SetGrupy(const Grupy: Word);
    procedure Store(var S: TStream); virtual;
  end;

type { Typ opisuj¥cy okno edycji lekcji }
  PLekcjaDialog = ^TLekcjaDialog;
  TLekcjaDialog = object (TDataDialog)
  private
    FNauczycielStaticText: PStaticText;
    FPrzedmiotStaticText: PStaticText;
    FSalaStaticText: PStaticText;
    FKlasaStaticText: PStaticText;
    FGrupyCheckBoxes: PCheckBoxes;
    FNauczycielLabel: PLabel;
    FPrzedmiotLabel: PLabel;
    FSalaLabel: PLabel;
    FKlasaLabel: PLabel;
    FGrupyLabel: PLabel;

    FNauczycielIndex: LongInt;
    FPrzedmiotIndex: LongInt;
    FKlasaIndex: LongInt;
    FSalaIndex: LongInt;

    procedure ChangeNauczyciel;
    procedure ChangePrzedmiot;
    procedure ChangeSala;
    procedure ChangeKlasa;
    procedure UpdateNauczyciel;
    procedure UpdatePrzedmiot;
    procedure UpdateSala;
    procedure UpdateKlasa;
  public
    constructor Init(ATitle: TTitleStr);
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream); virtual;
  end;

function EditLekcja(ATitle: TTitleStr; var ALekcja: PLekcja; AddIndex: Integer; DisNauczyciel, DisKlasa: Boolean): Boolean;

const { Staˆe do rejestracji typ¢w w strumieniach }
  RLekcja: TStreamRec = (
    ObjType: $1500;
    VmtLink: Ofs(TypeOf(TLekcja)^);
    Load   : @TLekcja.Load;
    Store  : @TLekcja.Store);
  RLekcjaDialog: TStreamRec = (
    ObjType: $1501;
    VmtLink: Ofs(TypeOf(TLekcjaDialog)^);
    Load   : @TLekcjaDialog.Load;
    Store  : @TLekcjaDialog.Store);

procedure RegisterLekcja;

var Lekcje: Array[1..IloscDniTygodnia] of PDataCollection;

implementation
uses App, Latin2;

  { TLekcja }

constructor TLekcja.Init;
begin
  inherited Init;
  FNauczyciel:=-1;
  FPrzedmiot:=-1;
  FKlasa:=-1;
  FGrupy:=0;
  FSala:=-1;
  Dzwonek:=-1;
end;

constructor TLekcja.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(FNauczyciel, SizeOf(FNauczyciel));
  S.Read(FPrzedmiot, SizeOf(FPrzedmiot));
  S.Read(FKlasa, SizeOf(FKlasa));
  S.Read(FGrupy, SizeOf(FGrupy));
  S.Read(FSala, SizeOf(FSala));
  S.Read(Dzwonek, SizeOf(Dzwonek));
end;

destructor TLekcja.Done;
begin
  FNauczyciel:=-1;
  FPrzedmiot:=-1;
  FKlasa:=-1;
  FGrupy:=0;
  FSala:=-1;
  inherited Done;
end;

function TLekcja.Compare(Data: PDataObject): Integer;
var
  Nauczyciel1, Nauczyciel2: PNauczyciel;
  Przedmiot1, Przedmiot2: PPrzedmiot;
  Klasa1, Klasa2: PKlasa;
  Sala1, Sala2: PSala;
  Temp: Integer;
begin
  GetNauczyciel(Nauczyciel1); PLekcja(Data)^.GetNauczyciel(Nauczyciel2);
  GetPrzedmiot(Przedmiot1); PLekcja(Data)^.GetPrzedmiot(Przedmiot2);
  GetKlasa(Klasa1); PLekcja(Data)^.GetKlasa(Klasa2);
  GetSala(Sala1); PLekcja(Data)^.GetSala(Sala2);
  Temp:=0;
  if (Klasa1<>nil) and (Klasa2<>nil) then Temp:=Klasa1^.Compare(Klasa2);
  if Temp=0 then Temp:=-1;

{
  begin
    if (Nauczyciel1<>nil) and (Nauczyciel2<>nil) then Temp:=Nauczyciel1^.Compare(Nauczyciel2);
    if Temp=0 then
    begin
      if (Sala1<>Nil) and (Sala2<>nil) then Temp:=Sala1^.Compare(Sala2);
      if Temp=0 then
      begin
        if (Przedmiot1<>nil) and (Przedmiot2<>nil) then Temp:=Przedmiot1^.Compare(Przedmiot2);
      end;
    end;
  end;
}
  Compare:=Temp;
end;

function TLekcja.GetText(MaxLen: Integer): String;
var
  ANauczyciel: PNauczyciel;
  APrzedmiot: PPrzedmiot;
  AKlasa: PKlasa;
  ASala: PSala;
  S1, S2: String;
begin
  S1:=''; S2:='';
  GetNauczyciel(ANauczyciel);
  if ANauczyciel<>nil then
  begin
    ANauczyciel^.GetSkrot(S2);
    if Length(S2)<slSkrot then S2:=S2+SpaceStr(slSkrot-Length(S2));
  end
  else
  begin
    S2:='BRAK!';
  end;
  S1:=S2+'       ';
  S1:=S2+' ';

  GetPrzedmiot(APrzedmiot);
  if APrzedmiot<>nil then
  begin
    APrzedmiot^.GetSkrot(S2);
    if Length(S2)<slSkrot then S2:=S2+SpaceStr(slSkrot-Length(S2));
  end
  else
  begin
    S2:='BRAK!';
  end;
  S1:=S1+S2+'      ';

  GetKlasa(AKlasa);
  if AKlasa<>nil then
  begin
    S2:=AKlasa^.GetText(slNumerKlasy+1);
    if Length(S2)<slSkrot then S2:=S2+SpaceStr(slSkrot-Length(S2));
  end
  else
  begin
    S2:='BRAK!';
  end;
  S1:=S1+S2+'  ';

  GetSala(ASala);
  if ASala<>nil then
  begin
    ASala^.GetNumer(S2);
  end
  else
  begin
    S2:='BRAK!';
  end;
  S1:=S1+S2;

  if Assigned(APrzedmiot) then S1:=ANauczyciel^.GetText(5)+'/' else S1:='BRAK!/';
  if Assigned(APrzedmiot) then S1:=S1+APrzedmiot^.GetText(5)+'/' else S1:=S1+'BRAK!/';
  if Assigned(ASala) then S1:=S1+ASala^.GetText(5)+'/' else S1:=S1+'BRAK!/';

  GetText:=Copy(S1, 1, MaxLen);
end;

procedure TLekcja.GetNauczyciel(var ANauczyciel: PNauczyciel);
begin
  if (Nauczyciele<>nil) and (Nauczyciele^.Count>0) and (FNauczyciel<>-1) then
  begin
    ANauczyciel:=PNauczyciel(Nauczyciele^.ItemByIndex(FNauczyciel));
  end
  else
  begin
    ANauczyciel:=nil;
  end;
end;

procedure TLekcja.GetPrzedmiot(var APrzedmiot: PPrzedmiot);
begin
  if (Przedmioty<>nil) and (Przedmioty^.Count>0) and (FPrzedmiot<>-1) then
  begin
    APrzedmiot:=PPrzedmiot(Przedmioty^.ItemByIndex(FPrzedmiot));
  end
  else
  begin
    APrzedmiot:=nil;
  end;
end;

procedure TLekcja.GetKlasa(var AKlasa: PKlasa);
begin
  if (Klasy<>nil) and (Klasy^.Count>0) and (FKlasa<>-1) then
  begin
    AKlasa:=PKlasa(Klasy^.ItemByIndex(FKlasa));
  end
  else
  begin
    AKlasa:=nil;
  end;
end;

procedure TLekcja.GetSala(var ASala: PSala);
begin
  if (Sale<>nil) and (Sale^.Count>0) and (FSala<>-1) then
  begin
    ASala:=PSala(Sale^.ItemByIndex(FSala));
  end
  else
  begin
    ASala:=nil;
  end;
end;

procedure TLekcja.GetDzwonek(var ADzwonek: PDzwonek);
begin
  if (Dzwonki<>nil) and (Dzwonki^.Count>0) and (Dzwonek<>-1) then
  begin
    ADzwonek:=PDzwonek(Dzwonki^.ItemByIndex(Dzwonek));
  end
  else
  begin
    ADzwonek:=nil;
  end;
end;

procedure TLekcja.GetNauczycielIndex(var Index: LongInt);
begin
  Index:=FNauczyciel;
end;

procedure TLekcja.GetPrzedmiotIndex(var Index: LongInt);
begin
  Index:=FPrzedmiot;
end;

procedure TLekcja.GetKlasaIndex(var Index: LongInt);
begin
  Index:=FKlasa;
end;

procedure TLekcja.GetSalaIndex(var Index: LongInt);
begin
  Index:=FSala;
end;

procedure TLekcja.GetDzwonekIndex(var Index: LongInt);
begin
  Index:=Dzwonek;
end;

procedure TLekcja.GetGrupy(var Grupy: Word);
begin
  Grupy:=FGrupy;
end;

procedure TLekcja.SetNauczyciel(const ANauczyciel: PNauczyciel);
begin
  if ANauczyciel<>nil then ANauczyciel^.GetIndex(FNauczyciel)
  else FNauczyciel:=-1;
end;

procedure TLekcja.SetPrzedmiot(const APrzedmiot: PPrzedmiot);
begin
  if APrzedmiot<>nil then APrzedmiot^.GetIndex(FPrzedmiot)
  else FPrzedmiot:=-1;
end;

procedure TLekcja.SetKlasa(const AKlasa: PKlasa);
begin
  if AKlasa<>nil then AKlasa^.GetIndex(FKlasa)
  else FKlasa:=-1;
end;

procedure TLekcja.SetSala(const ASala: PSala);
begin
  if ASala<>nil then ASala^.GetIndex(FSala)
  else FSala:=-1;
end;

procedure TLekcja.SetDzwonek(const ADzwonek: PDzwonek);
begin
  if ADzwonek<>nil then ADzwonek^.GetIndex(Dzwonek)
  else Dzwonek:=-1;
end;

procedure TLekcja.SetNauczycielIndex(const Index: LongInt);
begin
  FNauczyciel:=Index;
end;

procedure TLekcja.SetPrzedmiotIndex(const Index: LongInt);
begin
  FPrzedmiot:=Index;
end;

procedure TLekcja.SetKlasaIndex(const Index: LongInt);
begin
  FKlasa:=Index;
end;

procedure TLekcja.SetSalaIndex(const Index: LongInt);
begin
  FSala:=Index;
end;

procedure TLekcja.SetDzwonekIndex(const Index: LongInt);
begin
  Dzwonek:=Index;
end;

procedure TLekcja.SetGrupy(const Grupy: Word);
begin
  FGrupy:=Grupy;
end;

procedure TLekcja.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(FNauczyciel, SizeOf(FNauczyciel));
  S.Write(FPrzedmiot, SizeOf(FPrzedmiot));
  S.Write(FKlasa, SizeOf(FKlasa));
  S.Write(FGrupy, SizeOf(FGrupy));
  S.Write(FSala, SizeOf(FSala));
  S.Write(Dzwonek, SizeOf(Dzwonek));
end;


  { TLekcjaDialog }

constructor TLekcjaDialog.Init(ATitle: TTitleStr);
var
  R: TRect;
  W: Word;
begin
  R.Assign(0, 0, 68, 12);
  inherited Init(R, ATitle);

  R.Assign(15, 2, Size.X-18, 3);
  New(FNauczycielStaticText, Init(R,'(BRAK)'));
  with FNauczycielStaticText^ do
  begin
    Options:=Options or ofSelectable;
    SetState(sfCursorVis, True);
  end;
  Insert(FNauczycielStaticText);

  R.Assign(2, 2, 15, 3);
  New(FNauczycielLabel, Init(R, '~N~auczyciel: ', FNauczycielStaticText));
  Insert(FNauczycielLabel);

  R.Assign(15, 3, Size.X-18, 4);
  New(FPrzedmiotStaticText, Init(R,'(BRAK)'));
  with FPrzedmiotStaticText^ do
  begin
    Options:=Options or ofSelectable;
    SetState(sfCursorVis, True);
  end;
  Insert(FPrzedmiotStaticText);

  R.Assign(2, 3, 15, 4);
  New(FPrzedmiotLabel, Init(R, '~P~rzedmiot : ', FPrzedmiotStaticText));
  Insert(FPrzedmiotLabel);

  R.Assign(15, 4, Size.X-18, 5);
  New(FSalaStaticText, Init(R,'(BRAK)'));
  with FSalaStaticText^ do
  begin
    Options:=Options or ofSelectable;
    SetState(sfCursorVis, True);
  end;
  Insert(FSalaStaticText);

  R.Assign(2, 4, 15, 5);
  New(FSalaLabel, Init(R, '~S~ala      : ', FSalaStaticText));
  Insert(FSalaLabel);

  R.Assign(15, 5, Size.X-18, 6);
  New(FKlasaStaticText, Init(R,'(BRAK)'));
  with FKlasaStaticText^ do
  begin
    Options:=Options or ofSelectable;
    SetState(sfCursorVis, True);
  end;
  Insert(FKlasaStaticText);

  R.Assign(2, 5, 15, 6);
  New(FKlasaLabel, Init(R, '~K~lasa     : ', FKlasaStaticText));
  Insert(FKlasaLabel);

  R.Assign(15, 6, Size.X-18, 8);
  New(FGrupyCheckBoxes, Init(R,
    NewSItem('~1~', NewSItem('~2~',
    NewSItem('~3~', NewSItem('~4~',
    NewSItem('~5~', NewSItem('~6~',
    NewSItem('~7~', NewSItem('~8~',
    NewSItem('~9~',
  nil)))))))))));
  Insert(FGrupyCheckBoxes);
  with FGrupyCheckBoxes^ do Options:=Options and (not ofSelectable);

  R.Assign(2, 6, 15, 7);
  New(FGrupyLabel, Init(R, '~G~rupy     : ', FGrupyCheckBoxes));
  Insert(FGrupyLabel);

  FNauczycielStaticText^.Select;

  FNauczycielIndex:=-1;
  FPrzedmiotIndex:=-1;
  FSalaIndex:=-1;
  FKlasaIndex:=-1;

  HelpCtx:=$1101;
end;

constructor TLekcjaDialog.Load(var S: TStream);
begin
  inherited Load(S);
  GetSubViewPtr(S, FNauczycielStaticText);
  GetSubViewPtr(S, FPrzedmiotStaticText);
  GetSubViewPtr(S, FSalaStaticText);
  GetSubViewPtr(S, FKlasaStaticText);
  GetSubViewPtr(S, FGrupyCheckBoxes);
  GetSubViewPtr(S, FNauczycielLabel);
  GetSubViewPtr(S, FPrzedmiotLabel);
  GetSubViewPtr(S, FSalaLabel);
  GetSubViewPtr(S, FKlasaLabel);
  GetSubViewPtr(S, FGrupyLabel);
  FNauczycielIndex:=-1;
  FPrzedmiotIndex:=-1;
  FSalaIndex:=-1;
  FKlasaIndex:=-1;
end;

procedure TLekcjaDialog.ChangeNauczyciel;
var Index: Integer;
begin
  Index:=ChooseNauczyciel(Nauczyciele, False);
  if Index<>-1 then
  begin
    FNauczycielIndex:=Index;
    UpdateNauczyciel;
    SelectNext(False);
  end;
end;

procedure TLekcjaDialog.ChangePrzedmiot;
var Index: Integer;
begin
  Index:=ChoosePrzedmiot(Przedmioty, False);
  if Index<>-1 then
  begin
    FPrzedmiotIndex:=Index;
    UpdatePrzedmiot;
    SelectNext(False);
  end;
end;

procedure TLekcjaDialog.ChangeSala;
var Index: Integer;
begin
  Index:=ChooseSala(Sale, False);
  if Index<>-1 then
  begin
    FSalaIndex:=Index;
    UpdateSala;
    SelectNext(False);
  end;
end;

procedure TLekcjaDialog.ChangeKlasa;
var
  Index: Integer;
  Grupy: Word;
  I, J: Integer;
  K: PKlasa;
  IloscGrup: Word;
  EnableMask: Word;
begin
  Index:=ChooseKlasa(Klasy, False);
  if Index<>-1 then
  begin
    FKlasaIndex:=Index;
    UpdateKlasa;
    Grupy:=0;
    FGrupyCheckBoxes^.SetData(Grupy);
    with FGrupyCheckBoxes^ do Options:=Options or ofSelectable;
    K:=PKlasa(Klasy^.ItemByIndex(Index));
    K^.GetIloscGrup(IloscGrup);
    EnableMask:=K^.EnableGroupMask;
    for I:=1 to IloscGrup do
    begin
      if EnableMask and 1<>0 then Break
      else EnableMask:=EnableMask shr 1;
    end;
    EnableMask:=1;
    for J:=1 to I-1 do EnableMask:=(EnableMask shl 1);
    FGrupyCheckBoxes^.GetData(I);
    I:=I or EnableMask;
    FGrupyCheckBoxes^.SetData(I);
    SelectNext(False);
  end;
end;

procedure TLekcjaDialog.UpdateNauczyciel;
var ANauczyciel: PNauczyciel;
begin
  if FNauczycielIndex=-1 then
  begin
    with FNauczycielStaticText^ do
    begin
      if (Text<>nil) then DisposeStr(Text);
      Text:=NewStr('(BRAK)');
      Draw;
    end;
  end
  else
  begin
    ANauczyciel:=PNauczyciel(Nauczyciele^.ItemByIndex(FNauczycielIndex));
    with FNauczycielStaticText^ do
    if ANauczyciel<>nil then
    begin
      if (Text<>nil) then DisposeStr(Text);
      Text:=NewStr(ANauczyciel^.GetText(255));
      Draw;
    end
    else
    begin
      if (Text<>nil) then DisposeStr(Text);
      Text:=NewStr('(BRAK)');
      Draw;
    end;
  end;
end;

procedure TLekcjaDialog.UpdatePrzedmiot;
var APrzedmiot: PPrzedmiot;
begin
  if FPrzedmiotIndex=-1 then
  begin
    with FPrzedmiotStaticText^ do
    begin
      if (Text<>nil) then DisposeStr(Text);
      Text:=NewStr('(BRAK)');
      Draw;
    end;
  end
  else
  begin
    APrzedmiot:=PPrzedmiot(Przedmioty^.ItemByIndex(FPrzedmiotIndex));
    with FPrzedmiotStaticText^ do
    if APrzedmiot<>nil then
    begin
      if (Text<>nil) then DisposeStr(Text);
      Text:=NewStr(APrzedmiot^.GetText(255));
      Draw;
    end
    else
    begin
      if (Text<>nil) then DisposeStr(Text);
      Text:=NewStr('(BRAK)');
      Draw;
    end;
  end;
end;

procedure TLekcjaDialog.UpdateSala;
var ASala: PSala;
begin
  if FSalaIndex=-1 then
  begin
    with FSalaStaticText^ do
    begin
      if (Text<>nil) then DisposeStr(Text);
      Text:=NewStr('(BRAK)');
      Draw;
    end;
  end
  else
  begin
    ASala:=PSala(Sale^.ItemByIndex(FSalaIndex));
    with FSalaStaticText^ do
    if ASala<>nil then
    begin
      if (Text<>nil) then DisposeStr(Text);
      Text:=NewStr(ASala^.GetText(255));
      Draw;
    end
    else
    begin
      if (Text<>nil) then DisposeStr(Text);
      Text:=NewStr('(BRAK)');
      Draw;
    end;
  end;
end;

procedure TLekcjaDialog.UpdateKlasa;
var
  AKlasa: PKlasa;
  Grupy, T, D, I: Word;
begin
  if FKlasaIndex=-1 then
  begin
    with FKlasaStaticText^ do
    begin
      if (Text<>nil) then DisposeStr(Text);
      Text:=NewStr('(BRAK)');
      Draw;
    end;
  end
  else
  begin
    AKlasa:=PKlasa(Klasy^.ItemByIndex(FKlasaIndex));
    with FKlasaStaticText^ do
    if AKlasa<>nil then
    begin
      if (Text<>nil) then DisposeStr(Text);
      Text:=NewStr(AKlasa^.GetText(255));
      Draw;
      AKlasa^.GetIloscGrup(Grupy);
      T:=0;
      for I:=0 to Grupy-1 do T:=(T shl 1)+1;
      FGrupyCheckBoxes^.EnableMask:=T and AKlasa^.EnableGroupMask;
    end
    else
    begin
      if (Text<>nil) then DisposeStr(Text);
      Text:=NewStr('(BRAK)');
      Draw;
    end;
  end;
end;

procedure TLekcjaDialog.HandleEvent(var Event: TEvent);
var
  Index: Integer;
  ANauczyciel: PNauczyciel;
  APrzedmiot: PPrzedmiot;
  AKlasa: PKlasa;
  ASala: PSala;
begin
  if (Event.What=evKeyboard) and (Current<>PView(FGrupyCheckBoxes)) then
  begin
    case Event.KeyCode of
      kbUp: SelectNext(True);
      kbDown: SelectNext(False);
      kbEnter:
        if (Current=PView(FNauczycielStaticText)) then
        begin
          ChangeNauczyciel;
          ClearEvent(Event);
        end
        else if (Current=PView(FPrzedmiotStaticText)) then
        begin
          ChangePrzedmiot;
          ClearEvent(Event);
        end
        else if (Current=PView(FSalaStaticText)) then
        begin
          ChangeSala;
          ClearEvent(Event);
        end
        else if (Current=PView(FKlasaStaticText)) then
        begin
          ChangeKlasa;
          ClearEvent(Event);
        end;
    end;
  end;
  inherited HandleEvent(Event);
end;

procedure TLekcjaDialog.GetData(var Rec);
var Grupy: Word;
begin
  PLekcja(Rec)^.SetNauczycielIndex(FNauczycielIndex);
  PLekcja(Rec)^.SetPrzedmiotIndex(FPrzedmiotIndex);
  PLekcja(Rec)^.SetSalaIndex(FSalaIndex);
  PLekcja(Rec)^.SetKlasaIndex(FKlasaIndex);
  FGrupyCheckBoxes^.GetData(Grupy);
  PLekcja(Rec)^.SetGrupy(Grupy);
end;

procedure TLekcjaDialog.SetData(var Rec);
var Grupy: Word;
begin
  PLekcja(Rec)^.GetNauczycielIndex(FNauczycielIndex); UpdateNauczyciel;
  PLekcja(Rec)^.GetPrzedmiotIndex(FPrzedmiotIndex); UpdatePrzedmiot;
  PLekcja(Rec)^.GetSalaIndex(FSalaIndex); UpdateSala;
  PLekcja(Rec)^.GetKlasaIndex(FKlasaIndex);
  PLekcja(Rec)^.GetGrupy(Grupy);
  FGrupyCheckBoxes^.SetData(Grupy); UpdateKlasa;
end;

procedure TLekcjaDialog.Store(var S: TStream);
begin
  inherited Store(S);
  PutSubViewPtr(S, FNauczycielStaticText);
  PutSubViewPtr(S, FPrzedmiotStaticText);
  PutSubViewPtr(S, FSalaStaticText);
  PutSubViewPtr(S, FKlasaStaticText);
  PutSubViewPtr(S, FGrupyCheckBoxes);
  PutSubViewPtr(S, FNauczycielLabel);
  PutSubViewPtr(S, FPrzedmiotLabel);
  PutSubViewPtr(S, FSalaLabel);
  PutSubViewPtr(S, FKlasaLabel);
  PutSubViewPtr(S, FGrupyLabel);
end;

function EditLekcja;
var
  Dialog: PLekcjaDialog;
  DataCreated: Boolean;
begin
  if ALekcja=nil then
  begin
    New(ALekcja, Init);
    DataCreated:=True;
  end
  else DataCreated:=False;

  New(Dialog, Init(ATitle));
  if DisNauczyciel then with Dialog^ do
  begin
    with FNauczycielStaticText^ do Options:=Options and (not ofSelectable);
    SelectNext(False);
  end;
  if DisKlasa then with Dialog^ do
  begin
    with FKlasaStaticText^ do Options:=Options and (not ofSelectable);
    with FGrupyCheckBoxes^ do Options:=Options and (not ofSelectable);
  end;

  Inc(Dialog^.HelpCtx, AddIndex);
  if Application^.ExecuteDialog(Dialog, @ALekcja)<>cmCancel then
  begin
    EditLekcja:=True;
  end
  else
  begin
    if DataCreated then
    begin
      ALekcja^.Free;
      ALekcja:=nil;
    end;
    EditLekcja:=False;
  end;
end;

procedure RegisterLekcja;
begin
  RegisterType(RLekcja);
  RegisterType(RLekcjaDialog);
end;

begin
  RegisterLekcja;
end.
