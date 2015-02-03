{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

Procedure EditMenu;
   procedure UpScrn;
      begin
      EditWindow;
      Window (3, 3, 80, 25);
      ChColor (15);
      WriteLn ('F1 - Edit Menu Title.');
      WriteLn ('F2 - Edit Program Discription.');
      WriteLn ('F3 - Edit Program Execution Process.');
      WriteLn;
      WriteLn ('F4 - Add a Menu.');
      WriteLn ('F5 - Add a Program Discription.');
      WriteLn;
      WriteLn ('F6 - Delete Tagged Program Discriptions. ');
      WriteLn ('F7 - Move   Tagged Program Discriptions.');
      WriteLn;
{     WriteLn ('F8 - Tag Discriptions with Invalid');
      WriteLn ('     Execution Processes.');          }
      Window (1,1,80,25);
      Color (Colors[5,2],Colors[5,2]);
      GotoXY (12,24);     Write (Chr(219), ' ', Chr(219));
      GotoXY (17,24);     Write (Chr(219), ' ', Chr(219));
      ChColor (5);
      GotoXY (13,24);     Write (Chr(24));
      GotoXY (18,24);     Write (Chr(25));
      GotoXY (3,16);      TextColor (12);
      WriteLn (' Menu Title: ');
      GotoXY (3,19);
      WriteLn (' Discription: ');
      end;

   var
      Dis : Integer;

   procedure Exec;
   Var
     DataFile : MenuData;
     HoldI    : LongInt;
     RnFile   : Text;
     Hold     : String;
     AutoR    : boolean;

   begin
      Color (14,1);
      GotoXY (50,2);
      Write (' Old Execution Process: ');
      Color (8,0);
      AutoR := AutoReload;
      Window (50,4,78,24);
      ClrScr;
      With MenuDis[Dis] do
         HoldI := Location;
      Assign  (DataFile, 'PGM72.DAT');
      {$I-}
      Reset   (DataFile);
      {$I+}
      if IOresult = 0 then
         begin
            Seek    (DataFile, HoldI);
            AutoR := True;
            repeat
               ReadStr (DataFile, Hold);
               if (Hold <> Chr(2)) and (Hold <> Chr(4)) then
                  WriteLn (Hold);
                  If (Hold = Chr(4)) then
                     AutoR := False;
            until Hold = Chr(2);
            Close (DataFile);
            If AutoR = False then
               WriteLn ('Don''t Reload PGM');
         end;
      Window (1,1,80,25);
   end; {End Exec}

   procedure Refresh;
      var
        i : integer;
      begin
         Color (2,Colors[15,2]);
         GotoXY (3,17);
         Write (Title);
         HideCursor;
         If (Dis > 0) and (TotDis > 0) then
           begin
              with MenuDis[Dis] do
                 begin
                    GotoXY (2,20);
                    Write (Dis:3, '-');
                    if Tag[Dis] then
                       Write (Chr(4))
                    else
                       Write (' ');
                    Color (2,Colors[15,2]);
                    Write (Discription)
                 end;
              Exec;
           end
      end; {End Refresh}

   procedure ConMo;
      var
         X, Y  : integer;
         I     : Integer;
         Holdn : Integer;

      begin
         X := MouseX {div 8};
         Y := MouseY {div 8};
{        GotoXY (1,1);    Write (X:3,Y:3);}
         case Y of
  {F1}      3 : If X In [3..23] then Key := Chr(0) + Chr(59);
  {F2}      4 : If X In [3..32] then Key := Chr(0) + Chr(60);
  {F3}      5 : If X In [3..30] then Key := Chr(0) + Chr(61);
  {F4}      7 : If X In [3..18] then Key := Chr(0) + Chr(62);
  {F5}      8 : If X In [3..33] then Key := Chr(0) + Chr(63);
  {F6}     10 : If X In [3..42] then Key := Chr(0) + Chr(64);
  {F7}     11 : If X In [3..42] then Key := Chr(0) + Chr(65);
{  F8      13 : If X In [3..36] then Key := Chr(0) + Chr(66);
   F8      14 : If X In [8..27] then Key := Chr(0) + Chr(66);}
         end;
         If Data = Chr(219)+Chr(24)+Chr(219) then
            Key := Chr(0)+Chr(72);

         If Data = Chr(219)+Chr(25)+Chr(219) then
            Key := Chr(0)+Chr(80);
         If MouseSpeed > 0 then Delay(MouseSpeed);
      end;  {End ConM}

   Procedure EditTitle;
      var
         MName : MenuFile;
         Hold  : MenuRec;
         T     : String;
      begin
         GotoXY (3,17);
         Color (15,1);
         T := Rtrim(Title);
         Write (T);
         GotoXY (3,17);
         NormCursor;
         Rkey (T, 45, 44, QT);
         HideCursor;
         If (Rtrim(T)<>Rtrim(Title)) and (Not QT) then
           begin
              While Length(T) < 60 do
                 T := T + ' ';
              Assign  (MName, Menus[CurrentMnu+MenuPag]+'.MNU');
              Reset   (MName);
              with Hold do
                 begin
                    Discription := T;
                    Location    := 0;
                 end;
              Write (MName, Hold);
              Close (MName);
              Title := Hold.Discription;
           end;
         UpScrn;
      end;

   function DoEditSort : boolean;
      var
         Hold                : MenuRec;
         I                   : Integer;
         Hbol                : Boolean;
         Done                : boolean;


      procedure SwapDis;
         begin
            Hold := MenuDis[I];
            MenuDis[I] := MenuDis[I+1];
            MenuDis[I+1] := Hold;
            Hbol := Tag[I];
            Tag[I] := Tag[I+1];
            Tag[I+1] := HBol;
            Done := False;
         end;

         begin
              Done := True;
              For I := 1 to TotDis - 1 do
                 If UCase(MenuDis[I].Discription) >
                    UCase(MenuDis[I+1].Discription) then
                       SwapDis;

              For I := TotDis - 1 downto 1 do
                 If UCase(MenuDis[I].Discription) >
                    Ucase(MenuDis[I+1].Discription) then
                       SwapDis;
              DoEditSort := Done;
         end;

   procedure DoEditDisSort;
      begin
         While DoEditSort = False do;
         SaveMenu (Menus[CurrentMnu+MenuPag]);
         UpScrn;
         Refresh;
      end;

   Procedure EditDis (DoSort : boolean);
      var
         D, H                : String;

      begin
         GotoXY (3,20);
         Color (15,1);
         D := Rtrim(MenuDis[Dis].Discription);
         Write (D);
         GotoXY (3,20);
         Write (Space (48));
         GotoXY (3,20);
         NormCursor;
         Rkey (D, 45, 44, Qt);
         D := Trim(D);
         HideCursor;
         If (D <> trim(H)) and (D <> '') then
           begin
              While Length(D) < 60 do
              D := D + ' ';
              MenuDis[Dis].Discription := D;
              If DoSort then DoEditDisSort;
           end;
      end; {End of EditDis}

      procedure TrimData;
         procedure Working;
            begin
               DoBox;
               GotoXY (20,11);
               Write (Chr(186),'  Please Wait, Compressing Data...    ',Chr(186));
            end;

         var
            MName       : MenuFile;
            POld, PNew  : MenuData;
            Loc         : LongInt;
            i, j        : Integer;
            Hold        : String;
            FSize       : longInt;
            CSize       : longint;

         procedure ALeft;
            begin
               GotoXY (42,13);
               Write ((CSize / Fsize * 100):6:2, '% Complete')
            end;

         begin
            Working;
            GetMenus;
            Loc := 0;
            if TotMenus > 0 then
               begin
                  Assign (Pold, 'PGM72.DAT');
                  CSize := 1;
                  Assign (PNew, 'TEMP.DAT');
                  {$I-}
                  Reset (POld);
                  {$I+}
                  If IOResult = 0 then
                     begin
                        ReWrite (PNew);
                        Fsize := FileSize(POld);
                        For i := 1 to TotMenus Do
                           begin
                              GotoXY (22,13);
                              Write ('  MENU:  ', Menus[I] + '        ');
                              ALeft;
                              LoadMenu (Menus[I]);
                              If TotDis > 0 then
                                 begin
                                    For j := 1 to TotDis do
                                       With MenuDis[j] do
                                          begin
                                             Seek(Pold, Location);
                                             Location := Loc;
                                             repeat
                                                ReadStr (Pold, Hold);
                                                WriteStr (PNew, Hold);
                                                CSize := FilePos(Pold);
                                                Loc := Loc + Length(Hold)+1;
                                             Until (Hold = Chr(2));
                                             ALeft;
                                          end;
                                 end;
                              SaveMenu (Menus[I]);
                           end;
                        Close (Pold);
                        Close (PNew);
                        Assign (Pold, 'PGM72.Dat');
                        Assign (PNew, 'Temp.Dat');
                        Erase (Pold);
                        Rename (PNew, 'PGM72.Dat');
                     end;
               end;
         end;

      procedure ReloadMenu (HName : String);
         var
            Fd, I : Integer;

         begin
            Fd := 0;
            Dis := 1;
            GetMenus;
            For I := 1 to TotMenus do
              If Menus[I] = HName then
                 Fd := I;
            CurrentMnu := 1;
            MenuPag := 0;
            If Fd = 0 then
               begin
                  Sound (100);
                  Delay (10);
                  NoSound;
               end
            else
               begin
                  CurrentMnu := Fd;
                  MenuPag := 0;
                  While CurrentMnu > 24 do
                     begin
                        CurrentMnu := CurrentMnu -1;
                        MenuPag := MenuPag + 1;
                     end;
               end;
            LoadMenu (Menus[CurrentMnu+MenuPag]);
         end;

      procedure DelTag (trim : Boolean);
         var
            MName : MenuFile;
            Hold  : MenuRec;
            TT, I : integer;
            HName : String;

         begin
            TT := 0;
            for I := 1 to TotDis do
               if Tag[I] then TT := TT + 1;
            HName := Menus[CurrentMnu+MenuPag];
            Assign  (MName, HName + '.MNU');
            {$I-}
            Erase   (MName);
            {$I+}
            If TotDis <> TT then
               begin
                  ReWrite (MName);
                  with Hold do
                     begin
                        Discription := Title;
                        Location    := 0;
                     end;
                  Write (MName, Hold);
                  For I := 1 to TotDis do
                     If Tag[I] =False then
                        Write (MName, MenuDis[I]);
                  Close (MName);
               end
            else
               begin
                  Title := 'No Name';
                  TotMenus := Totmenus -1;
               end;
            If Trim then
               begin
                  TrimData;
                  ReloadMenu (HName);
                  UpScrn;
               end;
         end;

   procedure AddMenu;
      var
         MN    : String[8];
         Temp  : String;
         I     : integer;
         Mname : MenuFile;
         Hold  : MenuRec;

      begin
         DoBox;
         GotoXY (21,11);
         Color (1,7);
         Write (' New Menu''s Name:                     ');
         GotoXY (21,14);  Color (7, 0);
         Write ('                                      ');
         GotoXY (22,14);
         Temp := '';
         Rkey (Temp, 8, 7 , Qt);
         HideCursor;
         MN := UCase(Trim (Temp));
         For I := 1 to TotMenus do
            if MN = Menus[I] then
               Mn := '';
         if MN <> '' then
            begin
               TotMenus := TotMenus + 1;
               Title := 'New Menu; No Title; '+ MN;
               TotDis := 0;
               Assign  (MName, MN+'.MNU');
               {$I-}
               ReWrite   (MName);
               {$I+}
               if IOResult = 0 then
                  begin
                     with Hold do
                        begin
                           Discription := Title;
                           Location    := 0;
                        end;
                     Write (MName, Hold);
                     Close (MName);
                  end
               else
                  begin
                     DoBox;
                     GotoXY (21,12);
                     Color (14,4);
                     Write ('           Invalid Menu Name          ');
                     Stub;
                     Pause;
                  end;
               ReloadMenu (MN);
            end
         else
            Stub;
         UpScrn;
         Refresh;
      end;

   procedure MoveTagged;
      procedure LoadToMenu (MenuName : String);
         var
            MName : MenuFile;
            Hold  : MenuRec;
            Lp    : Integer;

         begin
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
                              Tag[TotDis] := True;
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
                     if Tag[Lp] then
                        Tag[Lp] := False
                     else
                        Tag[LP] := True;
               end;
         end;

      var
         I, TotTag, MNum : integer;
         Mn, Temp        : String;

      begin
         TotTag := 0;
         For I := 1 to TotDis do
            If Tag[I] then TotTag := TotTag + 1;
         If TotTag > 0 then
            begin
               DoBox;
               GotoXY (21,11);
               Color (1,7);
               Write (' Move To Menu''s Named:                ');
               GotoXY (21,14);  Color (7, 0);
               Write ('                                      ');
               GotoXY (22,14);
               Temp := '';
               Rkey (Temp, 8, 7 , Qt);
               HideCursor;
               Temp := Ucase(Trim(Temp));
               MN := Temp;
               For I := 1 to TotMenus do
                  if MN = Menus[I] then
                     begin
                        Mn := '';
                        MNum := I;
                     end;
               If Mn <> Temp then
                  begin
                     DelTag (False);
                     LoadToMenu(Temp);
                     While DoEditSort = False do;
                     CurrentMnu := MNum;
                     MenuPag := 0;
                     DelTag (True);
                     ReLoadMenu (Temp);
                  end
               else
                  begin
                     DoBox;
                     GotoXY (21,12);
                     Color (14,4);
                     Write ('          Menu Was Not Found          ');
                     Stub;
                     Pause;
                  end;

            end
         else
            begin
               DoBox;
               GotoXY (21,12);
               Color (14,4);
               Write ('      No Discriptions Are Tagged      ');
               Stub;
               Pause;
            end;
         UpScrn;
         Refresh;
      end;

   procedure AddDis;
      var
         Df : MenuData;
         Sz : longInt;
         Mn : string;
      begin
         Mn := Menus[CurrentMnu + MenuPag];
         assign (Df, 'PGM72.DAT');
         {$I-}
         Reset (Df);
         {$I-}
         if IOResult = 0 then
            begin
               Sz := FileSize (DF);
               Seek (DF, Sz);
            end
         else
            begin
               Rewrite (DF);
               Sz := 0;
            end;
         WriteStr (DF, 'CD\');
         WriteStr (DF, Chr(2));
         Close (DF);
         TotDis := TotDis + 1;
         Dis := TotDis;
         MenuDis[Dis].Discription := '';
         MenuDis[DIS].Location := Sz;
         EditDis (False);
         if MenuDis[Dis].Discription <> '' then
            begin
               EditExec (Dis); {Edit Execution Process}
               DoEditDisSort;
               If Data <> 'NoSave' then
               TrimData;
            end;
         ReloadMenu(Mn);
         UpScrn;
         Refresh;
         Data := '';
      end;

   var
     TmpNm : String;

   begin   {Begin EditMenu}
      Dis := DisNum + DisPag;
      UpScrn;
      repeat
         Refresh;
         repeat
            ReadMouse (OldX, OldY, OldColor, Data);
            Key := Inkey;
         until (Key <> '') or (Data <> '');
         SplitButtons (Data, B1, B2, B3);
         ReleaseButtons;
         if B1 then
            ConMo;
         if Key <>'' then
         Case Ord(Key[1]) of
             27 : Data := Chr(186)+Chr(219)+Escape;
              0 : Case Ord(Key[2]) of
                      59 : If TotMenus > 0 then EditTitle;
                      60 : If TotDis   > 0 then EditDis (True);
                      61 : If TotDis   > 0 then
                             begin
                                EditExec (Dis); {Edit Execution Process}
                                UpScrn;
                                TmpNm := Menus[CurrentMnu + MenuPag];
                                If Data <> 'NoSave' then
                                   begin
                                      TrimData;
                                      ReloadMenu(TmpNm);
                                      UpScrn;
                                   end;
                                Refresh;
                                Data := '';
                             end;
                      62 : if TotMenus < 126 then
                              AddMenu
                           else
                              begin
                                 Sound (500);
                                 Delay (500);
                                 NoSound;
                              end;
                      63 : If (TotMenus > 0) and (TotDis < 200) then
                              AddDis;
                      {Delete Tagged Discriptions}
                      64 : If (TotMenus > 0) then
                              DelTag (True);

                      {Move Tagged Discriptions}
                      65 : If TotMenus > 1 then MoveTagged;
                      72 : If Dis > 1 then
                              Dis := Dis - 1;
                      80 : if Dis < TotDis then
                              Dis := Dis + 1;
                  end;
         end;

      until Data = Chr(186)+Chr(219)+Escape;
      ReleaseButtons;
      Squash;
      LoadScr (2);
      Data := '';
      Key  := '';

      LoadScr (1);
      UpDateScreen;

   end; {End EditMenu}
