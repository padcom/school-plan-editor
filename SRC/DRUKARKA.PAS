Unit Drukarka;

interface

procedure PrintFile(FileName: String);

implementation

function PlToPrinter(C: Char): string;
var
  S: String;
begin
  case C of
    '•': S:='a'+#8+',';
    'Ü': S:='c'+#8+'''';
    '©': S:='e'+#8+',';
    'à': S:='l'+#8+'/';
    '¢': S:='o'+#8+'''';
    '‰': S:='n'+#8+'''';
    'ò': S:='s'+#8+'''';
    '´': S:='z'+#8+'''';
    'æ': S:='z'+#8+'-';

    '§': S:='A'+#8+',';
    'è': S:='C'+#8+'''';
    '®': S:='E'+#8+',';
    'ù': S:='L'+#8+'/';
    '‡': S:='O'+#8+'''';
    '„': S:='N'+#8+'''';
    'ó': S:='S'+#8+'''';
    'ç': S:='X'+#8+'''';
    'Ω': S:='Z'+#8+'-'
    else S:=C;
  end;
  PlToPrinter:=S;
end;

procedure PrintFile;
var
  F, D: Text;
  S1, S2: String;
  I: Integer;
begin
  Assign(F, FileName);
  Reset(F);
  Assign(D, 'LPT1');
  Rewrite(D);

{$I-}
  while not EOF(F) do
  begin
    Readln(F, S1);
    S2:='';
    if S1<>'' then for I:=1 to Length(S1) do S2:=S2+PlToPrinter(S1[I]);
    Writeln(D, S2);
    if IOResult<>0 then
    begin
      Close(F);
      Close(D);
      Exit;
    end;
  end;

  Close(F);
  Write(D, #12);
  Close(D);
{$I+}
end;

begin
end.
