Unit Graphics;

interface
uses Objects;

type
  PPalette = ^TPalette;
  TPalette = array[0..255] of record
    Red, Green, Blue: Byte;
  end;

type
  PScreenPixels = ^TScreenPixels;
  TScreenPixels = array[0..199, 0..319] of Byte;

type { typ opisuj¥cy ekran w trybie 320x200 }
  PScreenObject = ^TScreenObject;
  TScreenObject = object (TObject)
  private
  public
    Visible: PScreenPixels;
    Buffer: PScreenPixels;
    Palette: PPalette;
    SpeedTest: Boolean;
    constructor Init;
    destructor Done; virtual;
    procedure Clear; virtual;
    procedure CopyToBuffer(Data: PScreenPixels); virtual;
    procedure Redraw; virtual;
    procedure WaitVR; virtual;
    procedure GetPalette(Data: PPalette); virtual;
    procedure SetPalette(Data: PPalette); virtual;
  end;

var
  Screen: TScreenObject;

implementation

var
  GraphicsInitialized: Boolean;

{ TScreenObject }

constructor TScreenObject.Init;
begin
  if GraphicsInitialized then Fail
  else
  begin
    inherited Init;
    Visible:=Ptr(SegA000, 0);
    New(Buffer);
    New(Palette);
    asm
      mov ax, $13
      int $10
    end;
    GraphicsInitialized:=True;
  end;
end;

destructor TScreenObject.Done;
begin
  if GraphicsInitialized then
  begin
    Dispose(Palette);
    Dispose(Buffer);
    Palette:=nil;
    Buffer:=nil;
    Visible:=nil;
    asm
      mov ax, $13
      int $10
    end;
    GraphicsInitialized:=False;
    inherited Done;
  end;
end;

procedure TScreenObject.Clear; assembler;
asm
  les di, Screen.Buffer
  mov cx, 16000
  db $66; xor ax, ax
  db $66; rep stosw
end;

procedure TScreenObject.CopyToBuffer; assembler;
asm
  push ds
  les di, Screen.Buffer
  lds si, Data
  mov cx, 16000
  db $66; rep movsw
  pop ds
end;

procedure TScreenObject.Redraw; assembler;
asm
  push ds
  les di, Screen.Visible
  lds si, Screen.Buffer
  mov cx, 16000
  db $66; rep movsw
  pop ds
end;

procedure TScreenObject.WaitVR;
begin
  if SpeedTest then begin Port[$3c8]:=0; Port[$3c9]:=0;Port[$3c9]:=0;Port[$3c9]:=0; End;
  repeat until Port[$3DA] and 8<>0;
  repeat until Port[$3DA] and 8=0;
  if SpeedTest then begin Port[$3c8]:=0; Port[$3c9]:=63;Port[$3c9]:=63;Port[$3c9]:=63; End;
end;

procedure TScreenObject.GetPalette;
var
  I: Integer;
begin
  if not Assigned(Data) then Exit;
  Port[$3C7]:=0;
  for I:=0 to 255 do with Data^[I] do
  begin
    Red:=Port[$3C9];
    Green:=Port[$3C9];
    Blue:=Port[$3C9];
  end;
end;

procedure TScreenObject.SetPalette;
var
  I: Integer;
begin
  if not Assigned(Data) then Exit;
  Port[$3C8]:=0;
  for I:=0 to 255 do with Data^[I] do
  begin
    Port[$3C9]:=Red;
    Port[$3C9]:=Green;
    Port[$3C9]:=Blue;
  end;
end;

begin
  GraphicsInitialized:=False;
end.

