Program Installator;
uses Dos, Crt, App, Objects, Views, Dialogs, Menus, Pack;

type { typ opisuj•cy gà¢wn• aplikacj© instalatora }
  PMainApp = ^TMainApp;
  TMainApp = object (TApplication)
  private
    FFileName: PStaticText;
  public
    constructor Init;
    procedure InitStatusLine; virtual;
    procedure DoInstall;
  end;

constructor TMainApp.Init;
begin
  inherited Init;
  DoInstall;
end;

procedure TMainApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R); R.A.Y:=R.B.Y-1;
  StatusLine:=New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF, nil, nil)));
end;

procedure NewStaticText(D: PDialog; X, Y, SX: Integer; S: String);
var
  R: TRect;
  T: PStaticText;
begin
  if D=nil then Exit;
  R.Assign(X, Y, X+SX, Y+1);
  New(T, Init(R, S));
  D^.Insert(T);
end;

procedure NewButton(D: PDialog; X, Y, SX: Integer; L: String; Cmd: Word; Opt: Word);
var
  R: TRect;
  B: PButton;
begin
  R.Assign(X, Y, X+SX, Y+2);
  New(B, Init(R, L, Cmd, Opt));
  D^.Insert(B);
end;

procedure NewDialog(var D: PDialog; Sx, Sy: Integer; Title: String);
var
  R: TRect;
begin
  R.Assign(0, 0, Sx, Sy);
  New(D, Init(R, Title));
  D^.Options:=D^.Options or ofCentered;
end;

procedure InstallFile(DestPath: String; FileName: String);
var
  D: PDialog;
  T: String;
  B: array[1..4096] of Byte;
  F1, F2: File;
  NumRead, NumWritten: Integer;
  I: Integer;
begin
  NewDialog(D, 50, 7, 'Instalowanie plik¢w');
  NewStaticText(D, 2, 3, D^.Size.X-4, #3'Plik docelowy: '+FileName);
  Application^.InsertWindow(D);
  T:=FExpand(Copy(FileName, 1, Length(FileName)-3)+'INS');
  Assign(F1, T);
  {$I-} Reset(F1, 1); {$I+}
  if IOResult<>0 then
  begin
    asm mov ax, 3; int $10; end;
    Writeln('Problem podczas instalacji ! - skontaktuj si© ze sprzedawc•.');
    Halt(100);
  end;
  Assign(F2, DestPath+'\'+FileName);
  {$I-} Rewrite(F2, 1); {$I+}
  repeat
    BlockRead(F1, B, SizeOf(B), NumRead);
    for I:=1 to 4096 do B[I]:=B[I] xor 47;
    BlockWrite(F2, B, NumRead, NumWritten);
  until (NumRead = 0) or (NumWritten <> NumRead);
  Close(F1); Close(F2);
  Delay(800);
  D^.Close;
end;

procedure TMainApp.DoInstall;
var
  R: TRect;
  D: PDialog;
  I: PInputLine;
  L: PLabel;
  T: PStaticText;
  Data: record
    Drive: String[1];
    Path: String[80];
  end;
  E: Integer;
begin
  NewDialog(D, 50, 11, 'Powitanie');
  NewStaticText(D, 1, 2, D^.Size.X-2, #3'Zapraszamy do instalacji programu');
  NewStaticText(D, 1, 4, D^.Size.X-2, #3'"Plan lekcji" wersja 1.2');
  NewButton(D, 17, 8, 15, '~D~alej', cmOK, bfDefault);

  ExecuteDialog(D, nil);

  NewDialog(D, 60, 18, 'Powitanie');
  NewStaticText(D, 1, 2, D^.Size.X-2, '     Instalator wymaga podania LITERY DYSKU oraz');
  NewStaticText(D, 1, 3, D^.Size.X-2, '   PEùNEJ óCIEΩKI DOST®PU do katalogu, w kt¢rym ma zostaÜ');
  NewStaticText(D, 1, 4, D^.Size.X-2, '   zainstalowany program "Plan lekcji".');
  NewStaticText(D, 1, 6, D^.Size.X-2, 'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ');

  R.Assign(3, 9, 6, 10);
  New(I, Init(R, 1));
  D^.Insert(I);
  R.Assign(2, 8, 15, 9);
  New(L, Init(R, '~L~itera dysku', I));
  D^.Insert(L);
  NewStaticText(D, 6, 9, 2, ':');

  R.Assign(4, 12, 57, 13);
  New(I, Init(R, 80));
  D^.Insert(I);
  R.Assign(2, 11, 30, 12);
  New(L, Init(R, 'ó~c~ieæka dost©pu', I));
  D^.Insert(L);
  NewStaticText(D, 3, 12, 1, '\');

  NewButton(D, 26, 15, 14, '~I~nstaluj', cmOK, bfDefault);
  NewButton(D, 42, 15, 14, '~A~nuluj', cmCancel, bfNormal);

  D^.SelectNext(False);

  Data.Drive:='C';
  Data.Path:='PLAN';

  if ExecuteDialog(D, @Data)=cmOK then
  begin
    {$I-}
    MkDir(Data.Drive+':\'+Data.Path);
    E:=IOResult;
    MkDir(Data.Drive+':\'+Data.Path+'\DATA');
    E:=IOResult;
    MkDir(Data.Drive+':\'+Data.Path+'\INTRO');
    E:=IOResult;
    {$I+}

    InstallFile(Data.Drive+':\'+Data.Path, 'PLAN.EXE');
    InstallFile(Data.Drive+':\'+Data.Path, 'PL.EXE');
    InstallFile(Data.Drive+':\'+Data.Path, 'START.BAT');
    InstallFile(Data.Drive+':\'+Data.Path+'\DATA', 'DZWONKI.DAT');
    InstallFile(Data.Drive+':\'+Data.Path+'\DATA', 'KLASY.DAT');
    InstallFile(Data.Drive+':\'+Data.Path+'\DATA', 'LEKCJE.DAT');
    InstallFile(Data.Drive+':\'+Data.Path+'\DATA', 'NAUCZ.DAT');
    InstallFile(Data.Drive+':\'+Data.Path+'\DATA', 'PRZEDM.DAT');
    InstallFile(Data.Drive+':\'+Data.Path+'\DATA', 'SALE.DAT');

    InstallFile(Data.Drive+':\'+Data.Path, 'INTRO.EXE');
    InstallFile(Data.Drive+':\'+Data.Path+'\INTRO', 'PLAN1.BMP');
    InstallFile(Data.Drive+':\'+Data.Path+'\INTRO', 'PROD2.BMP');
    InstallFile(Data.Drive+':\'+Data.Path+'\INTRO', 'GRAND1.BMP');
    InstallFile(Data.Drive+':\'+Data.Path+'\INTRO', 'AUTOR1.BMP');
    InstallFile(Data.Drive+':\'+Data.Path+'\INTRO', 'BLANK1.BMP');

    NewDialog(D, 50, 11, 'Informacja');
    NewStaticText(D, 1, 2, D^.Size.X-2, #3'Instalacja zako‰czona pomyòlnie');
    NewStaticText(D, 1, 4, D^.Size.X-2, #3'naciònij [ENTER] aby zako‰czyÜ');
    NewStaticText(D, 1, 5, D^.Size.X-2, #3'prac© instalatora');
    NewButton(D, 18, 8, 14, '~K~oniec', cmOK, bfDefault);
    ExecuteDialog(D, nil);
  end
  else
  begin
    NewDialog(D, 50, 10, 'Przerwanie');
    NewStaticText(D, 1, 2, D^.Size.X-2, #3'Instalacja programu zostaàa przerwana.');
    NewStaticText(D, 1, 4, D^.Size.X-2, #3'Zapraszam ponownie.');
    NewButton(D, 18, 7, 14, '~K~oniec', cmOK, bfDefault);
    ExecuteDialog(D, nil);
  end;
end;

var
  Install: TMainApp;

begin
  Install.Init;
  Install.Done;
end.
