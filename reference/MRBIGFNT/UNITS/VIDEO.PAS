{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

{ Reguires EGA/VGA. Although, many of the routines that have the same names
  and work similar to those in Borland's CRT unit, they are NOT compatable
  and should not be used in the same application.  Also, this text mode
  video extenetion unit is NOT compatible with any of Borland's Turbo Vision
  video character I/O routines. }

{$G-}       (* 8086/8087 compatible *)
{$A+,B-}    (* Byte alignment, short-circut boolean *)
{$E+,N+}    (* Emulation, coprocessor *)
{$F+,O-}    (* Farcalls, and no overlays *)
{$R-,Q-,S-} (* No range, overflow or stack checking *)
{$I-}       (* No I/O checking *)
{$D-,L-,Y-} (* No Debug, label or symbol information *)
{$P-,V+}    (* No open string parameters, with strict type-checking *)
{$T-}       (* No type-checked pointers *)
{$X+}       (* Enable extended syntax *)
unit Video;

interface

  const
{ Video mode constants }
    BW40         = 0;
    CO40         = 1;
    BW80         = 2;
    CO80         = 3;
    Mono         = 7;

    C40          = CO40;
    C80          = CO80;

{ Add-in video fonts constants }
    Font8x8      = $0800; { CGA, EGA, VGA+ }
    Font8x14     = $0E00; { EGA, VGA+ }
    Font8x16     = $1000; { VGA+ }

{ Foreground and Background color constants }
    Black        = 0;
    Blue         = 1;
    Green        = 2;
    Cyan         = 3;
    Red          = 4;
    Magenta      = 5;
    Brown        = 6;
    LightGray    = 7;

{ Foreground color constants }
    DargGray     = 8;
    LightBlue    = 9;
    LightGreen   = 10;
    LightCyan    = 11;
    LightRed     = 12;
    LightMagenta = 13;
    Yellow       = 14;
    White        = 15;

{ Add-in for blinking or background intensity constants }
    Blink        = 128;
    Intense      = Blink;

{ TTL Monochrome attributes constants }
    Underline               = $01;
    Normal                  = $07;
    BrightUnderline         = $09;
    Bold                    = $0F;
    Reverse                 = $70;
    BlinkingUnderline       = $81;
    BlinkingNormal          = $87;
    BlinkingBrightUnderline = $89;
    BlinkingBold            = $8F;

{ One-Color composite attributes  constants }
   {Normal                  = $07;}
    GrayOnBlack             = $08;
   {Bold                    = $0F;}
   {Reverse                 = $70;}
    GrayOnWhite             = $78;
    WhiteOnWhite            = $7F;
   {BlinkingNormal          = $87;}
   {BlinkingBold            = $8F;}

  type
    PaletteType = 0..15;
    RGBColor = record
      Red, Green, Blue : byte;
    end;

  var
{ CRT equivilant variables }
    CheckBreak  : boolean; { Enables Ctrl-Break checking }
    CheckEOF    : boolean; { Doesn't do anything }
    DirectVideo : boolean; { Enables Fast Direct Video Reads/Writes }
    CheckSnow   : boolean; { Doesn't do anything }
    LastMode    : word;
    TextAttr    : byte;    { Same as CRT but page independent }
    WindMin     : word;    { Same as CRT but page independent }
    WindMax     : word;    { Same as CRT but page independent }

{ More Variables }
    BreakCount  : word;    { Incremented if CheckBreak is false and
                             Ctrl-Break is sensed }
    CheckScroll : boolean; { Enables window scrolling when writing on
                             bottom line }
    CheckCursor : boolean; { Enables Automatic cursor movement }
    Keyboard101 : boolean; { Enable extended 101 key keyboard interface }
    Monochrome  : boolean; { Monochrome video mode flag }

{ Character used for filling screen in ClrScr, ClrEOL, InsLine, DelLine,
  DelChar, InsColumn, DelColumn, etc.  NOTE: Background character is only
  used when operating in direct video mode.  Also page independent. }
    BackGround  : Char;

{ Startup video mode/font, cursor, blink/Intensity, text attribute, alter
  these variables if you wish to keep a video mode, cursor, blink state
  after the program terminates. }
    FirstMode   : word;
    FirstCursor : word;
    FirstBlink  : boolean;
    FirstAttr   : byte;

{ Procedure called while a delay is being processed }
    VideoIdle   : procedure;

{ The following variables are read only, and are provided for use in fast
  assembly language procedures, directly altering them can produce
  undesirable results. }
    VideoSeg    : word;  { Video segment }
    ActivePage  : byte;  { Active page number }
    ActiveOfs   : word;  { Offset from video segment to active page }
    VisualPage  : byte;  { Visual page number }
    VisualOfs   : word;  { Offset from video segment to visual page }
    VideoPort   : word;  { Video I/O base port }
    VideoRegen  : word;  { Size of video regen buffer (Page Size) }
    Columns     : word;  { Total video columns }
    Rows        : word;  { Total Video Rows }
    MaxPage     : byte;  { Total Available Video Pages }
    CurrentXY   : word;  { Current active page's absolute cursor position }
    PageData : Array[0..7] of record  { variables used to tracking windows }
      Free       : boolean;           { across multiple video pages }
      CurrentXY,
      WindMin,
      WindMax    : word;
      TextAttr   : byte;
      Background : char;
    end;

{ procedures/functions that work like (not same as) there CRT equivialants }
  procedure TextMode ( Mode : word );
  procedure GotoXY ( X, Y : byte );
  function  WhereX : byte;
  function  WhereY : byte;
  procedure Window ( X1, Y1, X2, Y2 : byte );
  procedure ClrScr;
  procedure ClrEol;
  procedure InsLine;
  procedure DelLine;
  procedure TextColor ( Color : byte );
  procedure TextBackground ( Color : byte );
  procedure LowVideo;
  procedure HighVideo;
  procedure NormVideo;
  procedure Delay(MS : Word);
  procedure Sound ( Freq : Word );
  procedure NoSound;
  function Keypressed : boolean;
  function ReadKey : String;

{ Procedures/Functions not provided by CRT unit; - means will only work when
  operating in direct video mode, ie. cannot us in graphics modes; + means
  will work any time. }
  procedure InitVideo;
  {+ Call InitVideo if a mode or font is changed by an external procedure }
  function  GetCursor : word;
  {+ Returns the current cursors size/shape }
  procedure SetCursor ( Cursor : word );
  {+ Sets then current cursors size/shape }
  function  GetBlink : boolean;
  {+ Returns True if background intensity bit is used for blinking foreground }
  procedure SetBlink ( Blink : boolean );
  {+ Toggles between foreground blink and background intensity }
  function  WhereXY : word;
  {+ Returns absolute screen coordinates, same as
     (WINDMin + WhereX + WhereY * 256) }
  procedure GotoABSXY ( XY : word );
  {+ Same as Goto but goes to Absoulute Screen Coordinates }
  function  GetVideoOfs ( Start : word ) : Word;
  {+ Returns Offset from Video Segment for Active page and cursor position }
  procedure InsChar ( C : Char );
  {- Inserts a character, shifts characters to the right }
  procedure DelChar;
  {- Deletes a character, shifts characters to the left }
  procedure InsColumn;
  {- Inserts a column, shifts characters to the right }
  procedure DelColumn;
  {- Deletes a column, shifts characters to the left }
  procedure Speaker ( On : boolean );
  {+ Direct speaker state control, Manually create frequences }
  procedure TimerSound ( Val : word );
  {+ Direct timer based frequencey control }
  procedure RealSound ( Freq : Real );
  {+ Like Sound but more accurate }
  procedure Beep;
  {+ Generates sound similar to BEL character }
  function Return : word;
  {+ Equivilant to carriage return/line feed; returns new absolute screen
     coordinates }
  function SoftReturn ( XY : word ): word;
  {+ Same as Return except cursor is not moved }
  procedure Write ( S : String );
  {+ Writes any character (including BEL, CR, LF, etc.) to active video page }
  procedure WriteLn ( S : String );
  {+ Like Write but adds a call to return }
  procedure MoveCursor;
  {+ Moves cursor to current position, use if check cursor is false }
  procedure StoreActiveSettings;
  {+ Stores active page settings in tracking table }
  procedure RestoreActiveSettings;
  {+ Restores active page settings from tracking table }
  procedure SetVisualPage ( Page : Byte );
  {- Sets the current displayed video page }
  function SetActivePage ( Page : byte ) : word;
  {- Changes video page for text I/O functions/procedures }
  procedure CopyPage ( FromPage, ToPage : byte );
  {- Duplicates a video page }
  procedure CopyWindow ( FromPage, ToPage : byte );
  {- Duplicates a window between pages }
  function RequestPage : Byte;
  {- Returns the next available video page and makes that page unavailable.
     if No Pages are available then $FF is returned. NOTE: this fuction
     does not prevent text from being written to previosly allocated video
     page, it only tracks unused pages. }
  procedure ReleasePage ( Page : Byte );
  {- Releases a video page for use by another process. }
  procedure GetIntVec ( IntNo : byte; var Vec : pointer );
  {+ Works like GetIntVec in Borland's DOS unit }
  procedure SetIntVec ( IntNo : byte; Vec : pointer );
  {+ Works like SetIntVec in Borland's DOS unit }
  procedure NormalCursor;
  {+ Returns Cursor to size and shape of cursor at startup }
  procedure HideCursor;
  {+ Hides the cursor }
  procedure SmallCursor;
  {+ Makes cursor 2 scan lines high }
  procedure HalfCursor;
  {+ Makes cursor on half of the characters height }
  procedure FullCursor;
  {+ Makes cursor same size as characters }

{RGB Color/palette functions}
  procedure SetPalette ( Palette : PaletteType; DACreg : byte );
  {+ Assigns a DAC register to a palette number; Only valid for modes with
     less then 256 colors }
  procedure SetAllPalettes ( const Palettes );
  {+ Only valid for modes with less then 256 colors, 16 palettes + 1
     overscan = 17 byte buffer }
  procedure SetOverscan ( DACreg : byte );
  {+ Assigns DAC color register to the over scan border }
  procedure SetRGBColor ( DACReg : word; const Color );
  {+ Sets one DAC Color register }
  procedure SetRGBBlock ( First, Count : word; const Colors );
  {+ Sets a block of DAC color registers }
  procedure GetPalette ( Palette : PaletteType; var DACreg : byte );
  {+ Returns DAC color assignment for Palette; Not for 256 color modes }
  procedure GetAllPalettes ( var Palettes );
  {+ Returns 16 palettes + 1 overscan = 17 byte buffer; Not for 256 color modes }
  procedure GetOverscan ( var DACreg : byte );
  {+ Returns DAC color assignment for the over scan border }
  procedure GetRGBColor ( DACReg : word; var Color );
  {+ Returns one DAC Color register (3 bytes) }
  procedure GetRGBBlock ( First, Count : word; var Colors );
  {+ Returns a block of DAC color registers (3 * Count = Bytes) }

implementation
{----------------------------------------------------------------------------}
  type
    BIOSDataType = record
      Mode            : byte;
      Columns         : word;
      Regen           : word;
      VisualOfs       : word;
      Location        : array[0..7] of word;
      CursorSize      : word;
      VisualPage      : byte;
      Port            : word;
      CRTMode         : byte;
      CRTPalette      : byte;
      PostData        : array[0..4] of byte;
      TimerTickCount  : longint;
      TimerOverflow   : byte;
      BreakFlag       : byte;
      RebootData      : word;
      ATHardDiskData  : longint;
      PrinterTimeOut  : longint;
      SerialTimeOut   : longint;
      ATKeyboardStart : word;
      ATKeyboardEnd   : word;
      Rows            : byte;
      CharSize        : word;
      EGAMiscInfo     : word;
    end;

  var
    { BIOS Data area record pointer }
    BIOS        : ^BiosDataType;
    OldExitProc : pointer;
{----------------------------------------------------------------------------}
  function GetBIOSXY ( Page : Byte ) : word; assembler;
    asm
      MOV AH, $03
      MOV BH, Page
      INT $10
      MOV AX, DX
    end;

  procedure InitVideo;
    var
      I : Byte;
    begin
      VideoPort   := BIOS^.Port;
      Columns     := BIOS^.Columns;
      Rows        := BIOS^.Rows + 1;
      LastMode    := BIOS^.Mode + (Word(BIOS^.CharSize) Shl 8);
      VisualPage  := BIOS^.VisualPage;
      VisualOfs   := BIOS^.VisualOfs;
      VideoRegen  := BIOS^.Regen;
      if VideoRegen > 0 then
        MaxPage := ($8000 div VideoRegen) - 1
      else
        MaxPage := 0;
      if (LastMode and $FF <> 7) and (LastMode and $FF > 3) then
        MaxPage := 0;
      if MaxPage > 7 then MaxPage := 7;
      ActivePage  := VisualPage;
      ActiveOfs   := VisualOfs;
      Monochrome  := VideoPort = $03B4;
      WindMin     := $0000;
      WindMax     := (Columns - 1) + ((Rows - 1) Shl 8);
      CurrentXY   := GetBIOSxy( ActivePage );
      TextAttr    := LightGray;
      BackGround  := #$20;
      Case LastMode and $FF of
        BW40, CO40, BW80, CO80 : VideoSeg := SegB800;
        Mono                   : VideoSeg := SegB000;
      else
        VideoSeg := SegA000;
      end;
      DirectVideo := VideoSeg <> SegA000;
      for I := 0 to MaxPage do
        begin
          PageData[I].CurrentXY  := GetBIOSxy ( I );
          PageData[I].WindMin    := WindMin;
          PageData[I].WindMax    := WindMax;
          PageData[I].TextAttr   := TextAttr;
          PageData[I].Background := BackGround;
          PageData[I].Free       := True;
        end;
    end;

  { NUL Video Idle }
  procedure NULLVideoIdle; far; assembler;
    asm
    end;

{----------------------------------------------------------------------------}
  procedure TextMode ( Mode : word ); assembler;
    asm
      MOV AX, Mode
      XOR AH, AH
      INT $10
      MOV CX, Mode
      XOR CL, CL
      CMP CX, 0
      JE  @@Done
      MOV AL, $12
      CMP CX, Font8x8
      JE  @@LoadFont
      MOV AL, $11
      CMP CX, Font8x14
      JE  @@LoadFont
      MOV AL, $14
      CMP CX, Font8x16
      JE  @@LoadFont
      JMP @@Done
    @@LoadFont:
      MOV AH, $11
      MOV BL, 0 { Font block to Load }
      INT $10
    @@Done:
      CALL InitVideo
    end;

  function GetCursor : word; assembler;
    asm
      MOV AH, $03
      MOV BH, ActivePage
      INT $10
      MOV AX, CX
    end;

  procedure SetCursor ( Cursor : word ); assembler;
    asm
      MOV  AH, $01
      MOV  CX, Cursor
      INT  $10
    end;

  function GetBlink : boolean; assembler;
    asm
      MOV  AX, Seg0040
      MOV  ES, AX
      MOV  CL, ES:[$0065] { CRT_Mode }
      AND  CL, $20
      MOV  AL, True
      CMP  CL, $20
      JE   @@Done
      MOV  AL, False
    @@Done:
    end;

  procedure SetBlink ( Blink : boolean ); assembler;
    asm
      MOV AX, $1003
      MOV BL, Blink
      INT $10
    end;

  procedure GotoABSXY ( XY : Word ); assembler;
    asm
      MOV DX, XY
      MOV CurrentXY, DX
      CMP CheckCursor, True
      JNE @@Done
      MOV AH, $02
      MOV BH, ActivePage
      INT $10
    @@Done:
    end;

  procedure MoveCursor; assembler;
    asm
      MOV AH, $02
      MOV BH, ActivePage
      MOV DX, CurrentXY
      INT $10
    end;

  procedure GotoXY ( X, Y : byte ); assembler;
    asm
      MOV  DL, X
      MOV  DH, Y
      CMP  DH, 0
      JE   @@Done
      CMP  DL, 0
      JE   @@Done
      SUB  DX, $0101
      MOV  CX, WindMax
      SUB  CX, WindMin
      CMP  DH, CH
      JA   @@Done
      CMP  DL, CL
      JA   @@Done
      ADD  DX, WindMin
      PUSH DX
      CALL GotoABSXY
    @@Done:
    end;

  function WhereX : byte; assembler;
    asm
      MOV DX, CurrentXY
      MOV CX, WindMin
      SUB DL, CL
      ADD DL, 1
      MOV AL, DL
    end;

  function WhereY : byte; assembler;
    asm
      MOV DX, CurrentXY
      MOV CX, WindMin
      SUB DH, CH
      ADD DH, 1
      MOV AL, DH
    end;

  function WhereXY : word; assembler;
    asm
      MOV AX, CurrentXY
    end;

  procedure Window ( X1, Y1, X2, Y2 : byte ); assembler;
  { will swap X1 & X2 if X1 > X2; same for Y1 & 2.
    if (X1 < 1) or (X2 > Columns) or (Y1 < 1) or (Y2 > Rows) then No Change }
    asm
      MOV  CL, X1
      MOV  CH, Y1
      MOV  DL, X2
      MOV  DH, Y2
      CMP  DL, CL
      JNB  @@Window2
      XCHG DL, CL
    @@Window2:
      CMP  DH, CH
      JNB  @@Window3
      XCHG DH, CH
    @@Window3:
      CMP  CH, $00
      JE   @@Done
      CMP  CL, $00
      JE   @@Done
      XOR  AX, AX
      MOV  AL, DL
      CMP  AX, Columns
      JA   @@Done
      MOV  AL, DH
      CMP  AX, Rows
      JA   @@Done
      SUB  CX, $0101
      SUB  DX, $0101
      MOV  WindMin, CX
      MOV  WindMax, DX
    @@Done:
    {$IFOPT G+}
      PUSH 1
      PUSH 1
    {$ELSE}
      MOV  AX, 1
      PUSH AX
      PUSH AX
    {$ENDIF}
      CALL GotoXY
    end;

  procedure ClrScr; assembler;
    asm
      MOV  CX, WindMin
      MOV  DX, WindMax
      MOV  BH, TextAttr
      MOV  BL, BackGround
      CMP  DirectVideo, False
      JNE  @@ClrScr2
      { Only clears current visual page }
      MOV  AX, $0600
      INT  $10
      JMP  @@Done
    @@ClrScr2:
      SUB  DX, CX { Becomes 0-based range }
      PUSH DX
      MOV  DX, Columns
      SHL  DX, 1
      MOV  DI, ActiveOfs
      MOV  AX, DX { COMPUTE ROW OFFSET }
      MUL  CH
      ADD  DI, AX
      XOR  AX, AX { Compute Columns Offset }
      MOV  AL, CL
      SHL  AX, 1
      ADD  DI, AX
      MOV  AX, VideoSeg
      MOV  ES, AX { Load Video Segment as Data Segment }
      POP  CX  { MOV  CX, 0-BASED Range }
      ADD  CX, $0101
      MOV  AX, BX
      CLD
    @@ClrScr3:
      PUSH CX
      PUSH DI
      XOR  CH, CH
      REP  STOSW
      POP  DI
      POP  CX
      ADD  DI, DX
      DEC  CH
      JNZ  @@ClrScr3
    @@Done:
    {$IFOPT G+}
      PUSH 1
      PUSH 1
    {$ELSE}
      MOV  AX, 1
      PUSH AX
      PUSH AX
    {$ENDIF}
      CALL GotoXY
    end;

  procedure ClrEol; assembler;
    asm
      MOV  AX, CurrentXY
      MOV  CX, AX
      MOV  DX, WindMax
      MOV  DH, CH
      MOV  BH, TextAttr
      MOV  BL, BackGround
      CMP  DirectVideo, False
      JNE  @@ClrEol2
      { Only clears current visual page }
      MOV  AX, $0600
      INT  $10
      JMP  @@Done
    @@ClrEol2:
      SUB  DX, CX { Becomes 0-based range }
      PUSH DX
      MOV  DX, Columns
      SHL  DX, 1
      MOV  DI, ActiveOfs
      MOV  AX, DX { COMPUTE ROW OFFSET }
      MUL  CH
      ADD  DI, AX
      XOR  AX, AX { Compute Columns Offset }
      MOV  AL, CL
      SHL  AX, 1
      ADD  DI, AX
      MOV  AX, VideoSeg
      MOV  ES, AX { Load Video Segment as Data Segment }
      POP  CX  { MOV  CX, 0-BASED Range }
      ADD  CL, $01
      MOV  AX, BX
      CLD
      XOR  CH, CH
      REP  STOSW
    @@Done:
    end;

  procedure InsLine; assembler;
    asm
      MOV  AX, CurrentXY
      MOV  CX, AX
      MOV  AX, WindMin
      MOV  CL, AL
      MOV  DX, WindMax
      MOV  BH, TextAttr
      MOV  BL, BackGround
      CMP  DirectVideo, False
      JNE  @@InsLine2
      MOV  AX, $0701
      INT  $10
      JMP  @@Done
    @@InsLine2:
      MOV  AX, DX
      SUB  DX, CX { Becomes 0-based range }
      PUSH DX
      MOV  CH, AH
      MOV  DX, Columns
      SHL  DX, 1
      MOV  DI, ActiveOfs
      MOV  AX, DX { COMPUTE ROW OFFSET }
      MUL  CH
      ADD  DI, AX
      XOR  AX, AX { Compute Columns Offset }
      MOV  AL, CL
      SHL  AX, 1
      ADD  DI, AX
      MOV  AX, VideoSeg
      MOV  ES, AX { Load Video Segment as Data Segment }
      POP  CX  { MOV  CX, 0-BASED Range }
      ADD  CX, $0001
      MOV  AX, BX
      CLD
      CMP  CH, 0
      JE   @@InsLine4
      PUSH DS
      PUSH ES; POP DS { MOV ES, DS }
      MOV  SI, DI
      SUB  SI, DX
    @@InsLine3:
      PUSH CX
      PUSH DI
      PUSH SI
      XOR  CH, CH
      REP  MOVSW
      POP  SI
      POP  DI
      POP  CX
      SUB  DI, DX
      SUB  SI, DX
      DEC  CH
      JNZ  @@InsLine3
      POP  DS
    @@InsLine4:
      XOR  CH, CH
      REP  STOSW
    @@Done:
    end;

  procedure DelLine; assembler;
    asm
      MOV  AX, CurrentXY
      MOV  CX, AX
      MOV  AX, WindMin
      MOV  CL, AL
      MOV  DX, WindMax
      MOV  BH, TextAttr
      MOV  BL, BackGround
      CMP  DirectVideo, False
      JNE  @@DelLine2
      MOV  AX, $0601
      INT  $10
      JMP  @@Done
    @@DelLine2:
      SUB  DX, CX { Becomes 0-based range }
      PUSH DX
      MOV  DX, Columns
      SHL  DX, 1
      MOV  DI, ActiveOfs
      MOV  AX, DX { COMPUTE ROW OFFSET }
      MUL  CH
      ADD  DI, AX
      XOR  AX, AX { Compute Columns Offset }
      MOV  AL, CL
      SHL  AX, 1
      ADD  DI, AX
      MOV  AX, VideoSeg
      MOV  ES, AX { Load Video Segment as Data Segment }
      POP  CX  { MOV  CX, 0-BASED Range }
      ADD  CX, $0001
      MOV  AX, BX
      CLD
      CMP  CH, 0
      JE   @@DelLine4
      PUSH DS
      PUSH ES; POP DS { MOV ES, DS }
      MOV  SI, DI
      ADD  SI, DX
    @@DelLine3:
      PUSH CX
      PUSH DI
      PUSH SI
      XOR  CH, CH
      REP  MOVSW
      POP  SI
      POP  DI
      POP  CX
      ADD  DI, DX
      ADD  SI, DX
      DEC  CH
      JNZ  @@DelLine3
      POP  DS
    @@DelLine4:
      XOR  CH, CH
      REP  STOSW
    @@Done:
    end;

  procedure TextColor ( Color : byte ); assembler;
    asm
      MOV AL, TextAttr
      AND AL, 01110000b
      OR  AL, Color
      MOV TextAttr, AL
    end;

  procedure TextBackground ( Color : byte ); assembler;
    asm
      MOV AL, TextAttr
      AND AL, 00001111b
      MOV AH, Color
      {$IFOPT G+}
      SHL AH, 4
      {$ELSE}
      MOV CL, 4
      SHL AH, CL
      {$ENDIF}
      OR  AL, AH
      MOV TextAttr, AL
    end;

  procedure LowVideo; assembler;
    asm
      MOV  AL, TextAttr
      AND  AL, 11110111b
      MOV  TextAttr, AL
    end;

  procedure HighVideo; assembler;
    asm
      MOV  AL, TextAttr
      OR   AL, 00001000b
      MOV  TextAttr, AL
    end;

  procedure NormVideo; assembler;
    asm
      MOV  AL, FirstAttr
      MOV  TextAttr, AL
    end;

{$IFOPT G+}
  procedure Delay(MS : Word); assembler;
    asm
      JMP @@Delay2
    @@DelayFlag:
      DB  0
    @@Delay2:
      MOV  AX, $8301 { Cancel Event Wait }
      INT  $15
      MOV  AX, $8300
      MOV  CS:[OFFSET @@DelayFlag], AL
      MOV  DX, MS
      MOV  CX, DX
      SHL  DX, 10
      SHR  CX, 6
      PUSH CS; POP ES { MOV  ES, CS }
      MOV  BX, OFFSET @@DelayFlag
      INT  $15
    @@Delay3:
      CALL VideoIdle
      MOV  AL, CS:[OFFSET @@DelayFlag]
      AND  AL, $80
      CMP  AL, $80
      JNE  @@Delay3
    end;
{$ELSE}
  procedure Delay ( MS : word );
    var
      Last : LongInt;
    begin
      Last := 0;
      MS := (MS div 55) + 1;
      While (MS > 0) do
        begin
          VideoIdle;
          if MemL[Seg0040:$006C] <> Last then
            begin
              Last := MemL[Seg0040:$006C];
              DEC ( MS );
            end;
        end;
    end;
{$ENDIF}

  procedure NoSound; assembler;
    asm
      MOV  DX, 061h
      IN   AL, DX
      AND  AL, 11111101b
      OR   AL, 00000001b
      OUT  DX, AL
      MOV  AL, 10110110b
      MOV  DX, 043h
      OUT  DX, AL
      MOV  DX, 042h
      MOV  AL, 0
      OUT  DX, AL
      OUT  DX, AL
    end;

  procedure Speaker ( On : boolean ); assembler;
    asm
      MOV  DX, 061h
      IN   AL, DX
      AND  AL, 11111100b
      MOV  BL, On
      SHL  BL, 1
      OR   AL, BL
      OUT  DX, AL
    end;

  procedure TimerSound ( Val : word ); assembler;
    asm
      MOV  AL, 10110110b
      MOV  DX, 043h
      OUT  DX, AL
      MOV  DX, 042h
      MOV  AX, Val
      OUT  DX, AL
      MOV  AL, AH
      OUT  DX, AL
      MOV  DX, 061h
      IN   AL, DX
      AND  AL, 11111111b
      OR   AL, 00000011b
      OUT  DX, AL
    end;

  procedure RealSound ( Freq : Real );
    begin
      if Freq > 0 then
        TimerSound ( Trunc(1193180 / Freq));
    end;

  procedure Sound ( Freq : Word );
    begin
      if Freq > 0 then
        TimerSound ( 1193180 div Freq );
    end;

  procedure Beep;
    begin
      TimerSound ( 1028 );
      Delay ( 400 );
      NoSound;
      Delay ( 10 );
    end;
{----------------------------------------------------------------------------}
  function GetVideoOfs ( Start : word ) : Word; assembler;
    asm
      MOV  CX, Start
      MOV  AX, Columns
      SHL  AX, 1
      MUL  CH
      XOR  CH, CH
      SHL  CX, 1
      ADD  AX, CX
      ADD  AX, ActiveOfs
    end;

  procedure InsChar; assembler;
    asm
      CMP  DirectVideo, False
      JE   @@Done
      MOV  AX, CurrentXY
      MOV  DX, WindMax
      SUB  DX, AX
      PUSH AX; CALL GetVideoOfs { function ( Start : word ) : word; }
      MOV  DI, AX
      XOR  DH, DH
      MOV  CX, DX
      SHL  DX, 1
      ADD  DI, DX
      PUSH DS
      MOV  AX, VideoSeg
      MOV  ES, AX
      MOV  AH, TextAttr
      MOV  AL, C
      PUSH ES; POP DS { MOV DS, ES }
      MOV  SI, DI
      SUB  SI, 2
      STD
      REP  MOVSW
      STOSW
      POP  DS
    @@Done:
    end;

  procedure DelChar; assembler;
    asm
      CMP  DirectVideo, False
      JE   @@Done
      MOV  AX, CurrentXY
      MOV  CX, WindMax
      SUB  CX, AX
      PUSH AX; CALL GetVideoOfs { function ( Start : word ) : word; }
      MOV  DI, AX
      XOR  CH, CH
      PUSH DS
      MOV  AX, VideoSeg
      MOV  ES, AX
      MOV  AH, TextAttr
      MOV  AL, BackGround
      PUSH ES; POP DS { MOV DS, ES }
      MOV  SI, DI
      ADD  SI, 2
      CLD
      REP  MOVSW
      STOSW
      POP  DS
    @@Done:
    end;

  procedure InsColumn; assembler;
    asm
      CMP  DirectVideo, False
      JE   @@Done
      MOV  AX, CurrentXY
      MOV  DX, WindMin
      MOV  AH, DH
      MOV  DX, WindMax
      SUB  DX, AX
      PUSH AX; CALL GetVideoOfs { function ( Start : word ) : word; }
      MOV  DI, AX
      MOV  CX, DX
      XOR  DH, DH
      SHL  DX, 1
      ADD  DI, DX
      MOV  DX, Columns
      SHL  DX, 1
      PUSH DS
      MOV  AX, VideoSeg
      MOV  ES, AX
      MOV  AH, TextAttr
      MOV  AL, Background
      PUSH ES; POP DS { MOV DS, ES }
      MOV  SI, DI
      SUB  SI, 2
      ADD  CX, $0100
    @@Ins2:
      PUSH CX
      PUSH SI
      PUSH DI
      XOR  CH, CH
      STD
      REP  MOVSW
      STOSW
      POP  DI
      POP  SI
      POP  CX
      ADD  DI, DX
      ADD  SI, DX
      DEC  CH
      JNZ  @@Ins2
      POP  DS
    @@Done:
    end;

  procedure DelColumn; assembler;
    asm
      CMP  DirectVideo, False
      JE   @@Done
      MOV  AX, CurrentXY
      MOV  CX, WindMin
      MOV  AH, CH
      MOV  CX, WindMax
      SUB  CX, AX
      PUSH CX
      PUSH AX; CALL GetVideoOfs { function ( Start : word ) : word; }
      POP  CX
      MOV  DI, AX
      MOV  DX, Columns
      SHL  DX, 1
      PUSH DS
      MOV  AX, VideoSeg
      MOV  ES, AX
      MOV  AH, TextAttr
      MOV  AL, BackGround
      PUSH ES; POP DS { MOV DS, ES }
      MOV  SI, DI
      ADD  SI, 2
      ADD  CX, $0100
    @@Del2:
      PUSH CX
      PUSH SI
      PUSH DI
      XOR  CH, CH
      CLD
      REP  MOVSW
      STOSW
      POP  DI
      POP  SI
      POP  CX
      ADD  DI, DX
      ADD  SI, DX
      DEC  CH
      JNZ  @@Del2
      POP  DS
    @@Done:
    end;

  function Return : word; assembler;
    asm
      PUSH SI
      PUSH DI
      PUSH ES
      MOV  AX, CurrentXY
      MOV  CX, WindMin
      MOV  DX, WindMax
      MOV  BH, TextAttr
      MOV  BL, BackGround
      INC  AH
      CMP  AH, DH
      JBE  @@Done
      DEC  AH
      CMP  CheckScroll, True
      JNE  @@TopCorner
      CMP  DirectVideo, False
      JNE  @@Return2
      PUSH AX
      MOV  AX, $0601
      INT  $10
      POP  AX
      JMP  @@Done
    @@Return2:
      PUSH AX
      PUSH CX
      SUB  DX, CX        { Becomes 0-based range }
      PUSH DX
      MOV  DX, Columns
      SHL  DX, 1
      MOV  DI, ActiveOfs
      MOV  AX, DX        { COMPUTE ROW OFFSET }
      MUL  CH
      ADD  DI, AX
      XOR  AX, AX        { Compute Columns Offset }
      MOV  AL, CL
      SHL  AX, 1
      ADD  DI, AX
      MOV  AX, VideoSeg
      MOV  ES, AX        { Load Video Segment as Data Segment }
      POP  CX            { MOV  CX, 0-BASED Range }
      ADD  CX, $0001
      MOV  AX, BX
      CLD
      CMP  CH, 0
      JE   @@Return4
      PUSH DS
      PUSH ES; POP DS    { MOV ES, DS }
      MOV  SI, DI
      ADD  SI, DX
    @@Return3:
      PUSH CX
      PUSH DI
      PUSH SI
      XOR  CH, CH
      REP  MOVSW
      POP  SI
      POP  DI
      POP  CX
      ADD  DI, DX
      ADD  SI, DX
      DEC  CH
      JNZ  @@Return3
      POP  DS
    @@Return4:
      XOR  CH, CH
      REP  STOSW
      POP  CX
      POP  AX
      JMP  @@Done
    @@TopCorner:
      MOV  AX, WindMin
    @@Done:
      MOV  BX, WindMin
      MOV  AL, BL
      PUSH AX
      SUB  AH, CH
      ADD  AH, 1
      XOR  AL, AL
      XCHG AL, AH
    {$IFOPT G+}
      PUSH 1
      PUSH AX
    {$ELSE}
      MOV  CX, 1
      PUSH CX
      PUSH AX
    {$ENDIF}
      CALL GotoXY
      POP  AX
      POP  ES
      POP  DI
      POP  SI
    end;

  function SoftReturn ( XY : word ) : word; assembler;
    asm
      PUSH SI
      PUSH DI
      PUSH ES
      MOV  AX, XY
      MOV  CX, WindMin
      MOV  DX, WindMax
      MOV  BH, TextAttr
      MOV  BL, BackGround
      INC  AH
      CMP  AH, DH
      JBE  @@Done
      DEC  AH
      CMP  CheckScroll, True
      JNE  @@TopCorner
      CMP  DirectVideo, False
      JNE  @@Return2
      PUSH AX
      MOV  AX, $0601
      INT  $10
      POP  AX
      JMP  @@Done
    @@Return2:
      PUSH AX
      PUSH CX
      SUB  DX, CX        { Becomes 0-based range }
      PUSH DX
      MOV  DX, Columns
      SHL  DX, 1
      MOV  DI, ActiveOfs
      MOV  AX, DX        { COMPUTE ROW OFFSET }
      MUL  CH
      ADD  DI, AX
      XOR  AX, AX        { Compute Columns Offset }
      MOV  AL, CL
      SHL  AX, 1
      ADD  DI, AX
      MOV  AX, VideoSeg
      MOV  ES, AX        { Load Video Segment as Data Segment }
      POP  CX            { MOV  CX, 0-BASED Range }
      ADD  CX, $0001
      MOV  AX, BX
      CLD
      CMP  CH, 0
      JE   @@Return4
      PUSH DS
      PUSH ES; POP DS    { MOV ES, DS }
      MOV  SI, DI
      ADD  SI, DX
    @@Return3:
      PUSH CX
      PUSH DI
      PUSH SI
      XOR  CH, CH
      REP  MOVSW
      POP  SI
      POP  DI
      POP  CX
      ADD  DI, DX
      ADD  SI, DX
      DEC  CH
      JNZ  @@Return3
      POP  DS
    @@Return4:
      XOR  CH, CH
      REP  STOSW
      POP  CX
      POP  AX
      JMP  @@Done
    @@TopCorner:
      MOV  AX, WindMin
    @@Done:
      MOV  AL, CL
      POP  ES
      POP  DI
      POP  SI
    end;

  procedure Write ( S : String ); assembler;
    asm
      LES  SI, S
      MOV  AL, ES:[SI]
      CMP  AL, 0
      JE   @@NoWrite
      MOV  AH, Byte(WindMax)
      INC  SI
      CMP  DirectVideo, False
      JE   @@WriteBios1
    @@Write1:
      PUSH AX
      MOV  CX, CurrentXY
      PUSH CX
      MOV  AX, Columns
      SHL  AX, 1
      MUL  CH
      XOR  CH, CH
      SHL  CX, 1
      ADD  AX, CX
      ADD  AX, ActiveOfs
      MOV  DI, AX
      POP  DX
      POP  CX
      PUSH DS
      PUSH ES
      MOV  AX, VideoSeg
      MOV  ES, AX
      MOV  AH, TextAttr
      POP  DS
      CLD
    @@Write2:
      LODSB
      STOSW
      INC  DL
      CMP  DL, CH
      JA   @@Write3
      DEC  CL
      JZ   @@WriteDone
      JMP  @@Write2
    @@Write3:
      POP  DS
      PUSH CX
      PUSH AX
      PUSH DX
      CALL SoftReturn
      MOV  DX, AX
      PUSH AX; CALL GetVideoOfs
      MOV  DI, AX
      POP  AX
      POP  CX
      PUSH DS
      PUSH AX
      LDS  AX, S
      POP  AX
      DEC  CL
      JZ   @@WriteDone
      JMP  @@Write2
    { Write Through BIOS }
    @@WriteBios1:
      MOV  CX, AX
      MOV  DX, CurrentXY
      MOV  BH, ActivePage
      MOV  BL, TextAttr
      PUSH DS
      PUSH ES; POP  DS { MOV ES, DS }
    @@WriteBios2:
      CLD
      LODSB
      PUSH CX
      MOV  AH, $02
      INT  $10
      MOV  AH, $09
      MOV  CX, 1
      INT  $10
      POP  CX
      INC  DL
      CMP  DL, CH
      JA   @@WriteBios3
      DEC  CL
      JZ   @@WriteDone
      JMP  @@WriteBios2
    @@WriteBios3:
      POP  DS
      PUSH BX
      PUSH CX
      PUSH DX; CALL SoftReturn
      MOV  DX, AX
      POP  CX
      POP  BX
      PUSH DS
      LDS  AX, S
      DEC  CL
      JZ   @@WriteDone
      JMP  @@WriteBios2
    {---------}
    @@WriteDone:
      POP  DS
      PUSH DX
      CALL GotoAbsXY
    @@NoWrite:
    end;

  procedure WriteLn ( S : String ); assembler;
    asm
      LES SI, S
      PUSH ES
      PUSH SI
      CALL Write
      CALL Return
    end;

  function Keypressed : boolean; assembler;
    asm
      MOV AH, $11
      CMP Keyboard101, True
      JE  @@Keypressed1
      MOV AH, $01
    @@Keypressed1:
      INT $16
      MOV AL, False
      JZ  @@Done
      MOV AL, True
    @@Done:
    end;

  function ReadKey : String; assembler;
    asm
      CALL VideoIdle;
      LES  DI, @Result
      MOV  AH, $11
      CMP  Keyboard101, True
      JE   @@ReadKey1
      MOV  AH, $01
    @@ReadKey1:
      INT  $16
      MOV  CX, AX
      PUSHF
      PUSH DI
      XOR  AL, AL
      STOSB
      MOV  AL, CL
      STOSB
      MOV  AL, CH
      STOSB
      POP  DI
      POPF
      JZ  @@Done
      MOV AL, 2
      CMP CL, 0
      JE  @@SetLength
      CMP CL, $E0
      JE  @@SetLength
      MOV AL, 1
    @@SetLength:
      STOSB
      MOV AH, $10
      CMP Keyboard101, True
      JE  @@ReadKey2
      MOV AH, $00
    @@ReadKey2:
      INT $16
    @@Done:
    end;
{----------------------------------------------------------------------------}
{ Paging functions }
  procedure StoreActiveSettings;
    begin
      PageData[ActivePage].CurrentXY  := CurrentXY;
      PageData[ActivePage].WindMin    := WindMin;
      PageData[ActivePage].WindMax    := WindMax;
      PageData[ActivePage].TextAttr   := TextAttr;
      PageData[ActivePage].Background := BackGround;
    end;

  procedure RestoreActiveSettings;
    begin
      CurrentXY  := PageData[ActivePage].CurrentXY;
      WindMin    := PageData[ActivePage].WindMin;
      WindMax    := PageData[ActivePage].WindMax;
      TextAttr   := PageData[ActivePage].TextAttr;
      BackGround := PageData[ActivePage].Background;
    end;

  procedure SetVisualPage ( Page : Byte ); assembler;
    asm
      CMP  DirectVideo, False
      JE   @@Done
      MOV  AH, $05
      MOV  AL, Page
      CMP  AL, MaxPage
      JA   @@Done
      INT  $10
      MOV  AX, Seg0040
      MOV  ES, AX
      MOV  AX, ES:[$004E]; MOV VisualOfs, AX
      MOV  AL, ES:[$0062]; MOV VisualPage, AL
    @@Done:
    end;

  function SetActivePage ( Page : byte ) : word;
    begin
      StoreActiveSettings;
      asm
        CMP  DirectVideo, False
        JE   @@Done
        MOV  AX, VideoRegen
        XOR  CH, CH
        MOV  CL, Page
        CMP  CL, MaxPage
        JA   @@Done
        MUL  CX
        MOV  ActiveOfs, AX
        MOV  ActivePage, CL
      @@Done:
      end;
      RestoreActiveSettings;
      MoveCursor;
    end;

  procedure CopyPage ( FromPage, ToPage : byte );
    var
      XY : Word;
    begin
      if (FromPage = ToPage) or (FromPage > MaxPage) or (ToPage > MaxPage) then
        Exit;
      StoreActiveSettings;
      PageData[ToPage] := PageData[FromPage];
      RestoreActiveSettings;
      Move ( Ptr(VideoSeg, VideoRegen * FromPage)^,
             Ptr(VideoSeg, VideoRegen * ToPage)^,
             VideoRegen );
      XY := PageData[ToPage].CurrentXY;
      asm
        MOV AH, $02
        MOV BH, ToPage
        MOV DX, XY
        INT $10
      end;
    end;

  procedure CopyWindow ( FromPage, ToPage : byte );
    var
      XY,
      Count,
      Offset,
      ToOfs,
      FromOfs : word;
    begin
      if (FromPage = ToPage) or (FromPage > MaxPage) or (ToPage > MaxPage) then
        Exit;
      StoreActiveSettings;
      PageData[ToPage] := PageData[FromPage];
      RestoreActiveSettings;
      XY      := PageData[ToPage].CurrentXY;
      Count   := PageData[ToPage].WindMin;
      Offset  := (Columns SHL 1) * Hi(Count) + Lo(Count) SHL 1;
      FromOfs := (VideoRegen * FromPage) + Offset;
      ToOfs   := (VideoRegen * ToPage) + Offset;
      Count   := PageData[ToPage].WindMax - Count + $0101;
      asm
        PUSH DS
        MOV  AX, VideoSeg
        MOV  ES, AX
        MOV  SI, FromOfs
        MOV  DI, ToOfs
        MOV  CX, Count
        MOV  DX, Columns
        SHL  DX, 1
        PUSH ES; POP DS
        CLD
      @@Copy1:
        PUSH CX
        PUSH SI
        PUSH DI
        XOR  CH, CH
        REP  MOVSW
        POP  DI
        POP  SI
        POP  CX
        ADD  DI, DX
        ADD  SI, DX
        DEC  CH
        CMP  CH, 0
        JNE  @@Copy1
        POP  DS
        MOV  AH, $02
        MOV  BH, ToPage
        MOV  DX, XY
        INT  $10
      end;
    end;

  function RequestPage : Byte;
    var
      I : Byte;
    begin
      for I := 0 to MaxPage do
        if PageData[I].Free then Break;
      if PageData[I].Free then
        begin
          RequestPage := I;
          PageData[I].Free := False;
        end
      else
        RequestPage := $FF;
    end;

  procedure ReleasePage ( Page : Byte );
    begin
      if Page <= MaxPage then PageData[Page].Free := True;
    end;

  procedure NormalCursor;
    begin
      SetCursor ( FirstCursor );
    end;

  procedure HideCursor;
    begin
      SetCursor ( $2000 );
    end;

  procedure SmallCursor;
    begin
      SetCursor ( (MemW[$0:$0485]) shl 8 + (MemW[$0:$0485] - 2)  );
    end;

  procedure HalfCursor;
    begin
      SetCursor ( (MemW[$0:$0485] div 2) shl 8 + Lo(FirstCursor));
    end;

  procedure FullCursor;
    begin
      SetCursor ( MemW[$0:$0485] );
    end;
{-----------------------------------------------------------------------------}
  procedure SetPalette ( Palette : PaletteType; DACreg : byte ); assembler;
    asm
      MOV AX, $1000
      MOV BL, Palette
      MOV BH, DACreg
      INT $10
    end;

  procedure SetAllPalettes ( const Palettes ); assembler;
  { 16 palettes + 1 overscan = 17 byte buffer }
    asm
      MOV AX, $1002
      LES DX, Palettes
      INT $10
    end;

  procedure SetOverscan ( DACreg : byte ); assembler;
    asm
      MOV AX, $1001
      MOV BH, DACreg
      INT $10
    end;

  procedure SetRGBColor ( DACReg : word; const Color ); assembler;
    asm
      LES DI, Color
      MOV AX, $1010
      MOV BX, DACReg
      MOV DH, ES:[DI+0]
      MOV CH, ES:[DI+1]
      MOV CL, ES:[DI+2]
      INT $10
    end;

  procedure SetRGBBlock ( First, Count : word; const Colors ); assembler;
    asm
      MOV AX, $1012
      LES DX, Colors
      MOV BX, First
      MOV CX, Count
      INT $10
    end;

  procedure GetPalette ( Palette : PaletteType; var DACreg : byte ); assembler;
    asm
      MOV AX, $1007
      MOV BL, Palette
      INT $10
      LES DI, DACReg
      MOV ES:[DI], BH
    end;

  procedure GetAllPalettes ( var Palettes ); assembler;
  { 16 palettes + 1 overscan = 17 byte buffer }
    asm
      MOV AX, $1009
      LES DX, Palettes
      INT $10
    end;

  procedure GetOverscan ( var DACreg : byte ); assembler;
    asm
      MOV AX, $1008
      INT $10
      LES DI, DACReg
      MOV ES:[DI], BH
    end;

  procedure GetRGBColor ( DACReg : word; var Color ); assembler;
    asm
      MOV AX, $1015
      MOV BX, DACReg
      INT $10
      LES DI, Color
      MOV ES:[DI+0], DH
      MOV ES:[DI+1], CH
      MOV ES:[DI+2], CL
    end;

  procedure GetRGBBlock ( First, Count : word; var Colors ); assembler;
    asm
      MOV AX, $1017
      LES DX, Colors
      MOV BX, First
      MOV CX, Count
      INT $10
    end;

{----------------------------------------------------------------------------}
  procedure GetIntVec ( IntNo : byte; var Vec : pointer ); assembler;
    asm
      MOV  AH, $35
      MOV  AL, IntNo
      INT  $21
      MOV  DX, ES
      LES  DI, Vec
      MOV  AX, BX
      STOSW
      MOV  AX, DX
      STOSW
    end;

  procedure SetIntVec ( IntNo : byte; Vec : pointer ); assembler;
    asm
      PUSH DS
      MOV  AH, $25
      MOV  AL, IntNo
      LDS  DX, Vec
      INT  $21
      POP  DS
    end;

  var
    OldInt1B : procedure;
    OldInt23 : procedure;

  {$F+}
  procedure VideoINT1B; interrupt; assembler; { CTRL-BREAK }
    asm
      CMP CheckBreak, True
      JE  @@DoBreak
      PUSHF
      INC BreakCount
      POPF
      JMP @@BreakDone
    @@DoBreak:
      PUSHF
      CALL OldInt1B
    @@BreakDone:
    end;

  procedure VideoInt23; interrupt; assembler; { CTRL-BREAK }
    asm
      CMP CheckBreak, True
      JE  @@DoBreak
      PUSHF
      INC BreakCount
      POPF
      JMP @@BreakDone
    @@DoBreak:
      PUSHF
      CALL OldInt23
    @@BreakDone:
    end;
  {$F-}
{----------------------------------------------------------------------------}
  procedure DoneVideoUnit; far;
    begin
      ExitProc := OldExitProc;
      SetIntVec($1B, @OldInt1B );
      SetIntVec($23, @OldInt23 );
      if (LastMode <> FirstMode) then TextMode(FirstMode and $FF);
      if GetBlink <> FirstBlink then SetBlink( FirstBlink );
      if FirstCursor <> GetCursor then SetCursor ( FirstCursor );
      SetActivePage ( 0 );
      SetVisualPage ( 0 );
    end;

  procedure InitVideoUnit;
    begin
      OldExitProc := ExitProc;
      ExitProc    := @DoneVideoUnit;
      GetIntVec($1B, @OldInt1B );
      GetIntVec($23, @OldInt23 );
      SetIntVec($1B, @VideoInt1B );
      SetIntVec($23, @VideoInt23 );
      VideoIdle   := NULLVideoIdle;
      BIOS        := Ptr(Seg0040,$0049);
      InitVideo;
      FirstMode   := LastMode;
      FirstCursor := GetCursor;
      FirstBlink  := GetBlink;
      CheckBreak  := True;
      CheckEOF    := False;
      CheckSnow   := False;
      CheckScroll := True;
      CheckCursor := True;
      if DirectVideo then
        TextAttr := Mem[VideoSeg:ActiveOfs + (Columns shl 1) * Rows - 1]
      else
        TextAttr := LightGray;
      FirstAttr := TextAttr;
      Keyboard101 := False;
      BreakCount := 0;
    end;

begin
  InitVideoUnit;
end.
