Unit Archiwizacja;

interface

procedure Archiwizuj;
procedure Odtworz;

implementation
uses Crt, App, Objects, Drivers, Views, Dialogs, MsgBox,
     Pack, Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja, BazaDanych, MainWindow;

procedure MakeDialog(var D: PDialog; ATitle: TTitleStr);
var
  R: TRect;
  I: PInputLine;
begin
  R.Assign(0, 0, 35, 8);
  New(D, Init(R, ATitle));
  D^.Options:=D^.Options or ofCentered;

  R.Assign(10, 5, 25, 7);
  D^.Insert(New(PButton, Init(R, '~D~alej', cmOK, bfDefault)));

  R.Assign(25, 2, 28, 3);
  New(I, Init(R, 1));
  D^.Insert(I);

  R.Assign(5, 2, 25, 3);
  D^.Insert(New(PLabel, Init(R, '~L~itera dysku', I)));
end;

procedure Archiwizuj;
var
  D: PDialog;
  S: String;
begin
  S:='A'; Directvideo:=False;
  MakeDialog(D, 'Zapytanie');
  if Application^.ExecuteDialog(D, @S)<>cmCancel then
  begin
    CloseFiles;
    if IOResult<>0 then;
    SystemError(15, Ord(S[1])-Ord('A'));
    if UserRequest<>0 then Exit;
    UserRequest:=0;

    GotoXY(1, Application^.Size.Y); ClrEol; PrintStr('Plik: NAUCZ.DAT');
    Compress('DATA\NAUCZ.DAT', S+':\NAUCZ.ARC', True);
    if UserRequest<>0 then Exit;
    UserRequest:=0;

    GotoXY(1, Application^.Size.Y); ClrEol; PrintStr('Plik: PRZEDM.DAT');
    Compress('DATA\PRZEDM.DAT', S+':\PRZEDM.ARC', True);
    if UserRequest<>0 then Exit;
    UserRequest:=0;

    GotoXY(1, Application^.Size.Y); ClrEol; PrintStr('Plik: KLASY.DAT');
    Compress('DATA\KLASY.DAT', S+':\KLASY.ARC', True);
    if UserRequest<>0 then Exit;
    UserRequest:=0;

    GotoXY(1, Application^.Size.Y); ClrEol; PrintStr('Plik: SALE.DAT');
    Compress('DATA\SALE.DAT', S+':\SALE.ARC', True);
    if UserRequest<>0 then Exit;
    UserRequest:=0;

    GotoXY(1, Application^.Size.Y); ClrEol; PrintStr('Plik: DZWONKI.DAT');
    Compress('DATA\DZWONKI.DAT', S+':\DZWONKI.ARC', True);
    if UserRequest<>0 then Exit;
    UserRequest:=0;

    GotoXY(1, Application^.Size.Y); ClrEol; PrintStr('Plik: LEKCJE.DAT');
    Compress('DATA\LEKCJE.DAT', S+':\LEKCJE.ARC', True);
    if UserRequest<>0 then Exit;
    UserRequest:=0;

    Application^.Redraw;
  end
  else MessageBox(#3'Zaniechano procesu archiwizacji danych', nil, mfInformation or mfOkButton);
end;

procedure Odtworz;
var
  D: PDialog;
  S: String;
  I: Integer;
begin
  S:='A';
  MakeDialog(D, 'Zapytanie');
  if Application^.ExecuteDialog(D, @S)<>cmCancel then
  begin
    GotoXY(1, Application^.Size.Y); ClrEol; PrintStr('Plik: NAUCZ.DAT');
    Decompress(S+':\NAUCZ.ARC', 'DATA\NAUCZ.DAT', True);
    if UserRequest<>0 then Exit;
    UserRequest:=0;
    GotoXY(1, Application^.Size.Y); ClrEol; PrintStr('Plik: PRZEDM.DAT');
    Decompress(S+':\PRZEDM.ARC', 'DATA\PRZEDM.DAT', True);
    if UserRequest<>0 then Exit;
    UserRequest:=0;
    GotoXY(1, Application^.Size.Y); ClrEol; PrintStr('Plik: KLASY.DAT');
    Decompress(S+':\KLASY.ARC', 'DATA\KLASY.DAT', True);
    if UserRequest<>0 then Exit;
    UserRequest:=0;
    GotoXY(1, Application^.Size.Y); ClrEol; PrintStr('Plik: SALE.DAT');
    Decompress(S+':\SALE.ARC', 'DATA\SALE.DAT', True);
    if UserRequest<>0 then Exit;
    UserRequest:=0;
    GotoXY(1, Application^.Size.Y); ClrEol; PrintStr('Plik: DZWONKI.DAT');
    Decompress(S+':\DZWONKI.ARC', 'DATA\DZWONKI.DAT', True);
    if UserRequest<>0 then Exit;
    UserRequest:=0;
    GotoXY(1, Application^.Size.Y); ClrEol; PrintStr('Plik: LEKCJE.DAT');
    Decompress(S+':\LEKCJE.ARC', 'DATA\LEKCJE.DAT', True);
    if UserRequest<>0 then Exit;
    UserRequest:=0;

    Dispose(Nauczyciele, Done);
    Dispose(Przedmioty, Done);
    Dispose(Klasy, Done);
    Dispose(Sale, Done);
    Dispose(Dzwonki, Done);
    for I:=1 to 5 do Dispose(Lekcje[I], Done);
    OpenFiles('Data');
    CloseFiles;
    MainWin^.Draw;
  end
  else MessageBox(#3'Zaniechano procesu archiwizacji danych', nil, mfInformation or mfOkButton);
end;

begin

end.
