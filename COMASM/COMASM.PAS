{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

program COM_Program_Shell;
(* COM file compiler/builder version 2.20c *)

  procedure Com; far; assembler;
    asm
      @@PSP:
      @INT_20:         DB  90h,90h
      @MEMORY_TOP:     DB  90h,90h
      @RESERVED_1:     DB  90h
      @OPCODE:         DB  90h
      @SEGMENT_SIZE:   DB  90h,90h,90h,90h
      @TERMINATE:      DB  90h,90h,90h,90h
      @CONTROL_BREAK:  DB  90h,90h,90h,90h
      @CRITICAL_ERROR: DB  90h,90h,90h,90h
      @RESERVED_2:     DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h
      @ENV_SEGMENT:    DB  90h,90h
      @RESERVED_3:     DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h
      @DOS_CALL:       DB  90h,90h
      @RESERVED_4:     DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
      @FCB_1:          DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h
      @FCB_2:          DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h
      @COMMAND_LINE:   DB  90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
                       DB  90h,90h,90h,90h,90h,90h,90h,90h,90h,90h
    @@PSP_END:

        MOV  DI, OFFSET @@Text
      @@WriteString2:
        MOV  DL, CS:[DI]
        INC  DI
        CMP  DL, 0
        JE   @@WriteString3
        MOV  AH, 02h
        INT  21h
        JMP  @@WriteString2
      @@WriteString3:
        MOV  AX, 4C00h  { AL = Exit Code }
        INT  21h
      @@Text:
        DB 'This is a very simple COM program.',13,10,0
  end;

{ Following Code is required to generate the COM file, and is not included
  in the actual file.  }

  procedure ComEnd; assembler; asm end;

  const
    COMOfs = $0100;
    COMExt = 'COM';

  function GetDriverName : string;
    var
      P : Byte;
      S : String;
    begin
      S := ParamStr(0);
      P := Length(S);
      While (P > 0) and (S[P] <> '\') do Dec ( P );
      Delete (S, 1, P);
      GetDriverName := Copy (S, 1, Pos('.', S) ) + COMExt;
    end;

  procedure CreateDriver( FileName : String );
  { This procedure Generates then driver file. }
    function GetPtr ( TPtr : Pointer ) : Pointer;
      begin
        GetPtr := Pointer(LongInt(TPtr) + COMOfs);
      end;
    function GetSize ( FPtr, SPtr : Pointer ) : LongInt;
      begin
        GetSize := LongInt(SPtr) - LongInt(FPtr) - 1 - COMOfs;
      end;
    var
      F : File;
    begin
      if System.Ofs(GetPtr(@COM)^) <> COMOfs then
        begin
          System.WriteLn ( 'PSP segment is not alligned on a segment, cannot create COM file.');
          System.RunError ( 204 );
        end;
      System.Assign(F, FileName);
      System.ReWrite(F,1);
      System.BlockWrite(F, GetPtr(@COM)^, GetSize(GetPtr(@COM), GetPtr(@COMEnd)));
      System.Close(F);
      System.WriteLn ( FileName, ' created.' );
    end;

begin
  CreateDriver( GetDriverName );
end.