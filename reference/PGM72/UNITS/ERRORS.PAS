{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
unit Errors;

interface

  {$I ErConst.inc}

  function ErrorStr(StrID : word) : String;

implementation

  function ErrorStr(StrID : word) : String;
    var
      S : String;
    begin
      case StrId of
           0 : S := 'No error';
           1 : S := 'Invalid function number';
           2 : S := 'File not found';
           3 : S := 'Path not found';
           4 : S := 'Too many files open';
           5 : S := 'File access denied';
           6 : S := 'Invalid file handle';
           7 : S := 'User terminated';
           8 : S := 'Insufficient memory';
           9 : S := 'Mouse not found';
          10 : S := 'Internal error';
          12 : S := 'Invalid file access code';
          15 : S := 'Invalid drive number';
          16 : S := 'Cannot remove current directory';
          17 : S := 'Cannot rename across drives';

          19 : S := 'File already exists';

         100 : S := 'Disk read error';
         101 : S := 'Disk write error';
         102 : S := 'File not assigned';
         103 : S := 'File not open';
         104 : S := 'File not open for input';
         105 : S := 'File not open for output';
         106 : S := 'Invalid numeric format';
         149 : S := 'Disk full';
         150 : S := 'Disk is write-protected';
         151 : S := 'Unknown unit';
         152 : S := 'Drive not Ready';
         153 : S := 'Unknown command';
         154 : S := 'CRC error in data';
         155 : S := 'Bad drive request structure length';
         156 : S := 'Disk seek error';
         157 : S := 'Unknown media type';
         158 : S := 'Sector not found';
         159 : S := 'Printer out of paper';
         160 : S := 'Device write fault';
         161 : S := 'Device read fault';
         162 : S := 'Hardware failure';
         200 : S := 'Division by zero';
         201 : S := 'Range check error';
         202 : S := 'Stack overflow error';
         203 : S := 'Heap overflow error';
         204 : S := 'Invalid pointer operation';
         205 : S := 'Floating point overflow';
         206 : S := 'Floating point underflow';
         207 : S := 'Invalid floating point operation';
         208 : S := 'Overlay manager not installed';
         209 : S := 'Overlay file read error';
         210 : S := 'Object not initialized';
         211 : S := 'Call to abstract method';
         212 : S := 'Stream regestration error';
         213 : S := 'Collection index out of range';
         214 : S := 'Collection overflow error';

         erOverlay_Ok            : S := 'No overlay error';
         erOverlay_Error         : S := 'Overlay error';
         erOverlay_Not_Found     : S := 'Overlay file not found';
         erOverlay_No_Memory     : S := 'Insufficient memory for overlay';
         erOverlay_IO_Error      : S := 'Overlay I/O error';
         erOverlay_No_EMS_Driver : S := 'No EMS Driver installed for overlay';
         erOverlay_No_EMS_Memory : S := 'Insufficient EMS memory available for overlay';
         erOverlay_No_XMS_Driver : S := 'No XMS Driver installed for overlay';
         erOverlay_No_XMS_Memory : S := 'Insufficient XMS memory available for overlay';

(*     {XMS Errors}
       $180 : S := 'XMS function not implemented';
       $181 : S := 'VDISK device driver detected';
       $182 : S := 'A20 error';
       $18E : S := 'General XMM driver error';
       $18F : S := 'Unrecoverable XMM driver error';
       $190 : S := 'HMA does not exists';
       $191 : S := 'HMA already in use';
       $192 : S := 'Insufficient XMM size';
       $193 : S := 'HMA not allocated';
       $194 : S := 'A20 line still enabled';
       $1A0 : S := 'All XMS is allocated';
       $1A1 : S := 'XMS handles exhaused';
       $1A2 : S := 'Invalid XMS handle';
       $1A3 : S := 'Invalid XMS source handle';
       $1A4 : S := 'Invalid XMS source offset';
       $1A5 : S := 'Invalid XMS destination handle';
       $1A6 : S := 'Invalid XMS destination offset';
       $1A7 : S := 'Invalid XMS byte count';
       $1A8 : S := 'Invalid XMS overlap in move';
       $1A9 : S := 'XMS Parity Error';
       $1AA : S := 'XMS Block not locked';
       $1AB : S := 'XMS Block is locked';
       $1AC : S := 'XMS lock count overflow';
       $1AD : S := 'XMS lock failure';
       $1B0 : S := 'Smaller UMB available';
       $1B1 : S := 'No UMB''s available';
       $1B2 : S := 'Invalid UMB segment';
*)
        else
        S := 'unknown error code';
      end;
      ErrorStr := S;
    end;

end.