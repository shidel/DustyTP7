{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

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
      CLC
    @@Str2Word07:
      POP  BX
      POP  CX
      POP  DX
      POP  DI
      RET

