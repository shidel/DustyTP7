{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

      { 
	MOV  AH, Attribute
	MOV  AL, Character 
	CALL @@ClrScr

	Clears the Screen According to Columns and Rows fields in the BIOS
	  Variable table.  Requires EGA and Color Video }
      }	
	ClrScr: 
        PUSH DS               { Preserve registers }
        PUSH CX
        PUSH DX
        PUSH DI
        PUSH AX               { Store Character/Attribute }
        MOV  AX, $0040        { Load BIOS variable Segment }
        MOV  ES, AX
        MOV  AX, ES:[$004A]   { Get Columns Count }
        MOV  CL, ES:[$0084]   { Get Row Count - 1 }
        INC  CL
        MUL  CL               { Compute total characters to write }
        MOV  CX, AX           { Store total Count in CX }
        POP  AX               { Restore Character Attribute }
        MOV  DX, $B800        { Load Video Segment into DS }
        MOV  DS, DX
        MOV  DI, $0000        { Set Write offset to 0 }
      @@ClrScr2:              { Fill Screen with Character/Attribute }
        MOV  [DI], AX
        ADD  DI, 2
        LOOP @@CLRSCR2;       { if not finished jmp ClrScr2 }
        POP  DI               { Restore Registers }
        POP  DX
        POP  CX
        POP  DS
        RET

