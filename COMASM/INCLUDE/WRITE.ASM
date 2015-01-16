{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

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

