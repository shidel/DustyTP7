{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

{ Error Codes }
const
	erNo_Error                             = 0;
	erInvalid_Function_Number              = 1;
	erFile_Not_Found                       = 2;
	erPath_Not_Found                       = 3;
	erToo_Many_Open_Files                  = 4;
	erFile_Access_Denied                   = 5;
	erInvalid_File_Handle                  = 6;
	erInsufficient_Memory                  = 8;
	erInvalid_File_Access_Code             = 12;
	erInvalid_Drive_Number                 = 15;
	erCannot_Remove_Current_Directory      = 16;
	erCannot_Rename_Across_Drives          = 17;
	erNo_More_Files                        = 18;
	erDisk_Read_Error                      = 100;
	erDisk_Write_Error                     = 101;
	erFile_Not_Assigned                    = 102;
	erFile_Not_Open                        = 103;
	erFile_Not_Open_For_Input              = 104;
	erFile_Not_Open_For_Output             = 105;
	erInvalid_Numeric_Format               = 106;
	erDisk_Is_Writeprotected               = 150;
	erBad_Drive_Request_Struct_Length      = 151;
	erDrive_Not_Ready                      = 152;
	erCRC_Error_In_Data                    = 154;
	erDisk_Seek_Error                      = 156;
	erUnknown_Media_Type                   = 157;
	erSector_Not_Found                     = 158;
	erPrinter_Out_Of_Paper                 = 159;
	erDevice_Write_Fault                   = 160;
	erDevice_Read_Fault                    = 161;
	erHardware_Failure                     = 162;
	erDivision_By_Zero                     = 200;
	erRange_Check_Error                    = 201;
	erStack_Overflow                       = 202;
	erHeap_Overflow                        = 203;
	erInvalid_Pointer_Operation            = 204;
	erFloating_Point_Overflow              = 205;
	erFloating_Point_Underflow             = 206;
	erInvalid_Floating_Point_Operation     = 207;
	erOverlay_Manager_Not_Installed        = 208;
	erOverlay_File_Read_Error              = 209;
	erObject_Not_Initialized               = 210;
	erCall_To_Abstract_Method              = 211;
	erStream_Registration_Error            = 212;
	erCollection_Index_Out_Of_Range        = 213;
	erCollection_Overflow                  = 214;
	erArithmetic_Overflow                  = 215;
	erGeneral_Protection_Fault             = 216;

{ OverlayErrors := OvrResult + erOverlay_Ofs }
	erOverlay_Ofs                          = 300;
	erOverlay_Ok                           = erOverlay_Ofs - 0;
	erOverlay_Error                        = erOverlay_Ofs - 1;
	erOverlay_Not_Found                    = erOverlay_Ofs - 2;
	erOverlay_No_Memory                    = erOverlay_Ofs - 3;
	erOverlay_IO_Error                     = erOverlay_Ofs - 4;
	erOverlay_No_EMS_Driver                = erOverlay_Ofs - 5;
	erOverlay_No_EMS_Memory                = erOverlay_Ofs - 6;
	erOverlay_No_XMS_Driver                = erOverlay_Ofs - 7;
	erOverlay_No_XMS_Memory                = erOverlay_Ofs - 8;

{ BIOS ERROR CODES }
	erBad_Address_Mark                 = 1000;
	erReset_Failure                    = erHardware_Failure;
	erDMA_Failure                      = 1002;
	erDMA_Overrun                      = 1003;
	erBad_Track                        = 1004;
	erBad_CRC                          = erCRC_Error_In_Data;
	erData_Corrected                   = 1006;
	erController_Failure               = erHardware_Failure;
	erBad_Seek                         = erDisk_Seek_Error;
	erTime_Out                         = 1009;
	erSense_Failure                    = 1010;
