Unit Latin2;

interface

const { Staàe definuj•ca kody polskich liter (standard LATIN-2) }
  DuzeLitery = 'A§BCèDE®FGHIJKLùMN„O‡PQRSóTUVWXYZçΩ';
  MaleLitery = 'a•bcÜde©fghijklàmn‰o¢pqrsòtuvwxyz´æ';
  Litery     = DuzeLitery + MaleLitery;
  Cyfry      = '0123456789+-';
  Znaki      = Cyfry+Litery+'!@"#$%^&*()''`{}[];:,<.>~|\/?= ';

{ funkcja por¢wnuj•ca dwa ci•gi znak¢w }
function CompareStr(S1, S2: String; CaseSensitive: Boolean): Integer;
{ funkcja zamieniaj•ca zadany znak na duæ• liter© }
function UpCase(C: Char): Char;
{ funkcja zamieniaj•ca zadany ci•g znak¢w na duæe litery }
function UpStr(S: String): String;
{ funkcja zamieniaj•ca zadany znak na maà• liter© }
function LowCase(C: Char): Char;
{ funkcja zwracaj•ca àa‰cuch zamieniony na maàe litery }
function LowStr(S: String): String;
{ funkcja zwracaj•ca lustrzane odbicie zadanego ci•gu znak¢w }
function InvertStr(S: String): String;
{ funkcja usuwaj•ca z zadanego ci•gu znak¢w wszystkie spacje }
function RemoveSpaces(S: String): String;
{ funkcja obcinaj•ca spacje ko‰cz•ce àa‰cuch }
function CutEndingSpaces(S: String): String;
{ funkcja zwracaj•ca ci•g znak¢w zàoæonych z N spacji }
function SpaceStr(N: Byte): String;
{ funkcja zwracaj•ca ci•g znak¢w zàoæonych z N ci•g¢w C }
function RepeatStr(C: String; N: Byte): String;

implementation

function CompareStr;
var
  I, T1, T2: Byte;
  L, Result: Integer;
begin
  L:=Length(S1); If Length(S2)<L then L:=Length(S2);
  If not CaseSensitive then
  begin
    S1:=UpStr(S1);
    S2:=UpStr(S2);
  end;

  I:=1; Result:=0;
  while (I<=L) and (Result=0) do
  begin
    T1:=Pos(S1[I], Znaki);
    T2:=Pos(S2[I], Znaki);
    if (T1>0) and (T2>0) then
    begin
      if T1<T2 then Result:=-1
      else if T1>T2 then Result:=1
      else Inc(I);
    end
    else if (T1=0) and (T2>0) then Result:=-1
    else if (T1>0) and (T2=0) then Result:=1
  end;
  if (Result=0) and (Length(S1)<Length(S2)) then Result:=-1
  else if (Result=0) and (Length(S1)>Length(S2)) then Result:=1;

  CompareStr:=Result;
End; { CompareStr }

function UpCase(C: Char): Char;
begin
  if C='•' then UpCase:='§'
  else if C='Ü' then UpCase:='è'
  else if C='©' then UpCase:='®'
  else if C='à' then UpCase:='ù'
  else if C='‰' then UpCase:='„'
  else if C='¢' then UpCase:='‡'
  else if C='ò' then UpCase:='ó'
  else if C='´' then UpCase:='ç'
  else if C='æ' then UpCase:='Ω'
  else if C in ['a'..'z'] then UpCase:=Chr(Ord(C) and (not 32))
  else UpCase:=C;
end; { UpCase }

function UpStr(S: String): String;
var
  I: Byte;
begin
  if S='' then UpStr:=''
  else
  begin
    for I:=1 to Length(S) do S[I]:=UpCase(S[I]);
    UpStr:=S;
  end;
end; { UpStr }

function LowCase(C: Char): Char;
begin
  if C='§' then LowCase:='•'
  else if C='è' then LowCase:='Ü'
  else if C='®' then LowCase:='©'
  else if C='ù' then LowCase:='à'
  else if C='„' then LowCase:='‰'
  else if C='‡' then LowCase:='¢'
  else if C='ó' then LowCase:='ò'
  else if C='ç' then LowCase:='´'
  else if C='Ω' then LowCase:='æ'
  else if C in ['A'..'Z'] then LowCase:=Chr(Ord(C) or 32)
  else LowCase:=C;
end; { LowCase }

function LowStr(S: String): String;
var
  I: Byte;
begin
  if S='' then LowStr:=''
  else
  begin
    for I:=1 to Length(S) do S[I]:=UpCase(S[I]);
    LowStr:=S;
  end;
End; { LowStr }

function InvertStr(S: String): String;
var
  I: Byte;
  T: String;
begin
  if S='' then InvertStr:=''
  else
  begin
    T:='';
    for I:=1 to Length(S) do T:=T+S[Length(S)-I+1];
    InvertStr:=T;
  end;
end; { InvertStr }

function RemoveSpaces(S: String): String;
var
  I: Byte;
  T: String;
begin
  if S='' then RemoveSpaces:=''
  else
  begin
    T:='';
    for I:=1 to Length(S) do If S[I]<>' ' then T:=T+S[I];
    RemoveSpaces:=T;
  end;
end; { RemoveSpaces }

function CutEndingSpaces(S: String): String;
var
  I: Byte;
  T: String;
begin
  if S='' then CutEndingSpaces:=''
  else
  begin
    T:='';
    for I:=Length(S) downto 1 do If S[I]<>' ' then Break;
    if I>1 then CutEndingSpaces:=Copy(T, 1, I)
    else if (I=1) and (S[1]<>' ') then CutEndingSpaces:=S[I]
    else CutEndingSpaces:='';
  end;
end; { CutEndingSpaces }

function SpaceStr(N: Byte): String;
var
  I: Integer;
  T: String;
begin
  if N=0 then SpaceStr:=''
  else
  begin
    T:='';
    for I:=1 to N do T:=T+' ';
    SpaceStr:=T;
  end;
end; { SpaceStr }

function RepeatStr;
var
  S: String;
  I: Integer;
begin
  if N=0 then RepeatStr:=''
  else
  begin
    S:='';
    for I:=1 to N do S:=S+C;
    RepeatStr:=S;
  end;
end; { RepeatStr }

end.
