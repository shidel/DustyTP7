{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

procedure HelpMode;

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
      WriteLn ('Escape':w1, Escape               :w2, '  Exit Program.');
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
         If Key = Chr(27) then Data := Chr(186)+Chr(219)+Escape;
      until Data = Chr(186)+Chr(219)+Escape;
      ReleaseButtons;
      Squash;
      LoadScr (2);
      Data := '';
      Key  := '';
   end;


