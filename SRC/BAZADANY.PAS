Unit BazaDanych;

interface
uses DOS, Objects, Drivers, Views, Dialogs, Menus,
     DataObjects, DataDialogs,
     Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Stale, Lekcja;

procedure OpenFiles(DataDir: PathStr);
procedure CloseFiles;
procedure UpdateNauczycielStream;
procedure UpdatePrzedmiotStream;
procedure UpdateKlasaStream;
procedure UpdateSalaStream;
procedure UpdateDzwonekStream;
procedure UpdateAllStreams;

procedure DodajNauczyciela;
procedure PoprawNauczyciela;
procedure UsunNauczyciela;

procedure DodajPrzedmiot;
procedure PoprawPrzedmiot;
procedure UsunPrzedmiot;

procedure DodajKlase;
procedure PoprawKlase;
procedure UsunKlase;

procedure DodajSale;
procedure PoprawSale;
procedure UsunSale;

procedure DodajDzwonek;
procedure PoprawDzwonek;
procedure UsunDzwonek;

function BazaDanychMenu(Next: PMenuItem): PMenu;

implementation
uses App, MsgBox, Latin2, Pack;

var { Zmienne identyfikuj¥ce pliki danych }
  NauczycielStream: TDosStream;
  PrzedmiotStream: TDosStream;
  KlasaStream: TDosStream;
  SalaStream: TDosStream;
  DzwonekStream: TDosStream;
  LekcjaStream: TDosStream;

  { Procedury operuj¥ce na plikach }

procedure OpenFiles(DataDir: PathStr);
var
  I: Integer;
  S: String;
begin
  if DataDir[Length(DataDir)]<>'\' then DataDir:=DataDir+'\';
  {$I-} MkDir('DATA'); {$I+}

  NauczycielStream.Init(DataDir+'NAUCZ.DAT', stOpen);
  if NauczycielStream.Status<>stOK then
  begin
    NauczycielStream.Init(DataDir+'NAUCZ.DAT', stCreate);
    New(Nauczyciele, Init(10, 5));
  end
  else New(Nauczyciele, Load(NauczycielStream));

  PrzedmiotStream.Init(DataDir+'PRZEDM.DAT', stOpen);
  if PrzedmiotStream.Status<>stOK then
  begin
    PrzedmiotStream.Init(DataDir+'PRZEDM.DAT', stCreate);
    New(Przedmioty, Init(10, 5));
  end
  else New(Przedmioty, Load(PrzedmiotStream));

  KlasaStream.Init(DataDir+'KLASY.DAT', stOpen);
  if KlasaStream.Status<>stOK then
  begin
    KlasaStream.Init(DataDir+'KLASY.DAT', stCreate);
    New(Klasy, Init(10, 5));
  end
  else New(Klasy, Load(KlasaStream));

  SalaStream.Init(DataDir+'SALE.DAT', stOpen);
  if SalaStream.Status<>stOK then
  begin
    SalaStream.Init(DataDir+'SALE.DAT', stCreate);
    New(Sale, Init(10, 5));
  end
  else New(Sale, Load(SalaStream));

  DzwonekStream.Init(DataDir+'DZWONKI.DAT', stOpen);
  if DzwonekStream.Status<>stOK then
  begin
    DzwonekStream.Init(DataDir+'DZWONKI.DAT', stCreate);
    New(Dzwonki, Init(10, 5));
  end
  else New(Dzwonki, Load(DzwonekStream));

  LekcjaStream.Init(DataDir+'LEKCJE.DAT', stOpen);
  if LekcjaStream.Status<>stOK then
  begin
    LekcjaStream.Init(DataDir+'LEKCJE.DAT', stCreate);
    for I:=1 to IloscDniTygodnia do
    begin
      New(Lekcje[I], Init(1,1));
    end;
  end
  else
  begin
    for I:=1 to IloscDniTygodnia do
    begin
      New(Lekcje[I], Load(LekcjaStream));
    end;
  end;
end;

procedure CloseFiles;
var I: Integer;
begin
  NauczycielStream.Done;
  PrzedmiotStream.Done;
  KlasaStream.Done;
  SalaStream.Done;
  DzwonekStream.Done;
  LekcjaStream.Done;
end;

procedure UpdateNauczycielStream;
begin
  with NauczycielStream do
  begin
    Init('DATA\NAUCZ.DAT', stCreate);
    Seek(0);
    Nauczyciele^.Store(NauczycielStream);
    Truncate;
    Done;
  end;
end;

procedure UpdatePrzedmiotStream;
begin
  with PrzedmiotStream do
  begin
    Init('DATA\PRZEDM.DAT', stCreate);
    Seek(0);
    Przedmioty^.Store(PrzedmiotStream);
    Truncate;
    Done;
  end;
end;

procedure UpdateKlasaStream;
begin
  with KlasaStream do
  begin
    Init('DATA\KLASY.DAT', stCreate);
    Seek(0);
    Klasy^.Store(KlasaStream);
    Truncate;
    Done;
  end;
end;

procedure UpdateSalaStream;
begin
  with SalaStream do
  begin
    Init('DATA\SALE.DAT', stCreate);
    Seek(0);
    Sale^.Store(SalaStream);
    Truncate;
    Done;
  end;
end;

procedure UpdateDzwonekStream;
begin
  with DzwonekStream do
  begin
    Init('DATA\DZWONKI.DAT', stCreate);
    Seek(0);
    Dzwonki^.Store(DzwonekStream);
    Truncate;
    Done;
  end;
end;

procedure UpdateLekcjaStream;
var I: Integer;
begin
  with LekcjaStream do
  begin
    Init('DATA\LEKCJE.DAT', stCreate);
    Seek(0);
    for I:=1 to IloscDniTygodnia do Lekcje[I]^.Store(LekcjaStream);
    Truncate;
    Done;
  end;
end;

procedure UpdateAllStreams;
begin
  UpdateNauczycielStream;
  UpdatePrzedmiotStream;
  UpdateKlasaStream;
  UpdateSalaStream;
  UpdateDzwonekStream;
  UpdateLekcjaStream;
end;


  { Procedury operuj¥ce na nauczycielu }

procedure DodajNauczyciela;
var
  Dialog: PNauczycielDialog;
  Data  : PNauczyciel;
  Index : Integer;
begin
  New(Dialog, Init('Dodawanie nowego nauczyciela'));
  New(Data, Init);
  if Application^.ExecuteDialog(Dialog, @Data)<>cmCancel then
  begin
    if Nauczyciele^.Search(Data, Index) then
    begin
      MessageBox(#3'Taki nauczyciel ju¾ istnieje !',
                 nil,
                 mfError or mfCancelButton);
      Data^.Free;
    end
    else
    begin
      Nauczyciele^.Insert(Data);
      Message(Application, evBroadcast, cmDataChanged, nil);
    end;
  end
  else Data^.Free;
end;

procedure PoprawNauczyciela;
var
  Dialog: PNauczycielDialog;
  Data, Temp: PNauczyciel;
  Index: Integer;
  TempIndex: LongInt;
begin
  Index:=ChooseNauczyciel(Nauczyciele, False);
  if Index<>-1 then
  begin
    Data:=PNauczyciel(Nauczyciele^.ItemByIndex(Index));
    if Data<>nil then
    begin
      Nauczyciele^.Delete(Data);
      Data^.GetIndex(TempIndex);
      New(Temp, Init);
      Temp^:=Data^; Temp^.SetIndex(-1);
      New(Dialog, Init('Poprawnianie wpisu nauczyciela'));
      Inc(Dialog^.HelpCtx);
      if Application^.ExecuteDialog(Dialog, @Temp)<>cmCancel then
      begin
        if Nauczyciele^.Search(Temp, Index) then
        begin
          MessageBox(#3'Taki nauczyciel ju¾ istnieje !',
                     nil,
                     mfError or mfCancelButton);
          Nauczyciele^.Insert(Data);
          Data^.SetIndex(TempIndex);
        end
        else
        begin
          Data^:=Temp^;
          Nauczyciele^.Insert(Data);
          Data^.SetIndex(TempIndex);
          Message(Application, evBroadcast, cmDataChanged, nil);
        end;
      end
      else
      begin
        Nauczyciele^.Insert(Data);
        Data^.SetIndex(TempIndex);
      end;
      Temp^.Free;
    end;
  end;
end;

procedure UsunNauczyciela;
var
  Data: PNauczyciel;
  Index: Integer;
begin
  Index:=ChooseNauczyciel(Nauczyciele, False);
  if Index<>-1 then
  begin
    Data:=PNauczyciel(Nauczyciele^.ItemByIndex(Index));
    if Data<>nil then
    begin
      if MessageBox(#3'Czy na pewno chcesz usun¥† tego nauczyciela ?',
                    nil,
                    mfconfirmation or mfCancelButton or mfOkButton)<>cmCancel then
      begin
        Nauczyciele^.Free(Data);
        Message(Application, evBroadcast, cmDataChanged, nil);
      end;
    end;
  end;
end;


  { Procedury operuj¥ce na przedmiotach }

procedure DodajPrzedmiot;
var
  Dialog: PPrzedmiotDialog;
  Data  : PPrzedmiot;
  Index : Integer;
begin
  New(Dialog, Init('Dodawanie nowego przedmiotu'));
  New(Data, Init);
  if Application^.ExecuteDialog(Dialog, @Data)<>cmCancel then
  begin
    if Przedmioty^.Search(Data, Index) then
    begin
      MessageBox(#3'Taki przedmiot ju¾ istnieje !',
                 nil,
                 mfError or mfCancelButton);
      Data^.Free;
    end
    else
    begin
      Przedmioty^.Insert(Data);
      Message(Application, evBroadcast, cmDataChanged, nil);
    end;
  end
  else Data^.Free;
end;

procedure PoprawPrzedmiot;
var
  Dialog: PPrzedmiotDialog;
  Data, Temp: PPrzedmiot;
  Index: Integer;
  TempIndex: LongInt;
begin
  Index:=ChoosePrzedmiot(Przedmioty, False);
  if Index<>-1 then
  begin
    Data:=PPrzedmiot(Przedmioty^.ItemByIndex(Index));
    if Data<>nil then
    begin
      Przedmioty^.Delete(Data);
      Data^.GetIndex(TempIndex);
      New(Temp, Init);
      Temp^:=Data^; Temp^.SetIndex(-1);
      New(Dialog, Init('Poprawnianie wpisu przedmiotu'));
      Inc(Dialog^.HelpCtx);
      if Application^.ExecuteDialog(Dialog, @Temp)<>cmCancel then
      begin
        if Przedmioty^.Search(Temp, Index) then
        begin
          MessageBox(#3'Taki przedmiot ju¾ istnieje !',
                     nil,
                     mfError or mfCancelButton);
          Przedmioty^.Insert(Data);
          Data^.SetIndex(TempIndex);
        end
        else
        begin
          Data^:=Temp^;
          Przedmioty^.Insert(Data);
          Data^.SetIndex(TempIndex);
          Message(Application, evBroadcast, cmDataChanged, nil);
        end;
      end
      else
      begin
        Przedmioty^.Insert(Data);
        Data^.SetIndex(TempIndex);
      end;
      Temp^.Free;
    end;
  end;
end;

procedure UsunPrzedmiot;
var
  Data: PPrzedmiot;
  Index: Integer;
begin
  Index:=ChoosePrzedmiot(Przedmioty, False);
  if Index<>-1 then
  begin
    Data:=PPrzedmiot(Przedmioty^.ItemByIndex(Index));
    if Data<>nil then
    begin
      if MessageBox(#3'Czy na pewno chcesz usun¥† ten przedmiot ?',
                    nil,
                    mfconfirmation or mfCancelButton or mfOkButton)<>cmCancel then
      begin
        Przedmioty^.Free(Data);
        Message(Application, evBroadcast, cmDataChanged, nil);
      end;
    end;
  end;
end;


  { Procedury operuj¥ce na klasach }

procedure DodajKlase;
var
  Dialog: PKlasaDialog;
  Data  : PKlasa;
  Index : Integer;
begin
  New(Dialog, Init('Dodawanie nowej klasy'));
  New(Data, Init);
  if Application^.ExecuteDialog(Dialog, @Data)<>cmCancel then
  begin
    if Klasy^.Search(Data, Index) then
    begin
      MessageBox(#3'Taka klasa ju¾ istnieje !',
                 nil,
                 mfError or mfCancelButton);
      Data^.Free;
    end
    else
    begin
      Klasy^.Insert(Data);
      Message(Application, evBroadcast, cmDataChanged, nil);
    end;
  end
  else Data^.Free;
end;

procedure PoprawKlase;
var
  Dialog: PKlasaDialog;
  Data, Temp: PKlasa;
  Index: Integer;
  TempIndex: LongInt;
begin
  Index:=ChooseKlasa(Klasy, False);
  if Index<>-1 then
  begin
    Data:=PKlasa(Klasy^.ItemByIndex(Index));
    if Data<>nil then
    begin
      Data^.GetIndex(TempIndex);
      New(Temp, Init);
      Temp^:=Data^; Temp^.SetIndex(-1);
      New(Dialog, Init('Poprawnianie wpisu klasy'));
      Inc(Dialog^.HelpCtx);
      if Application^.ExecuteDialog(Dialog, @Temp)<>cmCancel then
      begin
        Klasy^.Delete(Data);
        if Klasy^.Search(Temp, Index) then
        begin
          MessageBox(#3'Taka klasa ju¾ istnieje !',
                     nil,
                     mfError or mfCancelButton);
          Data^.SetIndex(-1);
          Klasy^.Insert(Data);
          Data^.SetIndex(TempIndex);
        end
        else
        begin
          Data^:=Temp^;
          Klasy^.Insert(Data);
          Data^.SetIndex(TempIndex);
          Message(Application, evBroadcast, cmDataChanged, nil);
        end;
      end
      else
      begin
        Klasy^.Insert(Data);
        Data^.SetIndex(TempIndex);
      end;
      Temp^.Free;
    end;
  end;
end;

procedure UsunKlase;
var
  Data: PKlasa;
  Index: Integer;
begin
  Index:=ChooseKlasa(Klasy, False);
  if Index<>-1 then
  begin
    Data:=PKlasa(Klasy^.ItemByIndex(Index));
    if Data<>nil then
    begin
      if MessageBox(#3'Czy na pewno chcesz usun¥† t¥ klas© ?',
                    nil,
                    mfconfirmation or mfCancelButton or mfOkButton)<>cmCancel then
      begin
        Klasy^.Free(Data);
        Message(Application, evBroadcast, cmDataChanged, nil);
      end;
    end;
  end;
end;


  { Procedury operuj¥ce na salach }

procedure DodajSale;
var
  Dialog: PSalaDialog;
  Data  : PSala;
  Index : Integer;
begin
  New(Dialog, Init('Dodawanie nowej sali'));
  New(Data, Init);
  if Application^.ExecuteDialog(Dialog, @Data)<>cmCancel then
  begin
    if Sale^.Search(Data, Index) then
    begin
      MessageBox(#3'Taka sala ju¾ istnieje !',
                 nil,
                 mfError or mfCancelButton);
      Data^.Free;
    end
    else
    begin
      Sale^.Insert(Data);
      Message(Application, evBroadcast, cmDataChanged, nil);
    end;
  end
  else Data^.Free;
end;

procedure PoprawSale;
var
  Dialog: PSalaDialog;
  Data, Temp: PSala;
  Index: Integer;
  TempIndex: LongInt;
begin
  Index:=ChooseSala(Sale, False);
  if Index<>-1 then
  begin
    Data:=PSala(Sale^.ItemByIndex(Index));
    if Data<>nil then
    begin
      Data^.GetIndex(TempIndex);
      New(Temp, Init);
      Temp^:=Data^; Temp^.SetIndex(-1);
      New(Dialog, Init('Poprawnianie wpisu sali'));
      Inc(Dialog^.HelpCtx);
      if Application^.ExecuteDialog(Dialog, @Temp)<>cmCancel then
      begin
        if Sale^.Search(Temp, Index) then
        begin
          MessageBox(#3'Taka sala ju¾ istnieje !',
                     nil,
                     mfError or mfCancelButton);
        end
        else
        begin
          Sale^.Delete(Data);
          Data^:=Temp^;
          Sale^.Insert(Data);
          Data^.SetIndex(TempIndex);
          Message(Application, evBroadcast, cmDataChanged, nil);
        end;
      end
      else
      begin
        Sale^.Insert(Data);
        Data^.SetIndex(TempIndex);
      end;
      Temp^.Free;
    end;
  end;
end;

procedure UsunSale;
var
  Data: PSala;
  Index: Integer;
begin
  Index:=ChooseSala(Sale, False);
  if Index<>-1 then
  begin
    Data:=PSala(Sale^.ItemByIndex(Index));
    if Data<>nil then
    begin
      if MessageBox(#3'Czy na pewno chcesz usun¥† t¥ sal© ?',
                    nil,
                    mfconfirmation or mfCancelButton or mfOkButton)<>cmCancel then
      begin
        Sale^.Free(Data);
        Message(Application, evBroadcast, cmDataChanged, nil);
      end;
    end;
  end;
end;

function CheckTime(Data: PDzwonek): Boolean;
var
  I: Integer;
  Data2: PDzwonek;
  S1, S2: TDzwonekStart;
  T1, T2: Word;
begin
  if Dzwonki^.Count=0 then CheckTime:=False
  else
  begin
    Data^.GetStart(S1);
    T1:=S1.Godzina*60+S1.Minuta;
    for I:=0 to Dzwonki^.Count-1 do
    begin
      Data2:=PDzwonek(Dzwonki^.At(I));
      Data2^.GetStart(S2);
      T2:=S2.Godzina*60+S2.Minuta;
      if Abs(T1-T2)<50 then
      begin
        CheckTime:=True;
        Exit;
      end;
    end;
    CheckTime:=False;
  end;
end;

  { Procedury operuj¥ce na dzwonkach }

procedure DodajDzwonek;
var
  Dialog: PDzwonekDialog;
  Data  : PDzwonek;
  Index : Integer;
begin
  New(Dialog, Init('Dodawanie nowego dzwonka'));
  New(Data, Init);
  if Application^.ExecuteDialog(Dialog, @Data)<>cmCancel then
  begin
    if Dzwonki^.Search(Data, Index) or CheckTime(Data) then
    begin
      MessageBox(#3'Godziny lekcyjne nie mog¥ pokrywa† si© !',
                 nil,
                 mfError or mfCancelButton);
      Data^.Free;
    end
    else
    begin
      Dzwonki^.Insert(Data);
      Message(Application, evBroadcast, cmDataChanged, nil);
    end;
  end
  else Data^.Free;
end;

procedure PoprawDzwonek;
var
  Dialog: PDzwonekDialog;
  Data, Temp: PDzwonek;
  Index: Integer;
  TempIndex: LongInt;
begin
  Index:=ChooseDzwonek(Dzwonki, False);
  if Index<>-1 then
  begin
    Data:=PDzwonek(Dzwonki^.ItemByIndex(Index));
    if Data<>nil then
    begin
      Data^.GetIndex(TempIndex);
      New(Temp, Init);
      Temp^:=Data^; Temp^.SetIndex(-1);
      New(Dialog, Init('Poprawnianie wpisu dzwonka'));
      Inc(Dialog^.HelpCtx);
      if Application^.ExecuteDialog(Dialog, @Temp)<>cmCancel then
      begin
        if Dzwonki^.Search(Temp, Index) or CheckTime(Data) then
        begin
          MessageBox(#3'Godziny lekcyjne nie mog¥ pokrywa† si© !',
                     nil,
                     mfError or mfCancelButton);
        end
        else
        begin
          Dzwonki^.Delete(Data);
          Data^:=Temp^;
          Dzwonki^.Insert(Data);
          Data^.SetIndex(TempIndex);
          Message(Application, evBroadcast, cmDataChanged, nil);
        end;
      end
      else
      begin
        Dzwonki^.Insert(Data);
        Data^.SetIndex(TempIndex);
      end;
      Temp^.Free;
    end;
  end;
end;

procedure UsunDzwonek;
var
  Data: PDzwonek;
  Index: Integer;
begin
  Index:=ChooseDzwonek(Dzwonki, False);
  if Index<>-1 then
  begin
    Data:=PDzwonek(Dzwonki^.ItemByIndex(Index));
    if Data<>nil then
    begin
      if MessageBox(#3'Czy na pewno chcesz usun¥† ten dzwonek ?',
                    nil,
                    mfconfirmation or mfCancelButton or mfOkButton)<>cmCancel then
      begin
        Dzwonki^.Free(Data);
        Message(Application, evBroadcast, cmDataChanged, nil);
      end;
    end;
  end;
end;


function BazaDanychMenu(Next: PMenuItem): PMenu;
begin
  BazaDanychMenu:=NewMenu(
    NewSubMenu('~B~aza danych', $FF3F, NewMenu(
      NewSubMenu('~N~auczyciele', $FF40, NewMenu(
        NewItem('~D~odaj', 'F5', kbF5, cmDodajNauczyciela, $FF41,
        NewItem('~P~opraw', 'Shift-F5', kbShiftF5, cmPoprawNauczyciela, $FF42,
        NewItem('~U~suä', 'Ctrl-F5', kbCtrlF5, cmUsunNauczyciela, $FF43,
        nil)))),
      NewSubMenu('~P~rzedmioty', $FF44, NewMenu(
        NewItem('~D~odaj', 'F6', kbF6, cmDodajPrzedmiot, $FF45,
        NewItem('~P~opraw', 'Shift-F6', kbShiftF6, cmPoprawPrzedmiot, $FF46,
        NewItem('~U~suä', 'Ctrl-F6', kbCtrlF6, cmUsunPrzedmiot, $FF47,
        nil)))),
      NewSubMenu('~K~lasy', $FF48, NewMenu(
        NewItem('~D~odaj', 'F7', kbF7, cmDodajKlase, $FF49,
        NewItem('~P~opraw', 'Shift-F7', kbShiftF7, cmPoprawKlase, $FF4A,
        NewItem('~U~suä', 'Ctrl-F7', kbCtrlF7, cmUsunKlase, $FF4B,
        nil)))),
      NewSubMenu('~S~ale', $FF4C, NewMenu(
        NewItem('~D~odaj', 'F8', kbF8, cmDodajSale, $FF4D,
        NewItem('~P~opraw', 'Shift-F8', kbShiftF8, cmPoprawSale, $FF4E,
        NewItem('~U~suä', 'Ctrl-F8', kbCtrlF8, cmUsunSale, $FF4F,
        nil)))),
      NewLine(
      NewSubMenu('~D~zwonki', $FF50, NewMenu(
        NewItem('~D~odaj', 'F9', kbF9, cmDodajDzwonek, $FF51,
        NewItem('~P~opraw', 'Shift-F9', kbShiftF9, cmPoprawDzwonek, $FF52,
        NewItem('~U~suä', 'Ctrl-F9', kbCtrlF9, cmUsunDzwonek, $FF53,
        nil)))),
      nil))))))),
    Next));
end;

begin
end.
