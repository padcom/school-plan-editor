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
function KlasaAdd: Boolean;
function KlasaDel: Boolean;
function KlasaEdit: Boolean;
function DzwonekAdd: Boolean;
function DzwonekDel: Boolean;
function DzwonekEdit: Boolean;

function ChooseNauczyciel(List: PDataCollection): PNauczyciel;
function ChoosePrzedmiot(List: PDataCollection): PPrzedmiot;
function ChooseSala(List: PDataCollection): PSala;
function ChooseKlasa(List: PDataCollection): PKlasa;
function ChooseDzwonek(List: PDataCollection): PDzwonek;

function LekcjaDel(List: PDataCollection; Data: PLekcja): Boolean;
function LekcjaEdit(var Data: PLekcja): Boolean;

procedure OpenFiles(Dir: String);
procedure UpdateFiles;
procedure CloseFiles;

implementation

function NauczycielAdd;
var
  Data: PNauczyciel;
  Dialog: PDataDialog;
  I: Integer;
begin
  New(Data, Init);
  Dialog:=PDataDialog(ResourceFile.Get('NauczycielEditDialog'));
  Dialog^.SetTitle('Dodawanie nowego nauczyciela');
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
  Dialog^.SetTitle('Poprawianie wpisu nauczyciela');
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
  Dialog^.SetTitle('Dodawanie nowego przedmiotu');
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
  Dialog^.SetTitle('Poprawianie wpisu przedmiotu');
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
  Dialog^.SetTitle('Dodawanie nowej sali');
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
  Dialog^.SetTitle('Poprawianie wpisu sali');
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

function KlasaAdd;
var
  Data: PKlasa;
  Dialog: PDataDialog;
  I: Integer;
begin
  New(Data, Init);
  Data^.Numer:=1;
  Data^.Litera:='A';
  Data^.IloscGrup:=1;
  Dialog:=PDataDialog(ResourceFile.Get('KlasaEditDialog'));
  Dialog^.SetTitle('Dodawanie nowej klasy');
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Data)=cmOK) then
  begin
    if Klasy^.Search(Data, I) then
    begin
      MessageBox(#3'Taka klasa ju¾ istnieje !', nil, mfError or mfCancelButton);
      KlasaAdd:=False;
    end
    else
    begin
      Klasy^.Insert(Data);
      KlasaAdd:=True;
    end;
  end
  else
  begin
    Dispose(Data, Done);
    KlasaAdd:=False;
  end;
end;

function KlasaDel;
var
  Data: PDataObject;
  I: Integer;

procedure UsunKlaseZLekcji(Item: Pointer); far;
begin
  if PLekcja(Item)^.SalaIndex=Data^.Index then
  begin
    PLekcja(Item)^.KlasaIndex:=-1;
    PLekcja(Item)^.Grupy:=0;
  end;
end;

begin
  Data:=ChooseKlasa(Klasy);
  if Assigned(Data) then
  begin
    if MessageBox(#3'Czy na pewno chcesz usun¥† t¥ klas© ?',nil,mfConfirmation or mfYesButton or mfNoButton)=cmYes then
    begin
      for I:=1 to IloscDni do if Assigned(Lekcje[I]) then Lekcje[I]^.ForEach(@UsunKlaseZLekcji);
      Klasy^.Free(Data);
      KlasaDel:=True;
    end;
    KlasaDel:=False;
  end;
end;

function KlasaEdit;
var
  Data, Temp: PKlasa;
  Dialog: PDataDialog;
  I: Integer;

procedure UaktualnijKlaseNaPlanieZajec(Item: Pointer); far;
var
  Mask, I: Word;
begin
  for I:=1 to Data^.IloscGrup do I:=I shl 1;
  if PLekcja(Item)^.KlasaIndex=Data^.Index then PLekcja(Item)^.Grupy:=PLekcja(Item)^.Grupy and Mask;
end;

begin
  Data:=ChooseKlasa(Klasy);
  if not Assigned(Data) then Exit;

  New(Temp, Init);
  Temp^.Assign(Data);
  Klasy^.Delete(Data);

  Dialog:=PDataDialog(ResourceFile.Get('KlasaEditDialog'));
  Dialog^.SetTitle('Poprawianie wpisu klasy');
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Temp)=cmOK) then
  begin
    if Klasy^.Search(Temp, I) then
    begin
      MessageBox(#3'Taka klasa ju¾ istnieje !', nil, mfError or mfCancelButton);
      Klasy^.Insert(Data);
      KlasaEdit:=False;
    end
    else
    begin
      for I:=1 to IloscDni do if Assigned(Lekcje[I]) then Lekcje[I]^.ForEach(@UaktualnijKlaseNaPlanieZajec);
      Data^.Assign(Temp);
      Klasy^.Insert(Data);
      KlasaEdit:=True;
    end;
  end
  else
  begin
    Klasy^.Insert(Data);
    KlasaEdit:=False;
  end;
  Dispose(Temp, Done);
end;

function DzwonekAdd;
var
  Data: PDzwonek;
  Dialog: PDataDialog;
  I: Integer;
begin
  New(Data, Init);
  Dialog:=PDataDialog(ResourceFile.Get('DzwonekEditDialog'));
  Dialog^.SetTitle('Dodawanie nowego dzwonka');
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Data)=cmOK) then
  begin
    if Dzwonki^.Search(Data, I) then
    begin
      MessageBox(#3'Taki dzwonek ju¾ istnieje !', nil, mfError or mfCancelButton);
      DzwonekAdd:=False;
    end
    else
    begin
      Dzwonki^.Insert(Data);
      DzwonekAdd:=True;
    end;
  end
  else
  begin
    Dispose(Data, Done);
    DzwonekAdd:=False;
  end;
end;

function DzwonekDel;
var
  Data: PDataObject;
  I: Integer;

procedure UsunDzwonekZLekcji(Item: Pointer); far;
begin
  if PLekcja(Item)^.DzwonekIndex=Data^.Index then
  begin
    Dispose(PLekcja(Item), Done);
  end;
end;

begin
  Data:=ChooseDzwonek(Dzwonki);
  if Assigned(Data) then
  begin
    if MessageBox(#3'Czy na pewno chcesz usun¥† ten dzwonek ?',nil,mfConfirmation or mfYesButton or mfNoButton)=cmYes then
    begin
      for I:=1 to IloscDni do if Assigned(Lekcje[I]) then Lekcje[I]^.ForEach(@UsunDzwonekZLekcji);
      Dzwonki^.Free(Data);
      DzwonekDel:=True;
    end;
    DzwonekDel:=False;
  end;
end;

function DzwonekEdit;
var
  Data, Temp: PDzwonek;
  Dialog: PDataDialog;
  I: Integer;
begin
  Data:=ChooseDzwonek(Dzwonki);
  if not Assigned(Data) then Exit;

  New(Temp, Init);
  Temp^.Assign(Data);
  Dzwonki^.Delete(Data);

  Dialog:=PDataDialog(ResourceFile.Get('DzwonekEditDialog'));
  Dialog^.SetTitle('Poprawianie wpisu dzwonka');
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Temp)=cmOK) then
  begin
    if Dzwonki^.Search(Temp, I) then
    begin
      MessageBox(#3'Taki dzwonek ju¾ istnieje !', nil, mfError or mfCancelButton);
      Dzwonki^.Insert(Data);
      DzwonekEdit:=False;
    end
    else
    begin
      Data^.Assign(Temp);
      Dzwonki^.Insert(Data);
      DzwonekEdit:=True;
    end;
  end
  else
  begin
    Dzwonki^.Insert(Data);
    DzwonekEdit:=False;
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

function ChooseDzwonek;
begin
  ChooseDzwonek:=PDzwonek(ChooseFromList(List, 'Lista dost©pnych dzwonk¢w jest pusta !', '~L~ista dzwonk¢w'));
end;

function LekcjaDel;
var
  I: Integer;
begin
  LekcjaDel:=False;
  if Assigned(List) and (not List^.Empty) and Assigned(Data) then
    if List^.Search(Data, I) then
      if MessageBox(#3'Czy na pewno chczes usun¥† t¥ lekcj© ?',nil,mfconfirmation or mfYesButton or mfCancelButton)=cmYes then
      begin
        List^.Delete(Data);
        LekcjaDel:=True;
      end;
end;

function LekcjaEdit;
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
    if Application^.ExecuteDialog(D, Data)=cmOK then LekcjaEdit:=True
    else LekcjaEdit:=False;
  end;
end;

{ *** }

var
  DataDir: String;
  S: TBufStream;
  I: Integer;

procedure OpenFiles(Dir: String);
begin
  DataDir:=Dir;
  {$I-} MkDir(DataDir); {$I-}
  if IOResult<>0 then ;
  if DataDir[Length(Dir)]<>'\' then DataDir:=DataDir+'\';

  S.Init(DataDir+'NAUCZ.DAT', stOpenRead, 1024);
  if S.Status<>stOK then
  begin
    S.Init(DataDir+'NAUCZ.DAT', stCreate, 1024);
    New(Nauczyciele, Init(10, 5));
  end
  else New(Nauczyciele, Load(S));
  S.Done;

  S.Init(DataDir+'PRZEDM.DAT', stOpenRead, 1024);
  if S.Status<>stOK then
  begin
    S.Init(DataDir+'PRZEDM.DAT', stCreate, 1024);
    New(Przedmioty, Init(10, 5));
  end
  else New(Przedmioty, Load(S));
  S.Done;

  S.Init(DataDir+'SALE.DAT', stOpenRead, 1024);
  if S.Status<>stOK then
  begin
    S.Init(DataDir+'SALE.DAT', stCreate, 1024);
    New(Sale, Init(10, 5));
  end
  else New(Sale, Load(S));
  S.Done;

  S.Init(DataDir+'KLASY.DAT', stOpenRead, 1024);
  if S.Status<>stOK then
  begin
    S.Init(DataDir+'KLASY.DAT', stCreate, 1024);
    New(Klasy, Init(10, 5));
  end
  else New(Klasy, Load(S));
  S.Done;

  S.Init(DataDir+'DZWONKI.DAT', stOpenRead, 1024);
  if S.Status<>stOK then
  begin
    S.Init(DataDir+'DZWONKI.DAT', stCreate, 1024);
    New(Dzwonki, Init(10, 5));
  end
  else New(Dzwonki, Load(S));
  S.Done;

  S.Init(DataDir+'LEKCJE.DAT', stOpenRead, 1024);
  if S.Status<>stOK then
  begin
    S.Init(DataDir+'LEKCJE.DAT', stCreate, 1024);
    for I:=1 to IloscDni do New(Lekcje[I], Init(10, 5));
  end
  else for I:=1 to IloscDni do New(Lekcje[I], Load(S));
  S.Done;
end;

procedure UpdateFiles;
begin
  S.Init(DataDir+'NAUCZ.DAT', stOpenWrite, 1024);
  Nauczyciele^.Store(S);
  S.Truncate;
  S.Done;

  S.Init(DataDir+'PRZEDM.DAT', stOpenWrite, 1024);
  Przedmioty^.Store(S);
  S.Truncate;
  S.Done;

  S.Init(DataDir+'KLASY.DAT', stOpenWrite, 1024);
  Klasy^.Store(S);
  S.Truncate;
  S.Done;

  S.Init(DataDir+'SALE.DAT', stOpenWrite, 1024);
  Sale^.Store(S);
  S.Truncate;
  S.Done;

  S.Init(DataDir+'DZWONKI.DAT', stOpenWrite, 1024);
  Dzwonki^.Store(S);
  S.Truncate;
  S.Done;

  S.Init(DataDir+'LEKCJE.DAT', stOpenWrite, 1024);
  for I:=1 to IloscDni do Lekcje[I]^.Store(S);
  S.Truncate;
  S.Done;
end;

procedure CloseFiles;
begin
  UpdateFiles;
  Dispose(Nauczyciele, Done);
  Nauczyciele:=nil;
  Dispose(Przedmioty, Done);
  Przedmioty:=nil;
  Dispose(Klasy, Done);
  Klasy:=nil;
  Dispose(Sale, Done);
  Sale:=nil;
  Dispose(Dzwonki, Done);
  Dzwonki:=nil;
  for I:=1 to 5 do
  begin
    Dispose(Lekcje[I], Done);
    Lekcje[I]:=nil;
  end;
end;


begin
end.
