{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
program DDF_Link;

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

  procedure LinkDir( Path : String );
    begin
      if ReadDir ( Path, Dir, opIncDir or opForceDir or opIncFile or opForceFile ) <> erNone then
        Error ( Dir.Result );
      if Dir.Entries = nil then exit;
      WriteLn( 'Linking/Updating ', Path );;
      DirID;
      AutoID;
      Save;
      UnreadDir(Dir);
    end;

  type
    PDIR = ^TDir;
    TDir = record
      Next : PDir;
      Name : DirStr;
    end;

  const
    List : PDir = nil;

  procedure Read( Path : DirStr );
    var
      Srec : SearchRec;
      S : String;
      P : PDir;
    begin
      if Path[Length(Path)] <> '\' then AddChr(Path, '\');
      FindFirst(Path + '*.*', AnyFile, SRec);
      while DosError = 0 do
        begin
          if (SRec.Attr and Directory = Directory) and (SRec.Name <> '.') and
          (Srec.Name <> '..') then
            begin
              S := Path + Srec.Name + '\';
              if MaxAvail < 1024 then Error(8);
              New(P);
              P^.Next := List;
              P^.Name := S;
              List := P;
              Read(S);
            end;
          FindNext(Srec);
        end;
    end;

  procedure Link;
    var
      P : PDir;
    begin
      P := List;
      While Assigned(P) do
        begin
          LinkDir(P^.Name);
          P := P^.Next;
        end;
    end;

  procedure Go;
    var
      Path : String;
      P : PDir;
    begin
      if ReadDir ( ParamStr(1), Dir, 0 ) <> erNone then
        Error ( Dir.Result );
      Path := Dir.Dir;
      UnReadDir(Dir);
      WriteLn ( 'Scanning directories...');
      if MaxAvail < 1024 then Error(8);
      New(P);
      P^.Next := List;
      P^.Name := Path;
      List := P;
      Read(Path);
      Link;
      WriteLn ( 'Done.');
    end;

begin
  Go;
end.