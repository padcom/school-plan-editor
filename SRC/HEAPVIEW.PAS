Unit HeapViewer;

interface
uses Objects, Drivers, Views;

type { Typ opisuj¥cy podgl¥d zaj©tej pami©ci }
  PHeapMemViewer = ^THeapMemViewer;
  THeapMemViewer = object (TView)
    OldMem: LongInt;
    procedure Draw; virtual;
  end;

implementation

procedure THeapMemViewer.Draw;
var
  M: LongInt;
  S: String;
begin
  M:=MaxAvail;
  if M<>OldMem then
  begin
    OldMem:=M;
    Str(M, S);
    WriteStr(0, 0, S+'       ', 1);
  end;
end;

begin

end.
