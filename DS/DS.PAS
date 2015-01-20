{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$A+,B-,D-,E+,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+}
{$M 16384,0,655360}
program Directory;

  Uses Dos, QCrtNM, Scroller, StrAsm;

{---------------------------------------------------------------------------}
  type
    ColorType = record
      Norm,
      Directory,
      NoAttr,
      Archive,
      ReadOnly,
      System,
      Sync     : byte;
    end;

  const
    DefaultColors : ColorType =
     ( Norm:7; Directory:2; NoAttr:7; Archive:7; ReadOnly:1; System:4; Sync:1 );

  var
    Colors : ColorType;
{---------------------------------------------------------------------------}
  type
    DirRecPtr = ^DirRec;
    DirRec    = record
      Entry : SearchRec;
      Next,
      Prior : DirRecPtr;
    end;

  var
    Error               : integer;
    LineNum             : integer;
    VolumeID            : SearchRec;
    Found               : boolean;
    PathSpec            : Dos.DirStr;
    Free, Bytes         : LongInt;
    FileCount, DirCount : Integer;
    First, Last         : DirRecPtr;

  const
    White = 7;
    Blue  = 1;
    Cyan  = 3;
    Red   = 4;
{-----------------------------------------------------------------------------}
{Procedures Copied from Strings}
{   function Trim (IO : String) : String;
      var P : byte;
      begin
         P := 0;
         While (P < Length(IO)) and (IO[P + 1] = Chr(32)) do Inc(P);
         Delete (IO, 1, P);
         While (Length(IO) <> 0) and (IO[Length(IO)] = ' ') do
            IO[0] := Chr(Length(IO) - 1);
         Trim := IO;
      end; }

   function IntStr ( N : LongInt; P : byte) : String;
      var
         T : String;
      begin
         Str (N:P,T);
         IntStr := T;
      end;

   function IntPad ( N : LongInt; P : byte) : String;
      var
         T : String;
      begin
         Str (N,T);
         While Length(T)< P do T :=  '0' + T;
         IntPad := T;
      end;

{   function Space ( N : byte ) : String;
      var
         T : String;
      begin
         If N > 255 then N := 255;
         FillChar (T[1], N, 32);
         T[0] := Chr(N);
         Space := T;
      end;

   function RSpace ( IO : String; L : Byte ) : String;
      begin
         If Length(IO) < L then IO := IO + Space (L- Length(IO));
         RSpace := IO;
      end;

   function LCase ( IO : String ) : String;
      var
         P : Byte;
      begin
         For P := 1 to Length(IO) do
           if (IO[P] >= 'A') and (IO[P] <= 'Z') then
              IO[P] := Chr( Ord( IO[P] ) + 32);
         LCase := IO;
      end; }

  function IntComma ( I : LongInt; P : Byte ) : String;
    var
      S    : String;
      C, L : Byte;
    begin
      Str (I, S);
      L := Length(S);
      For C := L - 1 DownTo 2 do
        if (L - C + 1) Mod 3 = 0 then
          Insert (',', S, C);
      If Length(S) < P then
         S := Space (P - Length(S)) + S;
      IntComma := S;
    end;
{-----------------------------------------------------------------------------}
  procedure NULL;
    begin
      Last      := NIL;
      First     := NIL;
    end;

  function IsPath ( S : String ) : boolean;
    var
      F : File;
      A : Word;
    begin
      Assign   ( F, S );
      GetFAttr ( F, A );
      IsPath := A and $10 = $10;
    end;

  function TimeStr ( Time : LongInt ) : String;
    var
      DT : DateTime;
      S  : String;
      pm : boolean;
    begin
      UnPackTime ( Time, DT );
      pm := False;
      with DT do
        begin
          if Hour >= 12 then
            begin
              pm := True;
              if Hour > 12 then Dec(Hour, 12);
            end;
          if Hour = 0 then Hour := 12;
          S := IntStr(Hour, 2) + ':' + IntPad (Min, 2);
          Case Pm of
            True  : S := S + 'p';
            False : S := S + 'a';
          end;
        end;
      TimeStr := S;
    end;

  function DateStr ( Time : LongInt ) : String;
    var
      DT : DateTime;
    begin
      UnPackTime ( Time, DT );
      with DT do
        DateStr := IntStr(Month, 2) + '-' + IntPad (Day, 2) + '-' +
                   IntPad(Year mod 100, 2);
    end;

  function NameStr ( Name : String ) : String;
    var
      N : Dos.NameStr;
      E : Dos.ExtStr;
      D : Dos.DirStr;
    begin
      FSplit (Name, D, N, E);
      if (E = '.') or (E= '..') then
        begin
          N := E;
          E := '';
        end;
      NameStr := RSpace(Trim(N), 8) + RSpace(Trim(E), 4);
    end;

  function DirStr ( Name : String ) : String;
    begin
      Name := Trim(Name);
      DirStr := RSpace(Name, 12);
    end;

  function SStr ( Int : LongInt ) : Char;
    begin
      if Int <> 1 then SStr := 's' else SStr := ' ';
    end;

  function VolumeStr ( S : String ) : String;
    begin
      if S <> '' then While (Pos ('.', S) > 0) do Delete (S, Pos('.', S), 1);
      VolumeStr := RSpace(S, 15);
    end;

  function TextColor ( B : Byte ) : String;
    begin
      TextColor := #27 + Chr(TextAttr and $F0 + B);
    end;

  procedure DisplayDir;
    var
      Mark     : DirRecPtr;
      Buff     : array[1..50] of SearchRec;
      Color,
      MaxCount,
      I, Count,
      J, Lines : Byte;
      Key      : Char;
      TS       : String;
    begin
      WriteStr ( '' );
      TS := TextColor(Colors.Norm) + 'Volume in drive ' + PathSpec[1] + ' ';
      With VolumeID do
        Case Found of
          True  : TS := TS + 'is ' + VolumeStr(Name) + '   created on ' +
                           DateStr(Time) + ' ' + TimeStr(Time);
          False : TS := TS + 'has no label';
        end;
      WriteStr ( TS );
      TS := TextColor(Colors.Norm) +'Directory of ';
      If Length(PathSpec) > 3 then
        WriteStr ( TS + Copy(PathSpec, 1, Length(PathSpec) - 1))
      else
        WriteStr (TS + PathSpec);
      WriteStr (TextColor(Colors.Norm) +'');
      Mark     := First;
      MaxCount := 42;
      LineNum  := 4;
      While (Mark <> NIL) and (Error = 0) do
        begin
          Count := 0;
          While (Count < MaxCount) and (Mark <> NIL) do
            begin
              Inc(Count);
              Buff[Count] := Mark^.Entry;
              Mark := Mark^.Next;
            end;
          MaxCount := 48;
          Lines := Count div 2;
          if Count Mod 2 <> 0 then Inc(Lines);
          For I := 1 to Lines do
            begin
              TS := '';
              For J := 0 to 1 do
                if (I + J * Lines <= Count) then
                  with Buff[I + J * Lines] do
                    begin
                      if (Attr and $02 = $02) then Name := LCase(Name);
                      if Attr and $10 = $10 then Color := Colors.Directory
                      else
                      If Attr and $04 = $04 then Color := Colors.System
                      else
                      If Attr and $01 = $01 then Color := Colors.ReadOnly
                      else
                      if (Attr = $00) then Color := Colors.NoAttr
                      else Color := Colors.Archive;
                      TS := TS + TextColor( Color );
                      Case (Attr and $10 = $10) of
                        False : TS := TS + NameStr(Name) + ' ' + IntStr(Size,9);
                        True  : TS := TS + NameStr(Name)+  '     <DIR>';
                      end;
                      TS := TS + TextColor( Colors.Norm ) +
                                 ' ' + DateStr(Time)+ ' '+ TimeStr(Time);
                      if J = 0 then TS := TS + ' ' + #179 + ' ';
                    end;
              WriteSTR ( TS );
              Inc(LineNum);
            end;
          if (LineNum >= 21) then
            begin
              Key := ReadKey;
              While KeyPressed do Key := ReadKey;
              LineNum := 1;
            end;
        end;
      if Error <> 0 then
        Case Error of
           3 : WriteStr ('path not found');
           8 : WriteStr ('out of memory');
          15 : WriteStr ('invalid drive');
         100 : WriteStr ('disk read error');
         152 : WriteStr ('drive not ready');
         156 : WriteStr ('disk seek error');
         158 : WriteStr ('sector not found');
        else
          WriteStr ('Error #' + IntStr(Error,1));
        end
      else
        begin
          if First = NIL then
            WriteStr ('file not found');
          WriteStr(TextColor(Colors.Norm) +'');
          if FileCount <> 0 then
            begin
              WriteStr (TextColor(Colors.Norm) +
                        IntStr(FileCount, 9) + ' file' + SStr(FileCount) +
                        IntComma(Bytes, 17) + ' byte' + SStr(Bytes));
            end;
          WriteStr (TextColor(Colors.Norm) +
                    IntStr(DirCount, 9) + ' dir' + SStr(DirCount) +
                    IntComma(Free, 18) + ' byte' + SStr(Free) + ' free');
        end;
      WriteStr (TextColor(Colors.Norm));
      WriteStr (TextColor(Colors.Norm));
      GotoXY ( WhereX, WhereY - 1 );
    end;

  procedure Dispose;
    Var
      Mark, Temp : DirRecPtr;
    begin
      Mark := First;
      While Mark <> NIL do
        begin
          Temp := Mark^.Next;
          System.Dispose ( Mark );
          Mark := Temp;
        end;
      NULL;
    end;

  procedure AddRec ( var F, L : DirRecPtr; S : SearchRec);
    var
      Temp, Mark : DirRecPtr;
    begin
      If MaxAvail > Sizeof(DirRec) * 2 then
        begin
          New ( Temp );
          Temp^.Next  := NIL;
          Temp^.Prior := NIL;
          Temp^.Entry := S;
          if F = NIL then
            begin
              F := Temp;
              L := Temp;
            end
          else
          if (Temp^.Entry.Name < F^.Entry.Name) then
            begin
              Temp^.Next := F;
              F^.Prior   := Temp;
              F          := Temp;
            end
          else
          if (Temp^.Entry.Name > L^.Entry.Name) then
            begin
              Temp^.Prior := L;
              L^.Next     := Temp;
              L           := Temp;
            end
          else
            begin
              Mark := F;
              While Temp^.Entry.Name > Mark^.Entry.Name do Mark := Mark^.Next;
              Temp^.Next        := Mark;
              Temp^.Prior       := Mark^.Prior;
              Mark^.Prior^.Next := Temp;
              Mark^.Prior       := Temp;
            end;
        end
      else
        Error := 8;
    end;

  procedure Get (Path : String);
    var
      S     : SearchRec;
      N     : Dos.NameStr;
      E     : Dos.ExtStr;
      F, L  : DirRecPtr;
    begin
      Error     := 0;
      Bytes     := 0;
      FileCount := 0;
      DirCount  := 0;
      Path := FExpand (Path);
      if IsPath (Path) and (Path[Length(Path)] <> '\') then
         Path := Path + '\';
      if Path[Length(Path)] = '\' then
        Path := Path + '*.*';
      FSplit ( Path, PathSpec, N, E);
      N := Trim(N);  E := Trim(E);
      if N + E = '.' then E := '.*';
      if N     = ''  then  N := '*';
      if PathSpec[Length(PathSpec)] <> '\' then PathSpec := PathSpec + '\';
      Found := True;
      FindFirst (Path[1] + ':\*.*', $08, VolumeID);
      if DosError <> 0 then Found := False;
      FindFirst ( PathSpec + N + E, AnyFile Xor $08, S);
      NULL;
      F := NIL;
      L := NIL;
      While DosError = 0 do
        with S Do
          begin
            If (Attr and $10 = $10) then
              begin
                Inc(DirCount);
                AddRec( First, Last, S);
              end
            else
              begin
                Inc(FileCount);
                Inc(Bytes, Size);
                AddRec( F, L, S);
{               if Size mod 512 <> 0 then Inc (Slack, 512 - (Size mod 512)); }
              end;
            FindNext ( S );
          end;
        if (F <> NIL) and (Last <> NIL) then
          begin
            F^.Prior   := Last;
            Last^.Next := F;
            Last       := L;
          end
        else
        if (First = NIL) then
          begin
            First := F;
            Last  := L;
          end;
        If (DosError <> 18) and (DosError <> 0) then
          Error := DosError;
        Free := DiskFree(ord(PathSpec[1])-64);
    end;
{-----------------------------------------------------------------------------}
  procedure SetColors ( S : String );
    var
      Error : Integer;
    procedure GetCommand ( R : String; Var Value : Byte );
      var
        T     : String;
        TVal,
        I, P  : Byte;
        Err   : integer;
      begin
        P := Pos(' ' + R, S);
        if P > 0 then
          begin
            I := P + 1;
            While (S[I] <> ' ') do Inc(I);
            T := Copy (S, P, I - P);
            Delete ( S, P, I - P );
            S := ' ' + Trim(S) + ' ';
            T := Trim(T);
            if (Length(T) = 1) and (Error = 0) then begin Write(T); Error := 1; end;
            if Length(T) > 1 then
              begin
                Val(Copy(T, 2, Length(T)), TVal, Err );
                if (Err <> 0) and (Error <> 0) then Error := 2;
                If Err = 0 then Value := TVal;
              end;
          end
      end;

    begin
      Error := 0;
      S := ' ' + LCase(Trim(S)) + ' ';
      with Colors do
        begin
          GetCommand ( 't', Norm);
          GetCommand ( 'd', Directory);
          GetCommand ( 'n', NoAttr);
          GetCommand ( 'a', Archive);
          GetCommand ( 'r', ReadOnly);
          GetCommand ( 's', System);
          GetCommand ( 'y', Sync );
          S := Trim(S);
          if (S <> '') and (Error = 0) then Error := 3;
        end;
      if Error <> 0 then
        begin
          Case Error of
            1 : Write (' numeric constant expected');
            2 : Write (' invalid numeric constant');
            3 : Write (S + ' extra parameter')
          end;
          WriteLn (' in environment varable');
        end;
    end;

begin
  Colors := DefaultColors;
  SetColors (GetEnv('DCOLORS'));
  Get (ParamStr(1));
  SyncDelay := Colors.Sync;
  DisplayDir;
  Dispose;
end.
