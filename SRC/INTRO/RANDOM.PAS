Program Random;

var
  R: Word;
  I: Integer;

begin
  asm mov ax, $13; int $10; end;
  R:=Mem;
  for I:=0 to 319 do
  begin
    R:=((R*$8405) and $FFFF)+1;
    Mem[SegA000:I+(R div 100)*320]:=15;
  end;
  Readln;
  asm mov ax, $13; int $10; end;
end.
