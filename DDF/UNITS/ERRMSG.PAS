{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
unit ErrMsg; { version 2.20a }

{ This unit contains many error constants, with funtions to return the
  appropriate error discription. }

interface

  uses ErConst;

  function ErMsg ( AError : integer ) : String;

implementation

  function ErMsg( AError : integer ) : String;
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
        erNot_enough_memory                : Error := 'Not enough memory';
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
        erHeap_Overflow_error              : Error := 'Heap overflow error';
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
        erCollection_Overflow_error        : Error := 'Collection overflow error';
        erArithmetic_Overflow_error        : Error := 'Arithmetic overflow error';
        erGeneral_Protection_Fault         : Error := 'General Protection fault';
      else
        Error := 'Unrecognized error code';
      end;
      ErMsg := Error;
    end;
end.