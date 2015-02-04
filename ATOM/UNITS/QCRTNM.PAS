{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
{$F+,O-}
unit QCRTNM; { version 8.32b }

{ NOTE:  This text mode video interface requires an EGA/VGA compatable
    system.  Although many of the routines in this unit have the same
    names as those in Borland's CRT unit, and preform similar functions in
    a similar way to their counterparts, they are 278% INcompatable with
    that unit, and CANNOT be used together in the same application.  Also,
    you can use system's Write/WriteLn procedures, but the FWriteChar/
    FWrite/FWriteLn are many, many, many times faster.

    This unit also contains quite a bit more code then Borland's CRT unit,
    and when used with very small programs, the compiled size is noticably
    larger.  However, it is usually many times faster, and contains many
    functions overlooked by the CRT unit.  So, if you would like a more
    flexible line editor with mouse support or just a faster screen
    interface give QCRT a try.


    Some functions that are available here, but not CRT unit:

      SubWindow           Sets a new window, within the current window.
      GetMaxX             Returns the width in characters of the window.
      GetMaxY             Returns the height in characters of the window.
      InsChar             Inserts a space on the current line.
      DelChar             Deletes a character on the current line.
      InsColumn           Inserts a column.
      DelColumn           Deletes a column.
      PrintScreen         Prints the screen to the printer.
      FWriteChar          High speed character write.
      FWrite              High speed version of the Write Procedure.
      FWriteLn            High Speed version of the WriteLn Procedure.
      FReadChar           Reads a character directly from the screen.
      FReadAttr           Reads the Textattr directly from the screen.
      FReadCharAttr       Reads a character and attribute from the screen.
      WindowSize          Figures out the memory requirements to store a
                          window.
      GetWindow           Saves an entire window into memory.
      PutWindow           Puts an entire window on the screen.
      MoveCursor          Refreshes the cursor.
      GetCursor           Returns the cursor size and shape.
      SetCursor           Sets the cursors size and shape.
      HideCursor          Make the cursor disappear.
      NormalCursor        Resets the text cursor to its original size/shape.
      SmallCursor         Makes the cursor small.
      HalfCursor          Makes the cursor half as high as a character.
      FullCursor          Makes the cursor the same height as a character.
      GetBlink            Returns the current Blink/Intensity state.
      SetBlink            Toggles the Blink/Intensity state.
      DrawBox             Draws a box.
      DrawShadow          Draws a box shadow.
      DrawLine            Draws a line.
      PurgeEvents         Clears all event buffers.
      ClearEvent          Nulls an event.
      GetEvent            Retrieves a event if it exists.
      PutEvent            Puts an event in a buffer.
      EditLn              High power line editor.
      GetVideoSize        Size of the current video page.
      GetVideoPtr         Returns pointer where screen reads/writes go.
      SetVideoPtr         Sets pointer where screen reads/writes go.
      CopyToVideo         Copies memory from videoptr to the screen.
      CopyFromVideo       Copies screen memory to VideoPtr.
      InitQCRT            Reinitializes the QCrt unit for mode changes.
}

{$DEFINE RollOver} { when defined, if x or y are out of the current window
                     the cursor wraps from one end of the screen to the
                     other.  For example:
                       Window( 1,1,80,25 );
                       GotoXY( 81,25);
                     would be the same as:
                       Window( 1,1,80,25 );
                       GotoXY( 1, 25 ).

                     if not defined, the cursor stops at the end of the
                     window. }

interface

  const
  { CRT modes }
    BW40          = 0;            { 40x25 B/W on Color Adapter }
    CO40          = 1;            { 40x25 Color on Color Adapter }
    BW80          = 2;            { 80x25 B/W on Color Adapter }
    CO80          = 3;            { 80x25 Color on Color Adapter }
    Mono          = 7;            { 80x25 on Monochrome Adapter }
    Font8x8       = $0800;        { Add-in for 8x8 ROM font }
    Font8x14      = $0E00;        { Add-in for 8x14 ROM font, EGA and VGA }
    Font8x16      = $1000;        { Add-in for 8x16 ROM font, VGA only }
    FontUser      = $FF00;        { Add-in for User defined font, VGA only }

  { Mode constants for CRT 3.0 compatibility }
    C40           = CO40;
    C80           = CO80;

  { Foreground and background color/attribute constants }
    Black         = 0;
    Blue          = 1;
    Green         = 2;
    Cyan          = 3;
    Red           = 4;
    Magenta       = 5;
    Brown         = 6;
    LightGray     = 7;

  { Foreground color/attribute constants }
    DarkGray      = 8;
    LightBlue     = 9;
    LightGreen    = 10;
    LightCyan     = 11;
    LightRed      = 12;
    LightMagenta  = 13;
    Yellow        = 14;
    White         = 15;

  { Add-in for blinking and intense background constants }
    Blink         = 128;
    Intensity     = Blink;

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

  { One-Color composite attributes constants }
  { Normal                  = $07; }
    GrayOnBlack             = $08;
  { Bold                    = $0F; }
  { Reverse                 = $70; }
    GrayOnWhite             = $78;
    WhiteOnWhite            = $7F;
  { BlinkingNormal          = $87; }
  { BlinkingBold            = $8F; }

  { Box Constants }
    bxSingle     = $00; { Single Side/Single Top }
    bxDouble     = $03; { Double Side/Double Top }
    bxDoubleSide = $01; { Double Side/Single Top }
    bxDoubleTop  = $02; { Double Top/Single Side }

  { Box Shadow Styles }
    bsSingleWide = $00; { one character wide }
    bsDoubleWide = $01; { two characters wide }

  { Line Constants }
    lnSingle     = $00;
    lnDouble     = $01;
    lnVertical   = $02;
    lnHorizontal = $00;
    lnNoEnds     = $04;
    lnNoCenter   = $08;

  { Event Constants }
    evNothing   = $0000; { Event already handled }
    evKeyDown   = $0010; { Key pressed }
    evKeyboard  = $0010; { Keyboard event }
    evCommand   = $0100; { Command event }
    evBroadcast = $0200; { Broadcast event }
    evSystem    = $0400; { System Event }
    evMessage   = $FF00; { Message (command, broadcast, or user-defined) event }

  { Predefined Event Commands }
    cmNone          = $0000;
    cmClearedEvent  = $0001;
    cmMakeSysReq    = $0002;
    cmBreakSysReq   = $0003;
    cmPrintScreen   = $0004;
    cmBreak         = $0005;
    cmQuit          = $0006;
    cmHelp          = $0007;

  { Keyboard Shift Key Status Flags }
    RightSHift = $0001;
    LeftShift  = $0002;
    EitherCtrl = $0004;
    EitherAlt  = $0008;
    ScrollLock = $0010;
    NumsLock   = $0020;
    CapsLock   = $0040;
    InsertLock = $0080;
    LeftCtrl   = $0100;
    LeftAlt    = $0200;
    SysDown    = $0400;
    PauseFlag  = $0800;
    ScrollDown = $1000;
    NumsDown   = $2000;
    CapsDown   = $4000;
    InsertDown = $8000;

  type
    TPoint = record
      X : byte;
      Y : byte;
    end;

    TEvent = record
      What: Word;
      case Word of
        evNothing: ();
        evKeyDown: (
          ShiftCode : word;
          case Integer of
            0: (KeyCode: Word);
            1: (CharCode: Char;
                ScanCode: Byte));
        evMessage: (
          Command: Word;
          case Word of
            0: (InfoPtr: Pointer);
            1: (InfoLong: Longint);
            2: (InfoWord: Word);
            3: (InfoInt: Integer);
            4: (InfoByte: Byte);
            5: (InfoChar: Char));
    end;

  var
  { Interface variables }
    CheckBreak: Boolean;    { Enable Ctrl-Break checking }
    CheckPrint: Boolean;    { Enable Print Screen checking }
    CheckSysReq: Boolean;   { Enable System Request checking }
    CheckEOF: Boolean;      { Does not do anything }
    DirectVideo: Boolean;   { Enable direct video addressing }
    CheckSnow: Boolean;     { Does not do anything }
    CheckCursor: Boolean;   { Enables automatic cursor movement }
    CheckScroll: Boolean;   { Enables screen scrolling }
    CheckChar: Boolean;     { Enables some ascii control characters }
    Check101: Boolean;      { Enables use of Enhanced 101-key keyboard }
    LastMode: Word;         { Current text mode }
    TextAttr: Byte;         { Current text attribute }
    TextChar: Char;         { Current background fill character }
    InsertMode: boolean;    { Insert/Overtype mode switch }
    WindMin: Word;          { Window upper left coordinates }
    WindMax: Word;          { Window lower right coordinates }
    ScreenMax: Word;        { Screen lower right coordinates }
    BreakCount: Word;       { Number of times CTRL-BREAK has been pressed }
    PrintCount: word;       { Number of times PRINT-SCREEN has been pressed }
    SysReqCount: Word;      { Number of times SYSREQ has been pressed }
    FontHeight: word;       { Height of current defined font }
    UserFontSize: byte;     { Height of user defined font }
    UserFontPtr: Pointer;   { Pointer to user defined font }

    IdleProc : procedure;      { Called while processing a delay }
    PreWriteProc : procedure;  { Called before a screen write }
    PostWriteProc : procedure; { Called after a screen write }
    ReInitProc : procedure;    { Called after Textmode, and InitQCRT }

{ Interface procedures }
  procedure AssignCrt(var F : Text);
  function KeyPressed : Boolean;
  function ReadKey : Char;
  procedure TextMode( Mode : word );
  procedure Window( X1, Y1, X2, Y2 : Byte );
  procedure SubWindow ( X1, Y1, X2, Y2 : byte );
  function GetMaxX : byte;
  function GetMaxY : byte;
  procedure GotoXY( X, Y : Byte );
  function WhereX : Byte;
  function WhereY : Byte;
  procedure ClrScr;
  procedure ClrEol;
  procedure InsLine;
  procedure DelLine;
  procedure InsChar;
  procedure DelChar;
  procedure InsColumn;
  procedure DelColumn;
  procedure TextColor( Color : Byte );
  procedure TextBackground( Color : Byte );
  procedure LowVideo;
  procedure HighVideo;
  procedure NormVideo;
  procedure Delay( MS : Word );
  procedure Sound( Hz : Word );
  procedure NoSound;

{ Print screen dump routine }
  procedure PrintScreen;

{ High speed video write procedures }
  procedure FWriteChar ( Letter : Char );
  procedure FWrite ( Str : String );
  procedure FWriteLn ( Str : String );

{ High speed video read functions }
  function FReadChar : Char;
  function FReadAttr : byte;
  function FReadCharAttr : word;

{ Window functions }
  function WindowSize ( X1, Y1, X2, Y2 : byte ) : word;
  procedure GetWindow ( X1, Y1, X2, Y2 : byte; var Window );
  procedure PutWindow ( X1, Y1 : byte; var Window );

{ Cursor move procedure; Moves cursor to Current XY position when CheckCursor
  is false. }
  procedure MoveCursor;

{ Cursor Size/Shape functions }
  function  GetCursor : word;
  procedure SetCursor ( Cursor : word );
  procedure HideCursor;
  procedure NormalCursor;
  procedure SmallCursor;
  procedure HalfCursor;
  procedure FullCursor;

{ Blink/intensity control }
  function GetBlink : boolean;
  procedure SetBlink ( Blink : boolean );

{ Box and Line Functions }
  procedure DrawBox ( X1, Y1, X2, Y2, Style : byte );
  { Draws a box.  Does not move Cursor. }
  procedure DrawShadow ( X1, Y1, X2, Y2, Style : byte );
  { Draws a shadow for a box.  Does not move Cursor. }
  procedure DrawLine ( X1, Y1, Len, Style : byte );
  { Draws a line.  Does not move the Cursor. }

{ Event Functions }
  procedure PurgeEvents;
  procedure ClearEvent(var Event : TEvent);
  procedure GetEvent(var Event : TEvent);
  function  PutEvent(var Event : TEvent) : boolean;

{ Text input functions }
  function EditLn ( var Dest : String; First : boolean;
    MaxLen, MaxWide : Byte; var Event : TEvent) : boolean;
  { High power line editor. And is used internally by System's Read and
    ReadLn procedures. }

{ Direct Video Memory Procedures }
  { Returns total bytes of memory required to save current video page }
  function GetVideoSize : word;
  { Returns current video read/write pointer }
  function  GetVideoPtr : Pointer;
  { Sets current video read/write pointer }
  procedure SetVideoPtr ( P : Pointer );
  { Copies video from video read/write ptr to video memory pointer }
  procedure CopyToVideo;
  { Copies video from video memory to the video read/write pointer.  Note that
    it copies GetVideoSize bytes to memory, and when changing text modes the
    number of bytes may change also, the video read/write pointer is reset to
    video memory. }
  procedure CopyFromVideo;

{ Unit variable reset procedure; Must call if an external procedure changes
  video modes (InitQCRT is called internally by TextMode, and at application
  startup). }
  procedure InitQCRT;

implementation

  const
    KeyBufSize         = 16;
    CommandBufSize     = 128;
    fmClosed           = $D7B0;
    fmInput            = $D7B1;
    fmOutput           = $D7B2;
    fmInOut            = $D7B3;

{$F+}
(* Internal Event Buffer Handler *)
  type
    PEvents = ^TEvents;
    TEvents = array[1..$FFFF div Sizeof(TEvent)] of TEvent;
    EventBuf = object
         Buf   : PEvents;
         Head,
         Tail,
         Max,
         Count : word;
      procedure Init( ABuf : PEvents; AMax : word );
      procedure Done;
      procedure Purge;
      function  UsedSpace : word;
      function  FreeSpace : word;
      function  GetEvent(var Event : TEvent) : boolean;
      function  PutEvent(var Event : TEvent) : boolean;
    end;

  procedure EventBuf.Init( ABuf : PEvents; AMax : word );
    begin
      Buf := ABuf;
      Max := AMax;
      Purge;
    end;

  procedure EventBuf.Done;
    begin
      Purge;
    end;

  procedure EventBuf.Purge;
    begin
      Head  := 1;
      Tail  := 1;
      Count := 0;
    end;

  function  EventBuf.UsedSpace : word;
    begin
      UsedSpace := Count;
    end;

  function  EventBuf.FreeSpace : word;
    begin
      FreeSPace := Max - Count;
    end;

  function  EventBuf.GetEvent(var Event : TEvent) : boolean;
    begin
      if UsedSpace > 0 then
        begin
          Event := Buf^[Head];
          Inc(Head);
          Inc(Count);
          if Head > Max then Head := 1;
          GetEvent := True;
        end
      else
        GetEvent := False;
    end;

  function  EventBuf.PutEvent(var Event : TEvent) : boolean;
    begin
      if FreeSpace > 0 then
        begin
          Buf^[Tail] := Event;
          Inc(Tail);
          Dec(Count);
          if Tail > Max then Tail := 1;
          PutEvent := True;
        end
      else
        PutEvent := False;
    end;

(* Internal Data Types and variables *)
  type
    BIOSDataType = record
      Mode            : byte;
      Columns         : word;
      RegenSize       : word;
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
    end;
    WindowType = record
      Width  : byte;
      Height : byte;
      Data   : Array[0..$7FFD] of word;
    end;

    PTextBuf = ^TTextBuf;
    TTextBuf = array[0..127] of Char;
    TTextName = array[0..79] of char;
    TTextRec = record
      Handle: Word;
      Mode: Word;
      BufSize: Word;
      Private: Word;
      BufPos: Word;
      BufEnd: Word;
      BufPtr: PTextBuf;
      OpenFunc: function  ( var F ) : integer;
      InOutFunc: function ( var F ) : integer;
      FlushFunc: function ( var F ) : integer;
      CloseFunc: function ( var F ) : integer;
      UserData: array[1..16] of Byte;
      Name: TTextName;
      Buffer: TTextBuf;
    end;

    BoxStr = Array[0..6] of Char;
    LineStr = String[41];


  const
    BoxData : array[bxSingle..bxDouble] of BoxStr = (
       'Ú¿ÀÙÄ³', {bxSingle}
       'Ö·Ó½Äº', {bxDoubleSide}
       'Õ¸Ô¾Í³', {bxDoubleTop}
       'É»È¼Íº'  {bxDouble}
    );
    LineData : record
      Current : LineStr;
      Style: array[lnSingle..lnDouble,boolean,(Top, Middle, Bottom)] of LineStr;
    end = (
      Current:'ÍÄº³ÉË»ÌÎ¹ÈÊ¼ÖÒ·Ç×¶ÓÐ½ÕÑ¸ÆØµÔÏ¾ÚÂ¿ÃÅ´ÀÁÙ';
      Style:(

      ( { Single Line }
        ( { Horizontal }
          'ÄÄÇÃÖÒÒÇ××ÓÐÐÖÒÒÇ××ÓÐÐÚÂÂÃÅÅÀÁÁÚÂÂÃÅÅÀÁÁÄ', { Left }
          'ÄÄ×ÅÒÒÒ×××ÐÐÐÒÒÒ×××ÐÐÐÂÂÂÅÅÅÁÁÁÂÂÂÅÅÅÁÁÁÄ', { Middle }
          'ÄÄ¶´ÒÒ·××¶ÐÐ½ÒÒ·××¶ÐÐ½ÂÂ¿ÅÅ´ÁÁÙÂÂ¿ÅÅ´ÁÁÙÄ'  { Right }),
        ( { Vertical }
          'ÑÂ³³ÕÑ¸ÆØµÆØµÚÂ¿ÃÅ´ÃÅ´ÕÑ¸ÆØµÆØµÚÂ¿ÃÅ´ÃÅ´³', { Top }
          'ØÅ³³ÆØµÆØµÆØµÃÅ´ÃÅ´ÃÅ´ÆØµÆØµÆØµÃÅ´ÃÅ´ÃÅ´³', { Middle }
          'ÏÁ³³ÆØµÆØµÔÏ¾ÃÅ´ÃÅ´ÀÁÙÆØµÆØµÔÏ¾ÃÅ´ÃÅ´ÀÁÙ³'  { Bottom })),
      ( { Double Line }
        ( { Horizontal }
          'ÍÍÌÆÉËËÌÎÎÈÊÊÉËËÌÎÎÈÊÊÕÑÑÆØØÔÏÏÕÑÑÆØØÔÏÏÍ', { Left }
          'ÍÍÎØËËËÎÎÎÊÊÊËËËÎÎÎÊÊÊÑÑÑØØØÏÏÏÑÑÑØØØÏÏÏÍ', { Middle }
          'ÍÍ¹µËË»ÎÎ¹ÊÊ¼ËË»ÎÎ¹ÊÊ¼ÑÑ¸ØØµÏÏ¾ÑÑ¸ØØµÏÏ¾Í'  { Right }),
        ( { Vertical }
          'ËÒººÉË»ÌÎ¹ÌÎ¹ÖÒ·Ç×¶Ç×¶ÉË»ÌÎ¹ÌÎ¹ÖÒ·Ç×¶Ç×¶º', { Top }
          'Î×ººÌÎ¹ÌÎ¹ÌÎ¹Ç×¶Ç×¶Ç×¶ÌÎ¹ÌÎ¹ÌÎ¹Ç×¶Ç×¶Ç×¶º', { Middle }
          'ÊÐººÌÎ¹ÌÎ¹ÈÊ¼Ç×¶Ç×¶ÓÐ½ÌÎ¹ÌÎ¹ÈÊ¼Ç×¶Ç×¶ÓÐ½º'  { Bottom }))
      )
    );

  var
    TimerTick    : LongInt absolute $0040:$006c;  { Timer tick counter }
    OldExitProc  : pointer;        { Address of old exit procedure }
    OldInt05     : procedure;      { Address of old interrupt vector 05h }
    OldInt09     : procedure;      { Address of old interrupt vector 09h }
    OldInt15     : procedure;      { Address of old interrupt vector 15h }
    OldInt1B     : procedure;      { Address of old interrupt vector 1Bh }
    OldInt23     : procedure;      { Address of old interrupt vector 23h }
    BIOSPtr      : ^BIOSDataType;  { Pointer to main Video BIOS Data }
    VideoPtr     : pointer;        { Pointer to video memory }
    VideoSeg     : word;           { Video segment for direct video writes }
    ActiveOfs    : word;           { Offset for direct video writes }
    ActivePage   : byte;           { Page number of active video page }
    RegenSize    : word;           { Size of video regen buffer }
    CursorXY     : word;           { Absolute screen location of cursor }
    BytesPerLine : word;

    FirstAttr    : byte;           { StartUp TextAttr }
    FirstCursor  : word;           { StartUp Cursor Size/Shape }
    FirstBlink   : boolean;        { Startup Blink/Intensity setting }

    SysReqMake   : word;
    SysReqBreak  : word;

    KeyBuffer     : array[1..KeyBufSize] of TEvent;
    CommandBuffer : array[1..CommandBufSize] of TEvent;
    KeyBuf        : EventBuf;
    CommandBuf    : EventBuf;


(* Internal Keyboard Routines *)
  function ReadKeyboardStd : word; assembler;
    asm
      MOV  AH, 00h
      INT  16h
      CMP  AL, 00h
      JE   @@Done
      MOV  AH, 00h
    @@Done:
    end;

  function KeypressedStd : boolean; assembler;
    asm
      MOV  AH, 01h
      INT  16h
      MOV  AL, False
      JZ   @@Done
      MOV  AL, True
    @@Done:
    end;

  function ReadKeyboardEnh : word; assembler;
    asm
      MOV  AH, 10h
      INT  16h
      CMP  AL, 00h
      JE   @@Done2
      CMP  AL, 0E0h
      JE   @@Done1
      MOV  AH, 00h
      JMP  @@Done2
    @@Done1:
      MOV  AL, 00h
    @@Done2:
    end;

  function KeypressedEnh : boolean; assembler;
    asm
      MOV  AH, 11h
      INT  16h
      MOV  AL, False
      JZ   @@Done
      MOV  AL, True
    @@Done:
    end;

(* Internal service routines *)
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

  procedure SetCursorLoc; assembler;
    asm
      MOV  AH, 02h
      MOV  BH, ActivePage
      MOV  DX, CursorXY
      INT  10h
    end;

  procedure GetCursorLoc; assembler;
    asm
      MOV  AH, 03h
      MOV  BH, ActivePage
      INT  10h
      MOV  CursorXY, DX
    end;

  procedure UpdateCursor; assembler;
    asm
      CMP  CheckCursor, True
      JNE  @@Done
      CALL  SetCursorLoc
    @@Done:
    end;

  function GetVideoOfs( XY : word ) : word; assembler;
    asm
      PUSH BX
      PUSH CX
      PUSH DX
      MOV  BX, ActiveOfs
      MOV  AX, BytesPerLine
      MOV  CX, XY
      MOV  DL, CH
      XOR  DH, DH
      MUL  DX
      ADD  BX, AX
      MOV  AX, 0002h
      XOR  CH, CH
      MUL  CX
      ADD  AX, BX
      POP  DX
      POP  CX
      POP  BX
    end;

  function Return : word; assembler;
    asm
      MOV  DX, CursorXY
      MOV  AX, WindMin
      MOV  CX, WindMax
      MOV  DL, AL
      INC  DH
      CMP  DH, CH
      JNG  @@Return2
      CMP  CheckScroll, False
      JE   @@Return1
      PUSH DX
      MOV  CursorXY, AX
      CALL DelLine
      POP  DX
      DEC  DH
      JMP  @@Return3
    @@Return1:
      MOV  DX, AX
    @@Return2:
    @@Return3:
      MOV  CursorXY, DX
      CALL UpdateCursor
      MOV  AX, CursorXY
    end;

  function LineFeed : word; assembler;
    asm
      MOV  DX, CursorXY
      MOV  AX, WindMin
      MOV  CX, WindMax
      MOV  DL, AL
      INC  DH
      CMP  DH, CH
      JNG  @@Return2
      CMP  CheckScroll, False
      JE   @@Return1
      PUSH DX
      MOV  CursorXY, AX
      CALL DelLine
      POP  DX
      DEC  DH
      JMP  @@Return3
    @@Return1:
      MOV  DX, AX
    @@Return2:
    @@Return3:
      MOV  CX, CursorXY
      MOV  DL, CL
      MOV  CursorXY, DX
      CALL UpdateCursor
      MOV  AX, CursorXY
    end;

  procedure NullProc; far; assembler;
    asm
    end;

  procedure IdleMouseProc; far;
    var
      X,
      Y,
      Attr   : byte;
      WMin,
      WMax,
      Cursor : word;
    begin
      Cursor := GetCursor;
      X := WhereX;
      Y := WhereY;
      WMin := WindMin;
      WMax := WindMax;
      Attr := TextAttr;
      Window(1, 1, Lo(ScreenMax) + 1, Hi(ScreenMax) + 1);
      IdleProc;
      Window(Lo(WMin) + 1, Hi(WMin) + 1, Lo(WMax) + 1, Hi(WMax) + 1);
      GotoXY ( X, Y );
      TextAttr := Attr;
      MoveCursor;
      SetCursor(Cursor);
    end;

  procedure PreWriteMouseProc; far;
    begin
      PreWriteProc;
    end;

  procedure PostWriteMouseProc; far;
    begin
      PostWriteProc;
    end;

  procedure ReInitMouseProc; far;
    begin
    end;

  procedure PreWrite; assembler;
    const
      Level : word = 0;
    asm
      CMP  Level, 0
      JNE  @@Done
      INC  Level
      PUSH AX
      PUSH BX
      PUSH CX
      PUSH DX
      PUSH SI
      PUSH DI
      PUSH ES
      CALL PreWriteMouseProc
      POP  ES
      POP  DI
      POP  SI
      POP  DX
      POP  CX
      POP  BX
      POP  AX
      DEC  Level
    @@Done:
    end;

  procedure PostWrite; assembler;
    const
      Level : word = 0;
    asm
      CMP  Level, 0
      JNE  @@Done
      INC  Level
      PUSH AX
      PUSH BX
      PUSH CX
      PUSH DX
      PUSH SI
      PUSH DI
      PUSH ES
      CALL PostWriteMouseProc
      POP  ES
      POP  DI
      POP  SI
      POP  DX
      POP  CX
      POP  BX
      POP  AX
      DEC  Level
    @@Done:
    end;

{ Print-Screen Handler }
  procedure VideoInt05; Interrupt; assembler; { Print-Screen }
    asm
      CMP  CheckPrint, True
      JE   @PrintIt
      INC  PrintCount
      JMP  @Done
    @PrintIt:
      CALL PrintScreen
    @Done:
    end;

{ Keyboard Interrupt }
  procedure VideoInt09; interrupt;
    var
      Event : TEvent;
    begin
      asm
        PUSHF
        CALL OldInt09
      end;
      Event.What := evKeyDown;
      Event.InfoPtr := nil;
      Event.ShiftCode := MemW[Seg0040:$0017];
      case Check101 of
        False : if KeypressedStd then begin
          Event.KeyCode := ReadKeyboardStd;
          KeyBuf.PutEvent( Event );
        end;
        True : if KeypressedEnh then begin
          Event.KeyCode := ReadKeyboardEnh;
          KeyBuf.PutEvent( Event );
        end;
      end;
  end;

{ SysReq Handler }
  procedure SysReqPtr; assembler;
    asm
      DW 0,0
    end;

  procedure VideoInt15; assembler; { SysReq }
  { This CANNOT be compiled as interrupt or it won't work properly. The
    SysReq key is only on of the services provided by this interrupt.
    And Turbo Pascal PUSH'S AND POP'S everthing in an interrupt procedure,
    so the return data would get lost. }
    asm
      PUSHF
      PUSH DS
      PUSH AX
      MOV  AX, SEG @DATA
      MOV  DS, AX
      POP  AX

      CMP  AH, 85h
      JNE  @Done

      CMP  CheckSysReq, True
      JE   @Done

      CMP  AL, 0
      JNE  @KeyBreak
      INC  SysReqCount
      INC  SysReqMake
      JMP  @Bye
    @KeyBreak:
      INC  SysReqBreak
    @Bye:
      POP  DS
      POPF
      IRET
    @Done:
      POP  DS
      CALL DWORD PTR CS:[OFFSET SysReqPtr]
      IRET
    end;

(* New Interrupt 1B *)
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

(* New Interrupt 23 *)
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

(* Unit shutdown procedure *)
  procedure DoneVideoUnit; far;
    begin
      ExitProc      := OldExitProc;
      IdleProc      := NullProc;
      PreWriteProc  := NullProc;
      PostWriteProc := NullProc;
      ReInitProc    := NullProc;
      SetIntVec($05, @OldInt05 );
      SetIntVec($09, @OldInt09 );
      SetIntVec($15, @OldInt15 );
      SetIntVec($1B, @OldInt1B );
      SetIntVec($23, @OldInt23 );
      Assign(Output, '');
      Assign(Input, '');
      ReWrite(Output);
      Reset(Input);
      CommandBuf.Done;
      KeyBuf.Done;
    end;

(* Unit initialization procedure *)
  procedure InitQCRTUnit;
    var
      P : Pointer;
    begin
      KeyBuf.Init    (@KeyBuffer, KeyBufSize);
      CommandBuf.Init(@KeyBuffer, KeyBufSize);
      IdleProc      := NullProc;
      PreWriteProc  := NullProc;
      PostWriteProc := NullProc;
      ReInitProc    := NullProc;
      BIOSptr := Ptr(Seg0040, $0049);
      CheckBreak    := True;
      CheckPrint    := True;
      CheckSysReq   := True;
      InsertMode    := True;
      Check101      := (Mem[Seg0040:$0096]) and $10 = $10;
      CheckEOF      := False;
      CheckSnow     := False;
      CheckCursor   := True;
      CheckScroll   := True;
      CheckChar     := True;
      BreakCount    := 0;
      PrintCount    := 0;
      SysReqCount   := 0;
      SysReqMake    := 0;
      SysReqBreak   := 0;
      UserFontSize  := 8;
      UserFontPtr   := Pointer(MemL[0:$0043 * 4]);
      FirstCursor   := GetCursor;
      FirstBlink    := GetBlink;
      FirstAttr     := TextAttr;
      GetIntVec($05, @OldInt05 );
      GetIntVec($09, @OldInt09 );
      GetIntVec($15, @OldInt15 );
      GetIntVec($1B, @OldInt1B );
      GetIntVec($23, @OldInt23 );
      P := @SysReqPtr;
      P := Ptr(Seg(P^), Ofs(P^));
      Move (OldInt15, P^, Sizeof(Pointer));
      OldExitProc   := ExitProc;
      ExitProc      := @DoneVideoUnit;
      SetIntVec($05, @VideoInt05 );
      SetIntVec($09, @VideoInt09 );
      SetIntVec($15, @VideoInt15 );
      SetIntVec($1B, @VideoInt1B );
      SetIntVec($23, @VideoInt23 );
      AssignCrt(Output);
      Rewrite(Output);
      AssignCRT(Input);
      Reset(Input);
      InitQCRT;
    end;

(* variable reset procedure *)
  procedure InitQCRT;
    begin
    { Default DirectVideo to True if in any text mode. }
      DirectVideo := (BIOSPtr^.Mode = BW40) or (BIOSPtr^.Mode = BW80) or
                     (BIOSPtr^.Mode = CO40) or (BIOSPtr^.Mode = CO80) or
                     (BIOSPtr^.Mode = MONO);
    { Initialize LastMode to Current Mode and Font size }
      LastMode    := BIOSPtr^.Mode + (BIOSPtr^.CharSize Shl 8);
    { Initialize VideoSeg, and Offsets, and pages. }
      if LastMode and $00FF = Mono then
        VideoSeg := SegB000
      else
        VideoSeg := SegB800;
      ActiveOfs  := BIOSPtr^.VisualOfs;
      VideoPtr   := Ptr(VideoSeg, ActiveOfs);
      ActivePage := BIOSPtr^.VisualPage;
      RegenSize  := BIOSPtr^.RegenSize;
    { Initialize Current Text Attribute }
      Case DirectVideo of
        True  : TextAttr := Mem[VideoSeg:ActiveOfs + (BIOSPtr^.Columns shl 1) * (BIOSPtr^.Rows + 1) - 1];
        False : TextAttr := LightGray;
      end;
      TextChar := #32;
    { Initialize Window Limits }
      ScreenMax  := (Word(BIOSPtr^.Rows) Shl 8) + (BIOSPtr^.Columns - 1);
      WindMin    := $0000;
      WindMax    := ScreenMax;
      BytesPerLine := BIOSPtr^.Columns shl 1;
      FontHeight := Word(Mem[Seg0040:$0085]);
      GetCursorLoc;
      ReInitMouseProc;
    end;

(* Standard CRT like procedures *)
  function KeyPressed: Boolean;
    begin
      Keypressed := KeyBuf.UsedSpace > 0;
    end;

  function ReadKey: Char;
    const
      Next : String[1] = '';
    var
      Event : TEvent;
    begin
      if Next <> '' then
        begin
          ReadKey := Next[1];
          Next := '';
        end
      else
        begin
          While Not KeyBuf.GetEvent(Event) do;
          if Event.CharCode = #0 then
            Next := Char(Event.ScanCode);
          ReadKey := Event.CharCode;
        end;
    end;

  procedure TextMode(Mode: word); assembler;
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
      CMP CX, FontUser
      JE  @@LoadUserFont
      JMP @@Done
    @@LoadUserFont:
      PUSH BP
      MOV AX, $1110
      MOV BL, $00
      MOV CX, $00FF
      MOV DX, $0000
      MOV BH, UserFontSize
      LES BP, UserFontPtr
      INT $10
      POP BP
      JMP @@Done
    @@LoadFont:
      MOV AH, $11
      MOV BL, 0 { Font block to Load }
      INT $10
    @@Done:
      CALL InitQCRT
    end;

  procedure Window(X1,Y1,X2,Y2: Byte); assembler;
    asm
      MOV  AL, X1
      MOV  AH, Y1
      MOV  CL, X2
      MOV  CH, Y2
      SUB  AX, 0101h
      SUB  CX, 0101h
      CMP  AL, CL
      JLE  @@NoSwap1
      XCHG AL, CL
    @@NoSwap1:
      CMP  AH, CH
      JLE  @@NoSwap2
      XCHG AH, CH
    @@NoSwap2:
      CMP  AL, 0
      JL   @@BadWindow
      CMP  AH, 0
      JL   @@BadWindow
      MOV  DX, ScreenMax
      CMP  CL, DL
      JG   @@BadWindow
      CMP  CH, DH
      JG   @@BadWindow
      MOV  WindMin, AX
      MOV  WIndMax, CX
      MOV  CursorXY, AX
      CALL UpdateCursor
    @@BadWindow:
    end;

  procedure SubWindow ( X1, Y1, X2, Y2 : byte ); assembler;
    asm
      MOV BX, WindMin
      MOV CX, WindMax
      ADD CX, 0101h
      MOV AL, X1
      MOV AH, Y1
      MOV DL, X2
      MOV DH, Y2
      ADD AX, BX
      ADD DX, BX
      CMP AL, CL
      JG  @@Done
      CMP DL, CL
      JG  @@Done
      CMP AH, CH
      JG  @@Done
      CMP DH, CH
      JG  @@Done
      XOR  CX, CX
      MOV  CL, AL
      PUSH CX
      MOV  CL, AH
      PUSH CX
      MOV  CL, DL
      PUSH CX
      MOV  CL, DH
      PUSH CX
      CALL Window
    @@Done:
    end;

  function GetMaxX : byte; assembler;
    asm
      MOV  AX, WindMax
      SUB  AX, WindMin
      INC  AL
    end;

  function GetMaxY : byte; assembler;
    asm
      MOV  AX, WindMax
      SUB  AX, WindMin
      MOV  AL, AH
      INC  AL
    end;

  procedure GotoXY(X,Y: Byte); assembler;
    asm
      MOV  AL, X
      MOV  AH, Y
      ADD  AX, WindMin
      SUB  AX, 0101h
      MOV  DX, WindMax
      MOV  CX, WindMin
    {$IFDEF RollOver }
      PUSH BX
      MOV  BX, DX
      SUB  BX, CX
      ADD  BX, 0101H
    {$ENDIF}
    @@Step1:
      CMP  AL, DL
      JLE  @@Step2
    {$IFDEF RollOver }
      SUB  AL, BL
      JMP  @@Step1
    {$ELSE}
      MOV  AL, DL
    {$ENDIF}
    @@Step2:
      CMP  AL, CL
      JGE  @@Step3
    {$IFDEF RollOver}
      ADD  AL, BL
      JMP  @@Step2
    {$ELSE}
      MOV  AL, CL
    {$ENDIF}
    @@Step3:
      CMP  AH, DH
      JLE  @@Step4
    {$IFDEF RollOver}
      SUB  AH, BH
      JMP  @@Step3
    {$ELSE}
      MOV  AH, DH
    {$ENDIF}
    @@Step4:
      CMP  AH, CH
      JGE  @@Step5
    {$IFDEF RollOver}
      ADD  AH, BH
      JMP  @@Step4
    {$ELSE}
      MOV  AH, CH
    {$ENDIF}
    @@Step5:
    {$IFDEF RollOver}
      POP  BX
    {$ENDIF}
      MOV  CursorXY, AX
      CALL UpdateCursor
    end;

  function WhereX: Byte; assembler;
    asm
      MOV  AX, CursorXY
      SUB  AX, WindMin
      INC  AL
    end;

  function WhereY: Byte; assembler;
    asm
      MOV  AX, CursorXY
      SUB  AX, WindMin
      INC  AH
      MOV  AL, AH
    end;

  procedure ClrArea ( XY1, XY2 : word ); assembler;
    asm
      CALL PreWrite
      CMP  DirectVideo, True
      JE   @@Direct
      MOV  CX, XY1
      MOV  DX, XY2
      CMP  TextChar, 32
      JNE  @@Write1
      MOV  AX, 0600h
      MOV  BH, TextAttr
      INT  10h
      JMP  @@Done
    @@Write1:
      ADD  DX, $0101
      PUSH CX
      PUSH DX
      MOV  AH, 03h
      MOV  BH, ActivePage
      INT  10h
      MOV  AX, DX
      POP  DX
      POP  CX
      PUSH AX
      MOV  AL, TextChar
      MOV  BL, TextAttr
    @@Write2:
      PUSH CX
      PUSH DX
      MOV  AH, 02h
      XCHG CX, DX
      INT  10h
      MOV  AH, 09h
      SUB  CX, DX
      XOR  CH, CH
      INT  10h
      POP  DX
      POP  CX
      INC  CH
      CMP  CH, DH
      JNE  @@Write2
      POP  DX
      MOV  AH, 02h
      INT  10h
      JMP  @@Done
    @@Direct:
      MOV  DX, XY1
      MOV  CX, XY2
      SUB  CX, DX
      ADD  CX, $0101
      PUSH DX; CALL GetVideoOfs
      MOV  DI, AX
      MOV  DX, BytesPerLine
      MOV  AL, TextChar
      MOV  AH, TextAttr
      MOV  ES, VideoSeg
      CLD
    @@WriteLoop1:
      PUSH CX
      PUSH DI
      XOR  CH, CH
      REP  STOSW
      POP  DI
      ADD  DI, DX
      POP  CX
      DEC  CH
      CMP  CH, 0
      JNZ  @@WriteLoop1
    @@Done:
      CALL PostWrite
    end;

  procedure ClrScr; assembler;
    asm
      MOV  CX, WindMin
      MOV  DX, WindMax
      MOV  CursorXY, CX
      PUSH CX
      PUSH DX
      CALL ClrArea
      CALL UpdateCursor
    end;

  procedure ClrEol; assembler;
    asm
      MOV  CX, CursorXY
      MOV  DX, WindMax
      MOV  DH, CH
      PUSH CX
      PUSH DX
      CALL ClrArea
      CALL UpdateCursor
    end;

  procedure InsLine; assembler;
    asm
      CALL PreWrite
      MOV  DX, WindMin
      MOV  CX, WindMax
      MOV  AX, CursorXY
      MOV  DH, AH
      CMP  DirectVideo, True
      JE   @@Direct
      XCHG CX, DX
      MOV  AX, 0701h
      MOV  BH, TextAttr
      INT  10h
      CMP  TextChar, 32
      JNE  @@Write1
      CALL UpdateCursor
      JMP  @@Done
    @@Write1:
      CALL ClrEOL
      JMP  @@Done
    @@Direct:
      { Compute Range, Bytes Per Line & Video Offset }
      SUB  CX, DX
      ADD  CX, $0101
      PUSH CX
      MOV  CX, DX
      MOV  DI, ActiveOfs
      MOV  AX, ScreenMax
      XOR  AH, AH
      INC  AL
      PUSH AX
      MOV  DX, CX
      MOV  DL, DH
      XOR  DH, DH
      MUL  DX
      MOV  DX, CX
      XOR  DH, DH
      ADD  AX, DX
      MOV  DL, 02h
      MUL  DX
      ADD  DI, AX
      POP  AX
      MOV  DL, 02h
      MUL  DX
      MOV  DX, AX
      POP  CX
      PUSH DX
      MOV  DX, CX
      MOV  DL, DH
      XOR  DH, DH
      MUL  DX
      MOV  SI, AX
      ADD  SI, DI
      POP  DX
      { DI = Video Offset; CX = WindRange; DX = Bytes per Line }
      MOV  AL, TextChar
      MOV  AH, TextAttr
      MOV  ES, VideoSeg
      PUSH DS
      PUSH ES; POP DS { MOV DS, ES }
      CMP  CH, 1
      JE   @@Direct3
      PUSH AX
      PUSH DI
      SUB  SI, DX
      MOV  DI, SI
      SUB  SI, DX
      DEC  CH
    @@Direct2:
      PUSH CX
      PUSH SI
      PUSH DI
      XOR  CH, CH
      CLD
      REP  MOVSW
      POP  DI
      POP  SI
      POP  CX
      SUB  DI, DX
      SUB  SI, DX
      DEC  CH
      CMP  CH, 0
      JNE  @@Direct2
      POP  DI
      POP  AX
    @@Direct3:
      XOR  CH, CH
      REP  STOSW
      POP  DS
      CALL UpdateCursor
    @@Done:
      CALL PostWrite
    end;

  procedure DelLine; assembler;
    asm
      CALL PreWrite
      MOV  DX, WindMin
      MOV  CX, WindMax
      MOV  AX, CursorXY
      MOV  DH, AH
      CMP  DirectVideo, True
      JE   @@Direct
      XCHG CX, DX
      MOV  AX, 0601h
      MOV  BH, TextAttr
      INT  10h
      CMP  TextChar, 32
      JE  @@Write1
      MOV  CH, DH
      PUSH CX
      PUSH DX
      CALL ClrArea
    @@Write1:
      CALL UpdateCursor
      JMP  @@Done
    @@Direct:
      { Compute Range, Bytes Per Line & Video Offset }
      SUB  CX, DX
      ADD  CX, $0101
      PUSH CX
      MOV  CX, DX
      MOV  DI, ActiveOfs
      MOV  AX, ScreenMax
      XOR  AH, AH
      INC  AL
      PUSH AX
      MOV  DX, CX
      MOV  DL, DH
      XOR  DH, DH
      MUL  DX
      MOV  DX, CX
      XOR  DH, DH
      ADD  AX, DX
      MOV  DL, 02h
      MUL  DX
      ADD  DI, AX
      POP  AX
      MOV  DL, 02h
      MUL  DX
      MOV  DX, AX
      POP  CX
      { DI = Video Offset; CX = WindRange; DX = Bytes per Line }
      MOV  AL, TextChar
      MOV  AH, TextAttr
      MOV  ES, VideoSeg
      PUSH DS
      PUSH ES; POP DS { MOV DS, ES }
      CMP  CH, 1
      JE   @@Direct3
      PUSH AX
      MOV  SI, DI
      ADD  SI, DX
      DEC  CH
    @@Direct2:
      PUSH CX
      PUSH SI
      PUSH DI
      XOR  CH, CH
      CLD
      REP  MOVSW
      POP  DI
      POP  SI
      POP  CX
      ADD  DI, DX
      ADD  SI, DX
      DEC  CH
      CMP  CH, 0
      JNE  @@Direct2
      POP  AX
    @@Direct3:
      XOR  CH, CH
      REP  STOSW
      POP  DS
      CALL UpdateCursor
    @@Done:
      CALL PostWrite
    end;

  procedure InsChar; assembler;
    asm
      CALL PreWrite
      MOV  DX, WindMax
      MOV  CX, CursorXY
      CMP  DirectVideo, True
      JE   @@Direct
      MOV  DH, CH
      MOV  BH, ActivePage
    @@Bios1:
      CMP  CL, DL
      JE   @@Bios2
      PUSH CX
      MOV  AH, 02h
      DEC  DX
      INT  10h
      MOV  AH, 08h
      INT  10h
      MOV  BL, AH
      MOV  CX, 01h
      MOV  AH, 02h
      INC  DX
      INT  10h
      MOV  AH, 09h
      INT  10h
      POP  CX
      DEC  DX
      JMP  @@Bios1
    @@Bios2:
      MOV  AH, 02h
      INT  10h
      MOV  AH, 09h
      MOV  CX, 01h
      MOV  BL, TextAttr
      MOV  AL, TextChar
      INT  10h
      JMP  @@Done
    @@Direct:
      PUSH DS
      PUSH DX
      MOV  AX, ScreenMax
      XOR  AH, AH
      INC  AL
      MUL  CH
      POP  DX
      XOR  DH, DH
      ADD  AX, DX
      SHL  AX, 1
      SUB  DL, CL
      MOV  CX, DX
      MOV  DI, AX
      MOV  SI, AX
      SUB  SI, 2
      MOV  ES, VideoSeg
      MOV  AL, TextChar
      MOV  AH, TextAttr
      MOV  DS, VideoSeg
      STD
      PUSH AX
      REP  MOVSW
      POP  AX
      STOSW
      POP  DS
      CALL UpdateCursor
    @@Done:
      CALL PostWrite
    end;

  procedure DelChar; assembler;
    asm
      CALL PreWrite
      MOV  CX, WindMax
      MOV  DX, CursorXY
      CMP  DirectVideo, True
      JE   @@Direct
      MOV  BH, ActivePage
    @@Bios1:
      CMP  CL, DL
      JE   @@Bios2
      PUSH CX
      MOV  AH, 02h
      INC  DX
      INT  10h
      MOV  AH, 08h
      INT  10h
      MOV  BL, AH
      MOV  CX, 01h
      MOV  AH, 02h
      DEC  DX
      INT  10h
      MOV  AH, 09h
      INT  10h
      POP  CX
      INC  DX
      JMP  @@Bios1
    @@Bios2:
      MOV  AH, 02h
      INT  10h
      MOV  AH, 09h
      MOV  CX, 01h
      MOV  BL, TextAttr
      MOV  AL, TextChar
      INT  10h
      CALL UpdateCursor
      JMP  @@Done
    @@Direct:
      PUSH DS
      PUSH DX
      MOV  AX, ScreenMax
      XOR  AH, AH
      INC  AL
      MUL  DH
      POP  DX
      XOR  DH, DH
      ADD  AX, DX
      SHL  AX, 1
      SUB  CL, DL
      XOR  CH, CH
      MOV  DI, AX
      MOV  SI, AX
      ADD  SI, 2
      MOV  ES, VideoSeg
      MOV  AL, TextChar
      MOV  AH, TextAttr
      MOV  DS, VideoSeg
      CLD
      CMP  CX, 0
      JE   @@Direct2
      PUSH AX
      REP  MOVSW
      POP  AX
    @@Direct2:
      STOSW
      POP  DS
      CALL UpdateCursor
    @@Done:
      CALL PostWrite
    end;

  procedure InsColumn; assembler;
    asm
      CALL PreWrite
      MOV  BX, WindMin
      MOV  DX, WindMax
      MOV  CX, CursorXY
      CMP  DirectVideo, True
      JE   @@Direct
      MOV  AX, BX
      PUSH CX
      MOV  CH, DH
      MOV  DH, AH
      MOV  BH, ActivePage
    @@Bios0:
      CMP  CH, DH
      JL   @@Bios3
      PUSH  DX
      PUSH  CX
    @@Bios1:
      CMP  CL, DL
      JE   @@Bios2
      PUSH CX
      MOV  AH, 02h
      DEC  DX
      INT  10h
      MOV  AH, 08h
      INT  10h
      MOV  BL, AH
      MOV  CX, 01h
      MOV  AH, 02h
      INC  DX
      INT  10h
      MOV  AH, 09h
      INT  10h
      POP  CX
      DEC  DX
      JMP  @@Bios1
    @@Bios2:
      MOV  AH, 02h
      INT  10h
      MOV  AH, 09h
      MOV  CX, 01h
      MOV  BL, TextAttr
      MOV  AL, TextChar
      INT  10h
      POP  CX
      POP  DX
      INC  DH
      JMP  @@Bios0
    @@Bios3:
      POP  DX
      MOV  AH, 02h
      INT  10h
      JMP  @@Done
    @@Direct:
      MOV  CH, BH
      XOR  BX, BX
      MOV  BL, DH
      INC  BL
      SUB  BL, CH
      PUSH DS
      PUSH BX
      PUSH DX
      MOV  AX, ScreenMax
      XOR  AH, AH
      INC  AL
      MOV  BX, AX
      SHL  BX, 1
      MUL  CH
      POP  DX
      XOR  DH, DH
      ADD  AX, DX
      SHL  AX, 1
      SUB  DL, CL
      MOV  CX, DX
      MOV  DI, AX
      MOV  SI, AX
      SUB  SI, 2
      MOV  ES, VideoSeg
      MOV  AL, TextChar
      MOV  AH, TextAttr
      MOV  DS, VideoSeg
      POP  DX
    @@Direct2:
      STD
      PUSH SI
      PUSH DI
      PUSH CX
      PUSH AX
      REP  MOVSW
      POP  AX
      STOSW
      POP  CX
      POP  DI
      POP  SI
      ADD  SI, BX
      ADD  DI, BX
      DEC  DX
      JNZ  @@Direct2
      POP  DS
      CALL UpdateCursor
    @@Done:
      CALL PostWrite
    end;

  procedure DelColumn; assembler;
    asm
      CALL PreWrite
      MOV  AX, WindMin
      MOV  CX, WindMax
      MOV  DX, CursorXY
      CMP  DirectVideo, True
      JE   @@Direct
      PUSH CX
      MOV  DH, AH
      MOV  BH, ActivePage
    @@Bios0:
      CMP  CH, DH
      JL   @@Bios3
      PUSH  DX
      PUSH  CX
      MOV  BH, ActivePage
    @@Bios1:
      CMP  CL, DL
      JE   @@Bios2
      PUSH CX
      MOV  AH, 02h
      INC  DX
      INT  10h
      MOV  AH, 08h
      INT  10h
      MOV  BL, AH
      MOV  CX, 01h
      MOV  AH, 02h
      DEC  DX
      INT  10h
      MOV  AH, 09h
      INT  10h
      POP  CX
      INC  DX
      JMP  @@Bios1
    @@Bios2:
      MOV  AH, 02h
      INT  10h
      MOV  AH, 09h
      MOV  CX, 01h
      MOV  BL, TextAttr
      MOV  AL, TextChar
      INT  10h
      POP  CX
      POP  DX
      INC  DH
      JMP  @@Bios0
    @@Bios3:
      POP  DX
      MOV  AH, 02h
      INT  10h
      CALL UpdateCursor
      JMP  @@Done
    @@Direct:
      MOV  DH, AH
      XOR  BX, BX
      MOV  BL, CH
      INC  BL
      SUB  BL, DH
      PUSH DS
      PUSH BX
      PUSH DX
      MOV  AX, ScreenMax
      XOR  AH, AH
      INC  AL
      MOV  BX, AX
      SHL  BX, 1
      MUL  DH
      POP  DX
      XOR  DH, DH
      ADD  AX, DX
      SHL  AX, 1
      SUB  CL, DL
      XOR  CH, CH
      MOV  DI, AX
      MOV  SI, AX
      ADD  SI, 2
      MOV  ES, VideoSeg
      MOV  AL, TextChar
      MOV  AH, TextAttr
      MOV  DS, VideoSeg
      POP  DX
      CLD
    @@Direct2:
      PUSH SI
      PUSH DI
      PUSH CX
      CMP  CX, 0
      JE   @@Direct3
      PUSH AX
      REP  MOVSW
      POP  AX
    @@Direct3:
      STOSW
      POP  CX
      POP  DI
      POP  SI
      ADD  SI, BX
      ADD  DI, BX
      DEC  DX
      JNZ  @@Direct2
      POP  DS
      CALL UpdateCursor
    @@Done:
      CALL PostWrite
    end;

  procedure TextColor(Color: Byte); assembler;
    asm
      MOV  AL, TextAttr
      MOV  AH, Color
      AND  AL, 70h
      TEST AH, 0F0h
      JZ   @@SetColor
      OR   AL, 80h
    @@SetColor:
      AND  AH, 0Fh
      OR   AL, AH
      MOV  TextAttr, AL
    end;

  procedure TextBackground(Color: Byte); assembler;
    asm
      MOV  AL, TextAttr
      MOV  AH, Color
      AND  AL, 8Fh
      AND  AH, 07h
      MOV  CL, 04h
      SHL  AH, CL
      OR   AL, AH
      MOV  TextAttr, AL
    end;

  procedure LowVideo; assembler;
    asm
      AND  TextAttr, 11110111b
    end;

  procedure HighVideo; assembler;
    asm
      OR  TextAttr, 00001000b
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
      MOV  AX, 8301h { Cancel Event Wait }
      INT  15h
      MOV  AX, 8300h
      MOV  CS:[OFFSET @@DelayFlag], AL
      MOV  DX, MS
      MOV  CX, DX
      SHL  DX, 0Ah
      SHR  CX, 06h
      PUSH CS; POP ES { MOV  ES, CS }
      MOV  BX, OFFSET @@DelayFlag
      INT  15h
    @@Delay3:
      CALL IdleMouseProc
      MOV  AL, CS:[OFFSET @@DelayFlag]
      TEST AL, 80h
      JZ   @@Delay3
    end;
{$ELSE}
  procedure Delay( MS : Word ); assembler;
    var
      LastTick : Word;
    asm
      XOR  DX, DX
      MOV  LastTick, DX
      MOV  AX, MS
      MOV  CX, 55
      DIV  CX
      MOV  CX, AX
      MOV  DI, Seg0040
      MOV  ES, DI
      MOV  DI, 006Ch
      CMP  DX, 0
      JE   @@Delay2
      INC  CX
    @@Delay2:
      CMP  CX, 0
      JE   @@Done
    @@DelayLoop:
      PUSH CX
      PUSH DI
      PUSH ES
      CALL IdleMouseProc
      POP  ES
      POP  DI
      POP  CX
      MOV  AX, ES:[DI]
      CMP  LastTick, AX
      JE   @@DelayLoop
      MOV  LastTick, AX
      LOOP @@DelayLoop
    @@Done:
    end;
{$ENDIF}
  procedure Sound(Hz: Word); assembler;
    asm
      MOV  DX, 0012h
      MOV  AX, 34DCh
      MOV  CX, Hz
      CMP  CX, 0
      JE   @@Sound1
      DIV  CX
      JMP  @@Sound2
    @@Sound1:
      XOR  AX, AX
    @@Sound2:
      PUSH AX
      MOV  AL, 10110110b
      MOV  DX, 043h
      OUT  DX, AL
      MOV  DX, 042h
      POP  AX
      OUT  DX, AL
      MOV  AL, AH
      OUT  DX, AL
      MOV  DX, 061h
      IN   AL, DX
      AND  AL, 11111111b
      OR   AL, 00000011b
      OUT  DX, AL
    end;

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

  procedure PrintScreen; assembler;
    asm
      PUSH DS
      PUSH SP
      PUSH BP
      PUSHF
      CALL DWORD PTR OldInt05
      POP  BP
      POP  SP
      POP  DS
    end;


  procedure FWriteChar ( Letter : Char ); assembler;
    asm
      CALL PreWrite
      CMP  DirectVideo, True
      JE   @@Direct
      MOV  CX, WindMax
      MOV  DX, CursorXY
      MOV  BH, ActivePage
      MOV  BL, TextAttr
    @@Write:
      MOV  AH, 02h
      INT  10h
      PUSH CX
      MOV  CX, 0001h
      MOV  AH, 09h
      MOV  AL, Letter
      INT  10h
      POP  CX
      INC  DL
      CMP  DL, CL
      JNG  @@Write1
      MOV  CursorXY, DX
      CALL Return
      JMP  @@Done2
    @@Write1:
      MOV  CursorXY, DX
      JMP  @@Done
    @@Direct:
      MOV  DX, CursorXY
      MOV  CX, WindMax
      PUSH DX; CALL GetVideoOfs
      MOV  DI, AX
      MOV  AX, VideoSeg
      MOV  ES, AX
      MOV  AH, TextAttr
      MOV  AL, Letter
    @@Direct1:
      STOSW
      INC  DL
      CMP  DL, CL
      JNG  @@Direct2
      MOV  CursorXY, DX
      CALL Return
      JMP  @@Done2
    @@Direct2:
      MOV  CursorXY, DX
    @@Done:
    @@Done2:
      CALL UpdateCursor
      CALL PostWrite
    end;

  procedure FWrite ( Str : String ); assembler;
    asm
      LES  DI, Str
      MOV  AH, ES:[DI]
      CMP  AH, 0
      JE   @@Done2
      CALL PreWrite
      CMP  DirectVideo, True
      JE   @@Direct
      MOV  CX, WindMax
      MOV  DX, CursorXY
      MOV  BH, ActivePage
      MOV  BL, TextAttr
    @@Write:
      PUSH AX
      PUSH CX
      MOV  AH, 02h
      INT  10h
      INC  DI
      MOV  CX, 0001h
      MOV  AH, 09h
      MOV  AL, ES:[DI]
      INT  10h
      POP  CX
      POP  AX
      INC  DL
      CMP  DL, CL
      JNG  @@Write1
      PUSH AX
      PUSH CX
      PUSH BX
      PUSH ES
      PUSH DI
      MOV  CursorXY, DX
      CALL Return
      MOV  DX, AX
      POP  DI
      POP  ES
      POP  BX
      POP  CX
      POP  AX
    @@Write1:
      DEC  AH
      CMP  AH, 0
      JNE  @@Write
      MOV  CursorXY, DX
      CALL UpdateCursor
      JMP  @@Done
    @@Direct:
      MOV  BL, AH
      MOV  DX, CursorXY
      MOV  CX, WindMax
      PUSH DX; CALL GetVideoOfs
      MOV  DI, AX
      MOV  AX, VideoSeg
      MOV  ES, AX
      MOV  AH, TextAttr
      PUSH DS
      LDS  SI, Str
      INC  SI
      CLD
    @@Direct1:
      LODSB
      STOSW
      INC  DL
      CMP  DL, CL
      JNG  @@Direct2
      PUSH DS
      PUSH ES
      PUSH SI
      PUSH AX
      PUSH BX
      PUSH CX
      MOV  AX, SEG @DATA
      MOV  DS, AX
      MOV  CursorXY, DX
      CALL Return
      MOV  DX, AX
      PUSH DX; CALL GetVideoOfs
      MOV  DI, AX
      CLD
      POP  CX
      POP  BX
      POP  AX
      POP  SI
      POP  ES
      POP  DS
    @@Direct2:
      DEC  BL
      CMP  BL, 0
      JNE  @@Direct1
      POP  DS
      MOV  CursorXY, DX
    @@Done:
      CALL UpdateCursor
      CALL PostWrite
    @@Done2:
    end;

  procedure FWriteLn ( Str : String ); assembler;
    asm
      LES DI, Str
      PUSH ES
      PUSH DI
      CALL FWrite
      CALL Return
    end;

  function FReadChar : Char; assembler;
    asm
      CALL PreWrite
      CMP  DirectVideo, True
      JE   @@Direct
      MOV  CX, WindMax
      MOV  DX, CursorXY
      MOV  BH, ActivePage
      MOV  BL, TextAttr
    @@Write:
      MOV  AH, 02h
      INT  10h
      MOV  AH, 08h
      INT  10h
      PUSH AX
      INC  DL
      CMP  DL, CL
      JNG  @@Write1
      MOV  CursorXY, DX
      CALL Return
      JMP  @@Done2
    @@Write1:
      MOV  CursorXY, DX
      JMP  @@Done
    @@Direct:
      MOV  DX, CursorXY
      MOV  CX, WindMax
      PUSH DX; CALL GetVideoOfs
      MOV  DI, AX
      MOV  AX, VideoSeg
      MOV  ES, AX
    @@Direct1:
      MOV  AX, ES:[DI]
      PUSH AX
      INC  DL
      CMP  DL, CL
      JNG  @@Direct2
      MOV  CursorXY, DX
      CALL Return
      JMP  @@Done2
    @@Direct2:
      MOV  CursorXY, DX
    @@Done:
    @@Done2:
      CALL UpdateCursor
      CALL PostWrite
      POP  AX
    end;

  function FReadAttr : byte; assembler;
    asm
      CALL PreWrite
      CMP  DirectVideo, True
      JE   @@Direct
      MOV  CX, WindMax
      MOV  DX, CursorXY
      MOV  BH, ActivePage
      MOV  BL, TextAttr
    @@Write:
      MOV  AH, 02h
      INT  10h
      MOV  AH, 08h
      INT  10h
      PUSH AX
      INC  DL
      CMP  DL, CL
      JNG  @@Write1
      MOV  CursorXY, DX
      CALL Return
      JMP  @@Done2
    @@Write1:
      MOV  CursorXY, DX
      JMP  @@Done
    @@Direct:
      MOV  DX, CursorXY
      MOV  CX, WindMax
      PUSH DX; CALL GetVideoOfs
      MOV  DI, AX
      MOV  AX, VideoSeg
      MOV  ES, AX
    @@Direct1:
      MOV  AX, ES:[DI]
      PUSH AX
      INC  DL
      CMP  DL, CL
      JNG  @@Direct2
      MOV  CursorXY, DX
      CALL Return
      JMP  @@Done2
    @@Direct2:
      MOV  CursorXY, DX
    @@Done:
    @@Done2:
      CALL UpdateCursor
      CALL PostWrite
      POP  AX
      MOV  AL, AH
    end;

  function FReadCharAttr : word; assembler;
    asm
      CALL PreWrite
      CMP  DirectVideo, True
      JE   @@Direct
      MOV  CX, WindMax
      MOV  DX, CursorXY
      MOV  BH, ActivePage
      MOV  BL, TextAttr
    @@Write:
      MOV  AH, 02h
      INT  10h
      MOV  AH, 08h
      INT  10h
      PUSH AX
      INC  DL
      CMP  DL, CL
      JNG  @@Write1
      MOV  CursorXY, DX
      CALL Return
      JMP  @@Done2
    @@Write1:
      MOV  CursorXY, DX
      JMP  @@Done
    @@Direct:
      MOV  DX, CursorXY
      MOV  CX, WindMax
      PUSH DX; CALL GetVideoOfs
      MOV  DI, AX
      MOV  AX, VideoSeg
      MOV  ES, AX
    @@Direct1:
      MOV  AX, ES:[DI]
      PUSH AX
      INC  DL
      CMP  DL, CL
      JNG  @@Direct2
      MOV  CursorXY, DX
      CALL Return
      JMP  @@Done2
    @@Direct2:
      MOV  CursorXY, DX
    @@Done:
    @@Done2:
      CALL UpdateCursor
      CALL PostWrite
      POP  AX
    end;

  function WindowSize ( X1, Y1, X2, Y2 : byte ) : word;
    var
      T : Byte;
    begin
      if X2 < X1 then begin T := X1; X1 := X2; X2 := T; end;
      if Y2 < Y1 then begin T := Y1; Y1 := Y2; Y2 := T; end;
      WindowSize := Sizeof(Word) +
       (Word(X2) - Word(X1) + 1) * (Word(Y2) - Word(Y1) + 1) * 2;
    end;

  procedure GetWindow ( X1, Y1, X2, Y2 : byte; var Window );
    var
      TX, TY, X, Y : byte;
      TScroll : boolean;
      P : word;
    begin
      PreWrite;
      if X2 < X1 then begin TX := X1; X1 := X2; X2 := TX; end;
      if Y2 < Y1 then begin TY := Y1; Y1 := Y2; Y2 := TY; end;
      WindowType(Window).Width := X2 - X1;
      WindowType(Window).Height := Y2 - Y1;
      TX := WhereX;
      TY := WhereY;
      TScroll := CheckScroll;
      CheckScroll := False;
      P := 0;
      for Y := Y1 to Y2 do
        begin
          GotoXY ( X1, Y );
          for X := X1 to X2 do
            begin
              if (X <= GetMaxX) and (Y <= GetMaxY) then
                WindowType(Window).Data[P] := FReadCharAttr
              else
                WindowType(Window).Data[P] := Word(TextAttr) * $0100 + Byte(TextChar);
              Inc(P);
            end;
        end;
      GotoXY ( TX, TY );
      CheckScroll := TScroll;
      PostWrite;
    end;

  procedure PutWindow ( X1, Y1 : byte; var Window );
    var
      TScroll : boolean;
      TAttr, TX, TY, X, Y : byte;
      P : word;
    begin
      PreWrite;
      TX := WhereX;
      TY := WhereY;
      TAttr := TextAttr;
      TScroll := CheckScroll;
      CheckScroll := False;
      P := 0;
      for Y := 0 to WindowType(Window).Height  do
        if Y <= GetMaxY then
           begin
             GotoXY ( X1, Y + Y1 );
             for X := 0 to WindowType(Window).Width  do
               begin
                 if X <= GetMaxX then
                   begin
                     TextAttr := Hi(WindowType(Window).Data[P]);
                     FWriteChar (Char(Lo(WindowType(Window).Data[P])));
                   end;
                 Inc(P);
               end;
           end;
      GotoXY ( TX, TY );
      TextAttr := TAttr;
      CheckScroll := TScroll;
      PostWrite;
    end;


  procedure MoveCursor; assembler;
    asm
      CALL SetCursorLoc
    end;

{ Cusor size and shape functions }

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

  procedure NormalCursor; assembler;
    asm
      PUSH FirstCursor
      CALL SetCursor
    end;

  procedure HideCursor; assembler;
    asm
      MOV  AX, $2000
      PUSH AX
      CALL SetCursor
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

{ Blink Functions }
  function GetBlink : boolean; assembler;
    asm
      XOR  AX, AX
      MOV  ES, AX
      MOV  CL, ES:[$0465] { CRT_Mode }
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

{ Box and line functions }
  procedure DrawBox ( X1, Y1, X2, Y2, Style : byte );
    var
      CursorX, CursorY : byte;
      RangeX,  RangeY  : byte;
      I                : byte;
    begin
      RangeX := GetMaxX;
      RangeY := GetMaxY;
      if (X1 > RangeX) or (Y1 > RangeY) then Exit;
      PreWrite;
      CursorX := WhereX;
      CursorY := WhereY;
      { Draw Top }
      GotoXY( X1, Y1 );
      Write(BoxData[Style][0] );
      for I := X1 + 1 to X2 - 1 do
        if I > RangeX then Break else
          Write( BoxData[Style][4] );
      if (X2 <= RangeX) and (X1 <> X2) then
        Write( BoxData[Style][1] );
      { Draw Sides }
      for I := Y1 + 1 to Y2 - 1 do
        if I > RangeY then Break else
          begin
            GotoXY ( X1, I );
            Write(BoxData[Style][5]);
            if (X2 <= RangeX) and (X1 <> X2) then
              begin
                GotoXY ( X2, I );
                Write(BoxData[Style][5]);
              end;
          end;
      { Draw Bottom }
      if (Y2 <= RangeY) and (Y2 <> Y1) then
        begin
          GotoXY( X1, Y2 );
          Write(BoxData[Style][2] );
          for I := X1 + 1 to X2 - 1 do
            if I > RangeX then Break else
              Write( BoxData[Style][4] );
          if (X2 <= RangeX) and (X1 <> X2) then
            Write( BoxData[Style][3] );
        end;
      GotoXY ( CursorX, CursorY );
      PostWrite;
    end;

  procedure DrawShadow ( X1, Y1, X2, Y2, Style : byte );
    var
      CursorX, CursorY : byte;
      RangeX,  RangeY  : byte;
      C                : Char;
      Attr             : byte;
      I                : byte;
    begin
      RangeX := GetMaxX;
      RangeY := GetMaxY;
      Inc(X1,1);
      Inc(Y1,1);
      Inc(X2,1);
      Inc(Y2,1);
      if Style and bsDoubleWide = bsDoubleWide then
        Inc(X1, 1);
      if (X1 > RangeX) or (Y1 > RangeY) then Exit;
      PreWrite;
      CursorX  := WhereX;
      CursorY  := WhereY;
      Attr     := TextAttr;
      TextAttr := $08;
      { Draw Sides }
      if (X2 <= RangeX) and (X1 <> X2) then
        for I := Y1 to Y2 do
          if I > RangeY then Break else
            begin
              GotoXY ( X2, I );
              C := FReadChar;
              GotoXY ( X2, I );
              FWrite( C );
              if (X2 + 1 <= RangeX) and (Style and bsDoubleWide = bsDoubleWide) then
                begin
                  C := FReadChar;
                  GotoXY ( X2 + 1, I );
                  FWrite( C );
                end;
            end;
      { Draw Bottom }
      if (Y2 <= RangeY) and (Y2 <> Y1) then
        for I := X1 to X2 - 1 do
          if I > RangeX then Break else
            begin
              GotoXY ( I, Y2 );
              C := FReadChar;
              GotoXY ( I, Y2 );
              FWrite( C );
            end;
      TextAttr := Attr;
      GotoXY ( CursorX, CursorY );
      PostWrite;
    end;

  procedure DrawLine ( X1, Y1, Len, Style : byte );
    var
      CursorX, CursorY : byte;
      RangeX,  RangeY  : byte;
      I,       TPos    : byte;
    begin
      CursorX := WhereX;
      CursorY := WhereY;
      RangeX  := GetMaxX;
      RangeY  := GetMaxY;
      GotoXY ( X1, Y1 );
      TPos := Pos(Chr(Lo(FReadCharAttr)), LineData.Current);
      GotoXY ( WhereX - 1, WhereY );
      if (TPos = 0) or (Style and lnNoEnds = lnNoEnds) then
        TPos := 41;
      FWriteChar ( LineData.Style[Style and lnDouble, Style and lnVertical = lnVertical, Top][TPos]);
      Case Style and lnVertical = lnVertical of
        False : begin
          for I := X1 + 1 to X1 + Len - 2 do
            if I > RangeX then Break else
              begin
                if (Style and lnNoCenter = lnNoCenter) then
                  TPos := 41
                else
                  begin
                    TPos := Pos(Chr(Lo(FReadCharAttr)), LineData.Current);
                    GotoXY ( WhereX - 1, WhereY );
                    if TPos = 0 then TPos := 41;
                  end;
                FWriteChar ( LineData.Style[Style and lnDouble, False, Middle][TPos]);
              end;
          if X1 + Len - 1 <= RangeX then
            begin
              TPos := Pos(Chr(Lo(FReadCharAttr)), LineData.Current);
              GotoXY ( WhereX - 1, WhereY );
              if (TPos = 0) or (Style and lnNoEnds = lnNoEnds) then
                TPos := 41;
              FWriteChar ( LineData.Style[Style and lnDouble, False, Bottom][TPos]);
            end;
        end;
        True : begin
          for I := Y1 + 1 to Y1 + Len - 2 do
            if I > RangeY then Break else
              begin
                GotoXY ( X1, I );
                if (Style and lnNoCenter = lnNoCenter) then
                  TPos := 41
                else
                  begin
                    TPos := Pos(Chr(Lo(FReadCharAttr)), LineData.Current);
                    GotoXY(X1, I);
                    if TPos = 0 then TPos := 41;
                  end;
                FWriteChar ( LineData.Style[Style and lnDouble, True, Middle][TPos]);
              end;
          if Y1 + Len - 1 <= RangeY then
            begin
              GotoXY ( X1, Y1 + Len - 1 );
              TPos := Pos(Chr(Lo(FReadCharAttr)), LineData.Current);
              GotoXY ( X1, Y1 + Len - 1 );
              if (TPos = 0) or (Style and lnNoEnds = lnNoEnds) then
                TPos := 41;
              FWriteChar ( LineData.Style[Style and lnDouble, True, Bottom][TPos]);
            end;
        end;
      end;
      GotoXY ( CursorX, CursorY );
    end;

{ Event Functions }
  procedure PurgeEvents;
    begin
      CommandBuf.Purge;
      KeyBuf.Purge;
    end;

  procedure ClearEvent(var Event : TEvent);
    begin
      Event.What := evNothing;
      Event.Command := cmClearedEvent;
    end;

  procedure GetEvent(var Event : TEvent);
    begin
      ClearEvent(Event);
      if BreakCount <> 0 then
        begin
          Event.What     := evSystem;
          Event.Command  := cmBreak;
          Event.InfoWord := BreakCount;
          BreakCount := 0;
        end
      else
      if SysReqMake <> 0 then
        begin
          Event.What    := evSystem;
          Event.Command := cmMakeSysReq;
          Event.InfoWord := 1;
          Dec(SysReqMake);
        end
      else
      if SysReqBreak <> 0 then
        begin
          Event.What    := evSystem;
          Event.Command := cmBreakSysReq;
          Event.InfoWord := 1;
          Dec(SysReqBreak);
        end
      else
      if PrintCount <> 0 then
        begin
          Event.What    := evSystem;
          Event.Command := cmPrintScreen;
          Event.InfoWord := PrintCount;
          PrintCount := 0;
        end
      else
      if Not CommandBuf.GetEvent(Event) then
      if Not KeyBuf.GetEvent(Event)     then
        IdleMouseProc;
    end;

  function PutEvent(var Event : TEvent) : boolean;
    begin
      PutEvent := CommandBuf.PutEvent(Event);
    end;
{ Direct Video Memory procedures }

  function GetVideoSize : word;
    begin
      GetVideoSize := BIOSptr^.RegenSize;
    end;

  function  GetVideoPtr : Pointer;
    begin
      GetVideoPtr := Ptr(VideoSeg, ActiveOfs);
    end;

  procedure SetVideoPtr ( P : Pointer );
    begin
      VideoSeg := Seg(P^);
      ActiveOfs := Ofs(P^);
    end;

  procedure CopyToVideo;
    var
      TP : Pointer;
    begin
      if DirectVideo then
        begin
          TP := Ptr(VideoSeg, ActiveOfs);
          Move ( TP^, VideoPtr^, BIOSPtr^.RegenSize);
        end;
    end;

  procedure CopyFromVideo;
    var
      TP : Pointer;
    begin
      if DirectVideo then
        begin
          TP := Ptr(VideoSeg, ActiveOfs);
          Move ( VideoPtr^, TP^, BIOSPtr^.RegenSize);
        end;
    end;

{ EditLn Function }
  function RTrim ( Str : String ) : String;
    begin
      While (Str[Length(Str)] = #32) and (Str <> '') do Str[0] := Chr(Length(Str) - 1);
      RTrim := Str;
    end;

  function Space ( N : byte ) : String;
    Var
      T : String;
    begin
      FillChar ( T[1], N, 32);
      T[0] := Chr(N);
      Space := T;
    end;

  function RSpace ( Str : String; N : Byte ) : String;
    begin
      if Length(Str) < N then
        RSpace := Str + Space( N - Length(Str) )
      else
        RSpace := Str;
    end;

  procedure AddChr ( var S : String; C : Char );
    begin
      Inc(Byte(S[0]));
      S[Byte(S[0])] := C;
    end;

  function EditLn ( var Dest : String; First : boolean; MaxLen, MaxWide : Byte; var Event : TEvent) : boolean;
    const
      Source : String = '';
      OfsX   : byte = 0;
      CurX   : byte = 255;
    var
      OrgX,  OrgY : Byte;
      Cursor      : word;
      DoneFlag    : Boolean;

    procedure EditCursor;
      begin
        case InsertMode of
          True  : SmallCursor;
          False : HalfCursor;
        end;
      end;

    procedure DisplayStr;
      var
        TAttr : byte;
      begin
        TAttr := TextAttr;
        GotoXY ( OrgX, OrgY );
        if OfsX > 0 then
          FWriteChar(#17)
        else
          FWriteChar(#32);
        FWrite(RSpace(Copy(Dest, OfsX + 1, MaxWide - 2), MaxWide - 2));
        if OfsX + MaxWide - 2 < Length((Dest)) then
          FWriteChar(#16)
        else
          FWriteChar(#32);
        TextAttr := TAttr;
        GotoXY(OrgX + CurX, OrgY);
        MoveCursor;
      end;

    function Left(Display : boolean) : boolean;
      begin
        if CurX + OfsX > 1 then
          begin
            Dec(CurX);
            if CurX < 1 then
            begin
              CurX := 1;
              Dec(OfsX);
            end;
          end;
        if Display then DisplayStr;
        Left := CurX + OfsX > 1;
      end;

    function Right(Display : boolean) : boolean;
      begin
        if CurX + OfsX <= Length(Dest) then
          begin
            Inc(CurX);
            if CurX > MaxWide - 2 then
              begin
                Dec(CurX);
                Inc(OfsX);
              end;
          end;
        if Display then DisplayStr;
        Right := CurX + OfsX <= Length(Dest);
      end;

    procedure Home;
      begin
        OfsX := 0;
        CurX := 1;
        DisplayStr;
      end;

    procedure EndLine;
      begin
        while (CurX + OfsX > Length(Dest)) and (CurX + OfsX > 1) do
          begin
            Dec(CurX);
            if CurX < 1 then
            begin
              CurX := 1;
              Dec(OfsX);
            end;
          end;
        while Right(False) do;
        DisplayStr;
      end;

    procedure LeftWord;
      begin
        if Dest = '' then
          Home
        else
          begin
            Left(False);
            While (CurX + OfsX > Length(Dest)) and Left(False) do;
            if Dest[CurX + OfsX] = #32 then
              while (Dest[CurX + OfsX] = #32) and Left(False) do;
            while (Dest[CurX + OfsX] <> #32) and Left(False) do;
            if CurX + OfsX > 1 then Right(False);
          end;
        DisplayStr;
      end;

    procedure RightWord;
      begin
        if Dest = '' then
          Home
        else
          begin
            if CurX + OfsX < MaxLen then
              begin
                if Dest[CurX + OfsX] = #32 then
                  while (Dest[CurX + OfsX] = #32) and Right(False) do
                else
                  while (Dest[CurX + OfsX] <> #32) and Right(False) do;
                if Dest[CurX + OfsX] = #32 then
                  while (Dest[CurX + OfsX] = #32) and Right(False) do;
              end;
          end;
        DisplayStr;
      end;

    procedure VerifyPosition;
      begin
        if (Dest = '')  or (OfsX + CurX - 1 > Length(Dest)) then
          begin
            CurX := 1;
            OfsX := 0;
            EndLine;
          end;
        DisplayStr;
      end;

    procedure HandleKeyboard;
      begin
        Case Event.KeyCode of
          $0009, { TAB }
          $0F00, { Shift-TAB }
          $001A, { CTRL-Z }
          $0003, { CTRL-C }
          $007F, { CTRL-BACKSPACE }
          $000A  { CTRL-ENTER } : DoneFlag := True;
          $0008 : if OfsX + CurX > 1 then begin
            Delete(Dest, OfsX + CurX - 1, 1);
            Left(True);
          end;
          $000D : begin { Enter }
            Home;
            DoneFlag := True;
          end;
          $001B : begin { Escape }
            Dest := Source;
            Home;
            DoneFlag := True;
          end;
          $4B00, $7300 : begin
            if Event.ShiftCode and EitherCtrl = EitherCtrl then
              LeftWord
            else
              Left(True);
          end;
          $4D00, $7400 : begin
            if Event.ShiftCode and EitherCtrl = EitherCtrl then
              RightWord
            else
              Right(True);
          end;
          $5200 : begin
            InsertMode := Not InsertMode;
            DisplayStr;
          end;
          $5300 : if OfsX + CurX <= MaxLen then begin
            Delete(Dest, OfsX + CurX, 1);
            DisplayStr;
          end;
          $4700 : Home;
          $4F00 : EndLine;
          $0000..$00FF : case InsertMode of
            True : if (Length(RTrim(Dest)) < MaxLen) and (CurX + OfsX <= MaxLen) then begin
              while Length(Dest) < CurX + OfsX - 1 do AddChr(Dest, #32);
              Insert(Event.CharCode, Dest, CurX + OfsX);
              Right(True);
            end;
            False : if (Length(RTrim(Dest)) <= MaxLen) and (CurX + OfsX <= MaxLen) then begin
              while Length(Dest) < CurX + OfsX do AddChr(Dest, #32);
              Dest[CurX + OfsX] := Event.CharCode;
              Right(True);
            end;
          end;
        else
          DoneFlag := True;
        end;
      end;

    begin
      Cursor := GetCursor;
      OrgX := WhereX;
      OrgY := WhereY;
      if First then
        begin
          OfsX   := 0;
          CurX   := 1;
          Source := Dest;
          EndLine;
        end
      else
        VerifyPosition;
      repeat
        DoneFlag := False;
        EditCursor;
        repeat
          GetEvent(Event);
        until Event.What <> evNothing;
        HideCursor;
        if Event.What and evSystem <> evNothing then DoneFlag := True else
        if Event.What and evKeyDown = evKeyDown then HandleKeyboard;
      until DoneFlag;
      SetCursor(Cursor);
      GotoXY(OrgX, OrgY);
      EditLn := (Event.What = evKeyDown) and (Event.KeyCode = $000D);
    end;

  function ReadLn(var BufPtr : PTextBuf; Size : word) : word;
    var
      Cursor  : Word;
      ESize   : word;
      TempStr : String;
      Event   : TEvent;
      Wide    : byte;
      X, Y    : Byte;
      I       : word;
    begin
      ReadLn := 0;
      if Size < 2 then Exit;
      ESize := Size - 2;
      if ESize > Sizeof(TempStr) then
        ESize := Sizeof(TempStr) - 1;
      X := WhereX;
      Y := WhereY;
      Cursor  := GetCursor;
      HideCursor;
      TempStr := '';
      if CheckScroll then
        Wide := GetMaxX - X
      else
        Wide := GetMaxX - X + 1;
      if Not EditLn(TempStr, True, ESize, Wide, Event) then
        repeat
          GotoXY ( X, Y );
        until EditLn(TempStr, False, ESize, Wide, Event);
      SetCursor ( Cursor );
      FWriteLn('');
      if Length(TempStr) > ESize then
        TempStr[1] := Chr(ESize);
      AddChr(TempStr, #13);
      AddChr(TempStr, #10);
      Move(TempStr[1], BufPtr^[0], Length(TempStr));
      ReadLn := Length(TempStr);
    end;

{ Redirection of System's Read, ReadLn, Write, and WriteLn procedures }
  function InOutCRT( var F ) : integer;
    var
      I     : word;
      Event : TEvent;
      Chars : Boolean;
    begin
      with TTextRec(F) do
        case Mode of
          {fmInput}  $D7B1 : begin
             BufEnd := ReadLn(BufPtr, BufSize);
             BufPos := 0;
          end;
          {fmOutput} $D7B2 : begin
            I := BufEnd;
            while I < BufPos do
              begin
                if CheckChar = False then
                  FWrite ( BufPtr^[I] )
                else
                  case Byte(BufPtr^[I]) of
                    10 : LineFeed;
                    13 : GotoXY ( 1, WhereY );
                     8 : GotoXY ( WhereX - 1, WhereY );
                  else
                    FWrite ( BufPtr^[I] )
                  end;
                Inc ( I );
                if I >= BufSize then I := 0;
              end;
            BufPos := 0;
          end; { * }
        end;
      InOutCrt := 0;
    end;

  function FlushCRT( var F ) : integer;
    begin
      with TTextRec(F) do
        case Mode of
          fmOutput : InOutCrt ( F );
          fmInput : begin
            BufEnd := 0;
            BufPos := 0;
          end;
        end;
      FlushCrt := 0;
    end;

  function CloseCRT( var F ) : integer;
    begin
      TTextRec(F).Mode := fmClosed;
      CloseCrt := 0;
    end;

  function OpenCRT( var F ) : integer;
    begin
      with TTextRec(F) do
        begin
          if Mode = fmInOut then
            Mode := fmOutPut;
        end;
      OpenCrt := 0;
    end;

  procedure AssignCrt(var F: Text);
    const
      CRTName : Array[0..4] of char = 'CRT'#0;
    begin
      with TTextRec(F) do
        begin
          Handle    := $FFFF;
          Mode      := fmClosed;
          BufSize   := Sizeof(Buffer);
          BufPtr    := @Buffer;
          OpenFunc  := OpenCrt;
          InOutFunc := InOutCrt;
          FlushFunc := FlushCrt;
          CloseFunc := CloseCrt;
          Move(CrtName, Name, Sizeof(Name));
        end;
    end;

begin
  InitQCRTUnit;
end.
