Unit DataBase;

interface
uses
  App, Objects, Drivers, Views, Dialogs, MsgBox, Resource,
  DataObjects, DataDialogs, Stale,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja;

function NauczycielAdd: Boolean;
function NauczycielDel: Boolean;
function NauczycielEdit: Boolean;

function ChooseNauczyciel(List: PDataCollection): PDataObject;
function ChoosePrzedmiot(List: PDataCollection): PDataObject;
function ChooseSala(List: PDataCollection): PDataObject;
function ChooseKlasa(List: PDataCollection): PDataObject;
function EditLekcja(var Data: PLekcja): Boolean;

implementation

function NauczycielAdd;
var
  Data: PNauczyciel;
  Dialog: PDataDialog;
  I: Integer;
begin
  New(Data, Init);
  Dialog:=PDataDialog(ResourceFile.Get('NauczycielEditDialog'));
  if Application^.ExecuteDialog(Dialog, Data)=cmOK then
  begin
    if Nauczyciele^.Search(Data, I) then
    begin
      MessageBox(#3'Taki nauczyciel ju¾ istnieje !', nil, mfError or mfCancelButton);
      NauczycielAdd:=False;
    end
    else
    begin
      Nauczyciele^.Insert(Data);
      NauczycielAdd:=True;
    end;
  end
  else
  begin
    Dispose(Data, Done);
    NauczycielAdd:=False;
  end;
end;



function NauczycielDel;
var
  Data: PDataObject;
  I, J: Integer;
  L: PLekcja;

procedure UsunNauczycielaZLekcji(Item: Pointer); far;
begin
  if PLekcja(Item)^.NauczycielIndex=Data^.Index then PLekcja(Item)^.NauczycielIndex:=-1;
end;

begin
  Data:=ChooseNauczyciel(Nauczyciele);
  if Assigned(Data) then
  begin
    if MessageBox(#3'Czy na pewno chcesz usun¥† tego nauczyciela ?',nil,mfConfirmation or mfYesButton or mfNoButton)=cmYes then
    begin
      for I:=1 to IloscDni do if Assigned(Lekcje[I]) then Lekcje[I]^.ForEach(@UsunNauczycielaZLekcji);
      Nauczyciele^.Free(Data);
    end;
  end;
end;

function NauczycielEdit;
begin

end;


function ChooseFromList(List: PDataCollection; EmptyListMsg: String; DataListLabel: String): PDataObject;
var
  D: PChooseDataDialog;
  Data: record
    List: PDataCollection;
    Item: Integer;
  end;
begin
  if not Assigned(List) or List^.Empty then
  begin
    MessageBox(#3+EmptyListMsg, nil, mfError or mfCancelButton);
    ChooseFromList:=nil;
  end
  else
  begin
    D:=PChooseDataDialog(ResourceFile.Get('ChooseDataDialog'));
    if LoadSuccessful(D) then
    begin
      with D^.DataLabel^ do
      begin
        if Assigned(Text) then DisposeStr(Text);
        Text:=nil;
        Text:=NewStr(DataListLabel);
      end;
      Data.List:=List;
      Data.Item:=0;
      if Application^.ExecuteDialog(D, @Data)=cmOK then
      begin
        ChooseFromList:=Data.List^.At(Data.Item);
      end
      else ChooseFromList:=nil;
    end;
  end;
end;

function ChooseNauczyciel;
begin
  ChooseNauczyciel:=ChooseFromList(List, 'Lista dost©pnych nauczycieli jest pusta !', '~L~ista nauczycieli');
end;

function ChoosePrzedmiot;
begin
  ChoosePrzedmiot:=ChooseFromList(List, 'Lista dost©pnych przedmiot¢w jest pusta !', '~L~ista przedmiot¢w');
end;

function ChooseSala;
begin
  ChooseSala:=ChooseFromList(List, 'Lista dost©pnych sal jest pusta !', '~L~ista sal');
end;

function ChooseKlasa;
begin
  ChooseKlasa:=ChooseFromList(List, 'Lista dost©pnych klas jest pusta !', '~L~ista klas');
end;

function EditLekcja;
var
  D: PLekcjaDialog;
  DataCreated: Boolean;
begin
  if not Assigned(Data) then
  begin
    New(Data, Init);
    DataCreated:=True;
  end
  else DataCreated:=True;

  D:=PLekcjaDialog(ResourceFile.Get('LekcjaEditDialog'));
  if LoadSuccessful(D) then
  begin
    if Application^.ExecuteDialog(D, Data)=cmOK then EditLekcja:=True
    else EditLekcja:=False;
  end;
end;

begin
end.
