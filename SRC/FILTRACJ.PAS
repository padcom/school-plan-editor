Unit FiltracjaDanych;

interface
uses DataObjects;

procedure FiltrujDane(LekcjaList: PDataCollection);
procedure PrzywrocDane;

implementation
uses Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja;

var
  TempNauczycielList: PDataCollection;
  TempPrzedmiotList: PDataCollection;
  TempKlasaList: PDataCollection;
  TempSalaList: PDataCollection;

procedure FiltrujNauczycieli(LekcjaList: PDataCollection);
var
  I: Integer;
  L: PLekcja;
  Data: PNauczyciel;
  DataIndex: LongInt;
begin
  I:=0;
  New(TempNauczycielList, Init(10, 5));
  if Assigned(LekcjaList) then while I<LekcjaList^.Count do
  begin
    L:=LekcjaList^.At(I);
    L^.GetNauczyciel(Data);
    if Assigned(Data) then
    begin
      Data^.GetIndex(DataIndex);
      Nauczyciele^.Delete(Data);
      Data^.SetIndex(-1);
      TempNauczycielList^.Insert(Data);
      Data^.SetIndex(DataIndex);
    end;
    Inc(I);
  end;
end;

procedure PrzywrocNauczycieli;
var
  I: Integer;
  Data: PNauczyciel;
  DataIndex: LongInt;
begin
  I:=0;
  while I<TempNauczycielList^.Count do
  begin
    Data:=TempNauczycielList^.At(I);
    Data^.GetIndex(DataIndex); Data^.SetIndex(-1);
    Nauczyciele^.Insert(Data);
    Data^.SetIndex(DataIndex);
    Inc(I);
  end;
  TempNauczycielList^.DeleteAll;
  Dispose(TempNauczycielList, Done);
end;

procedure FiltrujSale(LekcjaList: PDataCollection);
var
  I: Integer;
  L: PLekcja;
  Data: PSala;
  DataIndex: LongInt;
begin
  I:=0;
  New(TempSalaList, Init(10, 5));
  if Assigned(LekcjaList) then while I<LekcjaList^.Count do
  begin
    L:=LekcjaList^.At(I);
    L^.GetSala(Data);
    if Assigned(Data) then
    begin
      Data^.GetIndex(DataIndex);
      Sale^.Delete(Data);
      Data^.SetIndex(-1);
      TempSalaList^.Insert(Data);
      Data^.SetIndex(DataIndex);
    end;
    Inc(I);
  end;
end;

procedure PrzywrocSale;
var
  I: Integer;
  Data: PSala;
  DataIndex: LongInt;
begin
  I:=0;
  while I<TempSalaList^.Count do
  begin
    Data:=TempSalaList^.At(I);
    Data^.GetIndex(DataIndex); Data^.SetIndex(-1);
    Sale^.Insert(Data);
    Data^.SetIndex(DataIndex);
    Inc(I);
  end;
  TempSalaList^.DeleteAll;
  Dispose(TempSalaList, Done);
end;


procedure FiltrujKlasy(LekcjaList: PDataCollection);
var
  I: Integer;
  L: PLekcja;
  Data: PKlasa;
  DataIndex: LongInt;
begin
  I:=0;
  New(TempKlasaList, Init(10, 5));
  if Assigned(LekcjaList) then while I<LekcjaList^.Count do
  begin
    L:=LekcjaList^.At(I);
    L^.GetKlasa(Data);
    if Assigned(Data) then
    begin
      Data^.EnableGroupMask:=Data^.EnableGroupMask and (not L^.FGrupy);
      if Data^.EnableGroupMask=0 then
      begin
        Data^.GetIndex(DataIndex);
        Klasy^.Delete(Data);
        Data^.SetIndex(-1);
        TempKlasaList^.Insert(Data);
        Data^.SetIndex(DataIndex);
      end;
    end;
    Inc(I);
  end;
end;

procedure PrzywrocKlasy;
var
  I: Integer;
  Data: PKlasa;
  DataIndex: LongInt;
begin
  I:=0;
  while I<TempKlasaList^.Count do
  begin
    Data:=TempKlasaList^.At(I);
    Data^.GetIndex(DataIndex); Data^.SetIndex(-1);
    Klasy^.Insert(Data);
    Data^.SetIndex(DataIndex);
    Data^.EnableGroupMask:=IncPower2(Data^.FIloscGrup);
    Inc(I);
  end;
  TempKlasaList^.DeleteAll;
  Dispose(TempKlasaList, Done);
end;


procedure FiltrujDane(LekcjaList: PDataCollection);
begin
  FiltrujNauczycieli(LekcjaList);
  FiltrujSale(LekcjaList);
  FiltrujKlasy(LekcjaList);
end;

procedure PrzywrocDane;
begin
  PrzywrocNauczycieli;
  PrzywrocSale;
  PrzywrocKlasy;
end;

begin

end.
