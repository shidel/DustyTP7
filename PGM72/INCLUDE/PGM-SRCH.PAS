{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

procedure GoFind (FStr : String);
   var
      HMenu, SMenu,
      HNum,  SNum   : Integer;
      intg, Er      : integer;
      Found         : boolean;

   procedure MovePos;
      begin
         While (CurrentMnu + MenuPag) < HMenu do
            begin
               CurrentMnu := CurrentMnu + 1;
               If CurrentMnu > 24 then
                  begin
                     CurrentMnu := 24;
                     MenuPag := MenuPag + 1;
                  end;
            end;
         While (CurrentMnu + MenuPag) > HMenu do
            begin
               CurrentMnu := CurrentMnu - 1;
               If CurrentMnu < 1 then
                  begin
                     CurrentMnu := 1;
                     MenuPag := MenuPag - 1;
                  end;
            end;

         While (DisNum + DisPag) < HNum do
            begin
               DisNum := DisNum + 1;
               If DisNum > 19 then
                  begin
                     DisNum := 19;
                     DisPag := DisPag + 1;
                  end;
            end;
         While (DisNum + DisPag) > HNum do
            begin
               DisNum := DisNum - 1;
               If DisNum < 1 then
                  begin
                     DisNum := 1;
                     DisPag := DisPag - 1;
                  end;
            end;
      end;

   begin
   If TotDis > 0 then
   begin
      Val (FStr, Intg, Er);
      If Er <> 0 then Intg := 0;
      SaveScr (2);
      DoBox;
      GotoXY (25,11);      Write ('Searching...');
      HMenu := CurrentMnu + MenuPag;
      HNum  := DisNum + DisPag;
      SMenu := HMenu;
      Snum  := HNum;
      Found := False;
      GotoXY (25,13);
      Write ('MENU:          ');
      GotoXY (31,13);
      Write (Menus[SMenu]);
      repeat
         SNum := SNum + 1;
         GotoXY (47,13);
         Write ('LINE:', SNum:4);
         if SNum > TotDis then
            begin
               SNum := 1;
               SMenu := SMenu + 1;
               If SMenu > TotMenus then
                  SMenu := 1;
               LoadMenu (Menus[SMenu]);
               GotoXY (25,13);
               Write ('MENU:          ');
               GotoXY (31,13);
               Write (Menus[SMenu]);
            end;
         If ( Pos (FStr,UCase(MenuDis[SNum].Discription)) > 0 ) or
            (SNum = Intg)                                            then
            begin
               HMenu := SMenu;
               HNum  := SNum;
               Found := True;
            end;
      until (HMenu = SMenu) and (HNum = SNum);
      MovePos;
      Squash;
      UpdateScreen;
   end;
   end;

procedure SearchMode;
   var
      Hold : String;
   begin
      If TotDis > 0 then
         begin
            GotoXY (57,24);
            Color (4,7);
            Write ('Find>                 ');
            Color (0,7);
            GotoXY (63,24);
            Hold := SrchStr;
            RKey (Hold, 45, 15, Qt);
            HideCursor;
            GotoXY (57,24);
            ChColor (1);
            Write ('                      ');
            If (Hold <> '') and (Not Qt) then
               begin
                  SrchStr := Trim(Ucase(Hold));
                  GoFind (SrchStr);
               end;
         end;
   end;


