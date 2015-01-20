{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

program PC_Keyboard_Driver;
(* External loadable code compiler/builder version 2.20 *)

  procedure Driver; assembler;
    asm
      JMP  @@CodeStart  { Jump to start of code }
      DB   7,'JES-DRV'  { Driver file format ID string }
      DB   1            { Driver compatibility byte }
    @@CodeStart:
      CMP  AH, 03h
      JLE  @@OkDone
      CMP  AH, 05h
      JE   @@GetDriverName
      JL   @@GetDriverVersion
      CMP  AH, 06h
      JE   @@GetCopyWrite

      CMP  AH, 0Dh
      JE   @@SetRate
      JG   @@InvalidFunction
      CMP  AH, 0Bh
      JE   @@Keypressed
      JG   @@GetShiftStatus
      CMP  AH, 0Ah
      JE   @@ReadKeystroke

    @@InvalidFunction:
      MOV  AX, 0001h { invalid function number }
      RETF

    @@Initialize: { fn 0 }
    @@Shutdown: { fn 1 }
    @@StatusIdle: { fn 2 }
    @@Reinitialize: { fn 3 }
    @@GetDriverVersion: { fn 4 }
      MOV  CX, CS:[OFFSET @@DriverVersion]
      JMP  @@OkDone
    @@GetDriverName: { fn 5 }
      PUSH CS
      POP  ES
      MOV  DI, OFFSET @@DriverName
      JMP  @@OkDone
    @@GetCopyWrite: { fn 6 }
      PUSH CS
      POP  ES
      MOV  DI, OFFSET @@CopyWrite
      JMP  @@OkDone

    @@ReadKeystroke: { fn 0a }
      MOV  AH, 00h
      INT  16h
      CMP  AL, 0
      JE   @@ReadKeystroke2
      XOR  AH, AH
    @@ReadKeystroke2:
      MOV  CX, AX
      MOV  DX, 0000h
      JMP  @@OkDone

    @@Keypressed: { fn 0b }
      MOV  AH, 01h
      INT  16h
      MOV  CX, False
      JZ   @@OkDone
      MOV  CX, True
      JMP  @@OkDone

    @@GetShiftStatus:
      MOV  AH, 02h
      INT  16h
      MOV  CL, AL
      MOV  CH, 0
      { JMP  @@OkDOne }

    @@SetRate:

    @@OkDone:
      XOR  AX, AX { no errors }
    @@Done:
      RETF

    @@DriverVersion:  DW 0300h
    @@DriverName:     DB 27,'Standard PC Keyboard Driver'
    @@CopyWrite:      DB 0
    end;

{ Following Code is required to generate the driver file, and is not included
  in the actual file.  }

  procedure DriverEnd; assembler; asm end;

  function GetDriverName : string;
    var
      P : Byte;
      S : String;
    begin
      S := ParamStr(0);
      P := Length(S);
      While (P > 1) and (S[P] <> '\') do Dec ( P );
      Delete (S, 1, P - 1);
      GetDriverName := Copy (S, 1, Pos('.', S) ) + 'DRV';
    end;

  procedure CreateDriver( FileName : String );
  { This procedure Generates then driver file. }
    function GetPtr ( TPtr : Pointer ) : Pointer;
      begin
        GetPtr := Pointer(LongInt(TPtr));
      end;
    function GetSize ( FPtr, SPtr : Pointer ) : LongInt;
      begin
        GetSize := LongInt(SPtr) - LongInt(FPtr) - 1;
      end;
    var
      F : File;
    begin
      if System.Ofs(GetPtr(@Driver)^) <> 0 then
        begin
          System.WriteLn ( 'PSP segment is not alligned on a segment, cannot create COM file.');
          System.RunError ( 204 );
        end;
      System.Assign(F, FileName);
      System.ReWrite(F,1);
      System.BlockWrite(F, GetPtr(@Driver)^, GetSize(GetPtr(@Driver), GetPtr(@DriverEnd)));
      System.Close(F);
      System.WriteLn ( FileName, ' created.' );
    end;

begin
  CreateDriver( GetDriverName );
end.
