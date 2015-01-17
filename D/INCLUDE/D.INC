{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

  const
    Bar          = #179;
    Fill         = #32;
    DiscriptChar = #249;
    Test         = 0;
    Off          = 1;
    On           = 2;
    Short        = 2;
    Full         = 3;
    Normal       = 0;
    Mini         = 1;
    Expanded     = 3;
    AnsiCode     = #1;
    aNormal      = AnsiCode + #1;
    aTitle       = AnsiCode + #2;
    aError       = AnsiCode + #3;
    aBold        = AnsiCode + #4;
    aHighlight   = AnsiCode + #5;
    aPause       = AnsiCode + #6;
    aDir         = AnsiCode + #7;
    aNoAttr      = AnsiCode + #8;
    aReadOnly    = AnsiCode + #9;
    aArchive     = AnsiCode + #10;
    aSystem      = AnsiCode + #11;
    aHidden      = AnsiCode + #12;
    aDisc        = AnsiCode + #13;
    aInfo        = AnsiCode + #14;
    aDiscChar    = AnsiCode + #15;
    AnsiFound    : boolean = False;
    WriteMode    : byte = 0;
    FileWide     : word = 40;
    Width        : word = 80;
    Line         : word = 1;
    LineMax      : word = 25;
    Columns      : word = 1;

    { Configuration }
    Config : record
      Ansi   : byte;
      Subst  : boolean;
      Serial : boolean;
      Fat    : boolean;
      DiskType : boolean;
      Pause: boolean;
      Style : byte;
      Disc : byte;
      CheckScr : boolean;
      Capture : boolean;
      DiscChar : Char;
      Only     : boolean;
      NoIncFile : boolean;
      NoIncDir  : boolean;
      ForceFile : boolean;
      ForceDir  : boolean;
    end = (
      Ansi:Test;
      Subst:True;
      Serial:True;
      Fat:False;
      DiskType:False;
      Pause:True;
      Style:Normal;
      Disc:Off;
      CheckScr:True;
      Capture:False;
      DiscChar: DiscriptChar;
      Only:False;
      NoIncFile:False;
      NoIncDir:False;
      ForceFile:False;
      ForceDir:False
    );

    { Ansi Colors }
    BackColor      : array[0..15] of char = #27 + '[0m';
    TitleColor     : array[0..15] of char = aNormal + #27 + '[1;37;44m';
    ErrorColor     : array[0..15] of char = aNormal + #27 + '[1;37;41m';
    BoldColor      : array[0..15] of char = aNormal + #27 + '[1;37m';
    HighLightColor : array[0..15] of char = aNormal + #27 + '[1;33m';
    PauseColor     : array[0..15] of char = aNormal + #27 + '[1;5;36m';
    DirColor       : array[0..15] of char = #27 + '[32m';
    NoAttrColor    : array[0..15] of char = #27 + '[1;30m';
    ReadOnlyColor  : array[0..15] of char = #27 + '[1;36m';
    ArchiveColor   : array[0..15] of char = #27 + '[37m';
    SystemColor    : array[0..15] of char = #27 + '[31m';
    HiddenColor    : array[0..15] of char = {#27 + '[1m'} '';
    DiscColor      : array[0..15] of char = aNormal + #27 + '[1;33m';
    InfoColor      : array[0..15] of char = aNormal + #27 + '[36m';
    DiscCharColor  : array[0..15] of char = aNormal + #27 + '[1;30m';
    AnsiRef        : array[1..15] of word = (
      Ofs((@BackColor)^),
      Ofs((@TitleColor)^),
      Ofs((@ErrorColor)^),
      Ofs((@BoldColor)^),
      Ofs((@HighlightColor)^),
      Ofs((@PauseColor)^),
      Ofs((@DirColor)^),
      Ofs((@NoAttrColor)^),
      Ofs((@ReadOnlyColor)^),
      Ofs((@ArchiveColor)^),
      Ofs((@SystemColor)^),
      Ofs((@HiddenColor)^),
      Ofs((@DiscColor)^),
      Ofs((@InfoColor)^),
      Ofs((@DiscCharColor)^)
    );

  { Text Strings }
    CrLfStr            : array[0..04] of char = aNormal + #13#10;
    NormalStr          : array[0..02] of char = aNormal;
    TitleStr           : array[0..26] of char = aTitle+' Directory Lister '+ Version + ' ';
    VolumeStr          : array[0..40] of char = ' Volume in drive ' + aBold;
    NoLabelStr         : array[0..15] of char = aNormal + ' has no label';
    IsStr              : array[0..20] of char = anormal + ' is ' + aBold;
    AtStr              : array[0..06] of char = anormal + ' at ';
    CreatedOnStr       : array[0..13] of char =  aNormal + 'created on ';
    SerialStr          : array[0..27] of char = ' Volume serial number is ' + aBold;
    FatStr             : array[0..23] of char = ' File system used is ' + aBold;
    DirStr             : array[0..14] of char = ' Directory of ';
    NoFilesStr         : array[0..22] of char = aError + ' no matching files ';
    PauseStr           : array[0..27] of char = aPause + ' press any key . . . ' + aNormal;

  { Error Messages }
    Path_Not_Found_Str     : array [0..14] of char = 'Path not found';
    Not_Enough_Memory_Str  : array [0..17] of char = 'Not enough memory';
    File_Access_Denied_Str : array [0..18] of char = 'File access denied';
    Drive_not_ready_Str    : array [0..15] of char = 'Drive not ready';
    Device_read_fault_Str  : array [0..17] of char = 'Device read fault';
    Invalid_Parameter_Str  : array [0..23] of char = 'Invalid parameter count';
    Unknown_Error_Str      : array [0..20] of char = 'Unrecognized error #';

  var
    Params : String;

  function DetectAnsi : boolean; assembler;
    asm
      MOV  DI, OFFSET @AnsiTestStr
    @2:
      MOV  DL, CS:[DI]
      INC  DI
      CMP  DL, 0
      JE   @3
      MOV  AH, $02
      INT  $21
      JMP  @2
    @3:
      MOV  AH, $06
      MOV  DL, $FF
      INT  $21
      JZ   @5
      CMP  AL, 27
      JNE  @5
      MOV  AH, $06
      MOV  DL, $FF
      INT  $21
      JZ   @5
      CMP  AL, '['
      JNE  @5
    @4:
      MOV  AH, $06
      MOV  DL, $FF
      INT  $21
      JZ   @5
      CMP  AL,'R'
      JNE  @4
    @5:
      MOV  AH, $06
      MOV  DL, $FF
      INT  $21
      JZ   @6
      CMP  AL,13
      JNE  @5
      MOV  AL, True
      JMP  @Done
    @6: { Not Found }
      MOV  DI, OFFSET @AnsiTestStr
    @7:
      MOV  DL, CS:[DI]
      INC  DI
      CMP  DL, 0
      JE   @8
      MOV  AH, $02
      MOV  DL, 8
      INT  $21
      MOV  AH, $02
      MOV  DL, 32
      INT  $21
      MOV  AH, $02
      MOV  DL, 8
      INT  $21
      JMP  @7
    @8:
      MOV  AL, False
      JMP  @Done
    @AnsiTestStr:
      DB 27,'[6n',0
    @Done:
      MOV  AnsiFound, AL
    end;

  procedure WriteNul ( P : Pointer ); assembler;
    asm
      LES  DI, P
      MOV  DH, WriteMode
    @2:
      MOV  DL, ES:[DI]
      INC  DI
      CMP  DL, 0
      JL   @3
      CMP  DL, AnsiCode
      JL   @6
      JG   @3
      MOV  DL, ES:[DI]
      INC  DI
      CMP  AnsiFound, False
      JE   @5
      CMP  DH, 0
      JNE  @5
      XOR  BX, BX
      MOV  BL, DL
      DEC  BX
      MOV  AX, 2
      MUL  BX
      MOV  BX, AX
      ADD  BX, OFFSET AnsiRef
      MOV  AX, [BX]
      PUSH DI
      PUSH ES
      PUSH DS
      PUSH AX
      CALL WriteNul
      POP  ES
      POP  DI
      JMP  @5
    @3:
      CMP  DH, 0
      JE   @4
      MOV  DL, 32
      CMP  DH, 2
      JE   @4
      MOV  DL, 8
    @4:
      MOV  AH, 02h
      INT  21h
    @5:
      JMP  @2
    @6:
    end;

  procedure EraseNul ( P : Pointer ); assembler;
    asm
      {$IFOPT G+}
      PUSH SEG NormalStr
      PUSH OFFSET NormalStr
      {$ELSE}
      MOV  AX, SEG NormalStr
      PUSH AX
      MOV  AX, OFFSET NormalStr
      PUSH AX
      {$ENDIF}
      CALL WriteNul
      LES  DI, P
      MOV  WriteMode, 1
      PUSH ES
      PUSH DI
      CALL WriteNul
      LES  DI, P
      MOV  WriteMode, 2
      PUSH ES
      PUSH DI
      CALL WriteNul
      LES  DI, P
      MOV  WriteMode, 1
      PUSH ES
      PUSH DI
      CALL WriteNul
      MOV  WriteMode, 0
    end;

  function ReadKey : char; assembler;
    asm
      MOV  AH, 08h
      INT  21h
    end;

  function Keypressed : boolean; assembler;
    asm
      MOV  AH, 0bh
      INT  21h
      MOV  CL, True
      CMP  AL, 0ffh
      JE   @Done
      MOV  CL, False
    @Done:
      MOV  AL, CL
    end;

  procedure Ln; assembler;
    asm
      MOV  AX, LineMax
      INC  Line
      CMP  Line, AX
      JL   @Done
      MOV  Line, 1
      CMP  Config.Pause, False
      JE   @Done
      {$IFOPT G+}
      PUSH SEG PauseStr
      PUSH OFFSET PauseStr
      {$ELSE}
      MOV  AX, SEG PauseStr
      PUSH AX
      MOV  AX, OFFSET PauseStr
      PUSH AX
      {$ENDIF}
      CALL WriteNul
    @1:
      CALL Keypressed
      CMP  AL, True
      JNE @1
      CALL ReadKey
      CMP  AL, 0
      JE   @1
      {$IFOPT G+}
      PUSH SEG PauseStr
      PUSH OFFSET PauseStr
      {$ELSE}
      MOV  AX, SEG PauseStr
      PUSH AX
      MOV  AX, OFFSET PauseStr
      PUSH AX
      {$ENDIF}
      CALL EraseNul
    @Done:
    end;

  procedure WriteLn; assembler;
    asm
      {$IFOPT G+}
      PUSH SEG CrLfStr
      PUSH OFFSET CrLfStr
      {$ELSE}
      MOV AX, SEG CrLfStr
      PUSH AX
      MOV AX, OFFSET CrLfStr
      PUSH AX
      {$ENDIF}
      CALL WriteNul
      CALL Ln;
    end;

  procedure WriteStr ( S : String );
    begin
      S[Length(S) + 1] := #0;
      WriteNul( @S[1] );
    end;

  procedure Error ( Code : word );
    const
      Prefix : array[0..10] of char = aError + ' ';
      Suffix : array[0..10] of char = '. ';
    var
      P : Pointer;
    begin
      if Not Config.Capture then EraseNul(@TitleStr);
      WriteNul(@Prefix);
      Case Code of
        erPath_Not_Found     : P := @Path_Not_Found_Str;
        erNot_Enough_Memory  : P := @Not_Enough_Memory_Str;
        erFile_Access_Denied : P := @File_Access_Denied_Str;
        erDrive_not_ready    : P := @Drive_not_ready_Str;
        erDevice_read_fault  : P := @Device_Read_fault_Str;
        erInvalid_Parameters : P := @Invalid_Parameter_Str;
      else
        P := nil;
        WriteNul (@Unknown_Error_Str);
        WriteStr (IntStr(Code));
      end;
      if Assigned(P) then WriteNul(P);
      WriteNul(@Suffix);
      WriteLn;
      Halt(Code);
    end;

  function CountStr ( ALong : LongInt; ASuffix : String ) : String;
    var
      S : String;
    begin
      if ALong = 0 then
        begin
          S := 'No ';
          AddStr (S, ASuffix);
          AddChr (S, 's');
        end
      else
        begin
          S := Comma(IntStr(ALong));
          AddChr( S, ' ');
          AddStr(S, ASuffix);
          if ALong = 1 then
            AddChr(S, ' ')
          else
            AddChr(S, 's');
        end;
      CountStr := S;
    end;

  function DateStr ( AStyle : byte; ALong : LongInt ) : String;
      var
      S : String;
      D : DateTime;
    begin
      UnpackTime(ALong, D);
      case AStyle of
        0 : S := '';
        2 : begin
          S := LSPace(IntStr(D.Month),3);
          AddChr(S, '/');
          AddStr(S, ZeroPad(IntStr(D.Day),2));
          AddChr(S, '/');
          AddStr(S, ZeroPad(IntStr(D.Year mod 100),2));
        end
      else
        S := IntStr(D.Month);
        AddChr(S, '/');
        AddStr(S, ZeroPad(IntStr(D.Day),2));
        AddChr(S, '/');
        AddStr(S, ZeroPad(IntStr(D.Year),4));
      end;
      DateStr := S;
    end;

  function TimeStr ( AStyle : byte; ALong : LongInt ) : String;
    var
      S : String;
      D : DateTime;
      P : boolean;
    begin
      UnpackTime(ALong, D);
      P := D.Hour > 11;
      if D.Hour > 12 then Dec(D.Hour,12);
      if D.Hour = 0 then D.Hour := 12;
      case AStyle of
        0 : S := '';
        2 : begin
          S := LSpace(IntStr(D.Hour),3);
          AddChr(S, ':');
          AddStr(S, ZeroPad(IntStr(D.Min),2));
          case P of
            True  : AddChr(S, 'p');
            False : AddChr(S, 'a');
          end;
        end;
      else
        S := IntStr(D.Hour);
        AddChr(S, ':');
        AddStr(S, ZeroPad(IntStr(D.Min),2));
        AddChr(S, ':');
        AddStr(S, ZeroPad(IntStr(D.Sec),2));
        case P of
          True  : AddStr(S, 'pm');
          False : AddStr(S, 'am');
        end;
      end;
      TimeStr := S;
    end;

  procedure Help; assembler;
    asm
      DB 'Displays a list of files in the specified directory.',13,10
      DB 13,10
      DB 'D [drive:][path][filename] [/H] [/Dn] [/Ln] [/R] [/S] [/P] [/T] [/F] [/A]',13,10
      DB '                           [/C] [/XF] [/XD] [/FF] [/FD]',13,10
      DB 13,10
      DB '  /H   Displays this help screen.',13,10
      DB '  /D   Displays file discriptions, where n is 0-2 (0=off; 1=short; 2=full).',13,10
      DB '       Also, sets /L1',13,10
      DB '  /L   Determins which line style to use, where n is 0-3 (0=normal; 1=mini;',13,10
      DB '       2=short; 3=long).',13,10
      DB '  /R   Display actual subst''d paths.',13,10
      DB '  /S   Display volume serial numbers.',13,10
      DB '  /T   Display drive types.',13,10
      DB '  /F   Display file allocation type.',13,10
      DB '  /P   Pause between pages.',13,10
      DB '  /A   Don''t test for ansi, and force ansi codes on or off',13,10
      DB '  /C   Prepares output is being for redirection. (Also, sets /P-/A-)',13,10
      DB '  /O   Displays only single column file list, no header or summary', 13,10
      DB '  /XF  Exclude files from list. (Overrides /FF)',13,10
      DB '  /XD  Exclude Directories from list. (Overrides /FD)',13,10
      DB '  /FF  Forces all files to be listed.',13,10
      DB '  /FD  Forces all directories to be listed.',13,10
      DB 0
{
      CheckScr : boolean;
      }
    end;

  procedure Parse ( var Params : String );
    function Scan ( S : String ) : boolean;
      var
        L : integer;
      begin
        Scan := False;
        L := Pos(UCase(S), UCase(Params));
        if L <> 0 then
          begin
            Scan := True;
            Delete (Params, L, Length(S));
          end;
      end;
    procedure ScanToggle( S : String; var B : Boolean );
      begin
        if Scan (S + '-') then B := False else
        if Scan (S + '+') or Scan(S) then B := True;
      end;
    begin
      if Scan ('/H') or Scan('/?') then
        begin
          WriteNUL ( @Help );
          Halt;
        end;
      ScanToggle ( '/C', Config.Capture );
      if Config.Capture then
        begin
          Config.Pause := False;
          Config.Ansi := Off;
        end;
      if Scan ('/D0') then Config.Disc := off else
      if Scan ('/D1') then Config.Disc := Short else
      if Scan ('/D2') or Scan('/D') then Config.Disc := Full;
      if Config.Disc <> off then Config.Style := Mini;
      if Scan ('/L0') then Config.Style := Normal else
      if Scan ('/L2') then Config.Style := Short else
      if Scan ('/L3') then Config.Style := Expanded else
      if Scan ('/L1') or Scan('/L') then Config.Style := Mini;
      ScanToggle ( '/XF', Config.NoIncFile );
      ScanToggle ( '/XD', Config.NoIncDir );
      ScanToggle ( '/FF', Config.ForceFile );
      ScanToggle ( '/FD', Config.ForceDir );
      ScanToggle ( '/R', Config.SubSt );
      ScanToggle ( '/S', Config.Serial );
      ScanToggle ( '/T', Config.DiskType );
      ScanToggle ( '/F', Config.Fat );
      ScanToggle ( '/P', Config.Pause );
      ScanToggle ( '/O', Config.Only );
      if Scan ('/A-') then Config.Ansi := Off else
      if Scan ('/A+') or Scan('/A') then Config.Ansi := On;
      While (Length(Params) > 0) and (Params[Length(Params)] = #32) do Dec(Byte(Params[0]));
      While (Length(Params) > 0) and (Params[1] = #32) do Delete ( Params, 1, 1 );
    end;

  procedure Init;
    var
      I, X : Word;
    begin
      Params := GetEnv(EnvVar);
      Parse( Params );
      Params := '';
      for I := 1 to ParamCount do
        AddStr(Params, ParamStr(I) + ' ');
      Parse( Params );
      if Pos(#32, Params) > 0 then Error(erInvalid_Parameters);
      Case Config.Ansi of
        Test : DetectAnsi;
        Off  : AnsiFound := False;
        On   : AnsiFound := True;
      end;
      case Config.Style of
        Normal : FileWide := 40;
        Mini   : FileWide := 14;
        Short  : FileWide := 24;
        Expanded : FileWide := 55;
      end;
      if Config.CheckScr then
        begin
          Width := MemW[0:$044a];
          LineMax := Mem[0:$0484] + 1;
        end;
      if Width < FileWide - 1 then
        Columns := 1
      else
        Columns := 1 + ((Width - (FileWide - 1)) div (FileWide + 1));
      if Config.Only = True then Columns := 1;
    end;

  function FileStr ( P : PEntry ) : String;
    var
      T, S : String;
      C : Char;
      DirID : String[5];
    begin
      DirID := '<DIR>';
      if Config.Disc <> Off then
        C := ' '
      else
      if Assigned(P^.Disc.Disc) then
        C := Config.DiscChar
      else
        C := ' ';
      S := P^.Name;
      if P^.Attr and Hidden = Hidden then
        begin
          S := LCase(S);
          DirId := LCase(DirID);
        end;
      if P^.Attr = 0 then InsStr(S, aNoAttr);
      if P^.Attr and Directory = Directory then InsStr(S, aDir);
      if P^.Attr and SysFile   = SysFile   then InsStr(S, aSystem);
      if P^.Attr and Hidden    = Hidden    then InsStr(S, aHidden);
      if P^.Attr and ReadOnly  = ReadOnly  then InsStr(S, aReadOnly);
      if P^.Attr and Archive   = Archive   then InsStr(S, aArchive);
      if Not (Config.Style = Mini) then
        begin
          T := IntStr(P^.Size);
          if Config.Style = Expanded then T := Comma(T);
          if (P^.Attr and Directory = Directory) then T := DirId;
          if Config.Style = Expanded then
            T := LSpace(T,14)
          else
            T := LSpace(T,10);
          if P^.Attr and Directory = Directory then
            begin
              InsStr(S, aNormal);
              AddStr(S, T + aNormal);
            end
          else
            begin
              InsStr(S, aNormal);
              AddStr(S, aNormal + T);
            end
        end
      else
        AddStr(S, aNormal);
      InsStr(S, aNormal);
      InsStr(S, C);
      InsStr(S, aDiscChar);
      if Not ((Config.Style = Short) or (Config.Style = Mini)) then
        begin
          if Config.Style = Expanded then
            begin
              AddChr(S, ' ');
              if P^.Attr and ReadOnly  = ReadOnly  then
                AddStr(S, aNormal + aReadOnly + 'r')
              else
                AddStr(S, aNormal + aNoAttr + '.');

              if P^.Attr and Archive   = Archive   then
                AddStr(S, aNormal + aArchive + 'a')
              else
                AddStr(S, aNormal + aNoAttr + '.');

              if P^.Attr and SysFile   = SysFile   then
                AddStr(S, aNormal + aSystem + 's')
              else
                AddStr(S, aNormal + aNoAttr + '.');

              if P^.Attr and Hidden    = Hidden    then
                AddStr(S, aNormal + aHidden + 'h')
              else
                AddStr(S, aNormal + aNoAttr + '.');

              AddStr(S, aNormal);
            end;

          if Config.Style = Expanded then
            AddStr(S, LSpace(DateStr(1, P^.Time),11))
          else
            AddStr(S, DateStr(2, P^.Time));

          if Config.Style = Expanded then
            AddStr(S, LSpace(TimeStr(1, P^.Time),11))
          else
            AddStr(S, TimeStr(2, P^.Time));
        end;
      FileStr := S;
    end;

  procedure DisplayColumn ( Dir : TDir );
    var
      PC    : array[1..255] of PEntry;
      Page  : PEntry;
      Lines : word;
      I, J, X  : Word;
      Count, Entry : LongInt;
    begin
      Page := Dir.Entries;
      Entry := Dir.FileCount + Dir.DirCount;
      Count := 0;
      while Assigned ( Page ) do
        begin
          if (Entry - Count) mod Columns <> 0 then
            Lines := ((Entry - Count) div Columns) + 1
          else
            Lines := ((Entry - Count) div Columns);
          if Lines > LineMax - Line then
            Lines := LineMax - Line;
          PC[1] := Page;
          for J := 2 to Columns do
            begin
              PC[J] := PC[J - 1];
              for I := 1 to Lines do
                if Assigned(PC[J]) then
                  PC[J] := PC[J]^.Next;
            end;
          for J := 1 to Lines do
            begin
              if Assigned(PC[1]) then
                begin
                  WriteStr ( FileStr(PC[1]));
                  PC[1] := PC[1]^.Next;
                  Inc(Count);
                end
              else
                WriteStr(ChrStr(Fill, FIleWide - 1));
              X := FileWide - 1;
              for I := 2 to Columns do
                begin
                  if Assigned(PC[I]) then
                    begin
                      WriteStr(' ' + Bar);
                      WriteStr( FileStr(PC[I]) );
                      PC[I] := PC[I]^.Next;
                      Inc(Count);
                    end
                  else
                    WriteStr( ChrStr(Fill, FileWide + 1) );
                  Inc(X, FileWide + 1);
                end;
              if Columns = 1 then Dec(X);
              if (X < Width) or (Config.Capture) then WriteLn else begin WriteStr ( aNormal ); Ln; end;
            end;
          for X := 1 to Lines * Columns do
            if Assigned(Page) then
              Page := Page^.Next;
        end;
    end;

  procedure DisplayDisc ( Dir : TDir );
    var
      P : PEntry;
      I : word;
      X : integer;
    begin
      P := Dir.Entries;
      while Assigned ( P ) do
        begin
          WriteStr ( FileStr(P) );
          WriteStr ( ' ' + Bar + ' ' + aDisc );
          X := FileWide + 2;
          if Assigned(P^.Disc.Disc) then
            begin
              I := 0;
              while (Chars(P^.Disc.Disc^)[I] <> 0) and
              ((Chars(P^.Disc.Disc^)[I] <> 13) or (Config.Disc <> Short)) do
                begin
                  if Chars(P^.Disc.Disc^)[I] = 13 then
                    begin
                      if X < Width then WriteLn;
                      X := FileWide + 2;
                      WriteStr(aNormal );
                      WriteStr(ChrStr(#32,X - 2));
                      WriteStr(Bar + ' ' + aDisc );
                    end
                  else
                  if X < Width then
                    begin
                      WriteStr(Chr(Chars(P^.Disc.Disc^)[I]) );
                      Inc(X);
                    end;
                  Inc(I);
                end;
            end;
          if (X < Width) or (Config.Capture) then WriteLn else begin WriteStr(aNormal); Ln; end;
          P := P^.Next;
        end;
    end;

  procedure DisplayFiles ( Dir : TDir );
    begin
      if Config.Disc <> Off then
        DisplayDisc(Dir)
      else
        DisplayColumn(Dir);
    end;

  procedure Display ( Dir : TDir );
    var
      I : LongInt;
      T : integer;
      J : word;
    procedure Indent ( Indent : byte );
      begin
        if Width < 80 then
          WriteStr(ChrStr(#32,Indent));
      end;
    procedure CheckWidth ( AIndent : byte );
      begin
        if Width < 80 then
          begin
            WriteLn;
            Indent(AIndent);
          end;
      end;
    begin
    (* Header *)
    if Config.Only = False then begin
      { Drive Type }
      if Config.DiskType then
        begin
          WriteStr ( ANormal + ' Drive ' + ABold );
          WriteStr( Chr(Dir.Drive + 64) );
          WriteStr( ANormal + ' is a ');
          if Dir.Remote then WriteStr ( 'remote' ) else WriteStr('local');
          CheckWidth(0);
          if Dir.CDROM then WriteStr(' CD-ROM');
          WriteStr ( ' drive using ');
          if Not Dir.Removable then WriteStr('non-');
          WriteStr('removable media.');
          WriteLn;
        end;
      { Volume Label }
      WriteNul ( @VolumeStr );
      WriteStr ( Chr(Dir.Drive + 64) );
      if Dir.VolumeID = '' then
        WriteNul ( @NoLabelStr )
      else
        begin
          WriteNul ( @IsStr );
          WriteStr ( Dir.VolumeID );
          if Width > 40 then
            WriteStr ( ChrStr(#32, 7) );
          CheckWidth(1);
          WriteNul ( @CreatedOnStr );
          WriteStr ( DateStr( 1, Dir.VolumeTime ) );
          WriteNul ( @AtStr );
          WriteStr ( TimeStr( 1, Dir.VolumeTime ) );
        end;
      WriteLn;
      { Serial Number }
      if (Dir.Serial <> '') and (Config.Serial) then
        begin
          WriteNul ( @SerialStr );
          WriteStr ( Dir.Serial );
          WriteLn;
        end;
      { Directory Path }
      if Dir.Dir <> '' then
        begin
          WriteNul ( @DirStr );
          T := 0;
          if (Dir.Subst <> '') and (Config.Subst) then
            begin
              WriteStr( AHighlight + '(' );
              WriteStr( Dir.SubSt );
              WriteStr( ') ' );
              T := Length(Dir.SubSt) + 3;
            end;
          WriteStr ( aBold );
          WriteStr ( Dir.Dir );
          Inc(T, Length(Dir.Dir));
          while (T + 14 > Width) do
            begin
              Dec(T,Width);
              Inc(Line);
            end;
          WriteLn;
        end;
      { FAT Type }
      if (Dir.FatType <> '') and (Config.Fat) then
        begin
          WriteNul ( @FatStr );
          WriteStr ( Dir.FatType );
          WriteLn;
        end;
      WriteLn;
    end;
    (* Info Text *)
    if Assigned(Dir.InfoText.Disc) then
      begin
        WriteStr ( AInfo );
        J := 0;
        T := 0;
        while Chars(Dir.InfoText.Disc^)[J] <> 0 do
          begin
            case Chars(Dir.InfoText.Disc^)[J] of
              13 : begin
                if T < Width then
                  begin
                    WriteLn;
                    WriteStr(AInfo)
                  end
                else
                  Ln;
                T := 0;
              end;
              10 : begin end;
            else
              if T > Width then Dec(T, Width);
              WriteStr(Chr(Chars(Dir.InfoText.Disc^)[J]));
              Inc(T);
              if T  = Width then
                  Ln;
            end;
            Inc(J);
          end;
        WriteStr ( ANormal );
        WriteLn;
        WriteLn;
      end;
    (* FileList *)
      if Dir.Entries = nil then
        begin
          WriteStr ( NoFilesStr );
          WriteLn;
        end
      else
        DisplayFiles( Dir );
    if Config.Only = False then begin
      WriteLn;
    (* Summary *)
      { File Summary }
      if Dir.FileCount <> 0 then
        begin
          Indent(11);
          WriteStr ( LSpace(CountStr(Dir.FileCount, 'file'), 16) );
          CheckWidth(3);
          WriteStr ( LSpace(CountStr(Dir.FileSize,  'file byte'), 29) );
          CheckWidth(0);
          WriteStr ( LSpace(CountStr(Dir.FileSlack, 'slack byte'), 33) );
          WriteLn;
        end;
      { Dir Summary }
      if Dir.DirCount <> 0 then
        begin
          Indent(11);
          WriteStr ( LSpace(CountStr(Dir.DirCount, 'dir'), 15) );
          CheckWidth(2);
          WriteStr ( LSpace(CountStr(Dir.FileSize + Dir.FileSlack,  'byte'), 25) + ' in dir' );
          CheckWidth(2);
          WriteStr ( LSpace(Comma(IntStr(Dir.SectorSize)) + ' byte sectors', 32) );
          WriteLn;
        end;
      { Disk Summary }
      I := (Dir.DiskSize - Dir.DiskFree) div ( Dir.DiskSize div 100 );
      if I > 100 then I := 100;
      Indent(11);
      WriteStr ( LSpace(IntStr(I),9) + '% used');
      CheckWidth(2);
      WriteStr ( LSpace(CountStr(Dir.DiskFree, 'free byte'), 30) );
      Checkwidth(0);
      WriteStr ( LSpace(CountStr(Dir.DiskSize - Dir.DiskFree, 'used byte'), 32) );
      WriteLn;
    end;
    end;

  procedure Run;
    var
      Dir : TDir;
      Result : integer;
      Options : word;
    begin
     Options := 0;
     if Not Config.NoIncFile then Options := Options or opIncFile;
     if     Config.ForceFile then Options := Options or opForceFile;
     if Not Config.NoIncDir then Options := Options or opIncDir;
     if     Config.ForceDir then Options := Options or opForceDir;
     if Not Config.Capture then WriteNul(@TitleStr);
     Result := ReadDir ( Params, Dir, Options );
     if Result = 0 then
       begin
         if Not Config.Capture then EraseNul ( @TitleStr );
         Display ( Dir );
       end
     else
       Error( Result );
    end;

  procedure Done;
    begin
    end;

