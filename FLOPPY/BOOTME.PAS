{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

program Device_Driver_Shell;
(* External loadable code compiler/builder version 2.20 *)

  procedure Com; far; assembler;
    asm
{      DD 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      DD 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
      JMP @Main
      DB  'JES DISK'
      DW  512
      DB  1
      DW  1
      DB  1
      DW  224
      DW  2880
      DB  0F0h
      DW  9
      DW  18
      DW  2
      DW  0
      dw  0,0,0,0,0,0,0
    @Main:
      MOV  SI, OFFSET @HelloMsg
      MOV  AX, $B800
      MOV  ES, AX
      MOV  DI, 0
    @WriteStr:
      MOV  AH, CS:[SI]
      INC  SI
    @WriteStr2:
      MOV  AL, CS:[SI]
      INC  SI
      CMP  AL, 0
      JE   @WriteStr3
      MOV  ES:[DI], AX
      ADD  DI, 2
      JMP  @WriteStr2
    @WriteStr3:
(*      MOV  AX, 4C00h  { AL = Exit Code }
      INT  21h *)
      JMP  @WriteStr3
      { RET }
      JMP DWORD PTR CS:[OFFSET @@PostJmpCodePtr]
    @@PostJmpCodePtr: DD 0FFFF0000h

    @HelloMsg:
      DB $1F
      DB '        ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป         '
      DB '        บ  HUNH version 2.00a                     Free-Software 1994  บ         '
      DB '        ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ         '
      DB '                                                                                '
      DB '           Sorry but your system is not authorized to boot this disk.           '
      DB 0

    @Stack:
      Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      Db 0,0,0,0,0,0,0,0,0,0,0,0
    @StackEnd:
      Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      Db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      Db 0,0,0,0,0,0,0,0,0,0,0,0

    end;

{ Following Code is required to generate the COM file, and is not included
  in the actual file.  }

  procedure ComEnd; assembler; asm end;

  const
    COMOfs = $0000;
    COMExt = 'BIN';

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