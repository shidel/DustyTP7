{
Copyright 1990-2015, Jerome Shidel.

This project and related files are subject to the terms of the Mozilla Public License,
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
program DDF;

  uses Dos, ErConst, ErrMsg, QCrt, QDir, StrAsm, Files;

  const
    LastLine = 23;

  type
    Chars = array[0..$FFF0] of char;

  const
    CurDirName  : String[12] = '.           ';
    PrevDirName : String[12] = '..          ';
    DDFDisc  : array[0..27] of char = 'Directory Discription File.'#0;
    CurDisc  : array[0..18] of char = 'Current Directory.'#0;
    PrevDisc : array[0..17] of char = 'Parent Directory.'#0;

  var
    Dir : TDir;
    Buf : array[1..25] of String[85];

  function ReadKey( aWait : boolean ) : String;
    var
      S : String[2];
    begin
      S := #0#0;
      S := '';
      repeat
        if Keypressed then
          begin
            S := QCrt.ReadKey;
            if S = #0 then
              S := S + QCrt.ReadKey;
          end;
      until (S <> '') or (Not AWait);
      ReadKey := S;
    end;

  procedure Error ( Code : integer );
    begin
      if Code = erNone then Exit;
      TextAttr := $07;
      ClrScr;
      WriteLn( ErMsg(Code) );
      Halt(Code);
    end;

  function Bar ( AStr : String ): String;
    begin
      if AStr = '' then
        Bar := ChrStr(#196, 80)
      else
        begin
          AStr := ' ' + AStr + ' ' + ChrStr(#196, 39 - Length(AStr) div 2);
          Bar := ChrStr(#196, 80 - Length(AStr)) + AStr;
        end;
    end;

    procedure GetDisc ( var Disc : TDisc );
      var
        I, Y : word;
      begin
        FillChar ( Buf, Sizeof(Buf), #0);
        Y := 3;
        if Assigned(Disc.Disc) then
          for I := 0 to $FFFF do
            case Chars(Disc.Disc^)[I] of
              #0 : Exit;
              #10 : begin end;
              #13 : Inc(Y);
            else
              if Y > LastLine - 1 then Exit;
              if Byte(Buf[Y][0]) < Sizeof(Buf[Y]) - 1 then
                AddChr ( Buf[Y], Chars(Disc.Disc^)[I] );
            end;
        for I := 3 to LastLine - 1 do
          Buf[I] := Copy(RSpace(Buf[I], 80), 1, 80);
      end;

    procedure SetDisc ( var Disc : TDisc; NoLF : boolean );
      var
        Size : word;
        P, I, J  : word;
      begin
        Size := 1;
        J := 3;
        for I := 3 to LastLine - 1 do
          begin
            Buf[I] := RTrim(Buf[I]);
            Inc(Size, Length(Buf[I]));
            if Length(Buf[I]) <> 0 then
              J := I;
          end;
        Dec(J, 3);
        if NoLF = True then
          Inc(Size, J)
        else
          Inc(Size, J * 2);
        if MaxAvail <= Size then Exit;
        if Assigned(Disc.Disc) then FreeMem(Disc.Disc, Disc.Size);
        Disc.Size := Size;
        GetMem(Disc.Disc, Size);
        P := 0;
        for I := 3 to J + 4 do
          begin
            Move(Buf[I][1], Chars(Disc.Disc^)[P], Length(Buf[I]));
            Inc(P, Length(Buf[I]));
            if I < J + 3 then
              begin
                Chars(Disc.Disc^)[P] := #13;
                Inc(P, 1);
                if Not NoLF then
                  begin
                    Chars(Disc.Disc^)[P] := #10;
                    Inc(P, 1);
                  end;
              end;
          end;
        Chars(Disc.Disc^)[P] := #0;
      end;

  procedure EditDisc ( var Disc : TDisc; Title : String; NoLF : boolean );
    var
      K : String;
    procedure DrawScreen;
      var
        I : integer;
      begin
        TextAttr := $1F;
        GotoXY ( 1, 2 );
        Write ( Bar(Title) );
        TextAttr := $1E;
        for I := 3 to LastLine - 1 do
          Write (RSpace(Buf[I], 80));
      end;
    var
      X : byte;
    begin
      GetDisc(Disc);
      DrawScreen;
      GotoXY (1,3);
      repeat
        X := WhereX;
        Buf[WhereY] := Copy(RSpace(Buf[WhereY], 80), 1, 80);
        GotoXY (1, WhereY );
        Write(Buf[WhereY]);
        GotoXY ( X, WhereY - 1);
        K := ReadKey(True);
        if K = #27 then Exit else
        if (K = #0#$48) and (WhereY > 3) then GotoXY (WhereX, WhereY - 1) else
        if ((K = #0#$50) or (K = #13)) and (WhereY < LastLine - 1) then GotoXY (WhereX, WhereY + 1) else
        if (K = #0#$4B) and (WhereX > 1) then GotoXY (WhereX - 1, WhereY) else
        if (K = #0#$4D) and (WhereX < 80) then GotoXY (WhereX + 1, WhereY) else
        if (K = #0#$47) then GotoXY (1, WhereY) else
        if (K = #0#$4F) then
          begin
            GotoXY (Length(RTrim(Buf[WhereY])), WhereY);
            if WhereX < 80 then GotoXY ( WhereX + 1, WhereY);
          end
        else
        if (K = #8) and (WhereX > 1) then
          begin
            GotoXY ( WhereX - 1, WhereY );
            Delete( Buf[WhereY], WHereX, 1 );
          end
        else
        if (K = #0#$53) then
        Delete( Buf[WhereY], WHereX, 1 )
        else
        if (Length(K) = 1) and (K >= #32) and (K<=#127) then
          begin
            Insert( K, Buf[WhereY], WhereX);
            if WhereX < 80 then GotoXY ( WhereX + 1, WhereY );
          end;
        if K = #13 then GotoXY ( 1, WhereY );
      until K = #0#$3C;
      SetDisc(Disc, NoLF);
    end;

  procedure ImportDisc ( var Disc : TDisc; Title : String; NoLF : boolean );
    begin
    end;

  procedure ExportDisc ( var Disc : TDisc; Title : String; NoLF : boolean );
    begin
    end;

  procedure Save;
    var
      Old, F : TDosFile;
      EraseOld : Boolean;
      Path : PathStr;
      P : PEntry;
      I : LongInt;
      DT : DateTime;
      T  : word;
      DH : TDiscHeader;
      FA : word;
    procedure EraseWork;
      begin
        F.Close;
        F.Erase;
      end;
    procedure Err ( AFunc : byte );
      var
        E : integer;
      begin
        Case AFunc of
          0 : Error ( F.IOResult );
          1 : begin
            E := F.IOResult;
            if E <> erNone then
              begin
                EraseWork;
                Error ( E );
              end;
          end;
          2 : begin
            E := DosError;
            if E <> erNone then
              begin
                Old.Close;
                EraseWork;
                Error ( E );
              end;
          end;
        end
      end;

    procedure WriteDisc ( Name : String; Disc : Pointer; Size : Word);
      var
        FH : TFileHeader;
      begin
        FH.Size := Size + (Sizeof(FH) - Sizeof(FH.Size));
        FH.Name := Name;
        F.WriteRecord ( FH, Sizeof(FH) );
        Err(1);
        F.WriteRecord(Disc^, Size);
        Err(1);
      end;
    begin
      TextAttr := $74;
      GotoXY (1, LastLine);
      Write( ' Saving... ' );
      Write ( Space(81-WhereX));
      Path := Dir.Dir;
      if Path[Length(Path)] <> '\' then Path := Path + '\';
      F.Init;
      repeat
        GetTime ( DT.Day, DT.Hour, DT.Min, DT.Sec );
        GetDate ( T, DT.Year, DT.Month, T );
        PackTime ( DT, I );
        F.Assign(Path+ HexLong(I)+'.$$$');
        F.Reset;
        T := F.IOResult;
        F.Close;
      until T <> erNone;
      if T <> erFile_Not_Found then Error(T);
      FileMode := 1;
      F.ReWrite;
      Err(0);
      DH.ID := 'DDF'#26#0;
      DH.Version := $0001;
      DH.TextSize := Dir.InfoText.Size;
      F.WriteRecord ( DH, Sizeof(DH) );
      Err(1);
      if Assigned(Dir.InfoText.Disc) then
        F.WriteRecord ( Dir.InfoText.Disc^, DH.TextSize );
      Err(1);
      P := Dir.Entries;
      while Assigned(P) do
        begin
          if Assigned(P^.Disc.Disc) then
            WriteDisc(P^.Name, P^.Disc.Disc, P^.Disc.Size);
          P := P^.Next;
        end;
      T := 0;
      F.WriteWord(T);
      F.Close;
      Err(1);
      EraseOld := False;
      Old.Init;
      Old.Assign(Path + DiscFIleName);
      FileMode := 0;
      Old.Reset;
      if Old.IOResult = erNone then
        begin
          Old.Close;
          GetFAttr(Old.FRec, FA);
          Err(2);
          SetFAttr(Old.FRec, 0);
          Err(2);
          repeat
            GetTime ( DT.Day, DT.Hour, DT.Min, DT.Sec );
            GetDate ( T, DT.Year, DT.Month, T );
            PackTime ( DT, I );
            Old.Rename(Path+ HexLong(I)+'.$$$');
            T := Old.IOResult;
            if (T <> erNone) and (T <> erFile_Access_Denied) then
              begin
                EraseWork;
                Error ( T );
              end;
          until T = erNone;
          EraseOld := True;
        end
      else
        FA := Archive;
      F.Close;
      F.Rename(Path + DiscFileName);
      Err(1);
      if EraseOld then Old.Erase;
      SetFAttr(F.FRec, FA);
      Old.Done;
      F.Done;
      GotoXY (1, LastLine);
      Write( RSpace(' ' + Path + DiscFileName + ' saved. ', 80));
    end;

  procedure WriteBut ( Key, Disc : String );
    begin
      TextAttr := $17;
      Write (' ');
      TextAttr := $1F;
      Write ( Key );
      TextAttr := $17;
      Write ( '-', Disc, ' ');
    end;

  procedure DrawOverlay;
    begin
      TextAttr := $17;
      ClrScr;
      GotoXY ( 1, 1 );
      Write ( ' PATH: ' );
      TextAttr := $1F;
      Write ( Dir.Dir );
      GotoXY ( 1, 2 );
      Write ( Bar('') );
      GotoXY ( 1, 23 );
      Write ( Bar('') );
      GotoXY ( 2, LastLine + 1 );
      WriteBut ( 'F2', 'Save' );
      WriteBut ( 'F3', 'Edit Dir' );
      WriteBut ( 'F4', 'Clear Dir' );
      WriteBut ( 'F5', 'Import Dir');
      WriteBut ( 'F6', 'Export Dir');
      GotoXY ( 2, LastLine + 2 );
      WriteBut ( 'ENTER', 'Edit File');
      WriteBut ( 'F7', 'Clear File');
      WriteBut ( 'F8', 'Import File');
      WriteBut ( 'F9', 'Export File');
      GotoXY ( 1, LastLine + 2 );
    end;

  procedure DrawFiles ( var Top, Current, Bottom : PEntry );
    var
      P : PEntry;
      I : word;
    begin
      GotoXY ( 1, 2 );
      TextAttr := $1F;
      Write ( Bar('File List') );
      P := Top;
      while Assigned( P ) and (WhereY < LastLine) do
        begin
          if P = Current then TextAttr := $47 else TextAttr := $17;
          Write ( P^.Name + ' ' );
          if P^.Attr and Directory = Directory then
            Write ( '<DIR> ')
          else
            Write ( '      ');
          if P = Current then TextAttr := $47 else TextAttr := $17;
          Write ( #179 );
          if P = Current then TextAttr := $4E else TextAttr := $1E;
          Write (#32);
          I := 0;
          with P^.Disc do
          if Assigned(Disc) then
            while (Chars(Disc^)[I] <> #0) and (Chars(Disc^)[I] <> #13) and (WhereX < 80) do
              begin
                Write(Chars(Disc^)[I]);
                Inc(I);
              end;
          if P = Current then TextAttr := $47 else TextAttr := $17;
          Write ( Space(81 - WhereX));
          Bottom := P;
          P := P^.Next;
        end;
      TextAttr := $17;
      while WHereY < LastLine do Write (ChrStr(#32, 80));
      TextAttr := $1F;
      if Assigned(Bottom^.Next) then
        Write ( Bar('more') )
      else
        Write ( Bar('end'));
      GotoXY ( 1, LastLine + 2);
    end;

  procedure EditDDF;
    var
      FileName : PathStr;
      K        : String;
      Top, Current, Bottom : PEntry;
    procedure Up(ACOunt : integer);
      begin
        While (ACount <> 0) and Assigned(Current^.Prior) do
          begin
            Current := Current^.Prior;
            if Current^.Next = Top then Top := Current;
            Dec(ACOunt);
          end;
        DrawFiles(Top, Current, Bottom);
      end;
    procedure Down(ACOunt : integer);
      begin
        While (ACount <> 0) and Assigned(Current^.Next) do
          begin
            Current := Current^.Next;
            if Current^.Prior = Bottom then
              begin
                Top := Top^.Next;
                Bottom := Current;
              end;
            Dec(ACOunt);
          end;
        DrawFiles(Top, Current, Bottom);
      end;
    function Filter(AStr : String) : String;
      begin
        While Pos(#32, AStr) > 0 do Delete(AStr, Pos(#32, AStr), 1);
        Filter := AStr;
      end;
    begin
      FileName := Dir.Dir;
      if FileName[Length(FileName)] <> '\' then FileName := FileName + '\';
      FileName := FileName + DiscFileName;
      DrawOverlay;
      Top := Dir.Entries;
      Current := Top;
      DrawFiles(Top, Current, Bottom);
      repeat
        K := ReadKey(True);
        if (K = #0#$48 {UP})  then Up(1) else
        if (K = #0#$50 {DOWN}) then Down(1) else
        if (K = #0#$49 {PAGE UP})  then Up(LastLine - 4) else
        if (K = #0#$51 {PAGE DOWN}) then Down(LastLine - 4) else
        if (K = #0#$47 {HOME}) then Up(-1) else
        if (K = #0#$4F {END})  then Down(-1) else
        if (K = #0#$3C {F2}) then Save else
        if (K = #0#$3E {F4}) then { Clear Dir }
          begin
            if Assigned(Dir.InfoText.Disc) then
              begin
                FreeMem ( Dir.InfoText.Disc, Dir.InfoText.Size );
                Dir.InfoText.Disc := nil;
                Dir.InfoText.Size := 0;
              end;
            DrawFiles(Top, Current, Bottom);
          end
        else
        if (K = #0#$41 {F7}) then { Clear File }
          begin
            if Assigned(Current^.Disc.Disc) then
              begin
                FreeMem ( Current^.Disc.Disc, Current^.Disc.Size );
                Current^.Disc.Disc := nil;
                Current^.Disc.Size := 0;
              end;
            DrawFiles(Top, Current, Bottom);
          end
        else
        begin
          if (K = #0#$3D {F3}) then
          EditDisc(Dir.InfoText, 'Directory Summary', False)
          else
          if (K = #0#$3F {F6}) then
          ImportDisc(Dir.InfoText, 'Directory Summary', False)
          else
          if (K = #0#$40 {F5}) then
          ExportDisc(Dir.InfoText, 'Directory Summary', False)
          else
          if (K = #13 {ENTER}) then
          EditDisc(Current^.Disc, 'File Discription (' + Filter(Current^.Name)+ ')', True)
          else
          if (K = #0#$42 {F8}) then
          ImportDisc(Current^.Disc, 'File Discription (' + Filter(Current^.Name)+ ')', True)
          else
          if (K = #0#$43 {F9}) then
          ExportDisc(Current^.Disc, 'File Discription (' + Filter(Current^.Name)+ ')', True);
          DrawFiles(Top, Current, Bottom);
        end;
      until K = #27;
    end;

    procedure ID ( PE : PEntry; var Name, Disc : OpenString );
      begin
        if (MaxAvail > Length(Disc) + 1) then
          while Assigned(PE) do
            begin
              if (Name = PE^.Name) then
                begin
                  if Assigned(PE^.Disc.Disc) then Exit;
                  PE^.Disc.Size := Length(Disc) + 1;
                  GetMem(PE^.Disc.Disc, PE^.Disc.Size);
                  Move ( Disc[1], PE^.Disc.Disc^, Length(Disc));
                  Chars(PE^.Disc.Disc^)[Length(Disc)] := #0;
                  PE := nil;
                end
              else
                PE := PE^.Next;
            end;
      end;

  procedure DirID;
    var
      F : TDosFile;
      E : PEntry;
      S : String;
      P : String;
      H : TDiscHeader;
    begin
      E := Dir.Entries;
      FileMode := 0;
      F.Init;
      P := Dir.Dir;
      if P[Length(P)] <> '\' then AddChr(P, '\');
      while assigned(E) do
        begin
          if (E^.Attr and Directory = Directory) and
          (Not Assigned(E^.Disc.Disc)) and
          (Trim(E^.Name) <> '.') {and (Trim(E^.Name)<>'..') } and
          (MaxAvail > 1024) then
            begin
              S := E^.Name ;
              While Pos(#32,S) <> 0 do Delete(S, Pos(#32,S), 1);
              F.Assign(P + S + '\' + DiscFileName);
              F.Reset;
              if F.IOresult = erNone then
                begin
                  F.ReadRecord(H, Sizeof(H));
                  if (F.IOResult = erNone) and (H.ID = 'DDF'#26#0) and
                  (H.Version = $0001) then
                    begin
                      if H.TextSize < 250 then
                        S[0] := Chr(H.TextSize)
                      else
                        S[0] := #250;
                      if S[0] <> #0 then
                        begin
                          F.Readrecord(S[1], Byte(S[0]));
                          if F.IOResult = erNone then
                            begin
                              if Pos(#13, S) > 0 then
                                S[0] := Chr(Pos(#13,S)-1);
                              if (Length(S) > 0) then
                                begin
                                  E^.Disc.Size := Length(S) + 1;
                                  GetMem(E^.Disc.Disc, Length(S) + 1);
                                  Move (S[1], E^.Disc.Disc^, E^.Disc.Size);
                                  Chars(E^.Disc.Disc^)[Length(S)] := #0;
                                end
                            end;
                        end;
                    end;
                  F.Close;
                end;
            end;
          E := E^.Next;
        end;
      F.Done;
    end;

  procedure AutoID;
    var
      D : DirStr;
      N : NameStr;
      E : ExtStr;
      F : Text;
      S : String;
      Name : String[12];
      Disc : String;
    begin
      FSPlit ( ParamStr(0), D, N, E );
      Assign(F, D + N + '.AID');
      FileMode := 0;
      Reset(F);
      if IOResult <> 0 then Exit;
      while (Not EOF(F)) and (IOResult = 0) do
        begin
          ReadLn(F, S);
          if IOResult <> 0 then
            begin
              Close(F);
              Exit;
            end;
          S := Trim(S);
          if (Pos('=', S) <> 0) and (S <> '') and (S[1] <> ';') then
            begin
              Name := Copy(S, 1, Pos('=', S) - 1);
              Disc := Copy(S, Length(Name) + 2, Length(S));
              NSplit ( Name, N, E );
              Name := N + E;
              ID ( Dir.Entries, Name, Disc );
            end
        end;
      Close(F);
      if IOResult <> 0 then Exit;
    end;

begin
  if ReadDir ( ParamStr(1), Dir, opStandard or opForceDir or opForceFile) <> erNone then
    Error ( Dir.Result );
  if Dir.Entries = nil then
    Error( erNo_More_Files );
  DirID;
  AutoID;
  TextAttr := $17;
  ClrScr;
  EditDDF;
  TextAttr := $07;
  ClrScr;
  UnreadDir(Dir);
end.