{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

program MrBigText;

  uses Files, Video, StrAsm;

  function LoadFont( Name : String ) : Pointer;
    var
      P : Pointer;
      F : TFile;
    begin
      P := nil;
      F.Init;
      F.Assign ( Name );
      if F.Reset then
        begin
          GetMem ( P, F.FileSize );
          F.ReadRecord ( P^, F.FileSize );
        end;
      F.Close;
      F.Done;
      LoadFont := P;
    end;

  procedure SetCRTC ( Index, Value : Byte ); assembler;
    asm
      MOV DX, $3d4
      IN  AL, DX
      MOV AL, Index
      OUT DX, AL
      INC DX
      MOV AL, Value
      OUT DX, AL
    end;

  var
    P : Pointer;
    I : integer;

begin
  P := LoadFont ( '8x19.fnt');
  asm
    PUSH BP
    MOV AX, $0003
    INT $10
    MOV AX, $1110
    MOV CX, $0100
    MOV DX, $0000
    MOV BL, $00
    LES DI, P
    MOV BH, ES:[DI]
    INC DI
    MOV BP, DI
    INT $10

    POP BP
  end;
{  SetCRTC ( 0, $70 );
  SetCRTC ( 1, $2f );}
  Mem[Seg0040:$0084] := 24;
  InitVideo;
  For I := 1 to 25 do
    begin
      GotoXY (1,I);
      Write (IntStr(I));
    end;
  SetCrtc ( $1, $FF);
  for I := 0 to 15 do
    begin
      SetCRTC ( 8, I and $F );
      delay ( 55 );
    end;
  While ReadKey = '' do;
  asm
    MOV AX, $0003
    INT $10
  end;
end.
