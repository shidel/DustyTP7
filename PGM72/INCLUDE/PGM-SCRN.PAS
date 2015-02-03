{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}


Procedure LoadScr (ScrNum : integer);
          begin
             ColorScreen := KeepScreen[ScrNum]
          end;

Procedure SaveScr (ScrNum : integer);

   begin
      KeepScreen[ScrNum] := ColorScreen;
   end;

procedure ChColor (Num : Integer);
   begin
      Color (Colors[Num,1], Colors[Num,2]);
   end;

procedure MainScreen;
   var
      Temp, Temp2 : String[77];
      i           : integer;

   begin
      TextMode (CO80);
      ChColor (1);
      ClrScr;
      ChColor (2);
      Temp := ChrStr(Chr(205),53);
      Temp2 := Space(53);
      GotoXY(1,1);
      Write (Chr(201),Temp,  Chr(187), Chr(201), Copy(Temp,1,22), Chr(187));
      GotoXY(1,3);
      Write (Chr(204),Temp,  Chr(185), Chr(200), Copy(Temp,1,22), Chr(188));
      GotoXY(1,4);
      Write (Chr(186),Temp2, Chr(186), Chr(201), Copy(Temp,1,22), Chr(187));
      GotoXY(1,7);
      Write (Chr(186),Temp2, Chr(186), Chr(204), Copy(Temp,1,22), Chr(185));
      GotoXY(1,23);
      Write (Chr(186),Temp,  Chr(186), Chr(204), Copy(Temp,1,22), Chr(185));
      GotoXY(1,25);
      Write (Chr(200),Temp,  Chr(188), Chr(200), Copy(Temp,1,22), Chr(188));
      For i := 2 to 24 do
          begin
             if (i <> 3) and (i<>4) and (i<>7) and (i<>23) then
                begin
                   GotoXY (1,i);
                   Write (Chr(186),Temp2, Chr(186));
                   Write (Chr(186), Copy(Temp2,1,22), Chr(186));
                end;
          end;
       ChColor (0);       GotoXY (57,  2);      Write (Version);
       ChColor (4);       GotoXY ( 3,  2);      Write ('Menu Title:  ');
       ChColor (5);       GotoXY (2, 24);       Write (' ',Enter,' ');
       ChColor (12);      GotoXY (15, 24);      Write (' ',Help,' ');
       ChColor (12);      GotoXY (25, 24);      Write (' ',Search, ' ');
       ChColor (12);      GotoXY (37, 24);      Write (' ',Edit,' ');
       ChColor (5);       GotoXY (47, 24);      Write (' ',Escape,' ');
       ChColor (8);       GotoXY (57,  8);      Write (' Availible Menus:     ');
       ChColor (6);       GotoXY ( 2,  4);      Write (Chr(24));
       ChColor (6);       GotoXY ( 2, 22);      Write (Chr(25));
       ChColor (7);       GotoXY (57, 10);      Write (Chr(24));
       ChColor (7);       GotoXY (57, 22);      Write (Chr(25));
       ChColor (6);
       For i := 5 to 21 do
          begin
             GotoXY (2, i);
             WriteLn (Chr(176));
          end;
       ChColor (7);
       For i := 11 to 21 do
          begin
             GotoXY (57, i);
             WriteLn (Chr(176));
          end;
      SaveScr(1);
   end;

procedure DisplayDis(i : integer);
   begin
      with MenuDis[i] do
         begin
            GotoXY (4,I-DisPag+3);
            if DisNum + DisPag = i then  Color (Colors[10,2],Colors[10,1]);
            Write (I:3, '-');
            TextColor (Colors[12,1]);
            if Tag[i] then
               Write (Chr(4))
            else
               Write (' ');
            if DisNum + DisPag = i then
               Color (Colors[10,2],Colors[10,1])
            else
               ChColor (10);
            Write (Discription)
         end;
            ChColor (10)
      end;

procedure ScrollUp;
   begin
      if DisNum+DisPag > 1 then
         begin
            DisNum := DisNum - 1;
            ChColor (10);
            DisplayDis(DisNum + DisPag + 1);
            If DisNum < 1 then
               begin
                  window (3,4,54,22);
                  GotoXY(1,1);
                  InsLine;
                  Window (1,1,80,25);
                  DisNum := 1;
                  DisPag := DisPag - 1;
               end;
            DisplayDis(DisNum+DisPag);
         end;
   end;

procedure ScrollDown;
   begin
      if DisNum+DisPag < TotDis then
         begin
            DisNum := DisNum + 1;
            ChColor(10);
            DisplayDis(DisNum+DisPag-1);
            If DisNum > 19 then
               begin
                  Window (3,4,54,22);
                  GotoXY (1,1);
                  DelLine;
                  Window (1,1,80,25);
                  DisNum := 19;
                  DisPag := DisPag + 1;
               end;
            DisplayDis(DisNum+DisPag);
         end;
   end;

procedure UpDateDiscript;
   var
     Mx, i : Integer;
   begin
       ChColor (10);
       Mx := 19;
       if Dispag+Mx > TotDis then
          Mx := TotDis-DisPag;
       for i := DisPag+1 to DisPag + Mx  do
          DisplayDis (i);
    end;

procedure PageUp;
   var
     jk : Integer;
   begin
      for JK := 1 to 19 do
         ScrollUp;
   end;

procedure PageDown;
   var
      jk : integer;
   begin
      For jk := 1 to 19 do
         ScrollDown;
   end;

procedure GoHome;
   begin
      DisNum := 1;
      DisPag := 0;
      UpDateDiscript;
   end;

procedure GoEnd;
   begin
     DisNum := TotDis;
     DisPag := 0;
     While DisNum > 19 do
        begin
           DisNum := DisNum - 1;
           DisPag := DisPag + 1;
        end;
     UpDateDiscript;
   end;


   var
      HoldTime, HoldDate   : String;

procedure UpDateScreen;
   var
     I, X, Y : integer;
     Mx      : integer;

   begin
     LoadScr (1);
     HoldTime := '';
     HoldDate := '';
     UpDateDiscript;
     GotoXY (16,2);
     ChColor (11);
     Write (Copy (Title,1,38));
     Mx := TotMenus;
     If Mx >24 then Mx := 24;
     ChColor (9);
     For I := 1 to Mx do
        begin
           X := 59;
           Y := I;
           If Y > 12 then
              begin
                 Y := Y - 12;
                 X := X + 10;
              end;
           GotoXY (X, Y+9);
           If I = CurrentMnu then
             Color (Colors[9,2], Colors[9,1]);
           Write (' ', Menus[I+MenuPag], Copy(spc, 1, 9-length(Menus[I+MenuPag])));
           If I = CurrentMnu then
             ChColor (9);
        end;
{       ReleaseButtons;}
   end;
procedure Squash;
   var
      I : Integer;
   begin
      Color (7,0);
      for I := 1 to 14 do
         begin
            GotoXY (1,13);
            DelLine;
            DelLine;
            GotoXY (1,1);
            InsLine;
            OldX := 0;
            OldY := 0;
         end;
   end;

procedure Blank;
   begin
         if TotWait >= BlankOut then
            begin
               PopMouse;
               Squash;
               while (Inkey = '') and (Not MouseButton1) do;
               LoadScr (1);
               UpDateScreen;
               TotWait := 0;
            end;
   end;

procedure BoxWindow (Md : Integer);
   var
      I : integer;
      H : String;

   begin
      SaveScr (2);
      Squash;
      ChColor (2);
      GotoXY (1,1);
      Window (1,1,80,25);
      For I := 2 to 24 do
        begin
           GotoXY (1,I);     Write (Chr(186));
           GotoXY (79,I);    Write (Chr(186));
        end;
      GotoXY (1,1);
      H := ChrStr(Chr(205),77);
      Write (Chr(201), H, Chr(187));
      GotoXY (1,25);
      Write (Chr(200), H, Chr(188));
      Window (2,2,78,24);
      case Md of
         1 : ChColor (14);
         2 : ChColor (15);
      end;
      ClrScr;
      Window (1,1,80,25);
      GotoXY (3, 24);
      ChColor (5);
      Write (Escape, ' ');
      Color (Colors[5,2],Colors[5,2]);
      GotoXY (2,24);
      Write (Chr(219));
   end;

procedure HelpWindow;
   begin
      BoxWindow (1);
   end;

procedure EditWindow;
   begin
      BoxWindow (2);
   end;

procedure DoBox;
   var
      i : integer;
   begin
      GotoXY (20,10);
      Color (15,4);
      Write (Chr(201),ChrStr(Char(205),38),Chr(187));
      For I := 11 to 14 do
         begin
            GotoXY (20,i);
            Write (Chr(186),'                                      ',Chr(186));
         end;
      GotoXY (20,15);
      Write (Chr(200), ChrStr(Char(205),38),Chr(188));
   end;


