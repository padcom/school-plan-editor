Unit Pictures;

interface
uses Objects, Graphics;

type
  PPictureObject = ^TPictureObject;
  TPictureObject = object (TObject)
  private
    FFileName: String;
  public
    Palette: PPalette;
    Data: PScreenPixels;
    constructor Load(AFileName: String);
    destructor Done; virtual;
    procedure Draw; virtual;
  end;

type
  TBMPPictureHeader = record
    Id: array[0..1] of Char;
    FileSize: LongInt;
    Reserved: array[0..3] of Byte;
    BitmapOffset: LongInt;
    HeaderLength: LongInt;
    Width: LongInt;
    Height: LongInt;
    NumberOfPlanes: Word;
    BPP: Word;
    CompressionType: LongInt;
    PictureSize: LongInt;
    HorizontalResolution: LongInt;
    VerticalResolution: LongInt;
    NumberOfUsedColors: LongInt;
    NumberOfImportantColors: LongInt;
  end;

type
  PBMPPictureObject = ^TBMPPictureObject;
  TBMPPictureObject = object (TPictureObject)
    Header: TBMPPictureHeader;
    constructor Load(AFileName: String);
  end;

implementation

{ TPictureObject }

constructor TPictureObject.Load;
begin
  inherited Init;
  FFileName:=AFileName;
  New(Data);
  New(Palette);
  FillChar(Data^, SizeOf(Data^), 0);
  FillChar(Palette^, SizeOf(Palette^), 0);
end;

destructor TPictureObject.Done;
begin
  Dispose(Data);
  Dispose(Palette);
  Data:=nil;
  Palette:=nil;
  inherited Done;
end;

procedure TPictureObject.Draw;
begin
  Screen.CopyToBuffer(Data);
end;

{ TBMPPictureObject }

constructor TBMPPictureObject.Load;
var
  F: File;
  I, X, Y: Integer;
  B: array[1..4096] of Byte;
  Error: Integer;
begin
  inherited Load(AFileName);

  Assign(F, FFileName);
  {$I-} Reset(F, 1); {$I+}
  if IOResult=0 then
  begin
    FillChar(Data^, SizeOf(Data^), 1);
    BlockRead(F, Header, SizeOf(Header));
    for I:=0 to Header.NumberOfUsedColors-1 do with Palette^[I] do
    begin
      BlockRead(F, B, 4);
      Red  :=B[3] shr 2;
      Green:=B[2] shr 2;
      Blue :=B[1] shr 2;
    end;
    Seek(F, Header.BitmapOffset);
    for Y:=Header.Height-1 downto 0 do
    begin
      BlockRead(F, B, Header.Width);
      for X:=0 to Header.Width-1 do Data^[Y, X]:=B[X+1];
    end;
    Close(F);
  end
  else Fail;
end;

begin
end.
