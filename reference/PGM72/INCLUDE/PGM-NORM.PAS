{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}


   var
      Lp     : integer;
      RnFile : Text;

   begin {Window1}
      PrintTime;
      UpdateScreen;
      HoldTime := '';
      HoldDate := '';
      repeat
         HideCursor;
         Data :='';
         Key := '';
         While (Data = '') and (Key ='') do
            begin
               ReadMouse (OldX, OldY, OldColor, Data);
               Blank;
               PrintTime;
               Key := Inkey;
            end;
         TotWait := 0;
         SplitButtons (Data, B1, B2, B3);
         If B1 = true then
            ConMouse;
         if Length(data)>2 then
            begin
               If Data[3] = Chr(24) then Key := '-';
               If Data[3] = Chr(25) then Key := '+';
            end;
         if Key <>'' then
            Case Ord(Key[1]) of
               13 : Data := Enter;
               27 : Data := Escape;
               45 : if TotMenus > 1 then
                       begin
                          PrevMenu;
                          UpDateScreen;
                          PrintTime;
                       end;
           43, 61 : If TotMenus > 1 then
                      begin
                         NextMenu;
                         UpDateScreen;
                         PrintTime;
                      end;
                0 : Case ord(Key[2]) of
                      59 : Data := Help;
                      60 : Data := Search;
                      61 : Data := Edit;
                      72 : ScrollUp;
                      80 : ScrollDown;
                      73 : PageUp;
                      81 : PageDown;
                      71 : GoHome;
                      79 : GoEnd;
                    end; {End Of Case Key(2)}
         else
             begin
                SrchStr := Key;
                SearchMode;
             end;
            end; {End of Case Key(1)}
      if Data = Help   then HelpMode;
      if (Data = Search) and (SrchStr <> '') then GoFind (SrchStr);
      if Key = Chr(0)+Chr(85) then Searchmode;
      If Data = Edit   then EditMode;
      if Data = Enter  then
         If TotDis = 0 then
            Data := ''
         else
            Execute;
      until (Data = Escape) or (Data = Enter);
      GotoXY (1,1);
      Color (7,0);
      if Data = Escape then
         begin
            Assign  (RnFile, 'RN.BAT');
            Rewrite (RnFile);
            WriteLn (RnFile, '@ECHO OFF');
            WriteLn (RnFile, 'CD\');
            WriteLn (RnFile, 'ECHO GoodBye.');
            Close   (RnFile);
            for Lp := 1 to 25 do
               DelLine;
         end;
      if Data = Enter then
         for Lp := 1 to 25 do
            InsLine;
      ReleaseButtons;
      NormCursor;
   end; {Window1}


