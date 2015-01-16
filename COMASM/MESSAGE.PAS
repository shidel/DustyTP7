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
        MOV  DI, OFFSET @@Message
        { INC  DI; 2015 Bug Fix }
        CALL @@WriteString
        JMP  @@Exit

      @@Exit:
        MOV AX, $4C00
        INT $21

      @@WriteString: { DS:DI := points to Null Terminated String }
        PUSH AX
        PUSH DX
        PUSH DI
      @@WriteString2:
        MOV  DL, [DI]
        INC  DI
        CMP  DL, 0
        JE   @@WriteString3
        MOV  AH, $02
        INT  $21
        JMP  @@WriteString2
      @@WriteString3:
        POP  DI
        POP  DX
        POP  AX
        RET

      @@Message:
      	DB 	'Hello World!',13,10,0
    end;

{$I COMASM.INC}

begin
  WriteLn ('Working...');
  CreateDriver( GetDriverName );
  WriteLn ( 'Finished.');
end.
