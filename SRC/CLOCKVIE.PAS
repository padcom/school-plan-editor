Unit ClockViewer;

interface
uses Objects, Drivers, Views;

type { Typ opisuj¥cy zegarek }
  PClockViewer = ^TClockViewer;
  TClockViewer = object (TView)
    OldSec: Word;
    procedure Draw; virtual;
  end;

implementation
uses Dos;

procedure TClockViewer.Draw;
var
  H, M, S, SS: Word;
  S1, S2, S3: String;
begin
  GetTime(H, M, S, SS);
  if S<>OldSec then
  begin
    OldSec:=S;
    Str(H, S1); if H<10 then S1:='0'+S1; S1:=S1+':';
    Str(M, S2); if M<10 then S2:='0'+S2; S2:=S2+':';
    Str(S, S3); if S<10 then S3:='0'+S3;
    WriteStr(0, 0, S1+S2+S3+'       ', 1);
  end;
end;

begin
end.
