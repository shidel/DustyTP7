{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

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
