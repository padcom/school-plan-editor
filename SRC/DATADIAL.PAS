Unit DataDialogs;

interface
uses Objects, Drivers, Views, Dialogs,
     DataObjects;

type { Typ opisuj¥cy ListBox danych }
  PDataListBox = ^TDataListBox;
  TDataListBox = object (TListBox)
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
  end;

type { Typ opisuj¥cy okno edycji danych }
  PDataDialog = ^TDataDialog;
  TDataDialog = object (TDialog)
  private
    FDalejButton: PButton;
    FZaniechajButton: PButton;
    FPomocButton: PButton;
  public
    constructor Init(R: TRect; ATitle: TTitleStr);
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure HideHelpButton;
    procedure ShowHelpButton;
    procedure Store(var S: TStream); virtual;
  end;

type { Typ opisuj¥cy okno wyboru danych z listy }
  PChooseDataDialog = ^TChooseDataDialog;
  TChooseDataDialog = object (TDataDialog)
  private
    FSearchInputLine: PInputLine;
    FDataListBoxScrollBar: PScrollBar;
    FDataListBox: PDataListBox;
    FSearchLabel: PLabel;
    FDataLabel: PLabel;
  public
    constructor Init(ATitle: TTitleStr; SearchLabel, ListLabel: String; AColumns: Integer);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure GetData(var Rec); virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SetData(var Rec); virtual;
    procedure SetList(List: PDataCollection);
    procedure Store(var S: TStream); virtual;
  end;

implementation
uses Latin2, Crt, Help;

  { TDataListBox }

function TDataListBox.GetText(Item: Integer; MaxLen: Integer): String;
begin
  GetText:=PDataObject(List^.At(Item))^.GetText(MaxLen);
end;

  { TDataDialog }

constructor TDataDialog.Init(R: TRect; ATitle: TTitleStr);
begin
  inherited Init(R, ATitle);
  Options:=Options or ofCentered;

  R.Assign(Size.X-16, 3, Size.X-3, 5);
  New(FDalejButton, Init(R, '~D~alej', cmOK, bfDefault));
  Insert(FDalejButton);

  R.Assign(Size.X-16, 5, Size.X-3, 7);
  New(FZaniechajButton, Init(R, '~Z~aniechaj', cmCancel, bfNormal));
  Insert(FZaniechajButton);

  R.Assign(Size.X-16, 7, Size.X-3, 9);
  New(FPomocButton, Init(R, '~P~omoc', cmHelp, bfNormal));
  Insert(FPomocButton);

  HelpCtx:=$1001;
end;

constructor TDataDialog.Load(var S: TStream);
begin
  inherited Load(S);
  GetSubViewPtr(S, FDalejButton);
  GetSubViewPtr(S, FZaniechajButton);
  GetSubViewPtr(S, FPomocButton);
end;

procedure TDataDialog.HandleEvent(var Event: TEvent);
begin
  if Event.What=evKeyboard then
  begin
    if ((Event.KeyCode=kbEnter) or (Event.KeyCode=kbCtrlEnter)) and (
       (Current<>PView(FDalejButton)) and
       (Current<>PView(FZaniechajButton)) and
       (Current<>PView(FPomocButton))) then
    begin
      if Event.KeyCode=kbEnter then SelectNext(False)
      else SelectNext(True);
      ClearEvent(Event);
    end
    else if Event.KeyCode=kbF1 then Message(@Self, evCommand, cmHelp, nil)
    else inherited HandleEvent(Event);
  end
  else if (Event.What=evBroadcast) or (Event.What=evCommand) then
  case Event.Command of
    cmHelp:
    begin
      ShowHelp(GetHelpCtx);
      ClearEvent(Event);
    end;
  end;
  inherited HandleEvent(Event);
end;

procedure TDataDialog.HideHelpButton;
var View: PView;
begin
  View:=Current;
  FPomocButton^.Hide;
  View^.Select;
end;

procedure TDataDialog.ShowHelpButton;
var View: PView;
begin
  View:=Current;
  FPomocButton^.Show;
  View^.Select;
end;

procedure TDataDialog.Store(var S: TStream);
begin
  inherited Store(S);
  PutPeerViewPtr(S, FDalejButton);
  PutPeerViewPtr(S, FZaniechajButton);
  PutPeerViewPtr(S, FPomocButton);
end;



  { TChooseDataDialog }

constructor TChooseDataDialog.Init(ATitle: TTitleStr; SearchLabel, ListLabel: String; AColumns: Integer);
var R: TRect;
begin
  R.Assign(0, 0, 50, 15);
  inherited Init(R, ATitle);
  Options:=Options or ofCentered;

  R.Assign(3, 3, Size.X-18, 4);
  New(FSearchInputLine, Init(R, 255));
  Insert(FSearchInputLine);

  R.Assign(2, 2, Size.X-18, 3);
  New(FSearchLabel, Init(R, SearchLabel, FSearchInputLine));
  Insert(FSearchLabel);

  R.Assign(Size.X-19, 5, Size.X-18, Size.Y-2);
  New(FDataListBoxScrollBar, Init(R));
  Insert(FDataListBoxScrollBar);

  R.Assign(3, 5, Size.X-19, Size.Y-2);
  New(FDataListBox, Init(R, AColumns, FDataListBoxScrollBar));
  Insert(FDataListBox);

  R.Assign(2, 4, Size.X-18, 5);
  New(FDataLabel, Init(R, ListLabel, FDataListBox));
  Insert(FDataLabel);

  FSearchInputLine^.Options:=FSearchInputLine^.Options and (not ofSelectable);

  FDataListBox^.Select;
end;

constructor TChooseDataDialog.Load(var S: TStream);
begin
  inherited Load(S);
  GetPeerViewPtr(S, FSearchInputLine);
  GetPeerViewPtr(S, FDataListBoxScrollBar);
  GetPeerViewPtr(S, FDataListBox);
  GetPeerViewPtr(S, FSearchLabel);
  GetPeerViewPtr(S, FDataLabel);
end;

destructor TChooseDataDialog.Done;
begin
  inherited Done;
end;

procedure TChooseDataDialog.GetData(var Rec);
var
  Data: PDataObject;
  Index: LongInt;
begin
  Data:=FDataListBox^.List^.At(FDataListBox^.Focused);
  Data^.GetIndex(Index);
  Integer(Rec):=Index;
end;

procedure TChooseDataDialog.HandleEvent(var Event: TEvent);
var
  I, T: Integer;
  Data: PDataObject;
  S1, S2: String;
  C: Char;
begin
  if (Event.What=evKeyboard) and (Current=PView(FDataListBox)) and
     (FDataListBox^.List<>nil) and (FDataListBox^.List^.Count>0) then
  begin
    T:=Pos(Event.CharCode, Znaki);
    if (T<>0) or (Event.KeyCode=kbBack) then
    begin
      S1:=FSearchInputLine^.Data^;
      If T<>0 then S1:=S1+Event.CharCode
      else S1:=Copy(S1, 1, Length(S1)-1);

      I:=0;
      while I<FDataListBox^.List^.Count do
      begin
        Data:=FDataListBox^.List^.At(I);
        S2:=Copy(Data^.GetText(255), 1, Length(S1));
        if CompareStr(S1, S2, False)=0 then
        begin
          FDataListBox^.FocusItem(I);
          FSearchInputLine^.Data^:=S2;
          FSearchInputLine^.Draw;
          Break;
        end
        else Inc(I);
      end;
      ClearEvent(Event);
    end
  end;
  if (Event.What=evBroadcast) and (Event.Command=cmScrollBarChanged) then
  begin
    Data:=FDataListBox^.List^.At(FDataListBox^.Focused);
    FSearchInputLine^.Data^:=Data^.GetText(255);
    FSearchInputLine^.Draw;
  end;
  inherited HandleEvent(Event);
end;

procedure TChooseDataDialog.SetData(var Rec);
begin
end;

procedure TChooseDataDialog.SetList(List: PDataCollection);
begin
  if FDataListBox^.List=nil then FDataListBox^.NewList(List);
end;

procedure TChooseDataDialog.Store(var S: TStream);
begin
  inherited Store(S);
  PutPeerViewPtr(S, FSearchInputLine);
  PutPeerViewPtr(S, FDataListBoxScrollBar);
  PutPeerViewPtr(S, FDataListBox);
  PutPeerViewPtr(S, FSearchLabel);
  PutPeerViewPtr(S, FDataLabel);
  PutPeerViewPtr(S, FDalejButton);
  PutPeerViewPtr(S, FZaniechajButton);
  PutPeerViewPtr(S, FPomocButton);
end;


begin

end.
