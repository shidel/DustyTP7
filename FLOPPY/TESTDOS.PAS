{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

program TestDosExtUnit;

uses QCrt, BIOS, Dos, DosExt, StrAsm;

  var
    Drive, Head, Track, Sector : word;

begin
  Drive := 2;
  WriteLn('FLOPPY DRIVES: ', Diskettes);
  WriteLn('Reset  ', ResetDrive(Drive), ':', BIOSError);
  GetDriveParams(Drive, Head, Track, Sector );
  WriteLn(Head, '/', Track, '/', Sector);
{  WriteLn(LongInt(Head + 1) * LongInt(Track + 1) * LongInt(Sector) * GetSectorSize(Drive) / (1024 * 1000):1:2);}
  WriteLn(ChangeLineSupport(Drive), ':', BIOSError);
  writeLn;
end.
