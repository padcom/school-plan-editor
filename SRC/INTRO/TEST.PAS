Program Test;
uses Graphics, Pictures;

var
  MorphCounter, MorphOffset: Integer;

procedure DoMorpherV(Pic, Destionation: PScreenPixels);
var
  X, Y: Word;
begin
  for Y:=0 to 1 do for X:=0 to 319 do
  begin
    Destionation^[(Y*2)+(MorphCounter*4)+MorphOffset, X]:=Pic^[(Y*2)+(MorphCounter*4)+MorphOffset, X];
  end;
  if MorphCounter=50 then
  begin
    MorphCounter:=0;
    MorphOffset:=1;
  end;
  Inc(MorphCounter, 1);
end;

procedure DoMorpherH(Pic, Destionation: PScreenPixels);
var
  X, Y: Word;
begin
  for X:=0 to 1 do for Y:=0 to 199 do
  begin
    Destionation^[Y, (X*2)+(MorphCounter*4)+MorphOffset]:=Pic^[Y, (X*2)+(MorphCounter*4)+MorphOffset];
  end;
  if MorphCounter=80 then
  begin
    MorphCounter:=0;
    MorphOffset:=1;
  end;
  Inc(MorphCounter, 1);
end;

Procedure Blur(Destionation: PScreenPixels); assembler;
asm
  LES BX, Destionation
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
end;

procedure FadeOut;
var
  Pal: TPalette;
  I: Integer;
  Counter: Integer;
begin
  for I:=0 to 255 do with Pal[I] do
  begin
    Red:=I div 4;
    Green:=I div 4;
    Blue:=I div 4;
  end;

  Counter:=0;
  repeat
    for I:=0 to 255 do with Pal[I] do
    begin
      if Red>0 then Dec(Red);
      if Green>0 then Dec(Green);
      if Blue>0 then Dec(Blue);
    end;
    Screen.WaitVR;
    Screen.SetPalette(@Pal);
    Inc(Counter);
  until (Port[$60] and 127=1) or (Counter>63);
end;

procedure FadeOut2;
var
  Pal: TPalette;
  I: Integer;
  Counter: Integer;
begin
  for I:=0 to 63 do with Pal[I] do
  begin
    Red:=I;
    Green:=I;
    Blue:=I;
  end;

  Counter:=0;
  repeat
    for I:=0 to 255 do with Pal[I] do
    begin
      if Red>0 then Dec(Red);
      if Green>0 then Dec(Green);
      if Blue>0 then Dec(Blue);
    end;
    for I:=0 to 500 do Screen.Buffer^[Random(180)+5, Random(310)+5]:=63;
    Blur(Screen.Buffer);
    Screen.Redraw;
    Screen.WaitVR;
    Screen.SetPalette(@Pal);
    Inc(Counter);
  until (Port[$60] and 127=1) or (Counter>63);
end;

procedure FadeIn;
var
  Pal: TPalette;
  I: Integer;
  Counter: Integer;
begin
  FillChar(Pal, SizeOf(Pal), 0);

  Counter:=0;
  repeat
    for I:=0 to Counter do
    begin
      with Pal[255-(I*4)] do begin Inc(Red); Inc(Green); Inc(Blue); end;
      with Pal[255-(I*4)-1] do begin Inc(Red); Inc(Green); Inc(Blue); end;
      with Pal[255-(I*4)-2] do begin Inc(Red); Inc(Green); Inc(Blue); end;
      with Pal[255-(I*4)-3] do begin Inc(Red); Inc(Green); Inc(Blue); end;
    end;
    Screen.WaitVR;
    Screen.SetPalette(@Pal);
    Inc(Counter);
  until (Port[$60] and 127=1) or (Counter>62);
end;

procedure FadeIn2;
var
  Pal: TPalette;
  I: Integer;
  Counter: Integer;
begin
  FillChar(Pal, SizeOf(Pal), 0);

  Counter:=0;
  repeat
    for I:=0 to Counter do
    begin
      with Pal[63-I] do begin Inc(Red); Inc(Green); Inc(Blue); end;
    end;
    Screen.WaitVR;
    Screen.SetPalette(@Pal);
    Inc(Counter);
  until (Port[$60] and 127=1) or (Counter>61);
end;

procedure Rozjazd(Destionation: PScreenPixels);
var
  X, Y: Word;
begin
  for X:=0 to 158 do for Y:=0 to 98 do
  begin

    Destionation^[(Y*2), (X*2)]:=Destionation^[(Y*2), (X*2)-1];
    Destionation^[(Y*2), (X*2)-1]:=Destionation^[(Y*2), (X*2)-2];

    Destionation^[(Y*2)+1, (X*2)+1]:=Destionation^[(Y*2)+1, (X*2)+3];
    Destionation^[(Y*2)+1, (X*2)+2]:=Destionation^[(Y*2)+1, (X*2)+5];

  end;
end;


var
  P1, P2, P3, P4: PBmpPictureObject;
  Pal: TPalette;
  C: Integer;
  I: Word;

begin
  MorphCounter:=0; MorphOffset:=0;
  New(P1, Load('intro\plan1.bmp'));
  New(P2, Load('intro\prod2.bmp'));
  New(P3, Load('intro\grand1.bmp'));
  New(P4, Load('intro\autor1.bmp'));

  for I:=0 to 64000 do Mem[Seg(P4^.Data^):I]:=Mem[Seg(P4^.Data^):I] div 4;

  Screen.Init;
  FillChar(Pal, SizeOf(TPalette), 0);
  Screen.SetPalette(@Pal);

  Move(P1^.Data^, Screen.Buffer^, 64000);
  Screen.Redraw;
  FadeIn;

  C:=0;
  repeat
    if C<150 then begin end
    else if C<410 then DoMorpherH(P2^.Data, Screen.Buffer)
    else if C=410 then
    begin
      MorphCounter:=0;
      MorphOffset:=0;
    end
    else DoMorpherV(P3^.Data, Screen.Buffer);
    Screen.WaitVR;
    Screen.Redraw;
    Inc(C);
  until (Port[$60] and 127=1) or (C>670);
  FadeOut;

  Move(P4^.Data^, Screen.Buffer^, 64000);
  Screen.Redraw;
  FadeIn2;
  C:=0;
  repeat
    if C<150 then begin end
    else
    begin
      for I:=0 to 500 do Screen.Buffer^[Random(180)+5, Random(310)+5]:=63;
      Blur(Screen.Buffer);
    end;
    Screen.WaitVR;
    Screen.Redraw;
    Inc(C);
  until (Port[$60] and 127=1) or (C>200);
  FadeOut2;

  Screen.Done;
  Dispose(P1, Done);
  Dispose(P2, Done);
  Dispose(P3, Done);
  Dispose(P4, Done);
end.
