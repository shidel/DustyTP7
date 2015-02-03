{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

unit Errors;

interface

   function ErrorMessage (ErrorCode : Integer) : String;

implementation

function ErrorMessage (ErrorCode : Integer) : String;
   var
     Em : String;
   begin
      Case ErrorCode of
           0 : Em := 'No Error';
           1 : Em := 'Invalid function number';
           2 : Em := 'File not found';
           3 : Em := 'Path not found';
           4 : Em := 'Too many files open';
           5 : Em := 'File access denied';
           6 : Em := 'Invalid file handle';
          12 : Em := 'Invalid file access code';
          15 : Em := 'Invalid drive number';
          16 : Em := 'Cannot remove current directory';
          17 : Em := 'Cannot rename across drives';
         100 : Em := 'Disk read error';
         101 : Em := 'Disk write error';
         102 : Em := 'File not assigned';
         103 : Em := 'File not open';
         104 : Em := 'File not open for input';
         105 : Em := 'File not open for output';
         106 : Em := 'Invalid numeric format';
         150 : Em := 'Disk is write-protected';
         151 : Em := 'Unknown unit';
         152 : Em := 'Drive not Ready';
         153 : Em := 'Unknown command';
         154 : Em := 'CRC error in data';
         155 : Em := 'Bad drive request structure length';
         156 : Em := 'Disk seek error';
         157 : Em := 'Unknown media type';
         158 : Em := 'Sector not found';
         159 : Em := 'Printer out of paper';
         160 : Em := 'Device write fault';
         161 : Em := 'Device read fualt';
         162 : Em := 'Hardware failure';
         200 : Em := 'Division by zero';
         201 : Em := 'Range check error';
         202 : Em := 'Stack overflow error';
         203 : Em := 'Heap overflow error';
         204 : Em := 'Invalid pointer operation';
         205 : Em := 'Floating point overflow';
         206 : Em := 'Floating point underflow';
         207 : Em := 'Invalid floating point operation';
         208 : Em := 'Overlay manager not installed';
         209 : Em := 'Overlay file read error';
         210 : Em := 'Object not initialized';
         211 : Em := 'Call to abstract method';
         212 : Em := 'Stream regestration error';
         213 : Em := 'Collection index out of range';
         214 : Em := 'Collection overflow error';
      else
         Em := 'Unknown error'
      end;
      ErrorMessage := Em;
   end;

end.

