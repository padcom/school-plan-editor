Unit Effects;

interface
uses Graphics, Pictures;

procedure DrawMerged(Pic1, Pic2: PScreenPixels; Procent: Word);

implementation

procedure DrawMerged;
var
  I, O: Word;
  T1, T2, B1, B2, B: Word;
  P1, P2: Byte;
begin
  P1:=64-Procent; P2:=Procent;

{ *** Pure Pascal version *** }

{
  for I:=0 to 64000 do
  begin
    B1:=(Mem[Seg(Pic1^.Data^):I]*P1) shr 6;
    B2:=(Mem[Seg(Pic2^.Data^):I]*P2) shr 6;
    Mem[Seg(Screen.Buffer^):I]:=B1+B2;
  end;
  Exit;
}

{ *** Assembler optimized version *** }
{ U¾ywa sˆ¢w zamiast bajt¢w i dlatego jest 2 razy szybsza ! }

  asm
    mov cx, 64000
@Loop:
    les di, Pic1
    mov di, cx
    sub di, 2
    mov ax, [es:di]
    mov bx, ax
    mov al, P1
    mul bl
    shr ax, 6
    mov dl, al
    mov al, P1
    mul bh
    shr ax, 6
    mov dh, al
    mov B, DX
  { Primary picture color ready }

    les di, Pic2
    mov di, cx
    sub di, 2
    mov bx, [es:di]
    mov al, P2
    mul bl
    shr ax, 6
    mov dl, al
    mov al, P2
    mul bh
    shr ax, 6
    mov dh, al
  { Secondary picture color ready }

    mov ax, B
    add al, dl
    add ah, dh
  { Added colors }

    les di, Screen.Buffer
    mov di, cx
    sub di, 2
    stosw
  { Stored to screen buffer }

    dec cx
    Loop @Loop
  end;
end;

begin
end.
