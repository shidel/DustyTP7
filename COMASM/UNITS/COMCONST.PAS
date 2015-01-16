{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

unit ComConst;

interface

  const
  { PSP Offsets }
    INT_20         = $0000;
    Memory_Top     = $0002;
    Reserved_1     = $0004;
    OpCode         = $0005;
    Segment_Size   = $0006;
    Terminate      = $000A;
    Control_Break  = $000E;
    Critical_Error = $0012;
    Reserved_2     = $0016;
    Env_Segment    = $002C;
    Reserved_3     = $002E;
    Dos_Call       = $0050;
    Reserved_4     = $0052;
    FCB_1          = $005C;
    FCB_2          = $006C;
    Command_Line   = $0080;

  { Register Flag Constants }
    fCarry     = $0001;
    fParity    = $0004;
    fAuxiliary = $0010;
    fZero      = $0040;
    fSign      = $0080;
    fOverflow  = $0800;

  { File mode magic numbers }
    fmClosed = $D7B0;
    fmInput  = $D7B1;
    fmOutput = $D7B2;
    fmInOut  = $D7B3;

  { File attribute constants }
    faReadOnly  = $01;
    faHidden    = $02;
    faSysFile   = $04;
    faVolumeID  = $08;
    faDirectory = $10;
    faArchive   = $20;
    faAnyFile   = $3F;

  { Maximum file name component string lengths }
    fsPathName  = 79;
    fsDirectory = 67;
    fsFileName  = 8;
    fsExtension = 4;

  { FileSplit return flags }
    fcExtension = $0001;
    fcFileName  = $0002;
    fcDirectory = $0004;
    fcWildcards = $0008;

  { Error codes }
    erNone                             = 0;
    erInvalid_function_number          = 1;
    erFile_not_found                   = 2;
    erPath_not_found                   = 3;
    erToo_many_open_files              = 4;
    erFile_access_denied               = 5;
    erInvalid_file_handle              = 6;
    erNot_enough_memory                = 8;
    erInvalid_environment              = 10;
    erInvalid_format                   = 11;
    erInvalid_file_access_code         = 12;
    erInvalid_drive_number             = 15;
    erCannot_remove_current_directory  = 16;
    erCannot_rename_across_drives      = 17;
    erNo_more_files                    = 18;
    erDisk_read_error                  = 100;
    erDisk_write_error                 = 101;
    erFile_not_assigned                = 102;
    erFile_not_open                    = 103;
    erFile_not_open_for_input          = 104;
    erFile_not_open_for_output         = 105;
    erInvalid_numeric_format           = 106;
    erDisk_is_write_protected          = 150;
    erBad_drive_request_struct_length  = 151;
    erDrive_not_ready                  = 152;
    erCRC_error_in_data                = 154;
    erDisk_seek_error                  = 156;
    erUnknown_media_type               = 157;
    erSector_Not_Found                 = 158;
    erPrinter_out_of_paper             = 159;
    erDevice_write_fault               = 160;
    erDevice_read_fault                = 161;
    erHardware_failure                 = 162;
    erDivision_by_zero                 = 200;
    erRange_check_error                = 201;
    erStack_overflow_error             = 202;
    erHeap_overflow_error              = 203;
    erInvalid_pointer_operation        = 204;
    erFloating_point_overflow          = 205;
    erFloating_point_underflow         = 206;
    erInvalid_floating_point_operation = 207;
    erOverlay_manager_not_installed    = 208;
    erOverlay_file_read_error          = 209;
    erObject_not_initialized           = 210;
    erCall_to_abstract_method          = 211;
    erStream_registration_error        = 212;
    erCollection_index_out_of_range    = 213;
    erCollection_overflow_error        = 214;
    erArithmetic_overflow_error        = 215;
    erGeneral_Protection_fault         = 216;

implementation

end.