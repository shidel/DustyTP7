{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}


  procedure SmallABSRead(Drive : Byte; Sector : word; Count : word; var Buf); assembler;
    asm
      MOV  AL, Drive
      CMP  AL, 0
      JNE  @SetData
      MOV  AH, 19h
      INT  21h
      INC  AL
    @SetData:
      PUSH DS
      DEC  AL
      MOV  DX, Sector
      MOV  CX, Count
      LDS  BX, Buf
      INT  25h
      JNC  @NoError
      JMP  @Done
    @NoError:
      XOR  AX, AX
    @Done:
      POP  DX
      POP  DS
      MOV  DosError, AX
    end;

  procedure SmallABSWrite(Drive : Byte; Sector : word; Count : word; var Buf); assembler;
    asm
      MOV  AL, Drive
      CMP  AL, 0
      JNE  @SetData
      MOV  AH, 19h
      INT  21h
      INC  AL
    @SetData:
      PUSH DS
      DEC  AL
      MOV  DX, Sector
      MOV  CX, Count
      LDS  BX, Buf
      INT  26h
      POP  DX
      POP  DS
      JC   @Done
      XOR  AX, AX
    @Done:
      MOV  DosError, AX
    end;

