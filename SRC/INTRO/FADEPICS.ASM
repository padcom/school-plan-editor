.model TPASCAL

.386

.code

public FadePics

FadePics PROC FAR Pic1: DWord, Pic2: DWord, Destionation: DWord, Procent: Word
LOCAL P1: Word, P2: Word, T: Word;
  xor ax, ax
  mov P1, ax
  mov P2, ax

  push ds
  mov al, 64
  mov bx, Procent
  sub al, bl
  mov Byte Ptr P1, al
  mov Byte Ptr P2, bl

  mov cx, 32000
  mov T, 0
  les di, Destionation
Loop1:
  lds si, Pic1
  mov si, T
  lodsw
  mov

  mul P1
  shr al, 6
  shr ah, 6
;  mov bx, ax

;  lds si, Pic2
;  mov si, T
;  lodsw

;  mul P2
;  shr al, 6
;  shr ah, 6

;  add ax, bx

  stosw

  add T, 2

  loop Loop1
  pop ds
  ret
FadePics ENDP

end
