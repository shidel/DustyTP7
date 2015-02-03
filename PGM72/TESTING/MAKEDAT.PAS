{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

program MakedataFile;
   uses Cursor,QCrt;

   type
      ChrFile = File of Char;
      MenuRec = record
                   Discription : String[45];
                   Location    : LongInt;
                end;
      MenuFile = file of MenuRec;
   const
      Max = 100;
      Tm  = 30;

   var
      MenuData : array [1..Max+1] of MenuRec;
      Tot      : Integer;
      MenuF    : MenuFile;
      I,k      : integer;
      Hl       : String;
      HStr     : String;
      DataFile : ChrFile;

Procedure WriteStr (var FileName : ChrFile; Hold : String);
   var
     j  : Integer;
     Ch : Char;
   begin
      For j := 1 to Length(Hold) do
        begin
           Ch := Hold[j];
           Write (FileName, Ch);
        end;
        Ch := Chr(1);
        Write (FileName, Ch);
   end;

   var
     ch : Char;
     Ii  : Integer;
     Hs : String;
     Ps : LongInt;

begin
   Ps := 0;
   For Ii := 1 to Tm do
      begin
         with MenuData[1] do
            begin
              Str (Ii, Hs);
              Discription := AddSpace('Test Title #'+Hs+'          ',45);
              Location := 0;
            end;
         for I := 2 to Max +1 do
             with MenuData[I] do
                begin
                   Str ((ii-1)*Max+I-1,Hl);
                   Discription := AddSpace('Demo file discription #'+Hl,45);
                   Ps := Ps +30;
                   Location := Ps;
                end;
         ClrScr;
         WriteLn ('Menu #',Hs);
         Assign (MenuF, Hs+'.Mnu');
         Rewrite(MenuF);
         for i := 1 to 1+max do
         Write (MenuF, MenuData[i]);
         Close (MenuF);
      end;
   ClrScr;
   Assign (DataFile, 'Pgm72.Dat');
   ReWrite (DataFile);
   Ps := 0;
   For I := 1 to Max*TM  do
     begin
       Ps := Ps + 30;
       WriteLn (ps :20,'Position ',I:20,' File');
       seek (DataFile, Ps);
       HStr := 'C:';
       WriteStr (DataFile, HStr);
       HStr := 'CD\';
       WriteStr (DataFile, HStr);
       Str (I, HStr);
       HStr := 'PROGRAM'+HStr;
       WriteStr (DataFile, HStr);
       HStr := Chr(2);
       WriteStr (DataFile, HStr);
     end;
   Close (DataFile);
end.
