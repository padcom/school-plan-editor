Unit Pack;

interface

type { Typ opisuj¥cy procedur© wykonywan¥ podczas kompresji/dekompresji danych }
  TProgressProc = procedure (ActualPos, TotalLength: LongInt; State: Byte);

const { Staˆa mianowana definiuj¥ca standardow¥ procedur© wykonywan¥ podczas kompresji/dekompresji danych }
  ProgressProc: TProgressProc = nil;

const { Staˆe definiuj¥ce bˆ©dy podczas kompresji/dekompresji plik¢w }
  erOK                            = 0;
  erErrorOpeningSourceFile        = 1;
  erErrorCreatingDestionationFile = 2;

  { Podstawowe procedury: kompresuj¥ca i dekompresuj¥ca }
function Compress(OriginalFileName, PackedFileName: String; Overwrite: Boolean): Byte;
function Decompress(PackedFileName, OriginalFileName: String; Overwrite: Boolean): Byte;

  { Dodatkowe procedury i funkcje operuj¥ce na plikach i ich nazwach }
function FileExist(FileName: String): Boolean;

implementation
uses Objects, Streams, Huffman, Dos;

var
  CopyBuffer: Array[0..4095] of Byte;
  ReadCount : Word;

function Compress(OriginalFileName, PackedFileName: String; Overwrite: Boolean): Byte;
var
  Source      : PBufStream;
  Destionation: PHuffmanFilter;
  SourceSize  : LongInt;
  Position    : LongInt;
  Temp        : LongInt;
begin
  { Sprawdzanie poprawno˜ci podanej nazwy orginalnego pliku }
{  if (OriginalFileName='') or (not FileExist(OriginalFileName)) then
  begin
    Compress:=erErrorOpeningSourceFile;
    Exit;
  end;
}
  { Sprawdzanie poprawno˜ci podanej nazwy skompresowanego pliku }
{
  if PackedFileName='' then PackedFileName:='_'+OriginalFileName;
  if FileExist(PackedFileName) and (not Overwrite) then
  begin
    Compress:=erErrorCreatingDestionationFile;
    Exit;
  end;
}
  { Otwarcie orinalnego pliku }
  Source:=New(PBufStream, Init(OriginalFileName, stOpenRead, 2048));

  { Sprawdzenie poprawno˜ci otwarcia orginalnego pliku }
  if not Assigned(Source) then
  begin
    Compress:=erErrorOpeningSourceFile;
    Exit;
  end
  else if Source^.Status<>stOK then
  begin
    Compress:=erErrorOpeningSourceFile;
    Dispose(Source, Done);
    Exit;
  end;

  { Utworzenie skompresowanego pliku }
  Destionation:=New(PHuffmanFilter, Init(New(PBufStream, Init(PackedFileName, stCreate, 2048))));

  { Sprawdzenie poprawno˜ci utworzenia skompresowanego pliku }
  if not Assigned(Destionation) then
  begin
    Compress:=erErrorCreatingDestionationFile;
    Exit;
  end
  else if Destionation^.Status<>stOK then
  begin
    Compress:=erErrorCreatingDestionationFile;
    Dispose(Destionation, Done);
    Exit;
  end;

  { Inicjalizacja zmiennych wyko¾ystanych podczas kompresji danych }
  SourceSize:=Source^.GetSize;
  Position:=0;
  ReadCount:=SizeOf(CopyBuffer);

  { Tworzenie kodu kompresuj¥cego }
  if Assigned(ProgressProc) then ProgressProc(Position, SourceSize, 1);
  Destionation^.Write(SourceSize,Sizeof(SourceSize));
  FastCopy(Source^, Destionation^, SourceSize);
  Source^.Seek(0);
  With Destionation^ do
  begin
    Seek(0);
    BuildCode;
    StoreCode;
    Learning:=False;
    Write(SourceSize,Sizeof(SourceSize));
  end;

  Temp:=65535;
  { P©tla kompresuj¥ca }
  while Temp<>0 do
  begin
    Temp:=SourceSize-Position;
    if Temp=0 then Continue;
    if Temp<ReadCount then ReadCount:=Temp;
    if Assigned(ProgressProc) then ProgressProc(Position, SourceSize, 2);
    Source^.Read(CopyBuffer, ReadCount);
    Destionation^.Write(CopyBuffer, ReadCount);
    Position:=Source^.GetPos;
  end;

  if Assigned(ProgressProc) then ProgressProc(Position, SourceSize, 3);
  Dispose(Source, Done);
  Destionation^.Flush;
  Dispose(Destionation, Done);
  Compress:=erOK;
end;

function Decompress(PackedFileName, OriginalFileName: String; Overwrite: Boolean): Byte;
var
  Source      : PHuffmanFilter;
  Destionation: PBufStream;
  SourceSize  : LongInt;
  Position    : LongInt;
  Temp        : LongInt;
begin
{  PackedFileName:=FExpand(PackedFileName);}
  { Sprawdzanie poprawno˜ci podanej nazwy orginalnego pliku }
{  if (PackedFileName='') or (not FileExist(PackedFileName)) then
  begin
    Decompress:=erErrorOpeningSourceFile;
    Exit;
  end;
}
  { Sprawdzanie poprawno˜ci podanej nazwy skompresowanego pliku }
{  if OriginalFileName='' then OriginalFileName:='_'+PackedFileName;
  if FileExist(OriginalFileName) and (not Overwrite) then
  begin
    Decompress:=erErrorCreatingDestionationFile;
    Exit;
  end;
}
  { Otwarcie skompersowanego pliku }
  Source:=New(PHuffmanFilter, Init(New(PBufStream, Init(PackedFileName, stOpenRead, 2048))));

  { Sprawdzenie poprawno˜ci otwarcia skompresowanego pliku }
  if not Assigned(Source) then
  begin
    Decompress:=erErrorOpeningSourceFile;
    Exit;
  end
  else if Source^.Status<>stOK then
  begin
    Decompress:=erErrorOpeningSourceFile;
    Dispose(Source, Done);
    Exit;
  end;

  { Utworzenie docelowego pliku }
  Destionation:=New(PBufStream, Init(OriginalFileName, stCreate, 2048));

  { Sprawdzenie poprawno˜ci utworzenia docelowego pliku }
  if not Assigned(Destionation) then
  begin
    Decompress:=erErrorCreatingDestionationFile;
    Exit;
  end
  else if Destionation^.Status<>stOK then
  begin
    Decompress:=erErrorCreatingDestionationFile;
    Dispose(Destionation, Done);
    Exit;
  end;

  { Inicjalizacja zmiennych wyko¾ystanych podczas kompresji danych }
  with Source^ do
  begin
    LoadCode;
    Learning:=False;
    Read(SourceSize,Sizeof(SourceSize));
  end;
  Position:=0;
  ReadCount:=SizeOf(CopyBuffer);
  Temp:=65535;

  { P©tla dekompresuj¥ca }
  while Temp>0 do
  begin
    Temp:=SourceSize-Position;
    if Temp<=0 then Continue;
    if Temp<ReadCount then ReadCount:=Temp;
    if Assigned(ProgressProc) then ProgressProc(Position, SourceSize, 2);
    Source^.Read(CopyBuffer, ReadCount);
    Destionation^.Write(CopyBuffer, ReadCount);
    Position:=Source^.GetPos;
  end;

  if Assigned(ProgressProc) then ProgressProc(Position, SourceSize, 3);
  Dispose(Source, Done);
  Destionation^.Flush;
  Dispose(Destionation, Done);
  Decompress:=erOK;
end;

function FileExist(FileName: String): Boolean;
var
  F: File;
begin
  Assign(F, FileName);
  {$I-} Reset(F, 1); {$I+}
  if IOResult=0 then
  begin
    Close(F);
    FileExist:=True;
  end
  else FileExist:=False;
end;


begin

end.
