{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

program TestData;

    Uses QCrt, Dos, Pgm_Unit;

{$I PGM-DISK.PAS}

    const
       Comm  : Array [1..16] of String[10] =
              ('CALL', 'CHCP', 'COPY', 'CTTY', 'DEL', 'FOR', 'GOTO', 'IF',
               'LOADHIGH', 'LH', 'RENAME', 'REN',
               'SET', 'SHIFT', 'TYPE', 'VERIFY');

         Max = 12;
      Single : array [1..Max] of String[10] =
              ('CD', 'CHDIR', 'CLS', 'DATE', 'DIR', 'EXIT', 'PATH',
               'PAUSE', 'PROMPT', 'TIME', 'VER', 'VOL');
    var
       Data  : Array [1..100] of String;
       HPath, Cpath       : PathStr;
{      Dir                : DirStr;
       n                  : NameStr;
       e                  : ExtStr;}
       Path, Hold         : String;
       I                  : integer;
       Drv                : String;
       U, Nc              : boolean;
       Dir                : Byte;
       DirList            : DirData;
       Srp                : Array [0..20] of PathStr;
       TSrp               : Integer;

procedure SplitSrp;
   var
      l : integer;
      H : String;
      M : Char;

   begin
      Tsrp := 0;
      H := '';
      For L := 1 to Length(Path) do
        begin
           m := Path[L];
           If m =';' then
              begin
                 TSrp := Tsrp + 1;
                 Srp[Tsrp] := H;
                 H := '';
              end
           else
              begin
                 H := H + m;
              end
        end;
   end;

function Cd (S : String) : Integer;
   begin
     {$I-}
     If (Length(S)>1) and (S[2] =':') then
        ChDir (S)
     else
        ChDir (Drv+S);
     {$I+}
     Cd := IoResult;
   end;

function Drive (Ch : Char) : Integer;
   var
      Pt : String;
      Hl : Integer;
   begin
      {$I-}
      GetDir (Ord(Ch)-64, Pt);
      ChDir  (Ch+':\');
      {$I+}
      Hl := IoResult;
      If Hl = 0 then
         begin
            Drv := Ch + ':';
            ChDir (PT);
         end;
      Drive := Hl;
   end;

procedure GoFind (Var H : Integer);
   var
     P, g, SF : String;
    k, j, Tot : Integer;
            n : NameStr;
            e : ExtStr;
           Pt : PathStr;
            D : DirStr;
   begin
      Sf := Hold;
      If Copy(Sf,1,5) = 'CALL ' then
         begin
            Sf := Copy (Sf,6,Length(Sf));
            FSplit (Sf,d,n,e);
            If E = '' then E := '.BAT';
            Sf := D+n+e;
         end;
      If (Length(Sf)>1) and (Sf[2] <> ':') then
         Sf := Drv+Sf;
      Srp[0] := FExpand (Sf);
{     WriteLn;}
      For j := 0 to Tsrp do
         begin
            if j = 0 then
               P := (Srp[0])
            else
               begin
                  FSplit (Sf,d,n,e);
                  g := Srp[J];
                  If g[Length(g)]<>'\' then
                     g := g + '\';
                  P := g+n+e;
               end;
            FSplit (P,D,N,E);
{           WriteLn (P);
            WriteLn (D);}
            FindFiles (D, '', DirList, Tot);
            For k := 1 to Tot do
               begin
                 if E <> '' then
                    If DirList[k].Name = N+e Then
                       begin
                          H := 0;
                          k := Tot;
                          J := Tsrp;
                       end;
                 If E = '' then
                    If (DirList[k].Name = N + '.EXE') or
                       (DirList[k].Name = N + '.COM') or
                       (DirList[k].Name = N + '.BAT') Then
                       begin
                          H := 0;
                          k := Tot;
                          J := Tsrp;
                       end;
               end;
         end;
   end;

procedure Check;
    var
       H, L : Integer;
       HH   : String;
    begin
        U  := False;
        Nc := False;
        H := -1;

{Change Directory}
        For L := 1 to Max do
           If Hold = Single[L] then
              H := 0;
        If Copy(Hold,1,2)= 'CD' then
           begin
              HH := Copy (Hold,3,Length(Hold));
              If (Hh[1] = '\') or (Hh[1] = ' ') or (Hh[1] = '.') then
                 H := Cd (Trim(Hh));
           end;
        If Copy(Hold,1,5)= 'CHDIR' then
           begin
              HH := Copy (Hold,6,Length(Hold));
              If (Hh[1] = '\') or (Hh[1] = ' ') Or (Hh[1] = '.') then
                 H := Cd (Trim(Hh));
           end;
{Make Dir}
        If Copy(Hold,1,2)= 'MD' then
           begin
              Nc := True;
              H := 0;
{              HH := Copy (Hold,3,Length(Hold));
              If (Hh[1] = '\') or (Hh[1] = ' ') or (Hh[1] = '.') then
                 H := Cd (Trim(Hh));}
           end;
        If Copy(Hold,1,5)= 'MKDIR' then
           begin
              Nc := True;
              H := 0;
{              HH := Copy (Hold,6,Length(Hold));
              If (Hh[1] = '\') or (Hh[1] = ' ') Or (Hh[1] = '.') then
                 H := Cd (Trim(Hh));}
           end;
{Remove Directory}
        If Copy(Hold,1,2)= 'RD' then
           begin
              Nc := True;
              H  := 0;
{              HH := Copy (Hold,3,Length(Hold));
              If (Hh[1] = '\') or (Hh[1] = ' ') or (Hh[1] = '.') then
                 H := Cd (Trim(Hh));}
           end;
        If Copy(Hold,1,5)= 'RMDIR' then
           begin
              Nc := True;
              H := 0;
{              HH := Copy (Hold,6,Length(Hold));
              If (Hh[1] = '\') or (Hh[1] = ' ') Or (Hh[1] = '.') then
                 H := Cd (Trim(Hh));}
           end;

{Change Drive}
        If (Hold[2]= ':') and (Length(Hold)=2) then
           begin
              H := Drive (Hold[1]);
           end;
{Echo}
        If Copy(Hold,1,4)= 'ECHO' then
           begin
              HH := Copy (Hold,5,Length(Hold));
              If (Hh[1] = '.') or (Hh[1] = ' ') then
                 H := 0;
           end;

        If H = -1 then
           GoFind (h);

        If H = 0 then
           U := True;
    end;   {End of Check}

    var
      Fl : Text;
       V : integer;
    Hld  : String;
begin
     V := 0;
     Assign (Fl, ParamStr(1));
     {$I-}
     Reset (Fl);
     {$I+}
     If (IoResult <>0) or (ParamCount <> 1 ) then
        begin
           WriteLn ('File Not Found.');
           Halt;
        end;
     While Not Eof(Fl) do
       begin
          V := V + 1;
          ReadLn (Fl, hld);
          Data[V] := Hld;
       end;
     V := V + 1;
     Data[V] := Chr(2);
     Close (Fl);
     Path := '';
     For I := 1 to EnvCount do
        If Copy(EnvStr(I),1,4) = 'PATH' then
           Path := (Copy(EnvStr(I),6,Length(EnvStr(I))));
     SplitSrp;
     HPath := FExpand ('');
     If Length(HPath) > 3 then HPath := Copy (HPath, 1, Length(HPath)-1);
     CPath := HPath;
     Drv := Copy(HPath,1,2);
     Dir := ORD(Drv[1])-64;
     I := 0;
     WriteLn ('Start  Drive:  ', Drv);
     WriteLn ('Start   Path:  ', HPath);
     WriteLn ('Search  Path:  ', Path);
     WriteLn;

     repeat
        I := I + 1;
        Hold := Trim(UCase(Data[I]));
        If (Hold <> Chr(2)) and (Hold <> Chr(4)) and (Hold <>'') then
           begin
              Write (Hold+' ',ChrStr('.',60-Length(Hold)));
              If Hold[1] = '@' then
                 Hold := Copy (Hold, 2, Length(Hold));
              Check;
              If Not U then
                 Write ('--BAD');
              if U then
                 if Nc then
                    write ('--Can''t Check')
                 else
                    Write ({Chr(251)}'--Good');
              WriteLn ;
              If Not U then
                 begin
                    Write (Chr(7));
                 end;
              GetDir (ORD(Drv[1])-64, CPath);
{              WriteLn ('':40, CPath);}
           end;
     until Hold = Chr(2);
     Chdir ('C:\');
     ChDir (HPath);
     GetDir (ORD(Drv[1])-64,CPath);
     WriteLn;
{    WriteLn ('CD ', CPath);}
     GetDir (ORD(HPath[1])-64,CPath);
{    WriteLn ('':40, CPath);}
     Pause;
end.
