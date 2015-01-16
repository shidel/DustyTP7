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
    @@Main:
      MOV  DI, OFFSET @@Message
      CALL NEAR PTR @@WriteString

      { get lastdrive }
      MOV  AH, 19h
      INT  21h
      MOV  DL, AL
      MOV  AH, 0Eh
      INT  21h
      { display lastdrive }
      MOV  AH, 02h
      MOV  DL, 64
      ADD  DL, AL
      INT  21h

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
      MOV  AX, 4C00h  { AL = Exit Code }
      INT  21h

    @@Message:     DB 'LAST_DRIVE=',0
    @@CRLF:        DB ':',13,10,0
  end;

{$I COMASM.INC}

begin
  WriteLn ('Working...');
  CreateDriver( GetDriverName );
  Run ( GetDriverName );
  WriteLn ( 'Finished.');
end.
