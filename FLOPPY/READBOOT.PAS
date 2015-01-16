{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

program ReadBootSector;

  uses QCrt, Bios, StrAsm;

  type
    TFBS = record
      JMP : array[0..2] of byte;
      OEM : array[0..7] of char;
      SectSize : word;
      ClustSize : byte;
      ResSecs : word;
      FatCnt : byte;
      RootSize : word;
      TotSecs : word;
      Media : byte;
      FatSize : word;
      TrkSize : word;
      HeadCnt : word;
      HidnSecs: word;
      Data:array[0..480] of byte;
    end;

  var
    Drive : byte;
    Buf : array [0..18,0..511] of byte;
    PBS : ^TFBS;
    Try : byte;
    C   : word;
    F   : File;
    I   : word;


begin
  Drive := 1;
  Try := 0;
  repeat
    Inc(Try);
    ResetDrive(Drive);
    ReadSectors(Drive, 0, 0, 1, 1, Buf);
    if (BIOSError <> 0) and (Try < 3) then Delay(500);
  until (Try = 3) or (BIOSError = 0);
  if BiosError <> 0 then
    begin
      WriteLn('ERROR #', BiosError);
      Halt(1);
    end;
  C := MemW[Seg(Buf):Ofs(Buf) + $18] - 1;
  PBS := @Buf;
  Write ( 'OEM: "');
  for I := 0 to 7 do Write(PBS^.OEM[I]);
  WriteLn('"');
  WriteLn('Bytes per sector: ', PBS^.SectSize);
  WriteLn('Sectors per cluster: ', PBS^.ClustSize);
  WriteLn('Reserved Sectors: ', PBS^.RESSecs);
  WriteLn('File Allocation Tables: ', PBS^.FatCnt);
  WriteLn('Max Root Dir Entries: ', PBS^.RootSize);
  WriteLn('Total Sectors: ', PBS^.TotSecs);
  WriteLn('Media Discriptor: ', LCase(HexByte(PBS^.Media)) + 'H');
  WriteLn('Sectors per FAT: ', PBS^.FatSize);
  WriteLn('Sectors per Track: ', PBS^.TrkSize);
  WriteLn('Disk Surfaces: ', PBS^.HeadCnt);
  WriteLn('Hidden Sectors: ', PBS^.HidnSecs);
  WriteLn('Data: ');
  for I := 0 to 481 do
    if PBS^.Data[I] < 32 then Write('.') else Write(Chr(PBS^.Data[I]));
  WriteLn;
  Try := 0;
  repeat
    Inc(Try);
    ResetDrive(Drive);
    ReadSectors(Drive, 0, 0, 2, C, Buf[1]);
    if (BIOSError <> 0) and (Try < 3) then Delay(500);
  until (Try = 3) or (BIOSError = 0);
  if BiosError <> 0 then
    begin
      WriteLn('ERROR #', BiosError);
      Halt(1);
    end;
  if ParamCount > 1 then
    begin
      Assign(F, ParamStr(1));
      Rewrite(F,1);
      BlockWrite(F, Buf, LongInt(Sizeof(Buf[1])) * LongInt(PBS^.ResSecs));
      Close(F);
    end;
end.