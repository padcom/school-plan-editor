Unit Lekcja;

interface
uses
  Objects, Drivers, Views, Dialogs, Menus, MsgBox,
  DataObjects, DataDialogs, Stale,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek;

type { typ opisuj¥cy lekcj© }
  PLekcja = ^TLekcja;
  TLekcja = object (TDataObject)
    DzwonekIndex: LongInt;
    NauczycielIndex: LongInt;
    PrzedmiotIndex: LongInt;
    SalaIndex: LongInt;
    KlasaIndex: LongInt;
    Grupy: Word;
    constructor Load(var S: TStream);
    procedure Clear; virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opsiuj¥cy okno edycji lekcji }
  PLekcjaDialog = ^TLekcjaDialog;
  TLekcjaDialog = object (TDataDialog)
    NauczycielActiveText: PActiveText;
    NauczycielLabel     : PLabel;
    PrzedmiotActiveText : PActiveText;
    PrzedmiotLabel      : PLabel;
    SalaActiveText      : PActiveText;
    SalaLabel           : PLabel;
    KlasaActiveText     : PActiveText;
    KlasaLabel          : PLabel;
    GrupyCheckBoxes     : PCheckBoxes;
    GrupyLabel          : PLabel;
    NauczycielIndex,
    PrzedmiotIndex,
    SalaIndex,
    KlasaIndex: LongInt;
    GrupyMask: Word;
    constructor Init(var Bounds: TRect; ATitle: TTitleStr);
    constructor Load(var S: TStream);
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;

    procedure SetTexts;
    procedure ChangeNauczyciel;
    procedure ChangePrzedmiot;
    procedure ChangeSala;
    procedure ChangeKlasa;

    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream); virtual;
  end;

const
  RLekcja: TStreamRec = (
    ObjType: $7000;
    VmtLink: Ofs(TypeOf(TLekcja)^);
    Load   : @TLekcja.Load;
    Store  : @TLekcja.Store);
  RLekcjaDialog: TStreamRec = (
    ObjType: $7001;
    VmtLink: Ofs(TypeOf(TLekcjaDialog)^);
    Load   : @TLekcjaDialog.Load;
    Store  : @TLekcjaDialog.Store);

var
  Lekcje: array[1..IloscDni] of PDataCollection;

procedure RegisterLekcja;

implementation
uses
  DataBase;

{ TLekcja }

constructor TLekcja.Load;
begin
  inherited Load(S);
  S.Read(DzwonekIndex, SizeOf(DzwonekIndex));
  S.Read(NauczycielIndex, SizeOf(NauczycielIndex));
  S.Read(PrzedmiotIndex, SizeOf(PrzedmiotIndex));
  S.Read(SalaIndex, SizeOf(SalaIndex));
  S.Read(KlasaIndex, SizeOf(KlasaIndex));
  S.Read(Grupy, SizeOf(Grupy));
end;

procedure TLekcja.Clear;
begin
  DzwonekIndex:=-1;
  NauczycielIndex:=-1;
  PrzedmiotIndex:=-1;
  SalaIndex:=-1;
  KlasaIndex:=-1;
  Grupy:=0;
end;

procedure TLekcja.Store;
begin
  inherited Store(S);
  S.Write(DzwonekIndex, SizeOf(DzwonekIndex));
  S.Write(NauczycielIndex, SizeOf(NauczycielIndex));
  S.Write(PrzedmiotIndex, SizeOf(PrzedmiotIndex));
  S.Write(SalaIndex, SizeOf(SalaIndex));
  S.Write(KlasaIndex, SizeOf(KlasaIndex));
  S.Write(Grupy, SizeOf(Grupy));
end;

{ TLekcjaDialog }

constructor TLekcjaDialog.Init;
begin
  inherited Init(Bounds, ATitle);
  NauczycielIndex:=-1;
  PrzedmiotIndex:=-1;
  SalaIndex:=-1;
  KlasaIndex:=-1;
  GrupyMask:=0;
end;

constructor TLekcjaDialog.Load;
begin
  inherited Load(S);
  GetSubViewPtr(S, NauczycielActiveText);
  GetSubViewPtr(S, NauczycielLabel);
  GetSubViewPtr(S, PrzedmiotActiveText);
  GetSubViewPtr(S, PrzedmiotLabel);
  GetSubViewPtr(S, SalaActiveText);
  GetSubViewPtr(S, SalaLabel);
  GetSubViewPtr(S, KlasaActiveText);
  GetSubViewPtr(S, KlasaLabel);
  GetSubViewPtr(S, GrupyCheckBoxes);
  GetSubViewPtr(S, GrupyLabel);
  NauczycielIndex:=-1;
  PrzedmiotIndex:=-1;
  SalaIndex:=-1;
  KlasaIndex:=-1;
  GrupyMask:=0;
end;

procedure TLekcjaDialog.GetData;
var
  L: LongInt;
begin
  TLekcja(Rec).NauczycielIndex:=NauczycielIndex;
  TLekcja(Rec).PrzedmiotIndex:=PrzedmiotIndex;
  TLekcja(Rec).KlasaIndex:=KlasaIndex;
  TLekcja(Rec).SalaIndex:=SalaIndex;
  TLekcja(Rec).KlasaIndex:=KlasaIndex;
  L:=0; GrupyCheckBoxes^.GetData(L);
  TLekcja(Rec).Grupy:=L;
end;

procedure TLekcjaDialog.SetData;
var
  L: LongInt;
begin
  NauczycielIndex:=TLekcja(Rec).NauczycielIndex;
  PrzedmiotIndex:=TLekcja(Rec).PrzedmiotIndex;
  KlasaIndex:=TLekcja(Rec).KlasaIndex;
  SalaIndex:=TLekcja(Rec).SalaIndex;
  KlasaIndex:=TLekcja(Rec).KlasaIndex;
  L:=TLekcja(Rec).Grupy;
  GrupyCheckBoxes^.SetData(L);
  SetTexts;
end;

procedure TLekcjaDialog.SetTexts;
var
  Data: PDataObject;
  S: String;
begin
  Data:=nil;
  if Assigned(Nauczyciele) then Data:=Nauczyciele^.ItemByIndex(NauczycielIndex);
  if Assigned(Data) then S:=Data^.GetText(255) else S:='(BRAK)';
  NauczycielActiveText^.SetText(S);

  Data:=nil;
  if Assigned(Przedmioty) then Data:=Przedmioty^.ItemByIndex(PrzedmiotIndex);
  if Assigned(Data) then S:=Data^.GetText(255) else S:='(BRAK)';
  PrzedmiotActiveText^.SetText(S);

  Data:=nil;
  if Assigned(Sale) then Data:=Sale^.ItemByIndex(SalaIndex);
  if Assigned(Data) then S:=Data^.GetText(255) else S:='(BRAK)';
  SalaActiveText^.SetText(S);

  Data:=nil;
  if Assigned(Klasy) then Data:=Klasy^.ItemByIndex(KlasaIndex);
  if Assigned(Data) then S:=Data^.GetText(255) else S:='(BRAK)';
  KlasaActiveText^.SetText(S);
end;

procedure TLekcjaDialog.ChangeNauczyciel;
var
  Data: PDataObject;
begin
  Data:=nil;
  Data:=ChooseNauczyciel(Nauczyciele);
  if Assigned(Data) then NauczycielIndex:=Data^.Index;
  SetTexts;
end;

procedure TLekcjaDialog.ChangePrzedmiot;
var
  Data: PDataObject;
begin
  Data:=nil;
  Data:=ChoosePrzedmiot(Przedmioty);
  if Assigned(Data) then PrzedmiotIndex:=Data^.Index;
  SetTexts;
end;

procedure TLekcjaDialog.ChangeSala;
var
  Data: PDataObject;
begin
  Data:=nil;
  Data:=ChooseSala(Sale);
  if Assigned(Data) then SalaIndex:=Data^.Index;
  SetTexts;
end;

procedure TLekcjaDialog.ChangeKlasa;
var
  Data: PDataObject;
begin
  Data:=nil;
  Data:=ChooseKlasa(Klasy, False);
  if Assigned(Data) then KlasaIndex:=Data^.Index;
  SetTexts;
end;

procedure TLekcjaDialog.HandleEvent;
begin
  if Event.What=evKeyboard then
  case Event.KeyCode of
    kbUp:
    begin
      SelectNext(True);
      ClearEvent(Event);
    end;
    kbDown:
    begin
      SelectNext(False);
      ClearEvent(Event);
    end;
    kbEnter: if (Current<>PView(OkButton)) and (Current<>PView(CancelButton)) and (Current<>PView(HelpButton)) then
    begin
      Message(Current, evKeyboard, kbF2, nil);
      ClearEvent(Event);
    end;
  end;

  TDialog.HandleEvent(Event);

  if Event.What=evCommand then
  case Event.Command of
    cmClickActiveText:
    begin
      if Current=PView(NauczycielActiveText) then ChangeNauczyciel
      else if Current=PView(PrzedmiotActiveText) then ChangePrzedmiot
      else if Current=PView(SalaActiveText) then ChangeSala
      else if Current=PView(KlasaActiveText) then ChangeKlasa
    end;
  end;
end;

procedure TLekcjaDialog.Store;
begin
  inherited Store(S);
  PutSubViewPtr(S, NauczycielActiveText);
  PutSubViewPtr(S, NauczycielLabel);
  PutSubViewPtr(S, PrzedmiotActiveText);
  PutSubViewPtr(S, PrzedmiotLabel);
  PutSubViewPtr(S, SalaActiveText);
  PutSubViewPtr(S, SalaLabel);
  PutSubViewPtr(S, KlasaActiveText);
  PutSubViewPtr(S, KlasaLabel);
  PutSubViewPtr(S, GrupyCheckBoxes);
  PutSubViewPtr(S, GrupyLabel);
end;

{ *** }

procedure RegisterLekcja;
begin
  RegisterType(RLekcja);
  RegisterType(RLekcjaDialog);
end;

var
  I: Integer;
begin
  for I:=1 to IloscDni do Lekcje[I]:=nil;
end.
