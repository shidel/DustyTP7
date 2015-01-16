{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

      { CS:DI = Offset to String to search for; include '=' is string;
        ES := EnvSeg; DI <> 0 then is Offset to Value }
      @@SearchENV:
        PUSHF
        PUSH SI
        PUSH CX
        PUSH DX
        { Load ES:SI with Environment Segment:0 }
        MOV  DX, PrefixSeg
        MOV  ES, DX
        MOV  DX, ES:[$2C]
        MOV  ES, DX
        MOV  SI, 0
        { Display }
      @@SearchENV2:
        MOV  CX, 0
        PUSH DI
      @@SearchENV3:
        MOV  DH, CS:[DI]
        MOV  DL, ES:[SI]
        INC  SI
        INC  DI
        CMP  DL, 0
        JE   @@SearchENV4
        INC  CX
        CMP  DH, 0
        JE   @@SearchENV4
        CMP  DH, DL
        JNE  @@SearchENV4
        JMP  @@SearchENV3
      @@SearchENV4:
        POP  DI
        CMP  DH, 0
        JE   @@SearchENV7
        CMP  CX, 0
        JE   @@SearchENV6
      @@SearchENV5:
        CMP  DL, 0
        JE   @@SearchENV2
        MOV  DL, ES:[SI]
        INC  SI
        JMP  @@SearchENV5
      @@SearchENV6:
        MOV  SI, 1
      @@SearchENV7:
        DEC  SI
        MOV  DI, SI
        POP  DX
        POP  CX
        POP  SI
        POPF

