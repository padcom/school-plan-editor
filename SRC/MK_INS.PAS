Program MakeInstallFiles;
uses Crt;

function Compress(Infile, Outfile: String; Overwrite: Boolean): Byte;
var
  F1, F2: File;
  B: array[1..4096] of Byte;
  NumRead, NumWritten: Integer;
  I: Integer;
begin
  Assign(F1, Infile); {$I-} Reset(F1, 1); {$I+}
  if IOResult=0 then Compress:=0 else Compress:=1;
  Assign(F2, Outfile); Rewrite(F2, 1);

  repeat
    BlockRead(F1, B, SizeOf(B), NumRead);
    BlockWrite(F2, B, NumRead, NumWritten);
  until (NumRead = 0) or (NumWritten <> NumRead);

  Close(F1); Close(F2);
end;

var
  S: String;

begin
  ClrScr;
  Writeln('Install maker for SZKOùA 1.2 - (C) by Maicej Hryniszak in 1999');
  Writeln;

  Write('PLAN.EXE ... ');
  if Compress('c:\develop\output\plan.exe', 'c:\szkola\install\plan.ins', True)=0 then Writeln('Done.')
  else Writeln('Error while processing file PLAN.EXE');

  Write('START.BAT ... ');
  if Compress('c:\szkola\start.bat', 'c:\szkola\install\start.ins', True)=0 then Writeln('Done.')
  else Writeln('Error while processing file START.BAT');

  Write('PL.EXE ... ');
  if Compress('c:\szkola\pl.exe', 'c:\szkola\install\pl.ins', True)=0 then Writeln('Done.')
  else Writeln('Error while processing file PL.EXE');

  Write('INTRO.EXE ... ');
  if Compress('c:\szkola\intro.exe', 'c:\szkola\install\intro.ins', True)=0 then Writeln('Done.')
  else Writeln('Error while processing file INTRO.EXE');

  Write('DATA\DZWONKI.DAT ... ');
  if Compress('c:\szkola\data\dzwonki.dat', 'c:\szkola\install\dzwonki.ins', True)=0 then Writeln('Done.')
  else Writeln('Error while processing file DZWONKI.DAT');

  Write('INTRO\PLAN1.BMP ... ');
  if Compress('c:\szkola\intro\plan1.bmp', 'c:\szkola\install\plan1.ins', True)=0 then Writeln('Done.')
  else Writeln('Error while processing file PLAN1.BMP');

  Write('INTRO\PROD2.BMP ... ');
  if Compress('c:\szkola\intro\prod2.bmp', 'c:\szkola\install\prod2.ins', True)=0 then Writeln('Done.')
  else Writeln('Error while processing file PROD2.BMP');

  Write('INTRO\GRAND1.BMP ... ');
  if Compress('c:\szkola\intro\grand1.bmp', 'c:\szkola\install\grand1.ins', True)=0 then Writeln('Done.')
  else Writeln('Error while processing file GRAND1.BMP');

  Write('INTRO\AUTOR1.BMP ... ');
  if Compress('c:\szkola\intro\autor1.bmp', 'c:\szkola\install\autor1.ins', True)=0 then Writeln('Done.')
  else Writeln('Error while processing file AUTOR1.BMP');

  Write('INTRO\BLANK1.BMP ... ');
  if Compress('c:\szkola\intro\blank1.bmp', 'c:\szkola\install\blank1.ins', True)=0 then Writeln('Done.')
  else Writeln('Error while processing file BLANK1.BMP');

  S:='c:\szkola\src\help\';
  Write('help files ...');
  Compress(S+'4096.txt', 'c:\szkola\install\4096.ins', True);
  Compress(S+'4113.txt', 'c:\szkola\install\4113.ins', True);
  Compress(S+'4114.txt', 'c:\szkola\install\4114.ins', True);
  Compress(S+'4115.txt', 'c:\szkola\install\4115.ins', True);
  Compress(S+'4129.txt', 'c:\szkola\install\4129.ins', True);
  Compress(S+'4130.txt', 'c:\szkola\install\4130.ins', True);
  Compress(S+'4131.txt', 'c:\szkola\install\4131.ins', True);
  Compress(S+'4145.txt', 'c:\szkola\install\4145.ins', True);
  Compress(S+'4146.txt', 'c:\szkola\install\4146.ins', True);
  Compress(S+'4147.txt', 'c:\szkola\install\4147.ins', True);
  Compress(S+'4161.txt', 'c:\szkola\install\4161.ins', True);
  Compress(S+'4162.txt', 'c:\szkola\install\4162.ins', True);
  Compress(S+'4163.txt', 'c:\szkola\install\4163.ins', True);
  Compress(S+'4177.txt', 'c:\szkola\install\4177.ins', True);
  Compress(S+'4178.txt', 'c:\szkola\install\4178.ins', True);
  Compress(S+'4179.txt', 'c:\szkola\install\4179.ins', True);
  Compress(S+'4353.txt', 'c:\szkola\install\4353.ins', True);
  Compress(S+'4354.txt', 'c:\szkola\install\4354.ins', True);
  Compress(S+'8194.txt', 'c:\szkola\install\8194.ins', True);
  Writeln('Done.');
  Writeln;
  Writeln('All done !');
end.
