{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+,Y+}
{$M 16384,0,0}
program COM_Program_Shell;
(* COM file compiler/builder version 2.20c *)

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
        MOV  DI, OFFSET @@Intro
        CALL @@WriteLN
        MOV  BL, CS:[OFFSET @Command_Line]
        CMP  BL, 0
        JE   @@NoCMDLN
        XOR  BH, BH
        CMP  BX, 120
        JG   @@BadNumber
        MOV  CS:[OFFSET @Command_Line + BX + 1], BH
        MOV  DI, OFFSET @Command_Line + 1

        MOV  AX, 100
        JMP  @@FindError
        CALL @@WriteLN
        JMP  @@Done

      @@NoCMDLN:
        MOV  DI, OFFSET @@Instruct
        CALL @@WriteLN
        JMP  @@Done
      @@BadNumber:
        MOV  DI, OFFSET @@InvalidNumber
        CALL @@WriteLN
        JMP  @@Done

      @@FindError:  { Searchs for errorcode AX }
        MOV  DI, OFFSET @@ErrorData
      @@FindError2:
        MOV  CX, CS:[DI]
        ADD  DI, 2
        CMP  CX, AX
        JE   @@FoundError
        CMP  CX, 0
        JE   @@FoundError
      @@FindError3:
        MOV  DL, CS:[DI]
        INC  DI
        CMP  DL, 0
        JE   @@FindError2
        JMP  @@FindError3
      @@FoundError:
        CMP   CX, AX
        JNE   @@NotFound
        PUSH  DI
        MOV   DI, OFFSET  @@ErrorHeader
        CALL  @@WriteLn
        POP   DI
      @@FoundError2:
        PUSH  DI
        MOV   AL, CS:[DI]
        MOV   DI, OFFSET @@DosHeader
        CMP   AL, 0f0H
        JE    @@FoundError3
        MOV   DI, OFFSET @@BiosHeader
        CMP   AL, 0f1H
        JE    @@FoundError3
        MOV   DI, OFFSET @@TPHeader
        CMP   AL, 0f2H
        JE    @@FoundError3
        MOV   DI, OFFSET @@NoHeader
      @@FoundError3:
        CALL  @@Write
        POP   DI
        INC   DI
        CALL  @@WriteLN
        CMP   DL, 0
        JE    @@Done
        JMP   @@FoundError2
      @@NotFound:
        MOV   DI, OFFSET  @@CannotFind
        CALL  @@WriteLn
        JMP  @@Done
      @@Return:      { Write a cr/lf }
        CALL @@WriteLN
        RETN
      @@WriteLn:
        CALL @@Write
        PUSH DI
        PUSH DX
        MOV  DI, OFFSET @@CRLF
        CALL @@Write
        POP  DX
        POP  DI
        RETN
      @@Write:    { Displays a texts string at CS:[DI] ending in #0 }
      @@WriteString2:
        MOV  DL, CS:[DI]
        INC  DI
        CMP  DL, 0
        JE   @@WriteString3
        CMP  DL, 1
        JE   @@WriteString3
        MOV  AH, 02h
        INT  21h
        JMP  @@WriteString2
      @@WriteString3:
        RETN
      @@Done:
        MOV  AX, 4C00h  { AL = Exit Code }
        INT  21h
      @@ErrorData:
        DW   01h; DB 0f0h,'Invalid function number.',1
                  DB 0f1h,'Bad command: Invalid request to controller.',0
        DW   02h; DB 0f0h,'File not found.',1
                  DB 0f1h,'Bad address mark.',0
        DW   03h; DB 0f0h,'Path not found.',1
                  DB 0f1h,'Write protect: Attempted to write on write-protected diskette.',0
        DW   04h; DB 0f0h,'Too many files open.',1
                  DB 0f1h,'Sector ID bad or not found.',0
        DW   05h; DB 0f0h,'File access denied.',1
                  DB 0f1h,'Reset failed 
