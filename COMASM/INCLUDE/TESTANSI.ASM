{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

    @@TestAnsi:
      PUSH DX
      PUSH DI
      MOV  DI, OFFSET @@AnsiOutStr
    @@TestAnsi2:
      MOV  DL, [DI]
      INC  DI
      CMP  DL, 0
      JE   @@TestAnsi3
      MOV  AH, $02
      INT  $21
      JMP  @@TestAnsi2
    @@TestAnsi3:
      MOV  AH, $06
      MOV  DL, $FF
      INT  $21
      JZ   @@TestAnsi5
      CMP  AL, 27
      JNE  @@TestAnsi5
      MOV  AH, $06
      MOV  DL, $FF
      INT  $21
      JZ   @@TestAnsi5
      CMP  AL, '['
      JNE  @@TestAnsi5
    @@TestAnsi4:
      MOV  AH, $06
      MOV  DL, $FF
      INT  $21
      JZ   @@TestAnsi5
      CMP  AL,'R'
      JNE  @@TestAnsi4
      MOV  AL, True
      JMP  @@TestAnsi8
    @@TestAnsi5: { Not Found }
      MOV  DI, OFFSET @@AnsiOutStr
    @@TestAnsi6:
      MOV  DL, [DI]
      INC  DI
      CMP  DL, 0
      JE   @@TestAnsi7
      MOV  AH, $02
      MOV  DL, 8
      INT  $21
      JMP  @@TestAnsi6
    @@TestAnsi7:
      MOV  AL, False
    @@TestAnsi8:
      POP  DI
      POP  DX
      RET
    @@AnsiOutStr: DB 27,'[6n',0
