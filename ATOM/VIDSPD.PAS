{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

{$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V+,X+,Y+}
{$M 16384,0,655360}
program Video;

  uses TVideo, QCrtNM, Keyboard, StrAsm;

  type
{    ScreenArray = array[0..199, 0..319] of byte;}
    ScreenArray = array[0..199, 0..319] of byte;

  var
    Key         : PKeyboard;
    RealScreen,
    WriteScreen : ^ScreenArray;
    ForeColor,
    BackColor   : byte;

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

  procedure PutPixel ( X, Y, Color : Word );
    begin
      WriteScreen^[Y, X] := Color;
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

  var
    Ticks : LongInt absolute 0:$046c;

  function GetElapsed : LongInt;
    const
      Last : LongInt = 0;
    begin
      GetElapsed := Ticks - Last;
      Last := Ticks;
    end;

  const
    Frames = 32;

  procedure ShowElapsed ( T : LongInt );
    begin
      System.WriteLn ( Frames, ' frames in ', T * 0.055:1:2, ' seconds. ' );
      System.WriteLn ( 1 / ((T * 0.055) / Frames):1:2, ' frames per second. ' );
    end;

  var
    TByte  : byte;
    I, J   : word;

begin
  DirectVideo := False;
  Key := New(PKeyBoard, Init);
  RealScreen := Ptr($A000, 0);
  WriteScreen := RealScreen;
{  New(WriteScreen);}
  OpenVideo;
  Duplicate ( True );
  While GetElapsed <> 0 do;
  for I := Frames downto 1 do
    begin
      ForeColor := I;
      Bar ( 0, 0, 319, 199 );
    end;
  ShowElapsed(GetElapsed);
      repeat
      until (Key^.Inkey = #27) or Keypressed;
  CloseVideo;
  Dispose ( Key, Done );
end.
