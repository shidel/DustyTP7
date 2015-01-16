{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

      {Displays a Byte in Hexidecimal}
      @@WriteByte: { AL = Byte }
        PUSHF
        PUSH AX
        PUSH DX
        PUSH CX
        MOV  CX, AX
        MOV  AH, $02
        MOV  DL, CL
        SHR  DL, 1
        SHR  DL, 1
        SHR  DL, 1
        SHR  DL, 1
        CALL @@WriteByte2
        MOV  DL, CL
        AND  DL, $0F
        CALL @@WriteByte2
        POP  CX
        POP  DX
        POP  AX
        POPF
        RET
      @@WriteByte2:
        CMP  DL, $0A
        JB  @@WriteByte3
        ADD  DL, $07
      @@WriteByte3:
        ADD  DL, $30
        INT  $21
        RET

      {Displays a word in Hexidecimal }
      @@WriteWord: { AX = Word }
        PUSH AX
        PUSH AX
        MOV  AL, AH
        CALL @@WriteByte
        POP  AX
        CALL @@WriteByte
        POP  AX
        RET
