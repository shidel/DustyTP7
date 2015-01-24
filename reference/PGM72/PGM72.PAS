{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

program ProgramManager { Version #7.2 };
{$M 50000,0,655350}

{$I PGM-MAIN.PAS}

   var
      AL : String;
      Lp : integer;
      Md : Integer;
      I  : integer;
begin
   NoSound;
   DirectVideo := False;
   Al := '';
   If ParamCount > 0 then
      Al := UCase(Trim(ParamStr(1)));
   OldX := 0;
   OldY := 0;
   For Lp := 0 to MaxList do
      MenuDis[Lp].DisCription := '';
   ResetMouse;
   DefaultSetup;
   MainScreen;
   GetMenus;
   CurrentMnu := 1;
   MenuPag := 0;
   for I := 1 to TotMenus do
         if Menus[I] = Al then
            begin
               CurrentMnu := I;
               While CurrentMnu > 24 do
                  begin
                    CurrentMnu := CurrentMnu - 1;
                    MenuPag := MenuPag + 1;
                  end;
            end;
   If TotMenus > 0 then
      LoadMenu (Menus[CurrentMnu + MenuPag]);
   For Lp := 1 to MaxList do
      Tag[Lp] := False;
   Window1;
   Color (7,0);
   ClrScr;
end.
