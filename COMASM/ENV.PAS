{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y+}
program MakeCOM;

  uses Dos, ComConst;

  procedure Com; assembler;
    asm
      @@Interupt20:          NOP; NOP;
      @@MemTop:              NOP; NOP;
      @@DosReservedArea01:   NOP;
      @@DosDispatcher:       NOP; NOP; NOP; NOP; NOP;
      @@SegAvail:            NOP; NOP;
      @@TerminateAddress:    NOP; NOP; NOP; NOP;
      @@ControlBreak:        NOP; NOP; NOP; NOP;
      @@CriticalError:       NOP; NOP; NOP; NOP;
      @@DosReservedArea02:   NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
      @@EnvSeg:              NOP; NOP;
      @@DosReservedArea03:   NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP;
      @@FormatedParamArea01: NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
      @@FormatedParamArea02: NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP;
      @@ParamString:         NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP; NOP; NOP; NOP; NOP;
                             NOP; NOP; NOP; NOP;
      { End of PSP }
        PUSH DS
        MOV  DI, OFFSET @@Title
        CALL @@WriteString

        MOV  DI, 0
        MOV  DS, [$2C]

      @@WriteENV1:
        MOV  AL, [DI]
        CMP  AL, 0
        JE   @@WriteENV2
        PUSH DS
        PUSH DI
        PUSH CS
        POP  DS
        MOV  DI, OFFSET @@Return
        CALL @@WriteString
        CALL @@WriteString
        POP  DI
        POP  DS
        CALL @@WriteString
        JMP  @@WriteENV1
      @@WriteENV2:
        POP  DS
        PUSH DI
        MOV  DI, OFFSET @@ENVSize1
        CALL @@WriteString
        POP  DI
        MOV  AX, DI
        MOV  CX, AX
        MOV  DX, AX
        AND  DX, $0F
        AND  AX, $FFF0
        CMP  DX, 0
        JE   @@WriteENV3
        ADD  AX, $10
      @@WriteENV3:
        ADD  AX, $10
        CALL @@WriteDec
        MOV  DI, OFFSET @@EnvSize2
        CALL @@WriteString
        MOV  AX, CX
        CALL @@WriteDec
        CALL @@WriteString

      @@Exit:
        MOV AX, $4C00
        INT $21

      @@WriteString: { DS:DI := points to Null Terminated String }
        PUSH AX
        PUSH DX
      @@WriteString2:
        MOV  DL, [DI]
        INC  DI
        CMP  DL, 0
        JE   @@WriteString3
        MOV  AH, $02
        INT  $21
        JMP  @@WriteString2
      @@WriteString3:
        POP  DX
        POP  AX
        RET

        { Writes the decimal equivilant of a word AX }
      @@WriteDec:
        PUSHF
        PUSH AX
        PUSH DX
        PUSH CX
        MOV  DX, $00FF { Terminator }
        MOV  CX, $000A { Divisor }
        PUSH DX
      @@WriteDec2:
        CMP  AX, CX
        JNB  @@WriteDec4
        CMP  DX, $00FF
        JE   @@WriteDec3
        CMP  AX, 0
        JE   @@WriteDec5
      @@WriteDec3:
        PUSH AX
        JMP  @@WriteDec5
      @@WriteDec4:
        XOR  DX, DX
        DIV  CX
        PUSH DX
        JMP  @@WriteDec2
      @@WriteDec5:
        POP  DX
        CMP  DX, $00FF
        JE   @@WriteDec6
        MOV  AH, $02
        ADD  DL, $30
        INT  $21
        JMP  @@WriteDec5
      @@WriteDec6:
        POP  CX
        POP  DX
        POP  DX
        POPF
        RET
      @@Title:
        DB 13,10,'Current enviroment variable settings:',13,10,0
      @@Return:
        DB 13,10,0
        DB 32,32,0
      @@EnvSize1:
        DB 13,10,13,10,'Environment variable table uses ',0
      @@EnvSize2:
        DB ' bytes (',0
        DB ' bytes of data).',13,10,0
    end;

{$I COMASM.INC}

begin
  WriteLn ('Working...');
  CreateDriver( GetDriverName );
  WriteLn ( 'Finished.');
end.
