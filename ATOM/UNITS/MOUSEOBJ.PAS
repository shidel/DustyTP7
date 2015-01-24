{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

unit MouseObj;

{$O+,F+}
interface

  uses Dos;

  const
    {Const Button bit flags for GetPosition, GetPress, GetRelease }
    LeftButton      = $01;
    RightButton     = $02;
    CenterButton    = $04;

    {Const Button Flags for SetEventHandler, SwapEventHandler,
                            GetAlternateEventHandler}
    MouseMovement       = $0001;
    LeftButtonPress     = $0002;
    LeftButtonRelease   = $0004;
    RightButtonPress    = $0008;
    RightButtonRelease  = $0010;
    CenterButtonPress   = $0020;
    CenterButtonRelease = $0040;

    {Const Button Flags for SetAlternateEventHandler
    (first 5-same as GetAlternateEventHandler) }
    ShiftDuringPressOrRelease = $0020;
    CtrlDuringPressOrRelease  = $0040;
    AltDuringPressOrRelease   = $0080;


    {Const for Return by GetInfo's MType}
    BusMouse        = 1;
    SerialMouse     = 2;
    InPortMouse     = 3;
    PS2Mouse        = 4;
    HPMouse         = 5;

    {Const for Set & Get Language }
    EnglishMouse    = 0;
    FrenchMouse     = 1;
    DutchMouse      = 2;
    GermanMouse     = 3;
    SwedishMouse    = 4;
    FinnishMouse    = 5;
    SpanishMouse    = 6;
    PortugueseMouse = 7;
    ItalianMouse    = 8;

  type
    GraphicCursor = record
      ScreenMask,
      CursorMask : array[0..15] of word;
      HotX, HotY : word;
    end;
    TextCursor = record
      Hardware : boolean;
      Cursor   : Array[0..1] of word;
    end;
    PMouse = ^OMouse;
    OMouse = object
        Regs : Registers;
        xSHR,
        ySHR : byte;
      constructor Init;
      destructor Done; virtual;
      function Initialize : boolean; virtual; { True if successful; Called by Constructor }
      function Exist : boolean; virtual;
      function SetExist ( On : boolean ): boolean; virtual;
      function GetButtonCount : Word; virtual;
      function Show ( On : boolean ) : boolean; virtual; { True if visible }
      function GetPosition ( var X, Y, B : integer ) : boolean; virtual;
      function SetPosition ( X, Y : integer ) : boolean; virtual;
      function GetPress ( B : integer; var X, Y, C : integer ) : boolean; virtual; { True if Count > 0 }
      function GetRelease ( B : integer; var X, Y, C : integer ) : boolean; virtual; { True if Count > 0 }
      function SetLimits ( X1, Y1, X2, Y2  : integer ) : boolean; virtual;
      function SetGraphCursor ( C : GraphicCursor ) : boolean; virtual;
      function SetTextCursor ( C : TextCursor ) : boolean; virtual;
      function ReadMove ( var X, Y : integer ) : boolean; virtual;
      function SetEventHandler ( P : Pointer; EventMask : word ) : boolean; virtual;
      function SetLightPenEmu ( On : boolean ) : boolean; virtual;
      function SetRatio ( X, Y : integer ) : boolean; virtual;
      function SetExclusionArea ( X1, Y1, X2, Y2 : integer ) : boolean; virtual;
      function SetThreshold ( T : integer ) : boolean; virtual;
      function SwapEventHandler ( var P : Pointer; var EventMask : word ) : boolean; virtual;
      function GetStateSize : word; virtual;
      function SaveState ( P : Pointer ) : boolean; virtual;
      function RestoreState ( P : Pointer ) : boolean; virtual;
      function SetAlternateEventHandler ( P : Pointer; EventMask : word ) : boolean; virtual; { True is successful }
      function GetAlternateEventHandler ( var P : Pointer; EventMask : word ) : boolean; virtual; { True if successful }
      function SetSensitivity ( X, Y, T : integer ) : boolean; virtual;
      function GetSensitivity ( var X, Y, T : integer ) : boolean; virtual;
      function SetPage ( Page : word ) : boolean; virtual;
      function GetPage : word; virtual;
      function Disable ( var Orig : Pointer ) : boolean; virtual; { True if successful }
      function Enable : boolean; virtual;
      function Reset : boolean; virtual;  { True if Successful; Resets Mouse Button Count }
      function GetInfo ( var Version : word; var MType, IRQ : Byte ) : boolean; virtual;
      {Special Mouse Drivers}
      function SetInterruptRate ( Rate : word ) : boolean; virtual; { MicroSoft Inport Bus }
      function SetLanguage ( Language : word ) : boolean; virtual;
      function GetLanguage : word; virtual;
      function MouseActivity : boolean; { Use to test for mouse activity }
      procedure SetActivity ( X, Y, B : integer );   { Internally mouse activity monitor }
      procedure SetShiftRatio ( X, Y : byte );       { Sets return value ration, ie Xpos SHR X, Ypos SHR Y }
      { Mouse Cursor Emulation Functions; DO NOT use in graphics modes }
      procedure SetCursorEMU ( On : boolean ); { Turns on mouse Cursor position imulation }
      procedure SetSwap    ( var Data );
      procedure RefreshEMU ( NewX, NewY : integer );
    private
      CursorEMU    : boolean;
      EMUSwap      : String;
      EMUData      : word;
      EMUX, EMUY,
      LastX, LastY,
      LastButton   : integer;
      Activity     : boolean;
      Visible      : integer;
      Available    : boolean;
      ButtonCount  : word;
    end;

implementation

  var
    VideoSeg    : word;
    ScreenWide  : word;
    VideoOfs    : ^Word;
    CurrentMode : ^Byte;
{----------------------------------------------------------------------------}
  constructor OMouse.Init;
    begin
      Initialize;
    end;

  destructor OMouse.Done;
    begin
      Show(False);
    end;

  function OMouse.Initialize : boolean;
    begin
      with Regs do
        begin
          AX := 0;
          Intr($33, Regs);
          Available   := AX = $FFFF;
          ButtonCount := BX;
        end;
      CursorEMU  := False;
      Visible    := -1;
      Initialize := Available;
      Activity   := False;
      LastX      := -1;
      LastY      := -1;
      LastButton := -1;
      EMUX       := -1;
      EMUY       := -1;
      xSHR := 0;
      ySHR := 0;
      VideoOfs    := Ptr( Seg0040, $004E );
      CurrentMode := Ptr( Seg0040, $0049 );
    end;

  procedure OMouse.RefreshEMU ( NewX, NewY : integer );
    var
      O : word;
    begin
      if (EMUX <> LastX) or (EMUY <> LastY) then
        begin
          if EMUX <> -1 then
            MEMW[VideoSeg:VideoOfs^ + ScreenWide * EMUY + EMUX SHL 1] := EMUData;
          EMUX := NewX;
          EMUY := NewY;
          O := VideoOfs^ + ScreenWide * EMUY + EMUX SHL 1;
          EMUData := MEMW[VideoSeg:O];
          MEM[VideoSeg:O + 1] := Byte(EMUSwap[Hi(EmuData)]);
        end;
    end;

  procedure OMouse.SetSwap ( var Data );
    begin
      Move ( Data, EMUSwap, Sizeof(EMUSwap) );
    end;

  function OMouse.Exist : boolean;
    begin
      Exist := Available;
    end;

  function OMouse.SetExist ( On : Boolean ) : boolean;
    begin
      SetExist := Available;
      Available := On;
    end;

  function OMouse.GetButtonCount : word;
    begin
      if Available then
        GetButtonCount := ButtonCount
      else
        GetButtonCount := 0;
    end;

  function OMouse.Show ( On : boolean ) : boolean;
    begin
      if Available then
        Case CursorEMU of
          False : begin
            with Regs do
              begin
                Case On of
                  True : begin
                    Inc(Visible);
                    if Visible > 0 then Visible := 0;
                    AX := $01;
                  end;
                  False : begin
                    Dec(Visible);
                    AX := $02;
                  end;
                end;
                Intr( $33, Regs );
              end;
          end;
          True : Case On of
            True : begin
              if CurrentMode^ = 7 then VideoSeg := SegB000 else VideoSeg := SegB800;
              ScreenWide := MemW[Seg0040:$004A] Shl 1;
              Inc(Visible);
              RefreshEMU ( LastX, LastY );
              if Visible > 0 then Visible := 0;
            end;
            False : begin
              if Visible = 0 then
                begin
                  if EMUX <> -1 then
                    MEMW[VideoSeg:VideoOfs^ + ScreenWide * EMUY + EMUX SHL 1] := EMUData;
                  EMUX := -1;
                  EMUY := -1;
                end;
              Dec(Visible);
            end;
          end;
        end;
      Show := Visible = 0;
    end;

  function OMouse.GetPosition ( var X, Y, B : integer ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := 3;
            Intr($33, Regs);
            X := CX SHR xSHR;
            Y := DX SHR ySHR;
            B := BX;
          end;
      SetActivity ( X, Y, B );
      GetPosition := Available;
    end;

  function OMouse.SetPosition ( X, Y : integer ) : boolean;
    begin
      LastX := X SHL xSHR;
      LastY := Y SHL ySHR;
      Show(False);
      if Available then
        with Regs do
          begin
            AX := 4;
            CX := LastX;
            DX := LastY;
            Intr($33, Regs);
          end;
      Show(True);
      SetPosition := Available;
    end;

  function OMouse.GetPress ( B : integer; var X, Y, C : integer ) : boolean;
    begin
      if Available then
       with Regs do
         begin
           AX := $05;
           BX := B;
           Intr ( $33, Regs );
           if AX and B = B then C := BX else C := 0;
           X := CX SHR xSHR;
           Y := DX SHR ySHR;
         end;
      SetActivity ( X, Y, C );
      GetPress := Available and (C > 0);
    end;

  function OMouse.GetRelease ( B : integer; var X, Y, C : integer ) : boolean;
    begin
      if Available then
       with Regs do
         begin
           AX := $06;
           BX := B;
           Intr ( $33, Regs );
           if AX and B = B then C := BX else C := 0;
           X := CX SHR xSHR;
           Y := DX SHR ySHR;
         end;
      SetActivity ( X, Y, C );
      GetRelease := Available and (C > 0);
    end;

  function OMouse.SetLimits ( X1, Y1, X2, Y2  : integer ) : boolean;
    begin
      Show( False );
      if Available then
        with Regs do
          begin
            AX := $07;
            CX := X1 SHL xSHR;
            DX := X2 SHL xSHR;
            Intr( $33, Regs );
            AX := $08;
            CX := Y1 SHL ySHR;
            DX := Y2 SHL ySHR;
            Intr( $33, Regs );
          end;
      Show( True );
      SetLimits := Available;
    end;

  function OMouse.SetGraphCursor ( C : GraphicCursor ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $09;
            BX := C.HotX;
            CX := C.HotY;
            ES := Seg(C.ScreenMask);
            DX := Ofs(C.ScreenMask);
            Intr ( $33, Regs );
          end;
      SetGraphCursor := Available;
    end;

  function OMouse.SetTextCursor ( C : TextCursor ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $0A;
            if C.Hardware then BX := $01 else BX := $00;
            CX := C.Cursor[0];
            DX := C.Cursor[1];
            Intr ( $33, Regs );
          end;
      SetTextCursor := Available;
    end;

  function OMouse.ReadMove ( var X, Y : integer ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $0B;
            Intr ( $33, Regs );
            X := CX;
            Y := DX;
          end;
      SetActivity ( X, Y, 0 );
      ReadMove := Available;
    end;

  function OMouse.SetEventHandler ( P : Pointer; EventMask : word ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $0C;
            CX := EventMask;
            ES := Seg(P^);
            DX := Ofs(P^);
            Intr( $33, Regs );
          end;
      SetEventHandler := Available;
    end;

  function OMouse.SetLightPenEmu ( On : boolean ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            if On then AX := $0D else AX := $0E;
            Intr ( $33, Regs );
          end;
      SetLightPenEmu := Available;
    end;

  function OMouse.SetRatio ( X, Y : integer ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $0F;
            CX := X;
            DX := Y;
            Intr( $33, Regs );
          end;
      SetRatio := Available;
    end;

  function OMouse.SetExclusionArea ( X1, Y1, X2, Y2 : integer ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $10;
            CX := X1 SHL xSHR;
            DX := Y1 SHL ySHR;
            SI := X2 SHL xSHR;
            DI := Y2 SHL ySHR;
            Intr( $33, Regs );
          end;
      SetExclusionArea := Available;
    end;

  function OMouse.SetThreshold ( T : integer ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $13;
            DX := T;
            Intr ( $33, Regs );
          end;
      SetThreshold := Available;
    end;

  function OMouse.SwapEventHandler ( var P : Pointer; var EventMask : word ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $14;
            CX := EventMask;
            ES := Seg( P^ );
            DX := Ofs( P^ );
            Intr( $33, Regs );
            EventMask := CX;
            P := Ptr ( ES, DX );
          end;
      SwapEventHandler := Available;
    end;

  function OMouse.GetStateSize : word;
    begin
      if Available then
        with Regs do
          begin
            AX := $15;
            Intr ( $33, Regs );
            GetStateSize := BX;
          end
        else
          GetStateSize := 0;
    end;

  function OMouse.SaveState ( P : Pointer ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $16;
            ES := Seg(P^);
            DX := Ofs(P^);
            Intr ( $33, Regs );
          end;
      SaveState := Available;
    end;

  function OMouse.RestoreState ( P : Pointer ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $17;
            ES := Seg(P^);
            DX := Ofs(P^);
            Intr ( $33, Regs );
          end;
      RestoreState := Available;
    end;

  function OMouse.SetAlternateEventHandler ( P : Pointer; EventMask : word ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $18;
            CX := EventMask;
            ES := Seg(P^);
            DX := Ofs(P^);
            Intr ( $33, Regs );
            SetAlternateEventHandler := AX = $18;
          end
        else
          SetAlternateEventHandler := False;
    end;

  function OMouse.GetAlternateEventHandler ( var P : Pointer; EventMask : word ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $19;
            CX := EventMask;
            Intr ( $33, Regs );
            if CX = EventMask then P := Ptr( ES, DX ) else P := nil;
            GetAlternateEventHandler := CX = EventMask;
          end
        else
          GetAlternateEventHandler := False;
    end;

  function OMouse.SetSensitivity ( X, Y, T : integer ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $1A;
            BX := X;
            CX := Y;
            DX := T;
            Intr ( $33, Regs );
          end;
      SetSensitivity := Available;
    end;

  function OMouse.GetSensitivity ( var X, Y, T : integer ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $1B;
            Intr ( $33, Regs );
            X := BX;
            Y := CX;
            T := DX;
          end;
      GetSensitivity := Available;
    end;

  function OMouse.SetPage ( Page : word ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $1D;
            BX := Page;
            Intr ( $33, Regs );
          end;
      SetPage := Available;
    end;

  function OMouse.GetPage : word;
    begin
      if Available then
        with Regs do
          begin
            AX := $1E;
            Intr ( $33, Regs );
            GetPage := BX;
          end
        else
          GetPage := 0;
    end;

  function OMouse.Disable ( var Orig : Pointer ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $1F;
            Intr ( $33, Regs );
            if AX = $001F then Orig := Ptr ( ES, BX ) else Orig := nil;
            Disable := AX = $001F;
          end
        else
          Disable := False;
    end;

  function OMouse.Enable : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $20;
            Intr ( $33, Regs );
          end;
      Enable := Available;
    end;

  function OMouse.Reset : boolean;
    begin
      with Regs do
        begin
          AX := $21;
          Intr ( $33, Regs );
          Available := AX = $21;
          ButtonCount := BX;
        end;
      Reset := Available;
    end;

  function OMouse.GetInfo ( var Version : word; var MType, IRQ : Byte ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $24;
            Intr( $33, Regs );
            Version := BX;
            MType   := CH;
            IRQ     := CL;
          end;
      GetInfo := Available;
    end;

{----------------------------------------------------------------------------}
{ Special Mice }
  function OMouse.SetInterruptRate ( Rate : word ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $1C;
            BX := Rate;
            Intr ( $33, Regs );
          end;
      SetInterruptRate := Available;
    end;

  function OMouse.SetLanguage ( Language : word ) : boolean;
    begin
      if Available then
        with Regs do
          begin
            AX := $22;
            BX := Language;
            Intr ( $33, Regs );
          end;
      SetLanguage := Available;
    end;

  function OMouse.GetLanguage : word;
    begin
      if Available then
        with Regs do
          begin
            AX := $23;
            Intr ( $33, Regs );
            GetLanguage := BX;
          end
        else
          GetLanguage := 0;
    end;

  function OMouse.MouseActivity : boolean;
    begin
      MouseActivity := Activity and Available;
      Activity      := False;
    end;

  procedure OMouse.SetActivity ( X, Y, B : integer );
    begin
      if Available and CursorEMU and (Visible = 0) then RefreshEMU ( X, Y );
      Activity   := (X <> LastX) or (Y <> LastY) or (B <> LastButton);
      LastX      := X;
      LastY      := Y;
      LastButton := B;
    end;

  procedure OMouse.SetShiftRatio ( X, Y : byte );
    begin
      xSHR := X;
      ySHR := Y;
    end;

  procedure OMouse.SetCursorEMU ( On : boolean );
    begin
      Show ( False );
      CursorEMU := On;
      Show ( True );
      if Not On then EMUX := -1;
    end;
{----------------------------------------------------------------------------}
end.
