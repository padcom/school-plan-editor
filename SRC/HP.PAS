Unit HP;

interface

type
  PFontsDefinition = ^TFontsDefinition;
  TFontsDefinition = array[0..255, 0..31] of Byte;

var
  HP_Lst: Text;

procedure LoadFonts(Def: PFontsDefinition; FileName: String);
procedure GetCurrentFonts(Def: PFontsDefinition);
procedure BeginDoc(PortNum: Byte; DPI: Integer; LeftMargin: Integer);
procedure EndDoc;
procedure PrintLine(Fonts: PFontsDefinition; LineData: String);
procedure ChangeResolution(NewDPI: Integer);

implementation
uses
  DOS;

{ definicja i inicjalizacja pliku zapisu do drukarki }

{$F+}
function LSTNoFunction(var F: TextRec): Integer;
begin
   LSTNoFunction := 0;
end;

function LSTOutPutToPrinter(var F: TextRec): Integer;
var
  Regs: Registers;
  P: Word;
begin
  with F do
  begin
    P:=0;
    Regs.AH:=16;
    while (P<BufPos) and ((Regs.AH and 16)=16) do
    begin
      Regs.AL:=Ord(BufPtr^[P]);
      Regs.AH:=0;
      Regs.DX:=UserData[1];
      Intr($17, Regs);
      Inc(P);
    end;
    BufPos:=0;
  end;
  if ((Regs.AH and 16)=16) then LstOutPutToPrinter:=0         { No Error           }
  else if ((Regs.AH and 32)=32) then LSTOutPutToPrinter:=159  { Out of Paper       }
  else LSTOutPutToPrinter:=160;                               { Device Write Fault }
end;
{$F-}

procedure AssignLST(Port: Byte);
begin
  with TextRec(HP_Lst) Do
  begin
    Handle:=$FFF0;
    Mode:=fmOutput;
    BufSize:=SizeOf( Buffer );
    BufPtr:=@Buffer;
    BufPos:=0;
    OpenFunc:=@LSTNoFunction;
    InOutFunc:=@LSTOutPutToPrinter;
    FlushFunc:=@LSTOutPutToPrinter;
    CloseFunc:=@LSTOutPutToPrinter;
    UserData[1]:=Port-1;
  end;
end;

{ ciaˆo unitu }

procedure LoadFonts;
var
  F: File;
begin
  {$I-};
  if not Assigned(Def) then Exit;
  Assign(F, FileName);
  Reset(F, 1);
  if IOResult<>0 then Exit;
  BlockRead(F, Def^, SizeOf(TFontsDefinition));
  Close(F);
  {$I+}
end;

procedure GetCurrentFonts;
var
  C, Y: Integer;
begin
  if not Assigned(Def) then Exit;

  { inicjalizacja pami©ci ekranu tak, aby wskazywaˆa na definicj© znak¢w }
  Port[$3C4]:=0; Port[$3C5]:=1;
  Port[$3C4]:=2; Port[$3C5]:=4;
  Port[$3C4]:=4; Port[$3C5]:=7;
  Port[$3C4]:=0; Port[$3C5]:=3;
  Port[$3CE]:=4; Port[$3CF]:=2;
  Port[$3CE]:=5; Port[$3CF]:=0;
  Port[$3CE]:=6; Port[$3CF]:=0;

  { odczyt definicji znak¢w }
  for C:=0 to 255 do for Y:=0 to 31 do Def^[C, Y]:=Mem[SegA000:C*32+Y];

  { powr¢t do normalnej reprezentacji pami©ci ekranu }
  Port[$3C4]:=0; Port[$3C5]:=1;
  Port[$3C4]:=2; Port[$3C5]:=3;
  Port[$3C4]:=4; Port[$3C5]:=3;
  Port[$3C4]:=0; Port[$3C5]:=3;
  Port[$3CE]:=4; Port[$3CF]:=0;
  Port[$3CE]:=5; Port[$3CF]:=16;
  Port[$3CE]:=6; Port[$3CF]:=14;
end;

procedure BeginDoc(PortNum: Byte; DPI: Integer; LeftMargin: Integer);
var
  sDPI: String;
  sLeftMargin: String;
begin
  {$I-}
  AssignLST(PortNum);
  Str(DPI, sDPI);
  Str(LeftMargin, sLeftMargin);
  Write(HP_Lst, #27+'E');                   { inicjalizacja drukarki }
  Write(HP_Lst, #27+'*t'+sDPI+'R');         { ustawienie rozdzielczo˜ci }
  Write(HP_Lst, #27+'&a'+sLeftMargin+'C');  { ustawienie lewego marginesu }
  Write(HP_Lst, #27+'*r1A');                { rozpocz©cie grafiki rastrowej }
  {$I+}
end;

procedure EndDoc;
begin
  {$I-}
  Write(HP_Lst, #27+'*rB');                 { zakoäczenie grafiki rastrowej }
  Write(HP_Lst, #27+'E');                   { zakoäczenie drukowania i wys¢w papieru }
  Flush(HP_Lst);
  Close(HP_Lst);
  {$I+}
end;

procedure PrintLine;
var
  sLineLength: String;
  sLineHeader: String;
  sLineData: String;
  I, Y: Integer;
begin
  {$I-}
  if LineData='' then LineData:=' ';
  FillChar(sLineLength, SizeOf(sLineLength), 0);
  FillChar(sLineHeader, SizeOf(sLineHeader), 0);
  FillChar(sLineData, SizeOf(sLineData), 0);

  Str(Length(LineData)+1, sLineLength);
  sLineHeader:=#27'*b'+sLineLength+'W';

  for Y:=0 to 16 do
  begin
    sLineData:=sLineHeader;
    for I:=1 to Length(LineData) do sLineData:=sLineData+Chr(Fonts^[Ord(LineData[I]), Y]);
    sLineData:=sLineData+#0;
    Write(HP_Lst, sLineData);
  end;
  {$I+}
end;

procedure ChangeResolution;
var
  sDPI: String;
begin
  {$I-}
  Str(NewDPI, sDPI);
  Write(HP_Lst, #27+'*rB');                 { zakoäczenie grafiki rastrowej }
  Write(HP_Lst, #27+'*t'+sDPI+'R');         { ustawienie rozdzielczo˜ci }
  Write(HP_Lst, #27+'*r1A');                { rozpocz©cie grafiki rastrowej }
  {$I+}
end;

begin
end.
