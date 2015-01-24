{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

{ $DEFINE BLOTCH}
{$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y+}
{$M 2048,0,655360}
program Video;

  uses Crt, Keyboard;

  const
    Speed     = 1;
    SplitRate = 255;
    Maximum   = 400;
    Max       = 100;

  var
    Ticks : longint absolute $0040:$006c;

  const
    Last : LongInt = 0;

  type
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
        MV   : byte;
      constructor Init ( XX, YY : word; CC : Byte );
      destructor  Done;
      procedure   Draw;
    end;

  constructor OPixel.Init;
    begin
      X := XX;
      Y := YY;
      D := Random( 4 );
      C := CC;
      MV := SplitRate;
      Next := nil;
    end;

  destructor OPixel.Done;
    begin
    end;

  procedure OPixel.Draw;
    begin
      {$IFNDEF BLOTCH}
      WriteScreen^[Y, X] := 0;
      {$ENDIF}
      if X > 309 then D := 2 else
      if Y > 189 then D := 3 else
      if X < 10  then D := 0 else
      if Y < 10  then D := 1;
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
      if MV > 0 then Dec(MV);
      {$IFDEF BLOTCH}
      if (WriteScreen^[Y, X] <> C ) then
      {$ELSE}
      if (WriteScreen^[Y, X] <> 0 ) then
      {$ENDIF}
        begin
          D := Random ( 4 );
          if MV = 0 then
            begin
              NewPixel ( X, Y, C);
              MV := SplitRate;
            end;
          MV := SplitRate;
        end;
      WriteScreen^[Y, X] := C;
    end;

  const
    First : PPixel = nil;
    Count : word   = 0;
    Total : word   = 0;

  procedure NewPixel;
    var
      TPixel : PPixel;
    begin
      if (MaxAvail > Sizeof(OPixel)) and (Count < Maximum) then
        begin
          TPixel := New(PPixel, Init ( X, Y, C ));
          TPixel^.Next := First;
          First := TPixel;
          Inc (Count );
          Total := Count;
        end
      else
        Count := Max;
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
          Dec(Count);
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
    begin
{      while Count < Max do NewPixel(Random( 190 ) + 15, Random( 160 ) + 15);}
      while Count < Max do NewPixel(160, 100, Random(15) + 1 );
      repeat
        Draw;
        While Ticks - Last < Speed do;
        Last := Ticks;
      until Key^.Inkey = #27;
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
  ForeColor := 0;
  Bar ( 0, 0, 319, 199 );
  Main;
  CloseVideo;
  Dispose ( Key, Done );
  WriteLn ( Total );
end.
