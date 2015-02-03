{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

procedure Execute;
   Var
     TmpPath  : String;
     DataFile : MenuData;
     HoldI    : LongInt;
     RnFile   : Text;
     Hold     : String;

   begin
      With MenuDis[DisNum+DisPag] do
         HoldI := Location;
      Assign  (DataFile, 'PGM72.DAT');
      Reset   (DataFile);
      Assign  (RnFile,   'RN.BAT');
      ReWrite (RnFile);
      WriteLn (RnFile, '@ECHO OFF');
      WriteLn (RnFile, 'ECHO Loading '+MenuDis[DisNum+DisPag].Discription);
      Seek (DataFile, HoldI);
      repeat
         ReadStr (DataFile, Hold);
         if (Hold <> Chr(2)) and (Hold <> Chr(4)) then
            WriteLn (RnFile, Hold);
         If (Hold = Chr(4)) then
            AutoReLoad := False;
      until Hold = Chr(2);
      Close (DataFile);
      If AutoReload = True then
        begin
           GetDir (0, TmpPath);
           WriteLn (RnFile, Copy(TmpPath,1,2));
           WriteLn (RnFile, 'CD\ ');
           WriteLn (RnFile, 'Pgm ' + Menus[CurrentMnu + MenuPag]);
        end;
      Close (RnFile);
   end;

