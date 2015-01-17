{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}
  type
    Chars = array[0..$FFFE] of byte;
    Str2  = String[2];
    Str4  = String[4];
    Str5  = String[5];
    Str8  = String[8];
    Str16 = String[16];
    Str20 = String[20];
    Str32 = String[32];
    Str40 = String[40];

{---------------------------------------------------------------------------}
{ ERCONST.PAS                                                               }
{---------------------------------------------------------------------------}
  const
    { error codes }
    erNone                             = 0;
    erInvalid_function_number          = 1;
    erFile_not_found                   = 2;
    erPath_not_found                   = 3;
    erToo_many_open_files              = 4;
    erFile_access_denied               = 5;
    erInvalid_file_handle              = 6;
    erNot_enough_memory                = 8;
    erInvalid_environment              = 10;
    erInvalid_format                   = 11;
    erInvalid_file_access_code         = 12;
    erInvalid_drive_number             = 15;
    erCannot_remove_current_directory  = 16;
    erCannot_rename_across_drives      = 17;
    erNo_more_files                    = 18;
    erDisk_read_error                  = 100;
    erDisk_write_error                 = 101;
    erFile_not_assigned                = 102;
    erFile_not_open                    = 103;
    erFile_not_open_for_input          = 104;
    erFile_not_open_for_output         = 105;
    erInvalid_numeric_format           = 106;
    erDisk_is_write_protected          = 150;
    erBad_drive_request_struct_length  = 151;
    erDrive_not_ready                  = 152;
    erCRC_error_in_data                = 154;
    erDisk_seek_error                  = 156;
    erUnknown_media_type               = 157;
    erSector_Not_Found                 = 158;
    erPrinter_out_of_paper             = 159;
    erDevice_write_fault               = 160;
    erDevice_read_fault                = 161;
    erHardware_failure                 = 162;
    erDivision_by_zero                 = 200;
    erRange_check_error                = 201;
    erStack_overflow_error             = 202;
    erHeap_overflow_error              = 203;
    erInvalid_pointer_operation        = 204;
    erFloating_point_overflow          = 205;
    erFloating_point_underflow         = 206;
    erInvalid_floating_point_operation = 207;
    erOverlay_manager_not_installed    = 208;
    erOverlay_file_read_error          = 209;
    erObject_not_initialized           = 210;
    erCall_to_abstract_method          = 211;
    erStream_registration_error        = 212;
    erCollection_index_out_of_range    = 213;
    erCollection_overflow_error        = 214;
    erArithmetic_overflow_error        = 215;
    erGeneral_Protection_fault         = 216;
    erInvalid_Parameters               = 255;

{---------------------------------------------------------------------------}
{ STRASM.PAS                                                                }
{---------------------------------------------------------------------------}
  function ChrStr ( C   : Char;   N : byte ) : String;
    var
      S : String;
    begin
      S[0] := Char(N);
      if N > 0 then FIllChar ( S[1], N, C );
      ChrStr := S;
    end;

  function UCase ( Str : String ) : String;
    begin
      asm
        CLD
        LEA     SI, Str
        LES     DI, @Result
        SEGSS   LODSB
        STOSB
        XOR     AH, AH
        XCHG    AX, CX
        JCXZ    @3
      @1:
        SEGSS   LODSB
        CMP     AL, 'a'
        JB      @2
        CMP     AL, 'z'
        JA      @2
        SUB     AL, 20h
      @2:
        STOSB
        LOOP    @1
      @3:
      end;
    end;

  function LCase ( Str : String ) : String;
    begin
      asm
        CLD
        LEA     SI, Str
        LES     DI, @Result
        SEGSS   LODSB
        STOSB
        XOR     AH, AH
        XCHG    AX, CX
        JCXZ    @3
      @1:
        SEGSS   LODSB
        CMP     AL, 'A'
        JB      @2
        CMP     AL, 'Z'
        JA      @2
        ADD     AL, 20h
      @2:
        STOSB
        LOOP    @1
      @3:
      end;
    end;

  function LSpace ( Str : String; N : byte ) : String;
    begin
      if Length(Str) < N then
        LSpace := ChrStr(#32, N - Length(Str) ) + Str
      else
        LSpace := Str;
    end;

  function RSpace ( Str : String; N : Byte ) : String;
    begin
      if Length(Str) < N then
        RSpace := Str + ChrStr(#32, N - Length(Str) )
      else
        RSpace := Str;
    end;

  function ZeroPad ( Str : String; N : byte ) : String;
    begin
      if Length(Str) < N then
        ZeroPad := ChrStr('0', N - Length(Str) ) + Str
      else
        ZeroPad := Str;
    end;
{----------------------------------------------------------------------------}
  function HEXbyte ( B : byte ) : Str2; assembler;
    asm
      LES DI, @RESULT
      MOV AL, $02
      MOV ES:[DI], AL
      MOV AL, B
      MOV AH, B
      AND AH, $0F
      AND AL, $F0
      {$IFOPT G+}
      SHR AL, $04
      {$ELSE}
      MOV CL, $04
      SHR AL, CL
      {$ENDIF}
      CMP AL, $9
      JNA @@1
      ADD AL, $07
    @@1:
      ADD AL, $30
      CMP AH, $9
      JNA @@2
      ADD AH, $07
    @@2:
      ADD AH, $30
      MOV ES:[DI + 1], AX
    end;

  function HEXWord ( W : Word ) : Str4;
    begin
      HEXWord := HEXByte(Hi(W)) + HEXByte(Lo(W));
    end;

  function IntStr  ( L : LongInt ) : Str20;
    var
      S : Str20;
    begin
      Str ( L, S );
      IntStr := S;
    end;

  function Comma ( S : String ) : String;
    var
      I : Byte;
      P : Byte;
    begin
      P := Pos ('.', S);
      if P = 0 then P := Length(S) else Dec(P);
      I := P;
      While (I > 1) and (Pos(S[I - 1], '0123456789') <> 0) do
        if (P - I) and $3 = 2 then
          begin
            Insert ( ',', S, I );
            Inc(P);
          end
        else
          Dec(I);
      Comma := S;
    end;

  procedure AddChr ( var S : String; C : Char );
    begin
      Inc(Byte(S[0]));
      S[Byte(S[0])] := C;
    end;

  procedure AddStr ( var S1 : String; S2: String );
    var
      MoveLen : Byte;
    begin
      MoveLen := Byte(S2[0]);
      if MoveLen + Length(S1) > 255 then MoveLen := 255 - Length(S1);
      Move ( S2[1], S1[Length(S1) + 1], MoveLen );
      Inc(Byte(S1[0]), MoveLen);
    end;

  procedure InsChr ( var S1 : String; C : Char );
    begin
      S1 := C + S1;
    end;

  procedure InsStr ( var S1 : String; S2 : String );
    begin
      S1 := S2 + S1;
    end;

{---------------------------------------------------------------------------}
{ QDIR.PAS                                                                  }
{---------------------------------------------------------------------------}
  const
    opIncDir    = $0001;
    opForceDir  = $0002;
    opIncFile   = $0004;
    opForceFile = $0008;
    opStandard  = opIncDir or opIncFile;
    DiscFileName = 'DISCRIPT.DDF';

  type
    TDisc = record
      Disc : Pointer;
      Size : word;
    end;
    TDiscHeader = record
      ID      : Array[0..4] of char; { 'DDF'#26#0 }
      Version : word;                { $0001 }
      TextSize : word;
    end;
    TFileHeader = record
      Size    : word;
      Name    : String[12];
    end;
    PEntry = ^TEntry;
    TEntry = record
      Attr  : byte;
      Time  : LongInt;
      Size  : LongInt;
      Name  : String[12];
      Disc  : TDisc;
      Next  : PEntry;
      Prior : PEntry;
    end;

    PDir = ^TDir;
    TDir = record
      Result     : integer;
      Drive      : byte;
      Dir        : DirStr;
      Spec       : String[12];
      Subst      : DirStr;
      Join       : DirStr;
      VolumeID   : String[11];
      VolumeTime : LongInt;
      Serial     : String[9];
      FatType    : String[7];
      DriveType  : byte;  { 0=invalid; 1=physical; 2=network;
                            3:Installable File System; }
      Removable  : boolean;
      Remote     : boolean;
      CDROM      : boolean;
      FileCount  : LongInt;
      DirCount   : LongInt;
      FileSize   : LongInt;
      FileSlack  : LongInt;
      SectorSize : LongInt;
      DiskSize   : LongInt;
      DiskFree   : LongInt;
      Entries    : Pointer;
      InfoText   : TDisc;
    end;

  type
    TInfoBuffer = record
      InfoLevel  : word; {should be zero}
      Serial     : array[0..1] of word;
      VolumeID   : array [0..10] of char;
      FatType    : array [0..7] of char;
    end;

  function GetInfoBuffer( Disk : byte; var Buffer ) : Integer; assembler;
    asm
      PUSH DS
      MOV  AX, 6900h
      MOV  BL, Disk
      LDS  DX, Buffer
      INT  21h
      POP  DS
      JC   @Done
      XOR  AX, AX
    @Done:
    end;

  function GetSectorSize ( ADisk : byte ) : LongInt; assembler;
    asm
      PUSH DS
      MOV  AH, 1Ch
      MOV  DL, ADisk
      INT  21h
      MOV  DX, 0
      MOV  AX,CX
      POP  DS
    end;

  function IsRemovable ( ADrive : byte; var ARemovable : Boolean) : integer; assembler;
    asm
      MOV  AX, 4408h
      MOV  BL, ADrive
      INT  21h
      MOV  CL, False
      CMP  AX, 0
      JNE  @@SetRemovable
      MOV  CL, True
    @@SetRemovable:
      LES  DI, ARemovable
      MOV  ES:[DI], CL
      CMP  AX, 1
      JG   @@Error
      XOR  AX, AX
    @@Error:
    end;

  function IsRemote ( ADrive : byte; var ARemote : Boolean) : integer; assembler;
    asm
      MOV  AX, 4409h
      MOV  BL, ADrive
      INT  21h
      MOV  CL, False
      TEST DX, 1000h
      JZ   @@SetRemote
      MOV  CL, True
    @@SetRemote:
      LES  DI, ARemote
      MOV  ES:[DI], CL
      XOR  AX, AX
    end;

  function IsCDROM ( ADrive : byte ) : boolean; assembler;
    asm
      MOV  AX, 1500h
      XOR  BX, BX
      INT  2Fh
      MOV  DL, False
      CMP  BX, 0
      JE   @@Done { CDROM Multiplex not installed }
      XOR  AH, AH
      MOV  AL, ADrive
      INC  CX
      DEC  BX
      CMP  AX, CX
      JL   @@Done { Less then first CD }
      ADD  CX, BX
      CMP  AX, CX
      JG   @@Done { Greater then Last CD }
      MOV  DL, True
    @@Done:
      MOV  AL, DL
    end;

  procedure GetDiskInfo ( var Dir : TDir );
    var
      xword1, xword2, xword3, xword4, xword5 : word;
      Regs : Registers;
    begin
      with regs do
        begin
        AH:=$52;
        MsDos(regs);
        if (Lo(DosVersion)= 3) and (Hi(DosVersion) = 0) then
          begin
          xword1:=MemW[ES:BX + $19];
          xword2:=MemW[ES:BX + $17]
          end
        else
          begin
          xword1:=MemW[ES:BX + $18];
          xword2:=MemW[ES:BX + $16]
          end;
        if (Lo(DosVersion) >= 4) and (Lo(DosVersion) < 10) then
          xword5:=$58
        else
          xword5:=$51;
        if not ((xword1 = $FFFF) and (xword2 = $FFFF)) then
          begin
          xword3:=xword2 + (xword5 * (Dir.Drive - 1));
          Dir.DriveType := MemW[xword1:xword3 + $43] shr 14;
          if MemW[xword1:xword3 + $43] and $2000 = $2000 then
            begin
            xword4:=xword3;
            while Mem[xword1:xword4] <> 0 do
              begin
              Dir.Join := Chr(Mem[xword1:xword4]);
              Inc(xword4)
              end;
            end
          else
            Dir.Join := '';
          Dir.Subst := '';
          if MemW[xword1:xword3 + $43] and $1000 = $1000 then
            begin
            xword4:=xword3;
            while Mem[xword1:xword4] <> 0 do
              begin
              Dir.Subst := Dir.Subst + Chr(Mem[xword1:xword4]);
              Inc(xword4)
              end;
            end;
          end;
        end;
    end;

  procedure NSplit ( FileName : String; var Name : NameStr; var Ext : ExtStr );
    var
      Dir : DirStr;
    begin
      FSplit ( UCase(FileName), Dir, Name, Ext );
      if (Name = '') and ((Ext = '.') or (Ext = '..')) then
        begin
          Name := Ext;
          Ext := '';
        end;
      if Pos('*', Name) <> 0 then
        begin
          While Length(Name) < 8 do Insert('?', Name, Pos('*', Name) );
          While Pos('*', Name) > 0 do Name[Pos('*', Name)] := '?';
        end
      else
        Name := RSpace(Name,8);
      if Pos('*', Ext) <> 0 then
        begin
          While Length(Ext) < 4 do Insert('?', Ext, Pos('*', Ext) );
          While Pos('*', Ext) > 0 do Ext[Pos('*', Ext)] := '?';
        end
      else
        Ext := RSpace(Ext, 4);
    end;

  function Match ( Spec : String; Rec : SearchRec ) : boolean;
    var
      I : word;
    begin
      Match := False;
      for I := 1 to Length(Spec) do
        if (Spec[I] <> '?') and (Spec[I] <> Rec.Name[I]) and (I <> 9) then Exit;
      Match := True;
    end;

  function LessThan ( var P1, P2 : PEntry) : boolean;
    begin
      LessThan := P1^.Name < P2^.Name;
    end;

  function AddEntry ( var F, L : PEntry; Rec : SearchRec) : integer;
    var
      P, M : PEntry;
    begin
      AddEntry := erNot_enough_memory;
      if MaxAvail < Sizeof(TEntry) then Exit;
      New ( P );
      P^.Attr := Rec.Attr;
      P^.Time := Rec.Time;
      P^.Size := Rec.Size;
      P^.Name := Rec.Name;
      P^.Disc.Disc := nil;
      P^.Disc.Size := 0;
      P^.Next := nil;
      P^.Prior := nil;
      if not Assigned(F) then
        begin
          F := P;
          L := P;
        end
      else
      if LessThan(P, F) then
        begin
          P^.Next := F;
          F^.Prior := P;
          F := P;
        end
      else
      if LessThan(L, P) then
        begin
          L^.Next := P;
          P^.Prior := L;
          L := P;
        end
      else
        begin
          M := F;
          while Assigned(M) and LessThan(M, P) do M := M^.Next;
          if Assigned(M) then
            begin
              P^.Prior := M^.Prior;
              P^.Next := M;
              P^.Prior^.Next := P;
              M^.Prior := P;
            end
          else
            begin
              WriteLn ( P^.Name );
              AddEntry := erInvalid_Pointer_Operation;
              Exit;
            end;
        end;
      AddEntry := erNone;
    end;

  procedure LogDir ( Path, Spec : String; var Dir : TDir; Options : word );
    var
      FDir, LDir, FFile, LFile : PEntry;
      SRec : SearchRec;
      N : NameStr;
      E : ExtStr;
      Slack : LongInt;
    begin
      FDir := nil;
      LDir := nil;
      FFile := nil;
      LFile := nil;
{      if Length(Path) > 3 then Path := Path + '\';}
      NSplit ( Spec, N, E );
      Spec := N + E;
      FindFirst ( Path + '*.*', AnyFile, SRec );
      Dir.Result := DosError;
      While Dir.Result = erNone do
        begin
          if SRec.Attr and VolumeID = VolumeID then
            begin
              { Dump Volume ID }
            end
          else
          if SRec.Attr and Directory = Directory then
            begin
              NSplit( SRec.Name, N, E );
              SRec.Name := N + E;
              if (Options and opIncDir = opIncDir) then
                begin
                  if (Options and opForceDir = opForceDir) or
                  (Match(Spec, SRec)) then
                    begin
                      Dir.Result := AddEntry ( FDir, LDir, SRec );
                      if Dir.Result = erNone then
                        begin
                          Inc(Dir.DirCount);
                        end;
                    end;
                end;
            end
          else
            begin
              if (Options and opIncFile = opIncFile) then
                begin
                  NSplit( SRec.Name, N, E );
                  SRec.Name := N + E;
                  if (Options and opForceFile = opForceFile) or
                  (Match(Spec, SRec)) then
                    begin
                      Dir.Result := AddEntry ( FFile, LFile, SRec );
                      if Dir.Result = erNone then
                        begin
                          Inc(Dir.FileCount);
                          Inc(Dir.FileSize, SRec.Size);
                          Slack := SRec.Size mod Dir.SectorSize;
                          if Slack <> 0 then
                            Inc(Dir.FileSlack, Dir.SectorSize - Slack);
                        end;
                      end;
                end;
            end;
          if Dir.Result = erNone then
            begin
              FindNext(SRec);
              Dir.Result := DosError;
            end;
        end;
      if Dir.Result = erNo_More_Files then Dir.Result := erNone;
      Dir.Entries := FDir;
      if Assigned(FFile) then
        begin
          if Assigned(LDir) then
            begin
              LDir^.Next := FFile;
              FFile^.Prior := LDir;
            end
          else
            Dir.Entries := FFile;
        end;
    end;

  function ReadDisc(FileName : String; var Dir : TDir ) : integer;
    var
      FM : word;
      F  : File;
      N  : String[12];
      PE : PEntry;
      Er : integer;
      DH : TDiscHeader;
      FH : TFileHeader;
      P  : Pointer;
      Sz : word;
    begin
      ReadDisc := erNone;
      FM := FileMode;
      FileMode := 0;
      Assign(F, FileName);
      Reset(F,1);
      FileMode := FM;
      Er := IOResult;
      if Er <> erNone then Exit;
      BlockRead(F, DH, Sizeof(DH));
      Er := IOResult;
      if (Er <> erNone) or (DH.ID <> 'DDF'#26#0) or (DH.Version <> $0001) then Exit;
      { Read Info Text }
      if DH.TextSize <> 0 then
        begin
          if MaxAvail <= DH.TextSize then
            begin
              ReadDisc := erNot_Enough_Memory;
              Exit;
            end;
          GetMem(P, DH.TextSize);
          BlockRead ( F, P^, DH.TextSize );
          Er := IOResult;
          if Er = erNone then
            begin
              Dir.InfoText.Size := DH.TextSize;
              Dir.InfoText.Disc := P;
            end
          else
            FreeMem ( P, DH.TextSize );
        end;
      if Er <> erNone then Exit;
      { Read File Discription }
      PE := Dir.Entries;
      if Assigned(PE) then
        repeat
          BlockRead(F, FH.Size, Sizeof(FH.Size));
          Er := IOResult;
          if (FH.Size <> 0) and (Er = erNone) then
            begin
              Sz := FH.Size - (Sizeof(FH) - Sizeof(FH.Size));
              BlockRead ( F, FH.Name, Sizeof(FH.Name));
              Er := IOResult;
              if (Er = 0) then
                begin
                  while (FH.Name > PE^.Name) and Assigned(PE^.Next) do PE := PE^.Next;
                  while (FH.Name < PE^.Name) and Assigned(PE^.Prior) do PE := PE^.Prior;
                  while (FH.Name <> PE^.Name) and Assigned(PE^.Next) do PE := PE^.Next;
                  while (FH.Name <> PE^.Name) and Assigned(PE^.Prior) do PE := PE^.Prior;
                  if (FH.Name = PE^.Name) then
                    begin
                      if MaxAvail <= Sz then
                        Er := erNot_Enough_Memory
                      else
                        begin
                          PE^.Disc.Size := Sz;
                          GetMem(P, Sz);
                          BlockRead(F, P^, Sz);
                          Er := IOResult;
                          if Er = erNone then
                            begin
                              PE^.Disc.Disc := P;
                              PE^.Disc.Size := Sz;
                            end
                          else
                            FreeMem ( P, Sz );
                        end;
                    end
                  else
                    begin
                      Seek(F, FIlePos(F) + Sz);
                      Er := IOResult;
                    end;
                end;
            end;
        until (FH.Size = 0) or (Er <> erNone);
      Close(F);
      Er := IOResult;
    end;

  procedure ClearDir ( var Dir : TDir );
    begin
      Dir.Result     := erNone;
      Dir.Drive      := 0;
      Dir.Dir        := '';
      Dir.Subst      := '';
      Dir.Join       := '';
      Dir.VolumeID   := '';
      Dir.VolumeTime := 0;
      Dir.Serial     := '';
      Dir.FatType    := '';
      Dir.DriveType  := 0;
      Dir.Removable  := True;
      Dir.Remote     := False;
      Dir.CDROM      := False;
      Dir.FileCount  := 0;
      Dir.DirCount   := 0;
      Dir.FileSize   := 0;
      Dir.FileSlack  := 0;
      Dir.DiskSize   := 0;
      Dir.DiskFree   := 0;
      Dir.Entries    := nil;
      Dir.InfoText.Disc := nil;
      Dir.InfoText.Size := 0;
    end;

  function ReadDir ( PathSpec : String; var Dir : TDir; Options : word ) : integer;
    var
      InfoBuffer : TInfoBuffer;
      SRec       : SearchRec;
      D          : DirStr;
      N          : NameStr;
      E          : ExtStr;
      T          : String[12];
      WkDir      : DirStr;
    function Error ( Result : integer ) : boolean;
      begin
        Dir.Result := Result;
        ReadDir := Result;
        Error := Result <> 0;
      end;
    begin
      ClearDir ( Dir );
      FSPlit ( FExpand(PathSpec), D, N, E );
      Dir.Dir   := D;
      Dir.Drive := Ord(Dir.Dir[1]) - 64;

      GetDiskInfo ( Dir );

      PathSpec := D + N + E;
      if Length(PathSpec) <> 3 then
        begin
          FindFirst ( PathSpec, AnyFile, SRec );
          Error(DosError);
          if (Dir.Result = erNone) and (SRec.Attr and Directory = Directory) then
            begin
              T := SRec.Name;
              FindNext ( SRec );
              if DosError = erNo_More_Files then
                begin
                  D := D + T;
                  N := '';
                  E := '';
                end;
            end;
        end;
      if D[Length(D)] <> '\' then D := D + '\';
      Dir.Dir := D;
      if N + E <> '' then
        Dir.Spec := N + E
      else
        Dir.Spec := '*.*';
      WkDir := Dir.Dir;
      if Length(Dir.Dir) > 3 then Dec(Byte(Dir.Dir[0]));
      if GetInfoBuffer(Dir.Drive, InfoBuffer) = 0 then
        begin
          Dir.Serial := HexWord(InfoBuffer.Serial[1]) + '-' +
          HexWord(InfoBuffer.Serial[0]);
          Dir.FatType := InfoBuffer.FatType;
        end;
      FindFirst ( Copy(WkDir, 1, 3) + '*.*', VolumeID, SRec );
      if Error(DosError) and (Dir.Result <> 18) then Exit;
      if Dir.Result = 0 then
        begin
          SRec.Name := RSpace(SRec.Name, 12);
          Delete(SRec.Name,9,1);
          Dir.VolumeID := SRec.Name;
          Dir.VolumeTime := SRec.Time;
        end;
      Dir.DiskSize := DiskSize(Dir.Drive);
      Dir.DiskFree := DiskFree(Dir.Drive);
      Dir.SectorSize := GetSectorSize(Dir.Drive);
      if Error(IsRemovable(Dir.Drive, Dir.Removable)) then Exit;
      if Error(IsRemote(Dir.Drive, Dir.Remote)) then Exit;
      Dir.CDROM := IsCDROM(Dir.Drive);
      Error(0);
      LogDir(WkDir, Dir.Spec, Dir, Options);
      Error(Dir.Result);
      Error(ReadDisc(WkDir + DiscFileName, Dir));
    end;

  procedure UnreadDir ( var Dir : TDir );
    var
      P, H : PEntry;
    begin
      P := Dir.Entries;
      while Assigned(P) and Assigned(P^.Next) do P := P^.Next;
      while Assigned(P) do
        begin
          H := P^.Prior;
          if Assigned(P^.Disc.Disc) then
            FreeMem (P^.Disc.Disc, P^.Disc.Size);
          Dispose ( P );
          P := H;
        end;
      if Assigned(Dir.InfoText.Disc) then
        FreeMem ( Dir.InfoText.Disc, Dir.InfoText.Size );
      ClearDir(Dir);
    end;

