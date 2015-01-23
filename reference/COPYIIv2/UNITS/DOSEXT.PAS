{ 
Copyright 1990-2015, Jerome Shidel.
	
This project and related files are subject to the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
}

{$I TURBO.DEF}
unit DosExt; { Version 2.00a }

interface

  uses Dos;

  type
    PDiskInfo = ^TDiskInfo;
    TDiskInfo = record
      Drive        : byte;      { 0 = Drive A, 1 = B ... }
      SubUnit      : byte;      { SubUnit number from driver device header }
      SectorSize   : word;      { bytes per sector }
      MaxSector    : byte;      { sectors per cluster - 1; Max sector in clustor }
      ClusterShift : byte;      { Sector per cluster shift; cluster 2^n sectors }
      BootSize     : word;      { reserved secotrs; boot sectors; start of root dir }
      FATTables    : byte;      { number of FATs }
      MaxRootDir   : word;      { number of dir entries allowed in root dir }
      DataSector   : word;      { sector number of cluster #2 ( first data cluster ) }
      MaxCluster   : word;      { Total clusters + 2; number of highest cluster }
      FatSize      : byte;      { Sectors needed by 1 FAT }
      Unknown      : byte;
      RootSector   : word;      { Sector number of start of root directory }
      DeviceHeader : Pointer;   { address of device header }
      Media        : byte;      { Media discriptor }
      AccessFlag   : byte;      { access flag; 0 if drive has been accessed }
      NextInfo     : PDiskInfo; { address of next disk info block; 0ffffh if last one }
    end;

  function IsRedirectedInput : boolean;                          { DOS 2.00+ }
  function IsRedirectedOutput : boolean;                         { DOS 2.00+ }
  function GetBreak : boolean;                                   { DOS 2.00+ }
  procedure SetBreak ( Break : boolean );                        { DOS 2.00+ }
  function IsValid(Drive : byte) : boolean;                      { DOS 3.00+ }
  function IsRemovable(Drive : byte) : boolean;                  { DOS 3.00+ }
  function IsRemote(Drive : byte) : boolean;                     { DOS 3.10+ }
  function IsCDROM (Drive : byte ) : boolean;                    { UNDOCUMENTED }
  function LastDrive : byte;                                     { DOS 3.00+ }
  function BootDrive : byte;                                     { DOS 4.00+ }
  function GetLogicalDrive(Drive : byte) : byte;                 { DOS 3.20+ }
  function SetLogicalDrive(Drive : byte) : byte;                 { DOS 3.20+ }
  function GetSerialNumber(Drive: byte) : longInt;               { DOS 4.00+ }
  procedure SetSerialNumber(Drive: byte; Serial : longInt);      { DOS 4.00+ }
  function GetSerialLabel(Drive: byte) : String;                 { DOS 4.00+ }
  procedure SetSerialLabel(Drive: byte; SerialLabel : String);   { DOS 4.00+ }
  function GetDiskInfoPtr(Drive : Byte) : Pointer;               { UNDOCUMENTED }
  procedure GetFatInfo(Drive : byte; var IDByte, Clusters,       { DOS 2.00+ }
    Sectors, BytesPerSector : word);
  function GetMaxLogicalSector (Drive : byte) : LongInt;         { DOS 2.00+ }
  function GetSectorSize (Drive : byte) : LongInt;               { DOS 2.00+ }

implementation

  type
    SerialInfo = record
      InfoLevel  : word; {should be zero}
      Serial     : LongInt;
      VolLabel   : array [0..10] of char;
      FileSystem : array [0..7] of char;
    end;

  function GetDeviceInfoWord(Handle : word) : word; assembler;
    asm
      MOV  AX, 4400h
      MOV  BX, Handle
      INT  21h
      JNC  @OK
      XOR  DX, DX
      JMP  @Done
    @OK:
      XOR  AX, AX
    @Done:
      MOV  DosError, AX
      MOV  AX, DX
    end;

  function IsRedirectedInput : boolean;
    begin
      IsRedirectedInput  := (GetDeviceInfoWord(0) and $80 <> $80) and (DosError = 0);
    end;

  function IsRedirectedOutput : boolean;
    begin
      IsRedirectedOutput := (GetDeviceInfoWord(1) and $80 <> $80) and (DosError = 0);
    end;

  function GetBreak : boolean; assembler;
    asm
      MOV  AX, 3300h
      INT  21h
      MOV  AL, True
      CMP  DL, 1
      JE   @1
      MOV  AL, False
    @1:
      MOV  DosError, 0
    end;

  procedure SetBreak ( Break : boolean ); assembler;
    asm
      MOV  AX, 3301h
      MOV  DL, 1
      MOV  CL, Break
      CMP  CL, True
      JE   @1
      MOV  DL, 0
    @1:
      INT  21h
      MOV  DosError, 0
    end;

  function IsValid(Drive : byte) : boolean; assembler;
    asm
      MOV  AX, 4408h
      MOV  BL, Drive
      INT  21h
      JNC  @OK
      CMP  AL, 0Fh
      JNE  @OK
      MOV  DL, False
      JMP  @Done
    @OK:
      XOR  AX, AX
      MOV  DL, True
    @Done:
      MOV  DosError, AX
      MOV  AL, DL
    end;

  function IsRemovable(Drive : byte) : boolean; assembler;
    asm
      MOV  AX, 4408h
      MOV  BL, Drive
      INT  21h
      JNC  @OK
      MOV  DL, True
      JMP  @Done
    @OK:
      MOV  DL, AL
      XOR  AX, AX
      CMP  DL, 0
      JE   @Removable
      MOV  DL, False
      JMP  @Done
    @Removable:
      MOV  DL, True
    @Done:
      MOV  DosError, AX
      MOV  AX, DX
    end;

  function IsRemote(Drive : byte) : boolean; assembler;
    asm
      MOV  AX, 4409h
      MOV  BL, Drive
      INT  21h
      JNC  @OK
      MOV  DL, False
      JMP  @Done
    @OK:
      MOV  DL, AL
      XOR  AX, AX
      CMP  DL, 1
      JE   @Remote
      MOV  DL, False
      JMP  @Done
    @Remote:
      MOV  DL, True
    @Done:
      MOV  DosError, AX
      MOV  AX, DX
    end;

  function IsCDROM ( Drive : byte ) : boolean; assembler;
    asm
      MOV  AX, 1500h
      XOR  BX, BX
      INT  2Fh
      MOV  DL, False
      CMP  BX, 0
      JE   @NotInstalled { CDROM Multiplex not installed }
      XOR  AH, AH
      MOV  AL, Drive
      INC  CX
      DEC  BX
      CMP  AX, CX
      JL   @NotCD { Less then first CD }
      ADD  CX, BX
      CMP  AX, CX
      JG   @NotCD { Greater then Last CD }
      MOV  DosError, 0
      MOV  AL, True
      JMP  @Done
    @NotInstalled:
    @NotCD:
      XOR  AX, AX
      MOV  AL, Drive
      PUSH AX
      CALL IsValid
      MOV  AL, False
    @Done:
    end;

  function LastDrive : byte; assembler;
    asm
      MOV  AH, 19h
      INT  21h
      MOV  DL, AL
      MOV  AH, 0Eh
      INT  21h
    end;

  function BootDrive : byte; assembler;
    asm
      MOV  AX, 3305h
      INT  21h
      MOV  AL, DL
    end;

  function GetLogicalDrive(Drive : byte) : byte; assembler;
    asm
      MOV  AX, 440Eh
      MOV  BL, Drive
      INT  21h
      JC   @@Error
      CMP  AL, 00h
      JNE  @@ReturnDrive
      MOV  AX, 000Fh { invalid drive number }
    @@Error:
      XOR  CL, CL
      JMP  @@Done
    @@ReturnDrive:
      MOV  CL, AL
      XOR  AX, AX
    @@Done:
      MOV  DosError, AX
      MOV  AL, CL
    end;

  function SetLogicalDrive(Drive : byte) : byte; assembler;
    asm
      MOV  AX, 440Fh
      MOV  BL, Drive
      INT  21h
      JC   @@Error
      CMP  AL, 00h
      JNE  @@ReturnDrive
      MOV  AX, 000Fh { invalid drive number }
    @@Error:
      XOR  CL, CL
      JMP  @@Done
    @@ReturnDrive:
      MOV  CL, AL
      XOR  AX, AX
    @@Done:
      MOV  DosError, AX
      MOV  AL, CL
    end;

  function GetSerialInfo(ADrive: Byte; var Buf : SerialInfo ): integer; assembler;
    asm
      MOV  AH, 69h
      MOV  AL, 00h
      MOV  BL, ADrive
      PUSH DS
      LDS  DX, Buf
      INT  21h
      POP  DS
      JC   @@Error
      XOR  AX, AX
    @@Error:
    end;

  function SetSerialInfo(ADrive: Byte; var Buf : SerialInfo) : integer; assembler;
    asm
      MOV  AH, 69h
      MOV  AL, 01h
      MOV  BL, ADrive
      PUSH DS
      LDS  DX, Buf
      INT  21h
      POP  DS
      JC   @@Error
      XOR  AX, AX
    @@Error:
    end;

  function GetSerialNumber(Drive: byte) : longInt;
    var
      TBuf : SerialInfo;
    begin
      DosError := GetSerialInfo( Drive, TBuf );
      if DosError = 0 then
        GetSerialNumber := TBuf.Serial
      else
        GetSerialNumber := 0;
    end;

  procedure SetSerialNumber(Drive: byte; Serial : LongInt);
    var
      TBuf   : SerialInfo;
    begin
      GetSerialInfo( Drive, TBuf );
      TBuf.Serial := Serial;
      if DosError = 0 then
        DosError := SetSerialInfo ( Drive, TBuf );
    end;

  function GetSerialLabel(Drive: byte) : String;                   { DOS 4.00+ }
    var
      TBuf : SerialInfo;
      S    : String;
    begin
      DosError := GetSerialInfo( Drive, TBuf );
      S[0] := #11;
      Move(TBuf.VolLabel, S[1], 11);
      if DosError = 0 then
        GetSerialLabel := S
      else
        GetSerialLabel := '           ';
    end;

  procedure SetSerialLabel(Drive: byte; SerialLabel : String);       { DOS 4.00+ }
    var
      TBuf   : SerialInfo;
    begin
      DosError := GetSerialInfo( Drive, TBuf );
      while Length(SerialLabel) < 11 do SerialLabel := SerialLabel + ' ' ;
      Move(SerialLabel[1], TBuf.VolLabel, Sizeof(TBuf.VolLabel));
      if DosError = 0 then
        DosError := SetSerialInfo( Drive, TBuf );
    end;

  function GetDiskInfoPtr(Drive : Byte) : Pointer; assembler;
    asm
      PUSH DS
      MOV  AH, 32h
      MOV  DL, Drive
      INT  21h
      MOV  DX, DS
      POP  DS
      CMP  AL, 0
      JE   @OK
      XOR  AX, AX
      MOV  AL, Drive
      PUSH AX
      CALL IsValid
      CMP  AL, False
      JE   @NotValid
      MOV  DosError, 1
    @NotValid:
      XOR  DX, DX
      XOR  AX, AX
      JMP  @Done
    @OK:
      MOV  DosError, 0
      MOV  AX, BX
    @Done:
    end;

  procedure GetFatInfo(Drive : byte; var IDByte, Clusters, Sectors, BytesPerSector : word); assembler;
    asm
      PUSH  DS
      MOV   AX, 1C00h
      MOV   DL, Drive
      INT   21h
      LES   DI, IDByte
      XCHG  SI, BX
      MOV   BL, DS:[SI]
      XOR   BH, BH
      MOV   ES:[DI], BX
      POP   DS
      LES   SI, Clusters
      MOV   ES:[SI], DX
      LES   SI, Sectors
      XOR   AH, AH
      MOV   ES:[SI], AX
      LES   SI, BytesPerSector
      MOV   ES:[SI], CX
      MOV   DosError, 0
    end;

  function GetMaxLogicalSector (Drive : byte) : LongInt; assembler;
    asm
      MOV  AL, Drive
      PUSH AX
      CALL ISValid
      CMP  AX, False
      JE   @Error
      PUSH DS
      MOV  AH, 1Ch
      MOV  DL, Drive
      XOR  AL, AL
      XOR  DH, DH
      INT  21h
      XOR  AH, AH
      MUL  DX
      POP  DS
      INC  AX
      CMP  AX, 0
      JNE  @Done
      INC  DX
      JMP  @Done
    @Error:
      XOR  AX, AX
      XOR  DX, DX
    @Done:
    end;

  function GetSectorSize (Drive : byte) : LongInt; assembler;
    asm
      MOV  AL, Drive
      PUSH AX
      CALL ISValid
      CMP  AX, False
      JE   @Error
      PUSH DS
      MOV  AH, 1Ch
      MOV  DL, Drive
      XOR  AL, AL
      XOR  DH, DH
      INT  21h
      POP  DS
      JMP  @Done
    @Error:
      XOR  CX, CX
    @Done:
      MOV  AX, CX
      XOR  DX, DX
    end;

end.