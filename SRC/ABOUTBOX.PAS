Unit AboutBox;

interface
uses App, Objects, Drivers, Views, Dialogs;

type { typ opisuj¥cy okienko powitalne }
  PAboutBox = ^TAboutBox;
  TAboutBox = object (TDialog)
    constructor Init;
  end;

procedure ShowOProgramie;

implementation

procedure InsertText(D: PDialog; Y: Integer; S: String);
var
  R: TRect;
  T: PStaticText;
begin
  R.Assign(1, Y, D^.Size.X-2, Y+1);
  New(T, Init(R, S));
  D^.Insert(T);
end;

constructor TAboutBox.Init;
var
  R: TRect;
  B: PButton;
begin
  R.Assign(0, 0, 50, 12);
  inherited Init(R, 'O programie');
  Options:=Options or ofCentered;

  InsertText(@Self, 2, #3'Plan lekcji - wersja 1.2');
  InsertText(@Self, 4, #3'(C) by GRAND s.c. 1999');
  InsertText(@Self, 5, #3'Wszelkie prawa zastrze¾one');

  R.Assign(17, 9, 32, 11);
  New(B, Init(R, '~D~alej', cmOK, bfDefault));
  Insert(B);
end;

procedure ShowOProgramie;
var
  D: PAboutBox;
begin
  New(D, Init);
  Application^.ExecuteDialog(D, nil);
end;

begin
end.
