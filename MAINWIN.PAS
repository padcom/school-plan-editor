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
  end;

type { typ opisuj¥cy widok listy dzwonk¢w }
  PDzwonekListView = ^TDzwonekListView;
  TDzwonekListView = object (TDataListBox)
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

type { typ opisuj¥cy widok listy lekcji }
  PLekcjaListView = ^TLekcjaListView;
  TLekcjaListView = object (TListBox)
    function GetPalette: PPalette; virtual;
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

type { typ opisuj¥cy widok detali lekcji }
  PLekcjaDetailView = ^TLekcjaDetailView;
  TLekcjaDetailView = object (TView)

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
    procedure HandleEvent(var Event: TEvent); virtual;
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

{ THighlightedLabel }

function THighlightedLabel.GetPalette;
var
  S: PPalette;
begin
  S:=inherited GetPalette;
  S^[1]:=#2; S^[3]:=#3;
  S^[2]:=#5; S^[4]:=#5;
  GetPalette:=S;
end;

{ TDzienTygodniaListView }

function TDzienTygodniaListView.GetPalette;
var
  S: PPalette;
begin
  S:=inherited GetPalette;
  S^[1]:=#2; S^[3]:=#5;
  S^[2]:=#2; S^[4]:=#5;
  GetPalette:=S;
end;

{ TDzwonekListView }

function TDzwonekListView.GetPalette;
var
  S: PPalette;
begin
  S:=inherited GetPalette;
  S^[1]:=#2; S^[3]:=#5;
  S^[2]:=#2; S^[4]:=#5;
  GetPalette:=S;
end;

procedure TDzwonekListView.HandleEvent;
var
  L: PCollection;
begin
  if (Event.What=evBroadcast) and (Event.Command=cmUpdateLists) then
  begin
    L:=List;
    List:=nil;
    NewList(L);
  end;
  inherited HandleEvent(Event);
end;

{ TLekcjaListView }

function TLekcjaListView.GetPalette;
var
  S: PPalette;
begin
  S:=inherited GetPalette;
  S^[1]:=#2; S^[3]:=#5;
  S^[2]:=#2; S^[4]:=#5;
  GetPalette:=S;
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
begin
  Color1:=GetColor(2);
  Color2:=GetColor(2);
  C:='³';
  for Y:=0 to Size.Y-1 do
  begin

    MoveChar(Buf, ' ', Color1, Size.X);
{
    if TopItem+Y=Focused then Color:=2 else Color:=0;

    L:=List^.At(Y+TopItem);
    if not Assigned(Nauczyciele) then N:=nil
    else
    begin
      N:=PNauczyciel(Nauczyciele^.ItemByIndex(L^.NauczycielIndex));
      if not Assigned(N) then St:='BRAK!'
      else if not Assigned(N^.Skrot) then St:='BRAK!'
      else St:=N^.Skrot^;
    end;
    while Length(St)<5 do St:=St+' ';

    WriteStr(0, 0, St, Color);
}
    { narysowanie ramek rozdzielaj¥cych poszczeg¢lne elementy listy }
    MoveChar(Buf[8], C, Color2, 1);
    MoveChar(Buf[20], C, Color2, 1);
    MoveChar(Buf[28], C, Color2, 1);
    MoveChar(Buf[39], C, Color2, 1);
    WriteLine(0, Y, Size.X, 1, Buf);
  end;
end;

{ TLekcjaDetailView }

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
  end;
  inherited HandleEvent(Event);
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
