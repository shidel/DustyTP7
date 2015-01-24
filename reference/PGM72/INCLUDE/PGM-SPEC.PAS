{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

procedure PopMouse;
   begin
      SetSColor (OldX,OldY, OldColor);
      OldX := 0;
      OldY := 0;
   end;


function InKey : String;
         var
            I : String;
         begin
              I := '';
              If KeyPressed then
                 begin
                      I := ReadKey;
                      PopMouse;
                      If I = Chr(0) then
                         I := I + ReadKey
                 end;
              Inkey := I
         end;

