{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

{ Reguires VGA and always operates using direct video.  The fuctions and
  procedures in this unit that use character I/O cannot be used in graphics
  mode ( including ClrScr, ClrEol, etc ). Although, many of the functions and
  procedures that have the same names and work similar to those in Borland's
  CRT unit, they are NOT compatable and should not be used in the same
  application.  Also, this video extenetion unit is NOT compatible with any of
  Borland's Turbo Vision applications. }
unit TVideo;

{$O-,F-,S-,R-,D-,L-,I-}
interface
  uses Dos, Keyboard, MouseObj, StrAsm, StrSize;

  const
  { Video mode constants; use with TextMode }
    BW40        = $0000;
    CO40        = $0001;
    BW80        = $0002;
    CO80        = $0003;
    MONO        = $0007;
  { Add-ins for different video fonts; use with TextMode }
    DefaultFont = $0000;
    Font8x8     = $0800;
    Font8x14    = $0E00;
    Font8x16    = $1000;
  { Forground and background colors; use with TextColor and TextBackGround }
    Black        = $00;
    Blue         = $01;
    Green        = $02;
    Cyan         = $03;
    Red          = $04;
    Magenta      = $05;
    Brown        = $06;
    LightGray    = $07;
  { Forground Colors; ( Also background colors if Blink is disabled ) }
    DarkGray     = $08;
    LightBlue    = $09;
    LightGreen   = $0A;
    LightCyan    = $0B;
    LightRed     = $0C;
    LightMagenta = $0D;
    Yellow       = $0E;
    White        = $0F;
  { Add-in for linking text; use with TextBackGround if Blink is Enabled }
    Blink        = $08;
  { TTL Monochrome Attributes }
    Underline               = $01;
    Normal                  = $07;
    BrightUnderline         = $09;
    Bold                    = $0F;
    Reverse                 = $70;
    BlinkingUnderline       = $81;
    BlinkingNormal          = $87;
    BlinkingBrightUnderline = $89;
    BlinkingBold            = $8F;
  { One-Color composite Attributes }
   {Normal                  = $07;}
    GrayOnBlack             = $08;
   {Bold                    = $0F;}
   {Reverse                 = $70;}
    GrayOnWhite             = $78;
    WhiteOnWhite            = $7F;
   {BlinkingNormal          = $87;}
   {BlinkingBold            = $8F;}
  { Box Frame constants }
    bxSingle     = $00; { Single Side/Single Top }
    bxDouble     = $03; { Double Side/Double Top }
    bxDoubleSide = $01; { Double Side/Single Top }
    bxDoubleTop  = $02; { Double Top/Single Side }
  { Line Constants }
    lnSingle     = $00;
    lnDouble     = $01;
    lnVertical   = $02;
    lnHorizontal = $00;
    lnNoEnds     = $04;
  { predefined commands }
    cmNoCommand      = $0000;
    cmQuit           = $0001;
    cmExit           = $0002;
    cmHelp           = $0003;
    cmScrollBarRight = $0004;
    cmScrollBarLeft  = $0005;
    cmScrollBarUp    = $0006;
    cmScrollBarDown  = $0007;
    cmMarker         = $0008;
    cmCancel         = $0009;
    cmEscape         = $000A;
    cmBack           = $000B;

  type
    ByteCast = array[0..$FFFE] of byte;
    WordCast = array[0..$7FFE] of word;
    XYType = record X, Y : byte end;
    CharAttr = record C : Char; A : byte; end;
    HandlerFunc = function ( var Command : word ) : boolean;
    PageStateType = record
      WhereXY,
      WindMin,
      WindMax    : word;
      TextAttr,
      ShadowAttr : byte;
      BackChar   : Char;
      AutoCursor,
      Scrolling  : Boolean;
      Cursor     : Word;
    end;
  type
    ButtonAttrType = record
      Press, Release, InActive : word;
    end;
    ScrollAttrType = record
      Arrows, Marker, Bar : byte;
    end;

  const { Following variables are set upon startup only }
    TimerTicks : Word = 0; { Inc. on every timer tick about 18.2 a second }
    BlankDelay : Word = 2184; { Timer ticks until screen blanker executes }
    BlankTime  : Word = 0; { Is assigned BlankDelay on a mouse or keyboard event }
    CheckBreak : boolean = False; { Enables/Disables CtrlBreak Checking }
    BreakCount : Word = 0; { When CheckBreak is False, Is incremented when a
      press of the Ctrl Break Key has registered }
    CheckPrint : boolean = True; { Enables/Disables the default Print Screen
      routine }
    Scrolling : boolean = True; { Enables/Disables screen Scrolling when
      writing on the last line. }
    PrintCount : Word = 0; { When CheckPrint is False, PrintCount is Inc.
      when a Print Screen is requested }
    TKey : PKeyboard = nil; { Is assigned a valid Keyboard interface object }
    TMouse : PMouse = nil; { Is assigned a valid Mouse interface object }
    TVideoIdle : procedure = nil; { assign to coincide with Idle procedure }
    TVideoBlank : procedure = nil; { Is assigned the default Screen Blanker }
    TVideoHandler : HandlerFunc = nil; { Is assigned the default Command
     Handler, which handles cmNoCommand which is returned from buttons,
     scrollbars, etc when no event has occured. }

  var { Following variables contain startup information; Upon the termination,
        if the current BIOS settings are different, the BIOS is reset to
        these values (except original Cursor Position). }
    StartUpMode   : word;    { Contains startup video mode }
    StartUpXY     : XYType;  { Contains startup cursor position; 0 based }
    StartUpPage   : byte;    { Contains startup visual page; 0 based }
    StartUpCursor : word;    { Contains startup cursor size/shape }
    StartBlink    : boolean; { Contains startup blink value }

  var { Following variables are reset upon each mode change to defaults for
        that mode values and can be directly manipulated }
    TextAttr : byte; { attribute used for text output to screen;
      default is $07 ( LightGray on black ) }
    ShadowAttr : byte; { attribute used to draw box Shadows; default is
      DarkGray on Black }
    BackGroundChar : Char; { used to fill screen with ClrScr, ClrEOL, etc.;
      default is Space. }
    LastMode : word; { current video mode; provided for reference does
      nothing; defaults to the current mode. }
    AutoCursor : boolean; { if True cursor is updated with each call; default
      is True. }

  var { The following variables are also reset with each mode change to
        default values for that mode.  These variables are provided
        for reference ONLY, and are used internally without error checking by
        TVideo and the Video BIOS, DO NOT alter there value, incorrect
        changes to these variables will cause unpredictable results,
        (ie. distroy the display, crash the application or system, and
        other unwanted effects)}
{    BlinkMode : boolean;}
    Columns : byte; { total columns on the screen }
    Rows : byte; { total rows on the screen }
    CharSize : word; { bytes per character/scan-line height per character }
    ScreenWide : word; { bytes per screen line (ie. columns * 2) }
    VideoSeg : word; { current video segment }
    VisualOfs : word; { offset to current visual page }
    ActiveOfs : word; { offset to current active Page }
    RegenSize : word; { size of video regen buffer, one screen page }
    VisualPage : byte; { current visual page; 0 based }
    ActivePage : byte; { current active page; 0 based }
    MaxPage : byte; { maximum video pages for the current mode; 0 based }
    WindMin : word; { current minimum window coordinates; 0 based }
    WindMax : word; { current maximum window coordinates; 0 based }
    WhereXY : word; { current cursor XY coordinates; 0 based }

  procedure TVideoReset;
  { Resets TVideo unit for the current mode; call if another external function
    is used to change bios modes(ie. CRT's TextMode), or TVideo can produce
    unpredictable results. Note: all pages are released, Mouse is initialized
    to current mode, and above variables are reset, and many of the internal
    variables are reset. }
  { following procedures/functions work like (not the same as) equivilant
    functions in Borland's CRT unit.  Differences are mainly in the way that
    these deal with invalid data. }
  procedure TextMode ( Mode : Word );
  procedure Window ( X1, Y1, X2, Y2 : byte );
  procedure GotoXY ( X, Y : byte );
  function  WhereX : byte;
  function  WhereY : byte;
  procedure ClrScr;
  procedure ClrEOL;
  procedure InsLine;
  procedure DelLine;
  procedure TextColor ( Color : byte );
  procedure NoSound;
  procedure Sound ( Freq : Word );
  procedure TextBackGround ( Color : byte );
  { The following procedures/functions have no CRT equivilant }
  procedure InsColumn;
  { inserts a column at the cursor position shifting all following columns
    to the right. }
  procedure DelColumn;
  { deletes the column at the cursor position shifting all following columns
    to the left }
  procedure Write   ( S : String );
  { works like System Write; except cannot send output to a text file; and
    if Scrolling = False then writing in the last column & row will move the
    cursor to the first column/row instead of scrolling the screen; and all
    ascii characters can be written to the screen, including carriage return,
    bell, and other control characters; also output goes to the current Active
    video page, not current Visual page. }
  procedure WriteLn ( S : String );
  { works like System WriteLn with the same exceptions as Write. }
  procedure WriteScreen ( var Data; Size : word );
  { works like Write but writes Char, Attribute }
  procedure WriteAttr ( Attr : Byte; Size : word );
  { works like Write but writes only text attributes }
  procedure Fill ( X1, Y1, X2, Y2 : byte );
  { fills an area with current TextAttr and BackgroundChar, does not change
    window size or cursor position }
  procedure DrawBox ( X1, Y1, X2, Y2, Style : byte );
  { draws a box does not move Cursor }
  procedure DrawShadow ( X1, Y1, X2, Y2 : byte );
  { draws a box shadow does not move Cursor }
  procedure DrawLine ( X1, Y1, Len, Style : byte );
  { Draws A Line starting at (X1, Y1) }
  procedure SetActivePage ( Page : byte );
  { changes the current video page where text is written to and read from. }
  procedure SetVisualPage ( Page : byte );
  { changes the current video page that is displayed on the screen }
  function  GetVisualPage : byte;
  { returns the current video page that is being displayed }
  function  GetActivePage : byte;
  { returns the current video page where text is written to and read from }
  procedure CopyPage ( FromPage, ToPage : byte );
  { duplicates a video page }
  function  RequestPage : byte;
  { returns number of the next avalable video page; returns $FF if no pages
    are avialable }
  procedure ReleasePage ( Page : byte );
  { release a page to be used for other purposes }
  procedure SetBlink ( On : boolean );
  { enables/disables blinking attribute; with blink disabled 16 background
    colors are available. }
  function  GetBlink : boolean;
  { returns true if blink is enabled; false if intensity is enabled }
  function  SetScreenEnable ( Enabled : Boolean ) : boolean;
  { True/False-enables/disables video refresh for the active display.
    Returns True if successful. Requires VGA. }
  procedure MoveCursor;
  { Updates current Cursor Position }
  procedure PrintScreen;
  { Invokes the Default Print Screen Dump (ie. what usually happens when the
    Print Screen key is Pressed). }
  procedure GetPageState ( var PS : PageStateType );
  procedure SetPageState ( PS : PageStateType );
  { More Sound Stuff }
  procedure Speaker ( On : boolean );  { Direct control of PC internal Speaker }
  procedure TimerSound ( Val : word ); { Timer Based sound }
  procedure RealSound ( Freq : Real ); { Like Sound but more precise }
  procedure Delay ( Ticks : byte ); { Waits for n Timer Ticks to Elapse;
   timer ticks at .55 ms about 18.2 times a second, so if ticks = 18 then
   delay is about 1 second. }
  procedure Beep; { Sound simalar to that of dos BEL }

  function  WindowSize : word;
  procedure GetWindow ( var Adr );
  procedure PutWindow ( var Adr );
{--------------------------------------------------------------------------}
  const { Default Button Atributes }
    ColorButtonAttr : ButtonAttrType =
      (Press:$6460; Release:$1E1F; InActive:$1818 );
    MonoButtonAttr : ButtonAttrType =
      (Press:$7070; Release:$090F; InActive:$0707 );
    ColorScrollAttr : ScrollAttrType =
      (Arrows:$31; Marker:$31; Bar:$31 );
    MonoScrollAttr : ScrollAttrType =
      (Arrows:Reverse; Marker:Reverse; Bar:Reverse );

  var
    ButtonAttr  : ButtonAttrType; { Current Allocating Attributes; resets on
      mode change }
    ButtonError : integer; { is assigned 8 if insufficient memory; does not
      get reset }
    KeySpeed    : Word; { timer ticks to Hold button down when key was
      pressed; gets reset on mode change }
    ScrollSpeed : Word; { Timer Ticks To wait on scroll bar ends }
    ScrollAttr  : ScrollAttrType;
    HScrollChar : Char4;
    VScrollChar : CHar4;

  type
    PTButton = ^OTButton;
    OTButton = object
      constructor Init(X, Y : byte; D, K : String; Com : word; Next : PTButton );
      destructor  Done;
      procedure   Draw;
      procedure   Show( Press : boolean );
      function    Check ( Key : Str2 ) : word;
      function    MouseCheck (var Com : Word) : boolean;
      procedure   WaitDelay;
      function    SetState   ( Com : word; Act : boolean ) : boolean;
      function    SetCommand ( Com, NCom : word; Buttons : byte ) : boolean;
      function    Occupied ( X, Y : byte ) : word;
      function    WhereX ( Com : word ) : byte;
      function    WhereY ( Com : word ) : byte;
      procedure   SetXY  ( Com : word; X, Y : Byte );
      procedure   SetWait ( Com : word; Time : integer );
      procedure   SetPressable ( Com : word; P : boolean );
      private
        xPos, yPos,
        Wide        : byte;
        HPos, HLen  : byte;
        Pressable,
        Active      : boolean;
        WaitTime    : integer;
        KSpeed      : word;
        Attr        : ButtonAttrType;
        KeyValue    : Str2;
        Data        : Str40;
        Commands    : array[boolean, boolean, boolean] of word;
        NextButton  : PTButton;
        WindMn,
        WindMx      : word;
    end;
  { Scroll Objects }
    PVScroll = ^OVScroll;
    OVScroll = object
      constructor Init ( X, Y, L : byte; R, P : word; DKey, IKey : Str2 );
      destructor  Done;
      procedure   Draw;
      procedure   Refresh;
      function    GetPosition ( Key : Str2 ) : word;
      procedure   SetPosition ( P : word );
      procedure   SetRange    ( R : word );
      function    GetRange : word;
      procedure   SetLength  ( L : word );
    private
      Marker, Buts    : PTButton;
      WindMn, WindMx  : word;
      BAtr            : byte;
      BChr            : Char;
      xPos, yPos, Len : byte;
      Range, Pos      : Word;
      Scale           : Real;
    end;
    PHScroll = ^OHScroll;
    OHScroll = object
      constructor Init ( X, Y, L : byte; R, P : word; DKey, IKey : Str2 );
      destructor  Done;
      procedure   Draw;
      procedure   Refresh;
      function    GetPosition ( Key : Str2 ) : word;
      procedure   SetPosition ( P : word );
      procedure   SetRange    ( R : word );
      function    GetRange : word;
      procedure   SetLength  ( L : word );
    private
      Marker, Buts    : PTButton;
      WindMn, WindMx  : word;
      BAtr            : byte;
      BChr            : Char;
      xPos, yPos, Len : byte;
      Range, Pos      : Word;
      Scale           : Real;
    end;

  function NewButton ( X, Y : byte; D, K : String; Command : word; Next : PTButton ) : PTButton;
  function NewVScroll ( X, Y, L : byte; R, P : word; DKey, IKey : Str2 ) : PVScroll;
  function NewHScroll ( X, Y, L : byte; R, P : word; DKey, IKey : Str2 ) : PHScroll;

implementation

  const
    OldExitProc : Pointer = nil;
    OldTimer    : procedure = nil;
    OldBreak    : procedure = nil;
    OldPrint    : procedure = nil;
  var
    Blanked     : Boolean;
    DelayCount  : byte;
    WindRange   : word;
    PageAvail   : array[0..7] of Boolean;
    PageData    : array[0..7] of
      record WhereXY, WindMin, WindMax, WindRange : word end;
    WriteBuff   : array[1..256,0..1] of Char;
{----------------------------------------------------------------------------}
{BIOS CALLS}
  procedure SetCurrentVideoMode  ( Mode : Byte ); assembler;
    asm
      MOV AH, $00
      MOV AL, Mode
      INT $10
    end;

  procedure SetCurrentCursor ( Size : word ); assembler;
    asm
      MOV AH, $01
      MOV CX, Size
      INT $10
    end;

  function GetCurrentVideoMode : byte; assembler;
    asm
      MOV AH, $0F
      INT $10
    end;

  function GetCurrentColumns : byte; assembler;
    asm
      MOV AH, $0F
      INT $10
      MOV AL, AH
    end;

  function GetCurrentVisualPage : byte; assembler;
    asm
      MOV AH, $0F
      INT $10
      MOV AL, BH
    end;

  function SetScreenEnable ( Enabled : boolean ) : boolean; assembler;
    asm
      MOV AH, $12
      MOV AL, Enabled
      NOT AL
      AND AL, $01
      MOV BL, $36
      INT $10
      MOV AH, False
      CMP AL, $12
      JNE @@1
      MOV AH, True
    @@1:
      MOV AL, AH
    end;

  procedure SetCurrentVisualPage ( Page : byte ); assembler;
    asm
      MOV AH, $05
      MOV AL, Page
      INT $10
    end;

  function GetCurrentCursor : word; assembler;
    asm
      MOV AH, $03
      MOV BH, $00
      INT $10
      MOV AX, CX
    end;

  function GetCurrentPosition ( Page : Byte ): word; assembler;
    asm
      MOV AH, $03
      MOV BH, Page
      INT $10
      MOV AX, DX
    end;

  procedure SetCurrentPosition ( Page, Column, Row : byte ); assembler;
    asm
      MOV AH, $02
      MOV BH, Page
      MOV DL, Column
      MOV DH, Row
      INT $10
    end;

  function GetVideoMode : word;
    begin
      GetVideoMode := GetCurrentVideoMode + MemW[Seg0040:$0085] Shl 8;
    end;

  procedure SetVideoMode ( Mode : Word ); assembler;
    asm
{      MOV BlinkMode, True}
      MOV AX, Mode
      MOV AH, $00
      INT $10
      MOV BX, Mode
      MOV AH, $11
      MOV AL, $11
      CMP BH, $0E
      JE  @@1
      MOV AL, $12
      CMP BH, $08
      JE  @@1
      MOV AL, $14
      CMP BH, $10
      JE  @@1
      JMP @@2
    @@1:
      MOV BL, $00
      INT $10
    @@2:
    end;

  procedure SetBlink ( On : boolean ); assembler;
    asm
      MOV AH, $10
      MOV AL, $03
      MOV BL, On
{      MOV BlinkMode, BL}
      INT $10
    end;
{----------------------------------------------------------------------------}
  function DefaultHandler ( var Command : Word ) : Boolean; far;
    begin
      Case Command of
        cmNoCommand : DefaultHandler := True;
      else
        DefaultHandler := False;
      end;
    end;

  procedure DefaultBlank; far;
    var
      X, Y, B : integer;
    begin
      TMouse^.Show(False);
      SetScreenEnable ( False );
      TMouse^.GetPosition ( X, Y, B );
      TMouse^.MouseActivity;
      While TKey^.Keypressed do TKey^.Inkey;
      Repeat
        { Might prevent recursive calls if TVideoIdle Uses Button, ScrollBar,
          or KeyBoard Objects, Need to Check... }
        BlankTime := BlankDelay;
        if Assigned(TVideoIdle) then TVideoIdle;
        { need to call so activity can be checked }
        TMouse^.GetPosition ( X, Y, B );
      until TMouse^.MouseActivity or TKey^.KeyPressed;
      While TKey^.Keypressed do TKey^.Inkey;
      SetScreenEnable ( True );
      TMouse^.Show ( True );
    end;

  procedure UnitIdle; far;
    begin
      IF Assigned(TVideoIdle) then TVideoIdle;
      {$B+}
      if TMouse^.MouseActivity or TKey^.KeyboardActivity then
      {$B-}
        BlankTime := BlankDelay
      else
      if (BlankTime <= 0) and ( Not Blanked ) then
        begin
          if BlankDelay <> 0 then
            begin
              Blanked := True;
              TVideoBlank;
              Blanked := False;
              BlankTime := BlankDelay;
            end;
        end;
    end;

  {$F+}
  procedure TVIDEOTimer; interrupt; assembler;
    asm
      PUSHF
      CALL OldTimer
      PUSHF
      INC  TimerTicks
      DEC  BlankTime
      CMP  DelayCount, 0
      JE   @@1
      DEC  DelayCount
    @@1:
      POPF
    end;

  procedure TVideoBreak; interrupt; Assembler;
    asm
      PUSHF
      CMP  CheckBreak, True
      JE   @@1
      INC  BreakCount
      POPF
      JMP  @@2
    @@1:
      POPF
      PUSHF
      CALL OldBreak
    @@2:
    end;

  procedure TVideoPrint; interrupt; assembler;
    asm
      PUSHF
      CMP  CheckPrint, True
      JE   @@1
      INC  PrintCount
      POPF
      JMP  @@2
    @@1:
      POPF
      PUSHF
      CALL OldPrint
    @@2:
    end;
  {$F-}

  procedure TVideoExitProc; far;
    begin
      ExitProc  := OldExitProc;
      if Assigned ( OldTimer ) then SetIntVec ( $08, @OldTimer );
      if Assigned ( OldBreak ) then SetIntVec ( $23, @OldBreak );
      if Assigned ( OldPrint ) then SetIntVec ( $05, @OldPrint );
      if Assigned(TKey) then Dispose(TKey, Done);
      if Assigned(TMouse) then
        begin
          TMouse^.Show ( False );
          Dispose(TMouse, Done);
        end;
      if GetVideoMode <> StartUpMode then SetVideoMode  ( StartUpMode and $FF );
      if GetCurrentVisualPage <> StartUpPage then
        SetCurrentVisualPage ( StartUpPage );
      if GetCurrentCursor <> StartUpCursor then
        SetCurrentCursor ( StartUpCursor );
      if GetBlink <> StartBlink then SetBlink ( StartBlink );
    end;

  procedure TVideoAbort;
    begin
      System.WriteLn('insufficient memory.');
      Halt(1);
    end;

  procedure UnitInit;
    var
      TWord : Word;
    begin
      Blanked       := False;
      OldExitProc   := ExitProc;
      ExitProc      := @TVideoExitProc;
      KeyboardIdle  := UnitIdle;
      TVideoBlank   := DefaultBlank;
      TVideoHandler := DefaultHandler;
      BlankTime     := BlankDelay;
      GetIntVec ( $08, @OldTimer    ); SetIntVec ( $08, @TVideoTimer );
      GetIntVec ( $23, @OldBreak    ); SetIntVec ( $23, @TVideoBreak );
      GetIntVec ( $05, @OldPrint );    SetIntVec ( $05, @TVideoPrint );
      StartBlink    := GetBlink;
      ButtonError   := 0;
      StartUpMode   := GetVideoMode;
      StartUpPage   := GetCurrentVisualPage;
      StartUpCursor := GetCurrentCursor;
      TWord         := GetCurrentPosition(StartUpPage);
      StartUpXY     := XYType(TWord);
      if MaxAvail < Sizeof(OMouse) then TVideoAbort;
      TMouse := New(PMouse, Init);
      if MaxAvail < Sizeof(OKeyboard) then TVideoAbort;
      TKey := New(PKeyboard, Init);
      TMouse^.Show ( True );
      TVideoReset;
    end;
{----------------------------------------------------------------------------}
{TVIDEO Procedures/Functions}
  procedure TVideoReset;
    var
      I : Byte;
      S : String;
    begin
      FillChar ( PageAvail, Sizeof(PageAvail), True );
      TextAttr := LightGray;
      ShadowAttr := DarkGray;
      BackGroundChar := #32;
      Columns  := GetCurrentColumns;
      Rows     := Mem [Seg0040:$0084] + 1;
      CharSize := MemW[Seg0040:$0085];
      LastMode := GetVideoMode;
      if LastMode and MONO = Mono then VideoSeg := SegB000 else VideoSeg := SegB800;
      VisualOfs := MemW[Seg0040:$004E];
      RegenSize := MemW[Seg0040:$004C];
      ActiveOfs := VisualOfs;
      VisualPage := GetCurrentVisualPage;
      ActivePage := VisualPage;
      Case LastMode and $FF of
        0, 1, 2, 3, 7 : begin
          MaxPage := 7;
          if LastMode and $FF00 < $1000 then MaxPage := 3;
        end
      else
        MaxPage := 0;
      end;
      ScreenWide := Columns shl 1;
      for I := 0 to MaxPage do
        with PageData[I] do
          begin
            WhereXY := GetCurrentPosition ( I );
            WindMin := 0;
            WindMax := (Columns - 1) + ( Rows - 1 ) Shl 8;
            WindRange := WindMax + $0101;
          end;
      WhereXY   := PageData[VisualPage].WhereXY;
      WindMin   := PageData[VisualPage].WindMin;
      WindMax   := PageData[VisualPage].WindMax;
      WindRange := PageData[VisualPage].WindRange;
      TMouse^.Show ( False );
      TMouse^.Initialize;
      TMouse^.Show ( True );
      TKey^.ClearBuffer;
      Case LastMode and $FF of
        0..3, 7 : begin
          Case Columns of
            40 : TMouse^.SetShiftRatio ( 4, 3 );
            80 : TMouse^.SetShiftRatio ( 3, 3 );
          end;
          TMouse^.SetLimits ( 0, 0, Columns - 1, Rows - 1 );
        end;
      end;
      if LastMode and $FF = Mono then
        begin
          TMouse^.Show ( False );
          TMouse^.SetCursorEMU ( True );
          For I := 0 to 255 do
            S[I] := Char(Not I);
          S[Underline]               := Char( Reverse );
          S[Normal]                  := Char( Reverse );
          S[BrightUnderline]         := Char( Reverse );
          S[Bold]                    := Char( Reverse );
          S[Reverse]                 := Char( Bold );
          S[BlinkingUnderline]       := Char( Reverse );
          S[BlinkingNormal]          := Char( Reverse );
          S[BlinkingBrightUnderline] := Char( Reverse );
          S[BlinkingBold]            := Char( Reverse );
          S[GrayOnBlack]             := Char( Reverse );
          S[GrayOnWhite]             := Char( Normal );
          S[WhiteOnWhite]            := Char( Bold );
          TMouse^.SetSwap ( S );
          TMouse^.Show ( True );
        end;
      TMouse^.SetPosition ( 0, 0 );
      AutoCursor := True;
      if LastMode and $FF = Mono then
        begin
          ButtonAttr := MonoButtonAttr;
          ScrollAttr := MonoScrollAttr;
        end
      else
        begin
          ButtonAttr := ColorButtonAttr;
          ScrollAttr := ColorScrollAttr;
        end;
      KeySpeed := 2;
      ScrollSpeed := 2;
      HScrollChar := #17#16#254#176;
      VScrollChar := #30#31#254#176;
    end;

{----------------------------------------------------------------------------}
  procedure HideMouse;
    begin
      TMouse^.Show ( False );
    end;

  procedure ShowMouse;
    begin
      TMouse^.Show ( True );
    end;

  procedure MoveCursor; assembler;
    asm
      MOV  AH, $02
      MOV  BH, ActivePage
      MOV  DX, WhereXY
      ADD  DX, WindMin
      INT  $10
    end;

  procedure CursorRefresh; assembler;
    asm
      CMP  AutoCursor, True
      JNE  @@1
      PUSH AX
      PUSH BX
      PUSH DX
      MOV  AH, $02
      MOV  BH, ActivePage
      MOV  DX, WhereXY
      ADD  DX, WindMin
      INT  $10
      POP  DX
      POP  BX
      POP  AX
    @@1:
    end;

  procedure ClrScr; assembler;
    asm
      CALL HideMouse
      PUSH DS
      PUSH DI
      MOV  DI, ActiveOfs
      MOV  AX, ScreenWide
      MOV  BX, AX
      MOV  CX, WindMin
      MUL  CH
      MOV  CH, 0
      SHL  CX, 1
      ADD  AX, CX
      ADD  DI, AX
      MOV  CX, WindRange
      MOV  DH, 0
      MOV  DL, CH
      MOV  CH, 0
      MOV  AL, BackGroundChar
      MOV  AH, TextAttr
      MOV  DS, VideoSeg
    @@1:
      PUSH DI
      PUSH CX
    @@2:
      MOV  [DI], AX
      ADD  DI, 2
      LOOP @@2
      POP  CX
      POP  DI
      ADD  DI, BX
      DEC  DX
      CMP  DX, $00
      JNE  @@1
      POP  DI
      POP  DS
      MOV  WhereXY, 0
      CALL CursorRefresh
      CALL ShowMouse
    end;

  procedure Window ( X1, Y1, X2, Y2 : byte ); assembler;
    asm
      DEC  X1
      DEC  Y1
      DEC  X2
      DEC  Y2
      MOV  AL, Columns
      CMP  X1, AL
      JNB  @@3
      CMP  X2, AL
      JNB  @@3
      MOV  AL, Rows
      CMP  Y1, AL
      JNB  @@3
      CMP  Y2, AL
      JNB  @@3
      MOV  CL, X1
      MOV  CH, Y1
      MOV  DL, X2
      MOV  DH, Y2
      CMP  CL, DL
      JB   @@1
      MOV  AL, CL
      MOV  CL, DL
      MOV  DL, AL
    @@1:
      CMP  CH, DH
      JB   @@2
      MOV  AH, CH
      MOV  CH, DH
      MOV  DH, AH
    @@2:
      MOV  WindMin, CX
      MOV  WindMax, DX
      SUB  DX, CX
      ADD  DX, $0101
      MOV  WindRange, DX
      MOV  WhereXY, 0;
      CALL CursorRefresh
    @@3:
    end;

  procedure TextMode ( Mode : word );
    begin
      SetVideoMode ( Mode );
      TVideoReset;
    end;

  procedure GotoXY ( X, Y : byte ); assembler;
    asm
      MOV CH, Y
      MOV CL, X
      DEC CH
      DEC CL
      MOV DX, WindRange
      CMP CL, DL
      JB  @@1
      SUB CL, DL
      INC CH
    @@1:
      CMP CH, DH
      JB  @@2
      SUB CH, DH
    @@2:
      MOV WhereXY, CX
      CALL CursorRefresh
    end;

  function  WhereX : byte; assembler;
    asm
      MOV AL, XYType(WhereXY).X
      INC AL
    end;

  function  WhereY : byte; assembler;
    asm
      MOV AL, XYType(WhereXY).Y
      INC AL
    end;

  procedure ClrEOL; assembler;
    asm
      CALL HideMouse
      PUSH DS
      PUSH DI
      MOV  DI, ActiveOfs
      MOV  AX, ScreenWide
      MOV  DX, WindMin
      ADD  DX, WhereXY
      PUSH DX
      MUL  DH
      MOV  DH, 0
      SHL  DX, 1
      ADD  AX, DX
      ADD  DI, AX
      POP  DX
      MOV  CX, WindMax
      MOV  CH, 0
      INC  CL
      SUB  CL, DL
      MOV  AL, BackGroundChar
      MOV  AH, TextAttr
      MOV  DS, VideoSeg
    @@1:
      MOV  [DI], AX
      ADD  DI, 2
      LOOP @@1
      POP  DI
      POP  DS
      CALL ShowMouse
    end;

  procedure TextColor ( Color : byte ); assembler;
    asm
      AND TextAttr, $F0
      MOV AL, Color
      AND AL, $0F
      OR  TextAttr, AL
    end;

  procedure TextBackGround ( Color : byte ); assembler;
    asm
      AND TextAttr, $0F
      MOV AL, Color
      SHL AL, 1
      SHL AL, 1
      SHL AL, 1
      SHL AL, 1
      OR  TextAttr, AL
    end;

  procedure InsLine; assembler;
    asm
      CALL HideMouse
      PUSH DS
      PUSH DI
      PUSH SI
      MOV  DI, ActiveOfs
      MOV  AX, ScreenWide
      MOV  BX, AX
      MOV  CX, WindMin
      ADD  CH, XYType(WhereXY).Y
      MUL  CH
      MOV  CH, 0
      SHL  CX, 1
      ADD  AX, CX
      ADD  DI, AX
      MOV  CX, WindRange
      MOV  DH, 0
      MOV  DL, CH
      MOV  CH, 0
      MOV  AX, BX
      SUB  DL, XYType(WhereXY).Y
      DEC  DL
      MUL  DL
      ADD  DI, AX
      MOV  AH, TextAttr
      MOV  AL, BackGroundChar
      PUSH AX
      MOV  DS, VideoSeg
      MOV  SI, DI
      CMP  DL, 0
      JNA  @@3
      SUB  SI, BX
    @@1:
      PUSH SI
      PUSH DI
      PUSH CX
    @@2:
      MOV  AX, [SI]
      MOV  [DI], AX
      ADD  DI, 2
      ADD  SI, 2
      LOOP @@2
      POP  CX
      POP  DI
      POP  SI
      SUB  DI, BX
      SUB  SI, BX
      DEC  DX
      CMP  DX, $00
      JNE  @@1
      MOV  SI, DI
    @@3:
      POP  AX
    @@4:
      MOV  [SI], AX
      ADD  SI, 2
      LOOP @@4
      POP  SI
      POP  DI
      POP  DS
      CALL ShowMouse
    end;

  procedure DelLine; assembler;
    asm
      CALL HideMouse
      PUSH DS
      PUSH DI
      PUSH SI
      MOV  DI, ActiveOfs
      MOV  AX, ScreenWide
      MOV  BX, AX
      MOV  CX, WindMin
      ADD  CH, XYType(WhereXY).Y
      MUL  CH
      MOV  CH, 0
      SHL  CX, 1
      ADD  AX, CX
      ADD  DI, AX
      MOV  CX, WindRange
      MOV  DH, 0
      MOV  DL, CH
      MOV  CH, 0
      SUB  DL, XYType(WhereXY).Y
      DEC  DL
      MOV  AH, TextAttr
      MOV  AL, BackGroundChar
      PUSH AX
      MOV  DS, VideoSeg
      MOV  SI, DI
      CMP  DL, 0
      JNA  @@3
      ADD  SI, BX
    @@1:
      PUSH SI
      PUSH DI
      PUSH CX
    @@2:
      MOV  AX, [SI]
      MOV  [DI], AX
      ADD  DI, 2
      ADD  SI, 2
      LOOP @@2
      POP  CX
      POP  DI
      POP  SI
      ADD  DI, BX
      ADD  SI, BX
      DEC  DX
      CMP  DX, $00
      JNE  @@1
      MOV  SI, DI
    @@3:
      POP  AX
    @@4:
      MOV  [SI], AX
      ADD  SI, 2
      LOOP @@4
      POP  SI
      POP  DI
      POP  DS
      CALL ShowMouse
    end;

  procedure InsColumn; assembler;
    asm
      CALL HideMouse
      PUSH DS
      PUSH DI
      PUSH SI
      MOV  DI, ActiveOfs
      MOV  AX, ScreenWide
      MOV  BX, AX
      MOV  CX, WindMin
      ADD  CL, XYType(WhereXY).X
      MUL  CH
      MOV  CH, 0
      SHL  CX, 1
      ADD  AX, CX
      ADD  DI, AX
      MOV  CX, WindRange
      MOV  DH, 0
      MOV  DL, CH
      MOV  CH, 0
      SUB  CL, XYType(WhereXY).X
      DEC  CL
      MOV  AH, TextAttr
      MOV  AL, BackGroundChar
      MOV  DS, VideoSeg
      PUSH CX
      SHL  CX, 1
      ADD  DI, CX
      MOV  SI, DI
      SUB  SI, 2
      POP  CX
    @@1:
      PUSH SI
      PUSH DI
      PUSH CX
      CMP  CL, 0
      JNA  @@3
      PUSH AX
    @@2:
      MOV  AX, [SI]
      MOV  [DI], AX
      SUB  DI, 2
      SUB  SI, 2
      LOOP @@2
      POP  AX
    @@3:
      MOV  [DI], AX
      POP  CX
      POP  DI
      POP  SI
      ADD  DI, BX
      ADD  SI, BX
      DEC  DX
      CMP  DX, $00
      JNE  @@1
      POP  SI
      POP  DI
      POP  DS
      CALL ShowMouse
    end;

  procedure DelColumn; assembler;
    asm
      CALL HideMouse
      PUSH DS
      PUSH DI
      PUSH SI
      MOV  DI, ActiveOfs
      MOV  AX, ScreenWide
      MOV  BX, AX
      MOV  CX, WindMin
      ADD  CL, XYType(WhereXY).X
      MUL  CH
      MOV  CH, 0
      SHL  CX, 1
      ADD  AX, CX
      ADD  DI, AX
      MOV  CX, WindRange
      MOV  DH, 0
      MOV  DL, CH
      MOV  CH, 0
      SUB  CL, XYType(WhereXY).X
      DEC  CL
      MOV  AH, TextAttr
      MOV  AL, BackGroundChar
      MOV  DS, VideoSeg
      MOV  SI, DI
      ADD  SI, 2
    @@1:
      PUSH SI
      PUSH DI
      PUSH CX
      CMP  CL, 0
      JNA  @@3
      PUSH AX
    @@2:
      MOV  AX, [SI]
      MOV  [DI], AX
      ADD  DI, 2
      ADD  SI, 2
      LOOP @@2
      POP  AX
    @@3:
      MOV  [DI], AX
      POP  CX
      POP  DI
      POP  SI
      ADD  DI, BX
      ADD  SI, BX
      DEC  DX
      CMP  DX, $00
      JNE  @@1
      POP  SI
      POP  DI
      POP  DS
      CALL ShowMouse
    end;

  procedure SetActivePage ( Page : byte );
    begin
      if Page <= MaxPage then
        begin
          PageData[ActivePage].WhereXY := WhereXY;
          PageData[ActivePage].WindMin := WindMin;
          PageData[ActivePage].WindMax := WindMax;
          PageData[ActivePage].WindRange := WindRange;
          ActivePage := Page;
          WhereXY    := PageData[ActivePage].WhereXY;
          WindMin    := PageData[ActivePage].WindMin;
          WindMax    := PageData[ActivePage].WindMax;
          WindRange  := PageData[ActivePage].WindRange;
          ActiveOfs  := RegenSize * ActivePage;
          CursorRefresh;
        end
    end;

  procedure SetVisualPage ( Page : byte );
    begin
      if Page <= MaxPage then
        begin
          HideMouse;
          VisualPage := Page;
          SetCurrentVisualPage ( VisualPage );
          VisualOfs := MemW[Seg0040:$004E];
          CursorRefresh;
          ShowMouse;
        end
    end;

  function  GetVisualPage : byte; assembler;
    asm
      MOV AL, VisualPage
    end;

  function  GetActivePage : byte; assembler;
    asm
      MOV AL, ActivePage
    end;

  procedure PrintScreen; assembler;
    asm
      PUSHF
      CALL OldPrint
    end;

  procedure Write( S : String );
    var
      I       : Byte;
      O, Hold : word;
      XY      : word;
    begin
      HideMouse;
      XY   := WindMin + WhereXY;
      O    := ActiveOfs + (Hi(XY) * ScreenWide) + (Lo(XY) Shl 1);
      Hold := O - (Lo(WhereXY) Shl 1);
      For I := 1 to Length(S) do
        begin
          MEM[VideoSeg:O + 1] := TextAttr;
          MEM[VideoSeg:O] := Byte(S[I]);
          Inc( O, 2 );
          Inc( XYType(WhereXY).X);
          if XYType(WhereXY).X = XYType(WindRange).X then
            begin
              XYType(WhereXY).X := 0;
              Inc (XYType(WhereXY).Y);
              if XYType(WhereXY).Y = XYType(WindRange).Y then
                Case Scrolling of
                  True : begin
                    O := Hold;
                    XY := WhereXY - $0100;
                    WhereXY := 0;
                    DelLine;
                    WhereXY := XY;
                  end;
                  False : begin
                    O    := ActiveOfs + (Hi(WindMin) * ScreenWide) +
                            (Lo(WindMin) Shl 1);
                    Hold := O;
                    XYType(WhereXY).Y := 0;
                  end;
                end
              else
                O := Hold + ScreenWide;
            end;
        end;
      CursorRefresh;
      ShowMouse;
    end;

  procedure WriteLn ( S : String );
    var
      XY : word;
    begin
      Write ( S );
      XYType(WhereXY).X := 0;
      Inc (XYType(WhereXY).Y);
      if XYType(WhereXY).Y = XYType(WindRange).Y then
        Case Scrolling of
          True : begin
            XY := WhereXY - $0100;
            WhereXY := 0;
            DelLine;
            WhereXY := XY;
          end;
          False : XYType(WhereXY).Y := 0;
        end;
      CursorRefresh;
    end;

  procedure WriteScreen( var Data; Size : word );
    var
      I       : word;
      O, Hold : word;
      XY      : word;
    begin
      HideMouse;
      XY   := WindMin + WhereXY;
      O    := ActiveOfs + (Hi(XY) * ScreenWide) + (Lo(XY) Shl 1);
      Hold := O - (Lo(WhereXY) Shl 1);
      I := 0;
      While (I < Size) do
        begin
          MemW[VideoSeg:O] := WordCast(Data)[I]; Inc(I);
          Inc( O, 2 );
          Inc( XYType(WhereXY).X);
          if XYType(WhereXY).X = XYType(WindRange).X then
            begin
              XYType(WhereXY).X := 0;
              Inc (XYType(WhereXY).Y);
              if XYType(WhereXY).Y = XYType(WindRange).Y then
                Case Scrolling of
                  True : begin
                    O := Hold;
                    XY := WhereXY - $0100;
                    WhereXY := 0;
                    DelLine;
                    WhereXY := XY;
                  end;
                  False : begin
                    O    := ActiveOfs + (Hi(WindMin) * ScreenWide) +
                            (Lo(WindMin) Shl 1);
                    Hold := O;
                    XYType(WhereXY).Y := 0;
                  end;
                end
              else
                O := Hold + ScreenWide;
            end;
        end;
      CursorRefresh;
      ShowMouse;
    end;

  procedure WriteAttr( Attr : Byte; Size : word );
    var
      I       : word;
      O, Hold : word;
      XY      : word;
    begin
      HideMouse;
      XY   := WindMin + WhereXY;
      O    := ActiveOfs + (Hi(XY) * ScreenWide) + (Lo(XY) Shl 1) + 1;
      Hold := O - (Lo(WhereXY) Shl 1);
      I := 0;
      While (I < Size) do
        begin
          Mem[VideoSeg:O] := Attr; Inc(I);
          Inc( O, 2 );
          Inc( XYType(WhereXY).X);
          if XYType(WhereXY).X = XYType(WindRange).X then
            begin
              XYType(WhereXY).X := 0;
              Inc (XYType(WhereXY).Y);
              if XYType(WhereXY).Y = XYType(WindRange).Y then
                Case Scrolling of
                  True : begin
                    O := Hold;
                    XY := WhereXY - $0100;
                    WhereXY := 0;
                    DelLine;
                    WhereXY := XY;
                  end;
                  False : begin
                    O    := ActiveOfs + (Hi(WindMin) * ScreenWide) +
                            (Lo(WindMin) Shl 1);
                    Hold := O;
                    XYType(WhereXY).Y := 0;
                  end;
                end
              else
                O := Hold + ScreenWide;
            end;
        end;
      CursorRefresh;
      ShowMouse;
    end;

  procedure Fill ( X1, Y1, X2, Y2 : byte );
    var
      OldWindMin    : word;
      OldWindMax    : word;
      OldWhereXY    : word;
      OldAutoCursor : boolean;
    begin
      if (X1 <= XYType(WindRange).X) and (Y1 <= XYType(WindRange).Y) then
        begin
          if X2 > XYType(WindRange).X then X2 := XYType(WindRange).X;
          if Y2 > XYType(WindRange).Y then Y2 := XYType(WindRange).Y;
          OldWindMin    := WindMin;
          OldWindMax    := WindMax;
          OldWhereXY    := WhereXY + $0101;
          OldAutoCursor := AutoCursor;
          AutoCursor    := False;
          Window ( X1 + Lo(OldWindMin), Y1 + Hi(OldWindMin),
                   X2 + Lo(OldWindMin), Y2 + Hi(OldWindMin));
          ClrScr;
          OldWindMin    := OldWindMin + $0101;
          OldWindMax    := OldWindMax + $0101;
          Window (Lo(OldWindMin), Hi(OldWindMin), Lo(OldWindMax), Hi(OldWindMax));
          AutoCursor := OldAutoCursor;
          GotoXY ( Lo(OldWhereXY), Hi(OldWhereXY) );
        end;
    end;

  procedure CopyPage ( FromPage, ToPage : byte );
    var
      FP, TP : Pointer;
    begin
      if (FromPage > MaxPage) or (ToPage > MaxPage) or (FromPage = ToPage) then
        Exit;
      HideMouse;
      if FromPage = ActivePage then
        begin
          PageData[ActivePage].WhereXY := WhereXY;
          PageData[ActivePage].WindMin := WindMin;
          PageData[ActivePage].WindMax := WindMax;
          PageData[ActivePage].WindRange := WindRange;
        end;
      PageData[ToPage] := PageData[FromPage];
      FP := Ptr(VideoSeg, FromPage * RegenSize);
      TP := Ptr(VideoSeg, ToPage * RegenSize);
      Move (FP^, TP^, ScreenWide * Rows );
      if ToPage = ActivePage then
        begin
          WhereXY    := PageData[ActivePage].WhereXY;
          WindMin    := PageData[ActivePage].WindMin;
          WindMax    := PageData[ActivePage].WindMax;
          WindRange  := PageData[ActivePage].WindRange;
        end;
      if AutoCursor then
        with PageData[ToPage] do
          SetCurrentPosition ( ToPage, Lo(WhereXY + WindMin), Hi(WhereXY + WindMin) );
      ShowMouse;
    end;

  const
    SingleChar     : Char7 = 'ڿ
