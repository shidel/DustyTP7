{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

program Test_PCKeyBrd;

  uses EDrivers, KeyConst, Keyboard, StrAsm;

  procedure Load;
    var
      TError : integer;
    begin
      TError := LoadDriver( 'PCKEYBRD.DRV', @PKeyBoard );
      if TError <> 0 then RunError ( TError );
    end;

  var
    TC : word;
begin
  Load;
  WriteLn ( GetDriverName ( @PKeyboard ) );
  repeat
    while not Keypressed do;
    TC := GKeybrd.ReadKey;
    WriteLn ( Chr( Lo(TC) ), Chr(Hi(TC)), '[', HexWord(TC), ']' );
  until (TC = kbEscape);

end.
