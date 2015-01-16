{$F+,O-,G+}
program COM_Program_Shell;
(* COM file compiler/builder version 2.20c *)

  uses DOS, ComConst;

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
      MOV  AH, 19h
      INT  21h
      INC  AL
      MOV  [OFFSET @@DriveNum], AL
      ADD  AL, 64
      MOV  [OFFSET @@DriveLetter], AL

      MOV  DI, OFFSET @@Drive
      CALL NEAR PTR @@WriteString
      MOV  DI, OFFSET @@IsStr
      CALL NEAR PTR @@WriteString
      { Test if is a valid drive }
      MOV  AX, 4408h
      MOV  BL, [OFFSET @@DriveNum]
      INT  21h
      MOV  DI, OFFSET @@InvalidDrive
      CMP  AX, 01h
      JG   @@DoneError
      PUSH  AX

      MOV   DI, OFFSET @@ValidDrive
      CALL  NEAR PTR @@WriteString
      MOV   AX, 4409h
      MOV   BL, [OFFSET @@DriveNum]
      INT   21h
      TEST  DX, 1000h
      JZ    @@NotRemote
      MOV   DI, OFFSET @@RemoteStr
      CALL  NEAR PTR @@WriteString
    @@NotRemote:
      MOV  AX, 1500h
      XOR  BX, BX
      INT  2Fh
      MOV  DL, False
      CMP  BX, 0
      JE   @@NotCD { CDROM Multiplex not installed }
      XOR  AH, AH
      MOV  AL, [OFFSET @@DriveNum]
      INC  CX
      DEC  BX
      CMP  AX, CX
      JL   @@NotCD { Less then first CD }
      ADD  CX, BX
      CMP  AX, CX
      JG   @@NotCD { Greater then Last CD }
      MOV   DI, OFFSET @@CDROMStr
      CALL  NEAR PTR @@WriteString
    @@NotCD:
      MOV   DI, OFFSET @@DriveStr
      CALL  NEAR PTR @@WriteString

      POP   AX
      CMP   AX, 0
      JE    @@RemovableMedia
      MOV   DI, OFFSET @@FixedMedia
      CALL  NEAR PTR @@WriteString
    @@RemovableMedia:
      MOV   DI, OFFSET @@Removable
      CALL  NEAR PTR @@WriteString

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

    @@DoneError:
      CALL  NEAR PTR @@WriteString
    @@DONE:
      MOV   DI, OFFSET @@CRLF
      CALL  NEAR PTR @@WriteString
      MOV  AX, 4C00h  { AL = Exit Code }
      INT  21h

    @@DriveNum:     DB 10
    @@Drive:        DB 'Drive '
    @@DriveLetter:  DB '?'
    @@Colon:        DB ':',0
    @@IsStr:        DB ' is ',0
    @@InvalidDrive: DB 'an invalid drive.',0
    @@ValidDrive:   Db 'a valid ',0
    @@RemoteStr:    DB 'network ',0
    @@CDROMStr:     DB 'CD-ROM ',0
    @@DriveStr:     DB 'drive, and is using ',0
    @@FixedMedia:   DB 'non-',0
    @@Removable:    DB 'removable media.',0
    @@CRLF:         DB 13,10,0
  end;

{$I COMASM.INC}

begin
  WriteLn ('Working...');
  CreateDriver( GetDriverName );
  Run ( GetDriverName );
  WriteLn ( 'Finished.');
end.
