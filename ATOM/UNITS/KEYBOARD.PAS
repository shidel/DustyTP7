{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

unit Keyboard;   { version 3.02 }
{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V+,X+,Y+}
interface

  uses Dos, StrSize, Buffers;

  const
    BufferSize      : word = 1024;
    NormalCursor    : word = $0D0E;
    kbRightShiftKey = $01;
    kbLeftShiftKey  = $02;
    kbCtrlKey       = $04;
    kbAltKey        = $08;
    kbScrollKey     = $10;
    kbNumLockKey    = $20;
    kbCapsLockKey   = $40;
    kbInsertKey     = $80;

  type
    PKeyboard = ^OKeyboard;
    OKeyboard = object
      constructor Init;
      destructor  Done;
      function    Inkey : Str2;
      procedure   Pause;
      procedure   ClearBuffer;
      function    PutBuffer ( S : String ) : boolean;
      function    KeyboardActivity : boolean;
      function    Keypressed : boolean;
      function    GetCursor : word;
      procedure   SetCursor ( NewCursor : Word );
      function    GetStatus : byte;
      procedure   NormCursor;
      procedure   HideCursor;
      procedure   InsCursor;
      procedure   BlockCursor;
    private
      Activity : boolean;
    end;

  const
    KeyBoardIdle   : procedure = nil;
    BIOSKeypressed : function : boolean = nil;
    BIOSInkey      : function : Str2    = nil;
    ATKey          : boolean            = False;

  function Is286Compatable: Boolean;
  procedure SetKeyboardType ( AT : boolean );

implementation

  var
    OldExitProc : Pointer;
    OldTimer    : Procedure;
    Buffer      : PCircularBuffer;
    TString     : Str2;
    IRQEnabled  : boolean;

  function Is286Compatable: Boolean; assembler;
    asm
      PUSHF
      POP     BX
      AND     BX,0FFFH
      PUSH    BX
      POPF
      PUSHF
      POP     BX
      AND     BX,0F000H
      CMP     BX,0F000H
      MOV     AX,0
      JZ      @@1
      MOV     AX,1
    @@1:
  end;

  function XTBIOSKeypressed : boolean; assembler;
    asm
      MOV  BH, False
      MOV  AH, 1
      INT  $16
      JZ   @@1
      MOV  BH, True
    @@1:
      MOV  AL, BH
    end;

  function XTBIOSInkey : Str2; assembler;
    asm
      PUSH ES
      PUSH BX
      PUSH AX
      PUSH CX
      LES  BX, @Result
      MOV  CL, 0
      MOV  AH, 1
      INT  $16
      JZ   @@1
      MOV  AH, 0
      INT  $16
      MOV  ES:[BX + 1], AL
      INC  CL
      CMP  AL, 0
      JNE  @@1
      MOV  ES:[BX + 2], AH
      INC  CL
    @@1:
      MOV  ES:[BX], CL
      POP  CX
      POP  AX
      POP  BX
      POP  ES
    end;

  function ATBIOSKeypressed : boolean; assembler;
    asm
      MOV  BH, False
      MOV  AH, $11
      INT  $16
      JZ   @@1
      MOV  BH, True
    @@1:
      MOV  AL, BH
    end;

  function ATBIOSInkey : Str2; assembler;
    asm
      PUSH ES
      PUSH BX
      PUSH AX
      PUSH CX
      LES  BX, @Result
      MOV  CL, 0
      MOV  AH, $11
      INT  $16
      JZ   @@2
      MOV  AH, $10
      INT  $16
      MOV  ES:[BX + 1], AL
      INC  CL
      CMP  AL, 0
      JE   @@1
      CMP  AL, $E0
      JNE  @@2
    @@1:
      MOV  ES:[BX + 2], AH
      INC  CL
    @@2:
      MOV  ES:[BX], CL
      POP  CX
      POP  AX
      POP  BX
      POP  ES
    end;

{$F+}
  procedure KeyboardTimer; interrupt;
    begin
      inline ($9c);
      OldTimer;
      TString := '';
      if Assigned(Buffer) and IRQEnabled then
        repeat
          if Buffer^.FreeSpace > 2 then
            begin
              TString := BIOSInkey;
              if Length(TString) > 0 then
                begin
                  Buffer^.Put ( Byte(TString[1]) );
                  if Length(TString) > 1 then
                    Buffer^.Put ( Byte(TString[2]) );
                end;
            end;
        until (TString = '');
    end;
{$F-}

  procedure KeyboardExitProc; far;
    begin
      ExitProc := OldExitProc;
      SetIntVec ( $08, @OldTimer );
      if Assigned(Buffer) then Dispose ( Buffer, Done );
    end;

  procedure SetKeyboardType ( AT : boolean );
    begin
      ATKey := AT;
      if ATKey then
        begin
          @BIOSInkey      := @ATBIOSInkey;
          @BIOSKeypressed := @ATBIOSKeyPressed;
        end
      else
        begin
          @BIOSInkey      := @XTBIOSInkey;
          @BIOSKeypressed := @XTBIOSKeyPressed;
        end;
    end;

  procedure InitKeyBoard;
    begin
      IRQEnabled   := True;
      OldExitProc  := ExitProc;
      ExitProc     := @KeyBoardExitProc;
      SetKeyboardType ( Is286Compatable );
      GetIntVec    ( $08, @OldTimer );
      SetIntVec    ( $08, @KeyboardTimer );
      if MaxAvail > Sizeof(CircularBuffer) then
        Buffer := New(PCircularBuffer, Init( BufferSize ) )
      else
        Buffer := nil;
      asm
        MOV AH, 3
        MOV BH, 0
        INT $10
        MOV NormalCursor, CX
      end;
    end;

{---------------------------------------------------------------------------}
  constructor OKeyboard.Init;
    begin
      Activity := False;
      ClearBuffer;
    end;

  destructor OKeyboard.Done;
    begin
    end;

  function OKeyboard.Inkey : Str2;
    var
      TStr : Str2;
    begin
      if Assigned(KeyboardIdle) then KeyBoardIdle;
      IRQEnabled := False;
      if Assigned(Buffer) and (not Buffer^.Empty) then
        begin
          TStr := Chr(Buffer^.Get);
          if (TStr[1] = #0) and (not Buffer^.Empty) then
            TStr := TStr + Chr(Buffer^.Get);
        end
      else
        TStr := BIOSInkey;
      if TStr <> '' then Activity := True;
      Inkey := TStr;
      IRQEnabled := True;
    end;

  procedure OKeyboard.Pause;
    begin
      While Inkey = '' do;
    end;

  procedure OKeyboard.ClearBuffer;
    begin
      While Inkey <> '' do;
    end;

  function OKeyboard.PutBuffer ( S : String ) : boolean;
    var
      I : byte;
    begin
      PutBuffer := False;
      IRQEnabled := False;
      if Assigned(Buffer) and (Buffer^.FreeSpace < Length(S)) then
        begin
          For I := 1 to Length(S) do
            if Not Buffer^.Put(Byte(S[I])) then
              begin
                IRQEnabled := True;
                Exit;
              end;
          PutBuffer := True;
        end;
      IRQEnabled := True;
    end;

  function OKeyboard.KeyboardActivity : boolean;
    begin
      KeyboardActivity := Activity;
      Activity := False;
    end;

  function OKeyBoard.Keypressed : boolean;
    begin
      if Assigned(Buffer) then
        Keypressed := (not Buffer^.Empty) or (BIOSKeypressed)
      else
        Keypressed := BIOSKeypressed;
    end;

  function OKeyboard.GetCursor : word; assembler;
    asm
      MOV AH, 3
      MOV BH, 0
      INT $10
      MOV AX, CX
    end;

  procedure OKeyboard.SetCursor ( NewCursor : word ); assembler;
    asm
      MOV AH, 1
      MOV BH, 0
      MOV CX, NewCursor
      INT $10
    end;

  function OKeyboard.GetStatus : byte; assembler;
    asm
      MOV AH, 2
      INT $16
    end;

  procedure OKeyboard.NormCursor;
    begin
      SetCursor ( NormalCursor );
    end;

  procedure OKeyboard.HideCursor;
    begin
      SetCursor ( $2000 );
    end;

  procedure OKeyboard.InsCursor;
    begin
      SetCursor ( (MemW[$0:$0485] div 2) shl 8 + Lo(NormalCursor));
    end;

  procedure OKeyboard.BlockCursor;
    begin
      SetCursor ( MemW[$0:$0485] );
    end;

begin
  InitKeyBoard;
end.
