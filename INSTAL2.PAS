Program Install;
uses
  Crt, App, Objects, Drivers, Views, Dialogs, Menus, MsgBox, Validate;

var
  InstallData: record
    ProgramTitle: String;
    CancelInstall: Boolean;
    Failed: Boolean;
    Source, Destionation: record
      Drive: Char;
      Path: String;
    end;
    Directories: record
      Count: Integer;
      Destionation: array[1..50] of String[95];
    end;
    Files: record
      Count: Integer;
      Source,
      Destionation: array[1..100] of String[20];
    end;
  end;

type { typ opisuj¥cy okienko powitalne }
  PWelcomeBox = ^TWelcomeBox;
  TWelcomeBox = object (TDialog)
    constructor Init;
  end;

constructor TWelcomeBox.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 50, 10);
  inherited Init(R, 'Instalator');
  Options:=Options or ofCentered;

  R.Assign(2, 2, Size.X-2, 3);
  Insert(New(PStaticText, Init(R, #3'Zapraszamy do instalacji programu')));
  R.Assign(2, 4, Size.X-2, 5);
  Insert(New(PStaticText, Init(R, #3+InstallData.ProgramTitle)));

  R.Assign((Size.X div 2)-7, Size.Y-3, (Size.X div 2)+8, Size.Y-1);
  Insert(New(PButton, Init(R, '~D~alej', cmOK, bfDefault)));
end;

type { typ opisuj¥cy walidator linii wprowadzania ˜cie¾ki dost©pu }
  PPathValidator = ^TPathValidator;
  TPathValidator = object (TValidator)
    function IsValid(const S: string): Boolean; virtual;
    function IsValidInput(var S: string; SuppressFill: Boolean): Boolean; virtual;
    procedure Error; virtual;
  end;

function TPathValidator.IsValid;
var
  I: Integer;
begin
  IsValid:=True;
  if S<>'' then
  begin
    for I:=1 to Length(S) do
    begin
      if not (S[I] in ['A'..'Z', '\', '0'..'9']) then IsValid:=False;
    end;
  end;
end;

function TPathValidator.IsValidInput;
var
  I, Len: Integer;
begin
  IsValidInput:=True;
  if S<>'' then
  begin
    Len:=1;
    if S[1]<>'\' then S:='\'+S;
    for I:=1 to Length(S) do
    begin
      S[I]:=UpCase(S[I]);
      if not (S[I] in ['A'..'Z', '\', '0'..'9']) then IsValidInput:=False;
      if (S[I]='\') then
      begin
        if Len=0 then IsValidInput:=False
        else Len:=0;
      end
      else
      begin
        Inc(Len);
        if Len>8 then IsValidInput:=False;
      end;
    end;
  end;
end;

procedure TPathValidator.Error;
begin
  MessageBox(#3'Bˆ©dna ˜cie¾ka dost©pu !', nil, mfError or mfCancelButton);
end;

type { typ opisuj¥cy okno wyboru parametr¢w instalacji }
  PDataEntryBox = ^TDataEntryBox;
  TDataEntryBox = object (TDialog)
  private
    FSourceDrive: PInputLine;
    FDestionationDrive: PInputLine;
    FDestionationPath: PInputLine;
  public
    constructor Init;
    function ConfirmCancel: Boolean;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
  end;

constructor TDataEntryBox.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 70, 20);
  inherited Init(R, 'Wyb¢r parametr¢w instalacji');
  Options:=Options or ofCentered;

  R.Assign(2, 2, Size.X-2, 3);
  Insert(New(PStaticText, Init(R, '  Program instalacyjny wymaga podania nast©puj¥cych parametr¢w')));
  R.Assign(2, 3, Size.X-2, 4);
  Insert(New(PStaticText, Init(R, 'instalacji: Dysk instalacyjny, dysk docelowy oraz ˜cie¾ka dost©pu')));
  R.Assign(2, 4, Size.X-2, 5);
  Insert(New(PStaticText, Init(R, 'do katalogu, w kt¢rym program zostanie zainstalowany.')));
  R.Assign(1, 6, Size.X-1, 7);
  Insert(New(PStaticText, Init(R, 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ')));

  R.Assign(21, 8, 24, 9);
  New(FSourceDrive, Init(R, 1));
  Insert(FSourceDrive);
  R.Assign(2, 8, 16, 9);
  Insert(New(PLabel, Init(R, 'Dysk ~«~r¢dˆowy', FSourceDrive)));

  R.Assign(21, 10, 24, 11);
  New(FDestionationDrive, Init(R, 1));
  Insert(FDestionationDrive);
  R.Assign(2, 10, 16, 11);
  Insert(New(PLabel, Init(R, 'Dysk d~o~celowy', FDestionationDrive)));

  R.Assign(21, 12, Size.X-3, 13);
  New(FDestionationPath, Init(R, 80));
  Insert(FDestionationPath);
  FDestionationPath^.SetValidator(New(PPathValidator, Init));
  R.Assign(2, 12, 19, 13);
  Insert(New(PLabel, Init(R, 'Katalog do~c~elowy', FDestionationPath)));

  R.Assign(1, 14, Size.X-1, 15);
  Insert(New(PStaticText, Init(R, 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ')));

  R.Assign(Size.X-40, 17, Size.X-24, 19);
  Insert(New(PButton, Init(R, '~I~nstaluj', cmOK, bfDefault)));
  R.Assign(Size.X-20, 17, Size.X-4, 19);
  Insert(New(PButton, Init(R, '~P~rzerwij', cmCancel, bfNormal)));

  FSourceDrive^.Select;
end;

function TDataEntryBox.ConfirmCancel;
begin
  ConfirmCancel:=MessageBox(#3'Czy na pewno chcesz przerwa† instalacj© ?',
                 nil, mfConfirmation or mfYesButton or mfNoButton)=cmYes;
end;

procedure TDataEntryBox.HandleEvent;
begin
  if Event.What=evCommand then
  case Event.Command of
    cmCancel: if not ConfirmCancel then ClearEvent(Event);
  end;

  if Event.What=evKeyboard then
  case Event.KeyCode of
    kbUp   : SelectNext(True);
    kbDown : SelectNext(False);
    kbEnter: if (Current=PView(FSourceDrive)) or
                (Current=PView(FDestionationDrive)) or
                (Current=PView(FDestionationPath)) then
    begin
      SelectNext(False);
      ClearEvent(Event);
    end;
  end;

  inherited HandleEvent(Event);
end;

procedure TDataEntryBox.GetData;
var
  S: String;
begin
  FSourceDrive^.GetData(S);
  InstallData.Source.Drive:=S[1];
  FDestionationDrive^.GetData(S);
  InstallData.Destionation.Drive:=S[1];
  FDestionationPath^.GetData(InstallData.Destionation.Path);
end;

procedure TDataEntryBox.SetData;
var
  S: String;
begin
  S:=InstallData.Source.Drive;
  FSourceDrive^.SetData(S);
  S:=InstallData.Destionation.Drive;
  FDestionationDrive^.SetData(S);
  FDestionationPath^.SetData(InstallData.Destionation.Path);
end;

type { typ opisuj¥cy okno zaawansowania kopiowania zbior¢w }
  PCopyBox = ^TCopyBox;
  TCopyBox = object (TDialog)
  private
    FAllCompleted: PStaticText;
    FCurrentSource: PStaticText;
    FCurrentDestionation: PStaticText;
  public
    constructor Init;
    procedure SetAllCompleted(I: Integer);
    procedure SetCurrentSource(S: String);
    procedure SetCurrentDestionation(S: String);
  end;

constructor TCopyBox.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 50, 8);
  inherited Init(R, 'Kopiowanie plik¢w');
  Options:=Options or ofCentered;

  R.Assign(2, 2, Size.X-2, 3);
  New(FCurrentSource, Init(R, 'Plik «r¢dˆowy:'));
  Insert(FCurrentSource);

  R.Assign(2, 3, Size.X-2, 4);
  New(FCurrentDestionation, Init(R, 'Plik docelowy:'));
  Insert(FCurrentDestionation);

  R.Assign(2, 5, Size.X-2, 6);
  New(FAllCompleted, Init(R, 'Zakoäczono og¢ˆem:'));
  Insert(FAllCompleted);
end;

procedure TCopyBox.SetAllCompleted;
var
  S: String;
begin
  Str(I, S);
  if Assigned(FAllCompleted^.Text) then DisposeStr(FAllCompleted^.Text);
  FAllCompleted^.Text:=NewStr(' Zakoäczono og¢ˆem : '+S+'%');
end;

procedure TCopyBox.SetCurrentSource;
begin
  if Assigned(FCurrentSource^.Text) then DisposeStr(FCurrentSource^.Text);
  FCurrentSource^.Text:=NewStr(' Plik «r¢dˆowy : '+S);
end;

procedure TCopyBox.SetCurrentDestionation;
begin
  if Assigned(FCurrentDestionation^.Text) then DisposeStr(FCurrentDestionation^.Text);
  FCurrentDestionation^.Text:=NewStr(' Plik docelowy : '+S);
end;

type { typ opisuj¥cy aplikacj© instalatora }
  PMainApp = ^TMainApp;
  TMainApp = object (TApplication)
    procedure InitStatusLine; virtual;
    procedure Install; virtual;
    procedure DisplayError(ErrorNr: Integer; Info: String); virtual;
    procedure ExecuteWelcomeBox; virtual;
    procedure ExecuteDataEntryBox; virtual;
    function CopyFile(Source, Destionation: String): Boolean; virtual;
    procedure ExecuteInstallFiles; virtual;
  end;

procedure TMainApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y:=R.B.Y-1;
  StatusLine:=New(PStatusLine, Init(R, nil));
end;

procedure TMainApp.Install;
begin
  ExecuteWelcomeBox;
  ExecuteDataEntryBox;
  if not InstallData.CancelInstall then
    ExecuteInstallFiles;
  if InstallData.Failed or InstallData.CancelInstall then
  begin
    MessageBox(#3'Instalacja zostaˆa przerwana !', nil, mfInformation or mfCancelButton);
  end
  else
  begin
    MessageBox(#3'Instalacja zakoäczona sukcesem !', nil, mfInformation or mfOKButton);
  end;
end;

procedure TMainApp.DisplayError;
var
  BoxType: Word;
begin
  case ErrorNr of
    1: BoxType:=mfError or mfCancelButton;
  end;
  MessageBox(#3+Info, nil, BoxType);
end;

procedure TMainApp.ExecuteWelcomeBox;
var
  D: PWelcomeBox;
begin
  New(D, Init);
  ExecuteDialog(D, nil);
end;

procedure TMainApp.ExecuteDataEntryBox;
var
  D: PDataEntryBox;
begin
  New(D, Init);
  if ExecuteDialog(D, @InstallData)=cmCancel then InstallData.CancelInstall:=True
  else InstallData.CancelInstall:=False;
end;

function TMainApp.CopyFile;
var
  SF, DF: File;
  CountRead, CountWritten: Integer;
  CopyBuffer: array[1..4096] of Byte;
begin
  {$I-}
  CopyFile:=True;

  Assign(Sf, Source);
  Reset(Sf, 1);
  if IOResult<>0 then
  begin
    DisplayError(1, 'Uszkodzona dyskietka instalacyjna !!!');
    CopyFile:=False;
    Exit;
  end;
  Assign(Df, Destionation);
  Rewrite(Df, 1);
  if IOResult<>0 then
  begin
    DisplayError(1, 'Bˆ¥d przy tworzeniu pliku docelowego !');
    CopyFile:=False;
    Exit;
  end;

  repeat
    BlockRead(Sf, CopyBuffer, SizeOf(CopyBuffer), CountRead);
    BlockWrite(Df, CopyBuffer, CountRead, CountWritten);
  until (CountRead=0) or (CountWritten<>CountRead);

  Close(Sf);
  Close(Df);
  {$I+}
end;

procedure TMainApp.ExecuteInstallFiles;
var
  D: PCopyBox;
  I: Integer;
  BaseDir, SourceDir: String;
begin
  New(D, Init);
  Desktop^.Insert(D);

  {$I-}
  with InstallData.Destionation do BaseDir:=Drive+':'+Path;
  if BaseDir[Length(BaseDir)]<>'\' then BaseDir:=BaseDir+'\';

{  ChDir(InstallData.Destionation.Drive+':\');}
  MkDir(Copy(BaseDir, 1, Length(BaseDir)-1));
  if IOResult=3 then
  begin
    DisplayError(1, 'Bˆ¥d przy tworzeniu katalogu gˆ¢wnego programu');
    D^.Close;
    InstallData.Failed:=True;
    Exit;
  end;

  for I:=1 to InstallData.Directories.Count do with InstallData.Directories do
  begin
    MkDir(BaseDir+Destionation[I]);
    if IOResult<>0 then;
  end;

  SourceDir:={InstallData.Source.Drive+':'+}InstallData.Source.Path;
  if SourceDir<>'' then SourceDir:=SourceDir+'\';

  for I:=1 to InstallData.Files.Count do with InstallData.Files do
  begin
    D^.SetCurrentSource(Source[I]);
    D^.SetCurrentDestionation(Destionation[I]);
    D^.SetAllCompleted(I*100 div Count);
    D^.Redraw;
    if not CopyFile(SourceDir+Source[I], BaseDir+Destionation[I]) then
    begin
      InstallData.Failed:=True;
      Break;
    end;
    Delay(500);
  end;
  {$I+}
  D^.Close;
end;

var
  Main: TMainApp;
  S: String;

begin
  with InstallData do
  begin
    ProgramTitle:='Plan lekcji wersja 1.2';
    Failed:=False;
    CancelInstall:=False;

    GetDir(0, S);
    Source.Drive:=S[1];
    Source.Path:='';
    Destionation.Drive:='C';
    Destionation.Path:='\PLAN';

    Directories.Count:=3;
    Directories.Destionation[1]:='DATA';
    Directories.Destionation[2]:='HELP';
    Directories.Destionation[3]:='INTRO';

    Files.Count:=28;
    Files.Source[1]:='PLAN.INS'; Files.Destionation[1]:='PLAN.EXE';
    Files.Source[2]:='PL.INS'; Files.Destionation[2]:='PL.EXE';
    Files.Source[3]:='START.INS'; Files.Destionation[3]:='START.BAT';

    Files.Source[4]:='INTRO.INS'; Files.Destionation[4]:='INTRO.EXE';
    Files.Source[5]:='AUTOR1.INS'; Files.Destionation[5]:='INTRO\AUTOR1.BMP';
    Files.Source[6]:='BLANK1.INS'; Files.Destionation[6]:='INTRO\BLANK1.BMP';
    Files.Source[7]:='GRAND1.INS'; Files.Destionation[7]:='INTRO\GRAND1.BMP';
    Files.Source[8]:='PLAN1.INS'; Files.Destionation[8]:='INTRO\PLAN1.BMP';
    Files.Source[9]:='PROD2.INS'; Files.Destionation[9]:='INTRO\PROD2.BMP';

    Files.Source[10]:='4096.INS'; Files.Destionation[10]:='HELP\4096.TXT';
    Files.Source[11]:='4113.INS'; Files.Destionation[11]:='HELP\4113.TXT';
    Files.Source[12]:='4114.INS'; Files.Destionation[12]:='HELP\4114.TXT';
    Files.Source[13]:='4115.INS'; Files.Destionation[13]:='HELP\4115.TXT';
    Files.Source[14]:='4129.INS'; Files.Destionation[14]:='HELP\4129.TXT';
    Files.Source[15]:='4130.INS'; Files.Destionation[15]:='HELP\4130.TXT';
    Files.Source[16]:='4131.INS'; Files.Destionation[16]:='HELP\4131.TXT';
    Files.Source[17]:='4145.INS'; Files.Destionation[17]:='HELP\4145.TXT';
    Files.Source[18]:='4146.INS'; Files.Destionation[18]:='HELP\4146.TXT';
    Files.Source[19]:='4147.INS'; Files.Destionation[19]:='HELP\4147.TXT';
    Files.Source[20]:='4161.INS'; Files.Destionation[20]:='HELP\4161.TXT';
    Files.Source[21]:='4162.INS'; Files.Destionation[21]:='HELP\4162.TXT';
    Files.Source[22]:='4163.INS'; Files.Destionation[22]:='HELP\4163.TXT';
    Files.Source[23]:='4177.INS'; Files.Destionation[23]:='HELP\4177.TXT';
    Files.Source[24]:='4178.INS'; Files.Destionation[24]:='HELP\4178.TXT';
    Files.Source[25]:='4179.INS'; Files.Destionation[25]:='HELP\4179.TXT';
    Files.Source[26]:='4353.INS'; Files.Destionation[26]:='HELP\4353.TXT';
    Files.Source[27]:='4354.INS'; Files.Destionation[27]:='HELP\4354.TXT';
    Files.Source[28]:='8194.INS'; Files.Destionation[28]:='HELP\8194.TXT';
  end;
  Main.Init;
  Main.Install;
  Main.Done;
end.
