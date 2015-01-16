{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
unit StrAsm; { version 2.14a }
{$D-,Y-,L-}
{ This unit contains many different string manipulation routines, many
  of which are written in assembly language for faster execution. }

interface

  uses StrSize;

  type
    PString = ^String;

  function NextPos ( SubStr : String; S : String; StartPos : byte ) : byte;
  { Like Pos function, except starts searching at Startpos Byte.
    Uses Pos function. }
  function UCase      ( Str : String )              : String; {3.89x}
  { Converts lowercase letters to uppercase }
  function LCase      ( Str : String )              : String; {2.36x}
  { Converts uppercase letters to lowercase }
  function RTrim      ( Str : String )              : String; {proportional}
  { removes trailing spaces }
  function LTrim      ( Str : String )              : String; {proportional}
  { removes preceding spaces }
  function Trim       ( Str : String )              : String; {proportional}
  { removes trailing and preceding spaces }
  function Space      ( N   : byte   )              : String; {1.28x}
  { creates a string of N spaces }
  function LSpace     ( Str : String; N : byte )    : String; {1.28x}
  { pads a string with spaces to the left like "Write (Str:N)" }
  function RSpace     ( Str : String; N : Byte )    : String; {1.22x}
  { like LSpace except spaces go to the right }
  function CSpace     ( Str : String; N : Byte )    : String;
  { like LSpace except centers inbetween spaces }
  function ZeroPad    ( Str : String; N : Byte )     : String;
  { like LSpace except zero's are inserted }
  function ChrStr     ( C   : Char;   N : byte )    : String; { ?? }
  { creates a string of characters N bytes long }

  function HEXByte ( B : byte    ) : Str2;
  function HEXWord ( W : Word    ) : Str4;
  function HEXLong ( L : LongInt ) : Str8;
  function HEXPtr  ( P : Pointer ) : Str9;

  function BINByte ( B : Byte    ) : Str8;
  function BINWord ( W : Word    ) : Str16;
  function BINLong ( L : LongInt ) : Str32;

  function BoolStr ( B : Boolean ) : Str5;
  { Returns True/False }
  function IntStr   ( L : LongInt ) : Str20;
  { Returns String from Long Integer }
  function RealStr ( R : {$IFOPT N+} Extended {$ELSE} Real {$ENDIF}; P : byte ) : Str40;
  { Returns String from Extended Real number }
  function Comma ( S : String ) : String;
  { Inserts commas into a number string handles positive, negative, integer,
    and formated reals of any size }

  function FirstChar  ( Str : String )              : Byte;   {new}
  { returns the position of the first character }
  function FilterStr  ( Str : String; C    : Char ) : String; {new}
  { removes matching characters from a string }
  function ReplaceStr ( Str : String; O, N : Char ) : String; {new}
  { Replaces characters in a string }
  procedure AddChr ( var S : String; C : Char );
  { Adds Character to end of String }
  procedure AddStr ( var S1 : String; S2 : String );
  { Adds Character to end of String }
  function ClipStr( S : String; Len : byte ) : String;
  { Clips a string to a certian length, or pads it with spaces }
  function FlipStr( S : String ) : String;
  { Reverses the text in a string }

  function  AllocStr(S: String) : PString;
  function  ReAllocStr(var P : PString; S : String) : PString;
  procedure DeallocStr(var P : PString);
  function  GetStr(P : PString) : String;

implementation

  function NextPos ( SubStr : String; S : String; StartPos : byte ) : byte;
    var
      StrPtr : ^String;
      TPos   : Byte;
    begin
      if (StartPos = 0) or (StartPos > Length(S)) then
        NextPos := 0
      else
        begin
          Dec(StartPos);
          S[StartPos] := Char(Length(S) - StartPos);
          StrPtr := @S[StartPos];
          TPos := Pos(SubStr, StrPtr^);
          if TPos > 0 then Inc(TPos, StartPos);
          NextPos := TPos;
        end;
    end;

{----------------------------------------------------------------------------}
  function UCase ( Str : String ) : String;
    begin
      asm
        CLD
        LEA     SI, Str
        LES     DI, @Result
        SEGSS   LODSB
        STOSB
        XOR     AH, AH
        XCHG    AX, CX
        JCXZ    @3
      @1:
        SEGSS   LODSB
        CMP     AL, 'a'
        JB      @2
        CMP     AL, 'z'
        JA      @2
        SUB     AL, 20h
      @2:
        STOSB
        LOOP    @1
      @3:
      end;
    end;
{----------------------------------------------------------------------------}
  function LCase ( Str : String ) : String;
    begin
      asm
        CLD
        LEA     SI, Str
        LES     DI, @Result
        SEGSS   LODSB
        STOSB
        XOR     AH, AH
        XCHG    AX, CX
        JCXZ    @3
      @1:
        SEGSS   LODSB
        CMP     AL, 'A'
        JB      @2
        CMP     AL, 'Z'
        JA      @2
        ADD     AL, 20h
      @2:
        STOSB
        LOOP    @1
      @3:
      end;
    end;
{----------------------------------------------------------------------------}
  function FilterStr ( Str : String; C : Char ) : String;
    begin
      asm
        CLD
        MOV     BL, C
        LEA     SI, Str
        LES     DI, @Result
        SEGSS   LODSB
        STOSB
        XOR     AH, AH
        XCHG    AX, CX
        JCXZ    @3
      @1:
        SEGSS   LODSB
        CMP     AL, 32
        JB      @2
        CMP     AL, 126
        JA      @2
        MOV     AL, BL
      @2:
        STOSB
        LOOP    @1
      @3:
      end;
    end;
{----------------------------------------------------------------------------}
  function ReplaceStr ( Str : String; O, N : Char ) : String;
    begin
      asm
        CLD
        MOV     BL, O
        MOV     BH, N
        LEA     SI, Str
        LES     DI, @Result
        SEGSS   LODSB
        STOSB
        XOR     AH, AH
        XCHG    AX, CX
        JCXZ    @3
      @1:
        SEGSS   LODSB
        CMP     AL, BL
        JNE     @2
        MOV     AL, BH
      @2:
        STOSB
        LOOP    @1
      @3:
      end;
    end;

  function RTrim ( Str : String ) : String;
    begin
      While (Str[Length(Str)] = #32) and (Str <> '') do Str[0] := Chr(Length(Str) - 1);
      RTrim := Str;
    end;

  function FirstChar ( Str : String ) : Byte; assembler;
    asm
      PUSH DS
      LDS  DI, Str
      MOV  AX, 0
      MOV  CH, 0
      MOV  CL, DS:[DI]
    @@1:
      JCXZ @@2
      DEC  CX
      INC  DI
      INC  AH
      MOV  BL, DS:[DI]
      CMP  BL, 32
      JE   @@1
      MOV  AL, AH
    @@2:
      POP  DS
    end;

  function LTrim ( Str : String ) : String;
    var
      I : Byte;
    begin
      I := FirstChar(Str);
      Case I of
        0      : LTrim := '';
        1      : LTrim := Str;
        2..255 : LTrim := Copy( Str, I, Length(Str) - I + 1);
      end;
    end;

  function Trim ( Str : String ) : String;
    var
      I : Byte;
    begin
      While Str[Length(Str)] = #32 do Str[0] := Chr(Length(Str) - 1);
      I := FirstChar(Str);
      Case I of
        0      : Trim := '';
        1      : Trim := Str;
        2..255 : Trim := Copy( Str, I, Length(Str) - I + 1);
      end;
    end;

  function Space ( N : byte ) : String;
    Var
      T : String;
    begin
      FillChar ( T[1], N, 32);
      T[0] := Chr(N);
      Space := T;
    end;

  function LSpace ( Str : String; N : byte ) : String;
    begin
      if Length(Str) < N then
        LSpace := Space( N - Length(Str) ) + Str
      else
        LSpace := Str;
    end;

  function RSpace ( Str : String; N : Byte ) : String;
    begin
      if Length(Str) < N then
        RSpace := Str + Space( N - Length(Str) )
      else
        RSpace := Str;
    end;

  function CSpace ( Str : String; N : Byte ) : String;
    begin
      Str := Trim(Str);
      if N < Length(Str) then
        CSpace := Copy(Str, 1, N)
      else
        CSpace := RSpace(Space((N div 2) - (Length(Str) div 2)) + Str, N);
    end;

  function ZeroPad ( Str : String; N : byte ) : String;
    begin
      if Length(Str) < N then
        ZeroPad := ChrStr('0', N - Length(Str) ) + Str
      else
        ZeroPad := Str;
    end;
{----------------------------------------------------------------------------}
  function HEXbyte ( B : byte ) : Str2; assembler;
    asm
      LES DI, @RESULT
      MOV AL, $02
      MOV ES:[DI], AL
      MOV AL, B
      MOV AH, B
      AND AH, $0F
      AND AL, $F0
      MOV CL, $04
      SHR AL, CL
      CMP AL, $9
      JNA @@1
      ADD AL, $07
    @@1:
      ADD AL, $30
      CMP AH, $9
      JNA @@2
      ADD AH, $07
    @@2:
      ADD AH, $30
      MOV ES:[DI + 1], AX
    end;

  function HEXWord ( W : Word ) : Str4;
    begin
      HEXWord := HEXByte(Hi(W)) + HEXByte(Lo(W));
    end;

  function HEXLong ( L : LongInt ) : Str8;
    type
      WordCast = array[0..1] of word;
    begin
      HEXLong := HEXWord(WordCast(L)[1]) + HEXWord(WordCast(L)[0]);
    end;

  function HexPtr  ( P : Pointer ) : Str9;
    begin
      HexPtr := HexWord(Seg(P^)) + ':' + HexWord(Ofs(P^));
    end;


  function BINByte ( B : Byte ) : Str8; assembler;
    asm
      LES DI, @Result
      MOV AL, 8
      MOV ES:[DI], AL
      MOV CX, 8
      MOV AL, B
    @@1:
      INC DI
      MOV AH, '1'
      CMP AL, $80
      JAE @@2
      MOV AH, '0'
    @@2:
      MOV ES:[DI], AH
      SHL AL, 1
      DEC CX
      JNZ @@1
    end;

  function BINWord ( W : Word ) : Str16;
    begin
      BINWord := BINByte(Hi(W)) + BINByte(Lo(W));
    end;

  function BINLong ( L : LongInt ) : Str32;
    type
      WordCast = array[0..1] of word;
    begin
      BINLong := BINWord(WordCast(L)[1]) + BINWord(WordCast(L)[0]);
    end;

  function IntStr  ( L : LongInt ) : Str20;
    var
      S : Str20;
    begin
      Str ( L, S );
      IntStr := S;
    end;

  function RealStr ( R : {$IFOPT N+} Extended {$ELSE} Real {$ENDIF}; P : byte ) : Str40;
    var
      S : Str40;
    begin
      if P = 0 then
        Str ( R, S )
      else
        Str ( R:1:P, S );
      RealStr := S;
    end;

  function ChrStr ( C   : Char;   N : byte ) : String;
    var
      S : String;
    begin
      S[0] := Char(N);
      if N > 0 then FIllChar ( S[1], N, C );
      ChrStr := S;
    end;

  function BoolStr  ( B : Boolean ) : Str5;
    begin
      if B then BoolStr := 'TRUE' else BoolStr := 'FALSE';
    end;
{----------------------------------------------------------------------------}
  function Comma ( S : String ) : String;
    var
      I : Byte;
      P : Byte;
    begin
      S := Trim(S);
      P := Pos ('.', S);
      if P = 0 then P := Length(S) else Dec(P);
      I := P;
      While (I > 1) and (Pos(S[I - 1], '0123456789') <> 0) do
        if (P - I) and $3 = 2 then
          begin
            Insert ( ',', S, I );
            Inc(P);
          end
        else
          Dec(I);
      Comma := S;
    end;

  procedure AddChr ( var S : String; C : Char );
    begin
      Inc(Byte(S[0]));
      S[Byte(S[0])] := C;
    end;

  procedure AddStr ( var S1 : String; S2: String );
    var
      MoveLen : Byte;
    begin
      MoveLen := Byte(S2[0]);
      if MoveLen + Length(S1) > 255 then MoveLen := 255 - Length(S1);
      Move ( S2[1], S1[Length(S1) + 1], MoveLen );
      Inc(Byte(S1[0]), MoveLen);
    end;

  function ClipStr( S : String; Len : byte ) : String;
    begin
      S := RSpace(S, Len);
      if Length(S) > Len then S := Copy(S, 1, Len - 3) + '...';
      ClipStr := S;
    end;

  function FlipStr( S : String ) : String;
    var
      I : byte;
      C : Char;
    begin
      if Length(S) > 1 then
        begin
          for I := 0 to Length(S) div 2 - 1 do
            begin
              C := S[I + 1];
              S[I + 1] := S[Length(S) - I];
              S[Length(S) - I] := C;
            end;
        end;
      FlipStr := S;
    end;

  function  AllocStr(S: String) : PString;
    var
      P : PString;
    begin
      P := nil;
      if (S <> '') and (MaxAvail > Length(S) + 1) then
        begin
          GetMem(P, Length(S) + 1);
          Move(S, P^, Length(S) + 1);
        end;
      AllocStr := P;
    end;

  procedure DeallocStr(var P : PString);
    begin
      if Assigned(P) then
        FreeMem(P, Length(P^) + 1);
      P := nil;
    end;

  function  ReAllocStr(var P : PString; S : String) : PString;
    var
      T : PString;
    begin
      T := AllocStr(S);
      if Assigned(T) or (S = '') then
        begin
          if Assigned(P) then DeallocStr(P);
          P := T;
        end;
      ReAllocStr := P;
    end;

  function GetStr(P : PString) : String;
    begin
      if Assigned(P) then
        GetStr := P^
      else
        GetStr := '';
    end;


end.