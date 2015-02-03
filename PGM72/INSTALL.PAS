program PGM_Install;

   Uses QCrt, Dos, Errors, Cursor;


   type
     Screen     = array [1..25,1..80] of word;

   var
      ColorScreen     : Screen absolute $B800:$0000;
      KeepScreen      : Array[1..2] of Screen;

Procedure LoadScr (ScrNum : integer);
          begin
             ColorScreen := KeepScreen[ScrNum]
          end;

Procedure SaveScr (ScrNum : integer);

   begin
      KeepScreen[ScrNum] := ColorScreen;
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
         end;
   end;

procedure BoxWindow;
   var
      I : integer;
      H : String;

   begin
      Squash;
      Color (6,0);
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
      Color (7,0);
      ClrScr;
      Window (1,1,80,25);
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



{-----------------------------------------------------------------------------}
{ Heap Usage For File Copy }

   type
      DataArray    = array [1..5120] of Word;
      DatStr       = record
                        Data    : DataArray;
                        NumRead : integer;
                     end;
      RecPtr       = ^Rec;
      Rec          = record
                        Next, Prior : RecPtr;
                        Data        : DatStr;
                     end;
   const
      RecSize      = SizeOf (Rec);

   var
      FirstItem, LastItem, ThisItem,
      NewItem, MarkItem                : RecPtr;
      Heap_Top                         : ^integer;

   procedure Make_Heap;
      begin
         Mark ( Heap_Top );
         FirstItem := NIL;
         LastItem  := NIL;
         ThisItem  := NIL;
      end;

   procedure Put_Heap (Data : DatStr);
      begin
         New ( NewItem );
         if FirstItem = NIL then
            begin
               FirstItem       := NewItem;
               MarkItem        := NewItem;
               LastItem        := NewItem;
               LastItem^.Prior := NIL;
               LastItem^.Next  := NIL;
            end
         else
            begin
               MarkItem        := LastItem;
               LastItem^.Next  := NewItem;
               LastItem        := NewItem;
               LastItem^.Prior := MarkItem;
               LastItem^.Next  := NIL;
            end;
         NewItem^.Data := Data;
      end;

   procedure Get_Heap (var i : LongInt; var Data : DatStr);
      var
         SearchItem : RecPtr;
         j          : LongInt;
      begin
         SearchItem := FirstItem;
         j := 0;
         while (j < i) do
            begin
               j := j + 1;
               if SearchItem^.Next = NIL then
                  i := j
               else
                  SearchItem := SearchItem^.Next;
            end;
         Data := SearchItem^.Data;
      end;

   procedure Kill_Heap;
      begin
         Release ( Heap_Top );
      end;

{-----------------------------------------------------------------------------}

   var
      i, Cr, Cw           : LongInt;
      Temp                : DatStr;
      Hold                : DataArray;
      FromF, ToF          : File;
      FIn, FOut           : String;
      NumRead, NumWritten : Word;
      Fsize               : Longint;
      Block1, Block2      : String;
      Cy                  : Integer;

procedure DoError (ErrNum : Integer; FName : String);
   begin
      If ErrNum > 0 then
         begin
            GotoXY (1,Cy+3);
            WriteLn;
            WriteLn (ErrorMessage(ErrNum), ', in file ', FName);
            {$I-}
            If FName <> FOut then
               Close (ToF)
            else
               Close (FromF);
            {$I+}
            Pause;
            Halt(1);
         end;
   end;

   procedure Bar (ty : integer; Per : real);
      var
        i   : integer;
        h   : String;
      begin
        i :=  Trunc(65 * Per / 100);
        GotoXY (1,Cy + ty);
        TextColor (7);
        Case Ty of
           1 : Write (' Read ');
           2 : Write ('Wrote ');
           3 : Write (' Comp ');
        end;
        Write (Per:6:2,'% ');
        h := Copy (Block2,1,i);
        TextColor (10);
        Write (h);
        TextColor (8);
        if length(h)<65 then
           Write (Copy(Block1,1,65-i));
        TextColor (7);
      end;

   procedure DoPrcComp;
     var
        per    : real;
        i, j   : Integer;
        h      : String;
     begin
        per := 0;
        if (Cr+Cw) > 0 then
           Per := (Cr+Cw) / (FSize * 2) * 100;
        Bar (3, Per);
     end;


   procedure DoPrcRead (Max, At : LongInt);
     var
        per    : real;

     begin
        per := 0;
        if Max > 0 then
           Per := At / Max * 100;
        Bar (1, Per);
        DoPrcComp;
     end;

   procedure DoPrcWrite (Max, At : LongInt);
     var
        per    : real;

     begin
        per := 0;
        if Max > 0 then
           Per := At / Max * 100;
        Bar (2, Per);
        DoPrcComp;
     end;

{-----------------------------------------------------------------------------}
   procedure DoRead (var Num : LongInt);
       var
         Red : integer;
      begin
         Make_Heap;
         Num := 0;
         NumRead := 0;
         repeat
            {$I-}
            BlockRead(FromF, Hold,
                      SizeOf(Hold), Red);
            {$I+}
            DoError (IOResult, FIn);
            Num          := Num + 1;
            NumRead      := NumRead + Red;
            Cr           := Cr + Red;
            Temp.Data    := Hold;
            Temp.NumRead := Red;
            DoPrcRead (Fsize, Cr);
            Put_Heap (Temp);
         until (MaxAvail < 1000 + SizeOf(Rec)) or (Red = 0);
      end;

{-----------------------------------------------------------------------------}
   procedure DoWrite (Num : LongInt);
      var
         red, wrt, h : integer;
         i           : LongInt;

      begin
         NumWritten := 0;
         h          := NumRead;
         for i := 0 to Num-1 do
            begin
               Get_Heap (i, Temp);
               Red        := Temp.NumRead;
               Hold       := Temp.Data;
               {$I-}
               BlockWrite(ToF, Hold , Red, Wrt);
               {$I+}
               DoError (IOresult, FOut);
               If Red <> Wrt then DoError (101, FOut);
               NumWritten := NumWritten + Wrt;
               Cw         := Cw + Wrt;
               h          := h - Red;
               DoPrcWrite (FSize, Cw);
            end;
         Kill_Heap;
      end;

   var
     j : integer;
     Path1, Path2  : DirStr;
     N1, N2        : NameStr;
     E1, E2        : ExtStr;
     h             : String;

{-----------------------------------------------------------------------------}

procedure GoSplit;
begin
   WriteLn;
   FIn  := FExpand (FIn);
   FOut := FExpand (FOut);
   FSplit (FIn,  Path1, N1, E1);
   FSplit (FOut, Path2, N2, E2);
   If N2+E2 = '' then
      begin
         FOut := FOut + N1 + E1;
         FSplit (FOut, Path2, N2, E2);
      end;
end;



{-----------------------------------------------------------------------------}

   procedure DoInit;
      begin
         Block1 := ChrStr(Chr(176),70);
         Block2 := ChrStr(Chr(176),70);
         Cr     := 0;
         Cw     := 0;
         Cy     := WhereY;
         GoSplit;
         Assign  (FromF, FIn);
         Assign  (ToF,   FOut);
         {$I-}
         Reset   (FromF, 1);
         {$I+}
         DoError (IOresult, FIn);
         Fsize := FileSize (FromF);
         Close (FromF);
      end;

   procedure DoHeading;
      begin
         Str (FSize,h);
         h := h + ' bytes';
         h := h + Space(20-Length(h));
         Write   ('Copy File: ',N1+E1:12, ' as ' , N2+E2,
                  Space(14-Length(N2+E2)));
         WriteLn ('Size:  ', h);
         WriteLn ('     From: ', Path1);
         WriteLn ('       To: ', Path2);
         Cy    := WhereY;
         If Cy > 21 then
            begin
               for j := 1 to 4 do
                  WriteLn;
               Cy := 21;
            end;
         DoPrcRead  (FSize, 0);
         DoPrcWrite (FSize, 0);
      end;

    procedure GoCopy;
      begin
         DoInit;
         DoHeading;
         {$I-}
         Reset   (FromF,  1);
         {$I+}
         DoError (IOresult, FIn);
         {$I-}
         Rewrite (ToF,    1);
         {$I+}
         DoError (IOresult, FOut);
         Make_Heap;
         repeat
            DoRead  (i);
            DoWrite (i);
         until (NumRead = 0) or (NumWritten <> NumRead);
         Close(FromF);
         Close(ToF);
         WriteLn;
      end;

   var
     PathName : String;
     BatName  : String;
     Drv      : String[2];
     Key      : String;

    Procedure CheckPath;
       var
          MK : String;
          Ps : Integer;
       begin
          if FOut[Length(FOut)] <> '\' then FOut := FOut + '\';
          FOut := FExpand (FOut);
          PathName := FOut;
          MK := '';
          For Ps := 1 to Length (FOut) do
             begin
                MK := MK + FOut[ps];
                If (Ps > 3) and (Mk[Ps] = '\') then
                   begin
                     {$I-}
                     Mkdir (Copy(MK,1, Ps - 1));
                     {$I+}
                     If IOResult = 0 then
                       Write;
                   end;
             end;
       end;

    var
      Hx, Hy : integer;

   procedure MakeBats;
      var
        FN : Text;
      begin
         Assign (FN, Copy (PathName,1,3) + 'PGM.BAT');
         {$I-}
         Rewrite (FN);
         {$I+}
         DoError (IOResult, Copy(PathName,1,3)+'PGM.BAT');
         WriteLn (FN, '@ECHO OFF');
         WriteLn (FN, DRV);
         WriteLn (FN, 'CD ' + Copy (PathName, 3, Length(PathName)-3));
         WriteLn (FN, 'PGM72 %1');
         WriteLn (FN, 'RN');
         Close (FN);
         If BatName <> 'PGM' then
            begin
               Assign (FN, Copy (PathName,1,3) + BatName + '.BAT');
               {$I-}
               Rewrite (FN);
               {$I+}
               DoError (IOResult, Copy(PathName,1,3) + BatName + '.BAT');
               WriteLn (FN, '@ECHO OFF');
               WriteLn (FN, DRV);
               WriteLn (FN, 'CD ' + Copy (PathName, 3, Length(PathName)-3));
               WriteLn (FN, 'PGM72 %1');
               WriteLn (FN, 'RN');
               Close (FN);
            end;
      end;

   procedure DoInstall;
      begin
         CheckPath;
         GoCopy;
         MakeBats;
         LoadScr(1);
         GotoXY (HX, HY);
         WriteLn;
         WriteLn;
         WriteLn ('Installation Is Complete.');
         WriteLn;
         Color (7,0);
         WriteLn ('To Execute The Program Manager Version #7.2 from any directory,');
         WriteLn ('Make Sure that ', Drv, '\ Is In Your Path Command.');
         WriteLn ;
         WriteLn ('Type:');
         WriteLn ('  ', BatName);
      end;
   var
      k : integer;
      T : String;

begin
   SaveScr (1);
   Hx := WhereX;
   HY := WhereY;
   HideCursor;
   FIn := 'PGM72.EXE';
   FOut := 'C:\PGM72\';
   BatName := 'PGM';
   Color (7,0);
   ClrScr;
   BoxWindow;
   Color (1,0);
   T := ChrStr(Chr(176),77);
   For k := 2 to 24 do
      begin
         GotoXY (2, k);
         Write (T);
      end;
   Color (1,7);
   T := ChrStr(Chr(205),46);
   GotoXY (17,3);   Write (Chr(201), T, Chr(187));
   GotoXY (17,4);
   Write (Chr(186),' Program Manager Version #7.2 Install Program ', Chr(186));
   GotoXY (17,5);   Write (Chr(200), T, Chr(188));
   Color (4,7);
   GotoXY (17,8);   Write (Chr(201), T, Chr(187));
   GotoXY (17,12);   Write (Chr(200), T, Chr(188));
   T := Space (46);
   For k := 9 to 11 do
      begin
         GotoXY (17,K);
         Write (Chr(186), T, Chr(186));
      end;
   Repeat
   HideCursor;
   Color (0,7);
   GotoXY (19,9);    Write ('F1. Install');
   Drv := FOut;
   GotoXY (19, 10);  Write ('F2. Select Path ----- ', Copy (FOut+T, 1,23));
   GotoXY (19, 11);  Write ('F3. Execution File -- ', BatName, Space (8));
   Key := Inkey;
   If Key = Chr(0)+Chr(60) then
      begin
         GotoXY (41, 10);
         Color (14,0);
         RKey (FOut, 127, 22);
         FOut := Trim(Ucase(FOut));
      end;
   If Key = Chr(0)+Chr(61) then
      begin
         GotoXY (41, 11);
         Color (14,0);
         RKey (BatName, 8, 7);
         BatName := UCase(Trim(BatName));
      end;
   Until (Key = Chr(27)) or (Key = Chr(0)+Chr(59));
   Squash;
   GotoXY (1,1);
   NormCursor;
   if Key = Chr(0)+Chr(59) then
      DoInstall
   else
      begin
         LoadScr(1);
         GotoXY (Hx, Hy);
      end;
end.

