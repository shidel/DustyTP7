{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

Unit Pgm_DLog;

interface

   Uses QCrt, Dos, Pgm_Unit;
   const
      MaxBinary = 8;

   type
      DirDataStr   = SearchRec;
      DirDataRec   = DirDatastr;
      DirRecPtr    = ^DirRec;
      DirRec       = record
                        Next, Prior : DirRecPtr;
                        Data        : DirDataRec;
                     end;
      Point         = record
                        First, Last, This,
                        New, Mark           :  DirRecPtr;
                        Top                 : ^integer;
                     end;
   procedure Make_DirHeap (Var P : Point);
   procedure Put_DirHeap  (Var P : Point; Data : DirDataRec);
   procedure Get_DirHeap  (var P : Point; var i : LongInt;
                           var Data : DirDataRec);
   procedure Kill_DirHeap (P : Point);
   procedure LogDir (Var DirP : Point; Path : String; var Total : Integer);
   procedure ListDir (Var DirP : Point; Count : integer);
   function  DecToBin (D : Integer) : String;

implementation

function DecToBin (D : integer) : String;
   var
      i    : Integer;
      Temp : String;

   begin
      Temp := '';
      While d > 0 do
         begin
            if Odd(d) then
               Temp := '1' + Temp
            else
               Temp := '0' + Temp;
            d := d shr 1;
         end;
      While Length (Temp) < MaxBinary do
         Temp := '0' + Temp;
      DecToBin := Temp;
   end;

   const
      DirRecSize   = SizeOf (DirRec);

   procedure Make_DirHeap (Var P : Point);
      begin
         Mark ( P.Top );
         P.First := NIL;
         P.Last  := NIL;
         P.This  := NIL;
      end;

   procedure Put_DirHeap (Var P : Point; Data : DirDataRec);
      begin
         New ( P.New );
         if P.First = NIL then
            begin
               P.First       := P.New;
               P.Mark        := P.New;
               P.Last        := P.New;
               P.Last^.Prior := NIL;
               P.Last^.Next  := NIL;
            end
         else
            begin
               P.Mark        := P.Last;
               P.Last^.Next  := P.New;
               P.Last        := P.New;
               P.Last^.Prior := P.Mark;
               P.Last^.Next  := NIL;
            end;
         P.New^.Data := Data;
      end;

   procedure Get_DirHeap (var P : Point; var i : LongInt; var Data : DirDataRec);
      var
         SearchItem : DirRecPtr;
         j          : LongInt;
      begin
         SearchItem := P.First;
         j := 1;
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

   procedure Kill_DirHeap (P : Point);
      begin
         Release ( P.Top );
      end;

{-----------------------------------------------------------------------------}

   procedure LogDir (Var DirP : Point; Path : String; var Total : Integer);
      var
         Temp : DirDataRec;
      begin
         Path  := FExpand (Path);
         Total := 0;
         FindFirst (Path, AnyFile, Temp);
         If DosError = 0 then
            While (MaxAvail > 100 + DirRecSize) and (DosError = 0) do
               begin
                  Put_DirHeap ( DirP, Temp);
                  Total := Total + 1;
                  FindNext (Temp);
               end;
      end;

   procedure ListDir (Var DirP : Point; Count : integer);
      var
         Temp : DirDataRec;
         i    : LongInt;
      begin
         WriteLn;
         For i := 1 to Count do
            begin
               Get_DirHeap (DirP, i, Temp);
               Color (7,1);
               Write (' ',Temp.Name,Space (14-Length(Temp.Name)));
               Color (7,0);
               WriteLn;
            end;
      end;
end.

