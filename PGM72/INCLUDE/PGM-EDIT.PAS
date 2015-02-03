{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

procedure EditMode;
   procedure EditHelp;

   const
      w1 = 15;
      w2 = 15;

   begin
      HelpWindow;
      ChColor (14);
      Window (5,3,80,25);
      WriteLn (' Help Mode: ');
      WriteLn ;
      WriteLn ('Special Keys:':w1,'Mouse:':w2,'  Functions:');
      WriteLn ;
      WriteLn ('F1'    :w1, Help                 :w2, '  Help Mode.');
      WriteLn ('F2'    :w1, Search               :w2, '  Search Again.');
      WriteLn ('F3'    :w1, Edit                 :w2, '  Enter Editing Mode.');
      WriteLn (''      :w1, 'Point & Click'      :w2, '  Load A Specific Menu.');
      WriteLn (''      :w1, 'Left Button'        :w2, '  Move Highlight Bar.');
      WriteLn ('^T'    :w1, 'Middle Button'      :w2, '  Move Highlight Bar and Tag.');
      WriteLn ('^U'    :w1, 'Right Button'       :w2, '  Move Highlight Bar and Un-tag.');
      WriteLn ('Escape':w1, Escape               :w2, '  Exit Editing Mode.');
      WriteLn ('Enter' :w1, Enter                :w2, '  Execute A Program.');
      WriteLn;
      WriteLn ('-'     :w1, 'Scroll Bar '+Chr(24):w2, '  Load Last Menu.');
      WriteLn ('+'     :w1, 'Scroll Bar '+Chr(25):w2, '  Load Next Menu.');
      WriteLn ('Up'    :w1, 'Scroll Bar '+Chr(24):w2, '  Move Highlight Bar Up.');
      WriteLn ('Down'  :w1, 'Scroll Bar '+Chr(25):w2, '  Move Highlight Bar Down.');
      Window (1,1,80,25);
      repeat
         repeat
            ReadMouse (OldX, OldY, OldColor, Data);
            Key := Inkey;
         until (Key <> '') or (Data <> '');
         SplitButtons (Data, B1, B2, B3);
         If Key = Chr(27) then
            Data := Chr(186)+Chr(219)+Escape;
      until Data = Chr(186)+Chr(219)+Escape;
      ReleaseButtons;
      Squash;
      LoadScr (2);
      Data := '';
      Key  := '';
   end;  {End EditHelp}

   procedure ConM;
      var
         X, Y  : integer;
         I     : Integer;
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
                                            if B2 then
                                               Tag[DisNum+DisPag] := True;
                                            if B3 then
                                               Tag[DisNum+DisPag] := False;
                                            DisplayDis (Holdn);
                                            DisplayDis (DisNum + DisPag);
                                         end;
                                   end;
                      end;
           {472..624} 59..78  : begin
                         PickMenu (X, Y);
                         For I := 1 to MaxList do
                            Tag[I] := False;
                      end;
         end;
         If Data = Chr(186)+ Chr(24) then
            Key := Chr(0)+Chr(72);
         If Data = Chr(186)+ Chr(25) then
            Key := Chr(0)+Chr(80);
         If MouseSpeed > 0 then Delay(MouseSpeed);
      end;

   var
     I : Integer;
   begin
      Squash;
      PrintTime;
      UpdateScreen;
      HoldTime := '';
      HoldDate := '';
      repeat
         HideCursor;
         GotoXY (30,25);
         Color (30,4);
         Write(' EDITING MODE ');
         Data :='';
         Key := '';
         While (Data = '') and (Key ='') do
            begin
               ReadMouse (OldX, OldY, OldColor, Data);
               PrintTime;
               Key := Inkey;
            end;
         TotWait := 0;
         SplitButtons (Data, B1, B2, B3);
         If (B1 = true) or (B2 = True) or (B3 = True) then
            ConM;
         if Length(data)>2 then
            begin
               If Data[3] = Chr(24) then Key := '-';
               If Data[3] = Chr(25) then Key := '+';
            end;
         if Key <> '' then
            Case Ord(Key[1]) of
               13 : Stub;
               20 : begin
                       Tag[DisNum+DisPag] := True;
                       DisplayDis (DisNum + DisPag);
                       ScrollDown;
                    end;
               21 : begin
                       Tag[DisNum+DisPag] := False;
                       DisplayDis (DisNum + DisPag);
                       ScrollDown;
                    end;
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
      if Data = Help then EditHelp;
      if (Data = Search) and (SrchStr <> '') then GoFind (SrchStr);
      if Key = Chr(0)+Chr(85) then Searchmode;
      if Data = Edit then EditMenu;
      until Data = Escape;
      GotoXY (1,1);
      Color (7,0);
      Data := '';
{      UpDateScreen;}
      ReleaseButtons;
      For I := 1 to MaxList do
         Tag[I] := False;
      Squash;
      PrintTime;
      UpdateScreen;
   end;


