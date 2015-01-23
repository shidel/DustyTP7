{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
unit AnsiCrt; {Version 1.00}
{$D-,I-,S-}

interface

const

{ CRT modes }
  BW40          = 0;            { 40x25 B/W on Color Adapter }
  CO40          = 1;            { 40x25 Color on Color Adapter }
  BW80          = 2;            { 80x25 B/W on Color Adapter }
  CO80          = 3;            { 80x25 Color on Color Adapter }
  Mono          = 7;            { Not Supported }
  Font8x8       = 256;          { Not Supported }

{ Mode constants for 3.0 compatibility }
  C40           = CO40;
  C80           = CO80;

{ Foreground and background color constants }
  Black         = 0;
  Blue          = 1;
  Green         = 2;
  Cyan          = 3;
  Red           = 4;
  Magenta       = 5;
  Brown         = 6;
  LightGray     = 7;

{ Foreground color constants }
  DarkGray      = 8;
  LightBlue     = 9;
  LightGreen    = 10;
  LightCyan     = 11;
  LightRed      = 12;
  LightMagenta  = 13;
  Yellow        = 14;
  White         = 15;

{ Add-in for blinking }
  Blink         = 128;

var
{ Interface variables }
  CheckAnsi : boolean;        { Enable Ansi-Control codes }
  CheckBreak: Boolean;        { Enable Ctrl-Break }
  CheckEOF: Boolean;          { Enable Ctrl-Z }
  DirectVideo: Boolean;       { Not Supported }
  CheckSnow: Boolean;         { Not Supported }
  LastMode: Word;             { Current text mode }
  TextAttr: Byte;             { Not Supported }
  WindMin: Word;              { Window upper left coordinates }
  WindMax: Word;              { Window lower right coordinates }
  RedirectedInput : boolean;  { Current Input redirection status }
  RedirectedOutput : boolean; { Current Output redirection status }

{ Interface procedures }
procedure AssignCrt(var F: Text);
function KeyPressed: Boolean;
function ReadKey: Char;
procedure TextMode(Mode: Integer);
procedure Window(X1,Y1,X2,Y2: Byte);
procedure GotoXY(X,Y: Byte);
function WhereX: Byte;
function WhereY: Byte;
procedure ClrScr;
procedure ClrEol;
procedure InsLine; { Not Supported }
procedure DelLine; { Not Supported }
procedure TextColor(Color: Byte);
procedure TextBackground(Color: Byte);
procedure LowVideo;
procedure HighVideo;
procedure NormVideo;
procedure Delay(MS: Word); { Not Supported }
procedure Sound(Hz: Word); { Not Supported }
procedure NoSound;         { Not Supported }

implementation

(* Internal Procedures *)
var
  DosError    : integer;
  CurrentAttr : byte;

function GetDeviceInfoWord(Handle : word) : word; assembler;
  asm
    MOV  AX, 4400h
    MOV  BX, Handle
    INT  21h
    JNC  @OK
    XOR  DX, DX
    JMP  @Done
  @OK:
    XOR  AX, AX
  @Done:
    MOV  DosError, AX
    MOV  AX, DX
  end;

function IsRedirectedInput : boolean;
  begin
    IsRedirectedInput  := (GetDeviceInfoWord(0) and $80 <> $80) and (DosError = 0);
  end;

function IsRedirectedOutput : boolean;
  begin
    IsRedirectedOutput := (GetDeviceInfoWord(1) and $80 <> $80) and (DosError = 0);
  end;

procedure AnsiOut(S : String);
  begin
    if CheckAnsi then
      System.Write(#27'[', S);
  end;

function WhereXY ( var X, Y : integer) : String;
  var
    S1, S2 : String;
    E      : integer;
    P      : integer;
  begin
    X := 0;
    Y := 0;
    AnsiOut('6n');
    if CheckAnsi then
      begin
        S1 := '';
        while Keypressed and (S1[Length(S1)] <> 'R') do S1 := S1 + ReadKey;
        while Keypressed and (ReadKey <> #13) do;
        while Keypressed and (ReadKey <> #10) do;
        Delete(S1, 1, 2);
        if S1 <> '' then Dec(Byte(S1[0]));
        WhereXY := S1 + 'H';
        P := Pos(';', S1);
        if P <> 0 then
          begin
            S2 := Copy(S1, P + 1, Length(S1));
            S1[0] := Chr(P - 1);
          end;
        Val(S2, X, E); if E <> 0 then X := 0;
        Val(S1, Y, E); if E <> 0 then Y := 0;
      end
    else
      WhereXY := '1;1H';
    Inc(X, Lo(WindMin));
    Inc(Y, Hi(WindMin));
  end;

procedure DetectAnsi;
  var
    S : String;
    X, Y : integer;
  begin
    CheckAnsi := False;
    if IsRedirectedInput  or (DosError <> 0) then Exit;
    if IsRedirectedOutput or (DosError <> 0) then Exit;
    S := WhereXY(X, Y);
    if S = '' then
      begin
        Write(#8#8#8#8'    '#8#8#8#8);
        Exit;
      end;
    CheckAnsi := True;
  end;

procedure ChangeAttr;
  var
    AttrStr : String;
    Off     : boolean;

  procedure AppendAttr(S : String);
    begin
      if AttrStr <> '' then
        AttrStr := AttrStr + ';' + S
      else
        AttrStr := S;
    end;

  begin
    AttrStr := '';
    Off := Not ( (CurrentAttr and Blink = TextAttr and Blink) or
     (CurrentAttr and $08 = TextAttr and $08));
    if Off then
      AnsiOut('0m');
    if (TextAttr and Blink = Blink) then AppendAttr('5');
    if (TextAttr and $08 = $08) then AppendAttr('1');
    case TextAttr and $07 of
      Black  : AppendAttr('30');
      Red    : AppendAttr('31');
      Green  : AppendAttr('32');
      Yellow : AppendAttr('33');
      Blue   : AppendAttr('34');
      Magenta: AppendAttr('35');
      Cyan   : AppendAttr('36');
      White  : AppendAttr('37');
    end;
    case (TextAttr and $70) shr 4 of
      Black  : AppendAttr('40');
      Red    : AppendAttr('41');
      Green  : AppendAttr('42');
      Yellow : AppendAttr('43');
      Blue   : AppendAttr('44');
      Magenta: AppendAttr('45');
      Cyan   : AppendAttr('46');
      White  : AppendAttr('47');
    end;
    AnsiOut(AttrStr + 'm');
    CurrentAttr := TextAttr;
  end;

procedure GetWindMax;
  var
    Original   : String;
    A, B, X, Y : integer;
  begin
    if CheckAnsi then
      begin
        Original := WhereXY(X, Y);
        repeat
          A := X;
          B := Y;
          AnsiOut('99B');
          AnsiOut('99C');
          WhereXY ( X, Y );
        until (X = A) and (Y = B);
        if X = 0 then X := 132;
        WindMax := Word(Y - 1) * $0100 + Word(X - 1);
        AnsiOut(Original);
      end
    else
    case LastMode of
      BW40 : WindMax := $1827;
      CO40 : WindMax := $1827;
      BW80 : WindMax := $184F;
      CO80 : WindMax := $184F;
      Mono : WindMax := $184F;
    end;
  end;

(* AnsiCrt Procedures *)
procedure AssignCrt(var F: Text);
  begin
    Assign(F, '');
  end;

function KeyPressed: Boolean; assembler;
  asm
    MOV  AH, 0Bh
    INT  21h
    CMP  AL, 0
    JE   @NoChar
    MOV  AL, True
    JMP  @Done
  @NoChar:
    MOV  AL, False
  @Done:
  end;

function ReadKey: Char; assembler;
  asm
    MOV  AH, 07h
    INT  21h
  end;

procedure TextMode(Mode: Integer);
  begin
    WindMin := $0000;
    case Mode of
      BW40 : AnsiOut('0h');
      CO40 : AnsiOut('1h');
      BW80 : AnsiOut('2h');
      CO80 : AnsiOut('3h');
      Mono : AnsiOut('3h');
    end;
    LastMode := Mode;
    GetWindMax;
  end;

procedure Window(X1,Y1,X2,Y2: Byte);
  begin
{
    WindMin := Word(X1 - 1) + Word(Y1 - 1) * $100;
    WindMax := Word(X2 - 1) + Word(Y2 - 1) * $100;
}
  end;

procedure GotoXY(X,Y: Byte);
  var
    C, R : String[5];
  begin
    Str(X + Lo(WindMin), C);
    Str(Y + Hi(WindMin), R);
    AnsiOut(R + ';' + C + 'H');
  end;

function WhereX: Byte;
  var
    X, Y : integer;
  begin
    WhereXY ( X, Y );
    WhereX := X;
  end;

function WhereY: Byte;
  var
    X, Y : integer;
  begin
    WhereXY ( X, Y );
    WhereY := Y;
  end;

procedure ClrScr;
  begin
    AnsiOut('2J');
  end;

procedure ClrEol;
  begin
    AnsiOut('K');
  end;

procedure InsLine;
  begin
  end;

procedure DelLine;
  begin
  end;

procedure TextColor(Color: Byte);
  begin
    TextAttr := (TextAttr and $70) or Color;
    ChangeAttr;
  end;

procedure TextBackground(Color: Byte);
  begin
    TextAttr := (TextAttr and $8F) or (Color * $10);
    ChangeAttr;
  end;

procedure LowVideo;
  begin
    TextAttr := TextAttr and $F7;
    ChangeAttr;
  end;

procedure HighVideo;
  begin
    TextAttr := TextAttr or $08;
    ChangeAttr;
  end;

procedure NormVideo;
  begin
    TextAttr := $07;
    CurrentAttr := TextAttr;
    AnsiOut('0;37;40m')
  end;

procedure Delay(MS: Word);
  begin
  end;

procedure Sound(Hz: Word);
  begin
  end;

procedure NoSound;
  begin
  end;

procedure InitUnit;
  begin
    RedirectedInput  := IsRedirectedInput;
    RedirectedOutput := IsRedirectedOutput;
    DetectAnsi;
    CheckBreak  := False;
    CheckEOF    := False;
    DirectVideo := False;
    CheckSnow   := False;
    LastMode    := $03;
    TextAttr    := $07;
    WindMin     := $0000;
    WindMax     := $184F;
    CurrentAttr := $00;
    GetWindMax;
  end;

begin
  InitUnit;
end.
