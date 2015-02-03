{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

procedure WriteStr (var FileName : MenuData; Hold : String);
   var
      i  : integer;
      Ch : Char;

   begin
      For i := 1 to Length(Hold) do
         begin
            Ch := Hold[i];
            Write (FileName, Ch);
         end;
      Ch := Chr(1);
      Write (FileName, Ch);
   end;

procedure ReadStr (var FileName : MenuData; var Hold : String);
   var
      ll  : integer;
      Ch : Char;

   begin
      Hold := '';
      ll := 0;
      repeat
         Read (FileName, Ch);
        { WriteLn (Ch);}
         If Ch <> Chr(1) then
            Hold := Hold + Ch;
         ll := ll + 1;
      until (Ch = Chr(1)) or (ll > 255);
   end;

procedure Editexec (Dis : Integer);

   const
      Ent      = Chr(175) + 'Enter'     + Chr(174);
      Save     = Chr(175) + 'Save'      + Chr(174);
      Drive    = Chr(175) + 'Drive'     + Chr(174);
      Forget   = Chr(175) + 'Forget'    + Chr(174);
      AllFiles = Chr(175) + 'All-Files' + Chr(174);
      Prompt   = Chr(175) + 'Dos?'      + Chr(174);
      Auto     = Chr(175) + 'Auto-Reload' + Chr(174);

   procedure DirHelp;
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
      WriteLn ('F2'    :w1, Save                 :w2, '  Save Exec Process.');
      WriteLn ('F3'    :w1, Forget               :w2, '  Forget Last Entry.');
      WriteLn ('F4'    :w1, Drive                :w2, '  List Active Drives.');
      WriteLn ('F5'    :w1, AllFiles             :w2,
                                            '  Toggle All Files Listing.');
      WriteLn ('F6'    :w1, Prompt               :w2, '  Enter Dos Command.');
      WriteLn ('F7'    :w1, Auto                 :w2, '  Toggle Auto-Reload.');
      WriteLn;
      WriteLn ('Escape':w1, Escape               :w2,
                                            '  Leave Edit Exec (No Changes).');
      WriteLn ('Enter' :w1, Ent                  :w2,
                                            '  Put A Program In The Exec.');
      WriteLn (''                      :w2, '  Or Change Directorys.');
      WriteLn;
      WriteLn ('-'     :w1, 'Scroll Bar '+Chr(24):w2, '  Load Last Menu.');
      WriteLn ('+'     :w1, 'Scroll Bar '+Chr(25):w2, '  Load Next Menu.');
      WriteLn ('Up'    :w1, 'Scroll Bar '+Chr(24):w2, '  Move Highlight Bar Up.');
      WriteLn ('Down'  :w1, 'Scroll Bar '+Chr(25):w2, '  Move Highlight Bar Down.');
      WriteLn (''      :w1, 'Left Button'        :w2, '  Move Highlight Bar.');

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

   var
      StartPath   : String;
      Drv         : String[2];
      AutoR       : Boolean;
   procedure EditSpec;
      begin
         Color  (14, 1);
         GotoXY (12, 24);         Write (' ', Save,     ' ');
         GotoXY (22, 24);         Write (' ', Ent,      ' ');
         GotoXY (33, 24);         Write (' ', Forget,   ' ');
         GotoXY (45, 24);         Write (' ', Drive,    ' ');
         GotoXY (56, 24);         Write (' ', Allfiles, ' ');
         GotoXY (71, 24);         Write (' ', Prompt,   ' ');
         GotoXY (64, 23);         Write (' ', Auto,     ' ');
         GotoXY (54, 23);         Write (' ', Help,     ' ');
      end;

   const
      MaxExPro = 100;

   type
      ExProRecord = record
                      Path : String[127];
                      Name : String[20];
                      Com  : String[127];
                    end;
   var
     ExPro   : array [1..MaxExPro] of ExProRecord;
     Index   : integer;

   procedure GoSave;
   Var
     DataFile : MenuData;
     HoldI    : LongInt;
     RnFile   : Text;
     Hold     : String;
     C, Tmp1  : String;
     P, Tmp2  : String;
     TPath : String;


   procedure WriteData;
   var
      I     : integer;
   begin
      With MenuDis[Dis] do
         HoldI := Location;
      Assign  (DataFile, 'PGM72.DAT');
      {$I-}
      Reset   (DataFile);
      {$I+}
      If IOresult = 0 then
         Seek    (DataFile, HoldI)
      else
         ReWrite (DataFile);
      C := '';
      P := '';
      For I := 1 to Index do
         with ExPro[I] do
            begin
               Tmp1 := Copy (Path, 1, 2);
               If C <> Tmp1 then
                  WriteStr (DataFile, Tmp1);
               Tmp2 := Copy (Path, 3, Length(Path) - 2);
               If (P <> Tmp2) or (C <> Tmp1) then
                  WriteStr (DataFile, 'CD '+ Tmp2);
               C := Tmp1;
               P := Tmp2;
               WriteStr (DataFile, Name +  ' ' + Com)
            end;
      If Not AutoR then WriteStr (DataFile, Chr(4));
      WriteStr (DataFile, Chr(2));
      Close (DataFile);
   end;

   var
      DatF : MenuData;
   begin
      If Index > 0 then
         begin
            Assign (DatF, 'PGM72.DAT');
            {$I-}
            Reset (DatF);
            {$I+}
            if IOResult = 0 then
               begin
                  MenuDis[Dis].location := FileSize (DatF);
                  Close (DatF);
               end
            else
               MenuDis[Dis].location := 1;
            SaveMenu (Menus[CurrentMnu + MenuPag]);
            WriteData;
         end;
   end;

   procedure Exec;
   Var
     DataFile : MenuData;
     HoldI    : LongInt;
     RnFile   : Text;
     Hold     : String;

   procedure Exec1;
   var
      TPath : String;
   begin
      TPath := StartPath;
      If length(TPath)>3 then
        TPath := TPath + '\';
      With MenuDis[Dis] do
         HoldI := Location;
      Assign  (DataFile, TPath+'PGM72.DAT');
      {$I-}
      Reset   (DataFile);
      {$I+}
      AutoR := True;
      if IOResult = 0 then
         begin
            Seek    (DataFile, HoldI);
            repeat
               ReadStr (DataFile, Hold);
               if (Hold <> Chr(2)) and (Hold <> Chr(4)) then
                  WriteLn (' ', Hold);
               if (Hold = Chr(4)) then
                  AutoR := False;
            until Hold = Chr(2);
            Close (DataFile);
         end;
   end;

   procedure Exec2;
      var
        I, J    : integer;
        C, Tmp1 : String;
        P, Tmp2 : String;

      begin
         C := '';
         P := '';
         For I := 1 to Index do
            with ExPro[I] do
               begin
                  Tmp1 := Copy (Path, 1, 2);
                  If C <> Tmp1 then
                     WriteLn (' ',Tmp1);
                  Tmp2 := Copy (Path, 3, Length(Path) - 2);
                  If (P <> Tmp2) or (C <> Tmp1) then
                     WriteLn (' CD ', Tmp2);
                  C := Tmp1;
                  P := Tmp2;
                     WriteLn (' ', Name, ' ', Com)
               end;
      end;

   begin
      Color (14,1);
      GotoXY (50,2);
      If Index = 0 then
         Write (' Old')
      else
         Write (' New');
      Write (' Execution Process: ');
      Color (14,0);
      GotoXY (50,4);
      Write (Copy (MenuDis[Dis].Discription,1,29));
      GotoXY (50,5);
      Write (Copy (MenuDis[Dis].Discription,30,15));
      Window (49,6,77,21);
      Color (7,1);
      ClrScr;
      If Index = 0 then
         Exec1
      else
         Exec2;
      If AutoR = False then
         WriteLn (' Don''t Reload PGM');
      Window (1,1,80,25);
   end;

   procedure GetTheDir (Path : String; var Count : Integer);
      var
         I, Hold : Integer;
         Temp    : String;
      begin
         If Length(Path)> 3 then Path := Path + '\';
         Temp := Space(15);
         FindFiles (Path+'*.*', '<DIR>', 0, Count);
         Hold := Count;
         GoSort (1, Hold);
         If LoadAllIsOn then
            begin
               FindFiles (Path+'*.*', '', Hold, Count);
               GoSort (Hold + 1, Count);
            end
         else
            begin
               FindFiles (Path+'*.EXE', '', Count, Count);
               GoSort (Hold + 1, Count);
               Hold := Count;
               FindFiles (Path+'*.COM', '', Count, Count);
               GoSort (Hold + 1, Count);
               Hold := Count;
               FindFiles (Path+'*.BAT', '', Count, Count);
               GoSort (Hold + 1, Count);
            end;
      end;

   procedure CColor (atr : word; var Sml : Boolean; var Tmp : String;
                     Var Fc : Integer);
      begin
         Fc := 15 + 128; Sml := False;
         Tmp := DecToBin (Atr);
         If Tmp    = '00000000' then begin Fc := 6;  end;
         If Tmp[3] = '1'        then begin Fc := 7;  end;
         If Tmp[8] = '1'        then begin Fc := 1;  end;
         If Tmp[7] = '1'        then begin Fc := 4;  Sml := True; end;
         If Tmp[6] = '1'        then begin Fc := 4;  end;
         If Tmp[5] = '1'        then begin Fc := 15; end;
         If Tmp[4] = '1'        then begin Fc := 2;  end;
      end;

      procedure STime (T : SearchRec; var bn, Tm : String);
         var
            Dt   : DateTime;
            Sz   : String;
            AmPm : Boolean;
            Temp : String;

         begin
               UnPackTime (T.Time, DT);
               Str        (T.Size, Sz);
               Bn := DecToBin (T.Attr);
               If Bn[4] = '1' then Sz := '  ';
               Sz := LSpace (Sz, 10);
               Str        (Dt.Month:2, TM);
               Tm := Sz +' '+ Tm + '-' + PadNum(Dt.Day, 2) + '-' +
                     PadNum(Dt.Year mod 100, 2);
               AmPm := False;
               If Dt.Hour > 11 then
                  begin
                     Dt.Hour := Dt.Hour - 12;
                     AmPm    := True;
                  end;
               If Dt.Hour = 0  then Dt.Hour := 12;
               Str (Dt.Hour:3,   Temp);
               Tm := Tm + Temp + ':' + PadNum (Dt.Min,2);
               If AmPm then
                  Temp := 'p'
               else
                  Temp := 'a';
               Tm := Tm + Temp;
         end;

   var
     DirNum, DirPage : integer;
     DirCount        : integer;

   procedure DirItem (Y, I : Integer);
      var
         Atr     : String;
         Tmp     : DirStr;
         N       : NameStr;
         E       : ExtStr;
         Sm      : boolean;
         Cl      : integer;
         Tm, Bn  : String;

      begin
         GotoXY (4, Y);
         STime (DirDat[I], Bn, Tm);
         with DirDat[I] do
            begin
               CColor (Attr, Sm, Bn, Cl);
               Color (Cl, 0);
               If I = DirNum + DirPage then Color (0, Cl);
               FSplit (Name, Tmp, N, E);
               If N = '' then begin N := E; E := ''; End;
               WriteLn (' ',RSpace (N,9),RSpace (E,4), Tm, ' ');
            end;
      end;

   procedure UpDir;
      var
         Mx, D : integer;
      begin
         Mx := DirCount;
         If Mx > 19 then Mx := 19;
         Window (4,4, 48,22);
         Color (7,0);
         ClrScr;
         Window (1,1,79,25);
         For D := 1 to Mx do
            DirItem (D+3, D + DirPage);
      end;

   procedure DirUp;
      var
         H, F : integer;
      begin
         H := DirPage;
         F := DirNum;
         DirNum := DirNum - 1;
         DirItem(F+3, H + F);
         while DirNum < 1 do
            begin
               DirPage := DirPage - 1;
               DirNum := DirNum + 1;
            end;
         if H <> DirPage then
           begin
              Window (4,4, 48,22);
              GotoXY (1,1);
              Color (7,0);
              InsLine;
              Window (1,1,79,25);
           end;
          DirItem (DirNum+3, DirPage + DirNum);
      end;

   procedure DirDown;
      var
         H, F : integer;
      begin
         H := DirPage;
         F := DirNum;
         DirNum := DirNum + 1;
         DirItem(F+3, H + F);
         while DirNum > 19 do
            begin
               DirPage := DirPage + 1;
               DirNum := DirNum - 1;
            end;
         if H <> DirPage then
           begin
              Window (4,4, 48,22);
              GotoXY (1,1);
              Color (7,0);
              DelLine;
              Window (1,1,79,25);
           end;
          DirItem (DirNum+3, DirPage + DirNum);
      end;

   var
      CurPath : String;

   procedure Dr;
      var
         Tmp : String;
         bg  : integer;
      begin
         GotoXY (2,2);
         Color (15,0);
         Write ('Directory of ');
         Tmp := CurPath + Space(40);
         bg := Length(CurPath)- 32;
         If bg < 1 then Bg := 1;
         tmp := copy (Tmp, bg, 33);
         GotoXY (16,2);
         Color (14,0);
         Write (Tmp);
      end;

   procedure ComLine (Var Command : String);
      var
         IO : String;
      begin
         Command := '';
         SaveScr (2);
         DoBox;
         GotoXY (21,11);
         Color (0,7);
         Write ('  Please Enter the Command Line:      ');
         GotoXY (21,14);
         Color (7,0);
         Write ('                                      ');
         GotoXY (21,14);
         ReleaseButtons;
         Rkey (Command, 126, 37, Qt);
         HideCursor;
         Command := Trim(UCase(Command));
         LoadScr (2);
      end;

   procedure DoComLine;
      var
         Command : String;
         TP      : DirStr;
         N       : NameStr;
         E       : ExtStr;

      begin
         ComLine (Command);
         If (Command <> '') and (Not Qt) then
            begin
               Index := Index + 1;
               ExPro[Index].Path := CurPath;
               ExPRo[Index].Name := '';
               ExPro[Index].Com  := Command;
               Exec;
            end;
         ReleaseButtons;
      end;

   procedure DoEnter;
      var
         Bn, Tmp : String;
         Temp    : DirStr;
         N       : NameStr;
         E       : ExtStr;
         Command : String;

      begin
         with DirDat[DirPage+ DirNum] do
            begin
               Bn := DecToBin (Attr);
               If Bn[4] = '1' then
                  begin
                     Chdir (Drv + Name);
                     GetDir (Ord(CurPath[1])-64, CurPath);
                     Dr;
                     GetTheDir (CurPath, DirCount);
                     DirNum := 1;
                     DirPage := 0;
                     UpDir;
                  end
               else
                  begin
                     FSplit (Name, Temp, N, E);
                     if Index < 100 then
                        begin
                        if (E = '.EXE') or (E = '.COM') or (E = '.BAT') then
                           begin
                              ComLine (Command);
                              Index := Index + 1;
                              ExPro[Index].Path := CurPath;
                              If E <> '.BAT' then
                                 ExPro[Index].Name := Name
                              else
                                 ExPro[Index].Name := 'CALL ' + Name;
                              ExPro[Index].Com  := Command;
                              Exec;
                           end
                        else
                           Stub;
                        end;
                  end;
            end;
         ReleaseButtons;
      end;

   procedure ScrollBar;
      var
         i : integer;
         H, F : integer;
      begin
         Color (3, 0);
         GotoXY (2, 4 );      Write (Chr(24));
         GotoXY (2, 22);      Write (Chr(25));
         For i := 5 to 21 do
            begin
               GotoXY (2, i);
               WriteLn (Chr(176));
            end;
      end;

   procedure ConEMouse;
      var
         X, Y : Integer;
         H , F : integer;
      begin
         X := MouseX; Y := MouseY;
         If Data = Chr(186) + Chr(24) then Key := Chr(0)+Chr(72);
         If Data = Chr(186) + Chr(25) then Key := Chr(0)+Chr(80);
         { X := X div 8; }
         { Y := Y Div 8; }
         case X of
            4..44: Case Y of
                      4..22 : begin
                                 H := DirPage;
                                 F := DirNum;
                                 if Y - 4 < DirCount then
                                    begin
                                       DirNum := Y - 3;
                                       DirItem (F+3, H + F);
                                       DirItem (DirNum+3, DirPage + DirNum);
                                    end;
                               end;
                    end; { Case Y }
         end; { Case X }
         If MouseSpeed > 0 then Delay (MouseSpeed);
      end;

   procedure ChDrive (var Path : String);
      var
         I        : integer;
         av       : array [1..26] of boolean;
         Temp     : Integer;

      begin
         Drv := Path;
         SaveScr (2);
         DoBox;
         GotoXY (21,11);
         Color (14+128,1);
         Write (' Scanning...                          ');
         for I := 1 to 26 do
            begin
               {$I-}
               Temp := DiskSize (I);
               {$I+}
               If Temp <> -1 then
                  Av[I] := True
               else
                  Av[I] := False;
            end;
         GotoXY (21,11);
         Color (0,7);
         Write (' Select A Drive Letter:               ');
         Window (21,12, 56, 14);
         GotoXY (1, 3);
         Color (15,4);
         For I := 1 to 26 do
            If Av[I] then
               begin
                  TextColor (0);
                  Write (' ', Chr(175));
                  TextColor (15);
                  Write (Chr(I+64));
                  TextColor(0);
                  Write (Chr(174));
               end;
         Window (1,1,80,25);
         repeat
         HideCursor;
         Data :='';
         Key := '';
         While (Data = '') and (Key ='') do
            begin
               ReadMouse (OldX, OldY, OldColor, Data);
               Key := UCase(Inkey);
            end;
         SplitButtons (Data, B1, B2, B3);
         If Key = Chr(27) then
            Data := Chr(186) + Chr(219) + Escape;
         If length(Key) = 1 then
            if av[Ord(Key[1])-64] then
               Data := Chr(175)+ Key[1] + Chr(174);
         If length (Data) = 3 then
            if (Data[1] = Chr(175)) and (Data[3] = Chr(174)) then
               begin
                  Path := Data[2] + ':\';
                  Data := Chr(186) + Chr(219) + Escape
               end;
         until (Data = Chr(186)+Chr(219)+Escape);
         Data := '';
         if Path[1] <> Drv[1] then
            begin
               LoadScr(2);
               Drv  := Path;
               Dr;
               ChDir (Path);
               GetTheDir (Path, DirCount);
               DirNum  := 1;
               DirPage := 0;
               UpDir;
            end
         else
            LoadScr (2);
         ReleaseButtons;
      end;

   var
      i       : Integer;
      jk, Mjk : integer;

   begin
      AutoR := AutoReload;
      Index := 0;
      GetDir (0, StartPath);
      DirNum  := 1;
      DirPage := 0;
      CurPath := Copy(StartPath,1,3);
      CHDir (CurPath);
      Drv := CurPath;
      EditWindow;
      EditSpec;
      ScrollBar;
      Color (7,0);
      Exec;
      Dr;
      GetTheDir (CurPath, DirCount);
      For I := 1 to MaxExPro do
         begin
            ExPro[I].Path := '';
            ExPro[I].Name := '';
            ExPro[I].Com  := '';
         end;
      UpDir;
      repeat
      HideCursor;
      Data :='';
      Key := '';
      While (Data = '') and (Key ='') do
         begin
            ReadMouse (OldX, OldY, OldColor, Data);
            Key := Inkey;
         end;
      SplitButtons (Data, B1, B2, B3);
      If B1 = true then
          ConEMouse;
      if Key <>'' then
         Case Ord(Key[1]) of
            27 : Data := Chr(186)+Chr(219)+Escape;
            13 : Data := Ent;
             0 : Case ord(Key[2]) of
                    59 : Data := Help;
                    60 : Data := Save;
                    61 : Data := Forget;
                    62 : Data := Drive;
                    63 : Data := AllFiles;
                    64 : Data := Prompt;
                    65 : Data := Auto;
                    72 : if DirNum + DirPage > 1 then DirUp;
                    80 : if DirNum + DirPage < DirCount then DirDown;
                    71 : if DirNum + DirPage > 1 then
                            begin
                               DirNum := 1;
                               DirPage := 0;
                               UpDir;
                            end;
                    79 : if DirNum + DirPage < DirCount then
                            begin
                               DirNum := DirCount;
                               DirPage := 0;
                               While DirNum > 19 do
                                  begin
                                     DirNum := DirNum - 1;
                                     DirPage := DirPage + 1;
                                  end;
                               UpDir;
                            end;
                    73 : if DirNum + DirPage > 1 then
                            begin
                               Mjk := DirNum + DirPage - 1;
                               If Mjk > 19 then Mjk := 19;
                               for jk := 1 to Mjk do
                                  DirUp;
                            end;
                    81 : if DirNum + DirPage < DirCount then
                            begin
                               Mjk := DirCount - DirNum - DirPage;
                               If Mjk > 19 then Mjk := 19;
                               for jk := 1 to Mjk do
                                  DirDown;
                            end;

                 end; {End Of Case Key(2)}
      end; {End of Case Key(1)}
      if Data = Ent then
         DoEnter;
      if Data = AllFiles then
         begin
            if LoadAllIsOn then
               LoadAllIsOn := False
            else
               LoadAllIsOn := True;
            GetTheDir (CurPath, DirCount);
            DirNum  := 1;
            DirPage := 0;
            UpDir;
            ReleaseButtons;
         end;
      If Data = Prompt then
         DoComLine;
      If Data = Drive then
         ChDrive (CurPath);
      if Data = Auto then
         begin
           if AutoR then
              AutoR := False
           else
              AutoR := True;
           Exec;
           ReleaseButtons;
         end;
      If Data = Help then
         DirHelp;
      If Data = Forget then
         begin
            if Index > 0 then
               begin
                  Index := Index - 1;
                  Exec;
                  ReleaseButtons;
               end
            else
               Stub;
         end;
      until (Data = Chr(186)+Chr(219)+Escape) or (Data = Save);
      ChDir (StartPath);
      if Data = Save then
         GoSave;
      if Data = Chr(186)+ Chr(219) + Escape then
         Data := 'NoSave'
      else
         Data := '';
      LoadAllIsOn := False;
   end;


