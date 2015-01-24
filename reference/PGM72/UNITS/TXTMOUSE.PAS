{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

unit TxtMouse;

{$F+}

interface

type
   Position = record
                 BtnStat, opCount, xPos, yPos : word;
              end;
   EventRec = record
                 Event, BtnStatus, XPos, YPos : word;
              end;
   GCursor  = record
                 ScreenMask,
                 CursorMask : array [0..15] of word;
                 hotX, hotY : integer;
              end;
      Str10      = String[10];
      TButtonPtr = ^TButtonRec;
      TButtonRec = record
                      X, Y, C : word;
                      Txt     : String[40];
                      Key     : String[10];
                      Next    : TButtonPtr;
                   end;
   var
      mEvent : EventRec;

   const
      ButtonL  = 0;
      ButtonR  = 1;
      ButtonM  = 2;
      Software = 0;
      Hardware = 1;
      OFF      = False;
      On       = True;

   type
      GenMouse = object
         x, y : integer;
         Visible : boolean;
         function  TestMouse   : boolean;
         procedure SetAccel    ( threshold : integer);
         procedure Show        ( Option : boolean );
         procedure InstallTask ( Mask : word );
         procedure ClearEvent  ;
         procedure GetPosition (var BtnStatus, XPos, YPos : integer);
         procedure QueryBtnDn  ( button : integer; var mouse : Position);
         procedure QueryBtnUp  ( button : integer; var mouse : Position);
         procedure ReadMove    (var XMove, YMove : integer);
         procedure Reset       (var Status : boolean; var BtnCount : integer);
         procedure SetRatio    ( horPix, verPix : integer);
         procedure SetLimits   ( XMin, YMin, XMax, YMax : integer);
         procedure SetPosition ( XPos, YPos : integer);
      end;

      TextMouse = object ( GenMouse )
         procedure Initialize;
         procedure SetCursor ( ctype, C1, C2 : word);
      end;
      TMouse = object ( TextMouse )
                  TBut                   : TButtonPtr;
                  LastDate, LastTime     : String;
                  ClockX, ClockY, ClockColor,
                  LastX, LastY, LastChr  : word;
                  LastBut                : TButtonPtr;
                  ClockOn, Use80         : boolean;
                  function  EnoughMemory : Boolean;
                  procedure UseClock     ( On : boolean );
                  function  IsClockOn    : boolean;
                  procedure ResetClock;
                  procedure SetClockPos  ( XPos, YPos : word );
                  procedure DisplayClock;
                  procedure SetClockColor ( C : word );
                  procedure Init;
                  function  Inkey : str10;

                  procedure RKey ( var S              : String;
                                       MaxLen, MaxDis : byte;
                                   var Quit           : boolean );

                  function  CheckMouse ( Check : boolean ) : Str10;
                  procedure Create ( XPos, YPos, Color : word; T, K : String);
                  procedure Release ;
                  procedure Display ;
                  function  GetButton ( CurX, CurY : integer ) : TButtonPtr;
                  procedure ReleaseButton;
                  procedure Clear;
                  procedure Pause;
               end;

{* 2015 Additions *}
function MouseButton1 : boolean;
function MouseX : integer;
function MouseY : integer;
procedure ReadMouse (var X, Y, Color : integer; var Data : string);
procedure SplitButtons (Data : String; var B1, B2, B3 : boolean);
procedure ReleaseButtons;
procedure ResetMouse;

implementation

   uses QCrtNM, Dos, Clock, ScrnUtil, Screens;

   var
      Regs : registers;

{* 2015 Additions *}
	var
   		Active : boolean;
		IMouse : TMouse;

procedure StartMouse;
begin
	IMouse.Init;
	Active := True;
end;

function MouseButton1 : boolean;
begin
	if not Active then StartMouse;
	MouseButton1 := False;
end;

function MouseX : integer;
var
  X, Y, B: integer;
begin
	if not Active then StartMouse;
	IMouse.GetPosition(B, X, Y);
	MouseX := X;
end;

function MouseY : integer;
var
  X, Y, B: integer;
begin
	if not Active then StartMouse;
	IMouse.GetPosition(B, X, Y);
	MouseY := Y;
end;
procedure ReadMouse (var X, Y, Color : integer; var Data : string);
begin
	if not Active then StartMouse;
end;

procedure SplitButtons (Data : String; var B1, B2, B3 : boolean);
begin
	if not Active then StartMouse;
end;

procedure ReleaseButtons;
begin
	if not Active then StartMouse;
end;

procedure ResetMouse;
begin
	if not Active then StartMouse;
end;
{* Original Code *}

function Lower ( n1, n2 : integer ) : integer;
begin
   if n1 < n2 then Lower := n1
              else Lower := n2;
end;

function Upper ( n1, n2 : integer ) : integer;
begin
   if n1 > n2 then Upper := n1
              else Upper := n2;
end;

procedure MouseHandler ( Flags, CS, IP, AX, BX, CX, DX, SI,
                         DI, DS, ES, BP : word);

interrupt;
begin
   mEvent.Event     := AX;
   mEvent.BtnStatus := BX;
   mEvent.xPos      := CX;
   mEvent.yPos      := DX;
                    { exit processing for far return to driver}

{   asm
      mov sp,bp
      pop bp
      pop es
      pop ds
      pop di
      pop si
      pop dx
      pop cx
      pop bx
      pop ax
      retf
   end;}
end;


function GenMouse.TestMouse : boolean;
const
   iret = 207;
var
   dOff, dSeg : integer;
begin
   dOff := MemW[0000:0204];
   dSeg := MemW[0000:0206];
   if ( ( dSeg = 0 ) or ( dOff = 0 ) ) then
        TestMouse := False
   else TestMouse := Mem[dSeg:dOff] <> iret;
end;

procedure GenMouse.Reset ( var Status : boolean; var BtnCount : integer );
begin
   regs.AX := $00;
   intr($33,regs);
   Status   := regs.AX <> 0;
   BtnCount := regs.BX;
end;

procedure GenMouse.SetAccel (threshold : integer);
begin
   regs.AX := $13;
   regs.DX := threshold;
   intr($33,regs);
end;

procedure GenMouse.Show ( Option : boolean);
begin
   if (Option) and (not Visible) then
   begin
      Visible := True;
      regs.AX := $01;
      intr($33,regs);
   end else
   if (Visible) and (not Option) then
   begin
      Visible := False;
      regs.AX := $02;
      intr($33,regs);
   end;
end;

procedure GenMouse.GetPosition (var BtnStatus, XPos, YPos : integer);
begin
   regs.AX := $03;
   intr($33,regs);
   BtnStatus := regs.BX;
   XPos      := regs.CX;
   YPos      := regs.DX;
end;

procedure GenMouse.SetPosition (XPos, YPos : integer);
begin
  regs.AX := $04;
  regs.CX := XPos;
  regs.DX := YPos;
  intr ($33,regs);
end;

procedure GenMouse.SetRatio ( horPix, verPix : integer);
begin
   regs.AX := $0F;
   regs.CX := horPix;
   regs.DX := verPix;
   intr($33,regs);
end;

procedure GenMouse.QueryBtnDn ( button : integer; var mouse : Position );
begin
   regs.AX := $05;
   regs.BX := button;
   intr($33,regs);
   mouse.btnStat := regs.AX;
   mouse.opCount := regs.BX;
   mouse.xPos    := regs.CX;
   mouse.yPos    := regs.DX;
end;

procedure GenMouse.QueryBtnUp (button :integer; var mouse : Position );
begin
   regs.AX := $06;
   regs.BX := button;
   intr($33,regs);
   mouse.btnStat := regs.AX;
   mouse.opCount := regs.BX;
   mouse.xPos    := regs.CX;
   mouse.yPos    := regs.DX;
end;

procedure GenMouse.SetLimits ( XMin, YMin, XMax, YMax : integer );
begin
   regs.AX := $07;
   regs.CX := Lower (XMin, XMax);
   regs.DX := Upper (XMin, XMax);
   intr ($33,regs);
   regs.AX := $08;
   regs.CX := Lower (YMin, YMax);
   regs.DX := Upper (YMin, YMax);
   intr ($33,regs);
end;

procedure GenMouse.ReadMove ( var XMove, YMove : integer);
begin
   regs.AX := $0B;
   intr($33,regs);
   XMove := regs.CX;
   YMove := regs.DX;
end;

procedure GenMouse.InstallTask;
begin
   regs.AX := $0B;
   regs.CX := Mask;
   regs.DX := ofs ( MouseHandler );
   regs.ES := seg ( MouseHandler );
   intr ($33, regs);
end;

procedure GenMouse.ClearEvent;
begin
   mEvent.Event := 0;
end;

procedure TextMouse.Initialize;
begin
   Visible := False;
   SetLimits (lo(WindMin)*8, hi(WindMin)*8,
              lo(WindMax)*8, hi(WindMax)*8);
   SetCursor (Software, 6, 7);
   SetPosition (0,0);
   Show (True);
end;

procedure TextMouse.SetCursor (cType, c1, c2 : word);
begin
   regs.AX := $0A;
   regs.BX := cType;
   regs.CX := c1;
   regs.DX := c2;
   intr($33,regs);
end;

{-----------------------------------------------------------------------------}
   var
      Util : ScreenUtilities;

   procedure TMouse.UseClock (On : boolean);
      begin
         ClockOn := On;
      end;

   function TMouse.IsClockOn : boolean;
      begin
         IsClockOn := ClockOn;
      end;

   procedure TMouse.ResetClock;
      begin
         LastDate := '';
         LastTime := '';
      end;

   procedure TMouse.SetClockPos ( XPos, YPos : word );
      begin
         ClockX := XPos; ClockY := YPos;
      end;

   procedure TMouse.SetClockColor ( C : word);
      begin
         ClockColor := C;
      end;

   procedure TMouse.DisplayClock;
      var
         HC, HX, HY : word;
         CurTime : String;
      begin
         HC := TextAttr; HX := WhereX; HY := WhereY;
         TextAttr := ClockColor;
         CurTime  := Time;
         if LastTime <> CurTime then
            begin
               if (LastX >= ClockX) and (LastX <= ClockX + 18) and
                  (LastY  = ClockY) then Clear;
               GotoXY (ClockX, ClockY);  Write (CurTime + ' ':19);
               LastTime := CurTime;
               if Date(1) <> LastDate then
                  begin
                     if (LastX >= ClockX) and (LastX <= ClockX + 18) and
                        (LastY  = ClockY + 1) then Clear;
                     LastDate := Date(1);
                     GotoXY (ClockX, ClockY + 1);
                     Write (LastDate + ' ':19);
                  end;
            end;
         TextAttr := HC; GotoXY (HX, HY);
      end;
{-----------------------------------------------------------------------------}

   procedure TMouse.Init;
      var
         CurX, CurY : Word;
      begin
         CurX := WhereX;
         CurY := WhereY;
         Initialize;
         Visible := True;
         SetCursor (Software, 1, 7);
         Show (False);
         GotoXY (CurX, CurY);
         LastX := $FFFF;
         TBut := NIL;
         LastBut := NIL;
         case LastMode of
            BW80, BW80 + Font8x8,
            CO80, CO80 + Font8x8 : Use80 := True;
            BW40, BW40 + Font8x8,
            CO40, CO40 + Font8x8 : Use80 := False;
         end;
         ClockOn := False;
         ClockX := 1; ClockY := 1; ClockColor := Color (7,1);
         ResetClock;
      end;
{-----------------------------------------------------------------------------}
   function TMouse.EnoughMemory : Boolean;
      begin
         EnoughMemory := MaxAvail > SizeOf (TButtonRec);
      end;

   procedure TMouse.Create ( XPos, YPos, Color : word; T, K : String);
      var
         Temp, Mark : TButtonPtr;
      begin
         if EnoughMemory then
            begin
               New ( Temp );
               with Temp^ do
                  begin
                     X := XPos; Y := YPos; C := Color;
                     Txt := T; Key := K;
                     Next := NIL;
                  end;
               if TBut = NIL then
                  TBut := Temp
               else
                  begin
                     Mark := TBut;
                     while Mark^.Next <> Nil Do
                        Mark := Mark^.Next;
                     Mark^.Next := Temp;
                  end;
            end;
      end;

   procedure TMouse.Release;
      var
         Temp, Mark : TButtonPtr;
      begin
         if TBut <> NIL then
            begin
               Mark := TBut;
               while Mark <> NIL do
                  begin
                     Temp := Mark^.Next;
                     System.Dispose (Mark);
                     Mark := Temp;
                  end;
               TBut := NIL;
               LastBut := NIL;
            end;
      end;
{-----------------------------------------------------------------------------}
   procedure TMouse.Display;
      var
         Mark   : TButtonPtr;
      begin
         if TBut <> NIL then
            begin
               Mark := TBut;
               while Mark <> NIL do
                  With Mark^ do
                     begin
                        GotoXY (X, Y); TextAttr := C;
                        Write  (Txt);
                        Mark := Mark^.Next;
                     end;
               LastBut := NIL;
            end;
      end;
{-----------------------------------------------------------------------------}
   function TMouse.GetButton ( CurX, CurY : integer ) : TButtonPtr;
      var
         Mark : TButtonPtr;
      begin
         Mark := TBut;
         While (Mark <> NIL) and (Not ((Mark^.X <= CurX) and
               (Mark^.X + Length(Mark^.Txt) > CurX) and (Mark^.Y = CurY))) do
               Mark := Mark^.Next;
         GetButton := Mark;
      end;
{-----------------------------------------------------------------------------}
   procedure TMouse.ReleaseButton;
      var
         CurX, CurY, mBut : integer;
      begin
         Repeat
            GetPosition (mBut, CurX, CurY);
            if ClockOn then DisplayClock;
         until mBut = 0;
      end;
{-----------------------------------------------------------------------------}
   procedure TMouse.Clear;
      begin
         If LastX < $FFFF then
            begin
               Case Use80 of
                  True  : CO80Screen[LastY, LastX] := LastChr;
                  False : CO40Screen[LastY, LastX] := LastChr;
               end;
            end;
         if LastBut <> NIL then
            with LastBut^ do
               begin
                  GotoXY (X, Y);
                  TextAttr := C;
                  Write  (Txt);
               end;
         LastX := $FFFF; LastBut := NIL;
      end;
{-----------------------------------------------------------------------------}
   function TMouse.CheckMouse ( Check : boolean ) : Str10;
      var
         CurX, CurY, mBut : integer;
         CurBut           : TButtonPtr;
         CurC             : Word;
      begin
         GetPosition (mBut, CurX, CurY);
         CurX := CurX shr 3;
         CurY := CurY shr 3;
         if (CurX <> LastX) or (CurY <> LastY) then
            begin
               if TBut <> NIL then
                  CurBut := GetButton ( CurX, CurY )
               else
                  CurBut := NIL;
               If LastX < $FFFF then
                  begin
                     Case Use80 of
                        True  : CO80Screen[LastY, LastX] := LastChr;
                        False : CO40Screen[LastY, LastX] := LastChr;
                     end;
                  end;
               if (CurBut <> LastBut) and ( Check ) then
                  begin
                     If LastBut <> NIL then
                        with LastBut^ do
                           begin
                              GotoXY (X, Y);
                              TextAttr := C;
                              Write  (Txt);
                           end;
                     if CurBut <> NIL then
                     with CurBut^ do
                        begin
                           GotoXY (X, Y);
                           TextAttr := Util.InvertColor(C);
                           Write  (Txt);
                        end;
                     LastBut := CurBut;
                  end;
               LastX   := CurX;
               LastY   := CurY;
               Case Use80 of
                  True  : begin
                             LastChr := CO80Screen[LastY, LastX];
                             if LastBut = NIL then
                                CurC := Util.InvertColor (Hi(LastChr))
                             else
                                CurC := Util.Color (0,7);
                          end;
                  False : begin
                             LastChr := CO40Screen[LastY, LastX];
                             if LastBut = NIL then
                                CurC := Util.InvertColor (Hi(LastChr))
                             else
                                CurC := Util.Color (0,7);
                          end;
               end;
               Case Use80 of
                  True  : CO80Screen[LastY, LastX] := Lo(LastChr) + CurC Shl 8;
                  False : CO40Screen[LastY, LastX] := Lo(LastChr) + CurC Shl 8;
               end;
            end;
         if mBut > 0 then
            begin
               If LastBut <> NIL then
                  begin
                     CheckMouse := LastBut^.Key;
                     ReleaseButton;
                  end
               else
                  CheckMouse := Chr(0) + Chr(0) + Chr(LastX) + Chr(LastY);
            end;
      end;
{-----------------------------------------------------------------------------}
function GetCursor : Word;
  var
    Reg : Registers;
  begin
    with Reg do
      begin
        AH := 3;
        BH := 0;
        Intr($10, Reg);
        GetCursor := CX;
      end;
    end;

procedure RestCursor(NewCursor : Word);
  var
    Reg : Registers;
  begin
    with Reg do
      begin
        AH := 1;
        BH := 0;
        CX := NewCursor;
        Intr($10, Reg);
      end;
  end;

procedure NormCursor;  begin RestCursor ($0D0E) end;
procedure HideCursor;  begin RestCursor ($2000) end;
procedure InsCursor;   begin RestCursor ($0D11) end;

function KeyboardInKey : String;
  var
    I : String[2];
  begin
    I := '';
    If KeyPressed then
      begin
        I := ReadKey;
        If I = Chr(0) then
          I := I + ReadKey
      end;
    KeyboardInkey := I
  end;

   function TMouse.Inkey : Str10;
      var
        Key : String;
      begin
         repeat
            Key := KeyBoardInkey;
            if Key = '' then
               Key := TMouse.CheckMouse ( True );
            if ClockOn then DisplayClock;
         until Key <> '';
         TMouse.Clear;
         InKey := Key;
      end;

   procedure TMouse.Pause;
      var
        Key : String;
      begin
         repeat
            Key := KeyBoardInkey;
            if Key = '' then
               Key := TMouse.CheckMouse ( False );
            if ClockOn then DisplayClock;
         until Key <> '';
         TMouse.Clear;
         TMouse.ReleaseButton;
      end;
{-----------------------------------------------------------------------------}
   function Space ( N : byte ) : String;
      var
         T : String;
      begin
         If N > 255 then
            N := 255;
         FillChar (T[1], N, ' ');
         T[0] := Chr(N);
         Space := T;
      end;

   function LSpace ( IO : String; L : Byte ) : String;
      begin
         If Length(IO) < L then
            IO := Space (L- Length(IO)) + IO;
         LSpace := IO;
      end;

   function RSpace ( IO : String; L : Byte ) : String;
      begin
         If Length(IO) < L then
            IO := IO + Space (L- Length(IO));
         RSpace := IO;
      end;

   function CurrentMode : byte;
      var
         Regs : registers;
      begin
         Regs.AH := $0F;
         Intr ($10, Regs);
         CurrentMode := REGs. AL;
      end;

  procedure TMouse.RKey ( var S              : String;
                              MaxLen, MaxDis : byte;
                          var Quit           : boolean );
    var
      HoldS        : String;
      HoldX, HoldY,
      HoldCursor   : word;
      Key          : String;
      XPos, SPos   : byte;
      Ins          : Boolean;
      CursorMax    : byte;

    procedure DisplayString;
      begin
        While XPos - SPos + 1 > MaxDis do Inc (SPos);
        While XPos < SPos do Dec ( SPos );
        GotoXY (HoldX, HoldY);
        Write  ( Copy(S + Space(255), SPos, MaxDis) );
      end;

    procedure DisplayPart ( B : Byte );
      begin
        GotoXY (HoldX + B - SPos, HoldY);
        Write  ( Copy(S + Space(255), B, MaxDis - (B - SPos)));
      end;

    procedure Beep;
      begin
        Sound (500);
        Delay (100);
        NoSound;
      end;

    procedure AddChar ( C : String );
      begin
        if XPos + Length(C) <= MaxLen then
          begin
            if Length(S) < XPos then S := RSpace(S, XPos - 1);
            Case Ins of
              True  : if Length(S) + Length(C) <= MaxLen then
                        begin
                          Insert (C, S, XPos);
                          Inc(XPos, Length(C));
                          if XPos - SPos + 1 <= MaxDis then
                            DisplayPart ( XPos - Length(C) );
                        end
                      else
                        Beep;
              False : begin
                        Move ( C[1], S[XPos], Length(C));
                        Inc(XPos, Length(C));
                        if Length(S) < XPos then S[0] := Chr(XPos - 1);
                        if XPos - SPos + 1 <= MaxDis then
                          DisplayPart ( XPos - Length(C) );
                      end;
            end
          end
        else
          Beep;
      end;

    procedure BackSpace;
      begin
        if (XPos > 1) then
          begin
            If XPos <= Length(S) + 1 then
              Delete (S, XPos - 1, 1);
            Dec (XPos);
            if XPos - SPos + 1 >= 1 then
              DisplayPart ( XPos );
          end;
      end;

    procedure Del;
      begin
        if (XPos <= Length(S)) then
          begin
            Delete (S, XPos, 1);
            DisplayPart ( XPos );
          end;
      end;

    procedure NextWord;
      begin
        While (XPos <= MaxLen) and (XPos <= Length(S)) and
              (S[XPos] <> Chr(32)) do Inc (XPos);
        While (XPos <= MaxLen) and (XPos <= Length(S)) and
              (S[XPos] = Chr(32)) do Inc (XPos);
      end;

    procedure PriorWord;
      begin
        if XPos > Length(S) then
          XPos := Length(S)
        else
          begin
            While (XPos > 1) and (S[XPos] <> Chr(32)) do Dec (XPos);
            While (XPos > 1) and (S[XPos] = Chr(32)) do Dec (XPos);
          end;
        While (XPos > 1) and (S[XPos] <> Chr(32)) do Dec (XPos);
        if (S[XPos] = Chr(32)) and (XPos < Length(S)) then Inc(XPos);
      end;

    var
      Cursor : array[0..255] of byte;

    procedure EmulateCursor ( On : boolean );
      begin
        GotoXY (HoldX + (XPos - SPos), HoldY);
      end;

    begin
      HoldS      := S;
      case CurrentMode of
          $04, $05, $06,
          $0D, $0E, $13 : CursorMax := 8;
          $07, $0F, $10 : CursorMax := 14;
          $11, $12      : CursorMax := 16;
        else
          CursorMax := 0;
      end;
      if CursorMax = 0 then
         HoldCursor := GetCursor;
      HoldX      := WhereX;
      HoldY      := WhereY;
      Quit       := False;
      Ins        := True;
      Xpos       := Length(S) + 1;
      SPos       := 1;
      While MaxDis + WhereX >= 80 do Dec(MaxDis);
      DisplayString;
      Repeat
        If (XPos - SPos >= MaxDis) or (XPos < SPos) then DisplayString;
        GotoXY (HoldX + (XPos - SPos), HoldY);
        If CursorMax = 0 then
          Case Ins of
            True  : NormCursor;
            False : InsCursor;
          end
        else
          EmulateCursor ( True );
        Repeat
          Key := Inkey;
          if Key = '' then Key := CheckMouse(False);
          if ClockOn then DisplayClock;
        until Key <> '';
        TMouse.Clear;
        TMouse.ReleaseButton;
        if CursorMax = 0 then
          HideCursor
        else
          EmulateCursor ( False );
        case Length(Key) of
          1 : Case ord(Key[1]) of
                 8 : BackSpace;
                27 : Quit := True;
                13 : Quit := False;
              else
                AddChar ( Key );
              end;
          2 : Case Ord(Key[2]) of
                71 : XPos := 1;
                75 : If XPos > 1      then Dec (XPos);
                77 : If XPos < MaxLen then Inc (XPos);
                79 : begin
                       XPos := Length(S) + 1;
                       While XPos > MaxLen do Dec(XPos);
                     end;
                82 : Ins := Not Ins;
                83 : Del;
               115 : PriorWord;
               116 : NextWord;
              else
                Beep;
              end;
        end;
      until Quit or (Key = Chr(13));
      If Quit then S := HoldS;
      GotoXY ( HoldX, HoldY );
      if CursorMax = 0 then
        RestCursor ( HoldCursor );
    end;

end.
