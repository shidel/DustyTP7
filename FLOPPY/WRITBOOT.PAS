{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$S+,D+,L+}
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
      Data:array[0..481] of byte;
    end;

  var
    MaxHead : byte;
    MaxSect  : byte;
    Drive : byte;
    Buf   : array [0..511] of byte;
    BS    : TFBS;
    F     : File;
    C     : word;

procedure WriteSec(var Buf);
  const
    Head  : word = 0;
    Track : word = 0;
    Sect  : word = 1;
  var
    Try : byte;
  begin
    Try := 0;
    repeat
      Inc(Try);
      ResetDrive(Drive);
      WriteSectors(Drive, Head, Track, Sect, 1, Buf);
      if (BIOSError <> 0) and (Try < 3) then Delay(500);
    until (Try = 3) or (BIOSError = 0);
    if BiosError <> 0 then
      begin
        WriteLn('ERROR #', BiosError);
        Halt(1);
      end;
    Inc(Sect);
    if Sect > MaxSect then
      begin
        Sect := 1;
        Inc(Head);
        if Head >= MaxHead then
          begin
            Head := 0;
            Inc(Track);
          end;
      end;

  end;

begin
  MaxHead := 2;
  MaxSect := 18;
  Drive := 1;
  if ParamCount = 1 then
    begin
      WriteLn('Copy ', ParamStr(1), ' to Bootsector on drive A:');
      Assign(F, Paramstr(1));
      Reset (F);
      FillChar(BS, Sizeof(BS), 0);
      BlockRead(F, BS, Sizeof(BS), C);
      WriteSec(BS);
      repeat
        FillChar(Buf, Sizeof(Buf), 0);
        BlockRead(F, Buf, Sizeof(Buf), C);
        if C <> 0 then WriteSec(Buf);
      until C = 0;
      Close(F);
    end;
end.