Unit Drukowanie;

interface

procedure PrintFile(FileName: String);

implementation
uses
  HP, Latin2;

procedure PrintFile;
var
  F: Text;
  S, Command, Data: String;
  I, E: Integer;
  Fonts: PFontsDefinition;
begin
  {$I-}
  Assign(F, FileName);
  Reset(F);

  if IOResult<>0 then Exit;

  New(Fonts);
  GetCurrentFonts(Fonts);

  BeginDoc(1, 100, 5);
  if IOResult<>0 then;

  while not Eof(F) do
  begin
    Readln(F, S);
    if (S<>'') and (S[1]='\') then
    begin
      I:=Pos(':', S);
      if I=0 then Continue;
      Command:=UpStr(Copy(S, 2, I-2));
      if Command='FONT' then
      begin
        Data:=Copy(S, I+1, Length(S)-I);
        LoadFonts(Fonts, Data+'.ppf');
        {$I-}
      end
      else if Command='DPI' then
      begin
        Data:=Copy(S, I+1, Length(S)-I);
        Val(Data, I, E);
        ChangeResolution(I);
        {$I-}
      end;
    end
    else PrintLine(Fonts, S);
    if IOResult<>0 then Break;
  end;

  EndDoc;
  Dispose(Fonts);
  Close(F);
  {$I+}
  if IOResult<>0 then;
end;

begin
end.
