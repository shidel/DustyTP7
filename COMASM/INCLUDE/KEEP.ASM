{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

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

