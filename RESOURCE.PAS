Unit Resource;

interface
uses
  Strings, Objects, Drivers, Memory, Views, Menus, Dialogs, StdDlg, MsgBox,
  TextView, Colorsel, Editors, App, Validate, Outline,
  DataObjects, DataDialogs,
  Nauczyciel, Przedmiot, Klasa, Sala, Dzwonek, Lekcja,
  Help, HostWin, MainWin, SpecWins, Statystyka;

var
  ResourceFile: TResourceFile;

const
  { staˆa mianowana determinuj¥ca, czy aktualnie jest tworzony plik zasob¢w }
  CreatingResources: Boolean = False;

{ stworzenie nowego pliku zasob¢w }
procedure CreateResources(FileName: String);
{ otwarcie istniej¥cego pliku zasob¢w }
procedure OpenResources(FileName: String);
{ zamkni©cie pliku zasob¢w }
procedure CloseResources;
{ procedura wypisuj¥ca nazwy wszystkich obiekt¢w w pliku zasob¢w }
procedure DumpNames;
{ rozpocz©cie tworzenia nowego obiektu w pliku zasob¢w }
procedure BeginCreating(AObjectName: String);
{ zapisanie do pliku zasob¢w i zakoäczenie tworzenia obiektu }
procedure StoreObject(Data: PObject);
{ funkcja sprawdzaj¥ca poprawno˜† wczytania obiektu z pliku zasob¢w }
function LoadSuccessful(Data: PObject): Boolean;

{ procedura do testowania okienek dialogowych }
procedure TestDialog(D: PDialog);

implementation
uses Crt;

var
  ObjectName: String;

procedure RegisterTypes;
begin
  Write('Registering data types ... ');
  RegisterApp;
  RegisterObjects;
  RegisterViews;
  RegisterDialogs;
  RegisterMenus;
  RegisterEditors;
  RegisterStdDlg;
  RegisterColorSel;
  RegisterValidate;
  RegisterOutLine;

  RegisterDataObjects;
  RegisterDataDialogs;
  RegisterNauczyciel;
  RegisterPrzedmiot;
  RegisterKlasa;
  RegisterSala;
  RegisterDzwonek;
  RegisterLekcja;
  RegisterHelp;
  RegisterMainWin;
  RegisterSpecWins;
  RegisterHostWin;
  RegisterStatystyka;
  Writeln('OK.');
end;

procedure CreateResources;
begin
  CreatingResources:=True;
  asm mov ax, 3; int $10; end;
  RegisterTypes;
  RegisterType(RStrListMaker);

  Write('Creating and initializing resource file ... ');
  ResourceFile.Init(New(PBufStream, Init(FileName, stCreate, 1024)));
  if ResourceFile.Stream^.Status<>stOK then
  begin
    Writeln('ERROR !');
    Halt(1);
  end
  else Writeln('OK.');
  Writeln;
end;

procedure OpenResources;
begin
  asm mov ax, 3; int $10; end;
  RegisterTypes;
  RegisterType(RStringList);

  Write('Opening and initializing resource file ... ');
  ResourceFile.Init(New(PBufStream, Init(FileName, stOpenRead, 1024)));
  if ResourceFile.Stream^.Status<>stOK then
  begin
    Writeln('ERROR !');
    Halt(1);
  end
  else Writeln('OK.');
  Writeln;
end;

procedure CloseResources;
begin
  Writeln;
  Write('Closing resource file ... ');
  ResourceFile.Done;
  Writeln('OK.');
  Writeln('All done.');
end;

procedure DumpNames;
var
  I: Integer;
begin
  Writeln;
  Writeln('*** Begin of resources list ***');
  for I:=0 to ResourceFile.Count-1 do
    Writeln(ResourceFile.KeyAt(I));
  Writeln('*** End of resources list ***');
end;

procedure BeginCreating;
begin
  ObjectName:=AObjectName;
  Write('Creating ', ObjectName, ' ... ');
end;

procedure StoreObject;
begin
  Write('storing ... ');
  ResourceFile.Put(Data, ObjectName);
  if ResourceFile.Stream^.Status<>stOK then
  begin
    Writeln('ERROR ! (', ResourceFile.Stream^.Status, ', ',ResourceFile.Stream^.ErrorInfo,')');
    Halt(2);
  end
  else Writeln('OK.');
end;

function LoadSuccessful;
begin
  if Assigned(Data) then LoadSuccessful:=True
  else
  begin
    MessageBox(#3'Bˆ¥d podczas ˆadowania zasob¢w !'+
               #13#3'Nale¾y ponownie zainstalowa† program.', nil, mfError or mfCancelButton);
    LoadSuccessful:=False;
  end;
end;

{ procedura do testowania okienek dialogowych }

procedure TestDialog;
var
  Test: TApplication;
  P: Pointer;
  I: Integer;
  OldX, OldY: Integer;
begin
  GetMem(P, 4000);
  for I:=0 to 3999 do Mem[Seg(P^):Ofs(P^)+I]:=Mem[SegB800:I];
  OldX:=WhereX; OldY:=WhereY;
  Test.Init;
  Test.ExecuteDialog(D, nil);
  Test.Done;
  for I:=0 to 3999 do Mem[SegB800:I]:=Mem[Seg(P^):Ofs(P^)+I];
  GotoXY(OldX, OldY);
  FreeMem(P, 4000);
end;

begin
end.
