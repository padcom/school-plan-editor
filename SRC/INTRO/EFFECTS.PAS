Unit Effects;

interface
uses Graphics, Pictures;

procedure InitDrawMerged(Pic1, Pic2, Destionation: PScreenPixels);
procedure DrawMerged(Pic1, Pic2: PScreenPixels; Procent: Word);

var
  A: array[0..32008] of Byte;
  IntensityTable: array[0..63, 0..63] of Byte;

implementation

{$L FADEPICS.OBJ}

procedure FadePics(Pic1, Pic2, Destionation: PScreenPixels; Procent: Word); far; external;

procedure InitDrawMerged;
var
  I: Word;
  B1, B2: Byte;
begin
  for I:=0 to 64000 do
  begin
    B1:=Mem[Seg(Pic1^):Ofs(Pic1^)+I] shr 2;
    B2:=64+Mem[Seg(Pic2^):Ofs(Pic2^)+I] shr 2;
    Mem[Seg(Destionation^):Ofs(Destionation^)+I]:=B1+B2;
  end;
end;

procedure DrawMerged;
var
  P: Pointer;
  I: Word;
  B1, B2, B3, B4: Word;
  P1, P2, O1, O2, O3, O4: Word;

begin
  P1:=64-Procent; P2:=Procent;
  if P1>63 then P1:=63;
  if P2>63 then P2:=63;

  P:=@IntensityTable;

  asm
    push ds
    les di, Screen.Buffer

    mov cx, 16000
    mov I, 0
@Loop1:
    lds si, Pic1
    add si, I
    lodsw
    mov B1, ax

    lds si, Pic2
    add si, I
    lodsw
    mov B2, ax

    xor ah, ah
    mov al, Byte Ptr B1
    shr ax, 2
    shl ax, 6
    add ax, P1
    mov O1, ax
    xor ah, ah
    mov al, Byte Ptr B1+1
    shr ax, 2
    shl ax, 6
    add ax, P1
    mov O3, ax

    xor ah, ah
    mov al, Byte Ptr B2
    shr ax, 2
    shl ax, 6
    add ax, P2
    mov O2, ax
    xor ah, ah
    mov al, Byte Ptr B2+1
    shr ax, 2
    shl ax, 6
    add ax, P2
    mov O4, ax

    lds si, P
    mov bx, O1
    mov al, ds:[si+bx]
    mov bx, O2
    add al, ds:[si+bx]

    mov bx, O3
    mov ah, ds:[si+bx]
    mov bx, O4
    add ah, ds:[si+bx]
    mov bx, I
    mov es:[di+bx], ax

    add I, 2
    Loop @Loop1

    pop ds
  end;

{  FadePics(Pic1, Pic2, Screen.Buffer, Procent);}
end;

(*
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
*)
begin
end.
