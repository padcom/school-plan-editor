{$M 8192,0,655350}
Program CircleFireScrollWithStars3D;

Const OffsetX            =160;
      OffsetY            =100;
      ScrollLength       =320;
      FontHeightMultipler=1.5;
      MaxStars           =500;
      DoStars            =true;
      DoScroll           =true;
      DoMoveScroll       =True;
      DoFade             =false;

Type TScrollBufor        =Array[0..ScrollLength+8,0..15] of Byte;
     TScrollSinus        =Array[0..ScrollLength,0..15,0..1] of Word;
     TStars3D            =Array[0..MaxStars,0..2] of Integer;
     TStars2D            =Array[0..MaxStars,0..1] of Integer;
     TStarsSinus         =Array[0..255] of Integer;

Var  ScrollBufor         :TScrollBufor;
     ScrollSinus         :TScrollSinus;
     ScrollText          :String;
     ScrollPos           :Byte;
     ScrollFC            :Byte;
     FontSeg, FontOfs    :Word;
     Stars3D             :TStars3D;
     Stars2D             :TStars2D;
     StarsSinusX         :TStarsSinus;
     StarsSinusY         :TStarsSinus;
     StarsSinusC         :Byte;
     ScreenBufor         :Pointer;

Procedure SetColorRGB(Nr,R,G,B:Byte);
Begin
     Port[$03c8]:=Nr;
     Port[$03c9]:=R;
     Port[$03c9]:=G;
     Port[$03c9]:=B;
End;

Procedure SetBorderColor(Nr:Byte);
Var T:Byte;
Begin
     T:=Port[$03da];
     Port[$03c0]:=$11;
     Port[$03c0]:=Nr;
     T:=Port[$03da];
     Port[$03c0]:=$20;
End;

Procedure SetupStars3D;
Var I:Integer;
Begin
     Randomize;
     For I:=1 to MaxStars do
         Begin
              Stars3D[I,0]:=Random(1024);
              Stars3D[I,1]:=Random(1024);
              Stars3D[I,2]:=Random(320)+2;
         End;
     For I:=0 to 255 do StarsSinusX[I]:=Round(Sin(I*Pi/64)*80);
     For I:=0 to 255 do StarsSinusY[I]:=Round(Sin(I*Pi/32)*30);
End;

Procedure DrawStars;
Var I:Integer;
Begin
     Inc(StarsSinusC); StarsSinusC:=StarsSinusC and 127;
     If not DoStars then Exit;
     For I:=1 to MaxStars do
         Begin
              If not ((Stars2D[I,0]>319) or (Stars2D[I,0]<1) or (Stars2D[I,1]>199) or (Stars2D[I,1]<1)) then
                 Mem[Seg(ScreenBufor^):Ofs(ScreenBufor^)+(Stars2D[I,1]*320)+Stars2D[I,0]]:=0;
              Dec(Stars3D[I,2],7);
              If Stars3D[I,2]<=0 then Stars3D[I,2]:=Stars3D[I,2]+320;
              Stars2D[I,0]:=(((Stars3D[I,1]+StarsSinusX[StarsSinusC]) shl 7) div Stars3D[I,2])+OffsetX;
              Stars2D[I,1]:=(((Stars3D[I,0]+StarsSinusY[StarsSinusC]) shl 7) div Stars3D[I,2])+OffsetY;
              If not ((Stars2D[I,0]>319) or (Stars2D[I,0]<1) or (Stars2D[I,1]>199) or (Stars2D[I,1]<1)) then
                 Mem[Seg(ScreenBufor^):Ofs(ScreenBufor^)+(Stars2D[I,1]*320)+Stars2D[I,0]]:=64-(Stars3D[I,2] div 5);
         End;
End;

Procedure SetupScroll;
Var X,Y,I:Word;
Begin
     I:=ScrollLength;
     Case I of
          320:ScrollText:=' Szkoˆa 1.2 -  (C)by Grand Sytemy Informatyczne - ';
          640:ScrollText:='Maciej Hryniszak Presents Circle Scroll ! Code and idea by Pad. The Come-back ! '
          else ScrollText:='Maciej Hryniszak .. ';
     End;
     ScrollPos:=0;
     For X:=0 to ScrollLength do For Y:=0 to 15 do
         Begin
              ScrollSinus[X,Y,0]:=Round(sin((1*(X+((ScrollLength div 4)/1)))*Pi/(ScrollLength/2))*
                                       (70+(Y*FontHeightMultipler))+OffsetX);
              ScrollSinus[X,Y,1]:=Round(cos((1*(X+((ScrollLength div 4)/1)))*Pi/(ScrollLength/2))*
                                       (60+(Y*FontHeightMultipler))+OffsetY);
         End;
End;

Procedure ScrollDraw;
Var X,Y,Tx,Ty:Word;
    Tc:Byte;
Begin
     If not DoScroll then Exit;
     For X:=0 to ScrollLength do For Y:=0 to 15 do
         Begin
              Tx:=ScrollSinus[X,Y,0];
              Ty:=ScrollSinus[X,Y,1];
              Tc:=ScrollBufor[X,Y];
              If DoMoveScroll then
                 Begin
                      Tx:=Tx+StarsSinusX[StarsSinusC+64];
                      Ty:=Ty+StarsSinusY[StarsSinusC+32];
                 End;
              If (Tx>5) and (Tx<314) and (Ty>5) and (Ty<194){ and (Tc<>0) }then
              Mem[Seg(ScreenBufor^):Ofs(ScreenBufor^)+(Ty*320)+Tx]:=Tc;
         End;
     For X:=0 to ScrollLength+8 do For Y:=0 to 15 do ScrollBufor[X,Y]:=ScrollBufor[X+1,Y];

     Inc(ScrollFC);
     If ScrollFC>7 then
        Begin
             ScrollFC:=0;
             Inc(ScrollPos);
             If ScrollPos>Length(ScrollText) then ScrollPos:=1;
             For Y:=0 to 15 do For X:=0 to 7 do
             If (Mem[FontSeg:FontOfs+(Ord(ScrollText[ScrollPos])*16)+Y] and (128 shr X))<>0
                then ScrollBufor[X+ScrollLength,Y]:=63
                else ScrollBufor[X+ScrollLength,Y]:=0;
        End;
End;

Procedure Fade;
Var S,O:Word;
Begin
     If not DoFade then Exit;
     S:=Seg(ScreenBufor^); O:=Ofs(ScreenBufor^);
     Asm
        MOV AX,S
        MOV ES,AX
        MOV BX,O
        ADD BX,640
@Loop:
        MOV AX,WORD PTR [ES:BX+321]
        ADD AX,WORD PTR [ES:BX-321]
        ADD AX,WORD PTR [ES:BX+319]
        ADD AX,WORD PTR [ES:BX-319]
        SHR AH,2
        SHR AL,2
        MOV WORD PTR [ES:BX],AX
        ADD BX,2
        CMP BX,320*199
        JNE @Loop
     End;
End;

Procedure UpdateScreen(Bufor:Pointer);
Var S,O:Word;
Begin
     S:=Seg(Bufor^); O:=Ofs(Bufor^);
     Asm
        PUSH DS
        MOV AX,$A000
        MOV ES,AX
        MOV DI,320*2
        MOV AX,S
        MOV SI,O
        ADD SI,640
        MOV DS,AX
        MOV CX,320*49 { ->  DWORD }
        DB  $66       { TAKI TRIK }
        REP MOVSW     { DWORD  <- }

        POP DS
     End;
     If not DoFade then FillChar(ScreenBufor^, 320*200, 0);
End;

Procedure Intro;
Var I,J:Word;
Begin
     For I:=0 to 63 do
         Begin
              Repeat Until ((Port[$03DA] and 8)<>0);
              SetColorRGB(64,I,I,I);
              For J:=1 to 63 do SetColorRGB(J,(I*J) div 64,(I*J) div 64,(I*J) div 64);
              UpdateScreen(ScreenBufor);
              ScrollDraw;
              Fade;
              DrawStars;
         End;
End;

Procedure Dentro;
Var I,J:Word;
Begin
     For I:=63 downto 0 do
         Begin
              Repeat Until ((Port[$3da] and 8)<>0);
              SetColorRGB(64,I,I,I);
              For J:=1 to 63 do SetColorRGB(J,(I*J) div 64,(I*J) div 64,(I*J) div 64);
              UpdateScreen(ScreenBufor);
              ScrollDraw;
              Fade;
              DrawStars;
         End;
End;


Begin
     GetMem(ScreenBufor,320*200);
     If ScreenBufor=NIL then Halt;
     FillChar(ScreenBufor^,320*200,0);
     SetupStars3D;
     SetupScroll;
     Asm
        MOV AX,$0013; INT $10;
        MOV AX,$1130; MOV BH,6; INT $10;
        MOV AX,ES; MOV FontSeg,AX; MOV FontOfs,BP;
     End;
     SetColorRGB(255,0,0,0);
     SetBorderColor(255);
     InLine($FA);
     Intro;
     Repeat
           Repeat Until ((Port[$3da] and 8)<>0);
           SetColorRGB(254,63,63,63);
{           If not DoFade then FillChar(ScreenBufor^, 320*200, 0);}
           UpdateScreen(ScreenBufor);
           ScrollDraw;
           Fade;
           DrawStars;
           SetColorRGB(255,0,0,0);
     Until ((Port[$60] and 127)=1);
     Dentro;
     InLine($FB);
     FreeMem(ScreenBufor,320*200);
     Asm MOV AX,$03; INT $10; end;
     Writeln('Intro written by Maciej Hryniszak in 1999.');
End.
