Unit DataBase;

interface
uses
  App, Objects, Drivers, Views, Dialogs, MsgBox, Resource,
  DataObjects, DataDialogs, Stale,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja;

function NauczycielAdd: Boolean;
function NauczycielDel: Boolean;
function NauczycielEdit: Boolean;
function PrzedmiotAdd: Boolean;
function PrzedmiotDel: Boolean;
function PrzedmiotEdit: Boolean;
function SalaAdd: Boolean;
function SalaDel: Boolean;
function SalaEdit: Boolean;

function ChooseNauczyciel(List: PDataCollection): PNauczyciel;
function ChoosePrzedmiot(List: PDataCollection): PPrzedmiot;
function ChooseSala(List: PDataCollection): PSala;
function ChooseKlasa(List: PDataCollection): PKlasa;
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
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Data)=cmOK) then
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
  I: Integer;

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
      NauczycielDel:=True;
    end;
    NauczycielDel:=False;
  end;
end;

function NauczycielEdit;
var
  Data, Temp: PNauczyciel;
  Dialog: PDataDialog;
  I: Integer;
begin
  Data:=ChooseNauczyciel(Nauczyciele);
  if not Assigned(Data) then Exit;

  New(Temp, Init);
  Temp^.Assign(Data);
  Nauczyciele^.Delete(Data);

  Dialog:=PDataDialog(ResourceFile.Get('NauczycielEditDialog'));
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Temp)=cmOK) then
  begin
    if Nauczyciele^.Search(Temp, I) then
    begin
      MessageBox(#3'Taki nauczyciel ju¾ istnieje !', nil, mfError or mfCancelButton);
      Nauczyciele^.Insert(Data);
      NauczycielEdit:=False;
    end
    else
    begin
      Data^.Assign(Temp);
      Nauczyciele^.Insert(Data);
      NauczycielEdit:=True;
    end;
  end
  else
  begin
    Nauczyciele^.Insert(Data);
    NauczycielEdit:=False;
  end;
  Dispose(Temp, Done);
end;

function PrzedmiotAdd;
var
  Data: PPrzedmiot;
  Dialog: PDataDialog;
  I: Integer;
begin
  New(Data, Init);
  Dialog:=PDataDialog(ResourceFile.Get('PrzedmiotEditDialog'));
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Data)=cmOK) then
  begin
    if Przedmioty^.Search(Data, I) then
    begin
      MessageBox(#3'Taki przedmiot ju¾ istnieje !', nil, mfError or mfCancelButton);
      PrzedmiotAdd:=False;
    end
    else
    begin
      Przedmioty^.Insert(Data);
      PrzedmiotAdd:=True;
    end;
  end
  else
  begin
    Dispose(Data, Done);
    PrzedmiotAdd:=False;
  end;
end;

function PrzedmiotDel;
var
  Data: PDataObject;
  I: Integer;

procedure UsunPrzedmiotZLekcji(Item: Pointer); far;
begin
  if PLekcja(Item)^.PrzedmiotIndex=Data^.Index then PLekcja(Item)^.PrzedmiotIndex:=-1;
end;

begin
  Data:=ChoosePrzedmiot(Przedmioty);
  if Assigned(Data) then
  begin
    if MessageBox(#3'Czy na pewno chcesz usun¥† ten przedmiot ?',nil,mfConfirmation or mfYesButton or mfNoButton)=cmYes then
    begin
      for I:=1 to IloscDni do if Assigned(Lekcje[I]) then Lekcje[I]^.ForEach(@UsunPrzedmiotZLekcji);
      Przedmioty^.Free(Data);
      PrzedmiotDel:=True;
    end;
    PrzedmiotDel:=False;
  end;
end;

function PrzedmiotEdit;
var
  Data, Temp: PPrzedmiot;
  Dialog: PDataDialog;
  I: Integer;
begin
  Data:=ChoosePrzedmiot(Przedmioty);
  if not Assigned(Data) then Exit;

  New(Temp, Init);
  Temp^.Assign(Data);
  Przedmioty^.Delete(Data);

  Dialog:=PDataDialog(ResourceFile.Get('PrzedmiotEditDialog'));
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Temp)=cmOK) then
  begin
    if Przedmioty^.Search(Temp, I) then
    begin
      MessageBox(#3'Taki przedmiot ju¾ istnieje !', nil, mfError or mfCancelButton);
      Przedmioty^.Insert(Data);
      PrzedmiotEdit:=False;
    end
    else
    begin
      Data^.Assign(Temp);
      Przedmioty^.Insert(Data);
      PrzedmiotEdit:=True;
    end;
  end
  else
  begin
    Przedmioty^.Insert(Data);
    PrzedmiotEdit:=False;
  end;
  Dispose(Temp, Done);
end;

function SalaAdd;
var
  Data: PSala;
  Dialog: PDataDialog;
  I: Integer;
begin
  New(Data, Init);
  Dialog:=PDataDialog(ResourceFile.Get('SalaEditDialog'));
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Data)=cmOK) then
  begin
    if Sale^.Search(Data, I) then
    begin
      MessageBox(#3'Taka sala ju¾ istnieje !', nil, mfError or mfCancelButton);
      SalaAdd:=False;
    end
    else
    begin
      Sale^.Insert(Data);
      SalaAdd:=True;
    end;
  end
  else
  begin
    Dispose(Data, Done);
    SalaAdd:=False;
  end;
end;

function SalaDel;
var
  Data: PDataObject;
  I: Integer;

procedure UsunSaleZLekcji(Item: Pointer); far;
begin
  if PLekcja(Item)^.SalaIndex=Data^.Index then PLekcja(Item)^.SalaIndex:=-1;
end;

begin
  Data:=ChooseSala(Sale);
  if Assigned(Data) then
  begin
    if MessageBox(#3'Czy na pewno chcesz usun¥† t¥ sal© ?',nil,mfConfirmation or mfYesButton or mfNoButton)=cmYes then
    begin
      for I:=1 to IloscDni do if Assigned(Lekcje[I]) then Lekcje[I]^.ForEach(@UsunSaleZLekcji);
      Sale^.Free(Data);
      SalaDel:=True;
    end;
    SalaDel:=False;
  end;
end;

function SalaEdit;
var
  Data, Temp: PSala;
  Dialog: PDataDialog;
  I: Integer;
begin
  Data:=ChooseSala(Sale);
  if not Assigned(Data) then Exit;

  New(Temp, Init);
  Temp^.Assign(Data);
  Sale^.Delete(Data);

  Dialog:=PDataDialog(ResourceFile.Get('SalaEditDialog'));
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Temp)=cmOK) then
  begin
    if Sale^.Search(Temp, I) then
    begin
      MessageBox(#3'Taka sala ju¾ istnieje !', nil, mfError or mfCancelButton);
      Sale^.Insert(Data);
      SalaEdit:=False;
    end
    else
    begin
      Data^.Assign(Temp);
      Sale^.Insert(Data);
      SalaEdit:=True;
    end;
  end
  else
  begin
    Sale^.Insert(Data);
    SalaEdit:=False;
  end;
  Dispose(Temp, Done);
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
  ChooseNauczyciel:=PNauczyciel(ChooseFromList(List, 'Lista dost©pnych nauczycieli jest pusta !', '~L~ista nauczycieli'));
end;

function ChoosePrzedmiot;
begin
  ChoosePrzedmiot:=PPrzedmiot(ChooseFromList(List, 'Lista dost©pnych przedmiot¢w jest pusta !', '~L~ista przedmiot¢w'));
end;

function ChooseSala;
begin
  ChooseSala:=PSala(ChooseFromList(List, 'Lista dost©pnych sal jest pusta !', '~L~ista sal'));
end;

function ChooseKlasa;
begin
  ChooseKlasa:=PKlasa(ChooseFromList(List, 'Lista dost©pnych klas jest pusta !', '~L~ista klas'));
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
