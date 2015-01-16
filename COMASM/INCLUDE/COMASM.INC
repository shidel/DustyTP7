{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

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
      System.WriteLn ( 'Created (', FileName, '), ',
        GetSize(GetPtr(@COM), GetPtr(@COMEnd)), ' bytes.' );
    end;

  function ChrStr( ALen : byte; AChar : Char ) : String; assembler;
    asm
      LES DI, @Result
      CLD
      XOR CX, CX
      MOV AL, ALen
      STOSB
      MOV CL, AL
      MOV AL, AChar
      REP STOSB
    end;

  function ErrorMsg ( AError : integer ) : String;
    var
      Error : String;
    begin
      Case AError of
        erNone                             : Error := 'No error';
        erInvalid_Function_Number          : Error := 'Invalid function number';
        erFile_Not_Found                   : Error := 'File not found';
        erPath_Not_Found                   : Error := 'Path not found';
        erToo_Many_Open_Files              : Error := 'Too many open files';
        erFile_Access_Denied               : Error := 'File access denied';
        erInvalid_File_Handle              : Error := 'Invalid file handle';
        erNot_enough_Memory                : Error := 'Not enough memory';
        erInvalid_File_Access_Code         : Error := 'Invalid file access code';
        erInvalid_Drive_Number             : Error := 'Invalid drive number';
        erCannot_Remove_Current_Directory  : Error := 'Cannot remove current directory';
        erCannot_Rename_Across_Drives      : Error := 'Cannot rename across drives';
        erNo_More_Files                    : Error := 'No more files';
        erDisk_Read_Error                  : Error := 'Disk read error';
        erDisk_Write_Error                 : Error := 'Disk write error';
        erFile_Not_Assigned                : Error := 'File not assigned';
        erFile_Not_Open                    : Error := 'File not open';
        erFile_Not_Open_For_Input          : Error := 'File not open for input';
        erFile_Not_Open_For_Output         : Error := 'File not open for output';
        erInvalid_Numeric_Format           : Error := 'Invalid numeric format';
        erDisk_Is_Write_protected          : Error := 'Disk is write-protected';
        erBad_Drive_Request_Struct_Length  : Error := 'Bad drive request struct length';
        erDrive_Not_Ready                  : Error := 'Drive not ready';
        erCRC_Error_In_Data                : Error := 'CRC error in data';
        erDisk_Seek_Error                  : Error := 'Disk seek error';
        erUnknown_Media_Type               : Error := 'Unknown media type';
        erSector_Not_Found                 : Error := 'Sector Not Found';
        erPrinter_Out_Of_Paper             : Error := 'Printer out of paper';
        erDevice_Write_Fault               : Error := 'Device write fault';
        erDevice_Read_Fault                : Error := 'Device read fault';
        erHardware_Failure                 : Error := 'Hardware failure';
        erDivision_By_Zero                 : Error := 'Division by zero';
        erRange_Check_Error                : Error := 'Range check error';
        erStack_Overflow_Error             : Error := 'Stack overflow error';
        erHeap_Overflow_Error              : Error := 'Heap overflow error';
        erInvalid_Pointer_Operation        : Error := 'Invalid pointer operation';
        erFloating_Point_Overflow          : Error := 'Floating point overflow';
        erFloating_Point_Underflow         : Error := 'Floating point underflow';
        erInvalid_Floating_Point_Operation : Error := 'Invalid floating point operation';
        erOverlay_Manager_Not_Installed    : Error := 'Overlay manager not installed';
        erOverlay_File_Read_Error          : Error := 'Overlay file read error';
        erObject_Not_Initialized           : Error := 'Object not initialized';
        erCall_To_Abstract_Method          : Error := 'Call to abstract method';
        erStream_Registration_Error        : Error := 'Stream registration error';
        erCollection_Index_Out_Of_Range    : Error := 'Collection index out of range';
        erCollection_Overflow_Error        : Error := 'Collection overflow error';
        erArithmetic_Overflow_Error        : Error := 'Arithmetic overflow error';
        erGeneral_Protection_Fault         : Error := 'General Protection fault';
      else
        Error := 'Unrecognized error code';
      end;
      ErrorMsg := Error;
    end;

  procedure Run ( FileName : String );
    var
      S : String;
      I : integer;
    begin
      S := '';
      for I := 1 to ParamCount do
        S := S + ParamStr(I) + ' ';
      if Length(S) > 0 then Dec(Byte(S[0]));
      WriteLn ( 'Execution parameters are "', S, '".');
      WriteLn ( 'Executing (', FileName, ').' );
      Write(ChrStr(80, #177));
      Exec(GetDriverName, S);
      Write(ChrStr(80, #177));
      I := DosExitCode;
      WriteLn ('Dos exit code was #', I, ', "', ErrorMsg(I), '".');
    end;

