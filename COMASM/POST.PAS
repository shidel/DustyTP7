{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$F+,O-,G+}
program COM_Program_Shell;
(* COM file compiler/builder version 2.20c *)

  uses Dos, ComConst;

  procedure Com; far; assembler;
    asm
      @@PSP:
      @INT_20:         DB  90h,90h
      @MEMORY_TOP:     DB  90h,90h
      @RESERVED_1:     DB  90h
      @OPCODE:         DB  90h
      @SEGMENT_SIZE:   DB  90h,90h,90h,90h
      @TERMINATE:      DB  90h,90h,90h,90h
      @CONTROL_BREAK:  DB  90h,90h,90h,90h
      @CRITICAL_ERROR: DB  90h,90h,90h,90h
      @RESERVED_2:     DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h
      @ENV_SEGMENT:    DB  90h,90h
      @RESERVED_3:     DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h
      @DOS_CALL:       DB  90h,90h
      @RESERVED_4:     DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
      @FCB_1:          DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h
      @FCB_2:          DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h
      @COMMAND_LINE:   DB  90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
    @@PSP_END:
    @@Initialize:
    { Test for Ansi driver }
      MOV  DI, OFFSET @@AnsiTestStr
    @@Initialize2:
      MOV  DL, [DI]
      INC  DI
      CMP  DL, 0
      JE   @@Initialize3
      MOV  AH, $02
      INT  $21
      JMP  @@Initialize2
    @@Initialize3:
      MOV  AH, $06
      MOV  DL, $FF
      INT  $21
      JZ   @@Initialize5
      CMP  AL, 27
      JNE  @@Initialize5
      MOV  AH, $06
      MOV  DL, $FF
      INT  $21
      JZ   @@Initialize5
      CMP  AL, '['
      JNE  @@Initialize5
    @@Initialize4:
      MOV  AH, $06
      MOV  DL, $FF
      INT  $21
      JZ   @@Initialize5
      CMP  AL,'R'
      JNE  @@Initialize4
    @@Initialize5:
      MOV  AH, $06
      MOV  DL, $FF
      INT  $21
      JZ   @@Initialize6
      CMP  AL,13
      JNE  @@Initialize5
      MOV  AL, True
      JMP  @@Initialize9
    @@Initialize6: { Not Found }
      MOV  DI, OFFSET @@AnsiTestStr
    @@Initialize7:
      MOV  DL, [DI]
      INC  DI
      CMP  DL, 0
      JE   @@Initialize8
      MOV  AH, $02
      MOV  DL, 8
      INT  $21
      MOV  AH, $02
      MOV  DL, 32
      INT  $21
      MOV  AH, $02
      MOV  DL, 8
      INT  $21
      JMP  @@Initialize7
    @@Initialize8:
      MOV  AL, False
      MOV  CS:[OFFSET @@ANSIFOUND], AL
    @@Initialize9:

    @@Main:
      MOV  DI, OFFSET @@NoAnsiText
      CMP  AL, False
      JE   @@1
      MOV  DI, OFFSET @@AnsiText
    @@1:
      CALL NEAR PTR @@WriteString

      MOV  DI, OFFSET @@CRLF
      CALL NEAR PTR @@WriteString
      JMP  @@Done

    @@WriteString:  { NEAR PROC;  DS:[DI] ptr to NUL TERMINATED STRING }
      MOV  DL, [DI]
      INC  DI
      CMP  DL, 0
      JE   @@EndWriteString
      MOV  AH, 02h
      INT  21h
      JMP  @@WriteString
    @@EndWriteString:
      RETN

    @@DONE:
(*      MOV  AX, 4C00h  { AL = Exit Code }
      INT  21h *)
      JMP DWORD PTR CS:[OFFSET @@PostJmpCodePtr]

    @@PostJmpCodePtr: DD 0FFFF0000h
    @@AnsiFound:   DB False  { Becomes, True if ansi is present }
    @@AnsiTestStr: DB 27,'[6n',0
    @@CRLF:        DB 13,10,0
    @@NoAnsiText:
      DB 13,10
      DB 9,'ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป',13,10
      DB 9,'บ  POST version 2.10a',9,9,9,'  Free-Software 1995  บ',13,10
      DB 9,'ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ',13,10
      DB 13,10,0
    @@AnsiText:
      DB 27,'[0;1;40;31m',13,10
      DB 9,'ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป',13,10
      DB 9,'บ',27,'[1;44;33m  POST version 2.10a',9,9,9,'   Free-Software 1995  ',27,'[0;1;40;31mบ',13,10
      DB 9,'ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ',13,10
      DB 27,'[0m',13,10,0
  end;

{$I COMASM.INC}

begin
  WriteLn ('Working...');
  CreateDriver( GetDriverName );
{  Run ( GetDriverName );}
  WriteLn ( 'Finished.');
end.
