Unit Filtr;

interface

procedure FiltrujDane(Dzien: Integer; DzwonekIndex: LongInt);
procedure PrzywrocDane;

implementation
uses
  DataObjects, Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja;

var
  TempNauczyciele,
  TempPrzedmioty,
  TempKlasy,
  TempSale: PDataCollection;

procedure FiltrujNauczycieli(Dzien: Integer; DzwonekIndex: LongInt);
var
  I: Integer;
  Data: PDataObject;
  L: PLekcja;
begin
  New(TempNauczyciele, Init(10, 5));
  if not Assigned(Lekcje[Dzien]) or (Lekcje[Dzien]^.Count=0) then Exit;
  I:=0;
  while I<Lekcje[Dzien]^.Count do
  begin
    L:=PLekcja(Lekcje[Dzien]^.At(I));
    if L^.DzwonekIndex=DzwonekIndex then
    begin
      Data:=Nauczyciele^.ItemByIndex(L^.NauczycielIndex);
      if Assigned(Data) then
      begin
        Nauczyciele^.Delete(Data);
        TempNauczyciele^.Insert(Data);
      end;
    end;
    Inc(I);
  end;
end;

procedure PrzywrocNauczycieli;
var
  I: Integer;
  Data: PDataObject;
begin
  while TempNauczyciele^.Count<>0 do
  begin
    Data:=TempNauczyciele^.At(0);
    TempNauczyciele^.Delete(Data);
    Nauczyciele^.Insert(Data);
  end;
{  TempNauczyciele^.DeleteAll;}
  Dispose(TempNauczyciele, Done);
end;

procedure FiltrujKlasy(Dzien: Integer; DzwonekIndex: LongInt);
var
  W: Word;
  I, J: Integer;
  Data: PKlasa;
  L: PLekcja;
begin
  { inicjalizacja filtr¢w klasy }
  I:=0; while I<Klasy^.Count do
  begin
    Data:=PKlasa(Klasy^.At(I));
    W:=0;
    for J:=1 to Data^.IloscGrup do W:=(W shl 1)+1;
    Data^.FiltrowaneGrupy:=W;
    Inc(I);
  end;

  New(TempKlasy, Init(10, 5));
  if not Assigned(Lekcje[Dzien]) or (Lekcje[Dzien]^.Count=0) then Exit;

  I:=0;
  while I<Lekcje[Dzien]^.Count do
  begin
    L:=PLekcja(Lekcje[Dzien]^.At(I));
    if L^.DzwonekIndex=DzwonekIndex then
    begin
      Data:=PKlasa(Klasy^.ItemByIndex(L^.KlasaIndex));
      if Assigned(Data) then
      begin
        Data^.FiltrowaneGrupy:=Data^.FiltrowaneGrupy and (not L^.Grupy);
        if Data^.FiltrowaneGrupy=0 then
        begin
          Klasy^.Delete(Data);
          TempKlasy^.Insert(Data);
        end;
      end;
    end;
    Inc(I);
  end;
end;

procedure PrzywrocKlasy;
var
  I: Integer;
  Data: PDataObject;
begin
  while TempKlasy^.Count<>0 do
  begin
    Data:=TempKlasy^.At(0);
    TempKlasy^.Delete(Data);
    Klasy^.Insert(Data);
  end;
{  TempKlasy^.DeleteAll;}
  Dispose(TempKlasy, Done);
end;

procedure FiltrujSale(Dzien: Integer; DzwonekIndex: LongInt);
var
  I: Integer;
  Data: PDataObject;
  L: PLekcja;
begin
  New(TempSale, Init(10, 5));
  if not Assigned(Lekcje[Dzien]) or (Lekcje[Dzien]^.Count=0) then Exit;
  I:=0;
  while I<Lekcje[Dzien]^.Count do
  begin
    L:=PLekcja(Lekcje[Dzien]^.At(I));
    if L^.DzwonekIndex=DzwonekIndex then
    begin
      Data:=Sale^.ItemByIndex(L^.SalaIndex);
      if Assigned(Data) then
      begin
        Sale^.Delete(Data);
        TempSale^.Insert(Data);
      end;
    end;
    Inc(I);
  end;
end;

procedure PrzywrocSale;
var
  I: Integer;
  Data: PDataObject;
begin
  while TempSale^.Count<>0 do
  begin
    Data:=TempSale^.At(0);
    TempSale^.Delete(Data);
    Sale^.Insert(Data);
  end;
{  TempSale^.DeleteAll;}
  Dispose(TempSale, Done);
end;

procedure FiltrujDane;
begin
  FiltrujNauczycieli(Dzien, DzwonekIndex);
  FiltrujKlasy(Dzien, DzwonekIndex);
  FiltrujSale(Dzien, DzwonekIndex);
end;

procedure PrzywrocDane;
begin
  PrzywrocNauczycieli;
  PrzywrocKlasy;
  PrzywrocSale;
end;

begin
end.
