{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

   const
      MaxDir = 512;
   type
      DirData = array [0..MaxDir] of SearchRec;
   var
      DirDat : DirData;
      VolumeID : SearchRec;

procedure FindFiles (Path : PathStr; Atb : String; St : Integer;
                     var Count : integer);
   var
      Data     : SearchRec;
      P        : Point;
      I        : LongInt;
      C        : Integer;
      Atr      : String;
   begin
      Make_DirHeap (P);
      LogDir (P, Path, C);
      Count := St;
      For I := 1 to C do
         begin
            Get_DirHeap (P, I, Data);
            Atr := DecToBin (Data.Attr);
            If ((Atb =  '<DIR>') and (Atr[4] =  '1')) or
               ((Atb <> '<DIR>') and (Atr[4] <> '1')) then
                  If Atr[5] <> '1' then
                     begin
                        Count := Count + 1;
                        DirDat[Count] := Data;
                     end;
            If (Atr[5] =  '1') then
               VolumeID := Data;
         end;
      Kill_DirHeap (P);
   end;

procedure GoSort (St, Count : Integer);
  procedure Sort (l, r, tp : integer);
     var
        i, j : integer;
        x, y : SearchRec;

     begin
        i := l; j := r; x := DirDat[ ( l + r ) div 2 ];
        repeat
           if tp = 1 then
              begin
                 while DirDat[i].Attr < x.Attr do i := i + 1;
                 while x.Attr < DirDat[j].Attr do j := j - 1;
              end
           else
              begin
                 while DirDat[i].Name < x.Name do i := i + 1;
                 while x.Name < DirDat[j].Name do j := j - 1;
              end;
           if i <= j then
              begin
                 y := DirDat[i]; DirDat[i] := DirDat[j]; DirDat[j] := y;
                 i := i + 1; j := j - 1;
              end;
        until i > j;
        if l < j then Sort ( l, j, tp );
        If i < r then Sort ( i, r, tp );
     end;

     var
        Phi, Plo, i : integer;

  begin
     Sort (St, Count, 1);
     if St > 1 then
        for i := 1 to 63 do
           begin
             Phi := Count;
             Plo := St;
             While (DirDat[Plo].Attr <> i) and (Plo < count) do Plo := Plo + 1;
             If (Plo < count) then
                 While (DirDat[Phi].Attr <> i) and (Phi > 1) do Phi := Phi - 1;
             if Plo < PHi then
                 Sort (PLo, PHi, 0);
           end
        else
           Sort (St, Count, 0);
  end;

