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
    { CS, DS, ES, SS are same as PSP }
    asm
      { PSP start--Note this part is not included in com file}
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
        JMP @@Install
      @@OldTimer:  DW $0000,$0000
      @@UseMouse:  DB False
      @@DelayTime: DW $0885 { About 2 minutes }
      @@CurrTime:  DW $0000 { Will automatically be set to Delay time }
      @@LastHead:  DW $0000 { $041A }
      @@LastTail:  DW $0000 { $041C }
      @@LastX:     DW $0000
      @@LastY:     DW $0000
      @@LastBut:   DW $0000

      @@NewTimer:
        CLI
        PUSHF
        PUSH BX
        PUSH AX
        PUSH ES
        PUSH DS
        PUSH DI
        PUSH CS
        POP  DS
        MOV  DI, False { Motion flag }
        MOV  ES, DI    { Set Seg of ES to 0000 }
      @@TestTail:
        MOV  AX, ES:[$041C]
        CMP  [OFFSET @@LastTail], AX
        MOV  [OFFSET @@LastTail], AX
        JE   @@TestHead
        MOV  DI, True
      @@TestHead:
        MOV  AX, ES:[$041A]
        CMP  [OFFSET @@LastHead], AX
        MOV  [OFFSET @@LastHead], AX
        JE   @@TestMouse
        MOV  DI, True
      @@TestMouse:
        MOV  AL, False
        CMP  [OFFSET @@UseMouse], AL
        JE   @@TestOver
        PUSH DX
        PUSH CX
        MOV  AX, $0003
        INT  $33
        CMP  [OFFSET @@LastBut], BX
        MOV  [OFFSET @@LastBut], BX
        JE   @@TestX
        MOV  DI, True
      @@TestX:
        CMP  [OFFSET @@LastX], CX
        MOV  [OFFSET @@LastX], CX
        JE   @@TestY
        MOV  DI, True
      @@TestY:
        CMP  [OFFSET @@LastY], DX
        MOV  [OFFSET @@LastY], DX
        JE   @@MouseDone
        MOV  DI, True
      @@MouseDone:
        POP  CX
        POP  DX
      @@TestOver:
        CMP  DI, False
        JE   @@NoChange
        MOV  AX, [OFFSET @@CurrTime]
        CMP  AX, 0
        JNE  @@ResetCount
        MOV  AX, $1200 { Screen On }
        MOV  BL, $36
        INT  $10
      @@ResetCount:
        MOV  AX, [OFFSET @@DelayTime]
        MOV  [OFFSET @@CurrTime], AX
        JMP  @@Done
      @@NoChange:
        MOV  AX, [OFFSET @@CurrTime]
        CMP  AX, 0
        JE   @@Done
        DEC  AX
        MOV  [OFFSET @@CurrTime], AX
        CMP  AX, 0
        JNE  @@Done
        MOV  AX, $1201 { Screen Off }
        MOV  BL, $36
        INT  $10
      @@Done:
        POP  DI
        POP  DS
        POP  ES
        POP  AX
        POP  BX
        POPF
        PUSHF
        CALL DWORD PTR CS:[OFFSET @@OLDTimer]
        STI
        RETF 2
{----------------------------------------------------------------------------}
      @@Keep: {All Code beyond this Label is lost.}
        CALL @@FreeENVSeg
        MOV DX, OFFSET @@KEEP
        MOV CX, DX
        AND CX, $0F
        SHR DX, 1
        SHR DX, 1
        SHR DX, 1
        SHR DX, 1
        CMP CX, 0
        JE  @@Keep2
        INC DX
      @@Keep2:
        MOV AX, $3100
        INT $21

      @@FreeENVSeg:
        PUSH ES
        PUSH AX
        MOV  ES, [$002C] { Enviroment Variable Segment }
        MOV  AX, $4900
        INT  $21
        POP  AX
        POP  ES
        RET
{----------------------------------------------------------------------------}
      @@Install:
        MOV  AX, $1200 { Screen On/$1201 Screen Off }
        MOV  BL, $36
        INT  $10
        CMP  AL, $12
        JNE  @@NoVga
        { Relocate INT 8 to INT AL }
        PUSH DS
        PUSH AX
        MOV  AX, $3508
        INT  $21
        MOV  CS:[OFFSET @@OldTimer + 0], BX
        MOV  CS:[OFFSET @@OldTimer + 2], ES
        POP  AX
        POP  DS
        { Install New INT 8 }
        MOV  DX, OFFSET @@NewTimer
        MOV  AX, $2508
        INT  $21
        { Check Params }
        CALL @@SetDelay
        { Test for Mouse }
        MOV  AX, 0
        INT  $33
        MOV  DI, OFFSET @@NoMouse
        CMP  AX, $0000
        JE   @@InstallComplete
        MOV  AL, True
        MOV  CS:[OFFSET @@UseMouse], AL
        MOV  DI, OFFSET @@MouseFound
        { Display and Terminate }
      @@InstallComplete:
        CALL @@WriteString
        MOV  DI, OFFSET @@NoError
        CALL @@WriteString
        JMP  @@Keep

      @@NoVector:
        POP  ES
        MOV  DI, OFFSET @@RelocateError
        CALL @@WriteString
        JMP  @@Exit
      @@NoVga:
        MOV  DI, OFFSET @@VGAError
        CALL @@WriteString

      @@Exit:
        MOV  DI, OFFSET @@InstallError
        CALL @@WriteString
        MOV  AX, $4C00
        INT  $21

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

      @@RelocateError:
        DB 'No Available interrupts.  ',0
      @@VgaError:
        DB 'Incompatable video card.  ',0
      @@InstallError:
        DB 'Unable to install screen blanker.',13,10,13,10,0
      @@NoError:
        DB 'Screen Blanker version 2.00 installed.',13,10,13,10,0
      @@NoMouse:
        DB 'Mouse not found.  ',0
      @@MouseFound:
        DB 'Mouse found.  ',0
      @@ParamError:
        DB 'Invalid parameter, default of 2 minutes used.  ',13,10,0
      @@RangeError:
        DB 'Time is out of range, must be 1 to 30 minutes, defualt of 2 minutes used.',13,10,0

      @@SetDelay:
        MOV  BH, 0
        MOV  BL, [$0080]
        MOV  [BX + $0081], BH
        CMP  BL, 1
        JA   @@GetParam
        RET
      @@GetParam:
        MOV  DI, $82
        CALL @@Str2Word
        JNC  @@CheckParam
        MOV  DI, OFFSET @@ParamError
        CALL @@WriteString
        RET
      @@CheckParam:
        CMP  AX, 0
        JE   @@BadParam
        CMP  AX, 30
        JA   @@BadParam
        MOV  CX, AX
        MOV  AX, 1091
        MUL  CX
        MOV  CS:[OFFSET @@DelayTime], AX
        RET
      @@BadParam:
        MOV  DI, OFFSET @@RangeError
        CALL @@WriteString
        RET

    { CALL    @@STR2WORD

      INPUT-- DS:DI Point to null terminated string
      OUTPUT- CF = 0 then AX Result
              CF = 1 then AX Error Offset

      All registers except AX are preserved }
    @@Str2Word:
      PUSH DI
      PUSH DX
      PUSH CX
      PUSH BX
      XOR  DX, DX
      XOR  AX, AX
      MOV  BX, $000A
      MOV  CH, $00
      MOV  CL, [DI]
      CMP  CL, '$'
      JNE  @@Str2Word02
      MOV  BL, $10
      INC  DI
    @@Str2Word02:
      MOV  CL, [DI]
      INC  DI
      CMP  CL, $00
      JE   @@Str2Word06
      SUB  CL, $30
      CMP  CL, $09
      JA   @@Str2Word04
    @@Str2Word03:
      MUL  BX
      ADD  AX, CX
      JC   @@Str2Word05
      CMP  DX, $0000
      JNE  @@Str2Word05
      JMP  @@Str2Word02
    @@Str2Word04:
      CMP  BL, $10
      JNE  @@Str2Word05
      CMP  CL, $10
      JNA  @@Str2Word05
      CMP  CL, $16
      JA   @@Str2Word05
      SUB  CL, $07
      JMP  @@Str2Word03
    @@Str2Word05:
      MOV  AX, DI
      STC
      JMP  @@Str2Word07
    @@Str2Word06:
      CLI
    @@Str2Word07:
      POP  BX
      POP  CX
      POP  DX
      POP  DI
      RET
    end;
    
    
{$I COMASM.INC}

begin
  WriteLn ('Working...');
  CreateDriver( GetDriverName );
  WriteLn ( 'Finished.');
end.
