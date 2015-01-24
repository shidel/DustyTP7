{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

{ $DEFINE ShowIT}
{$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y+}
{$M $7FFF,0,655360}
program Video;

  uses Dos, Crt, Keyboard;

  const
    Speed        = 1;
    Energy       = 1000;
    EnergyNeeded = 125;
    StartMax     = 50;
    MaxJump      = 25;
    Life         = 500;

  var
    Ticks : longint absolute $0040:$006c;

  const
    Last  : LongInt = 0;
    Count : Word = 0;

  type
    ScreenArray = array[0..199, 0..319] of byte;

  var
    Key         : PKeyboard;
    RealScreen,
    WriteScreen : ^ScreenArray;
    ForeColor,
    BackColor   : byte;

  procedure SetColors;
    var
      Colors : array[0..255,0..2] of byte;
      I      : byte;
      Regs   : Registers;
    begin
      FillChar ( Colors, Sizeof(Colors), 0);
      for I := 0 to 63 do Colors[      I, 0] := I;
      for I := 0 to 63 do Colors[ 64 + I, 1] := I;
      for I := 0 to 63 do Colors[128 + I, 2] := I;
      for I := 0 to 63 do FillChar(Colors[192 + I, 0], 3, I);
      with Regs do
        begin
          ES := Seg(Colors); DX := Ofs(Colors);
          AX := $1012;
          BX := $00;
          CX := $100;
          Intr ( $10, Regs )
        end;
    end;

  procedure OpenVideo; assembler;
    asm
      MOV AX, $0013
      INT $10
      MOV ForeColor, 15
      MOV BAckColor, 0
    end;

  procedure CloseVideo; assembler;
    asm
      MOV AX, $0003
      INT $10
    end;

  procedure Bar ( X1, Y1, X2, Y2 : word );
    var
      Wide : word;
      J    : Word;
    begin
      Wide := X2 - X1 + 1;
      For J := Y1 to Y2 do
        FillChar(WriteScreen^[J, X1], Wide, ForeColor );
    end;

  procedure Duplicate ( Which : boolean );
    begin
      if RealScreen <> WriteScreen then
        Case Which of
          False : RealScreen^ := WriteScreen^;
          True  : WriteScreen^ := RealScreen^;
        end;
    end;

  procedure DuplicatePart ( Which : boolean; X1, Y1, X2, Y2 : word );
    var
      Wide, J : word;
    begin
      if RealScreen <> WriteScreen then
        Case Which of
          False : begin
            Wide := X2 - X1 + 1;
            For J := Y1 to Y2 do
              Move(WriteScreen^[J, X1], RealScreen^[J, X1], Wide );
          end;
          True  : begin
            Wide := X2 - X1 + 1;
            For J := Y1 to Y2 do
              Move(RealScreen^[J, X1], WriteScreen^[J, X1], Wide );
          end;

        end;
    end;

  procedure NewPixel ( X, Y : word; C : byte ); forward;

  type
    PPixel = ^OPixel;
    OPixel = object
        Next : PPixel;
        X, Y : word;
        D, C : byte;
        MV   : word;
        Left : word;
      constructor Init ( XX, YY : word; CC : Byte );
      destructor  Done;
      procedure   Draw;
    end;

  constructor OPixel.Init;
    begin
      X := XX;
      Y := YY;
      D := Random( 8 );
      C := CC;
      MV   := EnergyNeeded;
      Next := nil;
      Left := Life
    end;

  destructor OPixel.Done;
    begin
      WriteScreen^[Y, X] := 0;
    end;

  procedure OPixel.Draw;
    var
      TNext : PPixel;
      V     : Word;
    begin
      WriteScreen^[Y, X] := 0;
      if Left = 0 then Exit;
      if X > 319 then X := 1;
      if Y > 199 then Y := 1;
      if X < 1   then X := 319;
      if Y < 1   then Y := 199;
      Case D of
        0 : begin inc ( X ); end;
        1 : begin inc ( Y ); end;
        2 : begin dec ( X ); end;
        3 : begin dec ( Y ); end;
        4 : begin inc ( X ); inc ( Y ); end;
        5 : begin inc ( X ); dec ( Y ); end;
        6 : begin dec ( X ); dec ( Y ); end;
        7 : begin dec ( X ); inc ( Y ); end;
      end;
      Dec(Left);
      if MV > 0 then
        begin
          V := Energy div Count;
          if V > MV then
            MV := 0
          else
            Dec(MV, V);
        end;
      if (WriteScreen^[Y, X] <> 0 ) then
        begin
          D    := Random ( 8 );
          if MV = 0 then
            begin
              Left := Life;
              NewPixel ( X, Y, C);
            end;
          MV   := EnergyNeeded;
        end;
      if Left = 0 then Dec( Count );
      WriteScreen^[Y, X] := C + 63 - (MV SHR 3);
      if Assigned(Next) and ( Next^.Left = 0) then
        begin
          TNext := Next;
          Next := Next^.Next;
          Dispose(TNext, Done);
        end;
    end;

  const
    First : PPixel = nil;
    Total : word   = 0;

  procedure NewPixel;
    var
      TPixel : PPixel;
    begin
      if (MaxAvail > Sizeof(OPixel)) then
        begin
          TPixel := New(PPixel, Init ( X, Y, C ));
          TPixel^.Next := First;
          First := TPixel;
          Inc (Count );
          Total := Count;
        end
      else
        Count := StartMax;
    end;

  procedure DonePixel;
    var
      TPixel : PPixel;
    begin
      While Assigned(First) do
        begin
          TPixel := First^.Next;
          Dispose(First, Done);
          First := TPixel;
        end
    end;

  procedure Draw;
    var
      TPixel : PPixel;
    begin
      TPixel := First;
      While Assigned(TPixel) do
        begin
          TPixel^.Draw;
          TPixel := TPixel^.Next;
        end;
    end;

  procedure Main;
    var
      I : Word;
      J : word;
    const
      S : LongInt = 0;
    begin
      TextAttr := 230;
      repeat
        {$IFDEF Showit}
        GotoXY ( 1, 1 ); Write (Count:4 );
        {$ENDIF}
        Draw;
        if (Ticks - S > 364) or (Count = 0) then
          begin
            J := StartMax * 2 - Count;
            if J > MaxJump then J := MaxJump;
            if Count < StartMax then
              for I := 1 to J do NewPixel(160, 100, Random(4) * 64 );
            S := Ticks;
          end;
        While Ticks - Last < Speed do;
        Last := Ticks;
      until (Key^.Inkey = #27);
      DonePixel;
    end;


begin
  Randomize;
  DirectVideo := False;
  Key := New(PKeyBoard, Init);
  RealScreen := Ptr($A000, 0);
  WriteScreen := RealScreen;
{  New(WriteScreen);}
  OpenVideo;
  SetColors;
  ForeColor := 0;
  Bar ( 0, 0, 319, 199 );
  Main;
  CloseVideo;
  Dispose ( Key, Done );
end.
