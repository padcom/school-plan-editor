uses Graphics, Pictures, Effects;

function EscPressed: Boolean;
begin
  EscPressed:=Port[$60] and 127=1;
end;

procedure Scene1;
const
  Speed = 32;
var
  Counter: Integer;
  Procent: Integer;
  Pic1, Pic2, Temp: PBMPPictureObject;
begin
  New(Pic1, Load('intro\Blank1.bmp'));
  Screen.SetPalette(Pic1^.Palette);
  New(Pic2, Load('intro\Plan1.bmp'));

  Counter:=0;
  Procent:=0;
  repeat
    DrawMerged(Pic1^.Data, Pic2^.Data, Procent);
    if Counter<Speed then Inc(Procent, 64 div Speed)
    else if Counter=Speed then
    begin
      Procent:=0;
      Dispose(Pic1, Done);
      Pic1:=Pic2;
      New(Pic2, Load('intro\Prod2.bmp'));
    end
    else if Counter<Speed*2 then
    else if Counter<Speed*3 then Inc(Procent, 64 div Speed)
    else if Counter<Speed*4 then
    else if Counter=Speed*4 then
    begin
      Procent:=0;
      Dispose(Pic1, Done);
      Pic1:=Pic2;
      New(Pic2, Load('intro\Grand1.bmp'));
    end
    else if Counter<Speed*5 then Inc(Procent, 64 div Speed)
    else if Counter=Speed*5 then
    begin
      Procent:=0;
      Dispose(Pic1, Done);
      Pic1:=Pic2;
      New(Pic2, Load('intro\Autor1.bmp'));
    end
    else if Counter<Speed*6 then
    else if Counter<Speed*7 then Inc(Procent, 64 div Speed)
    else if Counter=Speed*8 then
    begin
      Procent:=0;
      Dispose(Pic1, Done);
      Pic1:=Pic2;
      New(Pic2, Load('intro\Blank1.bmp'));
    end
    else if Counter<Speed*8 then
    else if Counter<Speed*9 then Inc(Procent, 64 div Speed);

    Inc(Counter);
    Screen.WaitVR;
    Screen.Redraw;
  until EscPressed or (Counter>Speed*9+10);
  Dispose(Pic1, Done);
  Dispose(Pic2, Done);
end;

begin
  Screen.Init;
{  Screen.SpeedTest:=True;}
  Scene1;
  Screen.Done;
end.
