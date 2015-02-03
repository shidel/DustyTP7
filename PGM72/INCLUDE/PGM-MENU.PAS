{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}


procedure SortMnu;
   var
      Done : Boolean;
      I, J : Integer;
      Temp : String[12];
   begin
      Done := False;
      While not Done do
         begin
            Done := True;
            For I := 1 to TotMenus-1 do
                If Menus[I] > Menus[I+1] then
                  begin
                    Temp       := Menus[I];
                    Menus[I]   := Menus[I+1];
                    Menus[I+1] := Temp;
                    Done := False;
                  end
         end
   end;

procedure GetMenus;
   var
      Tot, I    : integer;
      FName     : NameStr;
      FExt      : ExtStr;

   begin
        FindFiles ('*.MNU', '', 0, Tot);
        For I := 1 to 126 do
           Menus[I] := '';
        TotMenus := 0;
        For I := 1 to Tot do
           begin
              Fsplit (DirDat[I].Name,OpPath,FName,FExt);
              If FExt = '.MNU' then
                 Begin
                    TotMenus := TotMenus + 1;
                    Menus[TotMenus] := Fname;
                 end;
           end;
        If TotMenus > 0 then
           begin
              SortMnu;
              CurrentMnu := 1;
           end
   end;

procedure LoadMenu (MenuName : String);
   var
      MName : MenuFile;
      Hold  : MenuRec;
      Lp    : Integer;

   begin
      TotDis := 0;
      If TotMenus > 0 then
        begin
           Assign (MName , MenuName+'.MNU');
           {$I-}
           Reset (MName);
           {$I+}
           if IoResult = 0 then
              begin
                 Read (MName, Hold);
                 Title := Hold.Discription;
                 While Not Eof(Mname) do
                    begin
                       Read (MName, Hold);
                       TotDis := TotDis + 1;
                       MenuDis[TotDis] := Hold;
                    end;
                 Close (MName);
              end
           else
              begin
                 NormCursor;
                 Color (7,0);
                 ClrScr;
                 Halt(1)
              end;
           DisPag := 0;
           DisNum := 1;
           For Lp := 1 to MaxList do
              Tag[Lp] := False;
        end;
   end;

procedure FixPage;
   begin
     While CurrentMnu < 1 do
       begin
          CurrentMnu := CurrentMnu + 1;
          MenuPag := MenuPag - 1;
       end;
     While CurrentMnu > 24 do
       begin
          CurrentMnu := CurrentMnu - 1;
          MenuPag := MenuPag + 1;
       end;
     if MenuPag > TotMenus - 24 then MenuPag := TotMenus - 24;
     if MenuPag < 0 then MenuPag := 0;
   end;

procedure PrevMenu;
   begin
      CurrentMnu := CurrentMnu - 1;
      If CurrentMnu + MenuPag < 1 then
         begin
            CurrentMnu := TotMenus;
            MenuPag := TotMenus-24;
         end;
      FixPage;
      LoadMenu (Menus[CurrentMnu+MenuPag]);
      DisNum   := 1;
      DisPag   := 0;
   end;

procedure NextMenu;
   begin
      CurrentMnu := CurrentMnu + 1;
      If CurrentMnu + MenuPag > TotMenus then
         begin
            CurrentMnu := 1;
            MenuPag := 0;
         end;
      FixPage;
      LoadMenu (Menus[CurrentMnu+MenuPag]);
      DisNum   := 1;
      DisPag   := 0;
   end;

   procedure SaveMenu (MenuName : String);
       var
          I : integer;
          Mname : MenuFile;
          Hold  : MenuRec;

       begin
          Assign  (MName, MenuName+'.MNU');
          {$I-}
          Reset   (MName);
          {$I+}
          if IOResult <> 0 then
             ReWrite (MName);
          with Hold do
             begin
                Discription := Title;
                Location    := 0;
             end;
          Write (MName, Hold);
          For I := 1 to TotDis do
             Write (MName, MenuDis[I]);
          Close (MName);
       end;


