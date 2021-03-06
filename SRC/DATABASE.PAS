Unit DataBase;

interface
uses
  App, Objects, Drivers, Views, Dialogs, MsgBox, Resource,
  DataObjects, DataDialogs, Stale,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja,
  {MainWin,} Filtr;

function NauczycielAdd: Boolean;
function NauczycielDel: Boolean;
function NauczycielEdit: Boolean;
function NauczycielDelAll: Boolean;
function PrzedmiotAdd: Boolean;
function PrzedmiotDel: Boolean;
function PrzedmiotEdit: Boolean;
function PrzedmiotDelAll: Boolean;
function SalaAdd: Boolean;
function SalaDel: Boolean;
function SalaEdit: Boolean;
function SalaDelAll: Boolean;
function KlasaAdd: Boolean;
function KlasaDel: Boolean;
function KlasaEdit: Boolean;
function KlasaDelAll: Boolean;
function DzwonekAdd: Boolean;
function DzwonekDel: Boolean;
function DzwonekEdit: Boolean;
function DzwonekDelAll: Boolean;

function ChooseNauczyciel(List: PDataCollection): PNauczyciel;
function ChoosePrzedmiot(List: PDataCollection): PPrzedmiot;
function ChooseSala(List: PDataCollection): PSala;
function ChooseKlasa(List: PDataCollection; ChooseGroup: Boolean): PKlasa;
function ChooseDzwonek(List: PDataCollection): PDzwonek;

function DelLekcja(List: PDataCollection; Data: PLekcja): Boolean;
function EditLekcja(var Data: PLekcja; ATitle: TTitleStr; HelpCtx: Word): Boolean;

procedure LekcjaAdd(Dzien: Integer; DzwonekIndex: LongInt);
procedure LekcjaDel(Dzien: Integer; Data: PLekcja);
procedure LekcjaEdit(Dzien: Integer; DzwonekIndex: LongInt; Data: PLekcja);
procedure LekcjaDelAll;

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
  Dialog^.HelpCtx:=hcNauczycielDialogNew;
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Data)=cmOK) then
  begin
    if Nauczyciele^.Search(Data, I) then
    begin
      MessageBox(#3'Taki nauczyciel ju� istnieje !', nil, mfError or mfCancelButton);
      NauczycielAdd:=False;
    end
    else
    begin
      Data^.Index:=Nauczyciele^.GetFirstFreeIndex;
      Nauczyciele^.Insert(Data);
      Message(Desktop, evBroadcast, cmDataBaseChanged, nil);
      UpdateFiles;
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
    if MessageBox(#3'Czy na pewno chcesz usun�� tego nauczyciela ?',nil,mfConfirmation or mfYesButton or mfNoButton)=cmYes then
    begin
      for I:=1 to IloscDni do if Assigned(Lekcje[I]) then Lekcje[I]^.ForEach(@UsunNauczycielaZLekcji);
      Nauczyciele^.Free(Data);
      Message(Desktop, evBroadcast, cmDataBaseChanged, nil);
      UpdateFiles;
      NauczycielDel:=True;
    end
    else NauczycielDel:=False;
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
  Dialog^.HelpCtx:=hcNauczycielDialogEdit;
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Temp)=cmOK) then
  begin
    if Nauczyciele^.Search(Temp, I) then
    begin
      MessageBox(#3'Taki nauczyciel ju� istnieje !', nil, mfError or mfCancelButton);
      Nauczyciele^.Insert(Data);
      NauczycielEdit:=False;
    end
    else
    begin
      Data^.Assign(Temp);
      Nauczyciele^.Insert(Data);
      Message(Desktop, evBroadcast, cmDataBaseChanged, nil);
      UpdateFiles;
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

function NauczycielDelAll;
var
  I, J: Integer;
  Data: PDataObject;

procedure UsunNauczycielaZLekcji(Item: Pointer); far;
begin
  if PLekcja(Item)^.NauczycielIndex=Data^.Index then PLekcja(Item)^.NauczycielIndex:=-1;
end;

begin
  if not Assigned(Nauczyciele) or Nauczyciele^.Empty then
  begin
    MessageBox(#3'Lista nauczycieli jest pusta', nil, mfError or mfCancelButton);
    Exit;
  end;
  if MessageBox(#3'Czy jeste� pewien, �e chcesz usun�� WSZYSTKICH nauczycieli ?',
                   nil, mfConfirmation or mfYesButton or mfNoButton)=cmYes then
  begin
    J:=0;
    while J<Nauczyciele^.Count do
    begin
      Data:=Nauczyciele^.At(J);
      for I:=1 to IloscDni do Lekcje[I]^.ForEach(@UsunNauczycielaZLekcji);
      Nauczyciele^.Free(Data);
    end;
    Message(Desktop, evBroadcast, cmUpdateLists, nil);
    Message(Desktop, evBroadcast, cmListItemChanged, nil);
    Message(Desktop, evBroadcast, cmDataBaseChanged, nil);
    UpdateFiles;
  end;
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
  Dialog^.HelpCtx:=hcPrzedmiotDialogNew;
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Data)=cmOK) then
  begin
    if Przedmioty^.Search(Data, I) then
    begin
      MessageBox(#3'Taki przedmiot ju� istnieje !', nil, mfError or mfCancelButton);
      PrzedmiotAdd:=False;
    end
    else
    begin
      Data^.Index:=Przedmioty^.GetFirstFreeIndex;
      Przedmioty^.Insert(Data);
      Message(Desktop^.Current, evBroadcast, cmDataBaseChanged, nil);
      UpdateFiles;
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
    if MessageBox(#3'Czy na pewno chcesz usun�� ten przedmiot ?',nil,mfConfirmation or mfYesButton or mfNoButton)=cmYes then
    begin
      for I:=1 to IloscDni do if Assigned(Lekcje[I]) then Lekcje[I]^.ForEach(@UsunPrzedmiotZLekcji);
      Przedmioty^.Free(Data);
      Message(Desktop^.Current, evBroadcast, cmDataBaseChanged, nil);
      UpdateFiles;
      PrzedmiotDel:=True;
    end
    else PrzedmiotDel:=False;
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
  Dialog^.HelpCtx:=hcPrzedmiotDialogEdit;
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Temp)=cmOK) then
  begin
    if Przedmioty^.Search(Temp, I) then
    begin
      MessageBox(#3'Taki przedmiot ju� istnieje !', nil, mfError or mfCancelButton);
      Przedmioty^.Insert(Data);
      PrzedmiotEdit:=False;
    end
    else
    begin
      Data^.Assign(Temp);
      Przedmioty^.Insert(Data);
      Message(Desktop^.Current, evBroadcast, cmDataBaseChanged, nil);
      UpdateFiles;
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

function PrzedmiotDelAll;
var
  I, J: Integer;
  Data: PDataObject;

procedure UsunPrzedmiotZLekcji(Item: Pointer); far;
begin
  if PLekcja(Item)^.PrzedmiotIndex=Data^.Index then PLekcja(Item)^.PrzedmiotIndex:=-1;
end;

begin
  if not Assigned(Przedmioty) or Przedmioty^.Empty then
  begin
    MessageBox(#3'Lista przedmiot�w jest pusta', nil, mfError or mfCancelButton);
    Exit;
  end;
  if MessageBox(#3'Czy jeste� pewien, �e chcesz usun�� WSZYSTKIE przedmioty ?',
                   nil, mfConfirmation or mfYesButton or mfNoButton)=cmYes then
  begin
    J:=0;
    while J<Przedmioty^.Count do
    begin
      Data:=Przedmioty^.At(J);
      for I:=1 to IloscDni do Lekcje[I]^.ForEach(@UsunPrzedmiotZLekcji);
      Przedmioty^.Free(Data);
    end;
    Message(Desktop, evBroadcast, cmUpdateLists, nil);
    Message(Desktop, evBroadcast, cmListItemChanged, nil);
    Message(Desktop, evBroadcast, cmDataBaseChanged, nil);
    UpdateFiles;
  end;
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
  Dialog^.HelpCtx:=hcSalaDialogNew;
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Data)=cmOK) then
  begin
    if Sale^.Search(Data, I) then
    begin
      MessageBox(#3'Taka sala ju� istnieje !', nil, mfError or mfCancelButton);
      SalaAdd:=False;
    end
    else
    begin
      Data^.Index:=Sale^.GetFirstFreeIndex;
      Sale^.Insert(Data);
      Message(Desktop^.Current, evBroadcast, cmDataBaseChanged, nil);
      UpdateFiles;
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
    if MessageBox(#3'Czy na pewno chcesz usun�� t� sal� ?',nil,mfConfirmation or mfYesButton or mfNoButton)=cmYes then
    begin
      for I:=1 to IloscDni do if Assigned(Lekcje[I]) then Lekcje[I]^.ForEach(@UsunSaleZLekcji);
      Sale^.Free(Data);
      Message(Desktop^.Current, evBroadcast, cmDataBaseChanged, nil);
      UpdateFiles;
      SalaDel:=True;
    end
    else SalaDel:=False;
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
  Dialog^.HelpCtx:=hcSalaDialogEdit;
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Temp)=cmOK) then
  begin
    if Sale^.Search(Temp, I) then
    begin
      MessageBox(#3'Taka sala ju� istnieje !', nil, mfError or mfCancelButton);
      Sale^.Insert(Data);
      SalaEdit:=False;
    end
    else
    begin
      Data^.Assign(Temp);
      Sale^.Insert(Data);
      Message(Desktop^.Current, evBroadcast, cmDataBaseChanged, nil);
      UpdateFiles;
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

function SalaDelAll;
var
  I, J: Integer;
  Data: PDataObject;

procedure UsunSaleZLekcji(Item: Pointer); far;
begin
  if PLekcja(Item)^.SalaIndex=Data^.Index then PLekcja(Item)^.SalaIndex:=-1;
end;

begin
  if not Assigned(Sale) or Sale^.Empty then
  begin
    MessageBox(#3'Lista sal jest pusta', nil, mfError or mfCancelButton);
    Exit;
  end;
  if MessageBox(#3'Czy jeste� pewien, �e chcesz usun�� WSZYSTKIE sale ?',
                   nil, mfConfirmation or mfYesButton or mfNoButton)=cmYes then
  begin
    J:=0;
    while J<Sale^.Count do
    begin
      Data:=Sale^.At(J);
      for I:=1 to IloscDni do Lekcje[I]^.ForEach(@UsunSaleZLekcji);
      Sale^.Free(Data);
    end;
    Message(Desktop, evBroadcast, cmUpdateLists, nil);
    Message(Desktop, evBroadcast, cmListItemChanged, nil);
    Message(Desktop, evBroadcast, cmDataBaseChanged, nil);
    UpdateFiles;
  end;
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
  Dialog^.HelpCtx:=hcKlasaDialogNew;
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Data)=cmOK) then
  begin
    if Klasy^.Search(Data, I) then
    begin
      MessageBox(#3'Taka klasa ju� istnieje !', nil, mfError or mfCancelButton);
      KlasaAdd:=False;
    end
    else
    begin
      Data^.Index:=Klasy^.GetFirstFreeIndex;
      Klasy^.Insert(Data);
      Message(Desktop^.Current, evBroadcast, cmDataBaseChanged, nil);
      UpdateFiles;
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
  Data:=ChooseKlasa(Klasy, False);
  if Assigned(Data) then
  begin
    if MessageBox(#3'Czy na pewno chcesz usun�� t� klas� ?',nil,mfConfirmation or mfYesButton or mfNoButton)=cmYes then
    begin
      for I:=1 to IloscDni do if Assigned(Lekcje[I]) then Lekcje[I]^.ForEach(@UsunKlaseZLekcji);
      Klasy^.Free(Data);
      Message(Desktop^.Current, evBroadcast, cmDataBaseChanged, nil);
      UpdateFiles;
      KlasaDel:=True;
    end
    else KlasaDel:=False;
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
  Mask:=0;
  for I:=1 to Data^.IloscGrup do Mask:=Mask shl 1+1;
  if PLekcja(Item)^.KlasaIndex=Data^.Index then
  begin
    PLekcja(Item)^.Grupy:=PLekcja(Item)^.Grupy and Mask;
    if PLekcja(Item)^.Grupy=0 then PLekcja(Item)^.KlasaIndex:=-1;
  end;
end;

begin
  Data:=ChooseKlasa(Klasy, False);
  if not Assigned(Data) then Exit;

  New(Temp, Init);
  Temp^.Assign(Data);
  Klasy^.Delete(Data);

  Dialog:=PDataDialog(ResourceFile.Get('KlasaEditDialog'));
  Dialog^.SetTitle('Poprawianie wpisu klasy');
  Dialog^.HelpCtx:=hcKlasaDialogEdit;
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Temp)=cmOK) then
  begin
    if Klasy^.Search(Temp, I) then
    begin
      MessageBox(#3'Taka klasa ju� istnieje !', nil, mfError or mfCancelButton);
      Klasy^.Insert(Data);
      KlasaEdit:=False;
    end
    else
    begin
      Data^.Assign(Temp);
      Klasy^.Insert(Data);
      for I:=1 to IloscDni do if Assigned(Lekcje[I]) then Lekcje[I]^.ForEach(@UaktualnijKlaseNaPlanieZajec);
      Message(Desktop, evBroadcast, cmDataBaseChanged, nil);
      Message(Desktop, evBroadcast, cmUpdateLekcjaListView, nil);
      UpdateFiles;
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

function KlasaDelAll;
var
  I, J: Integer;
  Data: PDataObject;

procedure UsunKlaseZLekcji(Item: Pointer); far;
begin
  if PLekcja(Item)^.KlasaIndex=Data^.Index then PLekcja(Item)^.KlasaIndex:=-1;
end;

begin
  if not Assigned(Klasy) or Klasy^.Empty then
  begin
    MessageBox(#3'Lista klas jest pusta', nil, mfError or mfCancelButton);
    Exit;
  end;
  if MessageBox(#3'Czy jeste� pewien, �e chcesz usun�� WSZYSTKIE klasy ?',
                   nil, mfConfirmation or mfYesButton or mfNoButton)=cmYes then
  begin
    J:=0;
    while J<Klasy^.Count do
    begin
      Data:=Klasy^.At(J);
      for I:=1 to IloscDni do Lekcje[I]^.ForEach(@UsunKlaseZLekcji);
      Klasy^.Free(Data);
    end;
    Message(Desktop, evBroadcast, cmUpdateLists, nil);
    Message(Desktop, evBroadcast, cmListItemChanged, nil);
    Message(Desktop, evBroadcast, cmDataBaseChanged, nil);
    UpdateFiles;
  end;
end;

function CheckTime(Data: PDzwonek): Boolean;
var
  Temp: PDzwonek;
  I: Integer;
begin
  CheckTime:=False;
  if Dzwonki^.Count=0 then Exit;
  I:=0;
  while I<Dzwonki^.Count do
  begin
    Temp:=Dzwonki^.At(I);
    if Data^.Poczatek<Temp^.Poczatek then
    begin
      if Data^.Poczatek+Data^.Dlugosc+5>Temp^.Poczatek then
      begin
        CheckTime:=True;
        Exit;
      end;
    end
    else if Data^.Poczatek>Temp^.Poczatek then
    begin
      if Temp^.Poczatek+Temp^.Dlugosc+5>Data^.Poczatek then
      begin
        CheckTime:=True;
        Exit;
      end;
    end
    else if Data^.Poczatek=Temp^.Poczatek then
    begin
      CheckTime:=True;
      Exit;
    end;
    Inc(I);
  end;
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
  Dialog^.HelpCtx:=hcDzwonekDialogNew;
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Data)=cmOK) then
  begin
    if Dzwonki^.Search(Data, I) or CheckTime(Data) then
    begin
      MessageBox(#3'Taki dzwonek ju� istnieje lub dzwonki pokrywaj� si� !', nil, mfError or mfCancelButton);
      DzwonekAdd:=False;
    end
    else
    begin
      Data^.Index:=Dzwonki^.GetFirstFreeIndex;
      Dzwonki^.Insert(Data);
      Message(Desktop^.Current, evBroadcast, cmUpdateLists, nil);
      Message(Desktop^.Current, evBroadcast, cmDataBaseChanged, nil);
      UpdateFiles;
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
  I, J: Integer;
  L: PLekcja;

procedure UsunDzwonekZLekcji(Item: Pointer); far;
begin
  if PLekcja(Item)^.DzwonekIndex=Data^.Index then
  begin
    Lekcje[I]^.Free(Item);
  end
end;

begin
  Data:=ChooseDzwonek(Dzwonki);
  if Assigned(Data) then
  begin
    if MessageBox(#3'Czy na pewno chcesz usun�� ten dzwonek ?',nil,mfConfirmation or mfYesButton or mfNoButton)=cmYes then
    begin
      for I:=1 to IloscDni do if Assigned(Lekcje[I]) then
      begin
        J:=0;
        while J<Lekcje[I]^.Count do
        begin
          L:=Lekcje[I]^.At(J);
          if L^.DzwonekIndex=Data^.Index then Lekcje[I]^.AtDelete(J)
          else Inc(J);
        end;
      end;
      Dzwonki^.Free(Data);
      Message(Desktop^.Current, evBroadcast, cmUpdateLists, nil);
      Message(Desktop^.Current, evBroadcast, cmDataBaseChanged, nil);
      UpdateFiles;
      DzwonekDel:=True;
    end
    else DzwonekDel:=False;
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
  Dialog^.HelpCtx:=hcDzwonekDialogEdit;
  if LoadSuccessful(Dialog) and (Application^.ExecuteDialog(Dialog, Temp)=cmOK) then
  begin
    if Dzwonki^.Search(Temp, I) or CheckTime(Temp) then
    begin
      MessageBox(#3'Taki dzwonek ju� istnieje lub dzwonki pokrywaj� si� !', nil, mfError or mfCancelButton);
      Dzwonki^.Insert(Data);
      DzwonekEdit:=False;
    end
    else
    begin
      Data^.Assign(Temp);
      Dzwonki^.Insert(Data);
      Message(Desktop^.Current, evBroadcast, cmUpdateLists, nil);
      Message(Desktop^.Current, evBroadcast, cmDataBaseChanged, nil);
      DzwonekEdit:=True;
      UpdateFiles;
    end;
  end
  else
  begin
    Dzwonki^.Insert(Data);
    DzwonekEdit:=False;
  end;
  Dispose(Temp, Done);
end;

function DzwonekDelAll;
var
  I, J: Integer;
  Data: PDataObject;
begin
  if not Assigned(Dzwonki) or Dzwonki^.Empty then
  begin
    MessageBox(#3'Lista dzwonk�w jest pusta', nil, mfError or mfCancelButton);
    Exit;
  end;
  if MessageBox(#3'Czy jeste� pewien, �e chcesz usun�� WSZYSTKIE dzwonki ?',
                   nil, mfConfirmation or mfYesButton or mfNoButton)=cmYes then
  begin
    Dzwonki^.FreeAll;
    for I:=1 to IloscDni do if Assigned(Lekcje[I]) then Lekcje[I]^.DeleteAll;
    Message(Desktop, evBroadcast, cmUpdateLists, nil);
    Message(Desktop, evBroadcast, cmListItemChanged, nil);
    Message(Desktop, evBroadcast, cmDataBaseChanged, nil);
    UpdateFiles;
  end;
end;

{ *** }

function ChooseFromList(List: PDataCollection; EmptyListMsg: String; DataListLabel: String; HelpCtx: Word): PDataObject;
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
      D^.HelpCtx:=HelpCtx;
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
  ChooseNauczyciel:=PNauczyciel(ChooseFromList(List,
                    'Lista dost�pnych nauczycieli jest pusta !',
                    '~L~ista nauczycieli', hcNauczycielDialogChoose));
end;

function ChoosePrzedmiot;
begin
  ChoosePrzedmiot:=PPrzedmiot(ChooseFromList(List,
                   'Lista dost�pnych przedmiot�w jest pusta !',
                   '~L~ista przedmiot�w',
                   hcPrzedmiotDialogChoose));
end;

function ChooseSala;
begin
  ChooseSala:=PSala(ChooseFromList(List,
              'Lista dost�pnych sal jest pusta !',
              '~L~ista sal',
              hcSalaDialogChoose));
end;

function ChooseKlasa;
var
  D: PChooseGrupaKlasyDialog;
  L, I, Grupa: LongInt;
  Data: PKlasa;
begin
  Data:=PKlasa(ChooseFromList(List,
               'Lista dost�pnych klas jest pusta !',
               '~L~ista klas',
              hcKlasaDialogChoose));
  if Assigned(Data) then
  begin
    if ChooseGroup and (Data^.IloscGrup>1) then
    begin
      D:=PChooseGrupaKlasyDialog(ResourceFile.Get('ChooseGrupaKlasyDialog'));
      if Loadsuccessful(D) then
      begin
        D^.HelpCtx:=hcKlasaDialogChooseGrupa;
        L:=0;
        for I:=1 to Data^.IloscGrup do L:=(L shl 1)+1;
        D^.GrupaRadioButtons^.EnableMask:=L;
        L:=0;
        if Application^.ExecuteDialog(D, @L)=cmOK then
        begin
          Inc(L);
          Grupa:=1;
          for I:=1 to L do Grupa:=Grupa shl 1;
          Data^.Grupy:=L;
        end
        else Data:=nil;
      end;
    end
    else Data^.Grupy:=0;
  end;
  ChooseKlasa:=Data;
end;

function ChooseDzwonek;
begin
  ChooseDzwonek:=PDzwonek(ChooseFromList(List,
                 'Lista dost�pnych dzwonk�w jest pusta !',
                 '~L~ista dzwonk�w',
                 hcDzwonekdialogChoose));
end;

function DelLekcja;
var
  I: Integer;
begin
  DelLekcja:=False;
  if Assigned(List) and (not List^.Empty) and Assigned(Data) then
    if List^.Search(Data, I) then
      if MessageBox(#3'Czy na pewno chczes usun�� t� lekcj� ?',nil,mfconfirmation or mfYesButton or mfCancelButton)=cmYes then
      begin
        List^.Delete(Data);
        DelLekcja:=True;
      end;
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
    D^.HelpCtx:=HelpCtx;
    D^.SetTitle(ATitle);
    if Application^.ExecuteDialog(D, Data)=cmOK then EditLekcja:=True
    else EditLekcja:=False;
  end;
end;

procedure LekcjaAdd;
var
  Data: PLekcja;
begin
  if DzwonekIndex=-1 then
  begin
    MessageBox(#3'Lista dzwonk�w jest pusta ! Prosz� j� uzupe�ni�.', nil, mfError or mfCancelButton);
    Exit;
  end;
  New(Data, Init);
  Data^.DzwonekIndex:=DzwonekIndex;
  FiltrujDane(Dzien, DzwonekIndex);
  if EditLekcja(Data, 'Tworzenie nowej lekcji', hcLekcjaDialogNew) then
  begin
    PrzywrocDane;
    Data^.Index:=Lekcje[Dzien]^.GetFirstFreeIndex;
    Lekcje[Dzien]^.Insert(Data);
    Message(Desktop, evBroadcast, cmUpdateLists, nil);
    Message(Desktop, evBroadcast, cmListItemChanged, nil);
    Message(Desktop, evBroadcast, cmDataBaseChanged, nil);
    UpdateFiles;
  end
  else
  begin
    PrzywrocDane;
    Dispose(Data, Done);
  end;
end;

procedure LekcjaDel;
begin
  if not Assigned(Data) then Exit;
  if MessageBox(#3'Czy na pewno chcesz usun�� t� lekcj� ?', nil, mfConfirmation or mfYesButton or mfNoButton)=cmYes then
  begin
    Lekcje[Dzien]^.Free(Data);
    Message(Desktop, evBroadcast, cmUpdateLists, nil);
    Message(Desktop, evBroadcast, cmListItemChanged, nil);
    Message(Desktop, evBroadcast, cmDataBaseChanged, nil);
    UpdateFiles;
  end;
end;

procedure LekcjaEdit;
begin
  if not Assigned(Data) then Exit;
  Lekcje[Dzien]^.Delete(Data);
  FiltrujDane(Dzien, DzwonekIndex);
  EditLekcja(Data, 'Edycja wpisu lekcji', hcLekcjaDialogEdit);
  Lekcje[Dzien]^.Insert(Data);
  PrzywrocDane;
  Message(Desktop, evBroadcast, cmUpdateLists, nil);
  Message(Desktop, evBroadcast, cmListItemChanged, nil);
  Message(Desktop, evBroadcast, cmDataBaseChanged, nil);
  UpdateFiles;
end;

procedure LekcjaDelAll;
var
  I: Integer;
begin
  if MessageBox(#3'Czy jeste� pewien, �e chcesz usun�� WSZYSTKIE lekcje z planu zaj�� ?',
                   nil, mfConfirmation or mfYesButton or mfNoButton)=cmYes then
  begin
    for I:=1 to IloscDni do if Assigned(Lekcje[I]) then Lekcje[I]^.DeleteAll;
    Message(Desktop, evBroadcast, cmUpdateLists, nil);
    Message(Desktop, evBroadcast, cmListItemChanged, nil);
    Message(Desktop, evBroadcast, cmDataBaseChanged, nil);
    UpdateFiles;
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

  UpdateFiles;
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
