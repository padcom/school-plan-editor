Unit DataDialogs;

interface
uses
  Objects, Drivers, Views, Dialogs, StdDlg,
  DataObjects, Stale;

type { typ opisuj¥cy bazowe okienko edycji danych }
  PDataDialog = ^TDataDialog;
  TDataDialog = object (TDialog)
    OkButton: PButton;
    CancelButton: PButton;
    HelpButton: PButton;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SetTitle(ATitle: TTitleStr); virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj¥cy ListBox danych }
  PDataListBox = ^TDataListBox;
  TDataListBox = object (TListBox)
    QuickSearchLine: PInputLine;
    SearchText: String;
    constructor Init(var Bounds: TRect; ANumCols: Word; AScrollBar: PScrollBar; AQuickSearchLine: PInputLine);
    constructor Load(var S: TStream);
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure DoSearch; virtual;
    procedure SetQuickText;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SetNumCols(NewNumCols: Integer); virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj¥cy okno wyboru danych z listy }
  PChooseDataDialog = ^TChooseDataDialog;
  TChooseDataDialog = object (TDataDialog)
    ScrollBar: PScrollBar;
    DataListBox: PDataListBox;
    DataLabel: PLabel;
    QuickSearchLine: PInputLine;
    QuickSearchLabel: PLabel;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream); virtual;
  end;

type { typ opisuj¥cy StaticText reaguj¥cy na dwuklik }
  PActiveText = ^TActiveText;
  TActiveText = object (TStaticText)
    constructor Init(var Bounds: TRect; AText: String);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SetText(NewText: String); virtual;
  end;

const
  RDataDialog: TStreamRec = (
    ObjType: $1100;
    VmtLink: Ofs(TypeOf(TDataDialog)^);
    Load   : @TDataDialog.Load;
    Store  : @TDataDialog.Store);
  RDataListBox: TStreamRec = (
    ObjType: $1101;
    VmtLink: Ofs(TypeOf(TDataListBox)^);
    Load   : @TDataListBox.Load;
    Store  : @TDataListBox.Store);
  RChooseDataDialog: TStreamRec = (
    ObjType: $1102;
    VmtLink: Ofs(TypeOf(TChooseDataDialog)^);
    Load   : @TChooseDataDialog.Load;
    Store  : @TChooseDataDialog.Store);
  RActiveText: TStreamRec = (
    ObjType: $1103;
    VmtLink: Ofs(TypeOf(TActiveText)^);
    Load   : @TActiveText.Load;
    Store  : @TActiveText.Store);

procedure RegisterDataDialogs;

implementation
uses
  Latin2;

{ TDataDialog }

constructor TDataDialog.Load;
begin
  inherited Load(S);
  GetSubViewPtr(S, OkButton);
  GetSubViewPtr(S, CancelButton);
  GetSubViewPtr(S, HelpButton);
end;

procedure TDataDialog.HandleEvent;
begin
  if Event.What=evKeyboard then
  begin
    case Event.KeyCode of
      kbEnter: if (Current<>PView(OkButton)) and (Current<>PView(CancelButton)) and (Current<>PView(OkButton)) then
      begin
        SelectNext(False);
        ClearEvent(Event);
      end;
      kbUp: SelectNext(True);
      kbDown: SelectNext(False);
    end;
  end;
  inherited HandleEvent(Event);
end;

procedure TDataDialog.SetTitle;
begin
  if Assigned(Title) then DisposeStr(Title);
  Title:=Nil;
  Title:=NewStr(ATitle);
end;

procedure TDataDialog.Store;
begin
  inherited Store(S);
  PutSubViewPtr(S, OkButton);
  PutSubViewPtr(S, CancelButton);
  PutSubViewPtr(S, HelpButton);
end;

{ TDataListBox }

constructor TDataListBox.Init;
begin
  inherited Init(Bounds, ANumCols, AScrollBar);
  QuickSearchLine:=AQuickSearchLine;
  SearchText:='';
end;

constructor TDataListBox.Load;
begin
  inherited Load(S);
  GetPeerViewPtr(S, QuickSearchLine);
  SearchText:='';
end;

function TDataListBox.GetText;
begin
  GetText:=PDataObject(List^.At(Item))^.GetText(MaxLen);
end;

procedure TDataListBox.DoSearch;
var
  I: Integer;
  Data: PDataObject;
  S: String;
begin
  if not Assigned(List) then SearchText:=''
  else
  begin
    I:=0;
    while I<List^.Count do
    begin
      Data:=List^.At(I);
      S:=Data^.GetText(Length(SearchText));
      if CompareStr(S, SearchText, False)=0 then
      begin
        SearchText:=S;
        FocusItem(I);
        Exit;
      end;
      Inc(I);
    end;
    SearchText:=Copy(SearchText, 1, Length(SearchText)-1);
  end;
end;

procedure TDataListBox.SetQuickText;
begin
  if Assigned(QuickSearchLine) then with QuickSearchLine^ do
  begin
    SetData(SearchText);
    Draw;
  end;
end;

procedure TDataListBox.HandleEvent;

begin
  if Event.What=evKeyDown then
  begin
    case Event.CharCode of
      'A'..'Z', 'a'..'z', ' ', '.', '-':
      begin
        SearchText:=SearchText+Event.CharCode;
        DoSearch;
        SetQuickText;
        ClearEvent(Event);
      end;
    end;
    case Event.KeyCode of
      kbUp, kbDown, kbLeft, kbRight, kbPgUp, kbPgDn, kbHome, kbEnd:
      begin
        SearchText:='';
        SetQuickText;
      end;
      kbBack:
      begin
        SearchText:=Copy(SearchText, 1, Length(SearchText)-1);
        DoSearch;
        SetQuickText;
        ClearEvent(Event);
      end;
    end;
  end;
  inherited HandleEvent(Event);
end;

procedure TDataListBox.SetNumCols;
begin
  NumCols:=NewNumCols;
  Draw;
end;

procedure TDataListBox.Store;
begin
  inherited Store(S);
  PutPeerViewPtr(S, QuickSearchLine);
end;

{ TChooseDataDialog }

constructor TChooseDataDialog.Load;
begin
  inherited Load(S);
  GetSubViewPtr(S, DataListBox);
  GetSubViewPtr(S, DataLabel);
  GetSubViewPtr(S, QuickSearchLine);
  GetSubViewPtr(S, QuickSearchLabel);
end;

procedure TChooseDataDialog.HandleEvent;
begin
  TDialog.HandleEvent(Event);
end;

procedure TChooseDataDialog.GetData;
begin
  DataListBox^.GetData(Rec);
end;

procedure TChooseDataDialog.SetData;
begin
  DataListBox^.SetData(Rec);
end;

procedure TChooseDataDialog.Store;
begin
  inherited Store(S);
  PutSubViewPtr(S, DataListBox);
  PutSubViewPtr(S, DataLabel);
  PutSubViewPtr(S, QuickSearchLine);
  PutSubViewPtr(S, QuickSearchLabel);
end;

{ TActiveText }

constructor TActiveText.Init;
begin
  inherited Init(Bounds, AText);
  Options:=Options or ofSelectable;
  SetState(sfCursorVis, True);
end;

procedure TActiveText.HandleEvent;
begin
  inherited HandleEvent(Event);
  if ((Event.What=evMouseDown) and Event.Double) or
     ((Event.What=evKeyboard) and (Event.KeyCode=kbF2)) then
  begin
    Message(Owner, evCommand, cmClickActiveText, @Self);
  end;
end;

procedure TActiveText.SetText;
begin
  if Assigned(Text) then DisposeStr(Text);
  Text:=nil;
  if NewText<>'' then Text:=NewStr(NewText);
  Draw;
end;

{ *** }

procedure RegisterDataDialogs;
begin
  RegisterType(RDataDialog);
  RegisterType(RDataListBox);
  RegisterType(RChooseDataDialog);
  RegisterType(RActiveText);
end;

begin
end.
