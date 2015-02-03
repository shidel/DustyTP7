{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

procedure PickMenu (X, Y : Integer);
   begin
      Case Y of
          {80..168} 10..21 : begin
                       If X < {552} 69 then
                          if Y {Div 8} - 9 <= TotMenus then
                             begin
                                CurrentMnu := Y {div 8} - 9;
                                LoadMenu (Menus[CurrentMnu+ MenuPag]);
                                UpDateScreen;
                             end;
                       If X > {544} 68 then
                          if Y {Div 8} + 3 <= TotMenus then
                             begin
                                CurrentMnu := Y {div 8} + 3;
                                LoadMenu (Menus[CurrentMnu+MenuPag]);
                                UpDateScreen;
                             end;
                    end;
      end;
   end;

procedure Window1;
   procedure PrintTime;
      begin
         If HoldTime <> Time then
            begin
               Inc (TotWait);
               ChColor (3);
               GotoXY (57,5);
               HoldTime := Time;
               Write (HoldTime:19,'   ');
               If HoldDate <> Date(1) then
                  begin
                     GotoXY (57,6);
                     HoldDate := Date(1);
                     Write (HoldDate:19,'   ');
                  end;
            end
      end; {PrintTime}

   var
      Key : String[2];
      B1, B2, B3           : boolean;

   procedure ConMouse;
      var
         X, Y  : integer;
         Holdn : Integer;
      begin
         X := MouseX;
         Y := MouseY;
         case X of
            {32..424} 4..53 : Case Y of
                         {32..176} 4..22 : begin
                                      if Y {div 8} - 4 < TotDis then
                                         begin
                                            Holdn := DisNum + DisPag;
                                            DisNum := y {div 8} - 3;
                                            ChColor (10);
                                            DisplayDis (Holdn);
                                            DisplayDis (DisNum + DisPag);
                                         end;
                                   end;
                      end;
           {472..624} 59..78 : PickMenu (X, Y);
         end;
         If Data = Chr(186)+ Chr(24) then
            Key := Chr(0)+Chr(72);
         If Data = Chr(186)+ Chr(25) then
            Key := Chr(0)+Chr(80);
         If MouseSpeed > 0 then Delay(MouseSpeed);
      end;

