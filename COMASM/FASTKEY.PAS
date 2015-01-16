{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

program FastKey;

 var
   F : File;
   S : String;


begin
  S := #$B8#$05#$03#$31#$DB#$CD#$16#$CD#$20;
  Assign(F, 'FASTKEY.COM');
  ReWrite (F,1);
  BlockWrite (F, S[1], Length(S));
  Close(F);
{  asm
    MOV  AX, 0305h
    XOR  BX, BX
    INT  16h
    INT  20h
  end;}
end.