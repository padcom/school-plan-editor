Unit Latin2;

Interface

Const { Staàe definuj•ca kody polskich liter (standard LATIN-2) }
  DuzeLitery = 'A§BCèDE®FGHIJKLùMN„O‡PQRSóTUVWXYZçΩ';
  MaleLitery = 'a•bcÜde©fghijklàmn‰o¢pqrsòtuvwxyz´æ';
  Litery     = DuzeLitery + MaleLitery;
  Cyfry      = '0123456789+-';
  Znaki      = Cyfry+Litery+'!@"#$%^&*()''`{}[];:,<.>~|\/?= ';

Function CompareStr(S1, S2: String; CaseSensitive: Boolean): Integer;
Function UpCase(C: Char): Char;
Function UpStr(S: String): String;
Function LowCase(C: Char): Char;
Function LowStr(S: String): String;
Function InvertStr(S: String): String;
Function RemoveSpaces(S: String): String;
Function CutEndingSpaces(S: String): String;
Function SpaceStr(N: Byte): String;
Function RepeatStr(C: String; Repetitons: Byte): String;

Implementation
Uses DOS;

Const { Staàa informuj•ca o stanie zainstalowania polskich znak¢w }
  Installed: Boolean = False;

Const { Staàa przechowuj•ca orginalny wektor przerwa‰ klawiatury }
  OriginalKeyboardISR: Pointer = Nil;

Const { Staàa przechowuj•ca adres orginalnej procedury wyjòciowej }
  OriginalExitProc: Pointer = Nil;

Var { Zmienna absolutna zawieraj•ca adres procedury obsàugi przerwania klaw. }
  IntVec:Pointer Absolute 0:88;

Const { Tablica z danymi o wygl•dzie polskich znak¢w }
  FontShapes:Array[1..18,0..16] of Byte=(
    (164,000,000,016,056,108,198,198,254,198,198,198,198,004,008,000,000),
    (143,004,008,060,102,194,192,192,192,192,194,102,060,000,000,000,000),
    (168,000,000,254,102,098,104,120,104,096,098,102,254,002,004,000,000),
    (157,000,000,240,096,096,100,104,112,096,098,102,254,000,000,000,000),
    (227,016,032,230,230,246,254,222,206,198,198,198,198,000,000,000,000),
    (224,000,002,124,206,214,198,198,198,198,198,198,124,000,000,000,000),
    (151,002,004,124,198,198,096,056,012,006,198,198,124,000,000,000,000),
    (189,000,000,254,198,134,012,126,048,096,194,198,254,000,000,000,000),
    (141,008,016,254,198,134,012,024,048,096,194,198,254,000,000,000,000),
    (165,000,000,000,000,000,120,012,124,204,204,204,118,004,002,000,000),
    (134,000,000,000,004,008,124,198,192,192,192,198,124,000,000,000,000),
    (169,000,000,000,000,000,124,198,254,192,192,198,124,008,004,000,000),
    (136,000,000,056,024,024,028,024,056,024,024,024,060,000,000,000,000),
    (228,000,000,000,004,008,220,102,102,102,102,102,102,000,000,000,000),
    (162,000,000,000,008,016,124,198,198,198,198,198,124,000,000,000,000),
    (152,000,000,000,008,016,124,198,096,056,012,198,124,000,000,000,000),
    (190,000,000,000,016,000,254,204,024,048,096,198,254,000,000,000,000),
    (171,000,000,000,004,008,254,204,024,048,096,198,254,000,000,000,000));

Function CompareStr(S1, S2: String; CaseSensitive: Boolean): Integer;
Var I, T1, T2: Byte;
    L, Result: Integer;
Begin { Funkcja por¢wnuj•ca dwa ci•gi znak¢w }
  L:=Length(S1); If Length(S2)<L then L:=Length(S2);
  If not CaseSensitive then
    Begin
      S1:=UpStr(S1);
      S2:=UpStr(S2);
    End;

  I:=1; Result:=0;
  While (I<=L) and (Result=0) do
    Begin
      T1:=Pos(S1[I], Znaki);
      T2:=Pos(S2[I], Znaki);
      If (T1>0) and (T2>0) then
        Begin
          If T1<T2 then Result:=-1
          else If T1>T2 then Result:=1
          else Inc(I);
        End
      else If (T1=0) and (T2>0) then Result:=-1
      else If (T1>0) and (T2=0) then Result:=1
    End;
  If (Result=0) and (Length(S1)<Length(S2)) then Result:=-1
  else If (Result=0) and (Length(S1)>Length(S2)) then Result:=1;

  CompareStr:=Result;
End; { CompareStr }

Function UpCase(C: Char): Char;
Begin { Procedura zamieniaj•ca zadany znak na duæ• liter© }
  If C='•' then UpCase:='§'
  else If C='Ü' then UpCase:='è'
  else If C='©' then UpCase:='®'
  else If C='à' then UpCase:='ù'
  else If C='‰' then UpCase:='„'
  else If C='¢' then UpCase:='‡'
  else If C='ò' then UpCase:='ó'
  else If C='´' then UpCase:='ç'
  else If C='æ' then UpCase:='Ω'
  else If C in ['a'..'z'] then UpCase:=Chr(Ord(C) and (not 32))
  else UpCase:=C;
End; { UpCase }

Function UpStr(S: String): String;
Var I: Byte;
Begin { Procedura zamieniaj•ca zadany ci•g znak¢w na duæe litery }
  If S='' then UpStr:=''
  else
    Begin
      For I:=1 to Length(S) do S[I]:=UpCase(S[I]);
      UpStr:=S;
    End;
End; { UpStr }

Function LowCase(C: Char): Char;
Begin { Procedura zamieniaj•ca zadany znak na maà• liter© }
  If C='§' then LowCase:='•'
  else If C='è' then LowCase:='Ü'
  else If C='®' then LowCase:='©'
  else If C='ù' then LowCase:='à'
  else If C='„' then LowCase:='‰'
  else If C='‡' then LowCase:='¢'
  else If C='ó' then LowCase:='ò'
  else If C='ç' then LowCase:='´'
  else If C='Ω' then LowCase:='æ'
  else If C in ['A'..'Z'] then LowCase:=Chr(Ord(C) or 32)
  else LowCase:=C;
End; { LowCase }

Function LowStr(S: String): String;
Var I: Byte;
Begin { Procedura zwracaj•ca àa‰cuch zamieniony na maàe litery }
  If S='' then LowStr:=''
  else
    Begin
      For I:=1 to Length(S) do S[I]:=UpCase(S[I]);
      LowStr:=S;
    End;
End; { LowStr }

Function InvertStr(S: String): String;
Var I: Byte;
    T: String;
Begin { Procedura zwracaj•ca lustrzane odbicie zadanego ci•gu znak¢w }
  If S='' then InvertStr:=''
  else
    Begin
      T:='';
      For I:=1 to Length(S) do T:=T+S[Length(S)-I+1];
      InvertStr:=T;
    End;
End; { InvertStr }

Function RemoveSpaces(S: String): String;
Var I: Byte;
    T: String;
Begin { Procedura usuwaj•ca z zadanego ci•gu znak¢w wszystkie spacje }
  If S='' then RemoveSpaces:=''
  else
    Begin
      T:='';
      For I:=1 to Length(S) do If S[I]<>' ' then T:=T+S[I];
      RemoveSpaces:=T;
    End;
End; { RemoveSpaces }

Function CutEndingSpaces(S: String): String;
Var I: Byte;
    T: String;
Begin { Funkcja obcinaj•ca spacje ko‰cz•ce àa‰cuch }
  If S='' then CutEndingSpaces:=''
  else
    Begin
      T:='';
      For I:=Length(S) downto 1 do If S[I]<>' ' then Break;
      If I>1 then CutEndingSpaces:=Copy(T, 1, I)
      else If (I=1) and (S[1]<>' ') then CutEndingSpaces:=S[I]
      else CutEndingSpaces:='';
    End;
End; { CutEndingSpaces }

Function SpaceStr(N: Byte): String;
Var I: Integer;
    T: String;
Begin { Funkcja zwracaj•ca àa‰cuch o zadanej iloòci spacji }
  If N=0 then SpaceStr:=''
  else
    Begin
      T:='';
      For I:=1 to N do T:=T+' ';
      SpaceStr:=T;
    End;
End; { SpaceStr }

Function RepeatStr(C: String; Repetitons: Byte): String;
var
  S: String;
  I: Integer;
begin
  if Repetitons=0 then RepeatStr:=''
  else
  begin
    S:='';
    for I:=1 to Repetitons do S:=S+C;
    RepeatStr:=S;
  end;
end;

  { Procedury prywatne unitu }

Function Shift: Boolean;
Begin { Funkcja zwracaj•ca stan klawisza Shift (lewego lub prawego) }
  Shift:=((Mem[Seg0040:$0017] and $3)<>0);
End; { Shift }

Function CapsLock: Boolean;
Begin { Funkcja zwracaj•ca stan klawisza CapsLock }
  CapsLock:=((Mem[Seg0040:$0017] and $40)<>0);
End; { CapsLock }

{ $F+ }
Procedure Latin2KeyboardISR(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word); Interrupt;
Var R     : Registers;
    Change: Boolean;
    P     : Pointer;
Begin { Zmodyfikowana procedura obsàugi klawiatury }
  Change:=(Hi(AX)=0) or (Hi(AX)=$10);
  InLine($FA); P:=IntVec; IntVec:=OriginalKeyboardISR; InLine($FB);
  R.AX:=AX; R.BX:=BX;
  Intr($16, R);
  AX:=R.AX; BX:=R.BX; Flags:=R.Flags;
  If (Mem[Seg0040:$0017] and 8<>0) and (Mem[Seg0040:$0018] and 2<>0) then Change:=False;

  If (Change and (R.AL=0)) then
    Case R.AH of
      30: AX:=FontShapes[10,0];
      46: AX:=FontShapes[11,0];
      18: AX:=FontShapes[12,0];
      38: AX:=FontShapes[13,0];
      49: AX:=FontShapes[14,0];
      24: AX:=FontShapes[15,0];
      31: AX:=FontShapes[16,0];
      44: AX:=FontShapes[17,0];
      45: AX:=FontShapes[18,0];
    End;

  If (Change and (R.AL=0) and ((Shift and (not CapsLock)) or ((not Shift) and CapsLock))) then
    Case R.AH of
      30: AX:=FontShapes[1,0];
      46: AX:=FontShapes[2,0];
      18: AX:=FontShapes[3,0];
      38: AX:=FontShapes[4,0];
      49: AX:=FontShapes[5,0];
      24: AX:=FontShapes[6,0];
      31: AX:=FontShapes[7,0];
      44: AX:=FontShapes[8,0];
      45: AX:=FontShapes[9,0];
    End;

  InLine($FA); IntVec:=P; InLine($FB);
End; { Latin2KeyboardISR }

Procedure Latin2ExitProc;
Begin { Zmodyfikowana procedura wyjòcia z programu }
  ExitProc:=OriginalExitProc;
  If OriginalKeyboardISR<>NIL then
    Begin
      SetIntVec($16, OriginalKeyboardISR);
      Asm
        mov ax,3
        int $10
      End;
    End;
End;
{ $F- }

Procedure SetupExitProc;
Begin { Procedura inicjuj•ca parametry wyjòcia z programu }
  OriginalExitProc:=ExitProc;
  ExitProc:=@Latin2ExitProc;
End; { SetupExitProc }

Procedure SetupKeyboardISR;
Begin { Procedura inicjuj•ca zmodyfikowan• obsàug© klawiatury }
  If OriginalKeyboardISR=NIL then
    Begin
      GetIntVec($16, OriginalKeyboardISR);
      SetIntVec($16, @Latin2KeyboardISR);
    End;
End; { SetupKeyboardISR }

Procedure SetupFontShapes;
Var R: Registers;
    I: Byte;
Begin { Procedura inicjuj•ca polskie znaki na ekranie }
  For I:=1 to 18 do
    Begin
      R.AX:=$1100;
      R.ES:=Seg(FontShapes[I,1]);
      R.BP:=Ofs(FontShapes[I,1]);
      R.CX:=1;
      R.DX:=FontShapes[I,0];
      R.BX:=$1000;
      Intr($10,R)
    End;
End; { SetupFontShapes }

Procedure Install;
Begin
  SetupExitProc;
  SetupKeyboardISR;
  SetupFontShapes;
End;

Begin
End.
