{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+,Y+}
{$M 16384,0,0}
program NullDisk;

  uses QCrt, Bios;

  var
    B : TFloppyFormatBuf;
    C : Char;
    Tries : byte;

begin
  DirectVideo := False;
  WriteLn('Insert new disk to wipe in drive A:');
  Write  ('and press ENTER when ready...');
  repeat
    while Not Keypressed do;
    C := ReadKey;
    if C = #3 then
      begin
        WriteLn('^C'#13#10);
        Halt(1);
      end;
  until C = #13;
  WriteLn;
  while Keypressed do ReadKey;
  FillFloppyFormatBuf(0, 0, 512, B);
  Tries := 0;
  repeat
    Inc(Tries);
    ResetDrive(1);
    FormatTrack(1, 0, 0, 0, B);
    if (Tries <= 3) and (BiosError <> 0) then
      Delay(500);
  until (Tries > 3) or (BiosError = 0);
  if BIOSError <> 0 then
    begin
      WriteLn('Error #', BIOSError);
      ResetDrive(1);
    end;
end.
