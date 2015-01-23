{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

program Ports;

  uses StrAsm, StrSize;

  const
    COM : Str3 = 'COM';
    LPT : Str3 = 'LPT';


  procedure ShowPort ( ATitle, ANumber : String; AOffset : word );
    begin
      if MemW[Seg0040:AOffset] <> 0 then
        WriteLn ( ATitle, ANumber, ' is ',
                  HexWord(MemW[Seg0040:AOffset]), '.' );
    end;

begin
  WriteLn ( 'Ports version 1.00');
  WriteLn;
  ShowPort ( COM, '1', $0000 );
  ShowPort ( COM, '2', $0002 );
  ShowPort ( COM, '3', $0004 );
  ShowPort ( COM, '4', $0006 );
  WriteLn;
  ShowPort ( LPT, '1', $0008 );
  ShowPort ( LPT, '2', $000A );
  ShowPort ( LPT, '3', $000C );
  ShowPort ( LPT, '4', $000E );
  WriteLn;
  ShowPort( '6859 video controller', '', $0063);
end.
