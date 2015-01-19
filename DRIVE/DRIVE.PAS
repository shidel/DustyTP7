{

	Copyright 1990-2015, Jerome Shidel.

	This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.

}

program Drives;

  uses Dos, StrAsm, Errors;

  const
    erNone = 0;

  type
    TDriveInfo = record
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
      Clusters   : LongInt;
      Sectors    : LongInt;
      SectorSize : LongInt;
      DiskSize   : LongInt;
      DiskFree   : LongInt;
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

  function GetClusters( ADrive: byte ) : word; assembler;
    asm
      PUSH DS
      MOV  AH, 1Ch
      MOV  DL, ADrive
      INT  21h
      MOV  AX, DX
      POP  DS
    end;

  function GetSectors( ADrive: byte ) : byte; assembler;
    asm
      PUSH DS
      MOV  AH, 1Ch
      MOV  DL, ADrive
      INT  21h
      POP  DS
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

  function IsValidDrive ( ADrive : byte ) : boolean; assembler;
    asm
      MOV  DosError, erInvalid_Drive_Number
      MOV  AX, 4408h
      MOV  BL, ADrive
      INT  21h
      MOV  CL, False
      CMP  AX, 01h
      JG   @@NotValid
      MOV  DosError, erNone
      MOV  CL, True
    @@NotValid:
      MOV  AL, CL
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

  procedure GetDiskInfo ( var Dir : TDriveInfo );
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

  procedure ClearDrive ( var Dir : TDriveInfo );
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
      Dir.Clusters   := 0;
      Dir.Sectors    := 0;
      Dir.SectorSize := 0;
      Dir.DiskSize   := 0;
      Dir.DiskFree   := 0;
    end;

  function ReadDrive ( DriveLetter : String; var Dir : TDriveInfo ) : integer;
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
        ReadDrive := Result;
        Error := Result <> 0;
      end;
    begin
      ClearDrive ( Dir );
      FSPlit ( FExpand(DriveLetter), D, N, E );
      Dir.Dir   := D;
      Dir.Drive := Ord(Dir.Dir[1]) - 64;

      GetDiskInfo ( Dir );

      DriveLetter := D + N + E;
      if Length(DriveLetter) <> 3 then
        begin
          FindFirst ( DriveLetter, AnyFile, SRec );
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
      Dir.Clusters := GetClusters(Dir.Drive);
      Dir.Sectors := GetSectors(Dir.Drive);
      Error(0);
      Error(Dir.Result);
    end;

  procedure ShowDrive ( var Info : TDriveInfo );
    const
      Tab = '  ';
    begin
      with Info do
        begin
          WriteLn ('Drive ', Chr(64 + Drive), ':');
          if IsValidDrive(Drive) then
            begin
              Write (Tab, 'Drive ', Chr(64 + Drive), ': is a ');
              if Remote then
                Write ('remote ')
              else
                Write ('local ');
              case DriveType of
                1 : Write ('physical ');
                2 : Write ('network ');
                3 : Write ('installable ');
              end;
              if CDROM then
                Write ('CDROM ');
              Write ('drive, using ');
              if Removable then
                Write ('removable ')
              else
                Write ('fixed ');
              WriteLn ('media.');

              if Result = erNone then
                begin
                  Write (Tab, 'Volume Label ');
                  if VolumeID <> '' then
                    WriteLn('is ''', VolumeID, '''')
                  else
                    WriteLn ( 'has no name');
                  if Serial <> '' then
                    WriteLn (Tab, 'Serial Number is ', Serial );
                  if FatType <> '' then
                    WriteLn (Tab, 'File Allocation Type is ', FATType );
                  WriteLn (Tab, 'Directory is ', Dir );
                  if SubSt <> '' then
                    WriteLn (Tab, Tab, 'SubSt of ', SubSt);
                  if Join <> '' then
                    WriteLn (Tab, Tab, 'Join''d to ', SubSt);
                  WriteLn;
                  WriteLn ( Tab, 'Total Clusters: ', Comma(IntStr(Clusters)));
                  WriteLn ( Tab, 'Sectors per cluster: ', Comma(IntStr(Sectors)));
                  WriteLn ( Tab, 'Sector Size: ', Comma(IntStr(SectorSize)));
                  WriteLn ( Tab, 'Disk Size: ', Comma(IntStr(DiskSize)));
                  WriteLn ( TAB, 'Free Space: ', Comma(IntStr(DiskFree )));
                end;
              end
            else
              WriteLn (Tab, 'Is Not A Valid Drive');
        end;
      WriteLn;
    end;

  procedure GetDrives;
    var
      I : word;
      D : TDriveInfo;
    begin
      for I := 1 to 26 do
        if isValidDrive (I) then
          begin
            ReadDrive ( Chr(64 + I) + ':', D );
            ShowDrive ( D );
          end;
    end;

  procedure GetDrivesListed;
    var
      I : word;
      D : TDriveInfo;
    begin
      for I := 1 to ParamCount do
        begin
          ReadDrive ( ParamStr(I), D );
          ShowDrive ( D );
        end;
    end;



begin
  if ParamCount = 0 then
    GetDrives
  else
    GetDrivesListed;
end.
